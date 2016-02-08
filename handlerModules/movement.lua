--------------------------------------------------------------------------------
-- Movement Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlerModules.handlerUtils")

local movement = {}
local status
local tasks

local addHandlers
local installTasks

local MAX_HISTORY_LENGTH = 100

function movement.init(worldStatus, worldTasks)
  status = worldStatus
  tasks = worldTasks

  addHandlers()
  installTasks()

  movement.reset()
end

function movement.reset()
  status.movement = {}
  status.movement.history = {}
end

--------------------------------------------------------------------------------
-- Handlers update the bot's knowledge of the world. The events they handle
-- are raised by triggers on input from the mud.
--------------------------------------------------------------------------------
function addHandlers()
  handlerUtils.addHandler("moved", "moveHistory",
  function(event, direction)
    if (#status.movement.history == MAX_HISTORY_LENGTH) then
      table.remove(status.movement.history, 1)
    end
    status.movement.history[#status.movement.history + 1] = direction
  end
  )
end

--------------------------------------------------------------------------------
-- Store all tasks in the bot.tasks dictionary, indexed by name. This is a
-- function so that it will happen only on module init and not on file load.
--------------------------------------------------------------------------------
function installTasks()

  -- Conditions ----------------------------------------------------------------

  -- Actions -------------------------------------------------------------------

  function tasks.moveTo(location)
    debugMessage("((STUB))Tried moving to.., unsuccessfully.")
    return false
  end

  function tasks.escape()
    debugMessage("((STUB))He's got me trapped!")
    return false
  end

end

return movement

