local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"
require "System.LuaDelegate"
local TweenUtility = require "Utils.TweenUtility"
local UnityEngine_Color = UnityEngine.Color
--------------------------------------------------------------

local DropdownNodeCls = Class(BaseNodeClass)

function DropdownNodeCls:Ctor(parent,index,key,name,redDot)
	self.parent = parent
	self.index = index
	self.key = key
	self.name = name
	self.redDot = redDot

	self.callback = LuaDelegate.New()
end


function DropdownNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end

function DropdownNodeCls:OnInit()
	-- 加载界面(只走一次)

	utility.LoadNewGameObjectAsync('UI/Prefabs/DropdownToggle', function(go)
		self:BindComponent(go,false)
	end)
end

function DropdownNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	--self:LinkComponent(self.parent)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function DropdownNodeCls:OnResume()
	-- 界面显示时调用
	DropdownNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:OnInitContent()
	self:InitVariables()
end

function DropdownNodeCls:OnPause()
	-- 界面隐藏时调用
	DropdownNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function DropdownNodeCls:OnEnter()
	-- Node Enter时调用
	DropdownNodeCls.base.OnEnter(self)
	-- self:GetRedDot()
end

function DropdownNodeCls:OnExit()
	-- Node Exit时调用
	DropdownNodeCls.base.OnExit(self)
end

function DropdownNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	-- 垂直布局
	self.layoutElement = transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))
	
	-- toggle
	self.toggleButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
	
	-- 背景
	self.Background = transform:Find('Background/Base')
	self.BackgroundObj = self.Background.gameObject
	
	-- content高度
	self.contentHiget = self.Background:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.y
	self.layoutElement.preferredHeight = self.contentHiget
	-- Label
	self.nameLabel = transform:Find('Label'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 选中状态图片
	self.StateChangeImage = self.Background:GetComponent(typeof(UnityEngine.UI.Image))	
	
	--红点
	self.redDotImage = transform:Find('RedDotImage').gameObject
	
end

function DropdownNodeCls:InitVariables()
	self.DisState = false
	self:ScheduleUpdate(self.Update)

	self.isGradually = false
	self.totalTime = 0.5
    self.passedTime = 0
end

function DropdownNodeCls:RegisterControlEvents()

	self.__event_button_ontoggleButtonClicked__ = UnityEngine.Events.UnityAction(self.OntoggleButtonClicked, self)
    self.toggleButton.onClick:AddListener(self.__event_button_ontoggleButtonClicked__)
end

function DropdownNodeCls:UnregisterControlEvents()
	
	if self.__event_button_ontoggleButtonClicked__ then
		self.toggleButton.onClick:RemoveListener(self.__event_button_ontoggleButtonClicked__)
		self.__event_button_ontoggleButtonClicked__ = nil
	end
end

function DropdownNodeCls:Update()
	if not self.isGradually then
        return
    end

    local t = self.passedTime / self.totalTime

    local finished = false
    if t >= 1 then
        t = 1
        finished = true
    end

    local alpha 

    if self.DisState then
    	alpha = TweenUtility.Linear(0, 1 ,t)
    else
    	alpha = TweenUtility.Linear(1, 0 ,t)
    end
    
    self.StateChangeImage.color.a = alpha
   	local color = UnityEngine_Color(1,1,1,alpha)
    self.StateChangeImage.color = color
    self.passedTime = self.passedTime + Time.unscaledDeltaTime

    if finished then
    	self.isGradually = false
    end

end

-----------------------------------------------------------------------
---
-----------------------------------------------------------------------
function DropdownNodeCls:OnInitContent()
	-- 初始化内容
	self.nameLabel.text = self.name
	
end

function DropdownNodeCls:GetRedDot()
	self.redDotImage:SetActive(self.redDot)
end

--红点更新
function DropdownNodeCls:SetRedDot(redDot)
	for i=1,#redDot do
		if self.key == redDot[i].sonid then
			-- debug_print(self.redDotImage)
			self.redDot = (redDot[i].red == 1)
			if self.redDotImage ~= nil then
				self.redDotImage:SetActive(self.redDot)
			end
			break
		end
	end
	
end


function DropdownNodeCls:OntoggleButtonClicked()
	if self.DisState then
		return
	end

	self.DisState = not self.DisState
	self.callback:Invoke(self.index,self,self.key)
end

function DropdownNodeCls:ChangeStateGraduallyCtrl()
	-- 控制渐变
	self.isGradually = true
	self.passedTime = 0 
end


function DropdownNodeCls:ChangeState()
	-- 改变自己的状态显示
	self.BackgroundObj:SetActive(self.DisState)
end

function DropdownNodeCls:ChangeShowState()
	self.DisState = true
end

function DropdownNodeCls:GetActiveState()
	-- 获取自己的状态
	return self.DisState
end

function DropdownNodeCls:ClearSelectedState()
	-- 清楚选中状态
	self.DisState = false
	local color = UnityEngine_Color(1,1,1,0)
    self.StateChangeImage.color = color
end


function DropdownNodeCls:GetPreferredHeight()
	return self.contentHiget
end

return DropdownNodeCls