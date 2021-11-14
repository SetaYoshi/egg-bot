local command = {}

command.name = "Connect 4"
command.info = " the classic game of Connect 4!"
command.desc = table.join({
                            "Drop your pieces in the gameList board. To win, you must outsmart your opponent and have 4 of your pieces connect",
                            "  \\• connect play - To start a gameList, player 2 must then use this command to join",
                            "  \\• connect drop <COLUMN> - To drop a piece in an already started gameList",
                            "  \\• connect forfeit - To forfeit in a gameList",
                          }, "\n")
command.iconURL = "https://cdn.discordapp.com/attachments/664534457679740948/744642346481746062/unknown.png"
command.trigger = {"connect", "con"}

local sendEmbed = Misc.embedBuild(command)
local timer = loadFile("timer")
local connectJSON = loadFile("connect.json")

local gameList = {}

local ROW_HEADER = ":one::two::three::four::five::six::seven:"
local STATE_NONE = ":white_large_square:"
local STATE_RED = ":red_square:"
local STATE_YELLOW = ":yellow_square:"

local dirlist = {{-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, -1}}


local function getChainScore(board, x, y, dir, color)
  x, y = x + dir[1], y + dir[2]

  if x < 1 or x > 7 or y < 1 or y > 6 or board[x][y] ~= color then
    return 0
  else
    return 1 + getChainScore(board, x, y, dir, color)
  end
end

local function checkWin(board, x, y, color)
  -- [left upleft up upright right downright down downleft]
  local dir = {}
  for k, v in ipairs(dirlist) do
    dir[k] = getChainScore(board, x, y, v, color)
  end

  for i = 1, 4 do
    if dir[i] + dir[i + 4] >= 3 then
      return true
    end
  end
end

local function finishGame(game, type)
  if type == "lose" then
    type = "win"
    game.turn = (game.turn%2) + 1
  end

  local playerList = game.playerList
  local player1 = playerList[game.turn]
  local player2 = playerList[(game.turn%2) + 1]

  if type == "win" then
    connectJSON[player1].win = connectJSON[player1].win + 1
    connectJSON[player2].lose = connectJSON[player2].lose + 1
    saveFile("connect.json")
  elseif type == "tie" then
    connectJSON[player1].tie = connectJSON[player1].tie + 1
    connectJSON[player2].tie = connectJSON[player2].tie + 1
    saveFile("connect.json")
  end

  gameList[game.channelId] = nil
end

local function cancelGame(game, m)
  sendEmbed(m, "No one accepedted the game invitation. The game has been cancelled", {channel = Misc.getChannel(game.channelId)})
  game:finish()
end

local function forfeitGame(game, m)
  sendEmbed(m, "@"..Misc.getName(game.playerList[game.turn], m.guild).." went inactive. The game has been forfeited", {channel = Misc.getChannel(game.channelId)})
  game:finish("lose")
end

local function printGame(game, m, output)
  output = output or ""

  for j = 6, 1, -1 do
    output = output.."\n"
    for i = 1, 7 do
      output = output..game.board[i][j]
    end
  end

  output = output.."\n"..ROW_HEADER

  sendEmbed(m, output, {channel = Misc.getChannel(game.channelId)})
end


local function iniGame(m)
  local game = {}
  gameList[m.channel.id] = game

  game.playerList = {}
  game.turn = 1
  game.channelId = m.channel.id
  game.guildId = m.guild.id
  game.hasStarted = false
  game.hasFinished = false

  game.print = printGame
  game.finish = finishGame

  game.timer = timer.setTimeout(5*60000, coroutine.wrap(cancelGame), game, m)

  game.board = {}
  for i = 1, 7 do
    game.board[i] = {}
    for j = 1, 6 do
      game.board[i][j] = STATE_NONE
    end
  end

  return game
end


local playGame = Misc.scheme()

function playGame.directory(m, game)
  if game then
    if game.hasStarted then
      return "occupiedchannel"
    elseif game.playerList[1] == m.author.id then
      return "invalidplayer"
    else
      return "startgame"
    end
  else
    if m.channel.type == Misc.enum("channelType", "text") then
      return "creategame"
    else
      return "invalidchannel"
    end
  end
end

function playGame.actions.creategame(m, game)
  local game = iniGame(m)
  table.insert(game.playerList, m.author.id)

  sendEmbed(m, "Game has been created.\nPlayer 2 must do `"..Misc.getCommand(m).." play` to begin the game!")
end

function playGame.actions.startgame(m, game)
  game.playerList[2] = m.author.id
  game.hasStarted = true

  timer.clearTimeout(game.timer)
  game.timer = timer.setTimeout(5*60000, coroutine.wrap(forfeitGame), game, m)

  for _, p in ipairs(game.playerList) do
    connectJSON[p] = connectJSON[p] or {win = 0, lose = 0, tie = 0}
  end

  game:print(m, "The game has begun.\n@"..Misc.getName(game.playerList[1], m.guild)..", it is your turn!")
