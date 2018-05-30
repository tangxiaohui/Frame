--
-- User: fenghao
-- Date: 16/06/2017
-- Time: 2:23 PM
--

require "Framework.GameSubSystem"
require "Collection.OrderedDictionary"
require "Collection.DataStack"
local AudioComponentClass = require "Framework.Subsystems.Audio.AudioComponent"
local AudioFaderClass = require "Framework.Subsystems.Audio.AudioFader"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

local AudioPoolClass = require "Framework.Subsystems.Audio.AudioPool"

local AudioManager = Class(GameSubSystem)

function AudioManager:Ctor()
    -- bgm
    self.currentBgmId = nil
    self.savedBgmId = nil

    -- me
    self.currentMeId = nil

    -- se
    self.playingSeList = OrderedDictionary.New()


    -- 音乐/音频 控制
    self.bgmEnabled = true
    self.soundEnabled = true
end

local function GetSoundData(id)
    return require "StaticData.SoundResPath":GetData(id)
end

local function OnAudioLoaded(self, audioComponent, audioClip, duration, pauseAfterPlay)
    audioComponent:FadeIn(audioClip, duration)

    if pauseAfterPlay then
        audioComponent:Pause()
    end
end

local function LoadAndPlay(self, data, audioComponent, duration, id_getter, pauseAfterPlay)
    utility.LoadResourceAsync(
        data:GetPath(),
        typeof(UnityEngine.AudioClip),
        function(audioClip)
            utility.ASSERT(audioClip ~= nil, string.format("音频资源不存在, path: %s", data:GetPath()))
            if type(id_getter) ~= "function" or id_getter(self) == data:GetId() then
                OnAudioLoaded(self, audioComponent, audioClip, duration, pauseAfterPlay)
            end
        end
    )
end

---------------------------------------------------------------------------
------- BGM (Background Music)
---------------------------------------------------------------------------

function AudioManager:FadeInBGM(id, duration)
    -- @ 1. 类型检查 --
    utility.ASSERT(type(id) == "number" and id > 0, "id不是number类型或者id<=0!")

    if id == self.currentBgmId then
        return
    end

    -- @ 2. 读取数据
    local data = GetSoundData(id)

    -- @ 3. 记录id
    self.currentBgmId = id

    -- @ 4. 获取&加载
    LoadAndPlay(self, data, self.bgmComponent, duration, self.GetBgmId, not self.bgmEnabled)
end

function AudioManager:FadeOutBGM(duration)
    if self.bgmComponent:IsPlaying() then
        self.bgmComponent:FadeOut(duration)
        self.currentBgmId = nil
    end
end

function AudioManager:SaveBGM()
    self.savedBgmId = self.currentBgmId
end

function AudioManager:ReplayBGM()
    if self.savedBgmId ~= nil then
        self:FadeInBGM(self.savedBgmId)
        self.savedBgmId = nil
    end
end

function AudioManager:SetBGMVolume(volume)
    self.bgmComponent:SetVolume(volume)
end

function AudioManager:PauseBGM()
    self.bgmComponent:Pause()
end

function AudioManager:ResumeBGM()
    self.bgmComponent:Resume()
end

function AudioManager:GetBgmId()
    return self.currentBgmId
end

---------------------------------------------------------------------------
------- ME (Music Effect)
---------------------------------------------------------------------------

function AudioManager:PlayME(id, duration)
    -- @ 1. 类型检查 --
    utility.ASSERT(type(id) == "number" and id > 0, "id不是number类型或者id<=0!")

    -- @ 2. 读取数据
    local data = GetSoundData(id)

    -- @ 3. 记录id
    self.currentMeId = id

    -- @ 4. 获取&加载
    LoadAndPlay(self, data, self.meComponent, duration, self.GetMeId, not self.bgmEnabled)
end

function AudioManager:StopME()
    self.currentMeId = nil
    if self.meComponent:IsPlaying() then
        self.meComponent:FadeOut()
    end
end

function AudioManager:GetMeId()
    return self.currentMeId
end

---------------------------------------------------------------------------
------- SE (Sound Effect)
---------------------------------------------------------------------------


local function SpawnAudioComponent(self)
    local seAudioComponent = self.audioComponentPool:Spawn()
    if seAudioComponent ~= nil then
        if seAudioComponent:IsPlaying() then
            seAudioComponent:FadeOut()
        end
        self.playingSeList:Remove(seAudioComponent)
        self.playingSeList:Add(seAudioComponent, seAudioComponent)
    end
    return seAudioComponent
end

