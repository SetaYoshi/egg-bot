--[[
  HOW TO MAKE YOUR BOT

  Thank you for choosing egg bot to startup and make your bot. Before you begin, I will explain how this bot is orginized so you
  can begin adding all the fun stuff you want! As a note, I highly encorage to chamge as much as you want, don't feel that you are limited by what I offer.
  You can add/modify as much as you want so it suits your own needs

  ========================
  ==== BOT'S WORKFLOW ====
  ========================
  The bot is divided into two parts: commands and features

  COMMANDS:
    The bot has an easy to use system for managing all the commands. A command is a function that does 'something' when the command is called. This bot is
    presented so commands are the promary usage for the bot. There are a lot of neat helper functions so the process of making a command is easy, streamlined,
    flexible, and fast!

  FEATURES:
    Features is for everything else that is not a command. Here you can do more complex things, such as, banning certain words, making greeting messages, or
    even logging data (message edits, message deletions, channel creation, etc). The point is, anything that you want the bot to do that isn't acommand is a feature

  ====================================
  ==== WHATS IN THIS INSTALLATION ====
  ====================================
  /commands
    Here is a list of all the command files. Only lua files should go here. All command files are automatically loaded

  /features
    Here is a list of all the feature files. Only lua files should go here. All feature files are automatically loaded

  /files
    This is a folder in which you can drop in whatever you want. Use it to store user data, images, libraries, etc.

  Startup.bat
    This bat file is a shorcut for starting up the bot. Open it with notepad to change the main.lua directory or the name of the window title

  main.lua
    The file you are looking right now! This is the glue that makes all the other files work.

  /files/luaextensions.lua
    Built-in file that includes a massive collection of helper functions. The whole artitechture of this bot relies on this file

  /files/token.lua
    Built-in file to store all your important tokens and passwords. Store sensitive information here instead of other files to avoid 'accidentally' sharing it. Technically optional

  /files/perserver.json
    Built-in file JSON file used for the purpose to store unique data for every server. Technically optional

  ==============================
  ==== ANATOMY OF A COMMAND ====
  ==============================
  This is how you should define each command file. Take a look at the ones included to get a feel how a command file works!

  local command = {}

  command.name = "" -- The display name for the command
  command.info = "" -- A quick tip about the command that will be shown in the built-in help command. Try keeping it a sentence long
  command.desc = "" -- This is what will be shown in the built-in help command. Be as detailed as possible! Any use of '{prefix}' will be automatically subbed in for the actual prefix
  command.trigger = {"", ""} -- This is a list of strings. A trigger is what a user needs to use to call a command. Note that 'name' and 'trigger' are not the same thing
  command.onCommand = function(message) -- This function will be called when the command is triggered by the user. Only one parameter is passed and it is the message object

  command.icon = ""  -- You can optionally add an image URL that will be used on the built-in help command
  command[EVENT_HANDLE] = function(...) -- You can optionally use any of the event handlers below to use for your commands
  command.hidden = bool -- You can optionally marked as a command as hidden. What this means is that it will not show up on the built-in help command

  return command

  ==============================
  ==== ANATOMY OF A FEATURE ====
  ==============================
  This is how you should define each feature file. Take a look at the ones included to get a feel how a feature file works!

  local feature = {}

  feature.name = "" -- The display name for the feature
  feature.desc = "" -- This is what will be shown in the built-in help command. Be as detailed as possible!
  feature.onCommandType = "" -- Can be "ignore", "override", or "both".
    What this is for is to provide a solution to conflics for when a command and feature are triggered at the same time
    "ignore": If a feature and command are both triggered, do command only, ignore feature
    "override": If a feature and command are both triggered, ignore the command, do feature only
    "both": If a feature and command are both triggered, do both
  feature.onMessage = function(message) return success -- This function will be called when a message is sent. The calling behavior changes depending on 'onCommandType. If returned true, the system will assume the feature is 'successful' in the sense that a message was sent

  feature[EVENT_HANDLE] = function(...) -- You can optionally use any of the event handlers below to use for your commands

  return feature

  =============================
  ==== ADDING MORE HANDLES ====
  =============================
  Right now, the only handles are: ready, guildCreate, memberJoin, memberLeave. You can add more if needed.
  List of all events: https://github.com/SinisterRectus/Discordia/wiki/Events
  Take a look at how memberJoin and memberLeave are set up in the bottom of this file so you can add your own!

  ======================
  ==== SO WHAT NOW? ====
  ======================
  Make your bot! I hope you have been convinced to use my little framework to begin making fun commands to your bot!
  If you are feeling bored and have nothing to do, feel free to share with me (author) your own creations you have made with this.
  My discord username is SetaYoshi, I am in the discordia server if you need me
  You can also DM me if you need help, feedback, suggestions, or yell at me if you have complaints
  ~ SetaYoshi
]]


