--[[ NOTE:
These standard library extensions are NOT used in Discordia. They are here as a
convenience for those who wish to use them.

There are multiple ways to implement some of these commonly used functions.
Please pay attention to the implementations used here and make sure that they
match your expectations.

You may freely add to, remove, or edit any of the code here without any effect
on the rest of the library. If you do make changes, do be careful when sharing
your expectations with other users.

You can inject these extensions into the standard Lua global tables by
calling either the main module (ex: discordia.extensions()) or each sub-module
(ex: discordia.extensions.string())
]]

local sort, concat = table.sort, table.concat
local insert, remove = table.insert, table.remove
local byte, char = string.byte, string.char
local gmatch, match = string.gmatch, string.match
local rep, find, sub = string.rep, string.find, string.sub
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
	for k, v in pairs(tbl) do
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

function math.round(n, i)
	local m = 10 ^ (i or 0)
	return floor(n * m + 0.5) / m
end

_G.Misc = {}

-- Given a path, it will check if a file exists
function Misc.fileExists(path)
	local f = io.open(path, "r")
	if f then
		io.close(f)
		return true
  end

	return false
end

-- Reads a file
function Misc.readFile(path)
	local file = io.open(path, "r") -- r read mode and b binary mode
	if not file then return end
	local content = file:read("*all") -- *a or *all reads the whole file
	file:close()
	return content
end

-- Writes a file
function Misc.writeFile(path, data)
  local writefile = io.open(path, "w")
  if not writefile then return end
  writefile:write(data)
  writefile:close()
end

-- Resolves a file in multiple paths
local resolvelist = {"", "files/", "commands/", "features/", "deps/discordia/libs/"}
function Misc.resolveFile(d)
  if type(d) == "string" then	d = {d}	end

	for k, v in ipairs(d) do
    for p, q in ipairs(resolvelist) do
			local n = q..v
		  if Misc.fileExists(n) then
			  return n
			elseif Misc.fileExists(n..".lua") then
				return n..".lua"
			end
		end
  end
end

local loadedJSON = {}
_G.loadFile = function(path)
	path = Misc.resolveFile(path)

	if string.endswith(path, '.lua') then
	  return require("../"..path)
  elseif string.endswith(path, '.json') then
		if not loadedJSON[path] then
			local t = Misc.JsonToTable(Misc.readFile(path))
			loadedJSON[path] = t
    end
		return loadedJSON[path]
	end
end

_G.saveFile = function(path, data)
	path = Misc.resolveFile(path)
	if string.endswith(path, '.json') then
		if not data then data = loadedJSON[path] end
		Misc.writeFile(path, Misc.TableToJson(data))
	end
end


local lunajson = require("json")
Misc.TableToJson = lunajson.encode
Misc.JsonToTable = lunajson.decode


-- Returns the name of a command given a message
function Misc.getCommandName(m)
  return string.sub(string.split(string.lower(m.content), " ")[1], 2)
end

-- Returns the name of a subcommand given a message
function Misc.getSubcommandName(m, lowercase)
	local s = string.split(m.content, " ")[2]
	if not s then return end
	if lowercase == false then return s end
	return string.lower(s)
end

-- Returns a list of all messgae's parameters. Set t to true to ignore subcommand. Set l to true to make everything lowercase
function Misc.getParameters(m, r, l)
	local s = m.content
	if l then
		s = string.lower(s)
	end
	local t = string.split(s, " ")

	table.remove(t, 1)
	if r then
		for i = 1, r do
			if #t == 0 then break end
				table.remove(t, 1)
		end
	end
	return t or {}
end

local perserverJSON = loadFile("perserver.json")
function Misc.getPrefix(guildID)
	if type(guildID) == "table" then guildID = Misc.getGuildID(guildID) end
	local t = perserverJSON[guildID]
	if t then return t.prefix end
	return Misc.defaultPrefix
end

function Misc.getGuildID(m)
	if m and m.guild then return m.guild.id end
	return ""
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
		local id = string.sub(s, 4, -2)
		local user = Misc.getUser(id)
		if user then
			return user.id
		end
	elseif string.startswith(s, "<@") then
			local id = string.sub(s, 3, -2)
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
		local id = string.sub(s, 3, -2)
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
		local id = string.sub(s, 4, -2)
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
	return guild.members:get(id)
end

function Misc.getName(id, guild)
	if guild then
		local member = Misc.getMember(id, guild)
		if member then return member.name end
	end
	return Misc.getUser(id).username
end


local sandbox = {}
local pp = require('pretty-print')

local function prettyLine(...)
	local ret = {}
	for i = 1, select('#', ...) do
		local arg = pp.strip(pp.dump(select(i, ...)))
		table.insert(ret, arg)
	end
	return table.concat(ret, '\t')
end

local function codeblock(str)
	return string.format('```\n%s```', str)
end

local function easyeval(code)
	return "local f = function() return "..code.." end local x = f() if type(x) == 'table' then for k, v in pairs(x) do p(k..': '..v) end else p('returns '..tostring(x)) end"
end

function Misc.exec(m, code)
	if code == "" or m.author ~= Misc.client.owner then return end

	local lines = {}
	sandbox.m = m
	sandbox.p = function(...)
		table.insert(lines, prettyLine(...))
	end
	sandbox.print = p
	sandbox.type = type
	sandbox.pairs = pairs
	sandbox.tostring = tostring
	sandbox.message = m
	sandbox.Misc = Misc

	code = code:gsub('```\n?', '') -- strip markdown codeblocks

	local fn, syntaxError = load(easyeval(code), 'DiscordBot', 't', sandbox)
	if not fn then return m:reply(codeblock(syntaxError)) end

	local success, runtimeError = pcall(fn)
	if not success then return m:reply(codeblock(runtimeError)) end

	lines = table.concat(lines, '\n')

	if #lines > 1990 then -- truncate long messages
		lines = lines:sub(1, 1990)
	end

	return m:reply(codeblock(lines))
end


function Misc.replyEmbed(m, command, data)
	if type(data) == "string" then data = {text = data} end
	command = command or {name = "-"}

	--[[
	  data:
		  - title
			- image
			- icon
			- text
			- footer
			- color
			- thumbnail
			- channel
			- guildID
			- commandName
			- description (avoid)
	]]
	local channel = data.channel or m.channel
	local commandName = data.commandName or Misc.getCommandName(m)
	local guildID = data.guildID or Misc.getGuildID(m)
	local t = {}
	t.color = data.color or 0x00FF00
	data.text = data.text or "⠀"
	data.title = data.title or command.name
	if data.description then
	  t.description = data.description
	end
	if data.icon then
		t.thumbnail = {url = data.icon}
	end
	if data.image then
		t.image = {url = data.image}
	end

	t.footer = {text = data.footer or "Do "..Misc.getPrefix(guildID).."help "..commandName.." for more help"}
	t.fields = {{name = "⠀", value = " \n"..data.text, inline = false}}
	if data.description then
		t.title = data.title
	else
		t.fields[1].name = data.title
	end
	channel:send{embed = t}
end

return {}
