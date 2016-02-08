--------------------------------------------------------------------------------
-- Equipment Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("modules.debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("modules.handlerUtils")

local equipment = {}
local status
local tasks

local addHandlers
local installTasks

function equipment.init(worldStatus, worldTasks)
  status = worldStatus
  tasks = worldTasks

  addHandlers()
  installTasks()

  equipment.reset()
end

function equipment.reset()
  status.equipment = {}
end

--------------------------------------------------------------------------------
-- Handlers update the bot's knowledge of the world. The events they handle
-- are raised by triggers on input from the mud.
--------------------------------------------------------------------------------
function addHandlers()
  handlerUtils.addHandler("equipmentUpdated", "equipmentUpdated",
  function()
    debugMessage("Equipment updated.")
  end
  )
end

--------------------------------------------------------------------------------
-- Enable equipment parsing triggers and request equipment from the mud.
--------------------------------------------------------------------------------
function equipment.updateEquipment()
  enableTrigger("refresh equipment")
  send("equipment")
end

--------------------------------------------------------------------------------
-- Store all tasks in the bot.tasks dictionary, indexed by name. This is a
-- function so that it will happen only on module init and not on file load.
--------------------------------------------------------------------------------
function installTasks()

  -- Conditions ----------------------------------------------------------------

  -- Actions -------------------------------------------------------------------

end

return equipment
