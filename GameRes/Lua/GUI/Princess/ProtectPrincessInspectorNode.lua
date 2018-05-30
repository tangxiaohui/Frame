--
-- User: fenghao
-- Date: 03/07/2017
-- Time: 7:50 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "Const"
local messageGuids = require "Framework.Business.MessageGuids"

local ProtectPrincessInspectorNode = Class(BaseNodeClass)

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 1. 敌人队形
    local ProtectPrincessEnemyViewNodeClass = require "GUI.Princess.ProtectPrincessEnemyViewNode"
    self.enemyViewNode = ProtectPrincessEnemyViewNodeClass.New(transform:Find("Formation"))
    self:AddChild(self.enemyViewNode)

    -- 2. 领取宝箱
    local ProtectPrincessAwardViewNodeClass = require "GUI.Princess.ProtectPrincessAwardViewNode"
    self.awardViewNode = ProtectPrincessAwardViewNodeClass.New(transform:Find("BoxInfo"))
    self:AddChild(self.awardViewNode)

    -- 3. 标题文本
    self.nameBaseObject = transform:Find("NameBase").gameObject
    self.textLabel = transform:Find("NameBase/TextLabel"):GetComponent(typeof(UnityEngine.UI.Text))
end

function ProtectPrincessInspectorNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

local function OnGateAwardMode(self)
    --print("奖励!")
    --debug_print("@@@@ >> aid", self.protectMsg.aid)

    self.awardViewNode:Show(self.protectMsg)
end

local function OnGateFightMode(self)
    --print("战斗!")
    self.enemyViewNode:Show(self.protectMsg)
end

local function OnProtectDataQueryUpdate(self, msg)
    --debug_print("OnProtectDataQueryUpdate >>>> 1", msg.aid)

    self.protectMsg = msg

    self.nameBaseObject:SetActive(false)
    -- 先关闭两个 --
    self.enemyViewNode:Close()
    self.awardViewNode:Close()
    
	local totalGateCount = #msg.gateInfo
	if self.protectMsg.curGate > totalGateCount then
		return
	end
	
    -- 然后判断模式 --
    if msg.gateState == kProtectPrincessGateStatus_Received then
        error("不可能走这个模式!!!")
    end

    print("模式 >>>> ", msg.gateState)

    if msg.gateState == kProtectPrincessGatetatus_NotReceiveYet then
        -- 领取宝箱模式 --
        OnGateAwardMode(self)
    else
        -- 战斗模式 请求敌人信息 --
        OnGateFightMode(self)
    end
end

local function OnProtectDataNextGateAnimFinished(self, msg)
    -- OnProtectDataQueryUpdate(self, msg)
end

local function OnProtectDataNextGate(self, msg)

    --debug_print("@@ OnProtectDataNextGate 2 @@")

    self.nameBaseObject:SetActive(false)
    -- 先关闭两个 --
    self.enemyViewNode:Close()
    self.awardViewNode:Close()

    OnProtectDataQueryUpdate(self, msg)
end

local function OnProtectShowInspectorTitle(self, isShow, title)
    self.nameBaseObject:SetActive(isShow)
    if isShow then
        self.textLabel.text = title
    end
end

function ProtectPrincessInspectorNode:OnResume()
    -- OnResume
    self:RegisterEvent(messageGuids.ProtectDataQueryUpdate, OnProtectDataQueryUpdate, nil)
    self:RegisterEvent(messageGuids.ProtectDataNextGate, OnProtectDataNextGate, nil)
    self:RegisterEvent(messageGuids.ProtectDataNextGateAnimFinished, OnProtectDataNextGateAnimFinished, nil)
    self:RegisterEvent(messageGuids.ProtectShowInspectorTitle, OnProtectShowInspectorTitle, nil)
end

function ProtectPrincessInspectorNode:OnPause()
    -- OnPause
    self:UnregisterEvent(messageGuids.ProtectDataQueryUpdate, OnProtectDataQueryUpdate, nil)
    self:UnregisterEvent(messageGuids.ProtectDataNextGate, OnProtectDataNextGate, nil)
    self:UnregisterEvent(messageGuids.ProtectDataNextGateAnimFinished, OnProtectDataNextGateAnimFinished, nil)
    self:UnregisterEvent(messageGuids.ProtectShowInspectorTitle, OnProtectShowInspectorTitle, nil)
end

return ProtectPrincessInspectorNode
