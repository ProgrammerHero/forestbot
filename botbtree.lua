--------------------------------------------------------------------------------
-- botbtree.lua
-- Aegeus, ProgrammerHero
-- 2016
--
-- Useful Links:
-- http://behavior3js.guineashots.com/editor/#
-- Disclaimer: This format is a piece of trash. - ProgrammerHero
--------------------------------------------------------------------------------
local debugMode = true
local debugMessage = require("debugUtils").getDebugMessage(debugMode)

local botbtree = {}
local btree
local json = require("json")
local bt = require("behaviourtree.behaviourtree")

function botbtree.init(worldStatus)
  botbtree.reset()
end

function botbtree.reset()
  btree = botbtree.loadJSON("behaviour.json")
end


---------------------------------------
-- Add custom behaviour tree nodes here
---------------------------------------
local function enemyPresent()
  debugMessage("Enemy present!")
  return true
  -- check for a bot in the current room
  --bot.map[]
end

local function shouldFight()
  debugMessage("I'm an aggressive little bot!")
  return true
end

local function escape()
  debugMessage("He's got me trapped!")
  return false
end

local function attack()
  debugMessage("He's too scary.. not attacking.")
  return false
end

local function moveTo()
  debugMessage("Tried moving to.., unsuccessfully.")
  return false
end

local function isHungry()
  debugMessage("Checking if the bot is hungry.")
  return bot.status.needs.hunger > 0
end

local function eatFood()
  debugMessage("Eating food")
  -- should be smarter and try to find specific food
  send("eat food")
  return true
  -- 
end

local function isThirsty()
  debugMessage("Checking if the bot is thirsty.")
  return bot.status.needs.thirst > 0
end

local function drink()
  debugMessage("Drinking")
  -- should be smarter and try to find a specific drink
  -- also need to make sure we have a drink equipped
  send("drink bronze.cup") -- this command is probably wrong
  return true
end

local function hasItem()
  debugMessage("I have some!")
  return true
end

local function isTired()
  debugMessage("Checking if the bot is tired.")
  return bot.status.health.moves < 20
end

local function sleep()
  debugMessage("Sleeping")
  send("sleep")
  return true
end

-----------------------
-- behaviourtree parser
-----------------------
local function buildBTree(tree, rootID)
  local node = tree[rootID]
  local children = {}

  -- sort out my children and build the tree from the bottom up
  if (node["children"] and #(node["children"]) > 0) then
    --echo("multiple children")
    for i,c in ipairs(node["children"]) do
      children[#children+1] = buildBTree(tree, c)
    end
  elseif (node["child"] and #(node["child"]) > 0) then
    --echo("one child")
    children[1] = buildBTree(tree, node["child"])
  else
    --echo("no children") -- probably an action node
    children[1] = bt.COND_TRUE
  end

  local maxLoop = 0
  if (tree[rootID]["parameters"] ~= nil and tree[rootID]["parameters"]["maxLoop"] ~= nil) then
    maxLoop = tonumber(tree[rootID]["parameters"]["maxLoop"])
  end

  -- now figure out what this node is
  --------------------------
  -- Behaviour3JS core nodes
  --------------------------
  local name = tree[rootID]["name"]
  if (name == "Sequence") then
    node = bt.Sequence(children)
  elseif (name == "Priority") then
    node = bt.Selector(children)
  elseif (name == "MemSequence") then
  elseif (name == "MemPriority") then
  elseif (name == "Repeater") then
    node = bt.Repeater(children[1], maxLoop)
  elseif (name == "RepeatUntilFailure") then
    node = bt.Repeater_Succeed(bt.Inverter(children[1], maxLoop))
  elseif (name == "RepeatUntilSuccess") then
    node = bt.Repeater_Succeed(children[1], maxLoop)
  elseif (name == "MaxTime") then
  elseif (name == "Inverter") then
    node = bt.Inverter(children[1])
  elseif (name == "Limiter") then
  elseif (name == "Failer") then
    node = bt.Inverter(bt.Succeeder(children[1]))
  elseif (name == "Succeeder") then
    node = bt.Succeeder(children[1])
  elseif (name == "Runner") then
  elseif (name == "Error") then
  elseif (name == "Wait") then

  ---------------
  -- Custom nodes
  ---------------
  elseif (name == "IsHungry") then
    node = bt.Action(isHungry)
  elseif (name == "IsThirsty") then
    node = bt.Action(isThirsty)
  elseif (name == "HasItem") then
    node = bt.Action(hasItem)
  elseif (name == "EatFood") then
    node = bt.Action(eatFood)
  elseif (name == "Drink") then
    node = bt.Action(drink)
  elseif (name == "EnemyPresent") then
    node = bt.Action(enemyPresent)
  elseif (name == "ShouldFight") then
    node = bt.Action(shouldFight)
  elseif (name == "Attack") then
    node = bt.Action(attack)
  elseif (name == "Escape") then
    node = bt.Action(escape)
  elseif (name == "MoveTo") then
    node = bt.Action(moveTo)
  elseif (name == "IsTired") then
    node = bt.Action(isTired)
  elseif (name == "Sleep") then
    node = bt.Action(sleep)
  else
    echo("Unrecognized btree element '" .. name .. "'")
    node = nil
  end

  return node
end

function botbtree.loadJSON(file)
  local j = io.open(os.getenv("forestbot_path") .. "/" .. file, "r")
  if (not j) then
    echo("Failed to open file: " .. file)
    return nil
  end

  local content = j:read("*all")
  j:close()

  local tree = json.parse(content)
  local root = tree["root"]
  --echo(tree["nodes"][root]["name"])
  return buildBTree(tree["nodes"], root)
end

function botbtree.think()
  btree:run()
end

return botbtree
