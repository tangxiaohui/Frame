local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local FormationGYJItemCls = Class(BaseNodeClass)

function FormationGYJItemCls:Ctor(parent,index)
	self.parent = parent
	self.index = index
	self.callback = LuaDelegate.New()
end

function FormationGYJItemCls:GetDataId()
    return self.id
end

function FormationGYJItemCls:GetData()
    return self.data
end

function FormationGYJItemCls:GetUid()
	return self.uid
end
----------------------------------------------------------------------
function FormationGYJItemCls:SetCallback(table, func)
    self.callback:Set(table, func)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function FormationGYJItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GYJHeroCardItem', function(go)
		self:BindComponent(go,false)
	end)
end

function FormationGYJItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function FormationGYJItemCls:OnResume()
	-- 界面显示时调用
	FormationGYJItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function FormationGYJItemCls:OnPause()
	-- 界面隐藏时调用
	FormationGYJItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function FormationGYJItemCls:OnEnter()
	-- Node Enter时调用
	FormationGYJItemCls.base.OnEnter(self)
end

function FormationGYJItemCls:OnExit()
	-- Node Exit时调用
	FormationGYJItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function FormationGYJItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.gameObject = transform.gameObject
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Base.interactable = not self.notCall

	self.HeadFrame1 = transform:Find('Base/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HeadIcon = transform:Find('Base/CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LvLabel = transform:Find('Base/LeftBase/LevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LvLabel.gameObject:SetActive(true)

	--self.AttributesImage = transform:Find('Base/Attribute1'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.NameLabel = transform:Find('Base/CardBasisHeroListNameLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OnSelectState = transform:Find('Base/OnMultiSelect').gameObject

	self.star_1 = transform:Find('Base/CharacterStars/RankStarIcon1').gameObject
	self.star_2 = transform:Find('Base/CharacterStars/RankStarIcon2').gameObject
	self.star_3 = transform:Find('Base/CharacterStars/RankStarIcon3').gameObject
	self.star_4 = transform:Find('Base/CharacterStars/RankStarIcon4').gameObject
	self.star_5 = transform:Find('Base/CharacterStars/RankStarIcon5').gameObject

	self.stars = {self.star_1,self.star_2,self.star_3,self.star_4,self.star_5}

	-- 隐藏
	transform:Find('Base/BottomInfo').gameObject:SetActive(false)

	-- 种族图标
	self.raceIcon = transform:Find('Base/RaceIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.raceIcon.gameObject:SetActive(true)

	-- 等级底图
	self.LevelBottomImage = transform:Find('Base/LeftBase'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 金币
	self.costObj = transform:Find('Base/Cost').gameObject
	self.costLabel = transform:Find('Base/Cost/CostValue'):GetComponent(typeof(UnityEngine.UI.Text))
	
	--ssr
	self.RarityImage = transform:Find("Base/Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
end


function FormationGYJItemCls:RegisterControlEvents()
	-- 注册 Base 的事件
	self.__event_button_onBaseClicked__ = UnityEngine.Events.UnityAction(self.OnBaseClicked, self)
	self.Base.onClick:AddListener(self.__event_button_onBaseClicked__)
end


function FormationGYJItemCls:UnregisterControlEvents()
	-- 取消注册 Base 的事件
	if self.__event_button_onBaseClicked__ then
		self.Base.onClick:RemoveListener(self.__event_button_onBaseClicked__)
		self.__event_button_onBaseClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function FormationGYJItemCls:OnBaseClicked()
	--Base控件的点击事件处理
	if self.cardHp ~= nil and self.cardHp == 0 then
		return
	end

	self.callback:Invoke(self.uid,self.playerID,self.price, self.pos, self.OnSelected)
end


------------------------------------------------------------------------

function FormationGYJItemCls:GetMajorAttr()
	return self.majorAttr
end

function FormationGYJItemCls:GetColor()
	return self.color
end

function FormationGYJItemCls:GetLv()
	return self.lv
end

function FormationGYJItemCls:OnShow(active)
	self.gameObject:SetActive(active)
end

local function SetStarShow(self,starCount)
	-- 设置星星
	if starCount <= #self.stars then
		for i=1,starCount do

			self.stars[i]:SetActive(true)
		end

		for i=starCount + 1,#self.stars do
			
			self.stars[i]:SetActive(false)
		end
	end
end

local function DelayResetView(self,data,showPrice)
	--加载完 刷新
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local gameTool = require "Utils.GameTools"

	local _,staticdata,name,icon = gameTool.GetItemDataById(self.id)
	
	-- 名字
	--self.NameLabel.text = name
	self.LvLabel.text = self.lv

	--设置星星
	-- local starCount = staticdata:GetStar()
	-- SetStarShow(self,starCount)
	
	--ssr
	local rarity = staticdata:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)

	local PropUtility = require "Utils.PropUtility"
    self.HeadFrame1.color = PropUtility.GetColorValue(self.color)

	-- 设置头像
	utility.LoadSpriteFromPath(icon,self.HeadIcon)

	-- 设置种族
	utility.LoadRaceIcon(staticdata:GetRace(),self.raceIcon)

	self.costObj:SetActive(showPrice)
	if showPrice then
		self.costLabel.text = data.price
	end
	self.OnSelectState:SetActive(self.OnSelected)
end

function FormationGYJItemCls:UpdatePos(pos)
	self.pos = pos
end

function FormationGYJItemCls:ResetView(data,showPrice)
	-- 刷新显示
	self.color = data.cardColor
	self.lv = data.cardLevel
	self.uid = data.cardUID
	print(self.id,data.cardID,"刷新显示")
	self.id = data.cardID
	self.playerID = data.playerID
	self.price = data.price
	self.data = data
	self.pos = data.cardPos
	-- coroutine.start(DelayResetView,self,data,showPrice)
	self:StartCoroutine(DelayResetView, data,showPrice)
end

function FormationGYJItemCls:GetSelectedState()
	-- 获取选中状态
	return self.OnSelected
end

local function DelayResetSelectedState(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	local state = self.OnSelected
	self.OnSelectState:SetActive(state)
end

function FormationGYJItemCls:ResetSelectedState(state)
	-- 卡牌上阵状态
	self.OnSelected = state
	-- coroutine.start(DelayResetSelectedState,self)
	self:StartCoroutine(DelayResetSelectedState)
end

function FormationGYJItemCls:ChangeBagIndex(index)
	self.index = index
end

local function SetDieState(self)
	-- 设置死亡状态
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	-- 死亡状态
		local grayMaterial = utility.GetGrayMaterial()

		-- 名字
		self.LvLabel.material = utility.GetGrayMaterial("Text")

		-- 星星
		for i=1,#self.stars do
			local image = self.stars[i]:GetComponent(typeof(UnityEngine.UI.Image))
			image.material = grayMaterial
		end

		-- 头像
		self.HeadIcon.material = grayMaterial

		-- 颜色
		self.HeadFrame1.material = grayMaterial

		-- 种族
		self.raceIcon.material = grayMaterial
		self.LevelBottomImage.material = grayMaterial
end

function FormationGYJItemCls:SetCardHp(hp)
	-- 设置血量是否死亡
	self.cardHp = hp
	if hp == 0 then
		-- coroutine.start(SetDieState,self)
		self:StartCoroutine(SetDieState)
	end
end

return FormationGYJItemCls