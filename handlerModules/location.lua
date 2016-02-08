--------------------------------------------------------------------------------
-- Location Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlerModules.handlerUtils")

local location = {}
local status
local tasks

local addHandlers
local installTasks

function location.init(worldStatus, worldTasks)
  status = worldStatus
  tasks = worldTasks

  addHandlers()
  installTasks()

  location.reset()
end

function location.reset()
  status.location = {}
  status.location.roomNo = 0
  status.location.exits = ""
end

--------------------------------------------------------------------------------
-- Handlers update the bot's knowledge of the world. The events they handle
-- are raised by triggers on input from the mud.
--------------------------------------------------------------------------------
function addHandlers()
  handlerUtils.addHandler("newRoom", "updateRoomNumber",
  function(event, roomNo)
    status.location.roomNo = roomNo
    debugMessage("Currently in room #".. status.location.roomNo)
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

end

return location
