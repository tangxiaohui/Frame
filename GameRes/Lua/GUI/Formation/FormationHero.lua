local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
require "Const"
local TweenUtility = require "Utils.TweenUtility"

ElvenrobotIndex = 5
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local FormationHeroCls = Class(BaseNodeClass)

function FormationHeroCls:Ctor(parent,index)
	self.parent = parent
	self.index = index
	--print("index======================",self.index )
	self.callback = LuaDelegate.New()
end
-----------------------------------------------------------------------
function FormationHeroCls:SetCallback(table, func)
    self.callback:Set(table, func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function FormationHeroCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/FormationHero', function(go)
		self:BindComponent(go,false)
	end)
end

function FormationHeroCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function FormationHeroCls:OnResume()
	-- 界面显示时调用
	FormationHeroCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function FormationHeroCls:OnPause()
	-- 界面隐藏时调用
	FormationHeroCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function FormationHeroCls:OnEnter()
	-- Node Enter时调用
	FormationHeroCls.base.OnEnter(self)
end

function FormationHeroCls:OnExit()
	-- Node Exit时调用
	FormationHeroCls.base.OnExit(self)
end

function FormationHeroCls:Update()
	if not self.isGradually then
        return
    end

    local t = self.passedTime / self.totalTime

    local finished = false
    if t >= 1 then
        t = 1
        finished = true
    end

  	
   	local x = TweenUtility.EaseOutBack(self.origenalPos.x, self.targetPos.x ,t)
   	local y = TweenUtility.EaseOutBack(self.origenalPos.y, self.targetPos.y ,t)


   	self.rectTransform.anchoredPosition = Vector2(x,y)
    self.passedTime = self.passedTime + Time.unscaledDeltaTime

    if finished then
    	self.isGradually = false
    end
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------


