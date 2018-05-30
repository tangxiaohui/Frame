local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local LotteryDrawScene = Class(BaseNodeClass)

function LotteryDrawScene:Ctor()
	-- 加载 登录界面
	utility.LoadNewGameObjectAsync('UI/Prefabs/LotteryDraw', function(go)
		self:BindComponent(go)
		self:InitControls()
	end)
	self.myGame = utility.GetGame()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function LotteryDrawScene:OnEnter()
	LotteryDrawScene.base.OnEnter(self)
	self:InitView()
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:OnLotteryQueryRequest()
	self:ScheduleUpdate(self.Update)
end

function LotteryDrawScene:OnExit()
	LotteryDrawScene.base.OnExit(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function LotteryDrawScene:Update()
	self:UpdateTime()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
function LotteryDrawScene:InitControls()
	local transform = self:GetUnityTransform()

	self.controls = {}
	self.controls.nomalLotteryTime = 0
	self.controls.dimondLotteryTime = 0
	self.controls.lotteryDefautInfo = "本次购买免费"
	self.controls.normalLotteryInfo_1 = "当前拥有："
	self.controls.normalLotteryInfo_2 = "\n消耗寻宝令*1"
	self.controls.diamandLotteryInfo = "消耗砖石100"
	self.controls.daojuCDTime = 0
	self.controls.diamondCDTime = 0
	self.controls.remainCount = 0
	--self.Image = transform:Find('Image'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.Button = transform:Find('Button'):GetComponent(typeof(UnityEngine.UI.Button))
	self.characterVipLabel = transform:Find('Character/VIP'):GetComponent(typeof(UnityEngine.UI.Text))
	self.characterNameLabel = transform:Find('Character/Name'):GetComponent(typeof(UnityEngine.UI.Text))
	self.characterCoinLabel = transform:Find('Character/Coin'):GetComponent(typeof(UnityEngine.UI.Text))
	self.characterDiamondLabel = transform:Find('Character/Diamond'):GetComponent(typeof(UnityEngine.UI.Text))
	self.normalLotteryTimeLabel = transform:Find('Main/NormalLottery/Time'):GetComponent(typeof(UnityEngine.UI.Text))
	self.normalLotteryInfoLabel = transform:Find('Main/NormalLottery/Info'):GetComponent(typeof(UnityEngine.UI.Text))
	self.diamondLotteryTimeLabel = transform:Find('Main/DiamondCheck/Time'):GetComponent(typeof(UnityEngine.UI.Text))
	self.diamondLotteryInfoLabel = transform:Find('Main/DiamondCheck/Info'):GetComponent(typeof(UnityEngine.UI.Text))
	self.diamondTimeLabel = transform:Find('DiamondLottery/DiamondOne/Time'):GetComponent(typeof(UnityEngine.UI.Text))
	self.diamondInfoLabel = transform:Find('DiamondLottery/DiamondOne/Info'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LotteryDialogInfoLabel = transform:Find('LottetyDialog/DialogInfoText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.backMainButton = transform:Find('Main/Buttons/BackMainBtn'):GetComponent(typeof(UnityEngine.UI.Button))
	self.normalBuyButton = transform:Find('Main/NormalLottery/NormalBuyBtn'):GetComponent(typeof(UnityEngine.UI.Button))
	self.lotteryDialogConfirmButton = transform:Find('LottetyDialog/ConfirmBtn'):GetComponent(typeof(UnityEngine.UI.Button))
	self.diamondCheckButton = transform:Find('Main/DiamondCheck/DiamondCheckBtn'):GetComponent(typeof(UnityEngine.UI.Button))
	self.diamondLotteryOneButton = transform:Find('DiamondLottery/DiamondOne'):GetComponent(typeof(UnityEngine.UI.Button))
	self.diamondLotteryTenButton = transform:Find('DiamondLottery/DiamondTen'):GetComponent(typeof(UnityEngine.UI.Button))
	self.diamondBackMainButton = transform:Find('DiamondLottery/BackMainBtn'):GetComponent(typeof(UnityEngine.UI.Button))
	self.lotteryMainPanel = transform:Find('Main').gameObject
	self.lotteryDiamondLotteryPanel = transform:Find('DiamondLottery').gameObject
	self.lotteryDialogPanel = transform:Find('LottetyDialog').gameObject
end

function LotteryDrawScene:InitView()
	-- 初始化界面
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)

    self.characterVipLabel.text  = userData:GetVip()
    self.characterNameLabel.text = userData:GetName()
    self.characterCoinLabel.text = userData:GetCoin()
    self.characterDiamondLabel.text = userData:GetDiamond()
end

function LotteryDrawScene:RegisterControlEvents()
	-- 注册 Button 的事件
	--self.__event_button_onButtonClicked__ = function() self:OnButtonClicked() end
	--self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)
	self.__event_button_onNormalBuyButtonClicked__ = function() self:OnNormalBuyButtonClicked() end
	self.normalBuyButton.onClick:AddListener(self.__event_button_onNormalBuyButtonClicked__ )
	self.__event_button_onBackMainButtonClicked__ = function() self:OnBackMainButtonClicked() end
	self.backMainButton.onClick:AddListener(self.__event_button_onBackMainButtonClicked__ )
	self.__event_button_onlotteryDialogConfirmButtonClicked__ = function() self:OnBackLotteryMainPanel(self.lotteryDialogPanel) end
	self.lotteryDialogConfirmButton.onClick:AddListener(self.__event_button_onlotteryDialogConfirmButtonClicked__)
	self.__event_button_onDiamondCheckButtonClicked__ = function() self:OnDiamondCheckButtonClicked() end
	self.diamondCheckButton.onClick:AddListener(self.__event_button_onDiamondCheckButtonClicked__)
	self.__event_button_onDiamondBackMainButtonClicked__ = function() self:OnBackLotteryMainPanel(self.lotteryDiamondLotteryPanel) end
	self.diamondBackMainButton.onClick:AddListener(self.__event_button_onDiamondBackMainButtonClicked__)
end

function LotteryDrawScene:UnregisterControlEvents()
	-- 取消注册 Button 的事件
	--if self.__event_button_onButtonClicked__ then
	--	self.Button.onClick:RemoveListener(self.__event_button_onButtonClicked__)
	--	self.__event_button_onButtonClicked__ = nil
	--end
	if self.__event_button_onNormalBuyButtonClicked__ then
		self.normalBuyButton.onClick:RemoveListener(self.__event_button_onNormalBuyButtonClicked__)
		self.__event_button_onNormalBuyButtonClicked__ = nil
	end
	if self.__event_button_onBackMainButtonClicked__ then
		self.backMainButton.onClick:RemoveListener(self.__event_button_onBackMainButtonClicked__)
		self.__event_button_onBackMainButtonClicked__ = nil
	end
	if self.__event_button_onlotteryDialogConfirmButtonClicked__ then
		self.lotteryDialogConfirmButton.onClick:RemoveListener(self.__event_button_onlotteryDialogConfirmButtonClicked__)
		self.__event_button_onlotteryDialogConfirmButtonClicked__ = nil
	end
	if self.__event_button_onDiamondCheckButtonClicked__ then
		self.diamondCheckButton.onClick:RemoveListener(self.__event_button_onDiamondCheckButtonClicked__)
		self.__event_button_onDiamondCheckButtonClicked__ = nil
	end
	if self.__event_button_onDiamondBackMainButtonClicked__ then
		self.diamondBackMainButton.onClick:RemoveListener(self.__event_button_onDiamondBackMainButtonClicked__)
		self.__event_button_onDiamondBackMainButtonClicked__ = nil
	end
end

function LotteryDrawScene:RegisterNetworkEvents()
    --myGame:RegisterMsgHandler(net.S2CTalkResultResult, self, self.OnSystemNoticeResponse)
    self.myGame:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
    self.myGame:RegisterMsgHandler(net.S2CChoukaDaojuChooseResult, self, self.OnNormalLotteryResult)
    self.myGame:RegisterMsgHandler(net.S2CChoukaQueryResult, self, self.OnLotteryQueryResult)
end

function LotteryDrawScene:UnregisterNetworkEvents()
    --myGame:UnRegisterMsgHandler(net.S2CTalkResultResult, self, self.OnSystemNoticeResponse)
    self.myGame:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
    self.myGame:UnRegisterMsgHandler(net.S2CChoukaDaojuChooseResult, self, self.OnNormalLotteryResult)
    self.myGame:UnRegisterMsgHandler(net.S2CChoukaQueryResult, self, self.OnLotteryQueryResult)
end

function LotteryDrawScene:OnLoadPlayerResponse()
    -- # 相应玩家数据更新
    self:InitView()
end

function LotteryDrawScene:OnLotteryQueryRequest()
	-- # 抽卡请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".LotteryDrawQueryRequest())
end

function LotteryDrawScene:OnLotteryQueryResult(msg)
	-- # 抽卡请求结果
	self.controls.daojuCDTime = msg.daojuCDTime / 1000
	self.controls.diamondCDTime = msg.diamondCDTime / 1000
	self.controls.remainCount = msg.remainCount
	self:OnUpdateLotteryPromptInfo()
end

function LotteryDrawScene:OnNormalLotteryResult(msg)
	-- # 道具抽卡响应
	self.controls.daojuCDTime = msg.daojuCDTime / 1000
	self:OnUpdateLotteryPromptInfo()
	self.lotteryMainPanel:SetActive(false)
	self.lotteryDialogPanel:SetActive(true)
	self.LotteryDialogInfoLabel.text = "道具:" .. msg.item.itemID .. 
										"\n" .. "数量:" ..msg.item.itemNum ..
										"\n" .. "品阶:" .. msg.item.itemColor

end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function LotteryDrawScene:OnNormalBuyButtonClicked()
	--道具抽卡的Button控件的点击事件处理
	self.myGame:SendNetworkMessage( require"Network/ServerService".NormalLotteryDraw())
end

function LotteryDrawScene:OnBackMainButtonClicked()
	-- 返回主界面
	local sceneManager = self.myGame:GetSceneManager()

    --local MainUINodeSceneCls = require "GUI.MainUINode"
    sceneManager:PopScene()
end

function LotteryDrawScene:OnBackLotteryMainPanel(currPanel)
	-- 抽奖结束返回抽奖主界面
	currPanel:SetActive(false)
	self.lotteryMainPanel:SetActive(true)
	--self:OnLotteryQueryRequest()
	self:OnUpdateLotteryPromptInfo()
end

function LotteryDrawScene:OnDiamondCheckButtonClicked()
	-- 钻石抽奖查看Button
	self.lotteryMainPanel:SetActive(false)
	self.lotteryDiamondLotteryPanel:SetActive(true)
	--self:OnLotteryQueryRequest()
	self:OnUpdateLotteryPromptInfo()
end

function LotteryDrawScene:OnUpdateLotteryPromptInfo()
	-- 更新抽卡提示信息
	if self.controls.daojuCDTime == 0 then 
		self.normalLotteryTimeLabel.gameObject:SetActive(false)
		self.normalLotteryInfoLabel.text = self.controls.lotteryDefautInfo
	else 
		-- todo 加上当前寻宝令数量
		self.normalLotteryTimeLabel.gameObject:SetActive(true)
		self.normalLotteryInfoLabel.text = self.controls.normalLotteryInfo_1..self.controls.normalLotteryInfo_2
	end
	if self.controls.diamondCDTime == 0 then 
		self.diamondLotteryTimeLabel.gameObject:SetActive(false)
		self.diamondLotteryInfoLabel.text = self.controls.lotteryDefautInfo
		self.diamondTimeLabel.gameObject:SetActive(false)
		self.diamondInfoLabel.text = self.controls.lotteryDefautInfo
	else 
		self.diamondLotteryInfoLabel.gameObject:SetActive(true)
		self.diamondLotteryInfoLabel.text = self.controls.diamandLotteryInfo
		self.diamondInfoLabel.gameObject:SetActive(true)
		self.diamondInfoLabel.text = self.controls.diamandLotteryInfo
	end
end

function LotteryDrawScene:UpdateTime()
	-- 更新显示时间
	if self.normalLotteryTimeLabel.gameObject.activeInHierarchy then
		self.controls.daojuCDTime = self.controls.daojuCDTime - Time.deltaTime
			if self.controls.daojuCDTime < 0 then
			self.controls.daojuCDTime = 0
			self:OnUpdateLotteryPromptInfo()
			end
	self.normalLotteryTimeLabel.text = utility.ConvertTime(self.controls.daojuCDTime)
	end
	if self.diamondLotteryTimeLabel.gameObject.activeInHierarchy then
		self.controls.diamondCDTime = self.controls.diamondCDTime - Time.deltaTime
			if self.controls.diamondCDTime < 0 then
			self.controls.diamondCDTime = 0
			self:OnUpdateLotteryPromptInfo()
			end
	self.diamondLotteryTimeLabel.text = utility.ConvertTime(self.controls.diamondCDTime)
	end
	if self.diamondTimeLabel.gameObject.activeInHierarchy then
		self.controls.diamondCDTime = self.controls.diamondCDTime - Time.deltaTime
			if self.controls.diamondCDTime < 0 then
			self.controls.diamondCDTime = 0
			self:OnUpdateLotteryPromptInfo()
			end
	self.diamondTimeLabel.text = utility.ConvertTime(self.controls.diamondCDTime)
	end
end

return LotteryDrawScene