--------------------------------------------------------------------------------
-- forestbot.lua
-- Aegeus, ProgrammerHero
-- 2016
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Central bot state machine
--------------------------------------------------------------------------------
bot = { health=0,
        energy=0,
        moves=0,
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
end

--------------------------------------------------------------------------------
-- Bot identity/score functions.
--------------------------------------------------------------------------------

-- is this useful at all? - Jason
function bot.score.updateScore()
  echo ">score"
  enableTrigger("score")
  bot.score = {}
  send("score")
end

function bot.ident.updateIdentity()
  echo ">identity"
  enableTrigger("identity")
  bot.ident = {}
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
  echo ">inventory"
  enableTrigger("inventory")
  bot.items = {}
  send("inventory")
end

function bot.items.setCoins(coins, weight)
  echo(">Set items.coins = " .. coins)
  bot.items.coins = coins
end

function bot.items.addLineItems(items)
  --echo table.concat(items, " ")
end

function bot.items.setCarriedWeight(weight, encumbrance)
  bot.weight = weight
  bot.encumbrance = encumbrance
end

function bot.items.setWornWeight(weight)
  bot.weight = bot.weight + weight -- should this be separated? - Jason
end

--------------------------------------------------------------------------------
-- Script start.
--------------------------------------------------------------------------------

bot.init()
