--------------------------------------------------------------------------------
-- Location Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlers.handlerUtils")

local location = {}
local status = {}

local addHandlers

function location.init(worldStatus)
  addHandlers()
  worldStatus.location = status

  location.reset()
end

function location.reset()
  status.roomNo = 0
  status.exits = ""
end

function addHandlers()
  handlerUtils.addHandler("newRoom", "updateRoomNumber",
  function(event, roomNo)
    status.roomNo = roomNo
    debugMessage("Currently in room #".. status.roomNo)
  end
  )
end

return location
