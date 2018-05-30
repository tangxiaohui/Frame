--
-- User: fenghao
-- Date: 5/8/17
-- Time: 5:08 PM
--

local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
require "Collection.DataStack"
require "Collection.DataQueue"
require "Const"

local ServerService = require "Network.ServerService"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"

local DefendPrincessStateMachineClass = require "GUI.DefendPrincess.DefendThePrincessStateMachine"

local BezierPathClass = require "Framework.Bezier.BezierPath"
local DefendThePrincessScene = Class(BaseNodeClass)

function DefendThePrincessScene:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function DefendThePrincessScene:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/DefendThePrincess', function(go)
        self:BindComponent(go)
    end)
end

function DefendThePrincessScene:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    self:InitControls()
end

function DefendThePrincessScene:OnResume()
    -- 界面显示时调用
    DefendThePrincessScene.base.OnResume(self)
    self:RegisterControlEvents()
    self:RegisterNetworkEvents()
    self:ScheduleUpdate(self.Update)

    -- 默认隐藏2个面板
--    self.defendEnemyPanel:Close()
--    self.defendChestPanel:Close()
end

function DefendThePrincessScene:OnPause()
    -- 界面隐藏时调用
    DefendThePrincessScene.base.OnPause(self)
    self:UnregisterControlEvents()
    self:UnregisterNetworkEvents()
end

function DefendThePrincessScene:OnEnter()
    -- Node Enter时调用
    DefendThePrincessScene.base.OnEnter(self)
end

function DefendThePrincessScene:OnExit()
    -- Node Exit时调用
    DefendThePrincessScene.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function DefendThePrincessScene:InitControls()
    local transform = self:GetUnityTransform()

    -- 敌人面板
    local EnemyFormationTrans = transform:Find("DefendThePrincessEnemy")
    local DefendEnemyPanelClass = require "GUI.DefendPrincess.DefendEnemyPanel"
    self.defendEnemyPanel = DefendEnemyPanelClass.New(EnemyFormationTrans, self, self.OnEnemyListRequested)
    self:AddChild(self.defendEnemyPanel)

    -- 宝箱面板
    local ChestPanelTrans = transform:Find("DefendThePrincessChest")
    local DefendChestPanelClass = require "GUI.DefendPrincess.DefendChestPanel"
    self.defendChestPanel = DefendChestPanelClass.New(ChestPanelTrans)
    self:AddChild(self.defendChestPanel)

    -- 默认隐藏2个面板
    self.defendEnemyPanel:Close()
    self.defendChestPanel:Close()

    -- 返回按钮
    self.DefendThePrincessReturnButton = transform:Find("DefendThePrincessReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 按钮面板 --
    local ButtonListTrans = transform:Find("ButtonList")
    self.BattleButton = ButtonListTrans:Find("BattleButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.ShopButton = ButtonListTrans:Find("ShopButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.RefreshButton = ButtonListTrans:Find("RefreshButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.DescriptionButton = ButtonListTrans:Find("DescriptionButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- ### 获取控制点
    local ControlPoints = {}
    local ControlPointsTrans = transform:Find("ControlPoints")
    local childCount = ControlPointsTrans.childCount
    for i = 0, childCount - 1 do
        local child = ControlPointsTrans:GetChild(i)
        ControlPoints[#ControlPoints + 1] = child.localPosition
    end
    ControlPointsTrans.gameObject:SetActive(false)

    -- ### 贝塞尔曲线 路径 ### --
    self.bezierPath = BezierPathClass.New(ControlPoints, 0.05)


    -- ### 获取玩家控件 ### --
    local DefendPrincessPlayerClass = require "GUI.DefendPrincess.DefendThePrincessPlayer"

    -- 保卫公主玩家控件
    local DefendPrincessPlayers = {
        DefendPrincessPlayerClass.New(transform:Find("DefendThePrincess/DefendThePrincessPlayer1")),
        DefendPrincessPlayerClass.New(transform:Find("DefendThePrincess/DefendThePrincessPlayer2")),
        DefendPrincessPlayerClass.New(transform:Find("DefendThePrincess/DefendThePrincessPlayer3")),
        DefendPrincessPlayerClass.New(transform:Find("DefendThePrincess/DefendThePrincessPlayer4")),
        DefendPrincessPlayerClass.New(transform:Find("DefendThePrincess/DefendThePrincessPlayer5"))
    }

    -- 保卫公主的位置比率
    self.LengthRatios = {
        1,
        0.84,
        0.66,
        0.48,
        0.29
    }

    -- 创建队列 / 池 --
    self.defendPlayerStack = DataStack.New()
    self.defendPlayerQueue = DataQueue.New()

    -- 先隐藏这些控件 --
    for i = 1, #DefendPrincessPlayers do
        DefendPrincessPlayers[i]:Clear()
        DefendPrincessPlayers[i]:SetCallback(self, self.OnRefreshPanelStatus)
        self.defendPlayerStack:Push(DefendPrincessPlayers[i])
        self:AddChild(DefendPrincessPlayers[i])
    end

    -- 初始化保卫公主状态机 --
    local Pool = require "Framework.Pool.CommonStatePool".New()
    local DataContext = {}
    DataContext.BezierPath = self.bezierPath
    DataContext.LengthRatios = self.LengthRatios
    DataContext.MaxViewPlayerNum = 5
    DataContext.Pool = Pool
    DataContext.DefendPlayerStack = self.defendPlayerStack
    DataContext.DefendPlayerQueue = self.defendPlayerQueue
    local InitState = Pool:Get(require "GUI.DefendPrincess.UpdateDataState")
    self.stateMachine = DefendPrincessStateMachineClass.New(self, InitState, DataContext)
    self.StateMachineDataContext = DataContext
end

function DefendThePrincessScene:ResetControlStatus()
    -- 默认隐藏2个面板
    self.defendEnemyPanel:Close()
    self.defendChestPanel:Close()

    while(self.defendPlayerQueue:Count() > 0)
    do
        local playerItem = self.defendPlayerQueue:Dequeue()
        playerItem:Clear()
        self.defendPlayerStack:Push(playerItem)
    end

end

function DefendThePrincessScene:Update()
    self.stateMachine:Update()
end


function DefendThePrincessScene:RegisterControlEvents()
    -- 注册 返回 按钮
    self.__event_button_PrincessReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPrincessReturnButtonClicked, self)
    self.DefendThePrincessReturnButton.onClick:AddListener(self.__event_button_PrincessReturnButtonClicked__)

    -- 注册 战斗 按钮
    self.__event_button_BattleButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBattleButtonClicked, self)
    self.BattleButton.onClick:AddListener(self.__event_button_BattleButtonClicked__)

    -- 注册 商店 按钮
    self.__event_button_ShopButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopButtonClicked, self)
    self.ShopButton.onClick:AddListener(self.__event_button_ShopButtonClicked__)

    -- 注册 重置 按钮
    self.__event_button_RefreshButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRefreshButtonClicked, self)
    self.RefreshButton.onClick:AddListener(self.__event_button_RefreshButtonClicked__)

    -- 注册 规则说明 按钮
    self.__event_button_DescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDescriptionButtonClicked, self)
    self.DescriptionButton.onClick:AddListener(self.__event_button_DescriptionButtonClicked__)
