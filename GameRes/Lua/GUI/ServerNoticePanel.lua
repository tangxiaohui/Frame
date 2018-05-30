
local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Const"
require "System.LuaDelegate"

local ServerNoticePanel = Class(BaseNodeClass)

local function InitControls(self)
    local transform = self:GetUnityTransform()

    self.titleButtonScrollView = transform:Find("Base/TitleButtonScrollView"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
    self.titleButtonParentTransform = transform:Find("Base/TitleButtonScrollView/Viewport/Content")

    self.textComponent = transform:Find("Base/Scroll View/Viewport/Content/Text"):GetComponent(typeof(UnityEngine.UI.Text))

    self.closeButton = transform:Find("Base/ReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))
end

local function OnCloseButtonClicked(self)
    self:InactiveComponent()
    self.callbackOnClose:Invoke(true)
    self.callbackOnClose:Clear()
end

function ServerNoticePanel:Ctor(transform)
    self.callbackOnClose = LuaDelegate.New()
    self.currentSelectedButton = nil
    self.isInitialized = false
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

local function OnRefreshContent( self, noticeData )
    -- debug_print("noticeData", noticeData:GetContent())
    self.textComponent.text = string.gsub(noticeData:GetContent(), "\\n", "\n")
end

local function OnTitleButtonClicked(self, button)
    if self.currentSelectedButton ~= button then
        self.currentSelectedButton:SetSelect(false)
        self.currentSelectedButton = button
        self.currentSelectedButton:SetSelect(true)
        OnRefreshContent(self, button:GetData())
    end
end

local function OnDelayWait(self)
    repeat
        coroutine.step()
    until(self:IsReady())

    coroutine.step()
    self:ActiveComponent()
    self.isInitialized = true
end

local function Init(self)
    -- 创建控件
    local NoticeTitleButtonClass = require "GUI.Notice.NoticeTitleButton"

    local gameServer = self:GetGame():GetGameServer()
    local total = gameServer:GetServerNoticeCount()
    for i = 1, total do

        local noticeData = gameServer:GetServerNoticeByIndex(i)
        local instance = NoticeTitleButtonClass.New()
        instance:SetCallback(self, OnTitleButtonClicked)
        instance:SetData(noticeData)
        instance:SetParentTransform(self.titleButtonParentTransform)

        if i == 1 then
            instance:SetSelect(true)
            self.currentSelectedButton = instance
        end

        self:AddChild(instance)
    end
    if self.currentSelectedButton ~= nil then
        OnRefreshContent(self, self.currentSelectedButton:GetData())
    end
    self:StartCoroutine(OnDelayWait)
end

function ServerNoticePanel:Show(table, func)
    if type(table) == "table" and type(func) == "function" then
        self.callbackOnClose:Set(table, func)
    end

    if not self.isInitialized then
        Init(self)
        return
    end
    self:ActiveComponent()
end

function ServerNoticePanel:OnResume()
    self.__event_closeButtonClicked__ = UnityEngine.Events.UnityAction(OnCloseButtonClicked, self)
    self.closeButton.onClick:AddListener(self.__event_closeButtonClicked__)
end

function ServerNoticePanel:OnPause()
    if self.__event_closeButtonClicked__ then
        self.closeButton.onClick:RemoveListener(self.__event_closeButtonClicked__)
        self.__event_closeButtonClicked__ = nil
    end
end

return ServerNoticePanel
