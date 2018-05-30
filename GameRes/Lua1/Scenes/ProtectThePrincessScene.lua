--
-- User: fenghao
-- Date: 03/07/2017
-- Time: 7:10 PM
--

local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local ServerService = require "Network.ServerService"
local messageGuids = require "Framework.Business.MessageGuids"

local ProtectThePrincessScene = Class(BaseNodeClass)

function ProtectThePrincessScene:Ctor()
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 返回按钮 --
    self.backButton = transform:Find("BackButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 刷新按钮 --
    self.refreshButton = transform:Find("TopCanvas/ButtonGroup/RefreshButton"):GetComponent(typeof(UnityEngine.UI.Button))
	
	 -- 商店按钮 --
    self.shopButton = transform:Find("TopCanvas/ButtonGroup/ShopButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 说明按钮 --
    self.infoButton = transform:Find("TopCanvas/ButtonGroup/InfoButton"):GetComponent(typeof(UnityEngine.UI.Button))

	
	-- 结果Canvas控件 --
	self.princessCongratulationsObject = transform:Find("TopCanvas/PrincessCongratulations").gameObject
    self.princessCongratulationsButton = transform:Find("TopCanvas/PrincessCongratulations/ReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))
	
	
    -- 场景预览 --
    local ProtectPrincessBattleViewNodeClass = require "GUI.Princess.ProtectPrincessBattleViewNode"
    self.battleViewNode = ProtectPrincessBattleViewNodeClass.New(transform:Find("Scene"))
    self:AddChild(self.battleViewNode)

    -- 状态检察框 --
    local ProtectPrincessInspectorNodeClass = require "GUI.Princess.ProtectPrincessInspectorNode"
    self.inspectorNode = ProtectPrincessInspectorNodeClass.New(transform:Find("Information/Group"))
    self:AddChild(self.inspectorNode)
end

function ProtectThePrincessScene:OnInit()
    utility.LoadNewGameObjectAsync(
        "UI/Prefabs/ProtectThePrincess",
        function(go)
            self:BindComponent(go)
        end
    )
end

function ProtectThePrincessScene:OnComponentReady()
    InitControls(self)
end

-- 返回按钮 --
local function OnBackButtonClicked(self)
    local myGame = require "Utils.Utility".GetGame()
    local sceneManager = myGame:GetSceneManager()
    sceneManager:PopScene()
end

-- 刷新请求 --
function ProtectThePrincessScene:OnRefreshButtonRequest()
    -- 发送重置消息 --
    local msg, prototype = ServerService.ProtectResetRequest()
    self:GetGame():SendNetworkMessage(msg, prototype)
end

-- 刷新按钮 --
local function OnRefreshButtonClicked(self)
    if self.protectMsg == nil then
        return
    end

    if self.protectMsg.remainResetCount == 0 then
        utility.ShowErrorDialog("今日重置次数已使用完")
        return
    end

    local windowManager = utility:GetGame():GetWindowManager()
    local str = string.format("今天剩余%d次重置机会，是否确定重置",self.protectMsg.remainResetCount)
    local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
    windowManager:Show(ConfirmDialogClass, str, self, self.OnRefreshButtonRequest)
end

-- 商店按鈕 --
local function OnShopButtonClicked(self)
	local windowManager = utility.GetGame():GetWindowManager()
   	windowManager:Show(require "GUI.Shop.Shop",KShopType_ProtectPrincess)
end

-- 说明按钮 --
local function OnInfoButtonClicked(self)
    -- CommonDescriptionModule
    local CommonDescriptionModuleClass = require "GUI.CommonDescriptionModule"
    local windowManager = utility.GetGame():GetWindowManager()
    
    local id = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_DefendPrincess):GetDescriptionInfo()[0]
    local description = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
    windowManager:Show(CommonDescriptionModuleClass, description)
end

-- 保卫公主的Response --
local function OnProtectQueryResponse(self, msg)

    self.princessCongratulationsObject:SetActive(false)

    debug_print("@@@@ aid", msg.aid)
    if msg.head.sid == 100 then
        if self.protectMsg == nil then
            return
        end
        self.protectMsg.curGate = msg.curGate
        self.protectMsg.gateState = msg.gateState
        msg = self.protectMsg
    else
        self.protectMsg = msg
    end

    -- self.protectMsg = msg

    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.ProtectDataQueryUpdate, nil, msg)
	
	-- total
    self.princessCongratulationsObject:SetActive(self.protectMsg.curGate > #msg.gateInfo)

end

local function OnProtectResetResponse(self, msg)
    -- 请求数据 --
    local msg, prototype = ServerService.ProtectQueryRequest()
    self:GetGame():SendNetworkMessage(msg, prototype)
end

local function OnProtectDataDone(self)
	self.princessCongratulationsObject:SetActive(true)
end

function ProtectThePrincessScene:OnResume()
    ProtectThePrincessScene.base.OnResume(self)

    -- 注册 BackButton
    self.__event_backButtonClicked__ = UnityEngine.Events.UnityAction(OnBackButtonClicked, self)
    self.backButton.onClick:AddListener(self.__event_backButtonClicked__)
    self.princessCongratulationsButton.onClick:AddListener(self.__event_backButtonClicked__)

    -- -- 注册 ResetButton
    -- self.__event_resetButtonClicked__ = UnityEngine.Events.UnityAction(OnRefreshButtonClicked, self)
    -- self.princessResetButton.onClick:AddListener(self.__event_resetButtonClicked__)
	
	 -- 注册 ShopButton
    self.__event_shopButtonClicked__ = UnityEngine.Events.UnityAction(OnShopButtonClicked, self)
    self.shopButton.onClick:AddListener(self.__event_shopButtonClicked__)

    -- 注册 RefreshButton
    self.__event_refreshButtonClicked__ = UnityEngine.Events.UnityAction(OnRefreshButtonClicked, self)
    self.refreshButton.onClick:AddListener(self.__event_refreshButtonClicked__)

    -- 注册 InfoButton
    self.__event_infoButtonClicked__ = UnityEngine.Events.UnityAction(OnInfoButtonClicked, self)
    self.infoButton.onClick:AddListener(self.__event_infoButtonClicked__)

	
	self:RegisterEvent(messageGuids.ProtectDataDone, OnProtectDataDone, nil)
	

    -- 注册保卫公主 --
    self:GetGame():RegisterMsgHandler(net.S2CProtectQueryResult, self, OnProtectQueryResponse)
    self:GetGame():RegisterMsgHandler(net.S2CProtectResetResult, self, OnProtectResetResponse)

    -- 请求数据 --
    local msg, prototype = ServerService.ProtectQueryRequest()
    self:GetGame():SendNetworkMessage(msg, prototype)

    -- 进入保卫公主界面
    require "Utils.GameAnalysisUtils".EnterScene("保卫公主")
    require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_ProtectThePrincessView)
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[12].systemGuideID,self)