end

function DefendThePrincessScene:UnregisterControlEvents()
    -- 取消 返回 按钮
    if self.__event_button_PrincessReturnButtonClicked__ then
        self.DefendThePrincessReturnButton.onClick:RemoveListener(self.__event_button_PrincessReturnButtonClicked__)
        self.__event_button_PrincessReturnButtonClicked__ = nil
    end

    -- 取消 战斗 按钮
    if self.__event_button_BattleButtonClicked__ then
        self.BattleButton.onClick:RemoveListener(self.__event_button_BattleButtonClicked__)
        self.__event_button_BattleButtonClicked__ = nil
    end

    -- 取消 商店 按钮
    if self.__event_button_ShopButtonClicked__ then
        self.ShopButton.onClick:RemoveListener(self.__event_button_ShopButtonClicked__)
        self.__event_button_ShopButtonClicked__ = nil
    end

    -- 取消 重置 按钮
    if self.__event_button_RefreshButtonClicked__ then
        self.RefreshButton.onClick:RemoveListener(self.__event_button_RefreshButtonClicked__)
        self.__event_button_RefreshButtonClicked__ = nil
    end

    -- 取消 规则说明 按钮
    if self.__event_button_DescriptionButtonClicked__ then
        self.DescriptionButton.onClick:RemoveListener(self.__event_button_DescriptionButtonClicked__)
        self.__event_button_DescriptionButtonClicked__ = nil
    end
end

function DefendThePrincessScene:RegisterNetworkEvents()
end

