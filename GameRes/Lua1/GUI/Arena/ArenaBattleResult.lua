
local BaseNodeClass = require "GUI.BattleResults.BaseBattleResultModule"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"

local ArenaBattleResultDialog = Class(BaseNodeClass)

windowUtility.SetMutex(ArenaBattleResultDialog, true)

-------------------------------------------------------------------------
----- ###### !!!!!竞技场战斗使用的!!!!! ######
-------------------------------------------------------------------------

-------------------------------------------------------------------------
----- 场景状态
-------------------------------------------------------------------------

function ArenaBattleResultDialog:Ctor()
end

function ArenaBattleResultDialog:OnInit()
    -- 加载界面
    utility.LoadNewGameObjectAsync('UI/Prefabs/BattleResult', function(go)
        self:BindComponent(go)
    end)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 胜利结果节点 --
    local BattleResultWinNodeClass = require "GUI.Arena.ArenaBattleResultWinNode"
    self.battleResultWinNode = BattleResultWinNodeClass.New(transform:Find("ArenaResultWin"))
    self:AddChild(self.battleResultWinNode)

    -- 胜利效果节点 --
    local BattleResultWinEffectNodeClass = require "GUI.Modules.ChapterBattleResult.BattleResultWinEffectNode"
    self.battleResultWinEffectNode = BattleResultWinEffectNodeClass.New(transform:Find("WinEffect"))
    self:AddChild(self.battleResultWinEffectNode)

    -- 失败效果节点 --
    local BattleResultLoseEffectNodeClass = require "GUI.Modules.ChapterBattleResult.BattleResultLoseEffectNode"
    self.battleResultLoseEffectNode = BattleResultLoseEffectNodeClass.New(transform:Find("LoseEffect"))
    self:AddChild(self.battleResultLoseEffectNode)

    -- 失败结果节点 --
    local BattleResultLoseNodeClass = require "GUI.Modules.ChapterBattleResult.BattleResultLoseNode"
    self.battleResultLoseNode = BattleResultLoseNodeClass.New(transform:Find("ResultLose"))
    self:AddChild(self.battleResultLoseNode)

    -- 数据节点 --
    local BattleResultDataNodeClass = require "GUI.Modules.ChapterBattleResult.BattleResultDataNode"
    self.battleResultDataNode = BattleResultDataNodeClass.New(transform:Find("Data"))

    print("Battle Owner", self.battleOwner)

    self.battleResultDataNode:SetData(self.battleOwner)
    self:AddChild(self.battleResultDataNode)

    --- > 按钮 < ---

    -- # 数据
    self.dataButton = transform:Find("DataButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.dataButtonObject = self.dataButton.gameObject
     self.dataButtonObject:SetActive(false)

    -- # 回放
    self.reviewButton = transform:Find("ReviewButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.reviewButtonObject = self.reviewButton.gameObject
     self.reviewButtonObject:SetActive(false)
    

    -- # 确认
    self.confirmButton = transform:Find("ConfirmButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.confirmButtonObject = self.confirmButton.gameObject

end

local function InitLogic(self)
    local isWin = self.isWin

    local resultMsg = self:GetBattleResultMsg()

    if isWin then
        -- 胜利 --
        print("@@@ 胜利 >>>>")
        self.battleResultWinEffectNode:Show(3)
        self.battleResultWinNode:Show(resultMsg)
    else
        -- 失败 --
        print("@@@ 失败 >>>>")
        self.battleResultLoseEffectNode:Show()
        self.battleResultLoseNode:Show()
    end
end

-- 指定为Module层!
function ArenaBattleResultDialog:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function ArenaBattleResultDialog:OnComponentReady()
    InitControls(self)
    InitLogic(self)
end


local function OnDataButtonClicked(self)

    local isWin = self.isWin
    if isWin then
        self.battleResultWinNode:InactiveComponent()
    else
        self.battleResultLoseNode:InactiveComponent()
    end

    self.dataButtonObject:SetActive(false)
    self.reviewButtonObject:SetActive(false)
    self.confirmButtonObject:SetActive(false)
    self.battleResultDataNode:Show()
end

local function OnReviewButtonClicked(self)
    self:Close(true)
    self:DispatchCloseEvent(true)
end

local function OnConfirmButtonClicked(self)
    self:Close(true)
    self:DispatchCloseEvent(false)
end


local function OnBattleResultDataBackButtonClicked(self)
    local isWin = self.isWin
    if isWin then
        self.battleResultWinNode:ActiveComponent()
    else
        self.battleResultLoseNode:ActiveComponent()
    end


    self.battleResultDataNode:Hide()
    self.dataButtonObject:SetActive(true)
    self.reviewButtonObject:SetActive(true)
    self.confirmButtonObject:SetActive(true)
end

function ArenaBattleResultDialog:OnResume()
    ArenaBattleResultDialog.base.OnResume(self)

    -- 注册 数据 按钮 --
    self.__event_button_dataButtonClicked__ = UnityEngine.Events.UnityAction(OnDataButtonClicked, self)
    self.dataButton.onClick:AddListener(self.__event_button_dataButtonClicked__)

    -- 注册 回放 按钮 --
    self.__event_button_reviewButtonClicked__ = UnityEngine.Events.UnityAction(OnReviewButtonClicked, self)
    self.reviewButton.onClick:AddListener(self.__event_button_reviewButtonClicked__)

    -- 注册 确认 按钮 --
    self.__event_button_confirmButtonClicked__ = UnityEngine.Events.UnityAction(OnConfirmButtonClicked, self)
    self.confirmButton.onClick:AddListener(self.__event_button_confirmButtonClicked__)


    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.BattleResultDataBackButton, OnBattleResultDataBackButtonClicked, nil)

end

function ArenaBattleResultDialog:OnPause()
    ArenaBattleResultDialog.base.OnPause(self)

    -- 取消注册 数据 按钮 --
    if self.__event_button_dataButtonClicked__ then
        self.dataButton.onClick:RemoveListener(self.__event_button_dataButtonClicked__)
        self.__event_button_dataButtonClicked__ = nil
    end

    -- 取消注册 回放 按钮 --
    if self.__event_button_reviewButtonClicked__ then
        self.reviewButton.onClick:RemoveListener(self.__event_button_reviewButtonClicked__)
        self.__event_button_reviewButtonClicked__ = nil
    end

    -- 取消注册 确认 按钮 --
    if self.__event_button_confirmButtonClicked__ then
        self.confirmButton.onClick:RemoveListener(self.__event_button_confirmButtonClicked__)
        self.__event_button_confirmButtonClicked__ = nil
    end

    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.BattleResultDataBackButton, OnBattleResultDataBackButtonClicked, nil)
end

return ArenaBattleResultDialog