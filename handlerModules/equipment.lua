--------------------------------------------------------------------------------
-- Equipment Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlerModules.handlerUtils")

local equipment = {}
local status = {}

local addHandlers

function equipment.init(worldStatus)
  addHandlers()
  worldStatus.equipment = status

  equipment.reset()
end

function equipment.reset()
end

function addHandlers()
  handlerUtils.addHandler("equipmentUpdated", "equipmentUpdated",
  function()
    debugMessage("Equipment updated.")
  end
  )
end

--------------------------------------------------------------------------------
-- Equipment actions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Enable equipment parsing triggers and request equipment from the mud.
--------------------------------------------------------------------------------
function equipment.updateEquipment()
  enableTrigger("refresh equipment")
  send("equipment")
end

return equipment
