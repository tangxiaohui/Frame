require "Const"
local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

-- 图标路径
local itemIconPath = "UI/Atlases/Icon/AchievementIcon/"


local AchievementItemNodeCls = Class(BaseNodeClass)

function AchievementItemNodeCls:Ctor(parent,itemWidth,itemHigh)
	self.parent = parent
	self.itemWidth = itemWidth
	self.itemHigh = itemHigh

	self.callback = LuaDelegate.New()
end


function AchievementItemNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function AchievementItemNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BigLibrarySpecies', function(go)
		self:BindComponent(go,false)
	end)
end

function AchievementItemNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
	self:LoadAwardItem()

end

function AchievementItemNodeCls:OnResume()
	-- 界面显示时调用
	AchievementItemNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function AchievementItemNodeCls:OnPause()
	-- 界面隐藏时调用
	AchievementItemNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function AchievementItemNodeCls:OnEnter()
	-- Node Enter时调用
	AchievementItemNodeCls.base.OnEnter(self)
end

function AchievementItemNodeCls:OnExit()
	-- Node Exit时调用
	AchievementItemNodeCls.base.OnExit(self)
end



-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function AchievementItemNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	self.transform = transform
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	
	-- -- 信息按钮
	self.infoButton = transform:GetComponent(typeof(UnityEngine.UI.Button))

	--  图标
	self.iconImage = transform:Find('Icon/BigLibrarySpeciesIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 名称
	self.titleNameLabel = transform:Find('Title/BigLibrarySpeciesNameLable'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 描述
	self.descriptionLabel = transform:Find('Title/BigLibrarySpeciesBriefingLable'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 进度图片
	self.progressImage = transform:Find('ProgressBar/BigLibrarySpeciesProgressBarMask/Base'):GetComponent(typeof(UnityEngine.UI.Image)) 

	-- 进度文字
	self.progressLabel = transform:Find('ProgressBar/BigLibrarySpeciesProgressBarNumLable'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 状态图标
	self.stateObj = transform:Find('BigLibrarySpeciesStatus').gameObject

	-- 标题背景图片
	self.lineImage = transform:Find('Title/Line'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 图标
	self.colorFrame = transform:Find('Icon/Frame')
	self.colorImage = transform:Find('Icon/Frame/Image'):GetComponent(typeof(UnityEngine.UI.Image))


	-- 奖励挂点
	self.AwardPoint = transform:Find('Award')

	-- 灰色材质球
	self.GrayMaterial = self.titleNameLabel.material
	-- hsl材质球
	self.hslMaterial = self.colorImage.material
end


function AchievementItemNodeCls:RegisterControlEvents()
	-- -- 注册 BackpackRetrunButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function AchievementItemNodeCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function DelayOnBind(self,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.rectTransform.sizeDelta = Vector2(self.itemWidth,self.itemHigh)

	self:ResetItem(data)
end

function AchievementItemNodeCls:OnBind(data,index,args)

	self.data = data
	self.index = index	
	--self.args = args
	
	--coroutine.start(DelayOnBind,self,data)
	self:StartCoroutine(DelayOnBind, data)

end

function AchievementItemNodeCls:OnUnbind()
	
end
--------------------------------------------------------------------------
local function DelayResetPosition(self,position)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.rectTransform.anchoredPosition = position
end

function AchievementItemNodeCls:ResetPosition(position)
	coroutine.start(DelayResetPosition,self,position)
end

function AchievementItemNodeCls:ResetItem(data)
	-- 重置数据
	--if dataType
	--data = {}
	--data.id = 2010101
	--data.done = 5
	--data.state = 0

	self.ItemID = data:GetId()

	local staticData = require "StaticData.BigLibrary.BigLibraryAchievement":GetData(self.ItemID)
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local itemIconStr = staticData:GetIcon()
	local itemIcon = string.format("%s%s",itemIconPath,itemIconStr)

	utility.LoadSpriteFromPath(itemIcon,self.iconImage)
	local iconColor = staticData:GetIconColor()
	self.colorImage.color = PropUtility.GetRGBColorValue(iconColor)

	local name = staticData:GetName()
	self.titleNameLabel.text = name

	local description = staticData:GetDescription()	
	self.descriptionLabel.text = description

	-- 完成需要
	local limit = staticData:GetLimit()
	local tatgetType = staticData:GetType()
	if tatgetType == 7 or tatgetType == 2 or tatgetType == 23 or tatgetType == 21 or tatgetType == 5 then
		limit = 1
	end

	-- 当前完成
	local currDone = data:GetDone()

	local awardId = staticData:GetItemID_1()
	local awardCount = staticData:GetItemNum_1()
	self.AwardNode:RefreshItem(awardId,awardCount)

	-- 完成状态
	local state = data:GetState()
	self.state = state
	self.key = data:GetKey()
	local material

	if state == 0 then
		material = self.GrayMaterial
		self.titleNameLabel.material = utility.GetGrayMaterial("Text")
		self.AwardNode:SetIconMaterial(material,true)
		self.colorImage.material = material
		self.colorImage.color = UnityEngine.Color(1,1,1,1)
	elseif state == 1 then
		material = utility.GetCommonMaterial()
		self.titleNameLabel.material = utility.GetCommonMaterial("Text")
		self.AwardNode:SetIconMaterial(material,false)
		self.colorImage.material = self.hslMaterial
		currDone = limit
	elseif state == 2 then
		self.titleNameLabel.material = utility.GetCommonMaterial("Text")
		material = utility.GetCommonMaterial()
		self.AwardNode:SetIconMaterial(material,false)
		self.colorImage.material = self.hslMaterial
		currDone = limit
	end

	-- 设置材质球
	
	self.lineImage.material = material
	
	self.iconImage.material = material
	self.progressImage.material = material

	-- 设置完成状态
	local completed =  (state == 2)
	self.stateObj:SetActive(completed)

	-- 设置进度
	self.progressImage.fillAmount = currDone / limit
	self.progressLabel.text = string.format("%s%s%s",currDone,"/",limit)

end

function AchievementItemNodeCls:LoadAwardItem()
	-- 加载奖励预制体
	local nodeCls = require "GUI.Task.TaskAwardItem"
	self.AwardNode = nodeCls.New(self.AwardPoint,true)
	self:AddChild(self.AwardNode)

	local scale = Vector3(0.80,0.80,0.80)
	self.AwardNode:SetLocalScale(scale)
	self.AwardNode:SetNameLabelPosition()
end

----------------------------------------------------------------
function AchievementItemNodeCls:OnInfoButtonClicked()
	--coroutine.start(DelayItemClickedCallback,self)
	if self.state == 1 then
		self.callback:Invoke(self.ItemID,self.key)
	end
end



return AchievementItemNodeCls