end

function playGame.actions.invalidplayer(m, game)
  sendEmbed(m, "You are already playing. Someone else needs to be player 2")
end

function playGame.actions.invalidchannel(m, game)
  sendEmbed(m, "You cannot create games in DMs")
end

function playGame.actions.occupiedchannel(m, game)
  sendEmbed(m, "A game has already been started")
end


local denyGame = Misc.scheme()

function denyGame.directory(m, game)
  if game and table.isearch(game.playerList, m.author.id) then
    if game.hasStarted then
      return "forfeitgame"
    else
      return "cancelgame"
    end
  end
end

function denyGame.actions.forfeitgame(m, game)
  sendEmbed(m, "The game has been forfeited")
  gameList[game.channelId] = nil
end

function denyGame.actions.cancelgame(m, game)
  sendEmbed(m, "The game has been cancelled")
  gameList[game.channelId] = nil
end


local dropPiece = Misc.scheme()

function dropPiece.directory(game, i)
  local successfulDrop = false

  local color = STATE_RED
  if game.turn == 2 then color = STATE_YELLOW end

  for j = 1, 6 do
    if game.board[i][j] == STATE_NONE then
      successfulDrop = true

      game.board[i][j] = color
      local haswon = checkWin(game.board, i, j, color)

      if haswon then
        return "gamewin"
      end
      break
    end
  end

  local isTie = true
  for i = 1, 7 do
    if game.board[i][6] == STATE_NONE then
      isTie = false
      break
    end
  end

  if isTie then
    return "gametie"
  end

  if successfulDrop then
    return "success"
  else
    return "columnfull"
  end
end


local dropGame = Misc.scheme()

function dropGame.directory(m, game, column)
  if game and game.hasStarted then
    if game.playerList[game.turn] ~= m.author.id then
      return "invalidturn"
    else
      timer.clearTimeout(game.timer)
      game.timer = timer.setTimeout(5*60000, coroutine.wrap(forfeitGame), game, m)

      if column and column > 0 and column <= 7 then
        return dropPiece(game, column)
      else
        return "invalidcolumn"
      end
    end
  end
end

function dropGame.actions.success(m, game, column)
  game.turn = (game.turn%2) + 1
  game:print(m, "@"..Misc.getName(game.playerList[game.turn], game.guildId)..", it is your turn!")
end

function dropGame.actions.gamewin(m, game, column)
  game:print(m, "@"..Misc.getName(game.playerList[game.turn], Misc.getGuild(game.guildId)).." has won!")
  game:finish("win")
end

function dropGame.actions.gametie(m, game, column)
  game:print(m, "The game has ended on a tie")
  game:finish("tie")
end

function dropGame.actions.columnfull(m, game, column)
  game:print(m, "That column is full. Please choose a different column")
end


function dropGame.actions.invalidturn(m, game, column)
  sendEmbed(m, "It's not your turn >:(")
end

function dropGame.actions.invalidcolumn(m, game, column)
  sendEmbed(m, "Invalid number, please choose between 1-7")
end




command.onCommand = function(m)
  local subcommand = Misc.getParameterLC(m, 1)
  local channelID = m.channel.id

  if subcommand == "play" then
    local game = gameList[m.channel.id]
    local result = playGame(m, game)

  elseif table.isearch({"deny", "forfeit"}, subcommand) then
    local game = gameList[m.channel.id]
    local result = denyGame(m, game)

  elseif subcommand == "drop" or tonumber(subcommand) then
    local game = gameList[m.channel.id]
    local column = tonumber(subcommand) or tonumber(Misc.getParametersLC(m, 2))
    local result = dropGame(m, game, column)

  elseif subcommand == "stat" then
    local statID = Misc.findUserID(m.guild, Misc.getParametersLC(m, 2)) or m.author.id
    local member = Misc.getMember(statID, m.guild)

    local conObj = connectJSON[statID] or {win = 0, tie = 0, lose = 0}
    output = member.name.." stats:\n"
    output = output.."**Wins: **"..conObj.win.."\n"
    output = output.."**Losses: **"..conObj.lose.."\n"
    output = output.."**Ties: **"..conObj.tie.."\n"
    output = output.."Total Games: "..(conObj.win + conObj.lose + conObj.tie)
    sendEmbed(m, output)
  else
    sendEmbed(m, "Invalid subcommand. Check `"..Misc.getPrefix(m).."help "..Misc.getTriggerLC(m.content).."` for more help")
  end
end

return command
