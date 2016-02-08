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
local debugMessage = require("modules.debugUtils").getDebugMessage(debugMode)

local botbtree = {}
local btree
local json = require("modules.json")
local bt = require("behaviourtree.behaviourtree")
local tasks

function botbtree.init(worldStatus, worldTasks)
  tasks = worldTasks
  botbtree.reset()
end

function botbtree.reset()
  btree = botbtree.loadJSON("behaviour.json")
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

  if bt[name] then
    debugMessage("Building " .. name)
    node = bt[name](children, maxLoop)
  elseif tasks and tasks[name] then
    debugMessage("Building " .. name)
    node = bt.Action(name, tasks[name])
  else
    debugMessage("Unrecognized btree element '" .. name .. "'")
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