local function DespawnAudioComponent(self, audioComponent)
    if audioComponent ~= nil then
        if audioComponent:IsPlaying() then
            audioComponent:FadeOut()
        end
        self.audioComponentPool:Despawn(audioComponent)
    end
end

local function UpdateAllSounds(self)
    local count = self.playingSeList:Count()
    for i = count, 1, -1 do
        local audioComponent = self.playingSeList:GetEntryByIndex(i)
        audioComponent:Update()
        if audioComponent:IsStopped() then
            DespawnAudioComponent(self, audioComponent)
            self.playingSeList:RemoveByIndex(i)
        end
    end
end

function AudioManager:PlaySE(id, duration)
    if not self.soundEnabled then
        return
    end

    -- @ 1. 类型检查 --
    utility.ASSERT(type(id) == "number" and id > 0, "id不是number类型或者id<=0!")

    -- @ 2. 读取数据
    local data = GetSoundData(id)

    -- @ 3. 获取&加载
    LoadAndPlay(self, data, SpawnAudioComponent(self), duration)
end

function AudioManager:StopAllSEs()
    local count = self.playingSeList:Count()
    for i = 1, count do
        DespawnAudioComponent(self, self.playingSeList:GetEntryByIndex(i))
    end
    self.playingSeList:Clear()
end


---------------------------------------------------------------------------
------- 允许/禁用功能
---------------------------------------------------------------------------

local function SetBgmEnabled(self, enabled)
    if self.bgmEnabled ~= enabled then
        self.bgmEnabled = enabled

        if self.bgmEnabled then
            self.bgmComponent:Resume()
            self.meComponent:Resume()
        else
            self.bgmComponent:Pause()
            self.meComponent:Pause()
        end
    end
end

local function SetSeEnabled(self, enabled)
    if self.soundEnabled ~= enabled then
        self.soundEnabled = enabled

        if not self.soundEnabled then
            self:StopAllSEs()
        end
    end
end

local function OnEffectSoundChanged(self, enabled)
    SetSeEnabled(self, enabled)
end

local function OnBgMusicChanged(self, enabled)
    SetBgmEnabled(self, enabled)
end

---------------------------------------------------------------------------
------- 初始化函数
---------------------------------------------------------------------------
local function LoadAudioManagerPrefab()
    local UnityEngine = UnityEngine
    local prefab = utility.LoadResourceSync("Prefabs/AudioManager", typeof(UnityEngine.GameObject))
    local gameObject = UnityEngine.Object.Instantiate(prefab)
    gameObject.name = prefab.name
    UnityEngine.Object.DontDestroyOnLoad(gameObject)
    return gameObject
end

local function InitAudioSettings(self)
    local musicSetting, effectSetting = utility.GetMusicSound()
    SetBgmEnabled(self, musicSetting)
    SetSeEnabled(self, effectSetting)
end

local function RegisterEvents(self)
    local eventMgr = utility.GetGame():GetEventManager()
    eventMgr:AddObserver(messageGuids.EffectSoundChanged, self, OnEffectSoundChanged, nil)
    eventMgr:AddObserver(messageGuids.BgMusicChanged, self, OnBgMusicChanged, nil)
end

local function UnregisterEvents(self)
    local eventMgr = utility.GetGame():GetEventManager()
    eventMgr:RemoveObserver(messageGuids.EffectSoundChanged, self, OnEffectSoundChanged, nil)
    eventMgr:RemoveObserver(messageGuids.BgMusicChanged, self, OnBgMusicChanged, nil)
end

local function InitComponents(self, gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform

    -- bgm --
    self.bgmComponent = AudioComponentClass.New(self.transform:Find("BGM"):GetComponent(typeof(UnityEngine.AudioSource)))
    self.bgmComponent:SetLoop(true)

    -- me --
    self.meComponent = AudioComponentClass.New(self.transform:Find("ME"):GetComponent(typeof(UnityEngine.AudioSource)))

    -- se
    self.audioComponentPool = AudioPoolClass.New(self.transform:Find("SE"), 10)
end


---------------------------------------------------------------------------
------- 实现 GameSubSystem 的接口
---------------------------------------------------------------------------

function AudioManager:GetGuid()
    return require "Framework.SubsystemGUID".AudioManager
end

function AudioManager:Startup()
    InitComponents(self, LoadAudioManagerPrefab())
    InitAudioSettings(self)
    RegisterEvents(self)
end

function AudioManager:Shutdown()
    UnregisterEvents(self)
end

function AudioManager:Restart()
end

function AudioManager:Update()
    UpdateAllSounds(self)
    self.bgmComponent:Update()
    self.meComponent:Update()
end

return AudioManager
