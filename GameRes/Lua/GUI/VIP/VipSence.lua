local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
require "LUT.StringTable"

local VipSenceCls = Class(BaseNodeClass)
windowUtility.SetMutex(VipSenceCls, true)

local firstEnter

function  VipSenceCls:Ctor()
	
end

function VipSenceCls:OnWillShow()
end

function  VipSenceCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/VIP",function(go)
		self:BindComponent(go)
	end)
end

function VipSenceCls:OnComponentReady()
	self:InitControls()
end

function VipSenceCls:OnResume()
	VipSenceCls.base.OnResume(self)
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

function VipSenceCls:OnPause()
	VipSenceCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	-- self:RemoveAll()
end

function VipSenceCls:OnEnter()
	VipSenceCls.base.OnEnter(self)
end

function VipSenceCls:OnExit()
	VipSenceCls.base.OnExit(self)
end

function VipSenceCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  VipSenceCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find("Base")
	self.returnButton = self.base:Find("RetrunButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.charge = self.base:Find("Charge")
	self.vipLabel = self.charge:Find("NowVIP"):GetComponent(typeof(UnityEngine.UI.Text))
	self.numLabel = self.charge:Find("Bar/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.fillSprite = self.charge:Find("Bar/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	self.needPriceLabel = self.charge:Find("Notice/PriceLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.nextVipLabel = self.charge:Find("Notice/NEWVIP"):GetComponent(typeof(UnityEngine.UI.Text))
	self.chargeButton = self.charge:Find("BuyButton"):GetComponent(typeof(UnityEngine.UI.Button))
	--功能解锁
	self.vipfunction = self.base:Find("FunctionUnlock/Notice"):GetComponent(typeof(UnityEngine.UI.Text))
	self.functionLabel = self.base:Find("FunctionUnlock/Scroll View/Viewport/Content/InfoLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--特权解锁
	self.viptimes = self.base:Find("FunctionTimes/Notice"):GetComponent(typeof(UnityEngine.UI.Text))
	self.timesLabel = self.base:Find("FunctionTimes/Scroll View/Viewport/Content/InfoLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--礼包
	self.vipPacksPanel = self.base:Find("Gift/Gift")
	self.vippack = self.base:Find("Gift/Notice"):GetComponent(typeof(UnityEngine.UI.Text))
	self.vipPackPoint = self.base:Find("Gift/Scroll View/Viewport/Content")
	self.vipPackBuy = self.vipPacksPanel:Find("BuyButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.vipPackBuyImage = self.vipPacksPanel:Find("BuyButton"):GetComponent(typeof(UnityEngine.UI.Image))
	self.vipPackBuyText = self.vipPacksPanel:Find("BuyButton/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.vipPackPrice = self.vipPacksPanel:Find("PriceLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--vip满级时隐藏
	self.noticeLabel = self.charge:Find("Notice")
	self.buyButton = self.charge:Find("BuyButton")
	self.vipButtonItemPoint = self.base:Find("Scroll View/Viewport/Content")

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.pos = self.vipButtonItemPoint.localPosition
	self.GrayMaterial = utility.GetGrayMaterial()
	self.myGame = utility:GetGame()
	firstEnter = true
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function VipSenceCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function VipSenceCls:OnExitTransitionDidStart(immediately)
    VipSenceCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function  VipSenceCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	self._event_button_onvipPackBuyButtonClicked_ = UnityEngine.Events.UnityAction(self.OnVipPackBuyClicked,self)
	self.vipPackBuy.onClick:AddListener(self._event_button_onvipPackBuyButtonClicked_)

	self._event_button_onChargeButtonClicked_ = UnityEngine.Events.UnityAction(self.OnChargeButtonClicked,self)
	self.chargeButton.onClick:AddListener(self._event_button_onChargeButtonClicked_)

end

function  VipSenceCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end

	if self._event_button_onvipPackBuyButtonClicked_ then
		self.vipPackBuy.onClick:RemoveListener(self._event_button_onvipPackBuyButtonClicked_)
		self._event_button_onvipPackBuyButtonClicked_ = nil
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

function VipSenceCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CVipChargeQueryResult,self,self.OnVipChargeQueryResult)	
end

function VipSenceCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CVipChargeQueryResult,self,self.OnVipChargeQueryResult)
end

function VipSenceCls:OnVipChargeQuery()
    self:GetGame():SendNetworkMessage( require "Network.ServerService".VipChargeQuery())
end

function VipSenceCls:OnVipChargeQueryResult(msg)
	print("接受服务器数据")
	self.msg = msg
	self.gifts = msg.diamondLibaos
	if self.clickVip ~= nil then
		self:LoadPanel(self.clickVip)
	else
		self:LoadPanel(self:GetVip())
	end
end

local buttonY = 67.5
function VipSenceCls:ShowPanel()
	self:OnVipChargeQuery()
	
	-- self:LoadPanel(vip)
	
	self:LoadButtonItem()
end

function VipSenceCls:LoadButtonItem()
	local tables = {}
	tables = self:GetVipInfo()	
	self.node = {}
	for i=1,#tables do
		self.VipButtonItemCls = require "GUI.VIP.VipButtonItem".New(self.vipButtonItemPoint,tables[i],self:GetVip())
		self.node[i] = self.VipButtonItemCls
		self.node[i]:SetCallback(self,self.OnChildClicked)
		self:AddChild(self.VipButtonItemCls)
	end
end


function VipSenceCls:LoadPanel(vip)
	local vipData = require "StaticData.Vip.Vip"
	-- local vip = self:GetVip()
	self.vipLabel.text = "VIP"..vip
	local nextvip = self:GetNextVip(vip)
	if nextvip ~= nil then
		self.noticeLabel.gameObject:SetActive(true)
		self.nextVipLabel.text = "VIP"..nextvip
		local diamonds = vipData:GetData(nextvip):GetChargeMin()
		local needDiamonds = diamonds-self.msg.totalCharge
		if needDiamonds>0 then
			self.needPriceLabel.text = needDiamonds
		else
			self.needPriceLabel.text = 0

		end
		self.numLabel.text = self.msg.totalCharge.."/"..diamonds
		self.fillSprite.fillAmount = self.msg.totalCharge/diamonds

	else
		nextvip = self:GetNextVip(vip - 1)
		local diamonds = vipData:GetData(nextvip):GetChargeMin()
		self.fillSprite.fillAmount = self.msg.totalCharge / diamonds
		if self.msg.totalCharge / diamonds >= 1 then
			self.numLabel.text ='MAX'
		else
			self.numLabel.text = self.msg.totalCharge.."/"..diamonds
		end
		self.noticeLabel.gameObject:SetActive(false)
	end
	self.vipfunction.text = string.format(Vip[0],vip)
	self.viptimes.text = string.format(Vip[1],vip)
	self.vippack.text = string.format(Vip[2],vip)
	self:ShowDescLabel(vip)
	self:GetPacksData(vip)
	for i=1,#self.gifts do
		if self.gifts[i].id == vip then
			self:GetState(vip,self.gifts[i].alreadyBuy)
		end
	end
	if firstEnter then
		local vip = self:GetVip()
		self.vipButtonItemPoint.localPosition = Vector2(self.pos.x,self.pos.y + vip*buttonY)
	end
end

function VipSenceCls:ShowDescLabel(vip)
	local vipData = require "StaticData.Vip.Vip"
	local vipInfoData = require "StaticData.Vip.VipInfo"
	local vipFunction = vipData:GetData(vip):GetFunctionUnlocked()
	local vipTimes = vipData:GetData(vip):GetTimesUnlocked()
	local keys = vipInfoData:GetKeys()
	local functionText 
	local timesText
	local functionTables = {}
	local tiemsTables = {}
	local vipFunctionIndex = {}
	local vipTimesIndex = {}
	for i=0,(keys.Length - 1) do
		local position = vipInfoData:GetData(keys[i]):GetPosition()
		local text = vipInfoData:GetData(keys[i]):GetInfo()
		if position == 0 then
			vipFunctionIndex[#vipFunctionIndex + 1] = keys[i]
			functionTables[#functionTables+1] = text
		else
			vipTimesIndex[#vipTimesIndex + 1] = keys[i]
			tiemsTables[#tiemsTables+1] = text
		end
	end
	for i=1,#functionTables do
		local isBlackMarket = string.find(functionTables[i],"s",1)
		-- print(functionTables[i])
		local isShow = vipInfoData:GetData(vipFunctionIndex[i]):GetIsShow()
		if isBlackMarket ~= nil then
			if isShow ~= 0 then
				if vipFunction[i] ~= 0 then
					local text = string.format(functionTables[i],vipFunction[i])
					if functionText ~= nil then
						functionText = functionText.."\n"..text
					else
						functionText = text
					end
				end
		else
			if vipFunction[i] == 1 then
				functionText = functionText.."\n"..functionTables[i]
			end
		end
	end
	end
	for i=1,#tiemsTables do
		-- print(vipTimes[i])
		local isShow = vipInfoData:GetData(vipTimesIndex[i]):GetIsShow()
		if isShow ~= 0 then
		if vipTimes[i] ~= 0 then
			local text = string.format(tiemsTables[i],vipTimes[i])
			if timesText ~= nil then
				timesText = timesText.."\n"..text
			else
				timesText = text
			end
		end
	end
	end
	-- print(type(functionTables[1]))
	-- functionText = string.format(functionTables[1],vipFunction[1])
	self.functionLabel.text = functionText
	local sizeDelta = self.functionLabel.rectTransform.sizeDelta
	sizeDelta.y = self.functionLabel.preferredHeight
	self.functionLabel.rectTransform.sizeDelta = sizeDelta
	self.timesLabel.text = timesText
	local sizeDelta = self.timesLabel.rectTransform.sizeDelta
	sizeDelta.y = self.timesLabel.preferredHeight
	self.timesLabel.rectTransform.sizeDelta = sizeDelta
end

function VipSenceCls:GetPacksData(vip)
	self:RemovePacks()
	-- if vip ~= 0 then
		self.vipPacksPanel.gameObject:SetActive(true)
		local vipData = require "StaticData.Vip.Vip"
		local vipPackId = vipData:GetData(vip):GetPacksID()
		local vipPacks = require "StaticData.Vip.VipPacks"
		local PropUtility = require "Utils.PropUtility"
		self.vipPacksNode = {}
		-- if vipPackId ~= 0 then
			local vipPackData = vipPacks:GetData(vipPackId)
			local items = utility.Split(vipPackData:GetItemID(),";")
			local nums = utility.Split(vipPackData:GetItemNum(),";")
			local colors = utility.Split(vipPackData:GetItemColor(),";")
			for i=1,#items do
				self.vipPacksItem = require "GUI.VIP.VipItem".New(self.vipPackPoint,items[i],nums[i],colors[i])
				self:AddChild(self.vipPacksItem)
				self.vipPacksNode[i] = self.vipPacksItem
			end
			self.vipPackPrice.text = vipPackData:GetPrice()
		-- else
		-- 	self.vipPackPrice.text = 0
		-- end
	-- else
	-- 	self.vipPacksPanel.gameObject:SetActive(false)
	-- end
end

function VipSenceCls:GetNextVip(vip)
	local vipId = self:GetVipInfo()
	local nextvip = nil
	for i=1,(#vipId - 1) do
		if vip == vipId[i] then
			nextvip = vipId[i+1]
		end
	end
	if vip == vipId[#vipId] then
		nextvip = nil
	end
	return nextvip
end

function VipSenceCls:GetVipInfo()
	local vip = require "StaticData.Vip.Vip":GetKeys()
	local vipId = {}
	for i=0,(vip.Length - 1) do
		vipId[#vipId + 1] = vip[i]
	end
	return vipId
end
-- function VipSenceCls:GetId()
	-- print("打印打印打印打印 >>>>>>>>>>> 1")
	-- local roleMgr = Data.Role.Manager.Instance()
	-- local staticData = roleMgr:GetObject(10000002)
	-- local vvv = "id"
	-- print(staticData.id, staticData[vvv])
	-- print("打印打印打印打印 >>>>>>>>>>> 2")
	-- local VipMgr = Data.Vip.Manager.Instance():GetObject(1)
	-- print("aaaaaaaaa",VipMgr["info"])	
	-- self:GetUnlocked()
-- end

-- function VipSenceCls:GetUnlocked()
	-- local VipInfoMgr = Data.VipInfo.Manager.Instance()
	-- local vip = require "StaticData.Vip.Vip":GetKeys()
	-- local infotables = {} 
	-- local vipShow = {}
	-- for i=0,(vip.Length - 1) do
	-- 	local vipinfo = Data.Vip.Manager.Instance():GetObject(vip[i])
	-- 	local info = vipinfo.info
	-- 	infotables[#infotables + 1] = info
	-- end
	-- print("info",#infotables,"id",vip.Length)
	-- local vipInfoKeys = require "StaticData.Vip.VipInfo":GetKeys()
	-- for i=0,#infotables do
	-- 	local id = VipInfoMgr:GetObject(vipInfoKeys[i])

	-- 		-- vipShow[#vipShow + 1] = {}
	-- 		-- vipShow[#vipShow + 1] = VipInfoMgr:GetObject(vipInfoKeys[i])[infotables[j]]
	-- 		print("VipInfo",VipInfoMgr:GetObject(vipInfoKeys[i]))
	-- 	end
	-- end
	-- -- return #infotables
-- end

function VipSenceCls:OnChildClicked(id,clickedState,closedState)
	firstEnter = false
	self.clickVip = id
	self:RemovePacks()
	for i=1,#self.node do
		self.node[i].clickedState.gameObject:SetActive(false)
		self.node[i].closedState.gameObject:SetActive(true)
	end
	clickedState.gameObject:SetActive(true)
	closedState.gameObject:SetActive(false)
	self:LoadPanel(id)
	-- print("aaaaaaaaaaaa",clickedState.name)
end

function  VipSenceCls:OnReturnButtonClicked()
	self:Close(true)
end

function VipSenceCls:OnVipPackBuyClicked()
	if self.state == 1 then
		local windowManager = utility:GetGame():GetWindowManager()
		if self.clickVip ~= nil then
			windowManager:Show(require "GUI.VIP.VipGiftPanel",self.clickVip,1)
		else
			windowManager:Show(require "GUI.VIP.VipGiftPanel",self:GetVip(),1)
		end
	end
end

function  VipSenceCls:OnChargeButtonClicked()
	-- local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
 --    local windowManager = utility.GetGame():GetWindowManager()
	-- local hintStr = string.format("暂未开启")
 --    windowManager:Show(ErrorDialogClass, hintStr)

     local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Deposit.Deposit")
    self:Close(true)
end

function  VipSenceCls:GetVip()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local viplv = userData:GetVip()
    return viplv
end

function VipSenceCls:RemoveAll()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
	self:RemovePacks()
	self.clickVip = nil
end

function VipSenceCls:RemovePacks()
	if self.vipPacksNode ~= nil then
		for i=1,#self.vipPacksNode do
			self:RemoveChild(self.vipPacksNode[i],true)
		end
	end
end

function VipSenceCls:GetState(vip,alreadyBuy)
	local vipLv = self:GetVip()
	local state = 0
	-- debug_print(alreadyBuy)
	if vipLv >= vip and not alreadyBuy then
		state = 1
	end
	if vipLv >= vip and alreadyBuy then
		state = 2
	end
	if vipLv < vip then
		state = 0
	end
	if state == 0 then
		self.vipPackBuyImage.material = self.GrayMaterial
		self.vipPackBuyText.text = "购买"
	end
	if state == 1 then
		self.vipPackBuyImage.material = utility.GetCommonMaterial()
		self.vipPackBuyText.text = "购买"
	end
	if state == 2 then
		self.vipPackBuyImage.material = self.GrayMaterial
		self.vipPackBuyText.text = "已购买"
	end
	self.state =state
end

function VipSenceCls:ServerDataHandler(id,state)
	if self.gifts ~= nil then
		for i=1,#self.gifts do
			
		end
	end
end

function VipSenceCls:GetServerState(id)
	local state = 0
	if self.gifts ~= nil then
		for i=1,#self.gifts do
			if self.gifts[i].id == id then
				state = self.gifts[i].alreadyBuy
			end
		end
	end
	return state
end

return VipSenceCls