require "Class"
local utility = require "Utils.Utility"

local SpeedLevelClass = Class()
function SpeedLevelClass:Ctor(speed, realSpeed, func)
    self.speed = speed
    self.realSpeed = realSpeed
    self.func = func
end

function SpeedLevelClass:GetSpeed()
    return self.speed
end

function SpeedLevelClass:GetRealSpeed()
    return self.realSpeed
end

function SpeedLevelClass:GetFunction()
    return self.func
end


local BattleSpeedSettings = Class()

local function GetKey()
    -- debug_print("@@@@@KKKKK@@@@@", "784c668f-adde-49a5-a1f1-5c780a77d60c" .. utility.GetUserUID())
    return "784c668f-adde-49a5-a1f1-5c780a77d60c" .. utility.GetUserUID()
end

local function GetCurrentLevelPos(self)
    return self.currentLevelPos
end

local function SetCurrentLevelPos(self, pos)
    self.currentLevelPos = pos
    --debug_print("new pos", pos, debug.traceback())
end

function BattleSpeedSettings:Ctor(owner)
    self.speedLevels = {}
    SetCurrentLevelPos(self, 1)
    self.owner = owner
end

local function Set(self)
    UnityEngine.PlayerPrefs.SetInt(GetKey(), GetCurrentLevelPos(self))
end

local function SwitchLevel(self, pos, force)
    local level = self.speedLevels[pos]
    local func = level:GetFunction()
    if type(func) == "function" then
        if func(self.owner, pos, level:GetSpeed(), force) or force then
            -- 判断是否可以切换!
            SetCurrentLevelPos(self, pos)
            UnityEngine.Time.timeScale = level:GetRealSpeed()
            Set(self)
        end
    end
end

function BattleSpeedSettings:Load()
    SetCurrentLevelPos(self, UnityEngine.PlayerPrefs.GetInt(GetKey(), 1))
    SwitchLevel(self, GetCurrentLevelPos(self), true)
end

function BattleSpeedSettings:Add(speed, realSpeed, func)
    self.speedLevels[#self.speedLevels + 1] = SpeedLevelClass.New(speed, realSpeed, func)
end

function BattleSpeedSettings:SwitchNextLevel()
    local nextPos = GetCurrentLevelPos(self) + 1
    --debug_print("new pos",nextPos);
    if nextPos > #self.speedLevels then
        nextPos = 1
    end

    -- 如果只有一个速度级别? 不重复判断!
    if nextPos == GetCurrentLevelPos(self) then
        -- debug_print("speed limit!!")
        return
    end

    SwitchLevel(self, nextPos)
end

function BattleSpeedSettings:GetCurrentRealSpeed()
    -- debug_print("@@@ ", self, self.speedLevels, GetCurrentLevelPos(self))
    return self.speedLevels[GetCurrentLevelPos(self)]:GetRealSpeed()
end

return BattleSpeedSettings
