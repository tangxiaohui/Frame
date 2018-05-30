require "Battle.BattleTeam"
require "Object.LuaComponent"
local camPathEvnt = require "Event.CameraPathEventHandler"
local utility = require "Utils.Utility"
local MessageGuids = require "Framework.Business.MessageGuids"
local BattleUtility = require "Utils.BattleUtility"
local cos3dGame = utility.GetGame()

BattlefieldController = Class(LuaComponent)

function BattlefieldController:Ctor(leftTeam, rightTeam)
    self.leftTeam = leftTeam
    self.rightTeam = rightTeam
    self.isPausing = false
end

function BattlefieldController:ToString()
    return "BattlefieldController"
end

function BattlefieldController:IsController()
    return true
end

function BattlefieldController:Update()
    if self.isPausing then return end
    if self.leftTeam and self.rightTeam then
        self.leftTeam:Update()
        self.rightTeam:Update()
    end
end

function BattlefieldController:Pause()
    if self.isPausing then return end
    -- debug_print("@Pause, BattlefieldController:Pause")
    self.leftTeam:Pause()
    self.rightTeam:Pause()
    self.isPausing = true
end

function BattlefieldController:Resume()
    if self.isPausing then
        -- debug_print("@Resume, BattlefieldController:Resume")
        self.leftTeam:Resume()
        self.rightTeam:Resume()
        self.isPausing = false
    end
end

local function NewRound(self)
    self.leftTeam:NewRound()
    self.rightTeam:NewRound()
    
    self.luaGameObject:AddRoundNumber()
    
    -- print("NewRound on round "..self.luaGameObject:GetRoundNumber())

    -- 通知回合变更
    cos3dGame:DispatchEvent(MessageGuids.BattleRoundChanged, nil, self.luaGameObject:GetRoundNumber())

    -- 当前回合行动!
    self:OnRoundContinued()
end

local function InsertMemberToTable(units, member)
    if member ~= nil then
        local count = #units
        for i = 1, count do
            if member:GetSpeed() > units[i]:GetSpeed() then
                table.insert(units, i, member)
                return
            end
        end
        units[count + 1] = member
    end
end

local function GetAllOrderedMembers(self)
    -- 首先拿到所有人 (左, 右) --
    local leftTeamOrderedMembers = self.leftTeam:GetOrderedUnits()
    local rightTeamOrderedMembers = self.rightTeam:GetOrderedUnits()

    -- 再按速度进行排序
    local allOrderedMembers = {}

    -- 右队
    for i = 1, #rightTeamOrderedMembers do
        InsertMemberToTable(allOrderedMembers, rightTeamOrderedMembers[i])
    end

    -- 左队
    for i = 1, #leftTeamOrderedMembers do
        InsertMemberToTable(allOrderedMembers, leftTeamOrderedMembers[i])
    end

    return allOrderedMembers
end


function BattlefieldController:StartBattle()
    self.battleHasFinished = nil

    -- 战斗开始前初始化参数
    self.leftTeam:OnBattleStarted()
    self.rightTeam:OnBattleStarted()

    local allOrderedMembers = GetAllOrderedMembers(self)

    -- 通知UI
    cos3dGame:DispatchEvent(MessageGuids.BattleInitFightingHeads, nil, allOrderedMembers)

    -- 新回合
    NewRound(self)
end

--local function OnBattleStarted(self)
--    local animator = self.luaGameObject:GetBattleStartAnimator()
--    animator:Play("BattleStartAppearAnim")
--
--    -- 延时开始
--    coroutine.start(DelayStart, self)
--end
--
--function BattlefieldController:OnCameraPathFinished(name)
--    local cameraPath = self.luaGameObject:GetCameraPathShowOffAtBeginning()
--    if name == cameraPath.name then
--        cameraPath:SetActive(false)
--        OnBattleStarted(self)
--    end
--end

local function IsCompleted(self)
    -- 超过最大数量算 输 或 赢 --
    local roundNumber = self.luaGameObject:GetRoundNumber()
    local maxRounds = self.luaGameObject:GetMaxAvailableRounds()
    debug_print("@@@ 当前回合 ", roundNumber, "最大回合", maxRounds)
    if roundNumber >= maxRounds then
        return self.luaGameObject:GetBattleResultWhenReachMaxRounds()
    end

    return self.luaGameObject:GetBattleResult()
end

--local function OnPrepareBackMainScene()
--    coroutine.wait(1)
--    local myGame = require "Utils.Utility".GetGame()
--    local sceneManager = myGame:GetSceneManager()
--    sceneManager:PopScene()
--end

local function DelayDispatchEvent(self, result)
    coroutine.wait(1)
    self.luaGameObject:DispatchBattleFinished(result == 1)
end

local function OnCompleted(self, result)
    if self.battleHasFinished then
        return
    end

    self.battleHasFinished = true
    -- 向上层发送战斗完成的通知

    coroutine.start(DelayDispatchEvent, self, result)
end

local function IsThisRoundFinished(self)
    if self.leftTeam:IsAllMoved() and self.rightTeam:IsAllMoved() then
        return true
    end
    return false
end


local function OnTeamTakeAction(self)
    local lSpeed = self.leftTeam:GetMaxSpeed()
    local rSpeed = self.rightTeam:GetMaxSpeed()
    if lSpeed > rSpeed then
        self.leftTeam:TakeAction(rSpeed)
        return
    end

    if lSpeed == rSpeed then
        if self.luaGameObject:GetBattleStarter() == Side.Left then
            self.leftTeam:TakeAction(rSpeed)
        else
            self.rightTeam:TakeAction(lSpeed)
        end
        return
    end

    self.rightTeam:TakeAction(lSpeed)
end

function BattlefieldController:OnRoundContinued()
    if self:IsBattleFinished() then
        return
    end

    -- 回合结束
    if IsThisRoundFinished(self) then
        NewRound(self)
        return
    end

--
--    -- 开始向下移动 (通知开始行动) --
--    cos3dGame:DispatchEvent(MessageGuids.BattleFightingHeadMoveDown, nil)

    -- 开始行动!!
    OnTeamTakeAction(self)
end

-- 处理自定义胜利条件
local function IsConditionWin(self)
    local isWin = true

    local conditionId, param = self.luaGameObject:GetCustomWinCondition()
    --local conditionId, param = 4,10
    isWin = require "Utils.BattleWinConditionUtils".IsTrue(self.luaGameObject, conditionId, param)

    if isWin then
        return 1
    else
        return 0
    end
end

function BattlefieldController:IsBattleFinished()
    local res = IsCompleted(self)
    if res then
        if res == 1 then
            -- 处理自定义条件 --
            res = IsConditionWin(self)
        end
        OnCompleted(self, res)
        return true
    end
    
    return false
end