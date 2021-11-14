local command = {}

command.name = "Commander"
command.info = "Manage commander roles"
command.desc = table.join({
                            "Users with commander roles get access to moderator permissions within the bot",
                            "  \\• {prefix}connect list - Shows a list of current commander roles",
                            "  \\• {prefix}commander <ROLE> - Makes the role a commander. If it is already a commander, it removes it. ROLE can be a rold ID, role name, or role ping",
                          }, "\n")
command.trigger = {"commander"}

local sendEmbed = Misc.embedBuild(command)
local perserverJSON = loadFile("perserver.json")

-- You can add extra Misc functions in command files too!
-- Checks if a member has a commander role
function Misc.isCommander(guild, member)
  if member == guild.owner then return true end  -- A server owner is automatically a commander
  return table.ishare(perserverJSON[guild.id].commander, member.roles:toArray())
end

command.onCommand = function(m)
  local param = Misc.getParametersLC(m)
  local commanderList = perserverJSON[m.guild.id].commander

  if not m.guild then
    sendEmbed(m, "This command is for servers only")
  elseif m.member ~= m.guild.owner then
    sendEmbed(m, "This command is for server owners only")
  elseif param == "list" then
    local commanderCount = #commanderList
    if commanderCount == 0 then
      sendEmbed(m, "No commander roles have been set")
    else
      local output = "Commanders:\n"
      for i = commanderCount, 1, -1 do
        local roleID = commanderList[i]
        local role = Misc.getRole(roleID)
        if not role then
          table.remove(commanderList, i)
        else
          output = output.."\\• ["..role.id.."] @"..role.name.."\n"
        end
      end
      sendEmbed(m, output)
      saveFile("perserver.json")
    end
  else
    local role = Misc.findRoleID(m.guild, param)
    if role then
      local isFound = table.isearch(commanderList, role)
      if isFound then
        table.remove(commanderList, isFound)
        sendEmbed(m, "Role removed")
      else
        table.insert(commanderList, role)
        sendEmbed(m, "Role added")
      end
      saveFile("perserver.json")
    else
      sendEmbed(m, "Role not found")
    end
  end
end

return command
