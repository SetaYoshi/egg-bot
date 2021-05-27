local command = {}

command.name = "XKCD Comic"
command.info = "Get a XKCD comic"
command.desc = table.join({
                            "I will show you kxcd webcomics!",
                            "  \\• {prefix}kxcd - Returns a random comic",
                            "  \\• {prefix}kxcd latest - For the latest comic",
                            "  \\• {prefix}kxcd <ID> - Returns the comic with the provided ID",
                          }, "\n")
command.trigger = {"xkcd", "kxcd", "comic"}

local http = loadFile("deps/coro-http")

local baseURL = "https://xkcd.com/"

-- Returns the max amount of comics available
local function requestMaxComicId()
  local _, body = http.request("GET", baseURL.."info.0.json")
  if body then
    local comic = Misc.JsonToTable(body)
    return comic.num
  end
end

-- Returns a comic object. If n is blank, returns the latest comic. If n is a valid comic ID, returns the specific comic
local function requestComic(n)
  local url = baseURL

  if n then
    url = url..n.."/"
  end
  url = url.."info.0.json"

  local _, body = http.request("GET", url)
  if body then
    return Misc.JsonToTable(body)
  end
end

-- Print an error message is a request is not returned
local function printError(m)
  Misc.replyEmbed(m, command, "Oh no! Something went wrong in finding the comic :(")
end

-- Print the comic with this specific format
local function printComic(m, comic)
  Misc.replyEmbed(m, command, {title = comic.safe_title.." ("..comic.num..")", image = comic.img, footer = comic.alt, text = "Published in "..comic.year.."/"..comic.month.."/"..comic.day})
end



command.onCommand = function(m)
  local subcommand = Misc.getSubcommandName(m)

  if not subcommand then -- Random comic
    local maxComicId = requestMaxComicId()
    if not maxComicId then printError(m) return end

    local comic = requestComic(math.random(1, maxComicId))
    if not comic then printError(m) return end

    printComic(m, comic)
  elseif subcommand == "latest" or subcommand == "new" then  -- latest comic
    local comic = requestComic()
    if not comic then printError(m) return end

    printComic(m, comic)
  else -- specific comic
    local maxComicId = requestMaxComicId()
    if not maxComicId then printError(m) return end

    local commandId = tonumber(subcommand)
    if commandId and commandId > 0 and commandId <= maxComicId then
      local comic = requestComic(commandId)
      if not comic then printError(m) return end

      printComic(m, comic)
    else
      Misc.replyEmbed(m, command, "Invalid ID! The ID range is from 1 to "..maxComicId)
    end
  end
end

return command
