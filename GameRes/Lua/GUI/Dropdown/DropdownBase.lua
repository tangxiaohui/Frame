local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"
require "System.LuaDelegate"
local TweenUtility = require "Utils.TweenUtility"


local OnSelectedRotation = Vector3(0,0,0) 
local OnNormorRotation = Vector3(0,0,90) 
local bottomBorder = 20
--------------------------------------------------------------

local DropdownBaseCls = Class(BaseNodeClass)

function DropdownBaseCls:Ctor(parent,index,title,subDirectory,titleSpacing,contentSpacing,redDot)
	self.parent = parent
	self.index = index
	self.title = title	
	self.subDirectory = subDirectory
	self.titleSpacing = titleSpacing
	self.contentSpacing = contentSpacing
	self.redDot = redDot

	self.callback = LuaDelegate.New()
end


function DropdownBaseCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end

function DropdownBaseCls:OnInit()
	-- 加载界面(只走一次)

	utility.LoadNewGameObjectAsync('UI/Prefabs/DropdownBase', function(go)
		self:BindComponent(go,false)
	end)
end

function DropdownBaseCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitVariables()
	self:InitControls()
end

function DropdownBaseCls:OnResume()
	-- 界面显示时调用
	DropdownBaseCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:OnInitContent()
end

function DropdownBaseCls:OnPause()
	-- 界面隐藏时调用
	DropdownBaseCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function DropdownBaseCls:OnEnter()
	-- Node Enter时调用
	DropdownBaseCls.base.OnEnter(self)
end

function DropdownBaseCls:OnExit()
	-- Node Exit时调用
	DropdownBaseCls.base.OnExit(self)
end

