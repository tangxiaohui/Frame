local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Collection.OrderedDictionary"
local messageGuids = require "Framework.Business.MessageGuids"

-----------------------------------------------------------------------
local ShowCardSkinsWinCls = Class(BaseNodeClass)
windowUtility.SetMutex(ShowCardSkinsWinCls, true)

function ShowCardSkinsWinCls:Ctor()
end
function ShowCardSkinsWinCls:OnWillShow(id)
	self.cardId = id
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ShowCardSkinsWinCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SkinSelect', function(go)
		self:BindComponent(go)
	end)
end

function ShowCardSkinsWinCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitVariable()
	self:InitControls()
end

function ShowCardSkinsWinCls:OnResume()
	-- 界面显示时调用
	ShowCardSkinsWinCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RegisterEventMonitor()

	self:ResetNode(self.cardId)

	self:FadeIn(function(self, t,finished)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
        if finished then
        	self.ScrollView.enabled = true
        end
    end)
end

function ShowCardSkinsWinCls:OnPause()
	-- 界面隐藏时调用
	ShowCardSkinsWinCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEventMonitor()
end

function ShowCardSkinsWinCls:OnEnter()
	-- Node Enter时调用
	ShowCardSkinsWinCls.base.OnEnter(self)
end

function ShowCardSkinsWinCls:OnExit()
	-- Node Exit时调用
	ShowCardSkinsWinCls.base.OnExit(self)
end


function ShowCardSkinsWinCls:IsTransition()
    return true
end

function ShowCardSkinsWinCls:OnExitTransitionDidStart(immediately)
	ShowCardSkinsWinCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ShowCardSkinsWinCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ShowCardSkinsWinCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('TweenObject')
	-- 返回按钮
 	self.RetrunButton = transform:Find('TweenObject/RetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
 	self.InfoButton = transform:Find('TweenObject/InfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
 	self.ConferButton = transform:Find('TweenObject/ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))
 	self.ConferButtonLabel = self.ConferButton.transform:Find('Text'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.ConferButtonImage = self.ConferButton.transform:GetComponent(typeof(UnityEngine.UI.Image))

 	self.ScrollView = transform:Find('TweenObject/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
 	self.ScrollView.enabled = false

 	self.nodePoint = transform:Find('TweenObject/Scroll View/Viewport/Content')
end

function ShowCardSkinsWinCls:InitVariable()
	self.myGame = utility:GetGame()
	-- 子类管理
	self.NodeDict = OrderedDictionary.New()
end


function ShowCardSkinsWinCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

	-- 注册 InfoButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.InfoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)

	-- 注册 ConferButton 的事件
	self.__event_button_onConferButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked, self)
	self.ConferButton.onClick:AddListener(self.__event_button_onConferButtonClicked__)
end

function ShowCardSkinsWinCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

	-- 取消注册 InfoButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.InfoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end

	-- 取消注册 ConferButton 的事件
	if self.__event_button_onConferButtonClicked__ then
		self.ConferButton.onClick:RemoveListener(self.__event_button_onConferButtonClicked__)
		self.__event_button_onConferButtonClicked__ = nil
	end
end

function ShowCardSkinsWinCls:RegisterNetworkEvents()
	--self.myGame:RegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
end

function ShowCardSkinsWinCls:UnregisterNetworkEvents()
	--self.myGame:UnRegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
end

function ShowCardSkinsWinCls:RegisterEventMonitor()
	self:RegisterEvent(messageGuids.CardSkinUpdate,self.OnCardSkinUpdate)
end

function ShowCardSkinsWinCls:UnregisterEventMonitor()
	self:UnregisterEvent(messageGuids.CardSkinUpdateCardSkinUpdate,self.OnCardSkinUpdate)
end

-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function ShowCardSkinsWinCls:CardSkinPutOnRequest(cardUID,cardSkinUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".CardSkinPutOnRequest(cardUID,cardSkinUID))
end

function ShowCardSkinsWinCls:CardSkinPutOffRequest(cardUID,cardSkinUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".CardSkinPutOffRequest(cardUID,cardSkinUID))
end
----------------------------------------------------------------------
function ShowFirstNode(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self:SetConferButtonTheme(self.currSelectNode)
end
function ShowCardSkinsWinCls:ResetNode(id)
	self.NodeDict:Clear()
	local CardskinStaticData = require"StaticData.CardSkin.Cardskin":GetData(id)
	local skinIdArray = CardskinStaticData:GetSkinid()

	local nodeCls = require "GUI.SkinSystem.CardSkinHeadItem"
	for i = 0 ,skinIdArray.Count-1 do
		local skinId = skinIdArray[i]
		local node = nodeCls.New(self.nodePoint,id,skinId,true)
		node:SetCallback(self,self.ItemCallBack)
		self:AddChild(node)
		self.NodeDict:Add(skinId,node)
	end

	self.currSelectNode = self.NodeDict:GetEntryByIndex(1)
	if self.currSelectNode ~= nil then
		self:StartCoroutine(ShowFirstNode)
	end
end

function ShowCardSkinsWinCls:OnCardSkinUpdate(cardSkinData,skinData)
	for i = 1,self.NodeDict:Count() do
		self.NodeDict:GetEntryByIndex(i):UpdateEquipState()
	end

	local skinId = skinData:GetCardSkinId()
	local node = self.NodeDict:GetEntryByKey(skinId)
	node:ResetView(self.cardId,skinId)
	self:SetConferButtonTheme(node)
end

function ShowCardSkinsWinCls:SetConferButtonTheme(node)
	local haded = node:GetHaded()
	if not haded then
		local grayMaterial = utility.GetGrayMaterial(true)
		local imageMaterial = utility.GetGrayMaterial()
		self.ConferButtonLabel.text = "穿上"
		self.ConferButtonLabel.material = grayMaterial
		self.ConferButtonImage.material = imageMaterial
	else
		self.currSkinEquipState = node:GetEquipState()
		self.ConferButtonLabel.material = nil
		self.ConferButtonImage.material = nil
		if self.currSkinEquipState then
			self.ConferButtonLabel.text = "卸下"
		else
			self.ConferButtonLabel.text = "穿上"
		end
	end
	self.hadCurrNode = haded
end

function ShowCardSkinsWinCls:ItemCallBack(node)
	if self.currSelectNode == node then
		return
	end
	self.currSelectNode = node
	self:SetConferButtonTheme(self.currSelectNode)
end
-----------------------------------------------------------------------
function ShowCardSkinsWinCls:OnRetrunButtonClicked()
	self:Close()
end

function ShowCardSkinsWinCls:OnInfoButtonClicked()
	local skinId = self.currSelectNode:GetSkinId()
	local haded = self.currSelectNode:GetHaded()

    local SkinSystemCls = require "GUI.SkinSystem.DisplayOneCardSkin"
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(SkinSystemCls,skinId,haded)
end

local function GetCardUid(self,cardId)
	local UserDataType = require "Framework.UserDataType"
	local cacheData = self:GetCachedData(UserDataType.CardBagData)
	local roleData = cacheData:GetRoleById(cardId)
	return roleData:GetUid()
end

function ShowCardSkinsWinCls:OnConferButtonClicked()
	if not self.hadCurrNode then
		return
	end

	local skinUid = self.currSelectNode:GetSkinUid()
	local cardId = self.currSelectNode:GetCardId()
	local cardUID = GetCardUid(self,cardId)
	if self.currSkinEquipState then
		self:CardSkinPutOffRequest(cardUID,skinUid)
	else
		self:CardSkinPutOnRequest(cardUID,skinUid)
	end
end

return ShowCardSkinsWinCls