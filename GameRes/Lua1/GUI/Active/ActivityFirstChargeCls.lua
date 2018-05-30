local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
require "LUT.StringTable"

local ActivityFirstCharge = Class(BaseNodeClass)
windowUtility.SetMutex(ActivityFirstCharge, true)


function  ActivityFirstCharge:Ctor()
end

function ActivityFirstCharge:OnWillShow(state)
	self.state = state
end

function  ActivityFirstCharge:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/Shouchong",function(go)
		self:BindComponent(go)
	end)
end

function ActivityFirstCharge:OnComponentReady()
	self:InitControls()
end

function ActivityFirstCharge:OnResume()
	ActivityFirstCharge.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RedDotStateQuery()
	self:ShowPanel()
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function ActivityFirstCharge:OnPause()
	ActivityFirstCharge.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function ActivityFirstCharge:OnEnter()
	ActivityFirstCharge.base.OnEnter(self)
end

function ActivityFirstCharge:OnExit()
	ActivityFirstCharge.base.OnExit(self)
end

function ActivityFirstCharge:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  ActivityFirstCharge:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find("Base")
	self.returnButton = self.base:Find("Closebtn"):GetComponent(typeof(UnityEngine.UI.Button))
	self.descLabel1 = self.base:Find("Title/Blackbg/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.descLabel2 = self.base:Find("Title/Name"):GetComponent(typeof(UnityEngine.UI.Text))
	self.descLabel3 = self.base:Find("Title/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.descLabel4 = self.base:Find("Title/Miaoshu"):GetComponent(typeof(UnityEngine.UI.Text))
	self.point = self.base:Find("Award")

	self.chargeButton = self.base:Find("Chongzhibtn"):GetComponent(typeof(UnityEngine.UI.Button))
	self.chargeLabel = self.base:Find("Chongzhibtn/ChongzhiTitle").gameObject
	self.getLabel = self.base:Find("Chongzhibtn/Lingqu").gameObject

	--背景按钮
	self.BackgroundButton = transform:Find('Image'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()
	self.buttonId = nil
end

----------------------------------------------------------------------------
--¶¯»­´¦Àí--
----------------------------------------------------------------------------

-- ## ÔÚÕâÀïÖ´ÐÐ µ­³öº¯Êý! (immediately ÖµÖ»Õë¶Ô WindowNode ¼°Æä×ÓÀà)
function ActivityFirstCharge:OnExitTransitionDidStart(immediately)
    ActivityFirstCharge.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function  ActivityFirstCharge:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)

	self._event_button_onChargeButtonClicked_ = UnityEngine.Events.UnityAction(self.OnChargeButtonClicked,self)
	self.chargeButton.onClick:AddListener(self._event_button_onChargeButtonClicked_)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function  ActivityFirstCharge:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end

	if self._event_button_onChargeButtonClicked_ then
		self.chargeButton.onClick:RemoveListener(self._event_button_onChargeButtonClicked_)
		self._event_button_onChargeButtonClicked_ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function ActivityFirstCharge:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
end

function ActivityFirstCharge:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
end

function ActivityFirstCharge:OnActivityGetAwardResult(msg)
	if msg.status then
		local windowManager = self:GetGame():GetWindowManager()
    	local AwardCls = require "GUI.Task.GetAwardItem"
    	windowManager:Show(AwardCls,self.itemstables)
    	self:OnReturnButtonClicked()
	end
end

function ActivityFirstCharge:OnActivityGetAwardRequest()
	self.myGame:SendNetworkMessage(require "Network/ServerService".ActivityFirstChargeRequest())
end

function  ActivityFirstCharge:OnReturnButtonClicked()
	self:Close(true)
end


function ActivityFirstCharge:OnChargeButtonClicked()
	if self.state then
		self:OnActivityGetAwardRequest()
	else
		local windowManager = self:GetGame():GetWindowManager()
    	windowManager:Show(require "GUI.Deposit.Deposit")
    	self:OnReturnButtonClicked()
	end

end

function ActivityFirstCharge:ShowPanel()
	local data = require "StaticData.Activity.ActivityFirstCharge":GetData(1)
	local descData = require "StaticData.Activity.Activefever"
	local gametool = require "Utils.GameTools"
	self.descLabel1.text = descData:GetData(data:GetFirstChargeInfo1()):GetDescription()
	self.descLabel2.text = descData:GetData(data:GetFirstChargeInfo2()):GetDescription()
	self.descLabel3.text = descData:GetData(data:GetFirstChargeInfo3()):GetDescription()
	self.descLabel4.text = descData:GetData(data:GetFirstChargeInfo4()):GetDescription()
	local itemId = data:GetItemID()
	local itemNum = data:GetItemNum()
	local itemColor = data:GetItemColor()
	self.node = {}
	local items = {}
	local nums = {}
	local colors = {}
	for i=0,itemId.Count - 1 do
		items[#items + 1] = itemId[i]
		nums[#nums + 1] = itemNum[i]
		colors[#colors + 1] = itemColor[i]
	end
	self.itemstables = {}
	for i=1,#items do
		self.itemstables[i] = {}
		self.itemstables[i].id = items[i]
		self.itemstables[i].count = nums[i]
		local _,data,_,_,itype = gametool.GetItemDataById(items[i])
		local color = gametool.GetItemColorByType(itype,data)
		self.itemstables[i].color = color
	end
	self:ShowItem(items,nums,colors)
	self:SetAwardButton(self.state)
end

function ActivityFirstCharge:SetAwardButton(state)
	self:HideState()
	if state then
		self.getLabel:SetActive(true)
	else
		self.chargeLabel:SetActive(true)
	end
end

function ActivityFirstCharge:HideState()
	self.chargeLabel:SetActive(false)
	self.getLabel:SetActive(false)
end

function ActivityFirstCharge:ShowItem(items,nums,colors)
	for i=1,#items do
		local awardItem = require "GUI.Active.ActiveAwardItem".New(self.point,items[i],nums[i],colors[i],isAlreceive)
		self:AddChild(awardItem)
		self.node[i] = awardItem
	end
end

--ºìµã
function ActivityFirstCharge:RedDotStateQuery()
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
    
end

function ActivityFirstCharge:RedDotStateUpdated(moduleId,moduleState)
	self:RedDotStateQuery()
end

return ActivityFirstCharge