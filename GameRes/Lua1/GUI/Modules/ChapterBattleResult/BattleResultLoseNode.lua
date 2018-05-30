--
-- User: fenghao
-- Date: 30/06/2017
-- Time: 12:11 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local BattleResultLoseNode = Class(BaseNodeClass)

local function InitControls(self)
    local transform = self:GetUnityTransform()
end

function BattleResultLoseNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function BattleResultLoseNode:OnResume()
end

function BattleResultLoseNode:OnPause()
end

function BattleResultLoseNode:Show()
    self:ActiveComponent()
end

function BattleResultLoseNode:Close()
    self:InactiveComponent()
end

return BattleResultLoseNode