--[[ NOTE:
There are multiple ways to implement some of these commonly used functions.
Please pay attention to the implementations used here and make sure that they
match your expectations.
]]

local sort, concat = table.sort, table.concat
local insert, remove = table.insert, table.remove
local byte, char = string.byte, string.char
local gmatch, match = string.gmatch, string.match
local rep, find, sub, lower = string.rep, string.find, string.sub, string.lower
local min, max, random = math.min, math.max, math.random
local ceil, floor = math.ceil, math.floor

function table.count(tbl)
	local n = 0
	for _ in pairs(tbl) do
		n = n + 1
	end
	return n
end

function table.deepcount(tbl)
	local n = 0
	for _, v in pairs(tbl) do
		n = type(v) == 'table' and n + table.deepcount(v) or n + 1
	end
	return n
end

function table.copy(tbl)
	local ret = {}
	for k, v in pairs(tbl) do
		ret[k] = v
	end
	return ret
end

function table.deepcopy(tbl)
	local ret = {}
	for k, v in pairs(tbl) do
		ret[k] = type(v) == 'table' and table.deepcopy(v) or v
	end
	return ret
end

function table.reverse(tbl)
	for i = 1, #tbl do
		insert(tbl, i, remove(tbl))
	end
end

function table.reversed(tbl)
	local ret = {}
	for i = #tbl, 1, -1 do
		insert(ret, tbl[i])
	end
	return ret
end

function table.keys(tbl)
	if not tbl then return end
	local ret = {}
	for k in pairs(tbl) do
		insert(ret, k)
	end
	return ret
end

function table.map(tbl)
	local t = {}
	for k, v in pairs(tbl) do
		t[v] = true
	end
	return t
end

function table.values(tbl)
	local ret = {}
	for _, v in pairs(tbl) do
		insert(ret, v)
	end
	return ret
end

