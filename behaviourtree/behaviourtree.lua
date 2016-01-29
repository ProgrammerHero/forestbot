--
--  BehaviourTree
--
--  Created by Tilmann Hars on 2012-07-12.
--  Copyright (c) 2012 Headchant. All rights reserved.
--
-- Useful links:
-- http://gamedev.stackexchange.com/questions/51693/decision-tree-vs-behavior-tree
-- http://aigamedev.com/open/article/behavior-trees-part1/

local Class = require 'behaviourtree.class'

--------------------------------------------------------------------------------
-- ACTION: Perform a single task and return the result.
--------------------------------------------------------------------------------
Action = Class({init = function(self, task)
  self.task = task
end})

function Action:run(creatureAI)
  return self.task(creatureAI)
end

--------------------------------------------------------------------------------
-- NEGATOR: Perform a single task and return the negative of the result.
--------------------------------------------------------------------------------
Negator = Class({init = function(self, task)
  self.task = task
end})

function Negator:run(creatureAI)
  return not self.task(creatureAI)
end

--------------------------------------------------------------------------------
-- REPEATER: Repeat a single task multiple times.
-- Return: true if all iterations pass
--         false if any iteration fails (?)
--------------------------------------------------------------------------------
Repeater = Class({init = function(self, task, count)
  self.task = task
  self.count = count
end})

function Repeater:run(creatureAI)
  for i = 1, self.count do
    self.task(creatureAI)
  end
  return true
end
--------------------------------------------------------------------------------
-- SELECTOR: Execute my children in order and stop executing if one succeeds.
-- Return: true if any child succeeds
--         false if every child fails
--------------------------------------------------------------------------------
Selector = Class({init = function(self, children)
  self.children = children
end})

function Selector:run(creatureAI)
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
  self.children = children
end})

function Sequence:run(creatureAI)
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
  self.children = children
end})

function Randomizer:run(creatureAI)
  if (#self.children == 0) then
    return math.random(2) == 2
  end
  i = math.random(#self.children)
  success = self.children[i]:run(creatureAI)
end


--------------------------------------------------------------------------------
-- Example
--------------------------------------------------------------------------------

function exampleLoop()

  local COND_TRUE = Action(function() return true end)
  local COND_FALSE = Action(function() return false end)

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
