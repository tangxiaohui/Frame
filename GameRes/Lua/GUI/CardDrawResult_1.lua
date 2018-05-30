local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
require "LUT.StringTable"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CardDrawResultCls = Class(BaseNodeClass)
windowUtility.SetMutex(CardDrawResultCls, true)

function CardDrawResultCls:Ctor()
end

function CardDrawResultCls:OnWillShow()
	--local eventMgr = utility.GetGame():GetEventManager()
    --eventMgr:AddObserver('CardDrawResult', self, self.CardDrawResult)
    --eventMgr:AddObserver('ResumeCoroutineState', self, self.ResumeCoroutineState)
    self:AddObserver()
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardDrawResultCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardDrawResult', function(go)
		self:BindComponent(go)
	end)
end

function CardDrawResultCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:InitAwardItem()
end

function CardDrawResultCls:OnResume()
	-- 界面显示时调用
	CardDrawResultCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end
function CardDrawResultCls:OnPause()
	-- 界面隐藏时调用
	CardDrawResultCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:HideItem(1,self.count)
	--self:UnregisterNetworkEvents()
end

function CardDrawResultCls:OnEnter()
	-- Node Enter时调用
	CardDrawResultCls.base.OnEnter(self)
end

function CardDrawResultCls:OnExit()
	-- Node Exit时调用
	CardDrawResultCls.base.OnExit(self)
end

function CardDrawResultCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardDrawResultCls:InitControls()
	local transform = self:GetUnityTransform()
	self.ConfirmButton = transform:Find('Canvas_Defaut/CardDrawResultBackButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CardDrawResultDiamondOneButton = transform:Find('Canvas_Defaut/CardDrawResultDiamondOneButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CardDrawResultDiamondTenButton = transform:Find('Canvas_Defaut/CardDrawResultDiamondTenButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.AwardListTrans = transform:Find('Canvas_Defaut/AwardList/Viewport/Content'):GetComponent(typeof(UnityEngine.RectTransform))
	self.AwardList = self.AwardListTrans.transform:GetComponent(typeof(UnityEngine.UI.GridLayoutGroup))
	self.AwardListContentSize = self.AwardListTrans.transform:GetComponent(typeof(UnityEngine.UI.ContentSizeFitter))
	self.AwardListScroll = transform:Find('Canvas_Defaut/AwardList'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.DiamondOneLabel = transform:Find('Canvas_Defaut/CardDrawResultDiamondOneButton/CardDrawResultDiamondOneNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DiamondIconOneImage = transform:Find('Canvas_Defaut/CardDrawResultDiamondOneButton/DiamondIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DiamondTenLabel = transform:Find('Canvas_Defaut/CardDrawResultDiamondTenButton/CardDrawResultDiamondTenNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DiamondIconTenImage = transform:Find('Canvas_Defaut/CardDrawResultDiamondTenButton/DiamondIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TenLabel = transform:Find('Canvas_Defaut/CardDrawResultDiamondTenButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.AllOpenImage = transform:Find('Canvas_Defaut/CardDrawResultDiamondTenButton/AllOpenImage').gameObject
	self.maskPanel = transform:Find('Canvas_Defaut/Panel').gameObject

	self.myGame = utility:GetGame()

	self.itemList = {}
	self.allItemList = {}
	self.cardDrawType = {DaoJu = "DaoJu", DiamondOne = "DiamondOne", DiamondTen = "DiamondTen",AllDaoju = "AllDaoju"}
	self.listTrans = self.AwardList.transform
	self.listPosition = self.listTrans.localPosition
	self.gameObject = transform.gameObject

	-- 剩余次数
	self.remainObj = transform:Find('Canvas_Defaut/RemainObj').gameObject
	self.remainLabel = transform:Find('Canvas_Defaut/RemainObj/RemainCount'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 爆炸
	self.baozhaEffect = transform:Find('Canvas_EffectModle/UI_chouka_baozha/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem))
	-- xin
	self.xinEffect = transform:Find('Canvas_EffectModle/UI_chouka_xin1').gameObject
	-- 蛋
	self.modleEffect = transform:Find('Canvas_EffectModle/D_Chouka').gameObject
	-- 模型
	self.changjingModle = transform:Find('Canvas_EffectModle/D_Choukachangjing').gameObject
	-- 火焰
	self.fireEffect = transform:Find('Canvas_EffectModle/UI_Choukachangjing').gameObject
	-- 闪屏
	self.shanpingEffect = transform:Find('Canvas_EffectModle/UI_shanping'):GetComponent(typeof(UnityEngine.Animator))

	local uiCanvas =  transform:Find('Canvas_Defaut'):GetComponent(typeof(UnityEngine.RectTransform))
	uiCanvas.gameObject:SetActive(false)
	local effectFazhenCanvas = transform:Find('Canvas_EffectFaZhen'):GetComponent(typeof(UnityEngine.RectTransform))
	local modelCanvas = transform:Find('Canvas_EffectModle'):GetComponent(typeof(UnityEngine.RectTransform))
	utility.SetRectDefaut(uiCanvas)
	utility.SetRectDefaut(modelCanvas)
	utility.SetRectDefaut(effectFazhenCanvas)

	self.uiCanvas = uiCanvas.gameObject
	self.fazhenCanvas = effectFazhenCanvas.gameObject
end


function CardDrawResultCls:RegisterControlEvents()
	-- 注册 CardDrawResultDiamondOneButton 的事件
	self.__event_button_onCardDrawResultDiamondOneButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardDrawResultDiamondOneButtonClicked, self)
	self.CardDrawResultDiamondOneButton.onClick:AddListener(self.__event_button_onCardDrawResultDiamondOneButtonClicked__)

	-- 注册 CardDrawResultDiamondTenButton 的事件
	self.__event_button_onCardDrawResultDiamondTenButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardDrawResultDiamondTenButtonClicked, self)
	self.CardDrawResultDiamondTenButton.onClick:AddListener(self.__event_button_onCardDrawResultDiamondTenButtonClicked__)

	self.__event_ConfirmButton_onCardDrawResultDiamondTenButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked, self)
	self.ConfirmButton.onClick:AddListener(self.__event_ConfirmButton_onCardDrawResultDiamondTenButtonClicked__)
end

function CardDrawResultCls:UnregisterControlEvents()
	-- 取消注册 CardDrawResultDiamondOneButton 的事件
	if self.__event_button_onCardDrawResultDiamondOneButtonClicked__ then
		self.CardDrawResultDiamondOneButton.onClick:RemoveListener(self.__event_button_onCardDrawResultDiamondOneButtonClicked__)
		self.__event_button_onCardDrawResultDiamondOneButtonClicked__ = nil
	end

	-- 取消注册 CardDrawResultDiamondTenButton 的事件
	if self.__event_button_onCardDrawResultDiamondTenButtonClicked__ then
		self.CardDrawResultDiamondTenButton.onClick:RemoveListener(self.__event_button_onCardDrawResultDiamondTenButtonClicked__)
		self.__event_button_onCardDrawResultDiamondTenButtonClicked__ = nil
	end

	if self.__event_ConfirmButton_onCardDrawResultDiamondTenButtonClicked__ then
		self.ConfirmButton.onClick:RemoveListener(self.__event_ConfirmButton_onCardDrawResultDiamondTenButtonClicked__)
		self.__event_ConfirmButton_onCardDrawResultDiamondTenButtonClicked__ = nil
	end
end

function CardDrawResultCls:AddObserver()
    self:RegisterEvent('CardDrawResult',self.CardDrawResult)
    self:RegisterEvent('ResumeCoroutineState',self.ResumeCoroutineState)
    self:RegisterEvent('ResetXunbaolingCount',self.ResetXunbaolingCount)
end

function CardDrawResultCls:RemoveObserver()
	self:UnregisterEvent('CardDrawResult',self.CardDrawResult)
	self:UnregisterEvent('ResumeCoroutineState',self.ResumeCoroutineState)
	self:UnregisterEvent('ResetXunbaolingCount',self.ResetXunbaolingCount)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function AllDaojuDispose(self)
	if self.XunbaolingCount ~= 0 then
		self:HideItem(1,self.count)
   	end
end

local function DaojuDispose(self)
	if self.XunbaolingCount ~= 0 then
		self:HideItem(1,self.count)
   	end
end

local function CheckIsHideItem(self,limit)
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local diamond = userData:GetDiamond()
    local result = false
    if diamond >= tonumber(limit) then
    	result = true
    end
    return result
end

function CardDrawResultCls:OnCardDrawResultDiamondOneButtonClicked()
	--CardDrawResultDiamondOneButton控件的点击事件处理
	if self.isShowResult then
		return true
	end

	if self.cardType == self.cardDrawType.DaoJu or self.cardType == self.cardDrawType.AllDaoju then
		DaojuDispose(self)
		self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDaojuChooseRequest())
	elseif self.cardType == self.cardDrawType.DiamondOne then
		self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseRequest())
		local result = CheckIsHideItem(self,CardDrawStringTable[6])
		if result then
			self:HideItem(1,self.count)
		end
	elseif self.cardType == self.cardDrawType.DiamondTen then
		self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseRequest())
		local result = CheckIsHideItem(self,CardDrawStringTable[6])
		if result then
			self:HideItem(1,self.count)
		end
	end
end

function CardDrawResultCls:OnCardDrawResultDiamondTenButtonClicked()
	--CardDrawResultDiamondTenButton控件的点击事件处理
	--self:AddChild(self.item)
	if self.isShowResult then
		return true
	end
	if self.cardType == self.cardDrawType.DaoJu or self.cardType == self.cardDrawType.AllDaoju then
		AllDaojuDispose(self)
		self.count = 0
		self.cardType = self.cardDrawType.AllDaoju
		self.myGame:SendNetworkMessage( require"Network/ServerService".UseAllTreasureRequest())
	elseif self.cardType == self.cardDrawType.DiamondOne then
		self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseTenRequest())
		local result = CheckIsHideItem(self,CardDrawStringTable[7])
		if result then
			self:HideItem(1,self.count)
		end
	elseif self.cardType == self.cardDrawType.DiamondTen then
		self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseTenRequest())
		local result = CheckIsHideItem(self,CardDrawStringTable[7])
		if result then
			self:HideItem(1,self.count)
		end
	end
