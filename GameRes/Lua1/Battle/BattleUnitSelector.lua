require "Object.LuaComponent"
require "Battle.BattleTargetInfo"

require "Const"

local probability = require "Utils.Probability"

BattleUnitSelector = Class(LuaComponent)

function BattleUnitSelector:ToString()
    return "BattleUnitSelector"
end

----------------------------------------------------
--------------------  声明  -------------------------
----------------------------------------------------

-- @@ 缓冲表 @@ --
local EMPTY_TABLE = {}

-- @@ units里 并非是连续的 @@ --
local Table_MaxN = table.maxn

----------------------------------------------------
-------------------  基本测试函数  -------------------
----------------------------------------------------

--- 测试是否活着
local function IsUnitAlive(unit)
    return unit ~= nil and unit:IsAlive()
end

--- 测试是否死了
local function IsUnitDead(unit)
    return not IsUnitAlive(unit)
end

--- 测试是否受伤
local function IsDamaged(unit)
    return unit ~= nil and unit:IsDamaged()
end

-- 测试是否后排
local function IsBackrow(unit)
    if unit == nil then
        return false
    end

    local location = unit:GetLocation()
    return location == 4 or location == 5 or location == 6
end

-- 测试是否前排
local function IsFrontrow(unit)
    if unit == nil then
        return false
    end

    local location = unit:GetLocation()
    return location == 1 or location == 2 or location == 3
end

----------------------------------------------------
------------- 基本工具函数(没有返回值)  ---------------
----------------------------------------------------
-- 排序 (units 和 排序方法)
local function SortUnits(units, sortcomp)
    table.sort(units, sortcomp)
end

-- 取 units max 个单位 , 多余的自动清除! --
local function ShrinkUnits(units, max)
    -- max 不是数字 不进行shrink --
    if type(max) ~= "number" or max <= 0 then
        return
    end

    -- 只有大于才进行Shrink --
    local count = #units
    if count > max then
        for i = count, max + 1, -1 do
            units[i] = nil
        end
    end
end

-- 重复单位N次 --
local function RepUnit(outputUnits, unit, times)
    local startPos = #outputUnits + 1
    local endPos = startPos + times - 1
    for i = startPos, endPos do
        outputUnits[i] = unit
    end
end

--------------------------------------------------
-------------------  基本Add函数  -----------------
--------------------------------------------------

