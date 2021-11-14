-- Majority of the code was originally made by The0x539 from code originally made for the SMBX2 project. The code here is modified. Permission is granted to be used here.

local feature = {}


feature.name = "Eval"
feature.desc = "-"
feature.onCommandType = "ignore"

local inspect = require("files/inspect")

local logger = {}
logger.buffer = ""
logger.list = {}
function logger.log(s)
	table.insert(logger.list, s)
end
function logger.reset()
	logger.list = {}
	logger.buffer = ""
end



local function printString(str)
	if str == nil then
		str = ""
	end
	logger.log(str)
end

local function printValues(vals)
	for k,v in pairs(vals) do
		printString(inspect(v, {depth = 1}))
	end
end


local function printError(err)
	printString("error: " .. err:gsub("%[?.*%]?:%d+: ", "", 1))
end



-- Memoize a function with one argument.
local memo_mt = {__mode = "k"}
local function memoize(func)
	local t = {}
	setmetatable(t, memo_mt)
	return function(x)
		if t[x] then
			return unpack(t[x])
		else
			local ret = {func(x)}
			t[x] = ret
			return unpack(ret)
		end
	end
end


-- Prevent eval from writing into global namespace (unless if _G is specifically called)
local env = {}
local eval_data = {}
local env_mt = {
	__index = function(t, k) return eval_data[k] or _G[k] end,
  __newindex = function(t, k, v) eval_data[k] = v end,
}

setmetatable(env, env_mt)


local function modload(str)
	return load(str, nil, "t", env)
end
modload = memoize(modload)

-- Check whether a string is syntactically valid Lua.
local function isValid(str)
	return not not modload(str)
end
isValid = memoize(isValid)

-- Check whether a string is a valid Lua expression.
local function isExpression(str)
	return isValid("return " .. str .. ";")
end
isExpression = memoize(isExpression)


-- Evaluate a chunk. Returns its validity and its values
local function eval(chunk)
	local vals = {pcall(chunk)}

	local success = vals[1]
	table.remove(vals, 1)

	return success, vals
end

local function exec(code)
	local prefix = ""
	local suffix = ""

	if isExpression(code) then prefix = "return " end
	if not string.endswith(code, ";") then suffix = ";" end

	local chunk = modload(prefix..code..suffix)
	local success, vals = eval(chunk)

	if success then
		-- Print nil if and only if an expression returns nil
		if isExpression(code) and not isValid(code) and next(vals, nil) == nil then
			printString("nil")
		else
			printValues(vals)
		end
	else
		printError(vals[1])
	end
end


local function cmd(str)
	if isValid(str) or isExpression(str) then
		exec(str)
	else
		printError(select(2, modload(str)))
	end
end

local function run()
	local isIncomplete = false
	if not isExpression(logger.buffer) then
		local _, err = modload(logger.buffer)
		if err then
			isIncomplete = err:match("expected near '<eof>'$") or err:match("'end' expected")
		end
	end

	if isIncomplete then
		logger.buffer = logger.buffer .. "\n"
		return true
	end

	cmd(logger.buffer)
end

feature.onMessage = function(m, event)
  if m.author == Misc.client.owner and m.channel.type == Misc.enum("channelType", "private") then
    event.success = true
    logger.buffer = logger.buffer..m.content

		_G.m = m
    local isIncomplete = run()
		_G.m = nil

		if isIncomplete then
			m:addReaction("⏭️")
		else
			-- Show confirmation eval was successful if nothing is printed
			if next(logger.list, nil) == nil then
				m:addReaction("✅")
			else
				print("Eval:")
				for k, v in ipairs(logger.list) do
					m:reply(v)
					print(v)
				end
			end

			logger.reset()
		end
  end
end

return feature