end

function ProtectThePrincessScene:OnPause()
    ProtectThePrincessScene.base.OnPause(self)

    self:GetGame():UnRegisterMsgHandler(net.S2CProtectQueryResult, self, OnProtectQueryResponse)
    self:GetGame():UnRegisterMsgHandler(net.S2CProtectResetResult, self, OnProtectResetResponse)

    -- 取消注册 BackButton
    if self.__event_backButtonClicked__ then
        self.backButton.onClick:RemoveListener(self.__event_backButtonClicked__)
		self.princessCongratulationsButton.onClick:RemoveListener(self.__event_backButtonClicked__)
        self.__event_backButtonClicked__ = nil
    end

    -- -- 取消注册 ResetButton
    -- if self.__event_resetButtonClicked__ then
    --     self.princessResetButton.onClick:RemoveListener(self.__event_resetButtonClicked__)
    --     self.__event_resetButtonClicked__ = nil
    -- end

    -- 取消注册 RefreshButton
    if self.__event_refreshButtonClicked__ then
        self.refreshButton.onClick:RemoveListener(self.__event_refreshButtonClicked__)
        self.__event_refreshButtonClicked__ = nil
    end

    -- 取消注册 InfoButton
    if self.__event_infoButtonClicked__ then
        self.infoButton.onClick:RemoveListener(self.__event_infoButtonClicked__)
        self.__event_infoButtonClicked__ = nil
    end

    -- 取消注册 ShopButton
    if self.__event_shopButtonClicked__ then
        self.shopButton.onClick:RemoveListener(self.__event_shopButtonClicked__)
        self.__event_shopButtonClicked__ = nil
    end
	
	self:RegisterEvent(messageGuids.ProtectDataDone, OnProtectDataDone, nil)
end


return ProtectThePrincessScene