end

function CardDrawResultCls:OnConfirmButtonClicked()
	--local sceneManager = self.myGame:GetSceneManager()
    --sceneManager:PopScene()
    if self.isShowResult then
		return true
	end
	self:HideItem(1,self.count)

	local guideMgr = utility.GetGame():GetGuideManager()
	guideMgr:AddGuideEvnt(kGuideEvnt_DiamondDrawTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_DiamondDraw)
	if self.cardType == self.cardDrawType.DiamondOne then
		guideMgr:AddGuideEvnt(kGuideEvnt_Draw2MainPanel)
	end
	guideMgr:SortGuideEvnt()
	guideMgr:ShowGuidance()
    self:Close()
end

------------------------------------------------------------------------
local function ChangeTargetButtonEnabled(targetButton,isEnabled)
	targetButton.interactable = isEnabled
end 

local function AddAwardItem(self)
	coroutine.step(1)
	if self.cardType == self.cardDrawType.AllDaoju then
		self:CreateAllAwardItem(#self.msg.items)
	end

	self:InitCompent(self.cardType)
	self.isShowResult = true
	for i=1,self.count do

		local isHeroShow = false
		
		if self.cardType == self.cardDrawType.DaoJu or self.cardType == self.cardDrawType.DiamondOne then
			self.itemList[i]:OnResetInfo(self.msg.item,self.remainCount,self.AddCardDict,function (result)
				isHeroShow = result
				if isHeroShow then
					coroutine.step(1)
					self:SetActive(false)
				end
				self:AddChild(self.itemList[i])
			end)
			
		elseif self.cardType == self.cardDrawType.DiamondTen then
			self.itemList[i]:OnResetInfo(self.msg.item[i],self.remainCount,self.AddCardDict,function (result)
				isHeroShow = result
				if isHeroShow then
					coroutine.step(1)
					self:SetActive(false)
				end
				self:AddChild(self.itemList[i])
			end)
			coroutine.wait(0.5)

		elseif self.cardType == self.cardDrawType.AllDaoju then
			local node = self.allItemList[i]
			self.allItemList[i]:OnResetInfo(self.msg.items[i],self.remainCount,self.AddCardDict,function (result)
				isHeroShow = result
				if isHeroShow then
					coroutine.step(1)
					self:SetActive(false)
				end
				self:AddChild(node)
			end)
			
			coroutine.step(1)
			self.AwardListScroll.verticalNormalizedPosition = 0
			
			coroutine.wait(0.4)
		end

		if isHeroShow then
			coroutine.yield()
			coroutine.wait(0.5)
		end
	
	end
	self.isShowResult = false
	self.maskPanel:SetActive(false)
end

function CardDrawResultCls:ResumeCoroutineState()
	self:SetActive(true)
	if coroutine.resume ~= nil then
		coroutine.resume (self.coroutineState)
	end
end

local function CheckFirstIsCard(self)
	-- 检查第一个是否是整卡
	local id
	if self.cardType == self.cardDrawType.DiamondTen then
		id = self.msg.item[1].itemID
	elseif self.cardType == self.cardDrawType.AllDaoju then
		id = self.msg.items[1].itemID
	else
		id = self.msg.item.itemID
	end
	local gametool = require "Utils.GameTools"
	local _,_,_,_,itype = gametool.GetItemDataById(id)
	local result = (itype == "Role")
	return result
end

local function DelaySetCanvasShow(self)
	coroutine.wait(1)
	self.uiCanvas:SetActive(true)
	self.fazhenCanvas:SetActive(true)
end

local function CoroutinuePlayEffect(self)
	coroutine.step(1)
	self.uiCanvas:SetActive(false)
	self.fazhenCanvas:SetActive(false)
	self.baozhaEffect:Play()
	self.xinEffect:SetActive(true)
	self.modleEffect:SetActive(true)
	self.changjingModle:SetActive(true)
	self.fireEffect:SetActive(true)
	self.shanpingEffect.gameObject:SetActive(true)
	coroutine.wait(4.9)
	--coroutine.step(8)

	-- 闪屏
	self.shanpingEffect:SetTrigger("Play")
	self.baozhaEffect:Play()
	self.changjingModle:SetActive(false)
	self.xinEffect:SetActive(false)
	self.modleEffect:SetActive(false)
	self.fireEffect:SetActive(false)	
	coroutine.step(18)
	self.shanpingEffect.gameObject:SetActive(false)
	local result = CheckFirstIsCard(self)
	if result then
		-- coroutine.start(DelaySetCanvasShow,self)
		self:StartCoroutine(DelaySetCanvasShow)
	else		
		self.uiCanvas:SetActive(true)
		self.fazhenCanvas:SetActive(true)
	end
	self.coroutineState = self:StartCoroutine(AddAwardItem)
end 

function CardDrawResultCls:CardDrawResult(msg,count,cardType,xunbaolingCount,remainCount,AddCardDict)
	self.msg = msg
	self.count = count
	self.cardType = cardType
	self.xunbaolingCount = xunbaolingCount
	self.remainCount = remainCount
	self.AddCardDict = AddCardDict
	--coroutine.start(CoroutinuePlayEffect,self)
	self:StartCoroutine(CoroutinuePlayEffect)
end

local function CoroutineResetCount(self,cardType,count)
	while (not self:IsReady()) do
			coroutine.step(1)
		end

	if cardType == "DaoJu" or cardType == "AllDaoju" then
		self.DiamondOneLabel.text = "剩余寻宝令:"..tostring(count)
	end
end

function CardDrawResultCls:ResetXunbaolingCount(cardType,count)
	self.XunbaolingCount = count
	-- coroutine.start(CoroutineResetCount,self,cardType,count)
	self:StartCoroutine(CoroutineResetCount, cardType, count)
end

function CardDrawResultCls:InitAwardItem()
	local count = 10
	for i=1,count do
		self.itemList[i] = require"GUI/CardDrawResultAward".New(self.AwardList.transform)
	end
end

function CardDrawResultCls:CreateAllAwardItem(count)
	for i=1,count do
		self.allItemList[i] = require"GUI/CardDrawResultAward".New(self.AwardList.transform)
		--self:AddChild(self.allItemList[i])
	end
end

function CardDrawResultCls:InitCompent(cardType,count)
	if cardType == self.cardDrawType.DiamondTen then
		self.AwardList.enabled = true
		self.DiamondIconOneImage.gameObject:SetActive(true)
		self.DiamondIconTenImage.gameObject:SetActive(true)
		self.DiamondTenLabel.gameObject:SetActive(true)
		self.TenLabel.text = "十连抽"
		self.DiamondOneLabel.text = CardDrawStringTable[6]
		self.remainObj:SetActive(true)
		self.remainLabel.text = string.format("%s%s%s",CardDrawStringTable[4],self.remainCount,CardDrawStringTable[5])
	elseif cardType == self.cardDrawType.DiamondOne then
		self.AwardList.enabled = false
		self.DiamondIconOneImage.gameObject:SetActive(true)
		self.DiamondIconTenImage.gameObject:SetActive(true)
		self.DiamondTenLabel.gameObject:SetActive(true)
		self.TenLabel.text = "十连抽"
		self.DiamondOneLabel.text = CardDrawStringTable[6]
		self.remainObj:SetActive(true)
		self.remainLabel.text = string.format("%s%s%s",CardDrawStringTable[4],self.remainCount,CardDrawStringTable[5])
	elseif cardType == self.cardDrawType.DaoJu then
		self.AwardList.enabled = false
	
		self.DiamondTenLabel.gameObject:SetActive(false)
		self.DiamondIconOneImage.gameObject:SetActive(false)
		self.DiamondIconTenImage.gameObject:SetActive(false)
		self.remainObj:SetActive(false)
		self.TenLabel.text = "全部开启"
	elseif cardType == self.cardDrawType.AllDaoju then
		self.AwardList.enabled = true
		self.DiamondTenLabel.gameObject:SetActive(false)
		self.DiamondIconOneImage.gameObject:SetActive(false)
		self.DiamondIconTenImage.gameObject:SetActive(false)
		self.remainObj:SetActive(false)
		self.TenLabel.text = "全部开启"
		self.maskPanel:SetActive(true)		
	end

	if self.count > 10 then
		self.AwardListScroll.enabled = true
		self.AwardListContentSize.enabled = true
	else
		if cardType == self.cardDrawType.AllDaoju then
			self.AwardList.childAlignment = UnityEngine.TextAnchor.MiddleCenter
		else
			self.AwardList.childAlignment = UnityEngine.TextAnchor.UpperLeft
		end

		self.AwardListScroll.enabled = false
	end
end

function CardDrawResultCls:HideItem(start,count)
	if self.cardType == self.cardDrawType.AllDaoju then
		for i = start , count do
			self.AwardListContentSize.enabled = false
			self:RemoveChild(self.allItemList[i],true)
		end
	else
		for i = start , count do
			self:RemoveChild(self.itemList[i],true)
		end 
	end
end

function CardDrawResultCls:SetActive(active)
	self.gameObject:SetActive(active)
end


return CardDrawResultCls