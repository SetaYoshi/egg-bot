local command = {}

command.name = "Emotion"
command.info = "Bots can have emotions too"
command.desc = table.join({
                            "A random emotion will be shown",
                            "  \\• {prefix}emotion - Shows a random emoji icon",
                          }, "\n")
command.trigger = {"emotion", "mood"}

local sendEmbed = Misc.embedBuild(command)

-- Returns the URL to a random emoji
local function randomEmoji()
  local n = math.random(1, 101)
  if n > 50 and n < 61 then
    n = randNumber()
  end
  return "http://static.tieba.baidu.com/tb/editor/images/client/image_emoticon"..n..".png"
end

command.onCommand = function(m)
  sendEmbed(m, {imageURL = randomEmoji()})
end

return command
