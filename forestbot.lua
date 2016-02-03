--------------------------------------------------------------------------------
-- forestbot.lua
-- Aegeus, ProgrammerHero
-- 2016
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Central bot namespace
--------------------------------------------------------------------------------
bot = {}
bot.handlers = {}
bot.functions = {}
bot.debug = true

--------------------------------------------------------------------------------
-- Initializer function.  Will be executed when this script file is loaded.
--------------------------------------------------------------------------------
function bot.init()
  if bot.debug then
    bot.debugMessage = function(s)
      print(">> " .. s)
    end
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

  bot.initHandlers()
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

  bot.items.inventory = {}

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
  enableTrigger("refresh inventory")
  send("inventory")
end

--------------------------------------------------------------------------------
-- Function to register an event handler with Mudlet's event system
-- Stores registered handlers in the bot.handlers namespace.
-- We guarantee that only one event will be fired per line from the mud.
--------------------------------------------------------------------------------
function bot.addHandler(eventName, handlerName, handlerFunc)
  bot.debugMessage("Adding bot.handlers." .. handlerName ..
  " to handle \"" .. eventName .. "\" event.")
  bot.handlers[handlerName] = handlerFunc
  registerAnonymousEventHandler(eventName, "bot.handlers." .. handlerName)
end

--------------------------------------------------------------------------------
-- Function to remove an event handler
-- As of Feb 2016, Mudlet's event system cannot unregister an event handler,
-- so we instead change the lua function registered as a handler to a no-op.
--------------------------------------------------------------------------------
function bot.removeHandler(eventName, handlerName)
  bot.handlers[handlerName] = function() end
end

--------------------------------------------------------------------------------
-- Handlers for triggered events
--------------------------------------------------------------------------------
function bot.initHandlers()
  bot.addHandler("hungerEvent", "hunger",
  function(eventName, hungerLevel)
    bot.debugMessage("Setting bot.needs.hunger to " .. hungerLevel)
    bot.needs.hunger = hungerLevel
  end
  )

  bot.addHandler("thirstEvent", "thirst",
  function(eventName, thirstLevel)
    bot.debugMessage("Setting bot.needs.thirst to " .. thirstLevel)
    bot.needs.thirst = thirstLevel
  end
  )

  bot.addHandler("inventoryUpdated", "inventory",
  function()
    bot.debugMessage("Implement inventory update handler.")
  end
  )

  bot.addHandler("noFood", "noFood",
  function()
    bot.debugMessage("Setting bot.items.hasFood = false")
    bot.items.hasFood = false
  end
  )

  bot.addHandler("noWater", "noWater",
  function()
    bot.items.hasWater = false
  end
  )

  bot.addHandler("scoreUpdated", "score",
  function()
    bot.debugMessage("Implement score update handler.")
  end
  )

  bot.addHandler("prompt", "prompt",
  function()
  end
  )
end

--------------------------------------------------------------------------------
-- Script start.
--------------------------------------------------------------------------------

bot.init()
