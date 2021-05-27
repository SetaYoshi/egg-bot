local command = {}

command.name = "APOD"
command.info = "Astronomy's Picture of the Day"
command.desc = table.join({
                            "Discover an amazing astronomy picture provided by NASA",
                            "  \\•{prefix}apod - For today's picture",
                            "  \\•{prefix}apod <YYYY-MM-DD> - Returns the picture from that day",
                          }, "\n")
command.trigger = {"apod", "nasa"}

local http = loadFile("deps/coro-http")

local baseURL = "https://api.nasa.gov/planetary/apod"
local appID = loadFile("token").NASA

-- Request an apod object for today. If a date is specified, then return the APOD for that day
local function requestAPOD(date)
  local url = baseURL.."?api_key="..appID

  if date and date ~= "" then
    url = url.."&date="..date
  end

  local _, body = http.request("GET", url)
  if body then
    return Misc.JsonToTable(body)
  end
end

-- Print an error message is a request is not returned
local function printError(m)
  Misc.replyEmbed(m, command, "Something went wrong :(")
end


command.onCommand = function(m)
  local param = table.join(Misc.getParameters(m, false, true), " ")

  local apod = requestAPOD(param)
  if not apod then printError(m) return end

  local text = "__"..apod.title.."__ "..apod.date.."\n"
  if apod.copyright then
    text = text.."©*"..apod.copyright.."*"
  end
  Misc.replyEmbed(m, command, {title = "NASA's Astronomy Picture of the Day", text = text, image = apod.hdurl})
  Misc.replyEmbed(m, command, {title = "NASA's Astronomy Picture of the Day", text = apod.explanation}) -- Split into two since its too long
end

return command