local function AddAliveUnitToTable(table, unit)
    if IsUnitAlive(unit) then
        table[#table + 1] = unit
    end
end

-- 过滤添加单元到数组 (table为dest, unit为要加入的单位, filterfunctions为过滤函数表 可以为 nil 无条件加入.)
local function AddFilteredUnitToTable(table, unit, filterfunctions)
    if type(table) ~= "table" then
        error("参数 table 不是 table 类型")
    end

    if unit == nil then
        return
    end

    -- 最起码得是table类型才可以过滤 --
    if type(filterfunctions) == "table" then

        local count = #filterfunctions -- 获取 function 的个数

        -- 检测是否所有过滤项都通过 --
        for i = 1, count do
            if type(filterfunctions[i]) == "function" then
                -- @ 其中一项不满足 则不加入 @ --
                if not filterfunctions[i](unit) then
                    return
                end
            end
        end

    end

    table[#table + 1] = unit
end


-- 从 units 中 随机 找出 max 个, 按顺序放入 randomUnits 中.
local function AddRandomUnitsToTable(randomUnits, units, max, excludeDuplicate)

    local copiedUnits = {}

    -- @ 为了防止破坏原始数据(非连续转连续) @ --
    local n = Table_MaxN(units)
    for i = 1, n do
        if units[i] ~= nil and units[i]:IsAlive() then
            copiedUnits[#copiedUnits + 1] = units[i]
        end
    end

    -- 随机选择 --
    local length = #copiedUnits
    max = math.min(length, max or length)
    if max <= 0 then return EMPTY_TABLE end

    -- 当前随机的个数 --
    local randomCount = 0

    while((length > 0) and randomCount < max) do
        local index = probability:Random(length) + 1
        randomCount = randomCount + 1
        randomUnits[randomCount] = copiedUnits[index]

        -- 是否去重 --
        if excludeDuplicate then
            -- 排到最后边
            copiedUnits[index] = copiedUnits[length]
            copiedUnits[length] = nil
            length = length - 1
        end
    end

end

--------------------------------------------------
-------------------  基本Get函数  -----------------
--------------------------------------------------
-- 获得BattleUnit
local function GetUnitRef(self)
    return self.luaGameObject
end

-- 获得站位
local function GetLocation(unit)
    return unit:GetLocation()
end

-- 获取所有敌人(和unit处于对立的阵营!)
local function GetFoes(unit)
    return unit:GetFoes()
end

-- 获取所有己方成员(和unit同一阵营)
local function GetMembers(unit)
    return unit:GetMembers()
end

-- 通过过滤 返回通过测试的 [BattleUnit] , 返回一张新table.
local function GetAllFilteredUnits(units, ...)
    if type(units) ~= "table" then
        error("参数 units 不是 table 类型!")
    end

    local length = Table_MaxN(units)

    local filterfunctions = {...}

    local targets = {} -- 返回的表 --

    for i = 1, length do
        AddFilteredUnitToTable(targets, units[i], filterfunctions)
    end

    return targets
end

-- 通过过滤和排序 返回通过测试的 [BattleUnit], 返回一张新的table.
local function GetAllFilteredUnitsBySort(units, sortcomp, ...)
    local targets = GetAllFilteredUnits(units, ...)
    SortUnits(targets, sortcomp)
    return targets
end

-- 获取随机单位 --
local function GetRandomUnits(units, max, excludeDuplicate)
    local randomUnits = {}
    AddRandomUnitsToTable(randomUnits, units, max, excludeDuplicate)
    return randomUnits
end



----------------------------------------------------
-------------------  几种类型的获取  -----------------
----------------------------------------------------

-- <<<<<< 默认单位 >>>>>>
local defaultUnitTables = {}

-- 1, 4
defaultUnitTables[1] = {3, 1, 2, 6, 4, 5}
defaultUnitTables[4] = defaultUnitTables[1]

-- 2, 5
defaultUnitTables[2] = {2, 1, 3, 5, 4, 6}
defaultUnitTables[5] = defaultUnitTables[2]

-- 3, 6
defaultUnitTables[3] = {1, 2, 3, 4, 5, 6}
defaultUnitTables[6] = defaultUnitTables[3]


local function GetDefaultUnit(self, units, filterFunc)
    local location = GetLocation(GetUnitRef(self)) -- 获得当前人物站位 --
    local ids = defaultUnitTables[location]

    if not ids then return error(string.format("未知位置: %d", location)) end

    for i = 1, #ids do
        local index = ids[i]

        if units[index] ~= nil then
            if type(filterFunc) ~= "function" or filterFunc(units[index]) then
                return units[index]
            end
        end
    end

    return nil
end


-- <<<<<< 获取后排单位 >>>>>>
local function GetBackrowUnits(self, units, max)
    -- 原始的数组 --
    local rawTargets = {}
    
    -- 先获取后排 --
    AddAliveUnitToTable(rawTargets, units[4])
    AddAliveUnitToTable(rawTargets, units[5])
    AddAliveUnitToTable(rawTargets, units[6])

    -- 当后排没人了 就获取前排 --
    if #rawTargets == 0 then
        AddAliveUnitToTable(rawTargets, units[1])
        AddAliveUnitToTable(rawTargets, units[2])
        AddAliveUnitToTable(rawTargets, units[3])
    end

    if #rawTargets == 0 then
        return rawTargets
    end

    local isAllUnits = type(max) ~= "number" or max <= 0
    if isAllUnits then
        return rawTargets
    end

    return GetRandomUnits(rawTargets, max, false)
end

-- <<<<<< 获取前排单位 >>>>>>
local function GetFrontrowUnits(self, units, max)
    -- 原始的数组 --
    local rawTargets = {}
    
    -- 先获取前排 --
    AddAliveUnitToTable(rawTargets, units[1])
    AddAliveUnitToTable(rawTargets, units[2])
    AddAliveUnitToTable(rawTargets, units[3])

    -- 当前排没人了 就获取后排 --
    if #rawTargets == 0 then
        AddAliveUnitToTable(rawTargets, units[4])
        AddAliveUnitToTable(rawTargets, units[5])
        AddAliveUnitToTable(rawTargets, units[6])
    end

    if #rawTargets == 0 then
        return rawTargets
    end

    local isAllUnits = type(max) ~= "number" or max <= 0
    if isAllUnits then
        return rawTargets
    end

    return GetRandomUnits(rawTargets, max, false)
end

-- <<<<<< 获取连带单位(TODO 需要重写) >>>>>>
local function GetAliveLinearUnits(self, units, direction)
    local aliveUnits = {}
    local starter = GetDefaultUnit(self, units, IsUnitAlive)
    local starterLocation = starter:GetLocation()
    AddAliveUnitToTable(aliveUnits, starter)
    if starterLocation == 1 then
        if (direction == 1) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[4])
        end
        if (direction == 2) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[2])
            AddAliveUnitToTable(aliveUnits, units[3])
        end
    elseif starterLocation == 4 then
        if (direction == 1) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[1])
        end
        if (direction == 2) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[5])
            AddAliveUnitToTable(aliveUnits, units[6])
        end
    elseif starterLocation == 2 then
        if (direction == 1) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[5])
        end
        if (direction == 2) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[1])
            AddAliveUnitToTable(aliveUnits, units[3])
        end
    elseif starterLocation == 5 then
        if (direction == 1) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[2])
        end
        if (direction == 2) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[4])
            AddAliveUnitToTable(aliveUnits, units[6])
        end
    elseif starterLocation == 3 then
        if (direction == 1) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[6])
        end
        if (direction == 2) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[1])
            AddAliveUnitToTable(aliveUnits, units[2])
        end
    elseif starterLocation == 6 then
        if (direction == 1) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[3])
        end
        if (direction == 2) or (direction == 3) then
            AddAliveUnitToTable(aliveUnits, units[4])
            AddAliveUnitToTable(aliveUnits, units[5])
        end
    end

    return aliveUnits
