local SceneClass = require "Framework.Base.Scene"

local UIScene = Class(SceneClass)

function UIScene:GetRootHangingPoint()
    return self:GetUIManager():GetBackgroundLayer()
end

return UIScene