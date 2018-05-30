
local WindowNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local messageGuids = require "Framework.Business.MessageGuids"

local BattlePauseModule = Class(WindowNodeClass)

-- # 设置为唯一 # --
windowUtility.SetMutex(BattlePauseModule, true)

function BattlePauseModule:Ctor()
end

function BattlePauseModule:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/Pause', function(go)
		self:BindComponent(go)
	end)
end

-- 指定为Module层!
function BattlePauseModule:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function BattlePauseModule:OnWillShow(battleNode)
    self:DispatchEvent(messageGuids.BattlePauseFight)
    self.battleNode = battleNode
end

local function AddSwitchButton(self, transform, isOn, f_callback)
    local SwitchButton = require "GUI.Controls.SwitchButton"
    local btn = SwitchButton.New(transform)
    btn:SetOn(isOn)
    btn:SetCallbackOnStateChanged(self, f_callback)
    self:AddChild(btn)
end

-- 音乐按钮切换回调
local function OnMusicSwitchStateChanged(self, isOn)
    debug_print("Music State Changed", isOn)
    utility.SetMusicEnabled(isOn)
end

-- SE按钮切换回调
local function OnSESwitchStateChanged(self, isOn)
    debug_print("SE State Changed", isOn)
    utility.SetSoundEnabled(isOn)
end

-- Effect按钮切换回调
local function OnEffectSwitchStateChanged(self, isOn)
    debug_print("Effect State Changed", isOn)
    utility.SetCameraPathEffectEnabled(isOn)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 三个开关按钮
    local mb, sb = utility.GetMusicSound()
    AddSwitchButton(self, transform:Find("SettingPanel/Config/MusicSwitchButton"), mb, OnMusicSwitchStateChanged)
    AddSwitchButton(self, transform:Find("SettingPanel/Config/SESwitchButton"), sb, OnSESwitchStateChanged)
    AddSwitchButton(self, transform:Find("SettingPanel/Config/EffectSwitchButton"), utility.IsCameraPathEnable(), OnEffectSwitchStateChanged)

    -- 继续战斗按钮
    self.goOnButton = transform:Find("SettingPanel/Config/OnButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 退出战斗按钮
    self.goOutButton = transform:Find("SettingPanel/Config/OutButton"):GetComponent(typeof(UnityEngine.UI.Button))
end

local function SetControls(self)
    local a = not self.battleNode:IsFirstFight()
    local b = self:GetGuideManager():IsAllDone()
    debug_print("@第一场战斗?", a, "引导完成?", b)
    self.goOutButton.interactable = a and b
end



local function OnGoOnButtonClicked(self)
    self:DispatchEvent(messageGuids.BattleResumeFight)
    self:Close()
end

local function OnGoOutButtonClicked(self)
    debug_print("战斗退出~~~~!!!")
    local BattleExitFightModuleClass = require "GUI.Modules.Battle.BattleExitFightModule"
    self:GetWindowManager():Show(BattleExitFightModuleClass)
end

local function OnBattleExitFight(self)
    self:Close(true)
end

local function RegisterEvents(self)
    self.__event_button_goOnButtonClicked__ = UnityEngine.Events.UnityAction(OnGoOnButtonClicked, self)
    self.goOnButton.onClick:AddListener(self.__event_button_goOnButtonClicked__)

    self.__event_button_goOutButtonClicked__ = UnityEngine.Events.UnityAction(OnGoOutButtonClicked, self)
    self.goOutButton.onClick:AddListener(self.__event_button_goOutButtonClicked__)

    self:RegisterEvent(messageGuids.BattleExitFight, OnBattleExitFight, nil)
end

local function UnregisterEvents(self)
    if self.__event_button_goOnButtonClicked__ then
        self.goOnButton.onClick:RemoveListener(self.__event_button_goOnButtonClicked__)
        self.__event_button_goOnButtonClicked__ = nil
    end

    if self.__event_button_goOutButtonClicked__ then
        self.goOutButton.onClick:RemoveListener(self.__event_button_goOutButtonClicked__)
        self.__event_button_goOutButtonClicked__ = nil
    end

    self:UnregisterEvent(messageGuids.BattleExitFight, OnBattleExitFight, nil)
end

function BattlePauseModule:OnResume()
    BattlePauseModule.base.OnResume(self)
    RegisterEvents(self)
    SetControls(self)
end

function BattlePauseModule:OnPause()
    BattlePauseModule.base.OnPause(self)
    UnregisterEvents(self)
end

function BattlePauseModule:OnComponentReady()
    InitControls(self)
end

return BattlePauseModule