end


--------------------------------------------------
----------------  目标选择实现  --------------------
--------------------------------------------------
local BusinessImpl = {}

-- @@ -19 @@ 己方 血% 最低 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_MembersLowestPercentHP] = function(self, max)

    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetMembers(GetUnitRef(self)),
        function(t1, t2)
            -- @ 从小到大排列 @
            return t1:GetHpRate() < t2:GetHpRate()
        end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ -18 @@ 己方 血% 最高 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_MembersHighestPercentHP] = function(self, max)

    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetMembers(GetUnitRef(self)),
        function(t1, t2)
            -- @ 从大到小排列 @ --
            return t1:GetHpRate() > t2:GetHpRate()
        end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets
    
end

-- @@ -17 @@ 己方 血量 最低 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_MembersLowestHP] = function(self, max)

    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetMembers(GetUnitRef(self)),
        function(t1, t2) return t1:GetCurHp() < t2:GetCurHp() end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ -16 @@ 己方 血量 最高 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_MembersHighestHP] = function(self, max)

    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetMembers(GetUnitRef(self)),
        function(t1, t2) return t1:GetCurHp() > t2:GetCurHp() end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ -15 @@ 己方 攻 最高 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_MembersHighestAttack] = function(self, max)

    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetMembers(GetUnitRef(self)),
        function(t1, t2) return t1:GetAp() > t2:GetAp() end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ -14 @@ 己方随机n次 (参数 times 随机次数, 可重复包括!) (未测试) --
BusinessImpl[kSkillTarget_RandomMembersByTimes] = function(self, times)

    -- units, max, excludeDuplicate

    if type(times) ~= "number" or times <= 0 then
        times = 1
    end

    return GetRandomUnits(
        GetMembers(GetUnitRef(self)),
        times,
        nil
    )

end

