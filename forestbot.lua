--------------------------------------------------------------------------------
-- forestbot.lua
-- Aegeus, ProgrammerHero
-- 2016
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Add the forestbot directory to lua's package search paths
-- This should only happen the first time this file is loaded.
--------------------------------------------------------------------------------
if not savedPackagePath then
  savedPackagePath = package.path
  package.path = os.getenv("forestbot_path") .. "/?.lua;" .. savedPackagePath
end

local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)

--------------------------------------------------------------------------------
-- Central bot namespace
--------------------------------------------------------------------------------
bot = {}
local modules = {
--                  "behaviourtree.behaviourtree",
                  "handlerModules.handlerUtils",
                  "handlerModules.needs",
                  "handlerModules.combat",
                  "handlerModules.inventory",
                  "handlerModules.score",
                  "handlerModules.location",
                  "handlerModules.equipment",
                  "handlerModules.health",
                  "handlerModules.scan",
                  "handlerModules.movement",
--                  "handlerModules.effects",
--                  "handlerModules.stance",
                  "botbtree",
                }

-- Forward declarations to allow these functions to be private and defined
-- after functions that call them.
local reloadModule
local initModule
local getModuleFromName
local resetModule

--------------------------------------------------------------------------------
-- Initializer function.  Will be executed when this script file is loaded.
--------------------------------------------------------------------------------
function bot.init()
  debugMessage("bot.init()")
  bot.status = {}
  bot.handlers = {}
  bot.tasks = {}

  for i, moduleName in ipairs(modules) do
    reloadModule(bot, moduleName)
    initModule(bot, moduleName, bot.status, bot.tasks)
  end
end

--------------------------------------------------------------------------------
-- Calls each module's reset() function, resetting the bot to its initial state.
--------------------------------------------------------------------------------
function bot.reset()
  debugMessage("bot.reset()")

  for i, moduleName in ipairs(modules) do
    resetModule(bot, moduleName)
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
-- Call the init() function of a module, given its period-delimited name.
--------------------------------------------------------------------------------
function initModule(rootNamespace, moduleName, worldStatus, worldTasks)
  debugMessage("  Initializing module " .. moduleName)
  local module = getModuleFromName(rootNamespace, moduleName)

  if module and module.init then
    module.init(worldStatus, worldTasks)
  end
end

--------------------------------------------------------------------------------
-- Call the reset() function of a module, given its period-delimited name.
--------------------------------------------------------------------------------
function resetModule(rootNamespace, moduleName)
  debugMessage("Resetting module " .. moduleName)
  local module = getModuleFromName(rootNamespace, moduleName)

  if module and module.reset then
    module.reset()
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
  bot.botbtree.think()
end

---- reset behaviours
--bot.btree = bot.botbtree.loadJSON("behaviour.json")
--
--  bot.btree:run(bot)
--
--end

--------------------------------------------------------------------------------
-- Script start.
--------------------------------------------------------------------------------

bot.init()
