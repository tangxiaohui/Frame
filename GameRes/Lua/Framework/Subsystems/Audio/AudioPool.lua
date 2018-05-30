--
-- User: fenghao
-- Date: 16/06/2017
-- Time: 2:50 PM
--

require "Object.LuaObject"
require "Collection.DataStack"
require "Collection.DataQueue"

local utility = require "Utils.Utility"
local AudioComponentClass = require "Framework.Subsystems.Audio.AudioComponent"

local AudioPool = Class(LuaObject)

function AudioPool:Ctor(transform, capacity)
    utility.ASSERT(type(capacity) == "number" and capacity > 0, "参数 capacity 比如传入大于0的数字")

    self.gameObject = transform.gameObject
    self.transform = transform
    self.capacity = capacity

    self.poolStack = DataStack.New()
    self.spawnedComponentQueue = DataQueue.New()

    self.recycleMode = true
end

local function CreateNewAudioComponent(self)
    return AudioComponentClass.New(self.gameObject:AddComponent(typeof(UnityEngine.AudioSource)))
end

local function GetCount(self)
    return self.poolStack:Count() + self.spawnedComponentQueue:Count()
end

function AudioPool:PreloadAll()
    local spawnedCount = GetCount(self)
    if spawnedCount >= self.capacity then
        return
    end

    local audioCountToSpawn = self.capacity - spawnedCount

    for i = 1, audioCountToSpawn do
        local newAudioComponent = CreateNewAudioComponent(self)
        if newAudioComponent ~= nil and newAudioComponent.OnDespawn then
            newAudioComponent:OnDespawn()
        end
        self.poolStack:Push(newAudioComponent)
    end
end

function AudioPool:Spawn()

    local audioComponent

    -- 从栈中拿出来!! --
    if self.poolStack:Count() > 0 then
        audioComponent = self.poolStack:Pop()
    else
        -- 找一下是不是超过最大上限! --
        local spawnedCount = GetCount(self)
        local audioCountToSpawn = self.capacity - spawnedCount  -- 还能创建多少个 --
        if audioCountToSpawn > 0 then
            -- 能创建就 创建一个 --
            audioComponent = CreateNewAudioComponent(self)
        else
            if not self.recycleMode then
                error("超过池最大上限!!!!")
            else
                -- 把最先的那个音频组件 拿出来 循环利用!
                audioComponent = self.spawnedComponentQueue:Dequeue()
                if audioComponent ~= nil and audioComponent.OnDespawn ~= nil then
                    audioComponent:OnDespawn()
                end
            end
        end
    end

    if audioComponent ~= nil then
        if audioComponent.OnSpawn ~= nil then
            audioComponent:OnSpawn()
        end
        self.spawnedComponentQueue:Enqueue(audioComponent)
    end

    return audioComponent
end

function AudioPool:Despawn(audioComponent)
    if audioComponent == nil then
        return
    end

    local successed = self.spawnedComponentQueue:Remove(function(component)
        return component == audioComponent
    end)

    if not successed then
        error("放入了不属于这个池的东西!")
        return
    end

    if audioComponent.OnDespawn ~= nil then
        audioComponent:OnDespawn()
    end

    self.poolStack:Push(audioComponent)
end

return AudioPool