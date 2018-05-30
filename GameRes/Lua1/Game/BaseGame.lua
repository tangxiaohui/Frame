require "Collection.OrderedDictionary"

require "Framework.Subsystems.UIManager"

local subsystemGUID = require "Framework.SubsystemGUID"

BaseGame = Class(LuaObject)
-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function InitDefaultSystems(self)
    local EventManagerClass = require "Framework.Subsystems.EventManager"
    local ScheduleManagerClass = require "Framework.Subsystems.ScheduleManager"
    local UIManagerClass = require "Framework.Subsystems.UIManager"
    local SceneManagerClass = require "Framework.Subsystems.SceneManager"
    local LocalDataManagerClass = require "Framework.Subsystems.LocalDataManager"
    local AudioManagerClass = require "Framework.Subsystems.AudioManager"
    local VideoManagerClass = require "Framework.Subsystems.VideoPlayerManager"
    local DataCacheClass = require "Framework.Subsystems.DataCacheManager"

    self:AddSubsystem(DataCacheClass.New())
    self:AddSubsystem(EventManagerClass.New())
    self:AddSubsystem(ScheduleManagerClass.New())
    self:AddSubsystem(UIManagerClass.New())
    self:AddSubsystem(SceneManagerClass.New())
    self:AddSubsystem(LocalDataManagerClass.New())
    self:AddSubsystem(AudioManagerClass.New())
    self:AddSubsystem(VideoManagerClass.New())
end

-----------------------------------------------------------------------
--- 获取常用组件
-------------------------------------------------------------------------
function BaseGame:GetLocalDataManager()
    return self:GetSubsystem(subsystemGUID.LocalDataManager)
end

function BaseGame:GetDataCacheManager()
    return self:GetSubsystem(subsystemGUID.DataCacheManager)
end

function BaseGame:GetUIManager()
    return self:GetSubsystem(subsystemGUID.UIManager)
end

function BaseGame:GetSceneManager()
    return self:GetSubsystem(subsystemGUID.SceneManager)
end

function BaseGame:GetScheduleManager()
    return self:GetSubsystem(subsystemGUID.ScheduleManager)
end

function BaseGame:GetEventManager()
    return self:GetSubsystem(subsystemGUID.EventManager)
end

function BaseGame:GetAudioManager()
    return self:GetSubsystem(subsystemGUID.AudioManager)
end

function BaseGame:GetVideoPlayerManager()
    return self:GetSubsystem(subsystemGUID.VideoPlayerManager)
end
-----------------------------------------------------------------------
--- 构造
-----------------------------------------------------------------------
function BaseGame:Ctor()
    self.subsystems = OrderedDictionary.New()
end

local function StartupAllSystems(self)
    local count = self.subsystems:Count()
    for i = 1, count do
        local entry = self.subsystems:GetEntryByIndex(i)
        if entry ~= nil then
            entry:Startup()
        end
    end
end

local function ShutdownAllSystems(self)
    local count = self.subsystems:Count()
    for i = count, 1, -1 do
        local entry = self.subsystems:GetEntryByIndex(i)
        if entry ~= nil then
            entry:Shutdown()
        end
    end
    self.subsystems:Clear()
end

function BaseGame:Start()
    InitDefaultSystems(self)
    self:InitCustomSystems()
    StartupAllSystems(self)
    if self.OnStart ~= nil then
        self:OnStart()
    end
end

function BaseGame:Close()
    print('Game Closing!')
    if self.OnClose ~= nil then
        self:OnClose()
    end
    ShutdownAllSystems(self)
    print('Game Closed!')
end

-----------------------------------------------------------------------
--- Mono相关
-----------------------------------------------------------------------
function BaseGame:Update()
    local count = self.subsystems:Count()
    for i = 1, count do
        local entry = self.subsystems:GetEntryByIndex(i)
        if entry ~= nil then
            entry:Update()
        end
    end

    self:OnUpdate()
end

-----------------------------------------------------------------------
--- 可让子类重载
-----------------------------------------------------------------------
function BaseGame:InitCustomSystems()
end

function BaseGame:OnUpdate()

end

-----------------------------------------------------------------------
--- 操作组件函数
-----------------------------------------------------------------------
function BaseGame:AddSubsystem(system)
    if system == nil then
        print('system is nil')
        return
    end

    local guid = system:GetGuid()
    if guid == nil or guid == 0 then
        error('guid must larger than zero! unexpected: ' .. tostring(guid))
    end

    if self.subsystems:Contains(guid) then
        print(string.format('the guid (%s) is in the dict already!', tostring(guid)))
        return
    end

    self.subsystems:Add(guid, system)
end

function BaseGame:GetSubsystem(guid)
    return self.subsystems:GetEntryByKey(guid)
end

-----------------------------------------------------------------------
--- 发消息
-----------------------------------------------------------------------
function BaseGame:DispatchEvent(name, cipher, ...)
    self:GetEventManager():PostNotification(name, cipher, ...)
end

function BaseGame:DispatchEventReversely(name, cipher, ...)
    self:GetEventManager():PostNotificationReversely(name, cipher, ...)
end

function BaseGame:RegisterEvent(key, table, func, cipher)
    self:GetEventManager():AddObserver(key, table, func, cipher)
end

function BaseGame:UnregisterEvent(key, table, func, cipher)
    self:GetEventManager():RemoveObserver(key, table, func, cipher)
end