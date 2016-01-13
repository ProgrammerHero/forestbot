--------------------------------------------------------------------------------
-- forestbot.lua
-- Aegeus, ProgrammerHero
-- 2016
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Central bot state machine
--------------------------------------------------------------------------------
bot = { needs={},
        health=0,
        energy=0,
        moves=0,
        stance="",

        friends={},
        items={}
      }

--------------------------------------------------------------------------------
-- Initializer function.  Will be executed on script load, should be used to
-- set initial state or reset original state.
--------------------------------------------------------------------------------
function bot.init()
  echo("forestbot main script loaded")
end

--------------------------------------------------------------------------------
-- Bot essential needs functions, all the functions required to keep this bot
-- health while not in combat.
--------------------------------------------------------------------------------

function bot.needs.eatfood(amount)
  -- find my food stuffs
  send("eat food") -- we can tell it what to eat later
end

function bot.needs.drink(amount)

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

function bot.items.setCoins(coins, weight)
  bot.items.coins = coins
end

function bot.items.updateInventory()
  echo ">inventory"
  enableTrigger("inventory")
  bot.items = {}
  send("inventory")
end

function bot.items.addLineItems(items)
  echo table.concat(items, " ")
end

--------------------------------------------------------------------------------
-- Script start.
--------------------------------------------------------------------------------

bot.init()
