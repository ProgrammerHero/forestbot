--
--  BehaviourTree
--
--  Created by Tilmann Hars on 2012-07-12.
--  Copyright (c) 2012 Headchant. All rights reserved.
--
-- Useful links:
-- http://www.gamasutra.com/blogs/ChrisSimpson/20140717/221339/Behavior_trees_for_AI_How_they_work.php
-- http://gamedev.stackexchange.com/questions/51693/decision-tree-vs-behavior-tree
-- http://aigamedev.com/open/article/behavior-trees-part1/
-- https://docs.unrealengine.com/latest/INT/Engine/AI/BehaviorTrees/NodeReference/index.html
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)

local bt = {}

local Class = require 'behaviourtree.class'

--------------------------------------------------------------------------------
-- ACTION: Perform a single task and return the result.
--------------------------------------------------------------------------------
bt.Action = Class({init = function(self, name, task)
  self.nodeType = "action"
  self.name = name
  self.task = task
end})

function bt.Action:run(creatureAI)
  debugMessage(self.name .. " update")
  if self.task then
    return self.task(creatureAI)
  end
  return false
end

--------------------------------------------------------------------------------
-- Inverter: Perform a single task and return the negative of the result.
--------------------------------------------------------------------------------
bt.Inverter = Class({init = function(self, children)
  self.nodeType = "inverter"
  self.action = children[1]
end})

function bt.Inverter:run(creatureAI)
  debugMessage(self.nodeType .. " update\n")
  return not self.action:run(creatureAI)
end

--------------------------------------------------------------------------------
-- Succeeder: Perform a single task and return true.
-- Return: true, always
--------------------------------------------------------------------------------
bt.Succeeder = Class({init = function(self, children)
  self.nodeType = "succeeder"
  self.action = children[1]
end})

function bt.Succeeder:run(creatureAI)
  debugMessage(self.nodeType .. " update")
  self.action:run(creatureAI)
  return true
end

--------------------------------------------------------------------------------
-- XOR: Perform a pair of task and return the xor of the results.
-- Return: true if exactly one task succeeded
--         false if both tasks succeeded or both tasks failed
--------------------------------------------------------------------------------
bt.XOR = Class({init = function(self, children)
  self.nodeType = "xor"
  if #children == 2 then
    self.children = children
  end
end})

function bt.XOR:run(creatureAI)
  debugMessage(self.nodeType .. " update")
  if #self.children == 2 then
    return (self.children[1]:run(creatureAI) == not self.children[2]:run(creatureAI))
  end
  return false
end

--------------------------------------------------------------------------------
-- REPEATER: Repeat a single task multiple times.
-- Return: true, always
--------------------------------------------------------------------------------
bt.Repeater = Class({init = function(self, children, count)
  self.nodeType = "repeater"
  self.action = children[1]
  self.count = count
end})

function bt.Repeater:run(creatureAI)
  debugMessage(self.nodeType .. " update")
  for i = 1, self.count do
    self.action:run(creatureAI)
  end
  return true
end

--------------------------------------------------------------------------------
-- REPEATER_SUCCEED: Repeat a single task multiple times or until it succeeds.
-- Note: you can create a REPEATER_FAIL by inverting my child task.
-- Return: true if any iteration succeeds (with early return)
--         false if all iterations fail
--------------------------------------------------------------------------------
bt.Repeater_Succeed = Class({init = function(self, children, count)
  self.nodeType = "repeater_succeed"
  self.action = children[1]
  self.count = count
end})

function bt.Repeater_Succeed:run(creatureAI)
  debugMessage(self.nodeType .. " update")
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
bt.Selector = Class({init = function(self, children)
  self.nodeType = "selector"
  self.children = children
end})

function bt.Selector:run(creatureAI)
  debugMessage(self.nodeType .. " update")
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
bt.Sequence = Class({init = function(self, children)
  self.nodeType = "sequence"
  self.children = children
end})

function bt.Sequence:run(creatureAI)
  debugMessage(self.nodeType .. " update")
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
bt.Randomizer = Class({init = function(self, children)
  self.nodeType = "randomizer"
  self.children = children
end})

function bt.Randomizer:run(creatureAI)
  debugMessage(self.nodeType .. " update")
  if (#self.children == 0) then
    return math.random(2) == 2
  end
  i = math.random(#self.children)
  success = self.children[i]:run(creatureAI)
end


local function _treeToString(tree, indent)
  local strTree = string.rep(" ", indent) .. tree.nodeType .. "\n"
  for i,c in ipairs(tree.children) do
    strTree = strTree .. _treeToString(c, indent+1)
  end
  return strTree
end

function treeToString(tree)
  return _treeToString(tree, 0)
end

COND_TRUE = bt.Action(function() return true end)
COND_FALSE = bt.Action(function() return false end)

--------------------------------------------------------------------------------
-- Example
--------------------------------------------------------------------------------
--[[
function exampleLoop()

  -- testing subtree 1
  local fightAndEatGuards = bt.Sequence {
    bt.Randomizer {
      bt.Action(function() print("fighting and eating guards") return true end),
      bt.Action(function() print("getting killed by guards") return false end)
    }
  }
  -- testing subtree 2
  local packStuffAndGoHome = bt.Selector {
    bt.Sequence {
      bt.Action(function() print("still strong enough? yes") return true end),
      bt.Action(function() print("picking up gold") return true end),
    },
    bt.Sequence {
      bt.Action(function() print("flying home") return true end),
      bt.Action(function() print("putting treasure away") return true end),
    }
  }

  -- main tree
  local simpleBehaviour = bt.Selector {
    bt.Sequence {
      bt.Action(function() print("is thief near treasure? no") return false end),
      bt.Action(function() print("making the thief flee") return false end),
    },
    bt.Sequence {
      bt.Action(function() print("choosing Castle") return true end),
      bt.Action(function() print("fly to Castle") return true end),
      fightAndEatGuards,
      packStuffAndGoHome
    },
    bt.Sequence {
      bt.Action(function() print("posting pics on facebook") return true end)
    }
  }

  for i = 1, 10 do
    simpleBehaviour:run()
  end
end

exampleLoop()
--]]

return bt
