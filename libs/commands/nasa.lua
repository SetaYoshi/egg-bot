local command = {}

command.name = "APOD"
command.info = "Astronomy's Picture of the Day"
command.desc = table.join({
                            "Discover an amazing astronomy picture provided by NASA",
                            "  \\•{prefix}apod - For today's picture",
                            "  \\•{prefix}apod <YYYY-MM-DD> - Returns the picture from that day",
                          }, "\n")
command.trigger = {"apod", "nasa"}

local sendEmbed = Misc.embedBuild(command)
local http = require("coro-http")

local baseURL = "https://api.nasa.gov/planetary/apod"
local appID = require("files/token").NASA

-- Request an apod object for today. If a date is specified, then return the APOD for that day
local function requestAPOD(date)
  local url = baseURL.."?api_key="..appID

  if date and date ~= "" then
    url = url.."&date="..date
  end

  local _, body = http.request("GET", url)
  if body then
    return Misc.jsonToTable(body)
  end
end

-- Print an error message is a request is not returned
local function printError(m, s)
  s = s or ""
  sendEmbed(m, "Something went wrong :(\n"..s)
end


command.onCommand = function(m)
  local param = Misc.getParametersLC(m)

  local apod = requestAPOD(param)
  if apod and apod.code == 400 then printError(m, "Date `"..param.."` does not match format YYYY-MM-DD") return end
  if not apod or not apod.explanation then printError(m) return end

  local text = "__"..apod.title.."__ "..(apod.date or "").."\n"
  if apod.copyright then
    text = text.."©*"..apod.copyright.."*"
  end
  sendEmbed(m, {title = "NASA's Astronomy Picture of the Day", text = text, imageURL = (apod.hdurl or apod.url)})
  sendEmbed(m, {title = "NASA's Astronomy Picture of the Day", text = apod.explanation}) -- Split into two since its too long
end

return command
