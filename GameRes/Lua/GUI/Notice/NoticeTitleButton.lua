
local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local NoticeTitleButton = Class(BaseNodeClass)

local function SetSelectRightNow(self, isSelect)
	if isSelect then
		self.selectedImage.enabled = true
		self.unselectImage.enabled = false
		self.outlineComponent.enabled = true
		self.textComponent.color = UnityEngine.Color(1, 1, 1, 1)
		self.mainButton.targetGraphic = self.selectedImage
	else
		self.selectedImage.enabled = false
		self.unselectImage.enabled = true
		self.outlineComponent.enabled = false
		self.textComponent.color = UnityEngine.Color(0, 0, 0, 1)
		self.mainButton.targetGraphic = self.unselectImage
	end
end


local function InitControls(self)
	local transform = self:GetUnityTransform()

	self.mainButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
	
	self.selectedImage = transform:Find("Selected"):GetComponent(typeof(UnityEngine.UI.Image))
	self.unselectImage = transform:Find("Unselect"):GetComponent(typeof(UnityEngine.UI.Image))

	self.textComponent = transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.outlineComponent = transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Outline))
end

local function OnMainButtonClicked(self)
	self.callback:Invoke(self)
end

local function RegisterEvents(self)
	-- 注册按钮事件
    self.__event_button_mainButtonClicked__ = UnityEngine.Events.UnityAction(OnMainButtonClicked, self)
    self.mainButton.onClick:AddListener(self.__event_button_mainButtonClicked__)
end

local function UnregisterEvents(self)
	-- 取消注册按钮事件
    if self.__event_button_mainButtonClicked__ then
        self.mainButton.onClick:RemoveListener(self.__event_button_mainButtonClicked__)
        self.__event_button_mainButtonClicked__ = nil
    end
end

function NoticeTitleButton:Ctor()
	self.controlReady = false
	self.selectOnResume = false
	self.callback = LuaDelegate.New()
end

function NoticeTitleButton:OnComponentReady()
	InitControls(self)
end

function NoticeTitleButton:OnInit()
	-- 加载 登录界面
    utility.LoadNewGameObjectAsync('UI/Prefabs/NoticeTitleButton', function(go)
        self:BindComponent(go, false)
    end)
end

function NoticeTitleButton:SetCallback(table, func)
    self.callback:Set(table, func)
end

function NoticeTitleButton:SetData(data)
	self.noticeData = data
end

function NoticeTitleButton:GetData()
	return self.noticeData
end

function NoticeTitleButton:SetParentTransform(transform)
	self.parentTransform = transform
end

function NoticeTitleButton:Clear()
	self.callback:Clear()
	self.textComponent.text = nil
end

function NoticeTitleButton:OnResume()
	NoticeTitleButton.base.OnResume(self)
	RegisterEvents(self)
	self.controlReady = true
	SetSelectRightNow(self, self.selectOnResume)
	self:LinkComponent(self.parentTransform, true)

	self.textComponent.text = self.noticeData:GetTitle()
end

function NoticeTitleButton:OnPause()
	NoticeTitleButton.base.OnPause(self)
	UnregisterEvents(self)
	self.controlReady = false
	self.selectOnResume = false

end

function NoticeTitleButton:SetSelect(isSelect)
	if self.controlReady then
		SetSelectRightNow(self, isSelect)
		return
	end
	self.selectOnResume = isSelect
end


return NoticeTitleButton
