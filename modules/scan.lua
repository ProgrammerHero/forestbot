--------------------------------------------------------------------------------
-- Scan Functions
-- For now, the mobs array is populated directly by a trigger (with no event).
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("modules.debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("modules.handlerUtils")
local numbers = require("modules.util.numbers")

local scan = {}
local status
local tasks

local addHandlers
local installTasks

function scan.init(worldStatus, worldTasks)
  status = worldStatus
  tasks = worldTasks

  addHandlers()
  installTasks()

  scan.reset()
end

function scan.reset()
  status.scan = {}
  status.scan.mobs = {}
end

--------------------------------------------------------------------------------
-- Handlers update the bot's knowledge of the world. The events they handle
-- are raised by triggers on input from the mud.
--------------------------------------------------------------------------------
function addHandlers()
  handlerUtils.addHandler("moved", "clearScanOnMove",
  function(event, direction)
    debugMessage("Move detected => clearing scan table.")
    status.scan.mobs = {}
  end
  )

  handlerUtils.addHandler("botFled", "clearScanOnFlee",
  function(event, direction)
    debugMessage("Flee detected => clearing scan table.")
    status.scan.mobs = {}
  end
  )
end

function scan.parseScanLine(rawDirection, rawMobString)
  local direction = scan.parseDirection(rawDirection)
  local mobTable = scan.parseMobString(rawMobString)

  status.scan.mobs[direction] = mobTable
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

--------------------------------------------------------------------------------
-- Store all tasks in the bot.tasks dictionary, indexed by name. This is a
-- function so that it will happen only on module init and not on file load.
--------------------------------------------------------------------------------
function installTasks()

  -- Conditions ----------------------------------------------------------------

  function tasks.enemyPresent(enemy)
    debugMessage("((STUB)) Yup, he's here.")
    return true
  end

  -- Actions -------------------------------------------------------------------

end

return scan
