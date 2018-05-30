--
-- User: fenghao
-- Date: 30/06/2017
-- Time: 12:10 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local BattleResultLoseEffectNode = Class(BaseNodeClass)

local function InitControls(self)

end

function BattleResultLoseEffectNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function BattleResultLoseEffectNode:OnResume()

end

function BattleResultLoseEffectNode:OnPause()

end

function BattleResultLoseEffectNode:Show()
    self:ActiveComponent()
end

function BattleResultLoseEffectNode:Close()
    self:InactiveComponent()
end

return BattleResultLoseEffectNode
