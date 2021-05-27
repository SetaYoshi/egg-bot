local command = {}

command.name = "Help"
command.info = "You must really need a lot of help!"
command.desc = table.join({
                            "Get a list of commands or get help on a specific command",
                            "  \\• {prefix}help - For a list of commands",
                            "  \\• {prefix}help <COMMAND TRIGGER> - Returns information about the command",
                          }, "\n")
command.trigger = {"help", "list", "commands", "cmd", "cmds"}
command.hidden = true


local iQuestion = "https://i.imgur.com/HU76y34.png"

-- This is a special modification! the viaPing parameter is meant for the helpping feature
command.onCommand = function(m, viaPing)
  local subcommand = Misc.getSubcommandName(m)
  local prefix = Misc.getPrefix(m)

  if subcommand and not viaPing then
    -- If the user used a subcommand, get the command the user is requesting help for
    local helpcommand = Misc.commandsMAP[subcommand]

    -- If a command is found, display the information of the command only
    if helpcommand then
      local desc = helpcommand.desc
      desc = string.gsub(desc, "{prefix}", prefix)
      local output = "**"..helpcommand.name.."** - "..helpcommand.info.."\n**Triggers:** "..table.join(helpcommand.trigger, ", ").."\n\n"..desc
      local icon = helpcommand.icon or iQuestion
      Misc.replyEmbed(m, command, {title = "Eggs Help!", text = output, icon = icon, footer = "Do "..prefix.."help for a list of all commands"})
    else
      local output = "Command not found"
      Misc.replyEmbed(m, command, {title = "Eggs Help!", text = output, icon = iQuestion, footer = "Do "..prefix.."help for a list of all commands"})
    end
  else
    -- Show the list of all commands
    local output = ""
    for k, v in ipairs(Misc.commands) do
      if not v.hidden then
        output = output.."**"..v.name.."** ["..v.trigger[1].."] - "..v.info.."\n"
      end
    end
    output = "To use a command: `"..prefix.."CommandTrigger`\nTo use a tag: `"..prefix..prefix.."TagName`\n\nCommand list:\n"..output.."\nDo `"..prefix.."help <command>` for a more in-depth help\nDo `"..prefix.."taglist` for a list of tags"
    Misc.replyEmbed(m, command, {title = "Eggs Help!", text = output, icon = iQuestion, footer = "Did I do good?"})
  end
end

return command