function DefendThePrincessScene:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 重置状态
-----------------------------------------------------------------------
function DefendThePrincessScene:ResetTheStateMachine()
    self.StateMachineDataContext.needToReset = true
end

function DefendThePrincessScene:CancelResetState()
    self.StateMachineDataContext.needToReset = nil
end

function DefendThePrincessScene:DoesNeedToResetTheStateMachine()
    return self.StateMachineDataContext.needToReset == true
end

-----------------------------------------------------------------------
--- 保卫公主的数据
-----------------------------------------------------------------------
function DefendThePrincessScene:SetProtectPrincessData(protectPrincess)
    self.StateMachineDataContext.protectPrincess = protectPrincess
end

function DefendThePrincessScene:GetProtectPrincessData()
    return self.StateMachineDataContext.protectPrincess
end

-----------------------------------------------------------------------
--- 网络事件处理
-----------------------------------------------------------------------
function DefendThePrincessScene:OnRefreshPanelStatus(playerItem)

    -- 清除
    self.BattleButton.interactable = false
    self.BattleButton.targetGraphic.material = utility.GetGrayMaterial()

    if playerItem:IsResetStatus() then
        self.defendEnemyPanel:Close()
        self.defendChestPanel:Close()
        return
    end

    if playerItem:IsWaitingForBattle() then
        -- 请求敌人 --
        self.defendChestPanel:Close()
        self.defendEnemyPanel:ShowEnemy(playerItem:GetGateID())
    elseif playerItem:IsWaitingForReceive() then
        -- 打开领取奖励 --
        self.defendEnemyPanel:Close()
        -- TODO 传入参数待定
        self.defendChestPanel:ShowChest()
    end
end

function DefendThePrincessScene:OnEnemyListRequested()
    -- 清除
    self.BattleButton.interactable = true
    self.BattleButton.targetGraphic.material = utility.GetCommonMaterial()
end

-----------------------------------------------------------------------
--- 控件事件处理
-----------------------------------------------------------------------
function DefendThePrincessScene:OnBattleButtonClicked()
    local princessData = self:GetProtectPrincessData()
    if princessData == nil then
        utility.ShowErrorDialog("网络繁忙 请稍后重试!")
        return
    end

    if princessData:IsWaitingForReceive() then
        utility.ShowErrorDialog("请先领取奖励!")
        return
    end

    if princessData:HasRewardReceived() then
        utility.ShowErrorDialog("已领取奖励 未知错误!")
        return
    end

    if self.defendEnemyPanel:GetGateID() == nil then
        utility.ShowErrorDialog("当前的数据id为nil!")
        return
    end

    -- 只有等待战斗时 才可以战斗
    -- 因为是 PVP 战斗 所以禁用手动操作
    local LocalDataType = require "LocalData.LocalDataType"
    local battleStartParams = require "LocalData.BattleStartParams".New()
    battleStartParams:DisableManuallyOperation()
    battleStartParams:SetBattleResultLocalDataName(LocalDataType.ProtectBattleResult)
    battleStartParams:SetBattleRecordProtocol(ServerService.ProtectStartFightRequest(princessData:GetCurrentGate()))
    battleStartParams:SetBattleResultResponse(net.S2CProtectStartFightResult)
    battleStartParams:SetBattleResultViewHANDLEClassName("GUI.BattleResults.ProtectFightingResultModule")

    local foeTeams = self.defendEnemyPanel:GetTeam()

    -- 敌人战斗
    utility.StartBattle(kLineup_Protect, battleStartParams, foeTeams)
end

function DefendThePrincessScene:OnShopButtonClicked()
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Shop.Shop",2)
end

function DefendThePrincessScene:OnRefreshButtonClicked()
    local princessData = self:GetProtectPrincessData()
    if princessData == nil then
        return
    end

    if princessData:GetRemainResetCount() == 0 then
        utility.ShowErrorDialog("今日重置次数已使用完")
        return
    end

    -- 重置的协议
    self:ResetTheStateMachine()
end

function DefendThePrincessScene:OnDescriptionButtonClicked()
    -- CommonDescriptionModule
    local CommonDescriptionModuleClass = require "GUI.CommonDescriptionModule"
    local windowManager = utility.GetGame():GetWindowManager()
    windowManager:Show(CommonDescriptionModuleClass, "没有内容 没有内容")
end

function DefendThePrincessScene:OnPrincessReturnButtonClicked()
    local myGame = self:GetGame()
    local sceneManager = myGame:GetSceneManager()
    sceneManager:PopScene()
end

return DefendThePrincessScene