-- # 控件绑定
function FormationHeroCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Base.interactable = false
	self.BaseDragUnit = transform:GetComponent(typeof(UnityEngine.UI.DragUnit))
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))

	-- HeroAttributes
	self.attrObj = transform:Find('Base/CardTypeBase').gameObject
	self.AttributesLabel = transform:Find('Base/CardTypeBase/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.attrObj.gameObject:SetActive(false)

	--名字
	self.nameObj = transform:Find('Base/NameBlackBase').gameObject
	self.nameObj:SetActive(false)
	self.NameLabel = transform:Find('Base/NameBlackBase/FormationHeroNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 头像
	self.FormationHeroNilHeroIcon = transform:Find('Base/IconMask/FormationHeroNilHeroIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.FormationHeroLock = transform:Find('Base/FormationHeroLock').gameObject
	self.HeadIconSprite = self.FormationHeroNilHeroIcon.sprite
	self.IconRect = self.FormationHeroNilHeroIcon:GetComponent(typeof(UnityEngine.RectTransform))

	-- 星星
	self.starsObj = transform:Find('Base/FormationHeroStarLayout').gameObject
	self.starsObj:SetActive(false)
	self.star_1 = transform:Find('Base/FormationHeroStarLayout/FormationHeroStarIcon1').gameObject
	self.star_2 = transform:Find('Base/FormationHeroStarLayout/FormationHeroStarIcon2').gameObject
	self.star_3 = transform:Find('Base/FormationHeroStarLayout/FormationHeroStarIcon3').gameObject
	self.star_4 = transform:Find('Base/FormationHeroStarLayout/FormationHeroStarIcon4').gameObject
	self.star_5 = transform:Find('Base/FormationHeroStarLayout/FormationHeroStarIcon5').gameObject
	
	--ssr 
	self.RarityImage = transform:Find("Base/Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
	self.RarityImage.gameObject:SetActive(false)
	self.stars = {self.star_1,self.star_2,self.star_3,self.star_4,self.star_5}

	--attributes路径
	self.attributesIconPath = {"UI/Atlases/CardBasis/CardBasis_Power","UI/Atlases/CardBasis/CardBasis_Quick","UI/Atlases/CardBasis/CardBasis_Intelligence"}

	local UserDataType = require "Framework.UserDataType"
    self.cardBagData = self:GetCachedData(UserDataType.CardBagData)
    self.gameTool = require "Utils.GameTools"

    self.myGame = utility:GetGame()
    self.eventMgr = self.myGame:GetEventManager()
    self.transform = transform

    -- 
    local mainCanvas = utility:GetUIManager():GetMainUICanvas():GetCanvasTransform():GetComponent(typeof(UnityEngine.Canvas))
    self.canvasScaleFactor = mainCanvas.scaleFactor

    self.isGradually = false
	self.totalTime = 0.2
    self.passedTime = 0
    self:ScheduleUpdate(self.Update)
end

function FormationHeroCls:RegisterControlEvents()
	-- 注册 Base 的事件
	self.__event_button_onBaseClicked__ = UnityEngine.Events.UnityAction(self.OnBaseClicked, self)
	self.Base.onClick:AddListener(self.__event_button_onBaseClicked__)

	self.__event_DragUnit_onBaseDragUnitEnd__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnBaseDragUnitEnd, self)
	self.BaseDragUnit.OnEndDraged:AddListener(self.__event_DragUnit_onBaseDragUnitEnd__)

	self.__event_DragUnit_onBaseDragUnitBegin__ = UnityEngine.Events.UnityAction(self.OnBaseDragUnitBegin, self)
	self.BaseDragUnit.OnBeginDraged:AddListener(self.__event_DragUnit_onBaseDragUnitBegin__)

	self.__event_DragUnit_onBaseDragUniting__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnBaseDragUniting, self)
	self.BaseDragUnit.OnDraging:AddListener(self.__event_DragUnit_onBaseDragUniting__)

end

function FormationHeroCls:UnregisterControlEvents()
		-- 取消注册 Base 的事件
	if self.__event_button_onBaseClicked__ then
		self.Base.onClick:RemoveListener(self.__event_button_onBaseClicked__)
		self.__event_button_onBaseClicked__ = nil
	end

	if self.__event_DragUnit_onBaseDragUnitEnd__ then
		self.BaseDragUnit.OnEndDraged:RemoveListener(self.__event_DragUnit_onBaseDragUnitEnd__)
		self.__event_DragUnit_onBaseDragUnitEnd__ = nil
	end

	if self.__event_DragUnit_onBaseDragUnitBegin__ then
		self.BaseDragUnit.OnBeginDraged:RemoveListener(self.__event_DragUnit_onBaseDragUnitBegin__)
		self.__event_DragUnit_onBaseDragUnitBegin__ = nil
	end

	if self.__event_DragUnit_onBaseDragUniting__ then
		self.BaseDragUnit.OnDraging:RemoveListener(self.__event_DragUnit_onBaseDragUniting__)
		self.__event_DragUnit_onBaseDragUniting__ = nil
	end
end

-----------------------------------------------------------------------

local function SetStarShow(self,starCount)
	-- 设置星星
	self.starsObj:SetActive(true)
	if starCount <= #self.stars then
		for i=1,starCount do

			self.stars[i]:SetActive(true)
		end

		for i=starCount + 1,#self.stars do
			
			self.stars[i]:SetActive(false)
		end
	end
end

local function DelayResetView(self,uid,isLock,formationType,index)
	--加载完 刷新
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local data = self.cardBagData:GetRoleByUid(uid)
	if data == nil then

		if formationType == kLineup_ElvenTree and index == ElvenrobotIndex then
			self:OnClearLock(false)
			data=self:GetElvenTreeRobotData(uid)
		end

	end

	self.data = data 

	local id = data:GetId()
	local _,_,name,icon = self.gameTool.GetItemDataById(id)

	--设置名字
	self.nameObj:SetActive(true)
	self.NameLabel.text = name

	--设置星星
	-- local starCount = data:GetStar()
	--ssr
	local rarity = data:GetRarity()
	if rarity ~= nil then
		self.RarityImage.gameObject:SetActive(true)
		utility.LoadSpriteFromPath(rarity,self.RarityImage)
	end
		
	-- 修改战斗力
	self.power = data:GetPower()
	self.eventMgr:PostNotification('ChangeArenaFightingPower', nil, self.power)

	-- SetStarShow(self,starCount)

	utility.LoadRolePortraitImage(id,self.FormationHeroNilHeroIcon)
	self.IconRect.sizeDelta = Vector2(290,290)
	self.IconRect.anchoredPosition = Vector2(0,0)


	-- 设置majorAttr属性
	self.attrObj.gameObject:SetActive(true)
	local majorAttr = data:GetMajorAttr()
	self.AttributesLabel.text = MajorAttr[majorAttr]
	self.AttributesLabel.color = self.gameTool.GetMajorAttrColor(majorAttr)

	self.BaseDragUnit.enabled = true

end

function FormationHeroCls:GetElvenTreeRobotData(uid)
	-- 获取精灵树五号位信息
	return self.cardBagData:GetGhostRoleByUid(uid)

end


function FormationHeroCls:ResetViewOnFormation(uid,isLock,formationType,index)
	--刷新上阵
	self.uid = uid
	-- coroutine.start(DelayResetView,self,uid,isLock,formationType,index)
	self:StartCoroutine(DelayResetView, uid,isLock,formationType,index)
end
------------雇佣军----------------------------------------------------
local function DelayResetGYJView(self,data,isLock,formationType,index)
	--加载完 刷新
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.data = data 

	local id = data.cardID
	local _,staticData,name,icon = self.gameTool.GetItemDataById(id)

	--设置名字
	self.nameObj:SetActive(true)
	self.NameLabel.text = name

	--设置星星
	-- local starCount = staticData:GetStar()
	
	--ssr
	local rarity = staticData:GetRarity()
	if rarity ~= nil then
		self.RarityImage.gameObject:SetActive(true)
		utility.LoadSpriteFromPath(rarity,self.RarityImage)
	end

	-- 修改战斗力
	self.power = data.zhanli
	self.eventMgr:PostNotification('ChangeArenaFightingPower', nil, self.power)

	-- SetStarShow(self,starCount)

	utility.LoadRolePortraitImage(id,self.FormationHeroNilHeroIcon)
	self.IconRect.sizeDelta = Vector2(220,220)
	self.IconRect.anchoredPosition = Vector2(0,0)


	-- 设置majorAttr属性
	self.attrObj.gameObject:SetActive(true)
	local majorAttr = staticData:GetMajorAttr()
	self.AttributesLabel.text = MajorAttr[majorAttr]
	self.AttributesLabel.color = self.gameTool.GetMajorAttrColor(majorAttr)

	self.BaseDragUnit.enabled = true

end

function FormationHeroCls:ResetViewOnGYJFormation(data,isLock,formationType,index)
	--刷新上阵
	self.uid = data.cardUID
	-- coroutine.start(DelayResetGYJView,self,data,isLock,formationType,index)
	self:StartCoroutine(DelayResetGYJView, data,isLock,formationType,index)
end

function DelayOnClearLock(self,isLock,hintText)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.FormationHeroLock:SetActive(isLock)

	if isLock then
		self.nameObj:SetActive(true)
		-- 替换字符串
		self.NameLabel.text = string.format("%d%s",hintText,"级开启") 
	end
end


function FormationHeroCls:OnClearLock(isLock,hintText)
	
	-- coroutine.start(DelayOnClearLock,self,isLock,hintText)
	self:StartCoroutine(DelayOnClearLock, isLock,hintText)
end

function FormationHeroCls:GetOnFormationState()
	-- 获取上阵状态
	return self.onFormationState
end

function DelayOnChangeState(self,state,InterceptOnly)
	
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.Base.interactable = state
	
	if InterceptOnly then
		self.BaseDragUnit.enabled = false
	end
end

function FormationHeroCls:ChangeOnFormationState(state)
	-- 切换上阵状态
	self.onFormationState = state
	-- coroutine.start(DelayOnChangeState,self,state)
	self:StartCoroutine(DelayOnChangeState, state)
end


function FormationHeroCls:InterceptOnly()
	-- 仅拦截点击事件
	-- coroutine.start(DelayOnChangeState,self,false,true)
	self:StartCoroutine(DelayOnChangeState, false,true)
end

function FormationHeroCls:OnPutOffFormation(state)
	
	-- 下阵操作
	self.FormationHeroNilHeroIcon.sprite = self.HeadIconSprite
	self.IconRect.sizeDelta = Vector2(145,190)
	self.IconRect.anchoredPosition = Vector2(0,-15)

	self.Base.interactable = state
	self.eventMgr:PostNotification('ChangeArenaFightingPower', nil, -self.power)

	-- 隐藏星星
	-- self.starsObj:SetActive(false)
	self.RarityImage.gameObject:SetActive(false)
	--隐藏名字
	self.nameObj:SetActive(false)
	
	-- 隐藏Attributes
	self.attrObj.gameObject:SetActive(false)
	self.BaseDragUnit.enabled = false
end

function FormationHeroCls:OnReturnRectPosion()
	-- 返回位置
	return self.rectPos
end

function FormationHeroCls:OnBaseDragUnitBegin()
	self.eventMgr:PostNotification('BeginDragFormation', nil, self.index)
end

function FormationHeroCls:OnBaseDragUnitEnd(pos)
	self.eventMgr:PostNotification('EndDragFormation', nil, pos)
end

function FormationHeroCls:OnBaseDragUniting(offset)
	self.rectTransform.anchoredPosition  = self.rectTransform.anchoredPosition  + offset/self.canvasScaleFactor
end

function FormationHeroCls:SetAnchoredPositionTween(pos)
	-- 设置位置
	self.origenalPos = self.rectTransform.anchoredPosition
	self.targetPos = pos
	self.passedTime = 0
	self.isGradually = true
end

function FormationHeroCls:SetAnchoredPosition(pos)
	-- 设置位置
	self.rectTransform.anchoredPosition = pos
end


function FormationHeroCls:ChangePosIndex(index)
	-- 交换索引
	self.index = index
end

local function DelaySetSiblingIndex(self,index)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.transform:SetSiblingIndex(index)
end

function FormationHeroCls:SetSiblingIndex(index)
	-- 设置index
	-- coroutine.start(DelaySetSiblingIndex,self,index)
	self:StartCoroutine(DelaySetSiblingIndex, index)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function FormationHeroCls:OnBaseClicked()
	-- 上阵卡牌点击事件
	if self.onFormationState == false then
		return
	end

	self.callback:Invoke(self.index,self.uid)
end


return FormationHeroCls