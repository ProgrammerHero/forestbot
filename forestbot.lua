--------------------------------------------------------------------------------
-- forestbot.lua
-- Aegeus, ProgrammerHero
-- 2016
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Central bot state machine
--------------------------------------------------------------------------------
bot = { hits=0,
        energy=0,
        moves=0,

        maxHits=0,
        maxEnergy=0,
        maxMoves=0

        level=0,
        xp=0,

        stance="",

        -- tables for functions
        score={},
        ident={},
        needs={},
        friends={},
        items={},
        map={}
      }

--------------------------------------------------------------------------------
-- Initializer function.  Will be executed on script load, should be used to
-- set initial state or reset original state.
--------------------------------------------------------------------------------
function bot.init()
  echo("forestbot main script loaded")
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
  bot.level = level
  bot.xp = xp
end

function bot.score.setHits(hits, maxHits)
  bot.hits = hits
  bots.maxHits = maxHits
end

function bot.score.setEnergy(energy, maxEnergy)
  bot.energy = energy
  bot.maxEnergy = maxEnergy
end

function bot.score.setMoves(moves, maxMoves)
  bot.moves = moves
  bots.maxMoves = maxMoves
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
  enableTrigger("inventory")
  send("inventory")
end

function bot.items.setCoins(coins, weight)
  echo(">Set items.coins = " .. coins)
  bot.items.coins = coins
end

function bot.items.addLineItems(items)
  --echo table.concat(items, " ")
end

function bot.items.setCarriedWeight(carried, encumbrance)
  bot.weight = carried
  bot.encumbrance = encumbrance
end

function bot.items.setWornWeight(worn)
  bot.weight = bot.weight + worn -- should this be separated? - Jason
end

--------------------------------------------------------------------------------
-- Script start.
--------------------------------------------------------------------------------

bot.init()
