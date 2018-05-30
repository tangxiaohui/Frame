
local BossRecorder = Class()
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

function BossRecorder:Ctor(owner, bossLocation)
    -- debug_print("@BossRecorder", "Init", bossLocation)
    self.owner = owner
    self.myGame = utility.GetGame()
    self.bossLocation = bossLocation
    self.totalLosedHp = 0
    self.lastBattleUnit = nil
end

function BossRecorder:GetTotalLosedHp()
    return self.totalLosedHp
end

local function CheckLastBattleUnit(self, battleUnit)
    if self.lastBattleUnit ~= battleUnit then
        --debug_print("@BossRecorder, BOSS变更, 重置伤害", "新怪物", battleUnit:GetGameObject().name)
        self.totalLosedHp = 0
        self.lastBattleUnit = battleUnit
    end
end

local function OnBattleUnitLoseHp(self, battleUnit, losedHp)
    if battleUnit:OnGetSide() ~= 1 and battleUnit:GetLocation() == self.bossLocation then
        CheckLastBattleUnit(self, battleUnit)
        self.totalLosedHp = self.totalLosedHp + losedHp
        --debug_print("@BossRecorder", battleUnit:GetGameObject().name, "总伤血量", self.totalLosedHp, "当次伤血量", losedHp)
    end
end

function BossRecorder:Start()
    --debug_print("@BossRecorder:Start")
    self.myGame:RegisterEvent(messageGuids.BattleUnitLoseHp, self, OnBattleUnitLoseHp)
end

function BossRecorder:Close()
    --debug_print("@BossRecorder:Close")
    self.myGame:UnregisterEvent(messageGuids.BattleUnitLoseHp, self, OnBattleUnitLoseHp)
end

return BossRecorder
