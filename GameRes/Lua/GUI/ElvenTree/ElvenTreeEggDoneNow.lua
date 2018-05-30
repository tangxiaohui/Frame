local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeEggDoneNowCls = Class(BaseNodeClass)

function ElvenTreeEggDoneNowCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeEggDoneNowCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTreeEggDoneNow', function(go)
		self:BindComponent(go)
	end)
end
function ElvenTreeEggDoneNowCls:OnWillShow(itemUID,itemID)
	self.itemUID=itemUID
	self.itemID=itemID
end
function ElvenTreeEggDoneNowCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ElvenTreeEggDoneNowCls:OnResume()
	-- 界面显示时调用
	ElvenTreeEggDoneNowCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:GetGame():SendNetworkMessage(require "Network.ServerService".RobBoxSecondKillInfoRequest(self.itemUID))
end

function ElvenTreeEggDoneNowCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeEggDoneNowCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ElvenTreeEggDoneNowCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeEggDoneNowCls.base.OnEnter(self)
end

function ElvenTreeEggDoneNowCls:OnExit()
	-- Node Exit时调用
	ElvenTreeEggDoneNowCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeEggDoneNowCls:InitControls()
	local transform = self:GetUnityTransform()
	self.TranslucentLayer = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BigFarme = transform:Find('SmallWindowBase/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GrayFarme = transform:Find('SmallWindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DownerDecoration = transform:Find('SmallWindowBase/DownerDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperBorder = transform:Find('SmallWindowBase/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Title = transform:Find('SmallWindowBase/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CheckInDescriptionRetrunButton = transform:Find('SmallWindowBase/CheckInDescriptionRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.base = transform:Find('ItemBox/base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Frame = transform:Find('ItemBox/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.EquipIcon = transform:Find('ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ConferButton = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Blackline = transform:Find('Blackline'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Notice = transform:Find('Notice'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Notice__2 = transform:Find('Notice (2)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Notice__4_ = transform:Find('Notice (4)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.NeedLabel = transform:Find('NeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DyaIcon = transform:Find('DyaIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	--背景按钮
	self.BackgroundButton = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	
end
function ElvenTreeEggDoneNowCls:InitViews()
	self.Notice__2.text="剩余修复时间"..utility.ConvertTime(self.time)
	self.NeedLabel.text=self.needDiamond
	local GameTools = require "Utils.GameTools"
	local _,staticData,itemName,iconPath,itemType = GameTools.GetItemDataById(self.itemID)
	local PropUtility = require "Utils.PropUtility"
	local defaultColor = GameTools.GetItemColorByType(itemType, staticData)
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon)
	PropUtility.AutoSetRGBColor(self.Frame, self.itemColor or defaultColor)
end

function ElvenTreeEggDoneNowCls:RegisterControlEvents()
	-- 注册 CheckInDescriptionRetrunButton 的事件
	self.__event_button_onCheckInDescriptionRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInDescriptionRetrunButtonClicked, self)
	self.CheckInDescriptionRetrunButton.onClick:AddListener(self.__event_button_onCheckInDescriptionRetrunButtonClicked__)

	-- 注册 ConferButton 的事件
	self.__event_button_onConferButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked, self)
	self.ConferButton.onClick:AddListener(self.__event_button_onConferButtonClicked__)

		-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function ElvenTreeEggDoneNowCls:UnregisterControlEvents()
	-- 取消注册 CheckInDescriptionRetrunButton 的事件
	if self.__event_button_onCheckInDescriptionRetrunButtonClicked__ then
		self.CheckInDescriptionRetrunButton.onClick:RemoveListener(self.__event_button_onCheckInDescriptionRetrunButtonClicked__)
		self.__event_button_onCheckInDescriptionRetrunButtonClicked__ = nil
	end

	-- 取消注册 ConferButton 的事件
	if self.__event_button_onConferButtonClicked__ then
		self.ConferButton.onClick:RemoveListener(self.__event_button_onConferButtonClicked__)
		self.__event_button_onConferButtonClicked__ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function ElvenTreeEggDoneNowCls:RegisterNetworkEvents()
	self:GetGame():RegisterMsgHandler(net.S2CTakeBoxSecondKillInfoResult, self, self.TakeBoxSecondKillInfoResult)
	--self:GetGame():RegisterMsgHandler(net.S2CTakeBoxSecondKillResult, self, self.TakeBoxSecondKillResult)
end

function ElvenTreeEggDoneNowCls:UnregisterNetworkEvents()
	self:GetGame():UnRegisterMsgHandler(net.S2CTakeBoxSecondKillInfoResult, self, self.TakeBoxSecondKillInfoResult)
	--self:GetGame():UnRegisterMsgHandler(net.S2CTakeBoxSecondKillResult, self, self.TakeBoxSecondKillResult)

end
function ElvenTreeEggDoneNowCls:TakeBoxSecondKillResult()
	--CheckInDescriptionRetrunButton控件的点击事件处理
	for i=1,#msg.award do
		debug_print(msg.award[i].itemID,msg.award[i].itemColor,msg.award[i].itemNum)
	end
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ElvenTreeEggDoneNowCls:OnCheckInDescriptionRetrunButtonClicked()
	--CheckInDescriptionRetrunButton控件的点击事件处理
	self:Close()
end

function ElvenTreeEggDoneNowCls:OnConferButtonClicked()
	--ConferButton控件的点击事件处理
	self:GetGame():SendNetworkMessage(require "Network.ServerService".RobBoxSecondKillRequest(self.itemUID))
	self:Close()
end

function ElvenTreeEggDoneNowCls:OnReturnButtonClicked()
	self:Close()
end

function ElvenTreeEggDoneNowCls:TakeBoxSecondKillInfoResult(msg)
	debug_print("TakeBoxSecondKillInfoResult",msg.needDiamond,msg.time)
	self.needDiamond=msg.needDiamond
	self.time=msg.time
	self:InitViews()

end
	
return ElvenTreeEggDoneNowCls
