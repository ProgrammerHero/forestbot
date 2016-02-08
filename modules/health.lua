--------------------------------------------------------------------------------
-- Health Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("modules.debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("modules.handlerUtils")

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
  status.health = {}
  status.health.hits = 0
  status.health.maxHits = 0

  status.health.energy = 0
  status.health.maxEnergy = 0

  status.health.moves = 0
  status.health.maxMoves = 0
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
    return status.health.moves < 20
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
