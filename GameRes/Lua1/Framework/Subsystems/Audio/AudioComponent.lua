--
-- User: fenghao
-- Date: 16/06/2017
-- Time: 2:50 PM
--

require "Object.LuaObject"
require "System.LuaDelegate"
local utility = require "Utils.Utility"

local AudioComponent = Class(LuaObject)

-- # 获得当前播放的 AudioClip
local function GetClip(self)
    return self.playingClip
end

-- # 设置当前播放的 AudioClip
local function SetClip(self, clip)
    self.playingClip = clip
    self.audioSource.clip = clip
end

local function IsAudioSourcePlaying(self)
    return self.audioSource.isPlaying
end

local function PlayAudioSource(self)
    self.audioSource:Play()
end

local function StopAudioSource(self)
    self.audioSource:Stop()
end

-- # 获得 AudioClip 的时间 (秒)
-- local function GetClipDuration(self)
--     return self.playingClip.length / self:GetPitch()
-- end

-- # 直接访问AudioSource的volume字段
local function SetRawVolume(self, volume)
    self.audioSource.volume = volume
end

-- # 停止 淡入/淡出 
local function StopFader(self)
    if self.fader:IsPlaying() then
        self.fader:Stop()
        self.isFadeIn = nil
        SetRawVolume(self, self:GetVolume())
    end
end

local function Stop(self)
    -- Stop the Audio --
    StopAudioSource(self)
    SetClip(self, nil)
    StopFader(self)
    self.isPlaying = false
end

-- # 淡入
local function FadeIn(self, duration)
    StopFader(self)
    if type(duration) == "number" and duration > 0 then
        SetRawVolume(self, 0)
        self.isFadeIn = true
        self.fader:SetStartValue(0)
        self.fader:SetEndValue(self:GetVolume())
        self.fader:SetDuration(duration)
        self.fader:Play()
    end
end

-- # 淡出
local function FadeOut(self, duration)
    if type(duration) == "number" and duration > 0 then
        StopFader(self)
        self.isFadeIn = false
        self.fader:SetStartValue(self:GetVolume())
        self.fader:SetEndValue(0)
        self.fader:SetDuration(duration)
        self.fader:Play()
    else
        Stop(self)
    end
end

-- >> 事件

-- loop
local function OnLoopChanged(self)
    self.audioSource.loop = self:IsLoop()
end

-- volume
local function OnVolumeChanged(self)
    SetRawVolume(self, self:GetVolume())

    -- TODO 需要重新设置FadeIn的终点或FadeOut的起点!
end

-- pitch
local function OnPitchChanged(self)
    self.audioSource.pitch = self:GetPitch()
end

-- onresume
local function OnResume(self)
    self.audioSource:UnPause()
end

-- onpause
local function OnPause(self)
    self.audioSource:Pause()
end

local function OnLoopPointReached(self)
    self.loopPointReachedEvent:Invoke()
    if not self:IsLoop() then
        Stop(self)
    else
        PlayAudioSource(self)
    end
end

local function OnFadeUpdate(self, volume)
    SetRawVolume(self, volume)
end

local function OnFadeCompleted(self)
    if self.isFadeIn == false then
        Stop(self)
    end
end

local function Reset(self)
    self.loop = self.audioSource.loop
    self.audioSource.loop = false
    self.volume = self.audioSource.volume
    self.pitch = self.audioSource.pitch
    self.isPlaying = false
    SetClip(self, nil)
end

local function InitDelegates(self)
    self.loopPointReachedEvent = LuaDelegate.New()
end

function AudioComponent:Ctor(audioSource)
    utility.ASSERT(audioSource ~= nil, "AudioSource 组件不能是空!")
    self.audioSource = audioSource
    self.audioSource.playOnAwake = false

    local TweenClass = require "Framework.Tween"
    self.fader = TweenClass.New()
    self.fader:SetCallbackOnUpdate(self, OnFadeUpdate)
    self.fader:SetCallbackOnComplete(self, OnFadeCompleted)

    Reset(self)
    InitDelegates(self)
end

-- 播放(duration 音频淡入时间(s))
function AudioComponent:FadeIn(clip, duration)
    -- @ clip 参数不能是 nil
    if clip == nil then
        error("参数 clip 不能为nil!")
    end

    -- @ 开始播放音频
    SetClip(self, clip)

    -- @ 播放Fader进行音频淡入
    FadeIn(self, duration)

    -- @ 播放
    PlayAudioSource(self)
    self.isPlaying = true
end

-- 停止(duration音频淡出时间(s))
function AudioComponent:FadeOut(duration)
    -- @ 是否有音乐在播放
    if not self:IsPlaying() then
        error("没有音乐在播放!")
    end

    -- @ 播放Fader进行音频淡出
    FadeOut(self, duration)
end

-- 循环
function AudioComponent:IsLoop()
    return self.loop
end

function AudioComponent:SetLoop(loop)
    if self.loop ~= loop then
        self.loop = loop
        OnLoopChanged(self)
    end
end

-- 音量
function AudioComponent:GetVolume()
    return self.volume
end

function AudioComponent:SetVolume(volume)
    if self.volume ~= volume then
        self.volume = volume
        OnVolumeChanged(self)
    end
end

-- Pitch
function AudioComponent:GetPitch(pitch)
    return self.pitch
end

function AudioComponent:SetPitch(pitch)
    if self.pitch ~= pitch then
        self.pitch = pitch
        OnPitchChanged(self)
    end
end

-- 状态判断相关函数
function AudioComponent:IsPlaying()
    return GetClip(self) ~= nil and self.isPlaying == true
end

function AudioComponent:IsPausing()
    return GetClip(self) ~= nil and self.isPlaying == false
end

function AudioComponent:IsStopped()
    return GetClip(self) == nil
end

-- 暂停/恢复相关
function AudioComponent:Pause()
    if self:IsPlaying() then
        self.isPlaying = false
        OnPause(self)
    end
end

function AudioComponent:Resume()
    if self:IsPausing() then
        self.isPlaying = true
        OnResume(self)
    end
end

local function CheckCompleteEvent(self)
    if not IsAudioSourcePlaying(self) then
        OnLoopPointReached(self)
    end
end

function AudioComponent:Update()
    if self:IsPlaying() then
        self.fader:Update()
        CheckCompleteEvent(self)
    end
end

return AudioComponent
