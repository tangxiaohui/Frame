local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
require "Const"

local GemNodeCls = Class(BaseNodeClass)

function GemNodeCls:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
end

function GemNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GemNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function GemNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function GemNodeCls:OnResume()
	-- 界面显示时调用
	GemNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function GemNodeCls:OnPause()
	-- 界面隐藏时调用
	GemNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function GemNodeCls:OnEnter()
	-- Node Enter时调用
	GemNodeCls.base.OnEnter(self)
end

function GemNodeCls:OnExit()
	-- Node Exit时调用
	GemNodeCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GemNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	self.transform = transform
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	-- 数量
	self.countLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 名称
	self.nameLabel = transform:Find('ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.nameLabel.gameObject:SetActive(true)
	local nameRect = self.nameLabel.rectTransform
	nameRect.anchorMax = Vector2(0.5,1)
	nameRect.anchorMin = Vector2(0.5,1)
	nameRect.offsetMax = Vector2(0,26)
	nameRect.offsetMin = Vector2(0,0)

	-- 图标
	self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 颜色
	self.colorFrame = transform:Find('Frame')
	-- 信息按钮
	self.infoButton = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 选中状态
	self.OnSelectState = transform:Find('OnSelectState').gameObject
	-- 属性
	self.attrLabel = transform:Find('ItemAttributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.attrLabel.gameObject:SetActive(true)
end


function GemNodeCls:RegisterControlEvents()
	-- 注册 BackpackRetrunButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function GemNodeCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function DelayResetItem(self,data,index,tempuid)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.transform:SetSiblingIndex(index -1)

	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local iType = data:GetKnapsackItemType()

	local id
	local count = 1
	local uid = tempuid
	if iType == KKnapsackItemType_Item then
		id = data:GetId()
		count = data:GetNumber()
		uid = data:GetUid()
	elseif iType == KKnapsackItemType_EquipNormal then
		id = data:GetEquipID()
	end
	self.uid = uid

	local itemInfoData,itemData,name,iconPath,itemType = gametool.GetItemDataById(id)
	-- 名字
	self.nameLabel.text = name
	-- 图片
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)
	-- 颜色
	local color = data:GetColor()
	PropUtility.AutoSetRGBColor(self.colorFrame,color)
	
	if count ~= 1 then
		self.countLabel.text = count
		self.countLabel.gameObject:SetActive(true)
	end

	-- 属性
	local attrStr
	if iType == KKnapsackItemType_Item then
		attrStr = itemInfoData:GetDesc()
	elseif iType == KKnapsackItemType_EquipNormal then
		local dict,mainId = data:GetEquipAttribute()
		local _,_,mainStr = gametool.GetEquipInfoStr(dict,mainId)
		attrStr = mainStr
	end
	self.attrLabel.text = attrStr
	
	self.id = id
	self.iType = iType
end

function GemNodeCls:ResetItem(data,uid,index)
	-- 重置数据
	self.data = data
	self.uid = uid
	self.index = index
	-- coroutine.start(DelayResetItem,self,data,index,uid)
	self:StartCoroutine(DelayResetItem, data,index,uid)
end

function GemNodeCls:SetCheckedState(state)
	self.OnSelectState:SetActive(state)
	self.state = state
end

function GemNodeCls:OnInfoButtonClicked()
	self.callback:Invoke(self.id,self.index,self.iType,self.state)
end

function GemNodeCls:SetNodeActive(active)
	self.active = active
end

function GemNodeCls:GetNodeActive()
	return self.active
end

function GemNodeCls:GetData()
	return self.data
end

function GemNodeCls:GetUid()
	return self.uid
end

function GemNodeCls:GetItype()
	return self.iType
end

function GemNodeCls:GetId()
	return self.id
end

function GemNodeCls:GetIndex()
	return self.index
end

return GemNodeCls