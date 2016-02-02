--------------------------------------------------------------------------------
-- botbtree.lua
-- Aegeus, ProgrammerHero
-- 2016
--
-- Useful Links:
-- http://behavior3js.guineashots.com/editor/#
-- Disclaimer: This format is a piece of trash. - ProgrammerHero
--------------------------------------------------------------------------------

local botbtree = {}
local json = require("json")

local function buildBTree(tree, rootID)
  local node = tree[rootID]
  local children = {}

  -- sort out my children and build the tree from the bottom up
  if (node["children"] and #(node["children"]) > 0) then
    echo("multiple children")
    for i,c in ipairs(node["children"]) do
      children[#children+1] = buildBTree(tree, c)
    end
  elseif (node["child"] and #(node["child"]) > 0) then
    echo("one child")
    children[1] = buildBTree(tree, node["child"])
  else
    echo("no children") -- probably an action node
    children[1] = COND_TRUE
  end

  local maxLoop = 0
  if (tree[rootID]["parameters"] ~= nil and tree[rootID]["parameters"]["maxLoop"] ~= nil) then
    maxLoop = tonumber(tree[rootID]["parameters"]["maxLoop"])
  end

  -- now figure out what this node is
  local name = tree[rootID]["name"]
  if (name == "Sequence") then
    node = Sequence(children)
  elseif (name == "Priority") then
    node = Selector(children)
  elseif (name == "MemSequence") then
  elseif (name == "MemPriority") then
  elseif (name == "Repeater") then
    node = Repeater(children[1], maxLoop)
  elseif (name == "RepeatUntilFailure") then
    node = Repeater_Succeed(Inverter(children[1], maxLoop))
  elseif (name == "RepeatUntilSuccess") then
    node = Repeater_Succeed(children[1], maxLoop)
  elseif (name == "MaxTime") then
  elseif (name == "Inverter") then
    node = Inverter(children[1])
  elseif (name == "Limiter") then
  elseif (name == "Failer") then
    node = Inverter(Succeeder(children[1]))
  elseif (name == "Succeeder") then
    node = Succeeder(children[1])
  elseif (name == "Runner") then
  elseif (name == "Error") then
  elseif (name == "Wait") then
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
  echo(tree["nodes"][root]["name"])
  return buildBTree(tree["nodes"], root)
end

return botbtree
