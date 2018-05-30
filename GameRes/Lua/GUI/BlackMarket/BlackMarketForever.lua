local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"

local BlackMarketForeverCls = Class(BaseNodeClass)

function BlackMarketForeverCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BlackMarketForeverCls:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/BlackMartStay",function(go)
		self:BindComponent(go)
	end)
end

function BlackMarketForeverCls:OnWillShow(dysNum)
	self.dysNum = dysNum
end

function BlackMarketForeverCls:OnComponentReady()
	--界面加载完成
	self:InitControls()
end

function BlackMarketForeverCls:OnResume()
	--界面显示时调用
	BlackMarketForeverCls.base.OnResume(self)
	self:RegisterControEvents()
	self:RegisterNetworkEvents()
	self:Show()
end

function BlackMarketForeverCls:OnPause()
	BlackMarketForeverCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function BlackMarketForeverCls:OnEnter()
	BlackMarketForeverCls.base.OnEnter(self)
end

function BlackMarketForeverCls:OnExit()
	BlackMarketForeverCls.base.OnExit(self)
end

-------------------------------------------------------------------
--- 控件相关
-------------------------------------------------------------------

-- 控件绑定
function BlackMarketForeverCls:InitControls()
	local transform = self:GetUnityTransform()
	self.ForeverButton = transform:Find("ConferButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.ForeverCancel = transform:Find("CancelButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.DyNum = transform:Find("DyaNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
end

function BlackMarketForeverCls:RegisterControEvents()
	self._event_button_onForeverButtonClciked_ = UnityEngine.Events.UnityAction(self.OnForeverButtonClicked,self)
	self.ForeverButton.onClick:AddListener(self._event_button_onForeverButtonClciked_)
	self._event_button_onForeverCancelClicked_ = UnityEngine.Events.UnityAction(self.OnForeverCancelClicked,self)
	self.ForeverCancel.onClick:AddListener(self._event_button_onForeverCancelClicked_)
end

function BlackMarketForeverCls:UnregisterControlEvents()
	if self._event_button_onForeverButtonClciked_ then
		self.ForeverButton.onClick:RemoveListener(self._event_button_onForeverButtonClciked_)
		self._event_button_onForeverButtonClciked_ = nil
	end
	if self._event_button_onForeverCancelClicked_ then
		self.ForeverCancel.onClick:RemoveListener(self._event_button_onForeverCancelClicked_)
		self._event_button_onForeverCancelClicked_ = nil
	end
end

function BlackMarketForeverCls:OnForeverButtonClicked()
	self:ShopHeishiForEverRequest()
end

function BlackMarketForeverCls:OnForeverCancelClicked()
	self:Hide()
end

-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function BlackMarketForeverCls:RegisterNetworkEvents()
	local myGame = utility.GetGame()
	myGame:RegisterMsgHandler(net.S2CShopHeishiForEverResult,self,self.OnBlackMarketForeverResult)
end

function BlackMarketForeverCls:UnregisterNetworkEvents()
	local myGame = utility.GetGame()
	myGame:UnRegisterMsgHandler(net.S2CShopHeishiForEverResult,self,self.OnBlackMarketForeverResult)
end

function BlackMarketForeverCls:ShopHeishiForEverRequest()
	--黑市永久请求
	self:GetGame():SendNetworkMessage( require "Network/ServerService".ShopHeishiForEverRequest())
end

function BlackMarketForeverCls:OnBlackMarketForeverResult()
	
end

function BlackMarketForeverCls:Show()
	self.DyNum.text = self.dysNum
end

return BlackMarketForeverCls