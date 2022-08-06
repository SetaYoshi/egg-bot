local feature = {}

feature.name = "Help ping"
feature.desc = "@ me to get the help message. Useful for when you forget the bot's prefix"
feature.onCommandType = "override"


feature.onMessage = function(m, event)
  if m.mentionedUsers.first == Misc.client.user and Misc.commandsMAP[Misc.getParametersLC(m)] and Misc.commandsMAP[Misc.getParametersLC(m)].name == "Help" then
    event.success = true
    Misc.commandsMAP.help.onCommand(m, true)
  end
end

return feature
