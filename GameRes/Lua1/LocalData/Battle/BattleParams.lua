--
-- User: fenghao
-- Date: 05/07/2017
-- Time: 8:42 PM
--

require "Object.LuaObject"

local utility = require "Utils.Utility"
local BattleStartParamsClass = require "LocalData.Battle.BattleStartParams"

local BattleParams = Class(LuaObject)

function BattleParams:Ctor()
    self.sceneID = nil                  -- 场景ID --
    self.scriptID = nil                 -- 剧情ID --

    self.replayDataMessage = nil                -- 回放数据(Protobuf) --
    self.replayDataResultResponseMsg = nil      -- 真实战斗时得到的结算(Protobuf) --

    --- # 原 BattleStartParams 参数 # ---
    --    self.battleType
    --    self.disabledManuallyOperation
    --    self.battleOverLocalDataName
    --    self.battleProtocolMsg
    --    self.battlePrototype
    --    self.battleResultResponsePrototype
    --    self.battleResultViewHANDLEClassName
    --    self.maxBattleRounds
    --    self.battleResultWhenReachMaxRounds
    --    self.isPVP
    --    self.isSkillRestricted
    --    self.isUnlimitedRage


end

--- >> 设置/获取 场景ID << ---
function BattleParams:SetSceneID(sceneID)
    self.sceneID = sceneID
end

function BattleParams:GetSceneID()
    return self.sceneID
end

--- >> 设置/获取 剧情ID << ---
function BattleParams:SetScriptID(scriptID)
    self.scriptID = scriptID
end

function BattleParams:GetScriptID()
    return self.scriptID
end

function BattleParams:HasScript()
    return type(self:GetScriptID()) == "number" and self:GetScriptID() > 0
end

--- >> 设置/获取 回放数据(由战斗来设置, 外部不要设置!!) fightRecordMessage << ---
function BattleParams:SetReplayDataMessage(msg)
    self.replayDataMessage = msg
end

function BattleParams:GetReplayDataMessage()
    return self.replayDataMessage
end

function BattleParams:IsReplayMode()
    return self:GetReplayDataMessage() ~= nil
end

--- >> 设置/获取 指定战斗结算的response msg (回放用) --
function BattleParams:SetReplayDataResultResponseMsg(msg)
    self.replayDataResultResponseMsg = msg
end

function BattleParams:GetReplayDataResultResponseMsg()
    return self.replayDataResultResponseMsg
end

function BattleParams:HasReplayDataResultResponseMsg()
    return self:GetReplayDataResultResponseMsg() ~= nil
end

--- >> 设置/获取 战斗类型(阵容) << ---
function BattleParams:SetBattleType(battleType)
    self.battleType = battleType
end

function BattleParams:GetBattleType()
    return self.battleType
end

--- >> 禁用/获取  是否禁止手动操作 << ---
function BattleParams:DisableManuallyOperation()
    self.disabledManuallyOperation = true
end

function BattleParams:HasManuallyOperationDisabled()
    return utility.ToBoolean(self.disabledManuallyOperation)
end

--- >> 设置/获取  结果存放的LocalData Name, 为nil就代表舍弃存储! << ---
function BattleParams:SetBattleOverLocalDataName(name)
    self.battleOverLocalDataName = name
end

function BattleParams:GetBattleOverLocalDataName()
    return self.battleOverLocalDataName
end


--- >> 设置/获取 战斗协议(真实战斗要发送的网络协议) << ---
--- note: 只需填充 fightRecord 字段即可
function BattleParams:SetBattleStartProtocol(msg, prototype)
    self.battleStartProtocolMsg = msg
    self.battleStartPrototype = prototype
end

function BattleParams:GetBattleStartProtocol()
    return self.battleStartProtocolMsg, self.battleStartPrototype
end

--- >> 设置/获取 战斗结算消息prototype, 用于在战斗时注册此协议 最后接收此协议(回放时 应该忽略此协议注册和接收) << ---
function BattleParams:SetBattleResultResponsePrototype(prototype)
    self.battleResultResponsePrototype = prototype
end

function BattleParams:GetBattleResultResponsePrototype()
    return self.battleResultResponsePrototype
end

--- >> 设置/获取 战斗结算的界面 , 会把他作为 require 函数的参数 << ---
function BattleParams:SetBattleResultViewClassName(className)
    self.battleResultViewClassName = className
end

function BattleParams:GetBattleResultViewClassName()
    return self.battleResultViewClassName
end


--- >> 设置/获取 最大回合数 默认值是30回合 << ---
function BattleParams:SetMaxBattleRounds(rounds)
    self.maxBattleRounds = rounds
end

function BattleParams:GetMaxBattleRounds()
    return self.maxBattleRounds or 30
end


--- >> 设置/获取 当到达最大回合时 是认为输了 还是赢了! 默认值是输 << --
function BattleParams:SetBattleResultWhenReachMaxRounds(isWin)
    if isWin then
        self.battleResultWhenReachMaxRounds = 1
    else
        self.battleResultWhenReachMaxRounds = 0
    end
end

function BattleParams:GetBattleResultWhenReachMaxRounds()
    return self.battleResultWhenReachMaxRounds
end

-- 设置自定义的战斗结果
function BattleParams:GetBattleCustomConditionId()
    return battleConditionId
end

function BattleParams:SetBattleCustomConditionId(battleConditionId)
    self.battleCustomConditionId = battleConditionId
end

--- >> 设置/获取 是否为PVP模式 << ---
function BattleParams:SetPVPMode(isPVP)
    self.isPVP = isPVP
end

function BattleParams:IsPVPMode()
    return utility.ToBoolean(self.isPVP)
end


--- >> 设置/获取 是否为禁魔 模式 << ---
function BattleParams:SetSkillRestricted(restricted)
    self.isSkillRestricted = restricted
