--------------------------------------------------------------------------------
-- forestbot.lua
-- Aegeus, ProgrammerHero
-- 2016
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Central bot namespace
--------------------------------------------------------------------------------
bot = bot or {}
bot.debug = true

bot.debugMessage = print
bot.debugMessage = function(s) end

-- tables for functions
bot.score = {}
bot.ident = {}
bot.needs = {}
bot.friends = {}
bot.items = {}
bot.map = {}
bot.util = {}

-- Set variables for running in the console
echo = echo or print

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
  end
  package.path = os.getenv("forestbot_path") .. "\\behaviourtree\\?.lua;" .. savedPackagePath

  -- unload+reload modules here
  package.loaded["behaviourtree"] = nil
  local bt = require("behaviourtree")

  bot.reset()
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

  bot.status.weight = 0
  bot.status.wornWeight = 0
  bot.status.encumbrance = ""

  bot.status.stance = ""

  -- should probably init inventory here
  -- and stats
end

--------------------------------------------------------------------------------
-- Bot identity/score functions.
--------------------------------------------------------------------------------

-- is this useful at all? - Jason
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
function bot.score.updateScore()
  enableTrigger("score")
  send("score")
end

function bot.score.setLevelXP(level, xp)
  bot.status.level = level
  bot.status.xp = xp
end

function bot.score.setHits(hits, maxHits)
  bot.status.hits = hits
  bot.status.maxHits = maxHits
end

function bot.score.setEnergy(energy, maxEnergy)
  bot.status.energy = energy
  bot.status.maxEnergy = maxEnergy
end

function bot.score.setMoves(moves, maxMoves)
  bot.status.moves = moves
  bot.status.maxMoves = maxMoves
end

function bot.ident.updateIdentity()
  enableTrigger("identity")
  send("identity")
end

--------------------------------------------------------------------------------
-- Bot essential needs functions, all the functions required to keep this bot
-- healthy while not in combat.
--------------------------------------------------------------------------------

function bot.needs.eatfood(amount)
  -- find my food stuffs
  send("eat food") -- we can tell it what to eat later
end

function bot.needs.drink(amount)
  -- note: cauldrons, fountains can be drunk
end

function bot.needs.sleep(seconds)
  -- should probably check for hostiles
  send("sleep")
  --tempTimer(seconds, bot.needs.wake)
end

function bot.needs.wake()
  --send("wake")
  send("stand")
end

function bot.needs.selfheal(amount)

end

--------------------------------------------------------------------------------
-- Bot inventory functions.  Used to manage the bot's items so it can make more
-- intelligent decisions
--------------------------------------------------------------------------------

function bot.items.updateInventory()
  bot.inventory = {}
  enableTrigger("inventory")
  send("inventory")
end

function bot.items.setCoins(coins, weight)
  echo(">Set items.coins = " .. coins)
  bot.items.coins = coins
end

function bot.items.addLineItem(name, number, weight)
  bot.inventory[#bot.inventory + 1] = {name, number, weight}
end

function bot.items.setCarriedWeight(carried, encumbrance)
  bot.status.weight = carried
  bot.status.encumbrance = encumbrance
end

function bot.items.setWornWeight(worn)
  bot.status.wornWeight = worn
end


--------------------------------------------------------------------------------
-- Remove leading and trailing whitespace from string s.
-- See http://lua-users.org/wiki/StringTrim  (trim6)
--------------------------------------------------------------------------------
function bot.util.trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end
--------------------------------------------------------------------------------
-- Script start.
--------------------------------------------------------------------------------

bot.init()
