local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"

local BlackMarketCls = Class(BaseNodeClass)
local game = require "Game.Cos3DGame"

function BlackMarketCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BlackMarketCls:OnInit()
	-- 加载界面 
	utility.LoadNewGameObjectAsync('UI/Prefabs/BlackMartNotice', function(go)
		self:BindComponent(go)
	end)
end

function BlackMarketCls:OnWillShow()
end

function BlackMarketCls:OnComponentReady()
	-- 界面加载完成
	self:InitControls()
end

function BlackMarketCls:OnResume()
	-- 界面显示时调用
	BlackMarketCls.base.OnResume(self)
	self:ShopHeishiQueryRequest()
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitView()
	-- self:FadeIn(function(self, t)
        -- local transform = self.tweenObjectTrans
        -- local TweenUtility = require "Utils.TweenUtility"
        -- local s = TweenUtility.EaseOutBack(0, 1, t)

		-- transform.localScale = Vector3(s, s, s)
    -- end)
end

function BlackMarketCls:OnPause()
	-- 界面隐藏时调用
	BlackMarketCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function BlackMarketCls:OnEnter()
	-- Node Enter时调用
	BlackMarketCls.base.OnEnter(self)
end

function BlackMarketCls:OnExit()
	-- Node Exit时调用
	BlackMarketCls.base.OnExit(self)
end

function BlackMarketCls:Update()
	self:TimeCountdown()
end
-- function BlackMarketCls:IsTransition()
	-- return true
-- end

-- function BlackMarketCls:OnExitTransitionDidStart(immedidtely)
	-- BlackMarketCls.base.OnExitTransitionDidStart(self,immedidtely)
	-- if not immedidtely then
		-- self:FadeIn(function(self,t)
			-- local transform = self.tweenObjectTrans
			-- local TweenUtility = require "Utils.TweenUtility"
			-- local s = TweenUtility.EaseInBacl(1, 0, t)
			-- transform.localScale = Vector3(s, s, s)
		-- end)
	-- end
-- end

-- function BlackMarketCls:GetRootHangingPoint()
	-- return self:GetUIManager():GetModuleLayer()
-- end

-------------------------------------------------------------------
--- 控件相关
-------------------------------------------------------------------

-- 控件绑定
function BlackMarketCls:InitControls()
	local transform = self:GetUnityTransform()
	self:ScheduleUpdate(self.Update)
	self.BlackMarketButton = transform:Find("ConferButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.BlackMarketCancel = transform:Find("CancelButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.BlackMarketTime = transform:Find("LasttimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
end

function BlackMarketCls:RegisterControlEvents()
	self.__event_button_onBlackMarketButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBlackMarketButtonClicked, self)
	self.BlackMarketButton.onClick:AddListener(self.__event_button_onBlackMarketButtonClicked__)
	self.__event_button_onBlackMarketCancelClicked__ = UnityEngine.Events.UnityAction(self.OnBlackMarketCancelClicked, self)
	self.BlackMarketCancel.onClick:AddListener(self.__event_button_onBlackMarketCancelClicked__)
end

function BlackMarketCls:UnregisterControlEvents()
	if self.__event_button_onBlackMarketButtonClicked__ then
		self.BlackMarketButton.onClick:RemoveListener(self.__event_button_onBlackMarketButtonClicked__)
		self.__event_button_onBlackMarketButtonClicked__ = nil
	end
	if self.__event_button_onBlackMarketCancelClicked__ then
		self.BlackMarketCancel.onClick:RemoveListener(self.__event_button_onBlackMarketCancelClicked__)
		self.__event_button_onBlackMarketCancelClicked__ = nil
	end
end

function BlackMarketCls:RegisterNetworkEvents()
	self:GetGame():RegisterMsgHandler(net.S2CShopHeishiQueryResult,self,self.OnBlackMarketQueryResult)
end

function BlackMarketCls:UnregisterNetworkEvents()
	self:GetGame():UnRegisterMsgHandler(net.S2CShopHeishiQueryResult,self,self.OnBlackMarketQueryResult)
end

function BlackMarketCls:OnBlackMarketQueryResult(msg)
	self.openTime = msg.remainTime
	self.lastTime = 0
end


function BlackMarketCls:OnBlackMarketCancelClicked()
	self:Close(true)
end

function BlackMarketCls:OnBlackMarketButtonClicked()
	self:HideAll()

	-- 切换到主页 --
	local GamePhase = require "Game.GamePhase"
    if self:GetGame():GetCurrentPhase() == GamePhase.Battle then
    	utility.PopToRootScene(function()
			local windowManager = utility.GetGame():GetWindowManager()
			windowManager:Show(require "GUI.Shop.Shop",KShopType_BlackMarket)
		end)
    else
		local windowManager = utility.GetGame():GetWindowManager()
		windowManager:Show(require "GUI.Shop.Shop",KShopType_BlackMarket)
	end
	self:OnBlackMarketCancelClicked()
	-- self:ShopHeishiQueryRequest()
end

function BlackMarketCls:HideAll()
	local windowManager = self:GetGame():GetWindowManager()
	windowManager:HideAll()
	local sceneManager = utility:GetGame():GetSceneManager()
    sceneManager:PopToRootScene()
end

function BlackMarketCls:ShopHeishiQueryRequest()
	--黑市Query请求
	self:GetGame():SendNetworkMessage( require "Network/ServerService".ShopHeishiQueryRequest())
end

function BlackMarketCls:InitView()
	-- self.BlackMarketTime.text = utility.ConvertTime(self.openTime)
end

function BlackMarketCls:TimeCountdown()
	if self.openTime ~= nil then
		if self.openTime <= 0 then
			self.BlackMarketTime.gameObject:SetActive(false)
		else
			self.BlackMarketTime.gameObject:SetActive(true)
		--	self.countTime=self.countTime-Time.deltaTime
			if os.time() - self.lastTime >= 1 then
				self.lastTime = os.time()
				self.openTime = self.openTime - 1
			end
			self.BlackMarketTime.text = utility.ConvertTime(self.openTime)
		end	
	end
end

return BlackMarketCls