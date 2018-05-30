local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local TowerAttrItem = Class(BaseNodeClass)
require "LUT.StringTable"

function TowerAttrItem:Ctor(parent,index,attrId,attrNum)
	self.parent = parent
	self.index = index
	local data = require "StaticData.Tower.RandomAdd":GetData(attrId)
	self.attrId = data:GetTypeid()
	self.attrNum = attrNum
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
local function GetPrefabNameByIndex(index)
	local temp
	if index == 1 then
		temp = ""
	elseif index == 2 then
		temp = "Add"
	end
	return string.format("%s%s","UI/Prefabs/Attribute",temp)
end

function TowerAttrItem:OnInit()
	-- 加载界面(只走一次)
	local path = GetPrefabNameByIndex(self.index)
	utility.LoadNewGameObjectAsync(path, function(go)
		self:BindComponent(go,false)
	end)
end

function TowerAttrItem:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function TowerAttrItem:OnResume()
	-- 界面显示时调用
	TowerAttrItem.base.OnResume(self)
	self:LoadItem()
end

function TowerAttrItem:OnPause()
	-- 界面隐藏时调用
	TowerAttrItem.base.OnPause(self)
end

function TowerAttrItem:OnEnter()
	-- Node Enter时调用
	TowerAttrItem.base.OnEnter(self)
end

function TowerAttrItem:OnExit()
	-- Node Exit时调用
	TowerAttrItem.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function TowerAttrItem:InitControls()
	local transform = self:GetUnityTransform() 
	self.AttrLabel = transform:Find("AttrLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.NumLabel = transform:Find("NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
end

function TowerAttrItem:LoadItem()
	-- debug_print(EquipStringTable[self.attrId])
	if self.index == 1 then
		self.AttrLabel.text = EquipStringTable[tonumber(self.attrId)].."<color=#74ff21>+"..string.format("%.1f",self.attrNum).."%</color>"
	else
		self.AttrLabel.text = EquipStringTable[tonumber(self.attrId)].."+"..string.format("%.1f",self.attrNum).."%"
	end
	-- self.NumLabel.text = "+"..string.format("%.1f",self.attrNum).."%"
end

return TowerAttrItem