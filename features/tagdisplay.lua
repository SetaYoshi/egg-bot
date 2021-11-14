local feature = {}

feature.name = "Tags"
feature.desc = "Use this feature to trigger already created tags. Use the tag command instead to create and manage tags!"
feature.onCommandType = "override"

local perserver = loadFile("perserver.json")

feature.onMessage = function(m, event)
  local prefix = Misc.getPrefix(m)

  -- If the prefix is used twice, that means its calling a tag
  if string.startswith(m.content, prefix..prefix) then
    event.success = true

    if not m.guild then
      -- Tags are dependent on a server, therefore it does not work in DMs
      m:reply("Tags only work in servers")
    else
      local tagName = Misc.getTagNameLC(m)
      local tagList = perserver[m.guild.id].tags

      if tagName and tagList and tagList[tagName] then
        -- If the tag exists then show it
        m:reply(table.irandomEntry(tagList[tagName].list))
      else
        -- Otherwise, inform the user they had an incorrect tag
        Misc.replyEmbed(m, {}, {title = "Tag", text = "Tag not found!", footer = "Use "..prefix.."taglist for a list of tags"})
      end
    end
  end
end

return feature
