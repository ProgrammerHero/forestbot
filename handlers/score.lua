--------------------------------------------------------------------------------
-- Bot identity/score functions.
--------------------------------------------------------------------------------

-- Request an update of the 'score' information. Its format follows:
--[[
           Items: 7/75             Weight: 11/436              Age: 20 years
      Quest Pnts: 0           Gossip Pnts: 73            Hit Regen: 0.0
   Practice Pnts: 25             Aptitude: Genius        Ene Regen: 0.0
         Hitroll: +2.00           Damroll: +1.00          Mv Regen: 0.0

      Str: 15(15)   Int:  9( 9)   Wis:  9( 9)   Dex: 15(15)   Con: 19(19)

         Magic: -9%        Fire: -21%       Cold: +4%        Mind: -7%
      Electric: +9%        Acid: +17%     Poison: +21%

            Coins: 5 sp.
         Position: [ mortally wounded ]    Condition: [ sober hungry thirsty ]

             [Also try the command identity for more information.]--]]

local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlers.handlerUtils")

local score = {}
local status = {}

local addHandlers

function score.init(worldStatus)
  addHandlers()
  worldStatus.score = status

  score.reset()
end

function score.reset()
  status.level = 0
end

function addHandlers()
  handlerUtils.addHandler("scoreUpdated", "scoreUpdated",
  function()
    debugMessage("Score updated.")
  end
  )

end

--------------------------------------------------------------------------------
-- Score Action
--------------------------------------------------------------------------------
function score.updateScore()
  enableTrigger("score")
  send("score")
end

return score
