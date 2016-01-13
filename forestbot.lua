-- begin awesome script

echo("init fbot v2")

bot = { needs={},
        health=0,
        energy=0,
        moves=0,
        stance="",

        friends={},
        items={}
 }

function bot.init()
end

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

bot.init()