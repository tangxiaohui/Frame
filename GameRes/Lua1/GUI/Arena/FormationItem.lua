local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local FormationItemCls = Class(BaseNodeClass)

function FormationItemCls:Ctor(parent,index,notCall)
	self.parent = parent
	self.index = index
	-- 是否可以点击
	self.notCall = notCall
	self.callback = LuaDelegate.New()
end

function FormationItemCls:GetDataId()
    return self.data:GetId()
end

function FormationItemCls:GetData()
    return self.data
end

function FormationItemCls:GetUid()
	return self.uid
end

function FormationItemCls:SetIndex(index)
	self.index = index
end
----------------------------------------------------------------------
function FormationItemCls:SetCallback(table, func)
    self.callback:Set(table, func)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function FormationItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/HeroCardItem', function(go)
		self:BindComponent(go,false)
	end)
end

function FormationItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function FormationItemCls:OnResume()
	-- 界面显示时调用
	FormationItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function FormationItemCls:OnPause()
	-- 界面隐藏时调用
	FormationItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function FormationItemCls:OnEnter()
	-- Node Enter时调用
	FormationItemCls.base.OnEnter(self)
end

function FormationItemCls:OnExit()
	-- Node Exit时调用
	FormationItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function FormationItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.gameObject = transform.gameObject
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Base.interactable = not self.notCall

	self.HeadFrame1 = transform:Find('Base/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HeadIcon = transform:Find('Base/CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LvLabel = transform:Find('Base/LeftBase/LevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LvLabel.gameObject:SetActive(true)

	self.OnSelectState = transform:Find('Base/OnMultiSelect').gameObject

	self.starFrame = transform:Find('Base/CharacterStars')
	-- 隐藏
	transform:Find('Base/BottomInfo').gameObject:SetActive(false)

	-- 种族图标
	self.raceIcon = transform:Find('Base/RaceIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.raceIcon.gameObject:SetActive(true)

	-- 等级底图
	self.LevelBottomImage = transform:Find('Base/LeftBase'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 改名
	if self.index ~= nil then
		transform.gameObject.name = tostring(self.index)
	end
	
	self.RarityImage = transform:Find('Base/Rarity'):GetComponent(typeof(UnityEngine.UI.Image))
end


function FormationItemCls:RegisterControlEvents()
	-- 注册 Base 的事件
	self.__event_button_onBaseClicked__ = UnityEngine.Events.UnityAction(self.OnBaseClicked, self)
	self.Base.onClick:AddListener(self.__event_button_onBaseClicked__)
end


function FormationItemCls:UnregisterControlEvents()
	-- 取消注册 Base 的事件
	if self.__event_button_onBaseClicked__ then
		self.Base.onClick:RemoveListener(self.__event_button_onBaseClicked__)
		self.__event_button_onBaseClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function FormationItemCls:OnBaseClicked()
	--Base控件的点击事件处理
	if self.cardHp ~= nil and self.cardHp <= 0 then
		return
	end

	 self.callback:Invoke(self.uid,self.index,self.OnSelected)
end


------------------------------------------------------------------------

function FormationItemCls:GetMajorAttr()
	return self.majorAttr
end

function FormationItemCls:GetColor()
	return self.color
end

function FormationItemCls:GetLv()
	return self.lv
end

function FormationItemCls:OnShow(active)
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

local function DelayResetView(self)
	--加载完 刷新
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local gameTool = require "Utils.GameTools"

	local id = self.data:GetId()
	local _,_,name,icon = gameTool.GetItemDataById(id)
	
	-- 名字
	--self.NameLabel.text = name
	self.LvLabel.text = self.data:GetLv()

	--设置星星
	local starCount = self.data:GetStar()
	local rarity = self.data:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
	-- gameTool.AutoSetRoleStar(self.starFrame,starCount)

	local PropUtility = require "Utils.PropUtility"
    self.HeadFrame1.color = PropUtility.GetRGBColorValue(self.data:GetColor())

	-- 设置头像
	utility.LoadSpriteFromPath(icon,self.HeadIcon)

	-- 设置种族
	utility.LoadRaceIcon(self.data:GetRace(),self.raceIcon)
end


function FormationItemCls:ResetView(data)
	-- 刷新显示
	self.data = data
	self.uid = data:GetUid()
	
	self.majorAttr = self.data:GetMajorAttr()
	
	self.color = self.data:GetColor()
	self.lv = self.data:GetLv()
	self:StartCoroutine(DelayResetView)
	--coroutine.start(DelayResetView,self)
	--HeadIcon
	--LvLabel
	--Attribute
	--NameLabel
	--stars

end

local function DelayResetViewByData(self,data)
	--加载完 刷新
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local gameTool = require "Utils.GameTools"

	local id = data.cardID
	local _,cardData,name,icon = gameTool.GetItemDataById(id)
	
	-- 名字
	--self.NameLabel.text = name
	self.LvLabel.text = data.cardLevel

	--设置星星
	local starCount = cardData:GetStar()
	local rarity = cardData:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
	-- gameTool.AutoSetRoleStar(self.starFrame,starCount)
	--SetStarShow(self,starCount)

	-- 设置头像
	utility.LoadSpriteFromPath(icon,self.HeadIcon)

	local PropUtility = require "Utils.PropUtility"
    self.HeadFrame1.color = PropUtility.GetRGBColorValue(data.cardColor)
	
	-- 设置种族
	utility.LoadRaceIcon(cardData:GetRace(),self.raceIcon)

end


function FormationItemCls:ResetViewByData(data)
	-- 根据服务器返回的消息设置显示
	self:StartCoroutine(DelayResetViewByData,data)
	--coroutine.start(DelayResetViewByData,self,data)
end




function FormationItemCls:GetSelectedState()
	-- 获取选中状态
	return self.OnSelected
end



local function DelayResetSelectedState(self,state)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.OnSelectState:SetActive(state)
	
end



function FormationItemCls:ResetSelectedState(state)
	-- 卡牌上阵状态
	self.OnSelected = state
	self:StartCoroutine(DelayResetSelectedState,state)
	--coroutine.start(DelayResetSelectedState,self,state)
end


function FormationItemCls:ChangeBagIndex(index)
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
    	local images = self.starFrame.transform:GetComponentsInChildren(typeof(UnityEngine.UI.Image))
    	local count = images.Length
    	for i = 0, count - 1 do
        	images[i].material = grayMaterial
    	end
		-- 头像
		self.HeadIcon.material = grayMaterial

		-- 颜色
		self.HeadFrame1.material = grayMaterial

		-- 种族
		self.raceIcon.material = grayMaterial
		self.LevelBottomImage.material = grayMaterial
end

function FormationItemCls:SetCardHp(hp)
	-- 设置血量是否死亡
	self.cardHp = hp
	if hp <= 0 then
		-- coroutine.start(SetDieState,self)
		self:StartCoroutine(SetDieState)
	end
end

return FormationItemCls