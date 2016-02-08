--------------------------------------------------------------------------------
-- Combat Functions
-- The bot maintains a simple list of 'targets'. A target is a mob the bot is
-- actively in combat with at the current time. Duplicates are allowed in the
-- list, since we could fight two of the same mob type simultaneously. Mobs are
-- added to the target list when they attack or counterattack the bot. They are
-- removed if they flee or the bot does, or if they die or the bot does. The
-- bot knows it is in combat if its target list is not empty.
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)
local handlerUtils = require("handlerModules.handlerUtils")

local combat = {}
local status
local tasks

local addHandlers
local installTasks

function combat.init(worldStatus, worldTasks)
  status = worldStatus
  tasks = worldTasks

  addHandlers()
  installTasks()

  combat.reset()
end

function combat.reset()
  status.combat = {}
  status.combat.targets = {}
end

--------------------------------------------------------------------------------
-- Handlers update the bot's knowledge of the world. The events they handle
-- are raised by triggers on input from the mud.
--------------------------------------------------------------------------------
function addHandlers()
  handlerUtils.addHandler("leapsToAttack", "leapsToAttackYou",
  function(event, attacker, target)
    if(attacker == "you") then
      combat.addTarget(target)
      debugMessage("Now fighting \"" .. target .. "\".")
    elseif(target == "you") then
      combat.addTarget(attacker)
      debugMessage("Now fighting \"" .. attacker .. "\".")
    end
  end
  )

  handlerUtils.addHandler("counterattacks", "counterattacksYou",
  function(event, attacker, target)
    if(target == "you") then
      debugMessage("Now fighting \"" .. attacker .. "\".")
      combat.addTarget(attacker)
    end
  end
  )

  handlerUtils.addHandler("someoneFled", "currentTargetFled",
  function(event, actor, direction)
    if combat.isTarget(actor) then
      debugMessage("Target \"" .. actor .. "\" fled " .. direction .. ".")
      combat.removeTarget(actor)
    end
  end
  )

  handlerUtils.addHandler("someoneIsDEAD", "targetIsDEAD",
  function(event, whoDied)
    if combat.isTarget(whoDied) then
      debugMessage("Target \"" .. whoDied .. "\" died.")
      combat.removeTarget(whoDied)
    end
  end
  )

  handlerUtils.addHandler("botFled", "botFled",
  function(event, fleeDirection)
    debugMessage("Bot fled " .. fleeDirection)
    botFleeDirection = fleeDirection
    combat.removeAllTargets()
    -- TODO: Track that we have 'angry' enemies around
  end
  )

  handlerUtils.addHandler("botDeath", "botCombatDeath",
  function()
    combat.removeAllTargets()
  end
  )
end

--------------------------------------------------------------------------------
-- Combat functions
--------------------------------------------------------------------------------
function combat.addTarget(target)
  status.combat.targets[#status.combat.targets + 1] = target
  debugMessage(combat.listTargets())
end

function combat.removeTarget(target)
  local index = table.index_of(status.combat.targets, target)
  local success = false

  if index then
    table.remove(status.combat.targets, index)
    success = true
  end

  debugMessage(combat.listTargets())

  return success
end

function combat.removeAllTargets()
  status.combat.targets = {}
  debugMessage(combat.listTargets())
end

function combat.isTarget(target)
  return table.contains(status.combat.targets, target)
end

function combat.listTargets()
  return "Targets = {" ..table.concat(status.combat.targets, ", ") .. "}"
end

--------------------------------------------------------------------------------
-- Store all tasks in the bot.tasks dictionary, indexed by name. This is a
-- function so that it will happen only on module init and not on file load.
--------------------------------------------------------------------------------
function installTasks()

  -- Conditions -----------------------------------------------------------------

  function tasks.inCombat()
    if #status.combat.targets == 0 then
      debugMessage("In combat? No.")
      return true
    else
      debugMessage("In combat? Yes.")
      return false
    end
  end


  -- Actions --------------------------------------------------------------------

  function tasks.attack(target)
    debugMessage("Attacking " .. target)
    return true
  end
end

return combat
