local command = {}

command.name = "Emotion"
command.info = "Bots can have emotions too"
command.desc = table.join({
                            "A random emotion will be shown",
                            "  \\• {prefix}emotion - Shows a random emoji icon",
                          }, "\n")
command.trigger = {"emotion", "mood"}


-- Returns the URL to a random emoji
local function randomEmoji()
  local n = math.random(1, 101)
  if n > 50 and n < 61 then
    n = randNumber()
  end
  return "http://static.tieba.baidu.com/tb/editor/images/client/image_emoticon"..n..".png"
end

command.onCommand = function(m)
  Misc.replyEmbed(m, command, {image = randomEmoji()})
end

return command