local ext = require('./files/luaextensions.lua') -- Load all helpful extensions
local discordia = require('discordia')
local client = discordia.Client()
local prefix = "!"  -- Default prefix. The bot will use this prefix in DMs and when joining a server
local token = loadFile("token").DISCORD


-- Store the client so commands have access to it
Misc.discordia = discordia
Misc.client = client
Misc.defaultPrefix = prefix


local perserver = loadFile("perserver.json")

-- Ensures that the guildID has proper perserver data, if not then default it
local function perserverCheck(guildID)
  perserver[guildID] = perserver[guildID] or {}
  local t = perserver[guildID]
  t.prefix = t.prefix or prefix
  t.commander = t.commander or {}
  t.tags = t.tags or {}
end

-- Table of commands
Misc.commands = {}
Misc.commandsMAP = {}
local commands = Misc.commands
local commandsMAP = Misc.commandsMAP

local commandFileList = {}
for dir in io.popen([[dir "./commands" /b]]):lines() do
  table.insert(commandFileList, dir)
end

-- Table of features
Misc.features = {}
local features = Misc.features

local featureFileList = {}
for dir in io.popen([[dir "./features" /b]]):lines() do
  table.insert(featureFileList, dir)
end

-- Load in and organize all commands
for k, v in ipairs(commandFileList) do
  local module = loadFile(v)

  -- commands is a list of commands
  table.insert(commands, module)

  -- commandsMAP is mapped by the triggers, for easy access
  for _, v in ipairs(module.trigger) do
    if commandsMAP[v] then p("!! Multiple commands have the same trigger: ["..v.."]") end
    commandsMAP[v] = module
  end
end

-- Load in and organize all features
for k, v in ipairs(featureFileList) do
  local module = loadFile(v)

  -- features is a list of features
  table.insert(features, module)
end

-- This function is used when needing to call a handle to all commands
local commandCache = {}
local function commandHandler(eventName, ...)
  if commandCache[eventName] then
    for k, v in ipairs(commandCache[eventName]) do
      v[eventName](...)
    end
  else
    for k, v in ipairs(commands) do
      local f = v[eventName]
      if f then
        f(...)
        table.insert(commandCache[eventName])
      end
    end
  end
end

-- This function is used when needing to call a handle to all commands
local featureCache = {}
local function featureHandler(eventName, ...)
  if featureCache[eventName] then
    for k, v in ipairs(featureCache[eventName]) do
      v[eventName](...)
    end
  else
    for k, v in ipairs(features) do
      local f = v[eventName]
      if f then
        f(...)
        table.insert(featureCache[eventName])
      end
    end
  end
end

-- One to control then all (handlers)
local function botHandler(eventName, ...)
  commandHandler(eventName, ...)
  featureHandler(eventName, ...)
end

-- Emitted after all shards and guilds are fully loaded.
client:on('ready', function()
  botHandler("ready")

  -- Pring a message to verify the bot is up and running!
	p(string.format('Logged in as %s', client.user.username))

  -- Set the defaults to every server, just in case
  for k, v in pairs(Misc.client.guilds) do
    perserverCheck(k)
  end
  saveFile("perserver.json")
end)

-- Emitted when a text channel message is created.
client:on('messageCreate', function(message)
  -- ignore its own messages
  if message.author == client.user then return end

  -- Get the server's currrent prefix
  local prefix = Misc.getPrefix(message)
  local isCommand = string.startswith(message.content, prefix)

 -- Run any of the bot's features before checking commands
  for k, v in ipairs(features) do
    if v.onCommandType ~= "ignore" or (not isCommand) then
      local f = v.onMessage
      local success
      if f then success = f(message) end
      if success and v.onCommandType == "override" then
        return
      elseif success then
        break
      end
    end
  end

  -- If the message does not start with the prefix, then ignore the message at this point
  if not isCommand then	return end

  -- Get the command name and command object
  local triggerName = Misc.getCommandName(message)
  local command = commandsMAP[triggerName]

  if command then
    -- Activate the command if found/exists!
    command.onCommand(message)
  else
    -- Otherwise, inform the user they had an incorrect command
    Misc.replyEmbed(message, {}, {title = "Error", text = "Command not found!\nCheck your spelling.", footer = "Use "..Misc.getPrefix(Misc.getGuildID(message)).."help to see a list of commands"})
  end

end)

-- Emitted when a guild is created from the perspective of the current user, usually after the client user joins a new one
client:on('guildCreate', function(guild)
  botHandler("guildCreate", guild)

  -- Set the defaults of the server
  perserverCheck(guild.id)
  saveFile("perserver.json")
end)

-- Emitted when a new user joins a guild.
client:on('memberJoin', function(member)
  botHandler("memberJoin", member)
end)

-- Emitted when a user leaves a guild.
client:on('memberLeave', function(member)
  botHandler("memberLeave", member)
end)


client:run("Bot "..token)
