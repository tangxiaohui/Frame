local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local SkipButtonNode = Class(BaseNodeClass)

local function InitControls(self)
    -- debug_print("InitControls......")
    self.skipButtonImage = self.skipButton.image

    self.skipButtonObject = self.skipButton.gameObject
    self.skipButtonObject:SetActive(false)
end

local function OnDelayEnd(self)
    self.skipButtonObject:SetActive(false)
end

local function OnDelay(self)
    coroutine.wait(6)
    OnDelayEnd(self)
end

local function OnMainButtonClicked(self)
    -- debug_print("OnMainButtonClicked......")

    self.skipButtonObject:SetActive(true)
    self:StopAllCoroutines()
    self:StartCoroutine(OnDelay)
end

local function OnSkipButtonClicked(self)
    -- debug_print("OnSkipButtonClicked......")
    self:StopAllCoroutines()
    OnDelayEnd(self)
    self.skipDelegate:Invoke()
end

local function RegisterEvents(self)
    self.__event_mainButtonClicked__ = UnityEngine.Events.UnityAction(OnMainButtonClicked, self)
    self.mainButton.onClick:AddListener(self.__event_mainButtonClicked__)

    self.__event_skipButtonClicked__ = UnityEngine.Events.UnityAction(OnSkipButtonClicked, self)
    self.skipButton.onClick:AddListener(self.__event_skipButtonClicked__)
end

local function UnregisterEvents(self)
    if self.__event_mainButtonClicked__ then
        self.mainButton.onClick:RemoveListener(self.__event_mainButtonClicked__)
        self.__event_mainButtonClicked__ = nil
    end

    if self.__event_skipButtonClicked__ then
        self.skipButton.onClick:RemoveListener(self.__event_skipButtonClicked__)
        self.__event_skipButtonClicked__ = nil
    end
end

function SkipButtonNode:Ctor(mainButton, skipButton)
    self.mainButton = mainButton
    self.skipButton = skipButton
    -- debug_print("id1", self.mainButton:GetInstanceID(), self.skipButton:GetInstanceID())
    self.skipDelegate = LuaDelegate.New()
end

function SkipButtonNode:SetCallback(t, func)
    self.skipDelegate:Set(t, func)
end

function SkipButtonNode:OnInit()
    -- debug_print("OnInit......")
    InitControls(self)
end

function SkipButtonNode:OnEnter()
    SkipButtonNode.base.OnEnter(self)
    -- debug_print("SkipButtonNode:OnEnter......")
    RegisterEvents(self)
end

function SkipButtonNode:OnExit()
    SkipButtonNode.base.OnExit(self)
    -- debug_print("SkipButtonNode:OnExit......")
    UnregisterEvents(self)
end

return SkipButtonNode