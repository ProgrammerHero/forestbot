--------------------------------------------------------------------------------
-- Health Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlerModules.handlerUtils")

local health = {}
local status
local tasks

local addHandlers
local installTasks

function health.init(worldStatus, worldTasks)
  status = worldStatus
  tasks = worldTasks

  addHandlers()
  installTasks()

  health.reset()
end

function health.reset()
  status.hits = 0
  status.maxHits = 0

  status.energy = 0
  status.maxEnergy = 0

  status.moves = 0
  status.maxMoves = 0
end

--------------------------------------------------------------------------------
-- Handlers update the bot's knowledge of the world. The events they handle
-- are raised by triggers on input from the mud.
--------------------------------------------------------------------------------
function addHandlers()
  handlerUtils.addHandler("prompt", "prompt",
  function()
  end
  )
end

--------------------------------------------------------------------------------
-- Store all tasks in the bot.tasks dictionary, indexed by name. This is a
-- function so that it will happen only on module init and not on file load.
--------------------------------------------------------------------------------
function installTasks()

  -- Conditions ----------------------------------------------------------------

  function tasks.isTired()
    if (status.moves < 20) then
      debugMessage("Checking if the bot is tired... yes.")
      return true
    else
      debugMessage("Checking if the bot is tired... no.")
      return false
    end
  end

  function tasks.shouldFight()
    debugMessage("((STUB))I'm an aggressive little bot!")
    return true
  end

  -- Actions -------------------------------------------------------------------

  function tasks.sleep()
    debugMessage("Sleeping")
    send("sleep")
    return true
  end

end

return health
