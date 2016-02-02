--------------------------------------------------------------------------------
-- forestbot.lua
-- Aegeus, ProgrammerHero
-- 2016
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Central bot namespace
--------------------------------------------------------------------------------
bot = {}
bot.debug = true

if bot.debug then
  bot.debugMessage = print
else
  bot.debugMessage = function(s) end
end

--------------------------------------------------------------------------------
-- Initializer function.  Will be executed when this script file is loaded.
--------------------------------------------------------------------------------
function bot.init()
  if bot.debug then
    bot.debugMessage = print
  else
    bot.debugMessage = function(s) end
  end

  bot.debugMessage("bot.init()")

  if not savedPackagePath then
    savedPackagePath = package.path
    bot.debugMessage("Capturing default package path")
    package.path = os.getenv("forestbot_path") .. "/?.lua;" .. savedPackagePath
  end

  -- unload+reload modules here
  package.loaded["botbtree"] = nil
  bot.botbtree = require("botbtree")
  package.loaded["behaviourtree.behaviourtree"] = nil
  behaviourtree = require("behaviourtree.behaviourtree")

  bot.reset()
end

--------------------------------------------------------------------------------
-- Evaluate the behaviour tree based on the current known state of the world.
--------------------------------------------------------------------------------
function bot.think()
  -- dispatch behaviour tree
end

--------------------------------------------------------------------------------
-- Resets all bot state to initial values.
--------------------------------------------------------------------------------
function bot.reset()
  bot.debugMessage("bot.reset()")

  bot.status = {}
  bot.status.hits = 0
  bot.status.energy = 0
  bot.status.moves = 0

  bot.status.maxHits = 0
  bot.status.maxMoves = 0

  bot.status.level = 0
  bot.status.xp = 0

  bot.status.stance = ""

  bot.needs = {}
  bot.needs.hunger = 0
  bot.needs.thirst = 0

  bot.items = {}
  bot.items.coins = 0
  bot.items.weight = 0
  bot.items.wornWeight = 0
  bot.items.encumbrance = ""
  bot.items.hasFood = true 
  bot.items.hasWater = true

  bot.inventory = {}

  -- should probably init inventory here
  -- and stats

  -- reset behaviours
  bot.btree = bot.botbtree.loadJSON("behaviour.json")

  bot.btree:run(bot)

end

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
function bot.functions.updateScore()
  enableTrigger("score")
  send("score")
end

--------------------------------------------------------------------------------
-- Enable inventory parsing triggers and request inventory from the mud.
--------------------------------------------------------------------------------
function bot.functions.updateInventory()
  enableTrigger("request_inventory")
  send("inventory")
end

--------------------------------------------------------------------------------
-- Script start.
--------------------------------------------------------------------------------

bot.init()