function DropdownBaseCls:InitControls()
	local transform = self:GetUnityTransform()
	-- 垂直布局
	self.layoutElement = transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))

	-- 标题按钮
	self.titleButton = transform:Find('TittleButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	-- 标题高度
	self.titleHight = transform:Find('TittleButton'):GetComponent(typeof(UnityEngine.UI.Image)).preferredHeight
	self.titleRealHight = self.titleHight + self.titleSpacing

	-- 标题文字
	self.titleLabel = transform:Find('TittleButton/TittleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 状态Image
	self.activeStateImage = transform:Find('TittleButton/ActiveState')

	-- toggle Group
	self.toggleGroup = transform:Find('TittleButton/ToggleGroup'):GetComponent(typeof(UnityEngine.UI.ToggleGroup))

	self.toggleGroup.transform.localPosition = Vector3(0,-self.titleRealHight,0)

	-- togele layout
	self.toggleGroupLayout = transform:Find('TittleButton/ToggleGroup'):GetComponent(typeof(UnityEngine.UI.VerticalLayoutGroup))
	self.toggleSpacing = self.toggleGroupLayout.spacing
	
	--红点
	self.redDotImage = self.titleButton.transform:Find('RedDotImage').gameObject

	self.isGradually = false
	self.totalTime = 0.2
    self.passedTime = 0
    self:ScheduleUpdate(self.Update)
end

function DropdownBaseCls:InitVariables()
	self.activeState = false
end

function DropdownBaseCls:RegisterControlEvents()

    self.__event_button_onTitleButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTitleButtonClicked, self)
    self.titleButton.onClick:AddListener(self.__event_button_onTitleButtonClicked__)
end

function DropdownBaseCls:UnregisterControlEvents()
	
	 if self.__event_button_onTitleButtonClicked__ then
        self.titleButton.onClick:RemoveListener(self.__event_button_onTitleButtonClicked__)
        self.__event_button_onTitleButtonClicked__ = nil
    end
end

function DropdownBaseCls:Update()
	if not self.isGradually then
        return
    end

    local t = self.passedTime / self.totalTime

    local finished = false
    if t >= 1 then
        t = 1
        finished = true
    end

  
   	local height = TweenUtility.EaseOutBack(0, self.totalPreferredHeight ,t)

    self.layoutElement.preferredHeight = height
    self.passedTime = self.passedTime + Time.unscaledDeltaTime

    if finished then
    	self.isGradually = false
    end
end
-----------------------------------------------------------------------
---
-----------------------------------------------------------------------
local function DelayWaitSetPreferredHeight(self)
	while (not self:IsReady()) do
    	coroutine.step(1)
   	end

   	local totalHeight = 0

   	local length = #self.toggleNodes
	for i = 1 ,length do
		local node = self.toggleNodes[i]
		local height = node:GetPreferredHeight()
		totalHeight = totalHeight + height
	end

	totalHeight = totalHeight + self.toggleSpacing * (length -1) + self.titleSpacing + bottomBorder
	self.totalPreferredHeight = totalHeight
	self.passedTime = 0
	self.isGradually = true
end 


function DropdownBaseCls:OnInitContent()
	-- 初始化内容
	self:RefreshTitle()
	self:RefreshStateIcon(self.activeState)
	self.layoutElement.preferredHeight = self.titleRealHight
	-- if self.redDot ~= nil then
		-- for i = 1,#self.redDot do
			-- self.redDotImage:SetActive(self.redDot[i].red == 1)
		-- end
	-- else
		-- self.redDotImage:SetActive(false)
	-- end
	print("初始化内容",self.titleHight)
	local nodeCls = require "GUI.Dropdown.DropdownToggle"

	-- node
	self.toggleNodes = {}
	local keys = self.subDirectory:GetKeys()
	local length = #keys
	for i = 1 ,length do
		local redDot = false
		local key = keys[i]
		local value = self.subDirectory:GetEntryByKey(key)
		-- if self.redDot ~= nil then
			-- for j = 1,#self.redDot do
				-- if self.redDot[j].sonid == key then
					-- redDot = (self.redDot[j].red == 1)
					-- self.redDotImage:SetActive(redDot)
					-- break
				-- end
			-- end
		-- else
			-- self.redDotImage:SetActive(false)
		-- end
		local node = nodeCls.New(self.toggleGroup.transform,i,key,value,redDot)
		node:SetCallback(self,self.OnToggleCallBack)
		
		self.toggleNodes[#self.toggleNodes + 1] = node
	end	
end


function DropdownBaseCls:RefreshTitle()
	-- 刷新标题
	self.titleLabel.text = self.title
end

--更新红点
function DropdownBaseCls:SetRedDot(redDot,first)
	if redDot ~= nil then
		self.redDot = redDot
		for j = 1,#redDot do
			if redDot[j].faName == self.title then
				-- debug_print("DropRedDot:"..redDot[j].faName.."名字："..self.title)
				-- redDot = (self.redDot[j].red == 1)
				-- debug_print(redDot[j].red)
				self.redDotImage:SetActive(redDot[j].red == 1)
				break
			end
		end
		if first then
			self:SetRedDotImage(redDot)
		end
	else
		self.redDotImage:SetActive(false)
	end
end

function DropdownBaseCls:RefreshStateIcon(active)
	-- 设置选中状态
	if active then
		self.activeStateImage.localEulerAngles = OnSelectedRotation
	else
		self.activeStateImage.localEulerAngles = OnNormorRotation
	end
end


function DropdownBaseCls:OnTitleButtonClicked()
	-- 标题按钮点击事件
	if self.isGradually then
		return
	end

	self.activeState = not self.activeState
	self:OnClickedEvent()
	self.callback:Invoke(self.index,self)
end

function DropdownBaseCls:GetActiveState()
	return self.activeState
end


function DropdownBaseCls:OnClickedEvent()
	-- 点击触发事件
	if self.activeState then
		self:OnExpandEvent()
	else
		self:OnHideEvent()
	end
end

function DropdownBaseCls:OnExpandEvent()
	-- 展开
	local length = #self.toggleNodes

	for i = 1 ,length do
		local node = self.toggleNodes[i]
		self:AddChild(node)
		
	end
	if length > 0 then 
		if self.currToggle == nil or self.currToggle == 0 then
			local node = self.toggleNodes[1]
	
			node:OntoggleButtonClicked()
			self.currToggle = 1
		else
			local node = self.toggleNodes[self.currToggle]
	
			node:OntoggleButtonClicked()
		end
	end
	self.activeState = true
	self:RefreshStateIcon(self.activeState)
	-- coroutine.start(DelayWaitSetPreferredHeight,self)
	self:StartCoroutine(DelayWaitSetPreferredHeight)
	self:SetRedDotImage(self.redDot)
end

function DropdownBaseCls:SetRedDotImage(redDot)
	if self.toggleNodes ~= nil then
		-- debug_print("aaaaaaaaaaaaa"..#self.toggleNodes)
		local count = #self.toggleNodes
		if redDot ~= nil then
			for i=1,count do
				self.toggleNodes[i]:SetRedDot(redDot)
			end
		end
	end
end

function DropdownBaseCls:OnHideEvent()
	-- 收起
	local length = #self.toggleNodes
	for i = 1 ,length do
		local node = self.toggleNodes[i]

		local active = node:GetActiveState()
		if active then
			node:ClearSelectedState()
		end		
		self:RemoveChild(node)
	end

	self.layoutElement.preferredHeight = self.titleRealHight
	self.currToggle = nil
	self.activeState = false
	self:RefreshStateIcon(self.activeState)
end

function DropdownBaseCls:OnToggleCallBack(index,node,key)
	-- 子控件状态改变
	-- debug_print("aaaaaaaaaaaa"..index)
	self:OnToggleStateChangeCtrl(index,node)
	self.callback:Invoke(self.index,self,key)
end

function DropdownBaseCls:OnToggleStateChangeCtrl(index,node)
	-- 状态管理 
	
	if self.currToggle ~= index then

		if self.currToggle ~= nil then
			self.toggleNodes[self.currToggle]:ClearSelectedState()
		end

		node:ChangeStateGraduallyCtrl()
		self.currToggle = index
	else

		local nodeActive = node:GetActiveState()
		if not nodeActive then
			node:ChangeStateGraduallyCtrl()
		else
			return
		end
	end

end



return DropdownBaseCls