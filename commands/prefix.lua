local command = {}

command.name = "Prefix"
command.info = "Change the prefix for the server"
command.desc = "Change the prefix for the server. The prefix for the tags will be the prefix twice. The prefix must be a single character"
command.trigger = {"prefix", "setprefix"}

local perserverJSON = loadFile("perserver.json")

command.onCommand = function(m)
  local subcommand = Misc.getSubcommandName(m)

  if not m.guild then
    m:reply('this command is for servers only')
  elseif subcommand and Misc.isCommander(m.guild, m.member) then
    perserverJSON[m.guild.id].prefix = string.sub(subcommand, 1, 1)
    saveFile("perserver.json")
    m:reply('Prefix has been changed')
  else
    m:reply('nah')
  end
end

return command
