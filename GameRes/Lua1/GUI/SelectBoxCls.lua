local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
local gametool = require "Utils.GameTools"
require "LUT.StringTable"

local SelectBoxCls = Class(BaseNodeClass)
windowUtility.SetMutex(SelectBoxCls, true)


function  SelectBoxCls:Ctor()
end

function SelectBoxCls:OnWillShow(id)
	self.id = id
end

function  SelectBoxCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/SelectBox",function(go)
		self:BindComponent(go)
	end)
end

function SelectBoxCls:OnComponentReady()
	self:InitControls()
end

function SelectBoxCls:OnResume()
	SelectBoxCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:ShowPanel()
end

function SelectBoxCls:OnPause()
	SelectBoxCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function SelectBoxCls:OnEnter()
	SelectBoxCls.base.OnEnter(self)
end

function SelectBoxCls:OnExit()
	SelectBoxCls.base.OnExit(self)
end

function SelectBoxCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  SelectBoxCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find("TweenObject")
	self.returnButton = self.base:Find("RetrunButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.point = self.base:Find("Scroll View/Viewport/Content")
	self.conferButton = self.base:Find("ConferButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.infoButton = self.base:Find("InfoButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.myGame = utility:GetGame()
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function SelectBoxCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function SelectBoxCls:OnExitTransitionDidStart(immediately)
    SelectBoxCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function  SelectBoxCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)

	self._event_button_onConferButtonClicked_ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked,self)
	self.conferButton.onClick:AddListener(self._event_button_onConferButtonClicked_)

	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)

end

function  SelectBoxCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end

	if self._event_button_onConferButtonClicked_ then
		self.conferButton.onClick:RemoveListener(self._event_button_onConferButtonClicked_)
		self._event_button_onConferButtonClicked_ = nil
	end

	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end

end

function SelectBoxCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2COpenTreasureChestRewardResult,self,self.OpenTreasureChestRewardResult)
end

function SelectBoxCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2COpenTreasureChestRewardResult,self,self.OpenTreasureChestRewardResult)
end

function  SelectBoxCls:OpenTreasureChestRewardResult(msg)
	if msg.status then
		self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,KKnapsackItemType_Item)
		self:GetItems()
		self:OnReturnButtonClicked()
	end
end

function SelectBoxCls:OpenTreasureChestRewardRequest(id)
	self.myGame:SendNetworkMessage( require "Network.ServerService".OpenTreasureChestRewardRequest(id,self.id,1))
end

function SelectBoxCls:OnReturnButtonClicked()
	self:Close(true)
end

function SelectBoxCls:OnConferButtonClicked()
	if self.boxId ~= nil then
		self:OpenTreasureChestRewardRequest(self.boxId)
	else
		local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        windowManager:Show(ErrorDialogClass, "请选择后确认！")
	end
end

function SelectBoxCls:OnInfoButtonClicked()
	if self.boxId ~= nil then
		local data = require "StaticData.ItemBox":GetData(self.boxId)
		local itemId = data:GetItemID()
		local windowManager = utility:GetGame():GetWindowManager()
		local gameTool = require "Utils.GameTools"
		gameTool.ShowItemWin(itemId)
		-- windowManager:Show(require "GUI.Collection.CollectionCardInfo",itemId)
	else
		local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        windowManager:Show(ErrorDialogClass, "请先选择后查看详情！")
	end
end

function SelectBoxCls:ShowPanel()
	self.node = {}
	local keys = require "StaticData.ItemBox":GetKeys()
	for i=0,keys.Length - 1 do
		local data = require "StaticData.ItemBox":GetData(keys[i])
		if data:GetBoxid() == self.id then
			local item = require "GUI.SelectBoxItem".New(self.point,keys[i])
			item:SetCallback(self,self.ButtonClicked)
			self:AddChild(item)
			self.node[#self.node + 1] = item
		end
	end
end

function SelectBoxCls:ButtonClicked(id)
	self.boxId = id
	for i=1,#self.node do
		self.node[i]:SetButtonState(id)
	end
end

function SelectBoxCls:GetItems(item)
	local itemstables = {}
	local data = require "StaticData.ItemBox":GetData(self.boxId)
	local itemId = data:GetItemID()
	local itemNum = data:GetItemNum()

	local modV = math.floor(itemId/100000)
	if modV==100 then

		local UserDataType = require "Framework.UserDataType"
		local cardBagData = self:GetCachedData(UserDataType.CardBagData)
		local card= cardBagData:GetRoleById(itemId)

		local addCardDict = OrderedDictionary.New()
		if card ==nil then
			addCardDict:Add(itemId,itemId)
		end
		local windowManager = utility.GetGame():GetWindowManager()
   		windowManager:Show(require "GUI.GeneralCard.GetCardWin",itemId,addCardDict)

   	elseif modV==101 then
		local gameTool = require "Utils.GameTools"
		gameTool.GetItemWin(itemId)

   	else
		itemstables[1] = {}
		itemstables[1].id = itemId
		itemstables[1].count = itemNum
		local _,data,_,_,itype = gametool.GetItemDataById(itemId)
		local color = gametool.GetItemColorByType(itype,data)
		itemstables[1].color = color
		local windowManager = self:GetGame():GetWindowManager()
	    local AwardCls = require "GUI.Task.GetAwardItem"
	    windowManager:Show(AwardCls,itemstables)
   	end
end


return SelectBoxCls