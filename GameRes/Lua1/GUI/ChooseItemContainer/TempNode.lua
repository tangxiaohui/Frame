local BaseNodeClass = require "GUI.HeroCardItemNode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
require "Const"

local TempNodeCls = Class(BaseNodeClass)

function TempNodeCls:Ctor(parent,itemWidth,itemHigh)
	self.parent = parent
	self.itemWidth = itemWidth
	self.itemHigh = itemHigh

	self.callback = LuaDelegate.New()

	self.mode = kCardItemMode_Got
end

function TempNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end

function TempNodeCls:OnInit()
	utility.LoadNewGameObjectAsync('UI/Prefabs/HeroCardItem', function(go)
		self:BindComponent(go,false)
	end)
end


function TempNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	TempNodeCls.base.OnComponentReady(self)
	self:InitControls()
end

function TempNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))

	self.active = false
end

function TempNodeCls:OnResume()
	TempNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function TempNodeCls:OnPause()
	-- 界面隐藏时调用
	TempNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function TempNodeCls:RegisterControlEvents()
	-- 注册 信息按钮 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.mainButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function TempNodeCls:UnregisterControlEvents()
	-- 取消注册 信息按钮 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.mainButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
-----------------------------------------------------------------------
local function DelayOnBind(self,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.rectTransform.sizeDelta = Vector2(self.itemWidth,self.itemHigh)

	self:ResetItem(data)
end

function TempNodeCls:OnBind(data,index)
	self.index = index
	self.data = data

	print(self.data:GetEquipID(),self.index,"bind ...>>>>>>")
	self:SetID(10000004)
	self:SetLevel(55)
	self:SetColorID(3)
	self:SetStar(5)

	-- coroutine.start(DelayOnBind,self,data)
	self:StartCoroutine(DelayOnBind, data)
end

function TempNodeCls:OnUnbind()
	
end

local function DelayResetPosition(self,position)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.rectTransform.anchoredPosition = position
end

function TempNodeCls:ResetPosition(position)
	-- coroutine.start(DelayResetPosition,self,position)
	self:StartCoroutine(DelayResetPosition, position)
end

function TempNodeCls:ResetItem(data)

end

function TempNodeCls:OnInfoButtonClicked()
	self.active = not self.active
	self.callback:Invoke(self.index,self.active)
end

function TempNodeCls:SetSelectedState(active)
	self.active = active
end

function TempNodeCls:SetNodeActive(active)
	self.active = active
end

function TempNodeCls:GetNodeActive()
	if self.active == nil then
		self.active = false
	end
	return self.active
end




return TempNodeCls