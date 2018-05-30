
require "Const"

local BattleStateTraitUtils = {}

-- 获取值/默认值(已测)
local function GetRateValue(value)
    return value or 0
end

-- 获取 Rate 总数(param1为rate, param2没有用) --
local function GetRawParam1Rate(state, id)
    local entryList = state:GetTraitMaps():GetEntries(id)
    local totalRate = 0

    if entryList ~= nil then
        local count = entryList:Count()
        for i = 1, count do
            local entry = entryList:GetEntry(i)
            totalRate = totalRate + GetRateValue(entry:GetParam1())
        end
    end

    return totalRate
end

-- 获取标志是否存在 --
local function HasAnyFlag(state, flag)
    local entryList = state:GetTraitMaps():GetEntries(kUnitState_Trait_Flag)

    if entryList ~= nil then
        local count = entryList:Count()
        for i = 1, count do
            local entry = entryList:GetEntry(i)
            if flag == entry:GetParam1() then
                return true
            end
        end
    end

    return false
end



-- 获取拒绝列表 --
function BattleStateTraitUtils.GetRejectList(state)
    return state:GetTraitMaps():GetEntries(kUnitState_Trait_StateToReject)
end

-- 获取抵消列表 --
function BattleStateTraitUtils.GetCounteractList(state)
    return state:GetTraitMaps():GetEntries(kUnitState_Trait_StateToCounteract)
end

-- >> 获取增加系数的接口 << --

function BattleStateTraitUtils.GetApRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_ApRate)
end

function BattleStateTraitUtils.GetDpRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_DpRate)
end

function BattleStateTraitUtils.GetSpeedRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_SpeedRate)
end

function BattleStateTraitUtils.GetCritRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_CritRate)
end

function BattleStateTraitUtils.GetCritDamageRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_CritDamageRate)
end

function BattleStateTraitUtils.GetDecritRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_DecritRate)
end

function BattleStateTraitUtils.GetAvoidRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_AvoidRate)
end

function BattleStateTraitUtils.GetHitRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_HitRate)
end

function BattleStateTraitUtils.GetVamRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_VamRate)
end

function BattleStateTraitUtils.GetDamageRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_DamageRate)
end

function BattleStateTraitUtils.GetScaleRate(state)
    return GetRawParam1Rate(state, kUnitState_Trait_ScaleRate)
end

-- >> Flag << --

-- # 判断是否无敌 # --
function BattleStateTraitUtils.HasGodFlag(state)
    return HasAnyFlag(state, kUnitState_TraitFlag_God)
end

-- # 判断是否不能行动 # --
function BattleStateTraitUtils.HasCannotMoveFlag(state)
    return HasAnyFlag(state, kUnitState_TraitFlag_CannotMove)
end


return BattleStateTraitUtils
