local handlerUtils = {}

local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)

--TODO: See if there's a nicer way to choose where handlers should be stored,
--rather than hard-coding their location to bot.handlers.
-- This may be tough, because I think Mudlet needs the handlers to be accessible
-- through the global namespace so that it can call them by name.

function handlerUtils.init()
  bot.handlers = {}
end

--------------------------------------------------------------------------------
-- Function to register an event handler with Mudlet's event system
-- Stores registered handlers in the bot.handlers namespace.
-- All events include bot.thinkAfterTriggers as a handler.
-- We guarantee that only one event will be fired per line from the mud.
--------------------------------------------------------------------------------
function handlerUtils.addHandler(eventName, handlerName, handlerFunc)
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
function handlerUtils.removeHandler(eventName, handlerName)
  bot.handlers[handlerName] = function() end
end

return handlerUtils
