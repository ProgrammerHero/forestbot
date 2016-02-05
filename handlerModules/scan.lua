--------------------------------------------------------------------------------
-- Scan Functions
-- For now, the mobs array is populated directly by a trigger (with no event).
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlers.handlerUtils")
local numbers = require("util.numbers")

local scan = {}
local status = {}

local addHandlers

function scan.init(worldStatus)
  addHandlers()
  worldStatus.scan = status

  scan.reset()
end

function scan.reset()
  status.mobs = {}
end

function addHandlers()
  handlerUtils.addHandler("moved", "clearScanOnMove",
  function(event, direction)
    debugMessage("Move detected => clearing scan table.")
    status.mobs = {}
  end
  )

  handlerUtils.addHandler("botFled", "clearScanOnFlee",
  function(event, direction)
    debugMessage("Flee detected => clearing scan table.")
    status.mobs = {}
  end
  )
end

function scan.parseScanLine(rawDirection, rawMobString)
  local direction = scan.parseDirection(rawDirection)
  local mobTable = scan.parseMobString(rawMobString)

  status.mobs[direction] = mobTable
end

function scan.parseDirection(rawDirection)
  local direction = string.trim(rawDirection)
  if (direction == "[Here]") then
    return "here"
  else
    return direction
  end
end

function scan.parseMobString(rawMobString)

  --TODO: Should set a status so we get out a new light
  if (rawMobString == "darkness") then
    return { darkness = 1 }
  end

  local mobs = string.split(rawMobString, ", ")

  local splitMobs = {}
  for i = 1, #mobs do
    splitMobs[i] = string.split(mobs[i], " ")
  end

  -- Check for strings that don't start with a count (a, an, two, three, ...)
  local i = 2
  while i <= #splitMobs do 
    if not numbers.wordsToNumber[splitMobs[i][1]] then
      -- the first word of a split is not a count -> join with previous 'mob'
      table.foreach(splitMobs[i], function(_, v) table.insert(splitMobs[i - 1], v) end)
      table.remove(splitMobs, i)
    else
      i = i + 1
    end
  end

  local mobTable = {}

  for _, splitMob in ipairs(splitMobs) do
    local mobCount = numbers.wordsToNumber[splitMob[1]]
    local mobID
    if mobCount > 1 then
      -- If we have more than one of a mob, the plural noun might not be a good
      -- keyword => don't include it in the mobID
      mobID = table.concat(splitMob, ".", 2, #splitMob - 1)
    else
      mobID = table.concat(splitMob, ".", 2, #splitMob)
    end
    mobTable[mobID] = mobCount
  end

  return mobTable
end

return scan

