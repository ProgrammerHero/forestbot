--------------------------------------------------------------------------------
-- forestbot.lua
-- Aegeus, ProgrammerHero
-- 2016
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)

--------------------------------------------------------------------------------
-- Central bot namespace
--------------------------------------------------------------------------------
bot = {}
bot.handlers = {}
bot.functions = {}
bot.combat = {}
local modules = {
                  "botbtree",
--                  "handlers.needs",
--                  "handlers.combat",
--                  "handlers.inventory",
--                  "handlers.score",
--                  "handlers.location",
--                  "handlers.scan",
                }

-- Forward declarations to allow these functions to be private and defined
-- after functions that call them.
local setupPackagePaths
local reloadModule
local initModule
local getModuleFromName
local reset

--------------------------------------------------------------------------------
-- Initializer function.  Will be executed when this script file is loaded.
--------------------------------------------------------------------------------
function bot.init()
  debugMessage("bot.init()")

  setupPackagePaths()

  for i, moduleName in ipairs(modules) do
    reloadModule(bot, moduleName)
    initModule(bot, moduleName)
  end

  bot.initHandlers()
  bot.reset()
end

--------------------------------------------------------------------------------
-- Add the forestbot directory to lua's package search paths
-- This should only happen the first time this file is loaded.
--------------------------------------------------------------------------------
function setupPackagePaths()
  if not savedPackagePath then
    savedPackagePath = package.path
    debugMessage("Capturing default package path")
    package.path = os.getenv("forestbot_path") .. "/?.lua;" .. savedPackagePath
  end
end