-- @@ -13 @@ 己方默认n次 (参数 times 重复次数, 需要大于等于0, nil时默认值为1) (未测试) --
BusinessImpl[kSkillTarget_DefaultMembersByTimes] = function(self, times)
    
    if type(times) ~= "number" or times <= 0 then
        times = 1
    end

    local defaultUnit = GetDefaultUnit(self, GetMembers(GetUnitRef(self)), IsUnitAlive)
    local targets = {}
    RepUnit(targets, defaultUnit, times)
    return targets
end

-- @@ -12 @@ 己方死亡 (参数max是返回数量, nil为己方死亡的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_DeadMembers] = function(self, max)
    
    local targets = GetAllFilteredUnits(
        GetMembers(GetUnitRef(self)),
        IsUnitDead
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ -11 @@ 己方受伤 (参数max是返回数量, nil为己方受伤的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_DamagedMembers] = function(self, max)

    local targets = GetAllFilteredUnits(
        GetMembers(GetUnitRef(self)),
        IsUnitAlive,
        IsDamaged
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ -10 @@ 己方状态 (参数 stateId 是 状态ID) (未测试) --
BusinessImpl[kSkillTarget_MembersByState] = function(self, stateId)

    return GetAllFilteredUnits(
        GetMembers(GetUnitRef(self)),
        IsUnitAlive,
        function(unit)
            return unit:HasUnitState(stateId)
        end
    )

end

-- @@ -9 @@ 己方性别 (参数 gender 为 性别) (未测试) --
BusinessImpl[kSkillTarget_MembersByGender] = function(self, gender)

    return GetAllFilteredUnits(
        GetMembers(GetUnitRef(self)),
        IsUnitAlive,
        function(unit)
            return unit:GetGender() == gender
        end
    )

end

-- @@ -8 @@ 己方属性 (参数 attr 为卡牌的主属性) (未测试) --
BusinessImpl[kSkillTarget_MembersByProperty] = function(self, attr)
    
    return GetAllFilteredUnits(
        GetMembers(GetUnitRef(self)),
        IsUnitAlive,
        function(unit)
            return unit:GetMajorAttr() == attr
        end
    )

end

-- @@ -7 @@ 己方种族 (参数 race 为卡牌的 种族) (未测试) --
BusinessImpl[kSkillTarget_MembersByRace] = function(self, race)

    return GetAllFilteredUnits(
        GetMembers(GetUnitRef(self)),
        IsUnitAlive,
        function(unit)
            return unit:GetRace() == race
        end
    )

end

-- @@ -6 @@ 己方连带 (参数 direction 为 连带方向) (未测试) --
BusinessImpl[kSkillTarget_MembersByDirection] = function(self, direction)

    return GetAliveLinearUnits(
        self,
        GetMembers(GetUnitRef(self)),
        direction
    )

end

-- @@ -5 @@ 己方随机 (参数max为随机次数, 不会出现重复!) (未测试) --
BusinessImpl[kSkillTarget_RandomMembers] = function(self, max)

    -- units, max, excludeDuplicate

    if type(max) ~= "number" or max <= 0 then
        max = 1
    end

    return GetRandomUnits(
        GetMembers(GetUnitRef(self)),
        max,
        true
    )

end

-- @@ -4 @@ 己方全体 (没有参数, 返回所有活着的单位) (未测试) --
BusinessImpl[kSkillTarget_AllMembers] = function(self)
    
    return GetAllFilteredUnits(
        GetMembers(GetUnitRef(self)),
        IsUnitAlive
    )

end

-- @@ -3 @@ 己方后排 (参数 max 为最大数量, 0 为默认 , > 0 为数量)
BusinessImpl[kSkillTarget_BackrowMembers] = function(self, max)
    -- 获取后排
    return GetBackrowUnits(
        self,
        GetMembers(GetUnitRef(self)),
        max
    )
end

-- @@ -2 @@ 己方前排 (参数 max 为最大数量, 0 为默认 , > 0 为数量) (未测试) --
BusinessImpl[kSkillTarget_FrontrowMembers] = function(self, max)
    -- 获取前排
    return GetFrontrowUnits(
        self,
        GetMembers(GetUnitRef(self)),
        max
    )
end

-- @@ -1 @@ 自己 (没有参数) (未测试) --
BusinessImpl[kSkillTarget_Self] = function(self)
    return {GetUnitRef(self)}
end

-- @@ 0 @@ 没有目标 
BusinessImpl[kSkillTarget_None] = function(self)
    return EMPTY_TABLE
end

-- @@ 1 @@ 敌方默认 (没有参数) (未测试) --
BusinessImpl[kSkillTarget_DefaultFoe] = function(self)
    -- local function GetDefaultUnit(self, units, filterFunc)
    local target = GetDefaultUnit(self, GetFoes(GetUnitRef(self)), IsUnitAlive)
    return {target}
end

-- @@ 2 @@ 敌方前排 (参数 max 为最大数量, 0 为默认 , > 0 为数量) (未测试) --
BusinessImpl[kSkillTarget_FrontrowFoes] = function(self, max)

    -- 获取前排
    return GetFrontrowUnits(
        self,
        GetFoes(GetUnitRef(self)),
        max
    )

end

-- @@ 3 @@ 敌方后排 (参数 max 为最大数量, 0 为 全体   > 0 为 随机n个
BusinessImpl[kSkillTarget_BackrowFoes] = function(self, max)

    -- 获取后排
    return GetBackrowUnits(
        self,
        GetFoes(GetUnitRef(self)),
        max
    )
    
end

-- @@ 4 @@ 敌方全体 (没有参数) (未测试) --
BusinessImpl[kSkillTarget_AllFoes] = function(self)

    local foes = GetFoes(GetUnitRef(self))

    local targets = GetAllFilteredUnits(
        GetFoes(GetUnitRef(self)),
        IsUnitAlive
    )

    return targets

end

-- @@ 5 @@ 敌方随机 (参数max为随机次数, 不会出现重复!) (已测试) --
BusinessImpl[kSkillTarget_RandomFoes] = function(self, max)
    -- units, max, excludeDuplicate
	
	if type(max) ~= "number" or max <= 0 then
		max = 1
	end

    return GetRandomUnits(
        GetFoes(GetUnitRef(self)),
        max,
        true
    )

end

-- @@ 6 @@ 敌方连带 (参数 direction 为 连带方向) (未测试) --
BusinessImpl[kSkillTarget_FoesByDirection] = function(self, direction)

    return GetAliveLinearUnits(
        self,
        GetFoes(GetUnitRef(self)),
        direction
    )

end

-- @@ 7 @@ 敌方种族 (参数 race 为卡牌的 种族) (未测试) --
BusinessImpl[kSkillTarget_FoesByRace] = function(self, race)

    return GetAllFilteredUnits(
        GetFoes(GetUnitRef(self)),
        IsUnitAlive,
        function(unit)
            return unit:GetRace() == race
        end
    )

end

-- @@ 8 @@ 敌方属性 (参数 attr 为卡牌的主属性) (未测试) --
BusinessImpl[kSkillTarget_FoesByProperty] = function(self, attr)

    return GetAllFilteredUnits(
        GetFoes(GetUnitRef(self)),
        IsUnitAlive,
        function(unit)
            return unit:GetMajorAttr() == attr
        end
    )

end

-- @@ 9 @@ 敌方性别 (参数 gender 为 性别) (未测试) --
BusinessImpl[kSkillTarget_FoesByGender] = function(self, gender)

    return GetAllFilteredUnits(
        GetFoes(GetUnitRef(self)),
        IsUnitAlive,
        function(unit)
            return unit:GetGender() == gender
        end
    )

end

-- @@ 10 @@ 敌方状态 (参数 stateId 是 状态ID) (未测试) --
BusinessImpl[kSkillTarget_FoesByState] = function(self, stateId)

    return GetAllFilteredUnits(
        GetFoes(GetUnitRef(self)),
        IsUnitAlive,
        function(unit)
            return unit:HasUnitState(stateId)
        end
    )

end

-- @@ 11 @@ 敌方受伤 (参数max是返回数量, nil为己方受伤的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_DamagedFoes] = function(self)

    local targets = GetAllFilteredUnits(
        GetFoes(GetUnitRef(self)),
        IsUnitAlive,
        IsDamaged
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ 12 @@ 敌方死亡 (参数max是返回数量, nil为己方死亡的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_DeadFoes] = function(self, max)

    local targets = GetAllFilteredUnits(
        GetFoes(GetUnitRef(self)),
        IsUnitDead
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ 13 @@ 敌方默认n次 (参数 times 重复次数, 需要大于等于0, nil时默认值为1) (未测试) --
BusinessImpl[kSkillTarget_DefaultFoesByTimes] = function(self, times)
    
    if type(times) ~= "number" or times <= 0 then
        times = 1
    end

    local defaultUnit = GetDefaultUnit(self, GetFoes(GetUnitRef(self)), IsUnitAlive)
    local targets = {}
    RepUnit(targets, defaultUnit, times)
    return targets

end

-- @@ 14 @@ 敌方随机n次 (参数 times 随机次数, 可重复包括!) (未测试) --
BusinessImpl[kSkillTarget_RandomFoesByTimes] = function(self, times)

    -- units, max, excludeDuplicate
    if type(times) ~= "number" or times <= 0 then
        times = 1
    end

    return GetRandomUnits(
        GetFoes(GetUnitRef(self)),
        times,
        nil
    )

end

-- @@ 15 @@ 敌方攻最高 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_FoesHighestAttack] = function(self, max)
    
    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetFoes(GetUnitRef(self)),
        function(t1, t2) return t1:GetAp() > t2:GetAp() end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ 16 @@ 敌方血量最高 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_FoesHighestHP] = function(self, max)

    -- units, sortcomp, ...(filter functions)
	local tempFoes = GetFoes(GetUnitRef(self))
    local targets = GetAllFilteredUnitsBySort(
        GetFoes(GetUnitRef(self)),
        function(t1, t2) return t1:GetCurHp() > t2:GetCurHp() end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ 17 @@ 敌方血量最低 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_FoesLowestHP] = function(self, max)

    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetFoes(GetUnitRef(self)),
        function(t1, t2) return t1:GetCurHp() < t2:GetCurHp() end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ 18 @@ 敌方血%最高 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_FoesHighestPercentHP] = function(self, max)

    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetFoes(GetUnitRef(self)),
        function(t1, t2)
            -- @ 从大到小排列 @ --
            return t1:GetHpRate() > t2:GetHpRate()
        end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end

-- @@ 19 @@ 敌方血%最低 (参数max是返回数量, nil为己方活着的最多单位个数)  (未测试) --
BusinessImpl[kSkillTarget_FoesLowestPercentHP] = function(self, max)

    -- units, sortcomp, ...(filter functions)

    local targets = GetAllFilteredUnitsBySort(
        GetFoes(GetUnitRef(self)),
        function(t1, t2)
            -- @ 从小到大排列 @
            return t1:GetHpRate() < t2:GetHpRate()
        end,
        IsUnitAlive
    )

    ShrinkUnits(targets, max)

    return targets

end


local function GetUniqueMaps(units)
    local maps = {}
    for i = 1, #units do
        if units[i] ~= nil and maps[units[i]] ~= true then
            maps[units[i]] = true
        end
    end
    return maps
end

local function UniqueAliveElements(units)
    local maps = {}
    local newElements = {}

    local maxCount = Table_MaxN(units)
    for i = 1, maxCount do
        if units[i] ~= nil and maps[units[i]] ~= true then
            if IsUnitAlive(units[i]) then
                newElements[#newElements + 1] = units[i]
            end
            maps[units[i]] = true
        end
    end

    return newElements
end

local function GetLastTargetType(self)
    local targetInfo = GetUnitRef(self):GetLastTargets()
    if targetInfo ~= nil then
        return targetInfo:GetTargetType()
    else
        -- 当没有targetInfo时 应该返回对立面的正/负
        if GetUnitRef(self):OnGetSide() == 1 then
            return 1
        else
            return -1
        end
    end
end

-- @@ 20 @@ 刚刚还活着的目标 
BusinessImpl[kSkillTarget_Targets]  = function(self) 
    local targetInfo = GetUnitRef(self):GetLastTargets()
    if targetInfo ~= nil then
        return UniqueAliveElements(targetInfo:GetTargets())
    else
        return EMPTY_TABLE
    end
end

-- @@ 21 @@ 刚刚的目标以外的全部单位
BusinessImpl[kSkillTarget_AllUnitsExcludeTargets] = function(self)

    local targets = BusinessImpl[kSkillTarget_Targets](self)

    local targetType = GetLastTargetType(self)

    -- 获取指定阵营所有人员
    local allUnits
    if targetType > 0 then
        allUnits = GetFoes(GetUnitRef(self))
    else
        allUnits = GetMembers(GetUnitRef(self))
    end

    -- 构建maps用于排除
    local maps = GetUniqueMaps(targets)

    -- 构建最终的table
    return GetAllFilteredUnits(
        allUnits,
        IsUnitAlive,
        function(unit)
            return maps[unit] ~= true
        end
    )
end

-- @@ 22 @@ 刚刚的目标以外的随机单位
BusinessImpl[kSkillTarget_RandomUnitsExcludeTargets] = function(self)
    local units = BusinessImpl[kSkillTarget_AllUnitsExcludeTargets](self)
    -- debug_print("@@@@ units", type(units))
    return GetRandomUnits(units, 1, true)
end

-- @@ 23 @@ 血量低于等于%的单位(策划说是敌方单位)
BusinessImpl[kSkillTarget_UnitsBelowPercentHp] = function(self,rate)
    return GetAllFilteredUnits(
        GetFoes(GetUnitRef(self)),
        function(unit)
            return unit:GetHpRate() <= rate
        end,
        IsUnitAlive
    )
end

-- @@ 24 @@ 攻击者
BusinessImpl[kSkillTarget_Attackers] = function(self)
    return GetUnitRef(self):GetLastDamageSources():GetUnits()
end


--------------------------------------------------
----------------  目标选择内部接口  ----------------
--------------------------------------------------
local function GetRawTargets(self, targetTypeId, param)
    local routine = BusinessImpl[targetTypeId]
    if routine == nil then
        error(string.format("未知的目标类型: %d [等待实现!]", targetTypeId))
    end
    return routine(self, param)
end

local function GetTargets(self, targetTypeId, param)
    local targets = GetRawTargets(self, targetTypeId, param)
    if targets == nil then
        return nil
    end
    local targetInfo = BattleTargetInfo.New(targets, targetTypeId, param)
    return targetInfo
end

--------------------------------------------------
----------------  目标选择外部接口  ----------------
--------------------------------------------------

-- 获得一组目标 --
function BattleUnitSelector:GetTargets(targetTypeId, param)
    -- debug_print("选择目标", targetTypeId, param)
    return GetTargets(self, targetTypeId, param)
end

-- 获得多组目标 --
function BattleUnitSelector:GetMultiTargets(targetTypeIdList, targetParamList)
    -- targetTypeIdList
    if type(targetTypeIdList) ~= "userdata" then
        error("参数 targetTypeIdList 必须是 userdata 类型 -> C# List<> 类型.")
    end

    -- targetParamList 
    if targetParamList ~= nil and type(targetParamList) ~= "userdata" then
        error("参数 targetParamList 只能接受 nil 或 userdata (List<>) 类型.")
    end

    -- 校验 --
    local hasValidParams = targetParamList ~= nil and targetParamList.Count > 0
    if hasValidParams then
        if targetTypeIdList.Count ~= targetParamList.Count then
            error(string.format("targetTypeIdList 和 targetParamList 数量不一致. [%d ~= %d]", targetTypeIdList.Count, targetParamList.Count))
        end
    end

    local maxCount = targetTypeIdList.Count - 1

    local allTargets = {}

    local currentParam

    -- 循环处理 --
    for i = 0, maxCount do

        -- 当前的参数 --
        if hasValidParams then
            currentParam = targetParamList[i]
        else
            currentParam = 0
        end

        -- target info --
        local targetInfo = GetTargets(self, targetTypeIdList[i], currentParam)
        allTargets[#allTargets + 1] = targetInfo
    end

    -- ret
    return allTargets
end


