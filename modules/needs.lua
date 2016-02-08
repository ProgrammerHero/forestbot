--------------------------------------------------------------------------------
-- Needs functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("modules.debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("modules.handlerUtils")

local needs = {}
local status
local tasks

local addHandlers
local installTasks

function needs.init(worldStatus, worldTasks)
  status = worldStatus
  tasks = worldTasks

  addHandlers()
  installTasks()

  needs.reset()
end

function needs.reset()
  status.needs = {}
  status.needs.hunger = 0
  status.needs.thirst = 0
end

--------------------------------------------------------------------------------
-- Handlers update the bot's knowledge of the world. The events they handle
-- are raised by triggers on input from the mud.
--------------------------------------------------------------------------------
function addHandlers()
  handlerUtils.addHandler("hungerEvent", "hunger",
  function(eventName, hungerLevel)
    debugMessage("Setting needs.hunger to " .. hungerLevel)
    status.needs.hunger = hungerLevel
  end
  )

  handlerUtils.addHandler("thirstEvent", "thirst",
  function(eventName, thirstLevel)
    debugMessage("Setting needs.thirst to " .. thirstLevel)
    status.needs.thirst = thirstLevel
  end
  )
end

--------------------------------------------------------------------------------
-- Store all tasks in the bot.tasks dictionary, indexed by name. This is a
-- function so that it will happen only on module init and not on file load.
--------------------------------------------------------------------------------
function installTasks()

  -- Conditions -----------------------------------------------------------------

  function tasks.isHungry()
    return status.needs.hunger > 0
  end

  function tasks.isThirsty()
    return status.needs.thirst > 0
  end

  -- Actions -------------------------------------------------------------------

  function tasks.eatFood()
    -- should be smarter and try to find specific food
    send("eat food")
    return true
    -- 
  end

  function tasks.drinkWater()
    -- should be smarter and try to find a specific drink
    -- also need to make sure we have a drink equipped
    send("drink bronze.cup")
    return true
  end

end

return needs
