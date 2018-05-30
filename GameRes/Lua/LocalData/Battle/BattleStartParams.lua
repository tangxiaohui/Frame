--
-- User: fenghao
-- Date: 5/11/17
-- Time: 10:51 PM
--

require "Object.LuaObject"

local utility = require "Utils.Utility"

local BattleStartParams = Class(LuaObject)

function BattleStartParams:Ctor()
    self.disabledManuallyOperation = false
    self.isPVP = false
end

-- @1. 给一些战斗分类, 区分不同的战斗类型
function BattleStartParams:SetBattleType(type)
    self.battleType = type
end

function BattleStartParams:GetBattleType()
    return self.battleType
end

-- @2. 禁用手动操作
function BattleStartParams:DisableManuallyOperation()
    self.disabledManuallyOperation = true
end

function BattleStartParams:HasManuallyOperationDisabled()
    return self.disabledManuallyOperation
end

-- @3. 设置战斗结束时 发送记录后 存储的结果信息的 name 值
-- 比如保卫公主 应该 放在保卫公主才知道的 地方
function BattleStartParams:SetBattleResultLocalDataName(name)
    self.battleOverLocalDataName = name
end

function BattleStartParams:GetBattleResultLocalDataName()
    return self.battleOverLocalDataName
end

-- @4. 设置战斗结束后 要发送的协议, 这样战斗结束时 只需填充 fightRecord 字段即可
function BattleStartParams:SetBattleRecordProtocol(msg, prototype)
    self.battleProtocolMsg = msg
    self.battlePrototype = prototype
end

function BattleStartParams:GetBattleRecordProtocol()
    return self.battleProtocolMsg, self.battlePrototype
end

-- @5. 设置战斗结果的 Response , 可以可选择进行注册 --
function BattleStartParams:SetBattleResultResponse(prototype)
    self.battleResultResponsePrototype = prototype
end

function BattleStartParams:GetBattleResultResponse()
    return self.battleResultResponsePrototype
end

-- @6. 设置战斗结束的 处理界面的 原型
function BattleStartParams:SetBattleResultViewHANDLEClassName(ClassName)
    self.battleResultViewHANDLEClassName = ClassName
end

function BattleStartParams:GetBattleResultViewHANDLEClassName()
    return self.battleResultViewHANDLEClassName
end

-- @8. 设置最大的回合数
function BattleStartParams:SetMaxAvailableRounds(rounds)
    self.maxBattleRounds = rounds
end

function BattleStartParams:GetMaxAvailableRounds()
    return self.maxBattleRounds or 30
end

-- @9. 当到达最大回合数时 结果认定是赢 还是 输!
function BattleStartParams:SetBattleResultWhenReachMaxRounds(isWin)
    if isWin then
        self.battleResultWhenReachMaxRounds = 1
    else
        self.battleResultWhenReachMaxRounds = 0
    end
end

function BattleStartParams:GetBattleResultWhenReachMaxRounds()
    return self.battleResultWhenReachMaxRounds or 0
end

-- @9. 是否为PVP模式
function BattleStartParams:SetPVPMode(pvp)
    self.isPVP = pvp
end

function BattleStartParams:IsPVPMode()
    return self.isPVP == true
end


-- @10. 禁魔
function BattleStartParams:SetSkillRestricted(restricted)
    self.isSkillRestricted = restricted
end

function BattleStartParams:IsSkillRestricted()
    return self.isSkillRestricted == true
end

-- @11. 无限怒气
function BattleStartParams:SetUnlimitedRage(unlimitedRage)
    self.isUnlimitedRage = unlimitedRage
end

function BattleStartParams:GetUnlimitedRage()
    return self.isUnlimitedRage == true
end


-- 验证参数的正确性, 在进入战斗阶段前判断 可以在之后少很多麻烦
function BattleStartParams:Verify()
    utility.ASSERT(type(self.battleType) == "number", "必须要设置有效的 battleType.")
    utility.ASSERT(self.battleOverLocalDataName ~= nil, "必须要设置有效的 localDataName 供战斗后存储!")

    if type(self.battleOverLocalDataName) == "string" and string.len(self.battleOverLocalDataName) == 0 then
        error("battleOverLocalDataName 不能设置为 空字符串!")
    end

    utility.ASSERT(self:GetMaxAvailableRounds() >= 3, "别太过分, 回合限制不能低于3回合!!!")
    utility.ASSERT(self.battleProtocolMsg ~= nil, "必须要设置有效的协议 msg.")
    utility.ASSERT(self.battlePrototype ~= nil, "必须要设置有效的协议 prototype")
    utility.ASSERT(self.battleResultResponsePrototype ~= nil, "必须要设置有效的 response prototype.")
    utility.ASSERT(self.battleResultViewHANDLEClassName ~= nil, "必须要设置有效的 战报界面的 HANDLE.")
end

-- msg = BattleStartParams
function BattleStartParams:CopyToProtobuf(msg)
    msg.battleType = self:GetBattleType()
    msg.disabledManuallyOperation = self:HasManuallyOperationDisabled()
    msg.resultViewClassName = self:GetBattleResultViewHANDLEClassName()
    msg.maxAvailableRounds = self:GetMaxAvailableRounds()
    msg.battleResultWhenReachMaxRounds = self:GetBattleResultWhenReachMaxRounds()
    msg.isPVP = self:IsPVPMode()
    msg.isSkillRestricted = self:IsSkillRestricted()
    msg.isUnlimitedRage = self:GetUnlimitedRage()
end

function BattleStartParams:InitByProtobuf(msg)
    print("初始化的时候", msg, msg.isPVP)
    self:SetBattleType(msg.battleType)
    self.disabledManuallyOperation = msg.disabledManuallyOperation
    self:SetBattleResultViewHANDLEClassName(msg.resultViewClassName)
    self:SetMaxAvailableRounds(msg.maxAvailableRounds)
    self:GetBattleResultWhenReachMaxRounds(msg.battleResultWhenReachMaxRounds)
    self:SetPVPMode(msg.isPVP)
    self:SetSkillRestricted(msg.isSkillRestricted)
    self:SetUnlimitedRage(msg.isUnlimitedRage)
end

return BattleStartParams