function table.irandomPair(tbl)
	local i = random(#tbl)
	return i, tbl[i]
end

function table.randomPair(tbl)
	local rand = random(table.count(tbl))
	local n = 0
	for k, v in pairs(tbl) do
		n = n + 1
		if n == rand then
			return k, v
		end
	end
end

function table.irandomEntry(tbl)
	local _, v = table.irandomPair(tbl)
	return v
end

function table.sorted(tbl, fn)
	local ret = {}
	for i, v in ipairs(tbl) do
		ret[i] = v
	end
	sort(ret, fn)
	return ret
end

function table.search(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			return k
		end
	end
	return nil
end

function table.isearch(tbl, value)
	for k, v in ipairs(tbl) do
		if v == value then
			return k
		end
	end
	return nil
end

function table.slice(tbl, start, stop, step)
	local ret = {}
	for i = start or 1, stop or #tbl, step or 1 do
		insert(ret, tbl[i])
	end
	return ret
end

function table.join(tbl, str)
	if tbl[1] then
		return table.concat(tbl, str)
	else
    local i = 0
		local j = table.count(tbl)
		local s = ""
		for k, v in pairs(tbl) do
			i = i + 1
			if i == j then
				s = s..v
				return s
			else
				s = s..v..str
			end
		end
	end
	return ""
end

function table.share(t1, t2)
  for _, v in pairs(t1) do
		for _, j in pairs(t2) do
			if v == j then return true end
		end
	end
end

function table.ishare(t1, t2)
  for _, v in ipairs(t1) do
		for _, j in ipairs(t2) do
			if v == j then return true end
		end
	end
end

function string.split(str, delim)
	local ret = {}
	if not str then
		return ret
	end
	if not delim or delim == '' then
		for c in gmatch(str, '.') do
			insert(ret, c)
		end
		return ret
	end
	local n = 1
	while true do
		local i, j = find(str, delim, n)
		if not i then break end
		insert(ret, sub(str, n, i - 1))
		n = j + 1
	end
	insert(ret, sub(str, n))
	return ret
end

function string.trim(str)
	return match(str, '^%s*(.-)%s*$')
end

function string.pad(str, len, align, pattern)
	pattern = pattern or ' '
	if align == 'right' then
		return rep(pattern, (len - #str) / #pattern) .. str
	elseif align == 'center' then
		local pad = 0.5 * (len - #str) / #pattern
		return rep(pattern, floor(pad)) .. str .. rep(pattern, ceil(pad))
	else -- left
		return str .. rep(pattern, (len - #str) / #pattern)
	end
end

function string.startswith(str, start)
  return str:sub(1, #start) == start
end

function string.endswith(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

function string.levenshtein(str1, str2)

	if str1 == str2 then return 0 end

	local len1 = #str1
	local len2 = #str2

	if len1 == 0 then
		return len2
	elseif len2 == 0 then
		return len1
	end

	local matrix = {}
	for i = 0, len1 do
		matrix[i] = {[0] = i}
	end
	for j = 0, len2 do
		matrix[0][j] = j
	end

	for i = 1, len1 do
		for j = 1, len2 do
			local cost = byte(str1, i) == byte(str2, j) and 0 or 1
			matrix[i][j] = min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end

	return matrix[len1][len2]
end

function string.random(len, mn, mx)
	local ret = {}
	mn = mn or 0
	mx = mx or 255
	for _ = 1, len do
		insert(ret, char(random(mn, mx)))
	end
	return concat(ret)
end

function math.clamp(n, minValue, maxValue)
	return min(max(n, minValue), maxValue)
end

function math.knot(n, minValue, maxValue)
  if n > maxValue then
		return minValue
	elseif n < minValue then
		return maxValue
	end
	return n
end

function math.round(n, i)
	local m = 10 ^ (i or 0)
	return floor(n * m + 0.5) / m
end

-- Namespace meant to contain a variety of helper functions
_G.Misc = {}

-- More aliases
local fs = require("fs")
Misc.fileExists = fs.existsSync
Misc.readFile = fs.readFileSync
Misc.writeFile = fs.writeFileSync

local loadedJSON = {}
function Misc.loadJson(filename)
	if not loadedJSON[filename] then
		local t = Misc.jsonToTable(Misc.readFile("libs/files/"..filename))
		loadedJSON[filename] = t
	end
	return loadedJSON[filename]
end

function Misc.saveJson(filename, data)
	if not data then data = loadedJSON[filename] end
	Misc.writeFile("libs/files/"..filename, Misc.tableToJson(data))
end

-- gone forever?
-- -- Resolves a file in multiple paths
-- local resolvelist = {"", "files/", "commands/", "features/", "deps/discordia/libs/"}
-- function Misc.resolveFile(d)
--   if type(d) == "string" then	d = {d}	end
--
-- 	for k, v in ipairs(d) do
--     for p, q in ipairs(resolvelist) do
-- 			local n = q..v
-- 		  if Misc.fileExists(n) then
-- 			  return n
-- 			elseif Misc.fileExists(n..".lua") then
-- 				return n..".lua"
-- 			end
-- 		end
--   end
-- end

-- local luaLibs = table.map({"discordia", "json", "timer", "fs", "pretty-print"}) --prob needs more included here
-- local loadedJSON = {}
-- _G.loadFile = function(path)
-- 	if luaLibs[path] then
-- 		return require(path)
-- 	end
-- 	path = Misc.resolveFile(path)
--
-- 	if string.endswith(path, '.lua') then
-- 	  return require("../"..path)
--   elseif string.endswith(path, '.json') then
-- 		if not loadedJSON[path] then
-- 			local t = Misc.jsonToTable(Misc.readFile(path))
-- 			loadedJSON[path] = t
--     end
-- 		return loadedJSON[path]
-- 	end
-- end
--
-- _G.saveFile = function(path, data)
-- 	path = Misc.resolveFile(path)
-- 	if string.endswith(path, '.json') then
-- 		if not data then data = loadedJSON[path] end
-- 		Misc.writeFile(path, Misc.tableToJson(data))
-- 	end
-- end

-- Aliases
local lunajson = require("json")
Misc.tableToJson = lunajson.encode
Misc.jsonToTable = lunajson.decode

function Misc.getContent(m, lowercase)
	local s
	if type(m) == "string" then
		s = m
	else
		s = m.content
	end
	if lowercase then
		s = lower(s)
	end
	return s
end

local perserverJSON = Misc.loadJson("perserver.json")
function Misc.getPrefix(guildID)
	if type(guildID) == "table" then guildID = (guildID.guild or {}).id end
	local t = perserverJSON[guildID]
	if t then return t.prefix end
	return Misc.defaultPrefix
end

function Misc.getCommand(m, lowercase)
	local txt = Misc.getContent(m, lowercase)
	return string.split(txt, " ")[1]
end

-- Given a message, it returns the command used (first word without the prefix)
function Misc.getTrigger(m, lowercase)
	local txt = Misc.getContent(m, lowercase)
	return sub(string.split(txt, " ")[1], 2)
end

-- Returns the parameter at position i
function Misc.getParameter(m, i, lowercase)
	local txt = Misc.getContent(m, lowercase)
  return string.split(txt, " ")[i + 1]
end

-- Returns a string of parameters at position between position b to f. If b or f are blank, its defaulted to beggining and finish of the mesage respectively
function Misc.getParameters(m, b, f, lowercase)
	local txt = Misc.getContent(m, lowercase)
	local list = string.split(txt, " ")
	table.remove(list, 1)

	local b = b or 1
	local f = f or #list
	local out = {unpack(list, b, f)}

	return table.join(out, " ")
end

-- Similar to getParameters, except it returns each parameter in a table instead of a string
function Misc.getParametersList(m, b, f, lowercase)
	local txt = Misc.getContent(m, lowercase)
	local list = string.split(txt, " ")
	table.remove(list, 1)

	local b = b or 1
	local f = f or #list
	return {unpack(list, b, f)}
end

-- These functions work identical to the ones above except they return its contents in lowercase (LC)
function Misc.getCommandLC(m)
	return Misc.getCommand(m, true)
end

function Misc.getTriggerLC(m)
	return Misc.getTrigger(m, true)
end

function Misc.getParameterLC(m, i)
	return Misc.getParameter(m, i, true)
end

function Misc.getParametersLC(m, b, f)
	return Misc.getParameters(m, b, f, true)
end

function Misc.getParametersListLC(m, b, f)
	return Misc.getParametersList(m, b, f, true)
end


-- Returns the ID of a user. Where s can be an ID, a user name, nickname, or a user mention
function Misc.findUserID(guild, s)
	if not s then return end
	if type(guild) == "string" then guild = Misc.getGuild(guild) end

	-- First check if the input is an already valid ID
	local user = Misc.client.users:get(s)
	if user then
		return user.id
	end

	-- Check if the input is a user mention
	if string.startswith(s, "<@!") then
		local id = sub(s, 4, -2)
		local user = Misc.getUser(id)
		if user then
			return user.id
		end
	elseif string.startswith(s, "<@") then
			local id = sub(s, 3, -2)
			local user = Misc.getUser(id)
			if user then
				return user.id
			end
	else
		-- Otherwise check if the input is a user name
		s = string.lower(s)
		local list, f
		if guild then
		 list = guild.members
		 f = function(m)
			 if string.lower(m.user.username) == s or (m.nickname and string.lower(m.nickname)) == s then
				 return true
			 end
		 end
	 else
		 list = Misc.client.users
		 f = function(u)
			 if string.lower(u.username) == s then
				 return true
			 end
		 end
	 end

		local user = list:find(f)
		if user then
			if guild then return user.user.id end
			return user.id
		end
	end
end

-- Returns the ID of a channel. Where s can be an ID, a channel name, or a channel mention
function Misc.findTextChannelID(guild, s)
	if not s then return end

	-- First check if the input is an already valid ID
	local channel = guild.textChannels:get(s)
	if channel then
		return channel.id
	end

	-- Check if the input is a channel mention
  if string.startswith(s, "<#") then
		local id = sub(s, 3, -2)
		local channel = guild.textChannels:get(id)
		if channel then
			return channel.id
		end
	else
		-- Otherwise check if the input is a channel name
    s = string.lower(s)
		local channel = guild.textChannels:find(function(c)
			if string.lower(c.name) == s then
				return true
			end
		end)
		if channel then
			return channel.id
		end
	end
end

-- Returns the ID of a role. Where s can be an ID, a role name, or a role mention
function Misc.findRoleID(guild, s)
	if not s then return end

	-- First check if the input is an already valid ID
	local role = guild.roles:get(s)
	if role then
		return role.id
	end

	-- Check if the input is a role mention
	if string.startswith(s, "<@&") then
		local id = sub(s, 4, -2)
		local role = guild.roles:get(id)
		if role then
			return role.id
		end
	else
		-- Otherwise check if the input is a role name
		s = string.lower(s)
		local role = guild.roles:find(function(r)
			if string.lower(r.name) == s then
				return true
			end
		end)
		if role then
			return role.id
		end
	end
end

function Misc.getGuild(id)
	return Misc.client:getGuild(id)
end

function Misc.getUser(id)
	return Misc.client:getUser(id)
end

function Misc.getChannel(id)
	return Misc.client:getChannel(id)
end

function Misc.getRole(id)
	return Misc.client:getRole(id)
end

function Misc.getMember(id, guild)
	if type(guild) == "string" then guild = Misc.getGuild(guild) end
	return guild.members:get(id)
end

function Misc.getName(id, guild)
	if guild then
		if type(guild) == "string" then guild = Misc.getGuild(guild) end
		local member = Misc.getMember(id, guild)
		if member then return member.name end
	end
	return Misc.getUser(id).username
end

-- Expose the enum stuff into the Misc class for easy access
function Misc.enum(class, type)
	return Misc.discordia.enums[class][type]
end

function Misc.enumId(class, type)
	return Misc.discordia.enums[class](type)
end


local schemeMt = {
	__call = function(t, ...)
		local result = t.directory(...)
		if result and t.actions[result] then
			t.actions[result](...)
		end
		return result
	end
}

function Misc.scheme(logic, actions)
  local scheme = {actions = {}, directory = function() end}
	setmetatable(scheme, schemeMt)
	return scheme
end



--[[

	Misc.replyEmbed(messageObj, "My message") -- defaults the channel of that of the message
	Misc.replyEmbed(messageObj, data) -- data can also be a table with all your settings
	Misc.replyEmbed(data)  -- you can also ignore the message shortcut and just do this

	data:
	- channel [m.channel]
	- title [" "]
	- text [" "]
	- footer [" "]
	- color [0x00FF00]
	- imageURL
	- iconURL
	- description (avoid)
]]
function Misc.replyEmbed(m, data)
	if not data then data = m end
	if type(data) == "string" then data = {text = data} end
  local embed = {}

	local channel = data.channel or m.channel

  data.text = data.text or "⠀"
	data.title = data.title or " "

  embed.color = data.color or 0x00FF00
	embed.description = data.description
	embed.footer = data.footer or "⠀"

	if type(embed.footer) == "string" then
	  embed.footer = {text = data.footer}
	end
	if data.iconURL then
		embed.thumbnail = {url = data.iconURL}
	end
	if data.imageURL then
		embed.image = {url = data.imageURL}
	end

	if embed.description then
		embed.title = data.title
	elseif data.fields then
		embed.fields = {}
		embed.title = data.title
		for k, v in ipairs(data.fields) do
			if type(v) == "string" then
				table.insert(embed.fields, {name = " ", value = " \n"..v, inline = false})
			else
				table.insert(embed.fields, v)
			end
		end
	else
		embed.fields = {{name = data.title, value = " \n"..data.text, inline = false}}
	end

	channel:send{embed = embed}
end

-- This is a shorcut meant for sending embeds for responses from commands.
--[[
  local sendEmbed = Misc.embedBuild(command)
	...
	-- The function is flexible! All these calls are valid
	sendEmbed(messageObj, "I am some text")
	sendEmbed(messageObj, "I am some text", {footer = "Override the default footer!", iconURL = "https://imgur.com/aIxCWjn.png"})
	sendEmbed(messageObj, {text = "I am some text", footer = "Override the default footer!", iconURL = "https://imgur.com/aIxCWjn.png"})
]]

function Misc.embedBuild(command)
	return function(m, data, dataPlus)
		if dataPlus then
			dataPlus.text = data
			data = dataPlus
		else
			if type(data) == "string" then data = {text = data} end
		end
		data.title = data.title or command.name
		data.footer = data.footer or "Do "..Misc.getPrefix(m).."help "..Misc.getTriggerLC(m).." for more help"

		Misc.replyEmbed(m, data)
	end
end

return {}
