--------------------------------------------------------------------------------
-- Movement Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlerModules.handlerUtils")

local movement = {}
local status = {}

local addHandlers

local MAX_HISTORY_LENGTH = 100

function movement.init(worldStatus)
  addHandlers()
  worldStatus.movement = status

  movement.reset()
end

function movement.reset()
  status.history = {}
end

function addHandlers()
  handlerUtils.addHandler("moved", "moveHistory",
  function(event, direction)
    if (#status.history == MAX_HISTORY_LENGTH) then
      table.remove(status.history, 1)
    end
    status.history[#status.history + 1] = direction
  end
  )
end

return movement

