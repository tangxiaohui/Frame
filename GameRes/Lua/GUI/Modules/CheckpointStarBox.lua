local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local windowUtility = require "Framework.Window.WindowUtility"
local CheckpointStarBox = Class(BaseNodeClass)
require "Const"

-- # 设置为唯一
windowUtility.SetMutex(CheckpointStarBox, true)


function CheckpointStarBox:Ctor()
	self.spawnedItems = {}
end

-- 指定为Module层!
function CheckpointStarBox:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CheckpointStarBox:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync("UI/Prefabs/CheckpointStarBox", function(go)
        self:BindComponent(go)
    end)
end

function CheckpointStarBox:OnWillShow(chapterID, stage)
    self.chapterID = chapterID
    self.awardStage = stage

    -- 取得完成度
    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    local score = playerChapterData:GetChapterTotalScore(chapterID)
    self.chapterScore = score
    self.status = playerChapterData:GetChapterCompleteStatus(chapterID, stage)

    -- 获得当前阶的数据
    local stageDataID = chapterID * 10 + stage
    self.stageData = require "StaticData.ChapterStar":GetData(stageDataID)
end

function CheckpointStarBox:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    self:InitControls()
end

local function IsReach(self)
    return self.chapterScore >= self.stageData:GetComplete() and self.status == kChapterBoxStatus_NotReceiveYet
end

local function GetNewGeneralItem()
	-- TODO 从内存池获取
	local GeneralItemClass = require "GUI.Item.GeneralItem"
	return GeneralItemClass.New()
end

local function AddNewItem(self, parent, id, number)
	if number > 0 then
		local item = GetNewGeneralItem()
		item:Set(parent, id, number)
		self:AddChild(item)
		return item
	end
end

local function AddToSpawnedItems(self, item)
	self.spawnedItems[#self.spawnedItems + 1] = item
end

local function DespawnItems(self)
	for i = #self.spawnedItems, 1, -1 do
		-- TODO 归还到池 --
		self:RemoveChild(self.spawnedItems[i])
		self.spawnedItems[i] = nil
	end
end

local function SetControls(self)

	-- 金币
	AddToSpawnedItems(self, AddNewItem(self, self.itemParentTrans, kCurrencyId_Coin, self.stageData:GetCoin()))
	
	-- 钻石
	AddToSpawnedItems(self, AddNewItem(self, self.itemParentTrans, kCurrencyId_Diamond, self.stageData:GetDiamond()))
	
	-- 物品
	AddToSpawnedItems(self, AddNewItem(self, self.itemParentTrans, self.stageData:GetItemID(), self.stageData:GetItemNum()))


    if IsReach(self) then
        self.ButtonImage.material= utility.GetCommonMaterial()
        self.ButtonText.text = "领取"
    else
        self.ButtonImage.material= utility.GetGrayMaterial()
        self.ButtonText.text = "确定"
    end

end

local function ResetControls(self)
    DespawnItems(self)
end

function CheckpointStarBox:OnResume()
    -- 界面显示时调用
    CheckpointStarBox.base.OnResume(self)
    self:RegisterControlEvents()
    self:RegisterNetworkEvents()
    SetControls(self)
end

function CheckpointStarBox:OnPause()
    -- 界面隐藏时调用
    CheckpointStarBox.base.OnPause(self)
    self:UnregisterControlEvents()
    self:UnregisterNetworkEvents()
    ResetControls(self)
end

function CheckpointStarBox:OnEnter()
    -- Node Enter时调用
    CheckpointStarBox.base.OnEnter(self)
end

function CheckpointStarBox:OnExit()
    -- Node Exit时调用
    CheckpointStarBox.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CheckpointStarBox:InitControls()
    local transform = self:GetUnityTransform()

    self.tweenObjectTrans = transform:Find("TweenObject")

	-- # 按钮 # --
    self.CheckpointStarBoxConfirmButton = transform:Find('TweenObject/CheckpointStarBoxConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.ButtonText = transform:Find("TweenObject/CheckpointStarBoxConfirmButton/Text"):GetComponent(typeof(UnityEngine.UI.Text))
    self.ButtonImage = transform:Find("TweenObject/CheckpointStarBoxConfirmButton"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # 爆炸特效 # --
    self.bombEffectObject = transform:Find("TweenObject/BombEffect/UI_baoxiang_baozha").gameObject

	self.itemParentTrans = transform:Find("TweenObject/Layout/ItemParent")

    --背景按钮
    self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
    -- # 初始化物品图标 # --
    --local GeneralItemClass = require "GUI.Item.GeneralItem"
	--self.itemControl = GeneralItemClass.New()
end


function CheckpointStarBox:RegisterControlEvents()
    -- 注册 CheckpointStarBoxConfirmButton 的事件
    self.__event_button_onCheckpointStarBoxConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckpointStarBoxConfirmButtonClicked, self)
    self.CheckpointStarBoxConfirmButton.onClick:AddListener(self.__event_button_onCheckpointStarBoxConfirmButtonClicked__)

        -- 注册 BackgroundButton 的事件
    self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
    self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function CheckpointStarBox:UnregisterControlEvents()
    -- 取消注册 CheckpointStarBoxConfirmButton 的事件
    if self.__event_button_onCheckpointStarBoxConfirmButtonClicked__ then
        self.CheckpointStarBoxConfirmButton.onClick:RemoveListener(self.__event_button_onCheckpointStarBoxConfirmButtonClicked__)
        self.__event_button_onCheckpointStarBoxConfirmButtonClicked__ = nil
    end

    -- 取消注册 BackgroundButton 的事件
    if self.__event_backgroundButton_onButtonClicked__ then
       self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
       self.__event_backgroundButton_onButtonClicked__ = nil
    end

end

function CheckpointStarBox:RegisterNetworkEvents()
    local net = require "Network.Net"
    self:GetGame():RegisterMsgHandler(net.S2CFBDrawCompleteAwardResult, self, self.OnDrawCompleteAwardResult)
end

function CheckpointStarBox:UnregisterNetworkEvents()
    local net = require "Network.Net"
    self:GetGame():UnRegisterMsgHandler(net.S2CFBDrawCompleteAwardResult, self, self.OnDrawCompleteAwardResult)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CheckpointStarBox:OnCheckpointStarBoxConfirmButtonClicked()
    --CheckpointStarBoxConfirmButton控件的点击事件处理
    if not IsReach(self) then
        self:Close(true)
        return
    end

    local ServerService = require "Network.ServerService"
    local msg, prototype = ServerService.DrawCompleteAward(self.chapterID, self.awardStage)
    self:GetGame():SendNetworkMessage(msg, prototype)
end

local function WaitingForFinished(self)
    coroutine.wait(1)
    self:Close(true)
end

local function ShowEffect(self)
    local itemID = self.stageData:GetItemID()

    local gameTool = require "Utils.GameTools"
    if gameTool.ShowGotEquipOrCardWindow(itemID) then
        -- debug_print("@@@@@@@@@@@ >>>")
        self:Close(true)
        return
    end
    -- debug_print("boom@@!!!")
    self.bombEffectObject:SetActive(true)
	self:StartCoroutine(WaitingForFinished)
end

function CheckpointStarBox:OnDrawCompleteAwardResult(msg)
    if msg.mapID == self.chapterID then
        self.CheckpointStarBoxConfirmButton.interactable = false
        ShowEffect(self)
    end
end
function CheckpointStarBox:OnReturnButtonClicked()
    self:Close()
end
return CheckpointStarBox
