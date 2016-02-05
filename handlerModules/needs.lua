--------------------------------------------------------------------------------
-- Needs functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlers.handlerUtils")

local needs = {}
local status = {}

local addHandlers

function needs.init(worldStatus)
  addHandlers()
  worldStatus.needs = status

  needs.reset()
end

function needs.reset()
  status.hunger = 0
  status.thirst = 0
end

function addHandlers()
  handlerUtils.addHandler("hungerEvent", "hunger",
  function(eventName, hungerLevel)
    debugMessage("Setting needs.hunger to " .. hungerLevel)
    status.hunger = hungerLevel
  end
  )

  handlerUtils.addHandler("thirstEvent", "thirst",
  function(eventName, thirstLevel)
    debugMessage("Setting needs.thirst to " .. thirstLevel)
    status.thirst = thirstLevel
  end
  )
end

return needs
