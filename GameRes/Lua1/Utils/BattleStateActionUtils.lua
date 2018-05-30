
require "Const"

local BattleStateActionUtils = {}

-- 工具函数 --
local function GetBattleUnit(state)
    return state:GetOwner()
end

-- 接口 用于实现每一个 action --
local ActionInterfaces = {}

-- @ 根据攻击者的攻击力 * 系数决定的 伤害HP
ActionInterfaces[kUnitState_Action_DamageValueByApFactor] = function(param1, param2, state)
    -- @@ 未实现 @@ --
end

-- @ 根据中状态者的血上限扣hp% (参数1是百分比)
ActionInterfaces[kUnitState_Action_DamageValueByHpPercent] = function(param1, param2, state)
    local battleUnit = GetBattleUnit(state)
    local hp = math.floor(battleUnit:GetMaxHp() * param1 / 100)

    -- 发送伤害记录(未测试 暂不上传)
	-- local messageGuids = require "Framework.Business.MessageGuids"
	-- require "Utils.Utility".GetGame():DispatchEvent(messageGuids.FightAddDamageRecord, nil, battleUnit, hp)

    battleUnit:LoseHp(hp, false, true)
    -- debug_print("@ 中状态伤血!", param1, param2, hp)
    battleUnit:HandleUnitDie(true, false)
end

-- 按阶段执行 --
function BattleStateActionUtils.Execute(state, phase)
    local entryList = state:GetActionMaps():GetEntriesByPhase(phase)
    if entryList ~= nil then
        local count = entryList:Count()
        for i = 1, count do
            local entry = entryList:GetEntry(i)
            if entry ~= nil then
                local routine = ActionInterfaces[entry:GetId()]
                if routine ~= nil then
                    routine(entry:GetParam1(), entry:GetParam2(), state)
                end
            end
        end
    end
end

return BattleStateActionUtils
