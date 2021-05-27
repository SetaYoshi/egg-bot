local command = {}

command.name = "Ping"
command.info = "Quick test for the bot"
command.desc = table.join({
                            "This is a quick test to verify the bot is on",
                            "  \\• {prefix}ping - Shows the ping time to when the message is sent",
                          }, "\n")
command.trigger = {"ping", "pong", "test"}

local Time = loadFile("utils/Time")

-- Returns the ping time of a message object
local function getPing(m)
  return math.round(Time.toMilliseconds(Misc.discordia.Date() - m:getDate()))
end

command.onCommand = function(m)
  local name = Misc.getCommandName(m)
  if name == "pong" then
    Misc.replyEmbed(m, command, "Ping! `"..getPing(m).." ms`")
  else
    Misc.replyEmbed(m, command, "Pong! `"..getPing(m).." ms`")
  end
end

return command
