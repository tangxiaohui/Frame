local NodeClass = require "Framework.Base.Node"

local Scene = Class(NodeClass)

function Scene:IsTransition()
    return false
end

return Scene