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
local status = {}

local addHandlers

function combat.init(worldStatus)
  addHandlers()
  worldStatus.combat = status

  combat.reset()
end

function combat.reset()
  status.targets = {}
end

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
  status.targets[#status.targets + 1] = target
  debugMessage(combat.listTargets())
end

function combat.removeTarget(target)
  local index = table.index_of(status.targets, target)
  local success = false

  if index then
    table.remove(status.targets, index)
    success = true
  end

  debugMessage(combat.listTargets())

  return success
end

function combat.removeAllTargets()
  status.targets = {}
  debugMessage(combat.listTargets())
end

function combat.isTarget(target)
  return table.contains(status.targets, target)
end

function combat.listTargets()
  return "Targets = {" ..table.concat(status.targets, ", ") .. "}"
end

function combat.inCombat()
  return #status.targets == 0
end

return combat
