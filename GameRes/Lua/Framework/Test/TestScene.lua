local SceneClass = require "Framework.Base.Scene"

local TestScene = Class(SceneClass)

function TestScene:Ctor()
    --self:AddChild(TestNodeCls.New())
end

function TestScene:OnEnter()
    TestScene.base.OnEnter(self)
    local TestNodeCls = require "GUI.Main.MainUINode"
    self:AddChild(TestNodeCls.New())
end

return TestScene