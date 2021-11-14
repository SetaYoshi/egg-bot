local command = {}

command.name = "Ping"
command.info = "Quick test for the bot"
command.desc = table.join({
                            "This is a quick test to verify the bot is on",
                            "  \\• {prefix}ping - Shows the ping time to when the message is sent",
                          }, "\n")
command.trigger = {"ping", "pong", "test"}

local sendEmbed = Misc.embedBuild(command)
local Time = Misc.discordia.Time

-- Returns the ping time of a message object
local function getPing(m)
  return math.round(Time.toMilliseconds(Misc.discordia.Date() - m:getDate()))
end

command.onCommand = function(m)
  local name = Misc.getTriggerLC(m)
  if name == "pong" then
    sendEmbed(m, "Ping! `"..getPing(m).." ms`")
  else
    sendEmbed(m, "Pong! `"..getPing(m).." ms`")
  end
end

return command
