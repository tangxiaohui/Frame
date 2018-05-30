require "Framework.GameSubSystem"
require "Framework.NotificationCenter"

-----------------------------------------------------------------------
--- 类型 & 消息Guid
-----------------------------------------------------------------------
local SceneLoadedGuid = 0x30bef125
local UpdateGuid = 0xeaf48155
local FixedUpdateGuid = 0xb933a31e
local LateUpdateGuid = 0x61fbabf3
local OnFocusGuid = 0x3530b132
local OnPauseGuid = 0x824e1108

-----------------------------------------------------------------------
--- 调度管理
-----------------------------------------------------------------------
local ScheduleManager = Class(GameSubSystem)

function ScheduleManager:Ctor()
    self.internalNotificationCenter = NotificationCenter.New()
end

local function AddObserverImpl(self, guid, table, func)
    self.internalNotificationCenter:AddObserver(guid, table, func)
end

local function RemoveObserverImpl(self, guid, table)
    self.internalNotificationCenter:RemoveObserver(guid, table)
end

-- # SceneLoaded
function ScheduleManager:RegisterOnSceneLoaded(table, func)
    AddObserverImpl(self, SceneLoadedGuid, table, func)
end

function ScheduleManager:UnregisterOnSceneLoaded(table)
    RemoveObserverImpl(self, SceneLoadedGuid, table)
end

-- # Update
function ScheduleManager:RegisterUpdate(table, func)
    AddObserverImpl(self, UpdateGuid, table, func)
end

function ScheduleManager:UnregisterUpdate(table)
    RemoveObserverImpl(self, UpdateGuid, table)
end

-- # FixedUpdate
function ScheduleManager:RegisterFixedUpdate(table, func)
    AddObserverImpl(self, FixedUpdateGuid, table, func)
end

function ScheduleManager:UnregisterFixedUpdate(table)
    RemoveObserverImpl(self, FixedUpdateGuid, table)
end

-- # LateUpdate
function ScheduleManager:RegisterLateUpdate(table, func)
    AddObserverImpl(self, LateUpdateGuid, table, func)
end

function ScheduleManager:UnregisterLateUpdate(table)
    RemoveObserverImpl(self, LateUpdateGuid, table)
end

-- # OnFocus
function ScheduleManager:RegisterOnFocus(table, func)
    AddObserverImpl(self, OnFocusGuid, table, func)
end

function ScheduleManager:UnregisterOnFocus(table)
    RemoveObserverImpl(self, OnFocusGuid, table)
end

-- # OnPause
function ScheduleManager:RegisterOnPause(table, func)
    AddObserverImpl(self, OnPauseGuid, table, func)
end

function ScheduleManager:UnregisterOnPause(table)
    RemoveObserverImpl(self, OnPauseGuid, table)
end

-- # All
function ScheduleManager:UnregisterAll(table)
    RemoveObserverImpl(self, nil, table)
end

-----------------------------------------------------------------------
--- 实现 GameSubSystem 的接口
-----------------------------------------------------------------------
function ScheduleManager:GetGuid()
    return require "Framework.SubsystemGUID".ScheduleManager
end

function ScheduleManager:Startup()
end

function ScheduleManager:Shutdown()
end

function ScheduleManager:Restart()
end

function ScheduleManager:Update()
    -- empty
end

-----------------------------------------------------------------------
--- 给 Global 留的调用函数
-----------------------------------------------------------------------
local function TriggerReversely(self, guid, ...)
    self.internalNotificationCenter:PostNotificationReversely(guid, nil, ...)
end

function ScheduleManager:TriggerOnSceneLoaded(scene, mode)
    TriggerReversely(self, SceneLoadedGuid, scene, mode)
end

function ScheduleManager:TriggerUpdate()
    TriggerReversely(self, UpdateGuid)
end

function ScheduleManager:TriggerFixedUpdate()
    TriggerReversely(self, FixedUpdateGuid)
end

function ScheduleManager:TriggerLateUpdate()
    TriggerReversely(self, LateUpdateGuid)
end

function ScheduleManager:TriggerOnFocus(hasFocus)
    TriggerReversely(self, OnFocusGuid, hasFocus)
end

function ScheduleManager:TriggerOnPause(pauseStatus)
    TriggerReversely(self, OnPauseGuid, pauseStatus)
end

return ScheduleManager