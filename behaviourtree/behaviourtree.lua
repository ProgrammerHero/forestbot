--
--  BehaviourTree
--
--  Created by Tilmann Hars on 2012-07-12.
--  Copyright (c) 2012 Headchant. All rights reserved.
--
-- Useful links:
-- http://gamedev.stackexchange.com/questions/51693/decision-tree-vs-behavior-tree
-- http://aigamedev.com/open/article/behavior-trees-part1/
-- https://docs.unrealengine.com/latest/INT/Engine/AI/BehaviorTrees/NodeReference/index.html

local Class = require 'behaviourtree.class'
debugOutput = true

--------------------------------------------------------------------------------
-- ACTION: Perform a single task and return the result.
--------------------------------------------------------------------------------
Action = Class({init = function(self, task)
  self.name = "action"
  self.task = task
end})

function Action:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  if self.task then
    return self.task(creatureAI)
  end
  return false
end

--------------------------------------------------------------------------------
-- Inverter: Perform a single task and return the negative of the result.
--------------------------------------------------------------------------------
Inverter = Class({init = function(self, action)
  self.name = "inverter"
  self.action = action
end})

function Inverter:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  return not self.action:run(creatureAI)
end

--------------------------------------------------------------------------------
-- Succeeder: Perform a single task and return true.
-- Return: true, always
--------------------------------------------------------------------------------
Succeeder = Class({init = function(self, action)
  self.name = "succeeder"
  self.action = action
end})

function Succeeder:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  self.action:run(creatureAI)
  return true
end

--------------------------------------------------------------------------------
-- XOR: Perform a pair of task and return the xor of the results.
-- Return: true if exactly one task succeeded
--         false if both tasks succeeded or both tasks failed
--------------------------------------------------------------------------------
XOR = Class({init = function(self, children)
  self.name = "xor"
  if #children == 2 then
    self.children = children
  end
end})

function XOR:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  if #self.children == 2 then
    return (self.children[1]:run(creatureAI) == not self.children[2]:run(creatureAI))
  end
  return false
end

--------------------------------------------------------------------------------
-- REPEATER: Repeat a single task multiple times.
-- Return: true, always
--------------------------------------------------------------------------------
Repeater = Class({init = function(self, action, count)
  self.name = "repeater"
  self.action = action
  self.count = count
end})

function Repeater:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  for i = 1, self.count do
    self.action:run(creatureAI)
  end
  return true
end

--------------------------------------------------------------------------------
-- REPEATER_FAIL: Repeat a single task multiple times or until it fails.
-- Return: true if all iterations succeed
--         false if any iteration fails (with early return)
--------------------------------------------------------------------------------
Repeater_Fail = Class({init = function(self, action, count)
  self.name = "repeater_fail"
  self.action = action
  self.count = count
end})

function Repeater_Fail:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  for i = 1, self.count do
    if not self.action:run(creatureAI) then
      return true
    end
  end
  return false
end

--------------------------------------------------------------------------------
-- REPEATER_SUCCEED: Repeat a single task multiple times or until it succeeds.
-- Return: true if any iteration succeeds (with early return)
--         false if all iterations fail
--------------------------------------------------------------------------------
Repeater_Succeed = Class({init = function(self, action, count)
  self.name = "repeater_succeed"
  self.action = action
  self.count = count
end})

function Repeater_Succeed:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  for i = 1, self.count do
    if self.action:run(creatureAI) then
      return true
    end
  end
  return false
end

--------------------------------------------------------------------------------
-- SELECTOR: Execute my children in order and stop executing if one succeeds.
-- Return: true if any child succeeds
--         false if every child fails
--------------------------------------------------------------------------------
Selector = Class({init = function(self, children)
  self.name = "selector"
  self.children = children
end})

function Selector:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  for i,v in ipairs(self.children) do
    status = v:run(creatureAI)
    if status then
      return true
    end
  end
  return false
end

--------------------------------------------------------------------------------
-- SEQUENCE: Execute my children in order and stop executing if one fails.
-- Return: true if every child succeeds
--         false if any child fails
--------------------------------------------------------------------------------
Sequence = Class({init = function(self, children)
  self.name = "sequence"
  self.children = children
end})

function Sequence:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  for i,v in ipairs(self.children) do
    success = v:run(creatureAI)
    if not success then
      return false
    end
  end
  return true
end

--------------------------------------------------------------------------------
-- RANDOMIZER: Execute one random child and return its result.
-- Return: true if the randomly selected child succeeds
--         false if the randomly selected child fails
-- Note: if no children are present then the return value is 50% true, 50% false
--------------------------------------------------------------------------------
Randomizer = Class({init = function(self, children)
  self.name = "randomizer"
  self.children = children
end})

function Randomizer:run(creatureAI)
  if (debugOutput) then echo(self.name .. " update\n") end
  if (#self.children == 0) then
    return math.random(2) == 2
  end
  i = math.random(#self.children)
  success = self.children[i]:run(creatureAI)
end


local function _treeToString(tree, indent)
  local strTree = string.rep(" ", indent) .. tree.name .. "\n"
  for i,c in ipairs(tree.children) do
    strTree = strTree .. _treeToString(c, indent+1)
  end
  return strTree
end

function treeToString(tree)
  return _treeToString(tree, 0)
end

COND_TRUE = Action(function() return true end)
COND_FALSE = Action(function() return false end)

--------------------------------------------------------------------------------
-- Example
--------------------------------------------------------------------------------
--[[

function exampleLoop()

  -- testing subtree 1
  local fightAndEatGuards = Sequence {
    Randomizer {
      Action(function() print("fighting and eating guards") return true end),
      Action(function() print("getting killed by guards") return false end)
    }
  }
  -- testing subtree 2
  local packStuffAndGoHome = Selector {
    Sequence {
      Action(function() print("still strong enough? yes") return true end),
      Action(function() print("picking up gold") return true end),
    },
    Sequence {
      Action(function() print("flying home") return true end),
      Action(function() print("putting treasure away") return true end),
    }
  }

  -- main tree
  local simpleBehaviour = Selector {
    Sequence {
      Action(function() print("is thief near treasure? no") return false end),
      Action(function() print("making the thief flee") return false end),
    },
    Sequence {
      Action(function() print("choosing Castle") return true end),
      Action(function() print("fly to Castle") return true end),
      fightAndEatGuards,
      packStuffAndGoHome
    },
    Sequence {
      Action(function() print("posting pics on facebook") return true end)
    }
  }

  for i = 1, 10 do
    simpleBehaviour:run()
  end
end

exampleLoop()
--]]
