local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local DailyContinueItem = Class(BaseNodeClass)
require "System.LuaDelegate"
require "LUT.StringTable"

function DailyContinueItem:Ctor(parent,data,index,id,state)
	self.parent = parent
	self.data = data
	self.index = index
	self.id = id
	self.state = state
	self.callback = LuaDelegate.New()
end

function DailyContinueItem:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
local function GetPrefabNameByIndex(index)
	local temp
	if index == 1 then
		temp = "DailyContinueItem"
	elseif index == 2 then
		temp = "DailyContinueFinItem"
	elseif index == 3 then
		temp = "ProgressMilestoneItem"
	end
	return string.format("%s%s","UI/Prefabs/",temp)
end

function DailyContinueItem:OnInit()
	-- 加载界面(只走一次)
	local path = GetPrefabNameByIndex(self.index)
	utility.LoadNewGameObjectAsync(path, function(go)
		self:BindComponent(go,false)
	end)
end

function DailyContinueItem:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function DailyContinueItem:OnResume()
	-- 界面显示时调用
	DailyContinueItem.base.OnResume(self)
	self:RegisterControlEvents()
	self:LoadPanel(self.index,self.id)
end

function DailyContinueItem:OnPause()
	-- 界面隐藏时调用
	DailyContinueItem.base.OnPause(self)
	self:UnregisterControlEvents()
end

function DailyContinueItem:OnEnter()
	-- Node Enter时调用
	DailyContinueItem.base.OnEnter(self)
end

function DailyContinueItem:OnExit()
	-- Node Exit时调用
	DailyContinueItem.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function DailyContinueItem:InitControls()
	local transform = self:GetUnityTransform() 
	self.infoButton = transform:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Button))
	self.text = transform:Find("Label"):GetComponent(typeof(UnityEngine.UI.Text))
	self.doneItem = transform:Find("DoneIcon").gameObject
end

function DailyContinueItem:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
end

function DailyContinueItem:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
end

function DailyContinueItem:OnInfoButtonClicked()
	-- debug("aaaaaaaaaaaa")
	self.callback:Invoke(self.id)
end

--加载界面
function DailyContinueItem:LoadPanel(index,id)
	local data = self.data:GetData(id)
	self:HideItem()
	if index ~= 3 then
		local dataType = data:GetType()
		if dataType == 1 then
			self.text.text = string.format(ActivityStringTable[4],data:GetDayNum())
		end
	else
		self.text.text = data:GetBuyNum()
	end
	if self.state == 1 then
		self.infoButton.gameObject:SetActive(true)
		-- self.infoButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetCommonMaterial()
	elseif self.state == 0 then
		self.doneItem:SetActive(true)
	elseif self.state == 2 then
		self.infoButton.gameObject:SetActive(true)
		-- self.infoButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetCommonMaterial()
	end
end

function DailyContinueItem:HideItem()
	self.doneItem:SetActive(false)
	self.infoButton.gameObject:SetActive(false)
	-- self.infoButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
end


return DailyContinueItem