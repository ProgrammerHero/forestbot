--
--  BehaviourTree
--
--  Created by Tilmann Hars on 2012-07-12.
--  Copyright (c) 2012 Headchant. All rights reserved.
--

local Class = require 'behaviourtree.class'

READY = "ready"
RUNNING = "running"
FAILED = "failed"

Action = Class({init = function(self, task)
    self.task = task
    self.completed = false
end})

function Action:update(creatureAI)
    if self.completed then return READY end
    self.completed = self.task(creatureAI)
    return RUNNING
    -- this probably needs a FAILED state
end

Condition = Class({init = function(self, condition)
    self.condition = condition
end})

function Condition:update(creatureAI)
    if self.condition(creatureAI) then
      return READY
    end
    return FAILED
end

Selector = Class({init = function(self, children)
    self.children = children
end})

function Selector:update(creatureAI)
    for i,v in ipairs(self.children) do
        status = v:update(creatureAI)
        if status == RUNNING then
            return RUNNING
        elseif status == READY then
            if i == #self.children then
                self:resetChildren()
                return READY
            end
        end
    end
    return READY
end

function Selector:resetChildren()
    for ii,vv in ipairs(self.children) do
        vv.completed = false
    end
end

Sequence = Class({init = function(self, children)
    self.children = children
    self.last = nil
    self.completed = false
end})

function Sequence:update(creatureAI)
echo("sequence update\n")
    if self.completed then
    echo ("sequence already complete\n")
      return READY
    end

     last = 1

    if self.last and self.last ~= #self.children then
        last = self.last + 1
    end

    for i = last, #self.children do
        v = self.children[i]:update(creatureAI)
        if v == RUNNING then
            self.last = i
            echo("sequence running\n")
            return RUNNING
        elseif v == FAILED then
            self.last = nil
            self:resetChildren()
            echo("sequence failed\n")
            return FAILED
        elseif v == READY then
            if i == #self.children then
                self.last = nil
                self:resetChildren()
                self.completed = true
            echo("sequence restarted\n")
                return READY
            end
        end
    end

end

function Sequence:resetChildren()
    for ii,vv in ipairs(self.children) do
        vv.completed = false
    end
end

---------------------------------------------------------------------------
-- Example
local TRUE = function() return true end
local FALSE = function() return false end

--[[
local isThiefNearTreasure = Condition(function() print("is thief near treasure? no") return false end)
local stillStrongEnoughToCarryTreasure = Condition(function() print("still strong enough? yes") return true end)
local updated = false


local makeThiefFlee = Action(function() print("making the thief flee") return false end)
local chooseCastle = Action(function() print("choosing Castle") return true end)
local flyToCastle = Action(function() print("fly to Castle") return true end)
local fightAndEatGuards = Action(function() print("fighting and eating guards") return false end)
local takeGold = Action(function() print("picking up gold") return true end)
local flyHome = Action(function() print("flying home") return true end)
local putTreasureAway = Action(function() print("putting treasure away") return true end)
local postPicturesOfTreasureOnFacebook = Action(function() print("posting pics on facebook") return true end)

-- testing subtree
 packStuffAndGoHome = Selector{
    Sequence{
        stillStrongEnoughToCarryTreasure,
        takeGold,

    },
    Sequence{
        flyHome,
        putTreasureAway,
    }
}

 simpleBehaviour = --Selector{
                            Sequence{
                                isThiefNearTreasure,
                                makeThiefFlee,
                            }--,
                            --Sequence{
                            --    chooseCastle,
                            --    flyToCastle,
                            --    fightAndEatGuards,
                            --    packStuffAndGoHome
                            --},
                            --Sequence{
                            --    postPicturesOfTreasureOnFacebook
                            --}
                        --}


function exampleLoop()
    for i=1,10 do
        simpleBehaviour:update()
    end
end

exampleLoop()
--]]