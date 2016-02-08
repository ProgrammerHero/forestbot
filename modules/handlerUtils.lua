local handlerUtils = {}

local debugMode = true
local debugMessage = require("modules.debugUtils").getDebugMessage(debugMode)

--TODO: See if there's a nicer way to choose where handlers should be stored,
--rather than hard-coding their location to bot.handlers.
-- This may be tough, because I think Mudlet needs the handlers to be accessible
-- through the global namespace so that it can call them by name.

--------------------------------------------------------------------------------
-- Function to register an event handler with Mudlet's event system
-- Stores registered handlers in the bot.handlers namespace.
-- Stores all events seen in the bot.events, treated as a set (no repeated events)
-- We guarantee that only one event will be fired per line from the mud.
--------------------------------------------------------------------------------
function handlerUtils.addHandler(eventName, handlerName, handlerFunc)
  debugMessage("    Adding bot.handlers." .. handlerName ..
  " to handle \"" .. eventName .. "\" event.")
  bot.handlers[handlerName] = handlerFunc
  registerAnonymousEventHandler(eventName, "bot.handlers." .. handlerName)
  bot.events[eventName] = true
end

--------------------------------------------------------------------------------
-- Function to remove an event handler
-- As of Feb 2016, Mudlet's event system cannot unregister an event handler,
-- so we instead change the lua function registered as a handler to a no-op.
--------------------------------------------------------------------------------
function handlerUtils.removeHandler(eventName, handlerName)
  bot.handlers[handlerName] = function() end
end

--------------------------------------------------------------------------------
-- The bot thinks after any event is received, but only as the final handler
-- for the event. This guarantees that other event handlers properly update
-- the world status before the bot thinks.
-- An unfortunate side-effect of not being able to remove event handlers in
-- Mudlet is that, when you add a handler, you must restart Mudlet. If you do
-- not, bot.think() will no longer happen as the final action for a given line
-- from the mud.
--------------------------------------------------------------------------------
function handlerUtils.setupThinking(events)
  for eventName, _ in pairs(events) do
    registerAnonymousEventHandler(eventName, "bot.think")
  end
end

return handlerUtils
