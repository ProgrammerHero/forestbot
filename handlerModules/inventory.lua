--------------------------------------------------------------------------------
-- Inventory handlers
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlerModules.handlerUtils")

local inventory = {}
local status
local tasks

local addHandlers
local installTasks

function inventory.init(worldStatus, worldTasks)
  status = worldStatus
  tasks = worldTasks

  addHandlers()
  installTasks()

  inventory.reset()
end

function inventory.reset()
  status.inventory = {}
  status.inventory.coins = 0
  status.inventory.weight = 0
  status.inventory.wornWeight = 0
  status.inventory.encumbrance = ""
  status.inventory.hasFood = true
  status.inventory.hasWater = true
  status.inventory.items = {}
end

--------------------------------------------------------------------------------
-- Handlers update the bot's knowledge of the world. The events they handle
-- are raised by triggers on input from the mud.
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- Store all tasks in the bot.tasks dictionary, indexed by name. This is a
-- function so that it will happen only on module init and not on file load.
--------------------------------------------------------------------------------
function installTasks()

  -- Conditions -----------------------------------------------------------------

  function tasks.hasItem(item)
    debugMessage("((STUB))I have some!")
    return true
  end

  -- Actions --------------------------------------------------------------------

end

return inventory