end

function BattleParams:IsSkillRestricted()
    return utility.ToBoolean(self.isSkillRestricted)
end


--- >> 设置/获取 是否为无限怒气 模式 << ---
function BattleParams:SetUnlimitedRage(unlimitedRage)
    self.isUnlimitedRage = unlimitedRage
end

function BattleParams:GetUnlimitedRage()
    return utility.ToBoolean(self.isUnlimitedRage)
end

-- 设置敌方额外攻击力倍数
function BattleParams:SetLeftApRate(apRate)
    self.leftApRate = apRate
end

-- 设置己方额外攻击力倍数
function BattleParams:SetRightApRate(apRate)
    self.rightApRate = apRate
end

-- 获得额外攻击力倍数
function BattleParams:GetApRate(side)
    if side == 1 then
        return self.rightApRate or 100
    else
        return self.leftApRate or 100
    end
end

-- 设置敌方额外伤害倍数
function BattleParams:SetLeftDamageRate(damageRate)
    self.leftDamageRate = damageRate
end

-- 设置己方额外伤害倍数
function BattleParams:SetRightDamageRate(damageRate)
    self.rightDamageRate = damageRate
end

-- 获得额外伤害倍数
function BattleParams:GetDamageRate(side)
    if side == 1 then
        return self.rightDamageRate or 100
    else
        return self.leftDamageRate or 100
    end
end

-- 设置胜利条件
function BattleParams:SetWinCondition(condition, param)
    self.winCondition = condition
    self.winConditionParam = param
end

-- 获得胜利条件
function BattleParams:GetWinCondition()
    local condition = self.winCondition
    if type(condition) ~= "number" or condition < 0 then
        condition = 0
    end

    local param = self.winConditionParam
    if type(param) ~= "number" or param < 0 then
        param = 0
    end

    return condition, param
end

--- >> 验证 << ---
function BattleParams:Verify()
--    utility.ASSERT(type(self.battleType) == "number", "必须要设置有效的 battleType.")
--    utility.ASSERT(self.battleOverLocalDataName ~= nil, "必须要设置有效的 localDataName 供战斗后存储!")
--
--    if type(self.battleOverLocalDataName) == "string" and string.len(self.battleOverLocalDataName) == 0 then
--        error("battleOverLocalDataName 不能设置为 空字符串!")
--    end
--
--    utility.ASSERT(self:GetMaxAvailableRounds() >= 3, "别太过分, 回合限制不能低于3回合!!!")
--    utility.ASSERT(self.battleProtocolMsg ~= nil, "必须要设置有效的协议 msg.")
--    utility.ASSERT(self.battlePrototype ~= nil, "必须要设置有效的协议 prototype")
--    utility.ASSERT(self.battleResultResponsePrototype ~= nil, "必须要设置有效的 response prototype.")
--    utility.ASSERT(self.battleResultViewHANDLEClassName ~= nil, "必须要设置有效的 战报界面的 HANDLE.")

    utility.ASSERT(type(self:GetSceneID()) == "number", "场景ID无效!")
    utility.ASSERT(type(self:GetBattleType()) == "number", "必须要设置有效的 battleType (阵容)!")

    local msg, prototype = self:GetBattleStartProtocol()
    utility.ASSERT(msg ~= nil, "必须要设置有效的协议 msg.")
    utility.ASSERT(prototype ~= nil, "必须要设置有效的协议 prototype.")
    utility.ASSERT(self:GetBattleResultResponsePrototype() ~= nil, "必须要设置有效的协议结算 prototype 用于注册 接收!")
    utility.ASSERT(self:GetBattleResultViewClassName() ~= nil, "必须要设置有效的 战报界面的 HANDLE.")

    --- # 原 BattleStartParams 参数 # ---
    --    self.battleType
    --    self.disabledManuallyOperation
    --    self.battleOverLocalDataName
    --    self.battleProtocolMsg
    --    self.battlePrototype
    --    self.battleResultResponsePrototype
    --    self.battleResultViewHANDLEClassName
    --    self.maxBattleRounds
    --    self.battleResultWhenReachMaxRounds
    --    self.isPVP
    --    self.isSkillRestricted
    --    self.isUnlimitedRage
end



--- FIXME : 目前先存到StartParams里去, 一定要改!!! --
function BattleParams:CopyToProtobuf(msg)
    msg.battleType = self:GetBattleType()
    msg.disabledManuallyOperation = self:HasManuallyOperationDisabled()
    msg.resultViewClassName = self:GetBattleResultViewClassName()
    msg.maxAvailableRounds = self:GetMaxBattleRounds()
    msg.battleResultWhenReachMaxRounds = self:GetBattleResultWhenReachMaxRounds()
    msg.isPVP = self:IsPVPMode()
    msg.isSkillRestricted = self:IsSkillRestricted()
    msg.isUnlimitedRage = self:GetUnlimitedRage()
    msg.sceneId = self:GetSceneID()
    print("sceneID >>> ", msg.sceneId, self:GetSceneID())
end


function BattleParams:InitByProtobuf(msg)
    print("初始化的时候", msg, msg.isPVP)
    self:SetSceneID(msg.sceneId)
    self:SetBattleType(msg.battleType)
    self.disabledManuallyOperation = msg.disabledManuallyOperation
    self:SetBattleResultViewClassName(msg.resultViewClassName)
    self:SetMaxBattleRounds(msg.maxAvailableRounds)
    self:SetBattleResultWhenReachMaxRounds(msg.battleResultWhenReachMaxRounds == 1)
    self:SetPVPMode(msg.isPVP)
    self:SetSkillRestricted(msg.isSkillRestricted)
    self:SetUnlimitedRage(msg.isUnlimitedRage)
end

return BattleParams
