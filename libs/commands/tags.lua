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

local sendEmbed = Misc.embedBuild(command)
local perserver = Misc.loadJson("perserver.json")

-- Returns the name of a tag given a message. Intended use for tagdisplay feature
function Misc.getTagName(m, lowercase)
	local txt = Misc.getContent(m, lowercase)
  return string.sub(string.split(txt, " ")[1], 3)
end

function Misc.getTagNameLC(m, lowercase)
  return Misc.getTagName(m, true)
end



local addTag = Misc.scheme()

function addTag.directory(m, name, text)
  if not text or text == "" then return "invalidtext" end
  if not name or name == "" then return "invalidname" end
  local tag = perserver[m.guild.id].tags[name]

  if tag then
    if tag.authorId == m.author.id then
      return "newoption"
    else
      return "invalidauthor"
    end
  else
    return "newtag"
  end
end

function addTag.actions.newtag(m, name, text)
  local tagList = perserver[m.guild.id].tags
  tagList[name] = {list = {text}, authorId = m.author.id, created = m.timestamp}
  Misc.saveJson("perserver.json")
  sendEmbed(m, "The `"..name.."` tag has been created.\nYou can add more options to the tag via:\n`"..Misc.getPrefix(guildId).."tag add "..name.." <text>`\nYou can use you tag via:\n`"..Misc.getPrefix(guildId)..Misc.getPrefix(guildId)..name.."`")
end

function addTag.actions.newoption(m, name, text)
  local tagList = perserver[m.guild.id].tags
  local tag = tagList[name]
  table.insert(tag.list, text)
  Misc.saveJson("perserver.json")
  sendEmbed(m, "Option added! The `"..name.."` tag now has "..#tagList[name].list.." options!")
end

function addTag.actions.invalidname(m, name, text)
  sendEmbed(m, "Invalid parameters were sent.\nMake sure to format you're message like this:\n`"..Misc.getCommand(m)" add <name> <text>`")
end

addTag.actions.invalidtext = addTag.actions.invalidname

function addTag.actions.invalidauthor(m, name, text)
  sendEmbed(m, "The `"..name.."` tag is already used. Please use a different name")
end



local removeTag = Misc.scheme()

function removeTag.directory(m, name, option)
  if not name or name == "" then return "invalidname" end

  local tag = perserver[m.guild.id].tags[name]
  if not tag then return "invalidname" end
  if tag.authorId ~= m.author.id and not Misc.isCommander(m.guild, m.member) then return "invalidauthor" end  -- Using the commander system. If commander command is removed, remove Misc.isCommander too

  local maxOptionId = #tag.list

  if option == "delete" or (maxOptionId == 1) then
    return "deletetag"
  elseif not option or option < 1 or option > maxOptionId then
    return "invalidoption"
  else
    return "deleteoption"
  end
end


function removeTag.actions.deletetag(m, name, option)
  local tagList = perserver[m.guild.id].tags
  tagList[name] = nil
  Misc.saveJson("perserver.json")
  sendEmbed(m, "The `"..name.."` tag has been deleted.")
end

function removeTag.actions.deleteoption(m, name, option)
  local tag = perserver[m.guild.id].tags[name]
  table.remove(tag.list, option)
  Misc.saveJson("perserver.json")
  sendEmbed(m, "Option ("..option..") has been removed succesfully.")
end

function removeTag.actions.invalidname(m, name, option)
  sendEmbed(m, "Tag not found. To get a list of available tags use: \n`"..Misc.getCommand(m).." list`")
end

function removeTag.actions.invalidoption(m, name, option)
  sendEmbed(m, "Invalid parameters were sent.\nMake sure to format you're message like this:\n`"..Misc.getCommand(m).." remove <name> <option>`")
end

function removeTag.actions.invalidauthor(m, name, option)
  sendEmbed(m, "You are not the creator of this tag. You can only remove your own tags.")
end






command.onCommand = function(m)
  local subcommand = Misc.getParameterLC(m, 1)

  if not m.guild then m:reply("This command is for servers only") return end

  local guildId = m.guild.id
  local tagList = perserver[guildId].tags
  local name = Misc.getParameterLC(m, 2)


  -- Will create a tag, or add an option to a tag if it already exists
  if table.isearch({"add", "create", "new"}, subcommand) then
    local text = Misc.getParameters(m, 3)
    local result = addTag(m, name, text)

  -- Will delete a tag, or remove an option if it has more than one entry
elseif table.isearch({"remove", "delete"}, subcommand) then
    local option = tonumber(Misc.getParameter(m, 3))
    if subcommand == "delete" then option = "delete" end
    local result = removeTag(m, name, option)

  -- Info for the tag
  elseif not subcommand or table.isearch({"list", "info"}, subcommand) then
    local tagList = perserver[m.guild.id].tags
    local tag = tagList[name]

    if not name or not tag then
      local output  = ""
      if name and not tag then
        output = "**Tag not found.** Available tags:\n"..output
      end
      local keys = table.keys(tagList)
      if keys and keys[1] then
        output = output.."Available tags:\n"
        output = output..table.join(keys, ", ")
      else
        output = output.."There are no tags available. Use `"..Misc.getPrefix(m).."tag create <NAME> <TEXT>` to create your very own tags!"
      end
      sendEmbed(m, output)
    else
      local output = "**"..name.."**\nBy: "..Misc.getName(tag.authorId, m.guild).."\n"
      for k, v in ipairs(tag.list) do
        output = output..k..") "..v.."\n"
      end
      sendEmbed(m, output)
    end
  else
    sendEmbed(m, "Invalid subcommand. Check `"..Misc.getPrefix(m).."help "..Misc.getTriggerLC(m).."` for more help")
  end
end

return command
