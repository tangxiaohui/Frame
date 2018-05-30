
local BaseNodeClass = require "GUI.BattleResults.BaseBattleResultModule"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"

local BattleResultDialog = Class(BaseNodeClass)

windowUtility.SetMutex(BattleResultDialog, true)

-------------------------------------------------------------------------
----- ###### !!!!!副本战斗使用的!!!!! ######
-------------------------------------------------------------------------

-------------------------------------------------------------------------
----- 场景状态
-------------------------------------------------------------------------

function BattleResultDialog:Ctor()
end

function BattleResultDialog:OnInit()
    -- 加载界面
    utility.LoadNewGameObjectAsync('UI/Prefabs/BattleResult', function(go)
        self:BindComponent(go)
    end)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 胜利结果节点 --
    local BattleResultWinNodeClass = require "GUI.Modules.ChapterBattleResult.BattleResultWinNode"
    self.battleResultWinNode = BattleResultWinNodeClass.New(transform:Find("ResultWin"))
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

    -- print("Battle Owner", self.battleOwner)

    self.battleResultDataNode:SetData(self.battleOwner)
    self:AddChild(self.battleResultDataNode)

    --- > 按钮 < ---

    -- # 数据
    self.dataButton = transform:Find("DataButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.dataButtonObject = self.dataButton.gameObject

    -- # 回放
    self.reviewButton = transform:Find("ReviewButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.reviewButtonObject = self.reviewButton.gameObject

    -- # 确认
    self.confirmButton = transform:Find("ConfirmButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.confirmButtonObject = self.confirmButton.gameObject
end

local function SetControls(self)
    local isWin = self.isWin

    debug_print("是否胜利>1?????", self.isWin)

    self.battleResultDataNode:Close()

    if isWin then
        -- 胜利 --
        local fbMsg = self:GetBattleResultMsg()
        require "Utils.GameAnalysisUtils".LevelDone(fbMsg.fbItem.fbID)

        self.battleResultLoseEffectNode:Close()
        self.battleResultLoseNode:Close()

        self.battleResultWinEffectNode:Show(fbMsg.fbItem.star)
        self.battleResultWinNode:Show(fbMsg)

        self.dataButtonObject:SetActive(true)
    else
        -- 失败 --
        -- FIXME: 以后必须把战斗结果框重构下!
        local msg = self.battleOwner:GetBattleParams():GetBattleStartProtocol()
        if type(msg.fbID) == "number" and msg.fbID > 0 then
            require "Utils.GameAnalysisUtils".LevelFail(msg.fbID)
        end

        self.battleResultWinEffectNode:Close()
        self.battleResultWinNode:Close()

        self.battleResultLoseEffectNode:Show()
        self.battleResultLoseNode:Show()

        -- 失败时 数据和回放屏蔽掉
        self.dataButtonObject:SetActive(false)
        self.reviewButtonObject:SetActive(false)
        
        -- 失败时 居中显示
        local pos = self.confirmButtonObject.transform.localPosition
        pos.x = 0
        self.confirmButtonObject.transform.localPosition = pos
    end
    
end

-- 指定为Module层!
function BattleResultDialog:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function BattleResultDialog:OnComponentReady()
    InitControls(self)
end


local function OnDataButtonClicked(self)
    local isWin = self.isWin
    debug_print("是否胜利>2?????", self.isWin)
    if isWin then
        self.battleResultWinNode:Close()
    else
        self.battleResultLoseNode:Close()
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
    debug_print("是否胜利>3?????", self.isWin)
    if isWin then
        self.battleResultWinNode:ActiveComponent()
        -- 成功才有数据和回放功能
        self.dataButtonObject:SetActive(true)
        -- self.reviewButtonObject:SetActive(true)
    else
        self.dataButtonObject:SetActive(false)
        self.battleResultLoseNode:ActiveComponent()
    end

    self.battleResultDataNode:Close()
    self.confirmButtonObject:SetActive(true)
end

function BattleResultDialog:OnResume()
    BattleResultDialog.base.OnResume(self)

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
    
    SetControls(self)
end

function BattleResultDialog:OnPause()
    BattleResultDialog.base.OnPause(self)

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

return BattleResultDialog
