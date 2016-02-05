--------------------------------------------------------------------------------
-- Health Functions
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlers.handlerUtils")

local health = {}
local status = {}

local addHandlers

function health.init(worldStatus)
  addHandlers()
  worldStatus.health = status

  health.reset()
end

function health.reset()
  status.hits = 0
  status.maxHits = 0

  status.energy = 0
  status.maxEnergy = 0

  status.moves = 0
  status.maxMoves = 0
end

function addHandlers()
  handlerUtils.addHandler("prompt", "prompt",
  function()
  end
  )
end

return health
