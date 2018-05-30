--
-- User: fenghao
-- Date: 16/06/2017
-- Time: 11:45 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local HeroDetailViewNode = Class(BaseNodeClass)

local function OnHeroDetailViewRefresh(self, heroID, userRoleData, refreshLeft, refreshRight, dataOnly)
    -- 发送消息 禁用相关按钮! --
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.GoEquipmentButtonDisabled, nil, userRoleData == nil)
    -- debug_print(self, heroID, userRoleData, refreshLeft, refreshRight, dataOnly)
    if refreshLeft then
        if userRoleData==nil then
            self.leftView:SetHeroID(heroID)
        else
            self.leftView:SetHeroID(nil)
        end

        self.leftView:Refresh(heroID, userRoleData, dataOnly)
      
    end

    if refreshRight then
        self.rightView:Refresh(heroID, userRoleData, dataOnly)
    end
end

local function RegisterEvents(self)
    -- 注册详细页面刷新事件 --
    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.HeroDetailViewRefresh, OnHeroDetailViewRefresh, nil)
end

local function UnregisterEvents(self)
    -- 取消注册详细页面刷新事件 --
    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.HeroDetailViewRefresh, OnHeroDetailViewRefresh, nil)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- LEFT --
    local LeftViewNodeClass = require "GUI.Hero.HeroDetailLeftViewNode"
    self.leftView = LeftViewNodeClass.New(transform:Find("Left"), self.rootAnimator)
    self:AddChild(self.leftView)

    -- RIGHT --
    local RightViewNodeClass = require "GUI.Hero.HeroDetailRightViewNode"
    self.rightView = RightViewNodeClass.New(transform:Find("Right"), self.rootAnimator)
    self:AddChild(self.rightView)

    RegisterEvents(self)
end

function HeroDetailViewNode:Ctor(parentTransform, rootAnimator)
    self.rootAnimator = rootAnimator
    self:BindComponent(parentTransform.gameObject, false)
    InitControls(self)

end

function HeroDetailViewNode:OnResume()
    HeroDetailViewNode.base.OnResume(self)

    UnregisterEvents(self)
    RegisterEvents(self)
end

function HeroDetailViewNode:OnPause()
    HeroDetailViewNode.base.OnPause(self)

    UnregisterEvents(self)
end

return HeroDetailViewNode

