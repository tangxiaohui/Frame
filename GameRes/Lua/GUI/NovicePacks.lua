local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local NovicePacksCls = Class(BaseNodeClass)

function NovicePacksCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function NovicePacksCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NovicePacks', function(go)
		self:BindComponent(go)
	end)
end

function NovicePacksCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	
end

function NovicePacksCls:OnResume()
	-- 界面显示时调用
	NovicePacksCls.base.OnResume(self)
	self.game:SendNetworkMessage(require"Network/ServerService".OnlineAwardQueryRequest())
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function NovicePacksCls:OnPause()
	-- 界面隐藏时调用
	NovicePacksCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function NovicePacksCls:OnEnter()
	-- Node Enter时调用
	NovicePacksCls.base.OnEnter(self)
end

function NovicePacksCls:OnExit()
	-- Node Exit时调用
	NovicePacksCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function NovicePacksCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()

	-- self.TranslucentLayer = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BigFarme = transform:Find('SmallWindowBase/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.UpperBorder = transform:Find('SmallWindowBase/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GrayFarme = transform:Find('SmallWindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BlackTitleBase = transform:Find('SmallWindowBase/BlackTitleBase'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Title = transform:Find('SmallWindowBase/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NovicePacksCancelButton = transform:Find('ButtonLayout/NovicePacksCancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.NovicePacksReceiveButton = transform:Find('ButtonLayout/NovicePacksReceiveButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.Base1 = transform:Find('ItemListLayout/GeneralItem/Base1'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemIcon1 = transform:Find('ItemListLayout/GeneralItem/GeneralItemIcon1'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme011 = transform:Find('ItemListLayout/GeneralItem/Farme1/GeneralItemFarme011'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme021 = transform:Find('ItemListLayout/GeneralItem/Farme1/GeneralItemFarme021'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme031 = transform:Find('ItemListLayout/GeneralItem/Farme1/GeneralItemFarme031'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme041 = transform:Find('ItemListLayout/GeneralItem/Farme1/GeneralItemFarme041'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemNumLabel1 = transform:Find('ItemListLayout/GeneralItem/GeneralItemNumLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.Base2 = transform:Find('ItemListLayout/GeneralItem2/Base2'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemIcon2 = transform:Find('ItemListLayout/GeneralItem2/GeneralItemIcon2'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme012 = transform:Find('ItemListLayout/GeneralItem2/Farme2/GeneralItemFarme012'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme022 = transform:Find('ItemListLayout/GeneralItem2/Farme2/GeneralItemFarme022'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme032 = transform:Find('ItemListLayout/GeneralItem2/Farme2/GeneralItemFarme032'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme042 = transform:Find('ItemListLayout/GeneralItem2/Farme2/GeneralItemFarme042'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemNumLabel2 = transform:Find('ItemListLayout/GeneralItem2/GeneralItemNumLabel2'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.Base3 = transform:Find('ItemListLayout/GeneralItem3/Base3'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemIcon3 = transform:Find('ItemListLayout/GeneralItem3/GeneralItemIcon3'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme013 = transform:Find('ItemListLayout/GeneralItem3/Farme3/GeneralItemFarme013'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme023 = transform:Find('ItemListLayout/GeneralItem3/Farme3/GeneralItemFarme023'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme033 = transform:Find('ItemListLayout/GeneralItem3/Farme3/GeneralItemFarme033'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme043 = transform:Find('ItemListLayout/GeneralItem3/Farme3/GeneralItemFarme043'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemNumLabel3 = transform:Find('ItemListLayout/GeneralItem3/GeneralItemNumLabel3'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.Base4 = transform:Find('ItemListLayout/GeneralItem4/Base4'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemIcon4 = transform:Find('ItemListLayout/GeneralItem4/GeneralItemIcon4'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme014 = transform:Find('ItemListLayout/GeneralItem4/Farme4/GeneralItemFarme014'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme024 = transform:Find('ItemListLayout/GeneralItem4/Farme4/GeneralItemFarme024'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme034 = transform:Find('ItemListLayout/GeneralItem4/Farme4/GeneralItemFarme034'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme044 = transform:Find('ItemListLayout/GeneralItem4/Farme4/GeneralItemFarme044'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemNumLabel4 = transform:Find('ItemListLayout/GeneralItem4/GeneralItemNumLabel4'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.Base = transform:Find('Title1/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Line = transform:Find('Title1/Line'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.TitleTextLabel = transform:Find('Title1/TitleTextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Text = transform:Find('Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemListLayout = transform:Find('ItemListLayout')


	local OnlineTime = require"StaticData/Activity/OnlineTimeAward":GetData(1)
	print(OnlineTime:GetIndex(),"**",OnlineTime:GetItemID(),"**",OnlineTime:GetItemNum(),"**",OnlineTime:GetBaseMinute())

end


function NovicePacksCls:RegisterControlEvents()
	-- 注册 NovicePacksCancelButton 的事件
	self.__event_button_onNovicePacksCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnNovicePacksCancelButtonClicked, self)
	self.NovicePacksCancelButton.onClick:AddListener(self.__event_button_onNovicePacksCancelButtonClicked__)

	-- 注册 NovicePacksReceiveButton 的事件
	self.__event_button_onNovicePacksReceiveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnNovicePacksReceiveButtonClicked, self)
	self.NovicePacksReceiveButton.onClick:AddListener(self.__event_button_onNovicePacksReceiveButtonClicked__)

end

function NovicePacksCls:UnregisterControlEvents()
	-- 取消注册 NovicePacksCancelButton 的事件
	if self.__event_button_onNovicePacksCancelButtonClicked__ then
		self.NovicePacksCancelButton.onClick:RemoveListener(self.__event_button_onNovicePacksCancelButtonClicked__)
		self.__event_button_onNovicePacksCancelButtonClicked__ = nil
	end

	-- 取消注册 NovicePacksReceiveButton 的事件
	if self.__event_button_onNovicePacksReceiveButtonClicked__ then
		self.NovicePacksReceiveButton.onClick:RemoveListener(self.__event_button_onNovicePacksReceiveButtonClicked__)
		self.__event_button_onNovicePacksReceiveButtonClicked__ = nil
	end

end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function NovicePacksCls:RegisterNetworkEvents()
	--RegisterNetworkEvents控件的网络事件处理
	 self.game:RegisterMsgHandler(net.S2COnlineAwardQueryResult, self, self.OnlineAwardQueryResult)
	 self.game:RegisterMsgHandler(net.C2SOnlineAwardDrawRequest, self, self.OnlineAwardDrawResult)
end

function NovicePacksCls:UnregisterNetworkEvents()
	--UnregisterNetworkEvents 控件的网络事件处理
	 self.game:UnRegisterMsgHandler(net.S2COnlineAwardQueryResult, self, self.OnlineAwardQueryResult)
	 self.game:RegisterMsgHandler(net.C2SOnlineAwardDrawRequest, self, self.OnlineAwardDrawResult)
end
-----------------------------------------------------------------------
--- 网络事件处理
-----------------------------------------------------------------------
function NovicePacksCls:OnlineAwardQueryResult(msg)
	--C2SOnlineAwardQueryRequest
	print(msg.totalTime)
		for i=1,#msg.list do
			if msg.list[i].state==1 then

				self.onlineAwardItem=require"GUI.CheckInItem".New(self.ItemListLayout,msg.list[i])	
				--self.onlineAwardItem[i]:SetCallback(self,CheckInCallBack)
				self:AddChild(self.onlineAwardItem[i])
			elseif msg.list[i].state=2 then
				print("())))))))))))))")
				self.onlineAwardItem=require"GUI.CheckInItem".New(self.ItemListLayout,msg.list[i])	
				--self.onlineAwardItem[i]:SetCallback(self,CheckInCallBack)
				self:AddChild(self.onlineAwardItem[i])
			end

		print("index",msg.list[i].index,"   ","**********state",msg.list[i].state,type(msg.list[i].state))
		end


end

function NovicePacksCls:OnlineAwardDrawResult(msg)
	--C2SOnlineAwardQueryRequest
	print("OnlineAwardDrawResult")
		


end


-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function NovicePacksCls:OnNovicePacksCancelButtonClicked()
	--NovicePacksCancelButton控件的点击事件处理
	self:UnregisterControlEvents()
	self:Hide()
end
--领取按钮
function NovicePacksCls:OnNovicePacksReceiveButtonClicked()
	--NovicePacksReceiveButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network/ServerService".OnlineAwardDrawRequest(1))

end
return NovicePacksCls

