local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"

local FixedStrHeight = 10
local FixedItemHeight = 90

local StrategyItemNodeCls = Class(BaseNodeClass)

function StrategyItemNodeCls:Ctor(parent)
	self.parent = parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function StrategyItemNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Spoil', function(go)
		self:BindComponent(go,false)
	end)
end

function StrategyItemNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function StrategyItemNodeCls:OnResume()
	-- 界面显示时调用
	StrategyItemNodeCls.base.OnResume(self)
end

function StrategyItemNodeCls:OnPause()
	-- 界面隐藏时调用
	StrategyItemNodeCls.base.OnPause(self)
end

function StrategyItemNodeCls:OnEnter()
	-- Node Enter时调用
	StrategyItemNodeCls.base.OnEnter(self)
end

function StrategyItemNodeCls:OnExit()
	-- Node Exit时调用
	StrategyItemNodeCls.base.OnExit(self)
end



-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function StrategyItemNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	self.element = transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))

	-- 背景图片
	self.itemBgImage = transform:Find('SpoilArea'):GetComponent(typeof(UnityEngine.UI.Image))
	self.itemBgRect = transform:Find('SpoilArea'):GetComponent(typeof(UnityEngine.RectTransform))

	-- 名称
	self.nameLabel = transform:Find('SpoilArea/Title/BigLibrarySpeciesTextNameLable'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 内容
	self.contentLabel = transform:Find('SpoilArea/Base/SpoilTextLable'):GetComponent(typeof(UnityEngine.UI.Text))
	self.contentRect = transform:Find('SpoilArea/Base'):GetComponent(typeof(UnityEngine.RectTransform))

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function DelayRefreshItem(self,id)
	-- 刷新
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	local staticData = require "StaticData.BigLibrary.BigLibraryStrategy" :GetData(id)

	local name = staticData:GetName()
	self.nameLabel.text = name

	local temp = staticData:GetDesc()

	local desc = string.gsub(temp,"\\n","\n")
	self.contentLabel.text = desc

	local labelPreferredHeight = self.contentLabel.preferredHeight  + FixedStrHeight

	local contentRectSize = self.contentRect.sizeDelta
	contentRectSize.y = labelPreferredHeight
	self.contentRect.sizeDelta  = contentRectSize

	local itemBgRectSize = self.itemBgRect.sizeDelta
	itemBgRectSize.y = labelPreferredHeight + FixedItemHeight
	self.itemBgRect.sizeDelta = itemBgRectSize

	self.element.preferredHeight = labelPreferredHeight + FixedItemHeight


end

function StrategyItemNodeCls:RefreshItem(id)
	-- coroutine.start(DelayRefreshItem,self,id)
	self:StartCoroutine(DelayRefreshItem, id)
end

function StrategyItemNodeCls:GetActive()
	return self.active
end

function StrategyItemNodeCls:SetActive(active)
	self.active = active
end

return StrategyItemNodeCls