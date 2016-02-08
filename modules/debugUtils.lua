local debugUtils = {}

--------------------------------------------------------------------------------
-- Return function for printing debug messages
--------------------------------------------------------------------------------
function debugUtils.getDebugMessage(debugMode)
  if debugMode then
    return function (s) print(">> " .. s) end
  else
    return function (s) end
  end
end

return debugUtils
