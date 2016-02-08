--------------------------------------------------------------------------------
-- Inventory handlers
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlerModules.handlerUtils")

local inventory = {}
local status = {}

local addHandlers

function inventory.init(worldStatus)
  addHandlers()
  worldStatus.inventory = status

  inventory.reset()
end

function inventory.reset()
  status = {}
  status.coins = 0
  status.weight = 0
  status.wornWeight = 0
  status.encumbrance = ""
  status.hasFood = true
  status.hasWater = true
  status.items = {}
end

function addHandlers()
  handlerUtils.addHandler("inventoryUpdated", "inventoryUpdated",
  function()
    debugMessage("Inventory updated.")
  end
  )

  handlerUtils.addHandler("noFood", "noFood",
  function()
    debugMessage("Setting inventory.hasFood = false")
    bot.items.hasFood = false
  end
  )

  handlerUtils.addHandler("noWater", "noWater",
  function()
    debugMessage("Setting inventory.hasWater = false")
    bot.items.hasWater = false
  end
  )
end

--------------------------------------------------------------------------------
-- Enable inventory parsing triggers and request inventory from the mud.
--------------------------------------------------------------------------------
function inventory.updateInventory()
  enableTrigger("refresh inventory")
  send("inventory")
end

return inventory
