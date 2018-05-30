local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local UserDataType = require "Framework.UserDataType"

require "System.LuaDelegate"

local DepositItemCls = Class(BaseNodeClass)

function DepositItemCls:Ctor(tables,parentTransform)
	self.tables = tables
	self.parentTransform = parentTransform
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function DepositItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/DepositItem', function(go)
		self:BindComponent(go)
	end)
end

function DepositItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function DepositItemCls:OnResume()
	-- 界面显示时调用
	DepositItemCls.base.OnResume(self)
	self:LinkComponent(self.parentTransform)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function DepositItemCls:OnPause()
	-- 界面隐藏时调用
	DepositItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function DepositItemCls:OnEnter()
	-- Node Enter时调用
	DepositItemCls.base.OnEnter(self)
end

function DepositItemCls:OnExit()
	-- Node Exit时调用
	DepositItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function DepositItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility:GetGame()
--	transform:SetParent(self.parentTransform))
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Deco = transform:Find('Deco'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NameLabel = transform:Find('NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PriceLabel = transform:Find('PriceLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Base1 = transform:Find('Item/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Icon = transform:Find('Item/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Frame = transform:Find('Item/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DescriptionLabel = transform:Find('DescriptionLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BuyButton = transform:Find('BuyButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self:InitViews()
end

function DepositItemCls:InitViews()
	self.NameLabel.text = self.tables:GetName()
	self.PriceLabel.text = (self.tables:GetPrice() / 100)..'元'
	self.DescriptionLabel.text = self.tables:GetDes()
	-- print(self.tables:GetIcon())
	local iconPath = "UI/Atlases/Icon/ItemIcon/"..self.tables:GetIcon()
	-- print(iconPath)
	utility.LoadSpriteFromPath(iconPath, self.Icon)
end

function DepositItemCls:RegisterControlEvents()
	-- 注册 BuyButton 的事件
	self.__event_button_onBuyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBuyButtonClicked, self)
	self.BuyButton.onClick:AddListener(self.__event_button_onBuyButtonClicked__)
end

function DepositItemCls:UnregisterControlEvents()
	-- 取消注册 BuyButton 的事件
	if self.__event_button_onBuyButtonClicked__ then
		self.BuyButton.onClick:RemoveListener(self.__event_button_onBuyButtonClicked__)
		self.__event_button_onBuyButtonClicked__ = nil
	end
end

function DepositItemCls:RegisterNetworkEvents()
end

function DepositItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
-- HTTP接口请求Json --
local function RequestJsonImpl(self, url, successCallback, failedCallback)
    local www = UnityEngine.WWW(url)
    coroutine.www(www)

    local error = www.error
    if error == nil or string.len(error) == 0 then
        -- 解析 json 数据 --
        local cjson = require "cjson.safe"
        local data = cjson.decode(www.text)

        if data ~= nil then
            if data.error == nil or data.error == 0 then
                successCallback(data)
            else
                failedCallback(data.msg)
            end
        else
            failedCallback("服务器数据加载失败!")
        end
    else
        failedCallback(string.format("网络失败, 原因: %s", www.error))
    end
end

local function OnPay(self, orderId)
	-- 价格&名字
	local unitPrice = self.tables:GetPrice()
	local unitName = self.tables:GetName()

	-- 回调信息(cbi)
	local callBackInfo = orderId

	-- 获取钻石
	local diamondToReceive = 0
	if self.tables:GetRechargeType() ~= 1 then
		diamondToReceive = self.tables:GetDiamond()
	end

	-- 用户开始支付.
	require "Utils.GameAnalysisUtils".StartPayment(
		orderId,
		unitPrice/100,
		diamondToReceive,
		unitName,
		1
	)

	-- 调用支付接口
	self.game:GetSDKManager():Pay(unitPrice, unitName, 1, callBackInfo, "", nil)
end

-- 新的实现
function DepositItemCls:OnBuyButtonClicked()

	self:GetUIManager():DisableInput()

	-- 请求URL
	local url = string.format(
		"http://%s:%d/loginserver/getOrder.do?serverId=%s&imei=%s&pid=%s&uid=%s&goodsId=%s&channel=%s&sdkid=%s",
		self:GetGame():GetGameServer():GetLoginIp(),
		self:GetGame():GetGameServer():GetLoginPort(),
		self:GetGame():GetCurrentServerId(),
		_G.DeviceUtility.GetIMEI(),
		self:GetCachedData(UserDataType.PlayerData):GetId(),
		self:GetGame():GetGameServer():GetChannelUserId(),
		self.tables:GetId(),
		_G.DeviceUtility.GetPlatformId(),
		_G.DeviceUtility.GetChannelId()
	)

	debug_print("支付订单号", url)

	self:StartCoroutine(
		RequestJsonImpl,
		url,
		function(jsonData)
			debug_print("订单ID", jsonData.orderId)
			OnPay(self, jsonData.orderId, self:GetCachedData(UserDataType.PlayerData):GetId())
			self:GetUIManager():EnableInput()
		end,
		function(errorMsg)
			debug_print("错误信息", errorMsg)
			self:GetUIManager():EnableInput()
        end
    )

end

return DepositItemCls
