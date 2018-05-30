local NodeClass = require "Framework.Base.Node"

local UINode = Class(NodeClass)

function UINode:GetRootHangingPoint()
    return self:GetUIManager():GetBackgroundLayer()
end

return UINode