--------------------------------------------------------------------------------
-- Reload module given its period-delimited name.
--------------------------------------------------------------------------------
function reloadModule(rootNamespace, moduleName)
  debugMessage("  Reloading module " .. moduleName)
  package.loaded[moduleName] = nil
  local modulePath = string.split(moduleName, "%.")
  local currentNamespace = rootNamespace

  for i=1,(#modulePath - 1) do
    if not currentNamespace[modulePath[i]] then
      currentNamespace[modulePath[i]] = {}
    end
    currentNamespace = currentNamespace[modulePath[i]]
  end

  currentNamespace[modulePath[#modulePath]] = require(moduleName)
end

--------------------------------------------------------------------------------
-- Call the init() function of a module, give its period-delimited name.
--------------------------------------------------------------------------------
function initModule(rootNamespace, moduleName)
  debugMessage("  Initializing module " .. moduleName)
  local module = getModuleFromName(rootNamespace, moduleName)

  if module and module.init then
    module.init()
  end
end

--------------------------------------------------------------------------------
-- Get the namespace for a module from its period-delimited name.
--------------------------------------------------------------------------------
function getModuleFromName(rootNamespace, moduleName)
  local modulePath = string.split(moduleName, "%.")
  local currentNamespace = rootNamespace

  for i=1,#modulePath do
    if not currentNamespace[modulePath[i]] then
      return nil
    end
    currentNamespace = currentNamespace[modulePath[i]]
  end

  return currentNamespace
end

--------------------------------------------------------------------------------
-- Evaluate the behaviour tree based on the current known state of the world.
--------------------------------------------------------------------------------
function bot.think()
  debugMessage("Thinking...")
end

--------------------------------------------------------------------------------
-- Resets all bot state to initial values.
--------------------------------------------------------------------------------
function bot.reset()
  debugMessage("bot.reset()")

  bot.status = {}
  bot.status.hits = 0
  bot.status.energy = 0
  bot.status.moves = 0

  bot.status.maxHits = 0
  bot.status.maxMoves = 0

  bot.status.level = 0
  bot.status.xp = 0

  bot.status.stance = ""

  bot.location = {}
  bot.location.roomNo = 0

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
  bot.items.equipment = {}

  bot.combat.targets = {}

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
-- Enable equipment parsing triggers and request equipment from the mud.
--------------------------------------------------------------------------------
function bot.functions.updateEquipment()
  enableTrigger("refresh equipment")
  send("equipment")
end

--------------------------------------------------------------------------------
-- Function to register an event handler with Mudlet's event system
-- Stores registered handlers in the bot.handlers namespace.
-- All events include bot.thinkAfterTriggers as a handler.
-- We guarantee that only one event will be fired per line from the mud.
--------------------------------------------------------------------------------
function bot.addHandler(eventName, handlerName, handlerFunc)
  debugMessage("Adding bot.handlers." .. handlerName ..
  " to handle \"" .. eventName .. "\" event.")
  bot.handlers[handlerName] = handlerFunc
  registerAnonymousEventHandler(eventName, "bot.handlers." .. handlerName)
  registerAnonymousEventHandler(eventName, "bot.think")
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
    debugMessage("Setting bot.needs.hunger to " .. hungerLevel)
    bot.needs.hunger = hungerLevel
  end
  )

  bot.addHandler("thirstEvent", "thirst",
  function(eventName, thirstLevel)
    debugMessage("Setting bot.needs.thirst to " .. thirstLevel)
    bot.needs.thirst = thirstLevel
  end
  )

  bot.addHandler("inventoryUpdated", "inventory",
  function()
    debugMessage("Implement inventory update handler.")
  end
  )

  bot.addHandler("equipmentUpdated", "equipment",
  function()
    debugMessage("Implement equipment update handler.")
  end
  )

  bot.addHandler("noFood", "noFood",
  function()
    debugMessage("Setting bot.items.hasFood = false")
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
    debugMessage("Implement score update handler.")
  end
  )

  bot.addHandler("prompt", "prompt",
  function()
  end
  )

  bot.addHandler("leapsToAttack", "leapsToAttackYou",
  function(event, attacker, target)
    if(attacker == "you") then
      bot.combat.addTarget(target)
      debugMessage("Now fighting \"" .. target .. "\".")
    elseif(target == "you") then
      bot.combat.addTarget(attacker)
      debugMessage("Now fighting \"" .. attacker .. "\".")
    end
  end
  )

  bot.addHandler("counterattacks", "counterattacksYou",
  function(event, attacker, target)
    if(target == "you") then
      debugMessage("Now fighting \"" .. attacker .. "\".")
      bot.combat.addTarget(attacker)
    end
  end
  )

  bot.addHandler("someoneFled", "currentTargetFled",
  function(event, actor, direction)
    if bot.combat.isTarget(actor) then
      debugMessage("Target \"" .. actor .. "\" fled " .. direction .. ".")
      bot.combat.removeTarget(actor)
    end
  end
  )

  bot.addHandler("someoneIsDEAD", "targetIsDEAD",
  function(event, whoDied)
    if bot.combat.isTarget(whoDied) then
      debugMessage("Target \"" .. whoDied .. "\" died.")
      bot.combat.removeTarget(whoDied)
    end
  end
  )

  bot.addHandler("botFled", "botFled",
  function(event, fleeDirection)
    debugMessage("Bot fled " .. fleeDirection)
    bot.combat.botFleeDirection = fleeDirection
    bot.combat.removeAllTargets()
    -- TODO: Track that we have 'angry' enemies around
  end
  )

  bot.addHandler("botDeath", "botCombatDeath",
  function()
    bot.combat.removeAllTargets()
  end
  )

  bot.addHandler("newRoom", "updateRoomNumber",
  function(event, roomNo)
    bot.location.roomNo = roomNo
    debugMessage("Currently in room #".. bot.location.roomNo)
  end
  )
end

--------------------------------------------------------------------------------
-- Combat Functions
--------------------------------------------------------------------------------
function bot.combat.addTarget(target)
  bot.combat.targets[#bot.combat.targets + 1] = target
  debugMessage(bot.combat.listTargets())
end

function bot.combat.removeTarget(target)
  local index = table.index_of(bot.combat.targets, target)
  local success = false

  if index then
    table.remove(bot.combat.targets, index)
    success = true
  end

  debugMessage(bot.combat.listTargets())

  return success
end

function bot.combat.removeAllTargets()
  bot.combat.targets = {}
  debugMessage(bot.combat.listTargets())
end

function bot.combat.isTarget(target)
  return table.contains(bot.combat.targets, target)
end

function bot.combat.listTargets()
  return "Targets = {" ..table.concat(bot.combat.targets, ", ") .. "}"
end

function bot.combat.inCombat()
  return #bot.combat.targets == 0
end

--------------------------------------------------------------------------------
-- Script start.
--------------------------------------------------------------------------------

bot.init()
