local command = {}

command.name = "Tag"
command.info = "Manage and edit tags"
command.desc = table.join({
                            "You can create your very own custom commands! Use {prefix}{prefix}TagName to use a tag. A tag can be a simple response, or you can add multiple options and it will reposond with a random option",
                            "  \\• `{prefix}tag list` - For a list of tags",
                            "  \\• `{prefix}tag create <NAME> <TEXT>` - Creates a new tag under the specified name. If the name already exists then it will add the text as an option",
                            "  \\• `{prefix}tag remove <NAME> <OPTION>` - Removes the option from the specified tag. Use the info subcommand to know what option to use",
                            "  \\• `{prefix}tag delete <NAME>` - Deletes the tag and all of its options",
                            "  \\• `{prefix}tag info <NAME>` - Returns information about the tag and a list of all options"
                          }, "\n")
command.trigger = {"tag", "taglist", "show"}

local perserver = loadFile("perserver.json")

-- Returns the name of a tag given a message. Intended use for tagdisplay feature
function Misc.getTagName(m)
  return string.sub(string.split(string.lower(m), " ")[1], 3)
end

local function addTag(m, name, text)
  if not text or text == "" then return "invalidtext" end
  if not name or name == "" then return "invalidname" end

  local tagList = perserver[m.guild.id].tags
  local tag = tagList[name]

  if tag then
    if tag.authorId == m.author.id then
      table.insert(tag.list, text)
      saveFile("perserver.json")
      return "newoption"
    else
      return "invalidauthor"
    end
  else
    tagList[name] = {list = {text}, authorId = m.author.id, created = m.timestamp}
    saveFile("perserver.json")
    return "newtag"
  end
end

local function removeTag(m, name, option)
  if not name or name == "" then return "invalidname" end

  local tagList = perserver[m.guild.id].tags
  local tag = tagList[name]

  if not tag then return "invalidname" end
  if tag.authorId ~= m.author.id and not Misc.isCommander(m.guild, m.member) then return "invalidauthor" end  -- Using the commander system. If commander command is removed, remove Misc.isCommander too

  local maxOptionId = #tag.list

  if option == "delete" or (maxOptionId == 1) then
    tagList[name] = nil
    saveFile("perserver.json")
    return "deletetag"
  elseif not option or option < 1 or option > maxOptionId then
    return "invalidoption"
  else
    table.remove(tag.list, option)
    return "invalidoption"
  end
end


command.onCommand = function(m)
  local subcommand = Misc.getSubcommandName(m)
  local params = Misc.getParameters(m, 1)

  if not m.guild then m:reply("This command is for servers only") return end

  local guildId = m.guild.id
  local tagList = perserver[guildId].tags

  local name = params[1]
  if name then name = string.lower(name) end  -- Lowercase the name to prevent case-sensitive tags


  -- Will create a tag, or add an option to a tag if it already exists
  if subcommand == "add" or subcommand == "create" or subcommand == "new" then
    local text = table.join(Misc.getParameters(m, 2), " ")
    local result = addTag(m, name, text)

    if result == "newtag" then
      Misc.replyEmbed(m, command, "The `"..name.."` tag has been created.\nYou can add more options to the tag via:\n`"..Misc.getPrefix(guildId).."tag add "..name.." <text>`\nYou can use you tag via:\n`"..Misc.getPrefix(guildId)..Misc.getPrefix(guildId)..name.."`")
    elseif result == "newoption" then
      Misc.replyEmbed(m, command, "Option added! The `"..name.."` tag now has "..#tagList[name].list.." options!")
    elseif result == "invalidname" or result == "invalidtext" then
      Misc.replyEmbed(m, command, "Invalid parameters were sent.\nMake sure to format you're message like this:\n`"..Misc.getPrefix(guildId).."tag add <name> <text>`")
    elseif result == "invalidauthor" then
      Misc.replyEmbed(m, command, "The `"..name.."` tag is already used. Please use a different name")
    end

  -- Will delete a tag, or remove an option if it has more than one entry
  elseif subcommand == "remove" or subcommand == "delete" then
    local option = tonumber(table.join(Misc.getParameters(m, 2), " "))
    if subcommand == "delete" then option = "delete" end
    local result = removeTag(m, name, option)

    if result == "deletetag" then
      Misc.replyEmbed(m, command, "The `"..name.."` tag has been deleted.")
    elseif result == "deleteoption" then
      Misc.replyEmbed(m, command, "Option ("..option..") has been removed succesfully.")
    elseif result == "invalidname" then
      Misc.replyEmbed(m, command, "Tag not found. To get a list of available tags use: \n`"..Misc.getPrefix(guildId).."tag list`")
    elseif result == "invalidoption" then
      Misc.replyEmbed(m, command, "Invalid parameters were sent.\nMake sure to format you're message like this:\n`"..Misc.getPrefix(guildId).."tag remove <name> <option>`")
    elseif result == "invalidauthor" then
      Misc.replyEmbed(m, command, "You are not the creator of this tag. You can only remove your own tags.")
    end

  -- Info for the tag
  elseif subcommand == "list" or subcommand == "info" or not subcommand then
    local tagList = perserver[m.guild.id].tags
    local tag = tagList[name]

    if not name or not tag then
      local output  = ""
      if name and not tag then
        output = "**Tag not found.** Available tags:\n"..output
      end
      local keys = table.keys(tagList)
      if keys then
        output = output..table.join(keys, ", ")
      else
        output = output.."There are no tags available. Use `"..Misc.getPrefix(m).."tag create <TEXT>` to create your very own tags!"
      end
      Misc.replyEmbed(m, command, {text = output})
    else
      local output = "**"..name.."**\nBy: "..Misc.getName(tag.authorId, m.guild).."\n"
      for k, v in ipairs(tag.list) do
        output = output..k..") "..v.."\n"
      end
      Misc.replyEmbed(m, command, output)
    end
  else
    Misc.replyEmbed(m, command, "Invalid subcommand. Check `"..Misc.getPrefix(m).."help "..Misc.getCommandName(m).."` for more help")
  end
end

return command
