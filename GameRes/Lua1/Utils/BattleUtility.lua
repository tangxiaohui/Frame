--
-- User: fbmly
-- Date: 4/24/17
-- Time: 5:37 PM
--

local utility = require "Utils.Utility"

require "Battle.Parameters.BattleTeamParameter"
require "Battle.Parameters.BattleUnitParameter"

require "Game.Role"
require "Const"


local Side_Left = kTeamSide_Left
local Side_Right = kTeamSide_Right


local BattleUtility = {}

-- 将C#的List<> 转成lua的table.
local function GetTableFromArray(userDataArray)
    local t = {}
    local max = userDataArray.Count - 1
    for i = 0, max do
        t[#t + 1] = userDataArray[i]
    end
    return t
end

--[[
    @desc: 统一创建单个战斗单位的
    --@role: 人物 Game.Role
    --@location: 站位
    --@scaleRate: 缩放系数
    return BattleUnitParameter
]]
local function CreateNewUnit(role, location, scaleRate)
    return BattleUnitParameter.New(role, location, scaleRate)
end

--[[
    @desc: 创建一个NPC卡牌
    --@id: 卡牌ID
    --@color: 卡牌颜色
    --@level: 卡牌等级
    --@stage: 卡牌阶数
    --@talents: 卡牌的天赋列表
    return 一张卡牌 Game.Role
]]
local function CreateStaticRole(id, color, level, stage, talents)
    if utility.IsValidUid(id) then
        local role = Role.New()
        role:UpdateForStatic(id, color, level, stage, talents)
        return role
    end
    return nil
end

--[[
    @desc: 创建一个NPC战斗单位
    --@id: 卡牌ID
    --@color: 卡牌颜色
    --@level: 卡牌等级
    --@stage: 卡牌阶数
    --@talents: 卡牌的天赋列表
    --@location: 卡牌站位
    --@scaleRate: 缩放系数
    --@equipDataList: 装备列表(OrderedDictionary<Data.EquipBag.EquipData>)
    return 战斗单位 BattleUnitParameter
]]
local function CreateStaticBattleUnitParameter(id, color, level, stage, talents, location, scaleRate, equipDataList)
    local role = CreateStaticRole(id, color, level ,stage, talents)
    if role ~= nil then
        role:SetEquipDataList(equipDataList)
        return CreateNewUnit(role, location, scaleRate)
    end
    return nil
end

-- 创建保卫公主队伍数据(玩家自己的卡牌数量)
function BattleUtility.CreateBattleProtectTeam(gyjinfo)
    local battleTeam = BattleUtility.CreateBattleTeamByLineup(kLineup_Protect)

    if gyjinfo ~= nil then
        local unit = BattleUtility.CreateStaticBattleUnitParameter(
            -- id, color, level, stage, talents, location, scaleRate, equipDataList
            gyjinfo.cardID,
            gyjinfo.cardColor,
            gyjinfo.cardLevel,
            gyjinfo.stage,
            nil,
            gyjinfo.cardPos,
            nil,
            nil
        )
        battleTeam:AddUnit(unit)

        debug_print("保卫公主雇佣军", gyjinfo.cardUID, gyjinfo.pos, gyjinfo.playerID, gyjinfo.cardID, gyjinfo.cardLevel, gyjinfo.cardColor)
    end

    return battleTeam
end

-- 通过指定阵型获得队伍数据(玩家自己的所有卡牌) --
function BattleUtility.CreateBattleTeamByLineup(lineupType)
    utility.ASSERT(type(lineupType) == "number", "参数 lineupType 必须是数字类型")

    local UserDataType = require "Framework.UserDataType"
    local cardBagData = utility.GetGame():GetDataCacheManager():GetData(UserDataType.CardBagData)
    local roles = cardBagData:GetTroopByLineup(lineupType)

    if roles ~= nil then
        local battleTeam = BattleTeamParameter.New()

        for i = 1, 6 do
            if utility.IsValidUid(roles[i]) then
                local roleData = cardBagData:GetRoleByUid(roles[i])
                if roleData ~= nil then
                    -- 这里不用管装备的Set, 因为自己卡包里的卡牌都已经被自动设置了装备列表 --
                    battleTeam:AddUnit(CreateNewUnit(roleData, i))
                end
            end
        end

        return battleTeam
    end

    return nil
end


--[[
    @desc: 创建一个NPC战斗单位(接口)
    --@id: 卡牌ID
    --@color: 卡牌颜色
    --@level: 卡牌等级
    --@stage: 卡牌阶数
    --@talents: 卡牌的天赋列表
    --@location: 卡牌站位
    --@scaleRate: 缩放系数
    --@equipDataList: 装备列表(OrderedDictionary<Data.EquipBag.EquipData>)
    return 战斗单位 BattleUnitParameter
]]
function BattleUtility.CreateStaticBattleUnitParameter(id, color, level, stage, talents, location, scaleRate, equipDataList)
    return CreateStaticBattleUnitParameter(id, color, level, stage, talents, location, scaleRate, equipDataList)
end

-- 通过用户Role数据来创建Unit
function BattleUtility.CreateBattleUnitParameter(role, location, scaleRate)
    if role == nil or location == 0 then
        return nil
    end
    return CreateNewUnit(role, location, scaleRate)
end

-- 通过数组创建多队人 { {BattleUnitParameter1 -> BattleUnitParameterN} , ... }
function BattleUtility.CreateBattleTeams(...)
    local inputTeams = {...}

    -- 最多创建多少队 队伍
    local maxTeams = #inputTeams

    local teams = {}

    for i = 1, maxTeams do

        local newBattleTeam = BattleTeamParameter.New()

        -- 拿到每一队的人员数组
        local currentInputUnits = inputTeams[i]

        -- 遍历循环
        local maxUnits = #currentInputUnits

        -- 循环加入当前队伍
        for j = 1, maxUnits do
            local unitParameter = currentInputUnits[j]
            newBattleTeam:AddUnit(unitParameter)
        end

        -- 加入队伍数组
        teams[#teams + 1] = newBattleTeam
    end

    return teams
end

-- 通过关卡队伍数据来创建队伍(静态数据) --
function BattleUtility.CreateBattleTeamsByLevelID(id)
    local levelData = require "StaticData.ChapterLevel":GetData(id)
    local levelTeams = levelData:GetTeams()

    local uniformLevel
    local uniformStage

    local lv = levelData:GetMonsterLevel()
    if lv > 0 then
        uniformLevel = lv
    end
    lv = nil

    local stage = levelData:GetMonsterStage()
    if stage > 0 then
        uniformStage = stage
    end
    stage = nil

    local teams = {}
    for i = 1, #levelTeams do
        local teamData = levelTeams[i]
        if teamData ~= nil then
            local newBattleTeam = BattleTeamParameter.New()
            newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID01(), teamData:GetFoeColor01(), uniformLevel or teamData:GetFoeLevel01(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility01()), 1, teamData:GetFoeScaleRate01()) )
            newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID02(), teamData:GetFoeColor02(), uniformLevel or teamData:GetFoeLevel02(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility02()), 2, teamData:GetFoeScaleRate02()) )
            newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID03(), teamData:GetFoeColor03(), uniformLevel or teamData:GetFoeLevel03(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility03()), 3, teamData:GetFoeScaleRate03()) )
            newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID04(), teamData:GetFoeColor04(), uniformLevel or teamData:GetFoeLevel04(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility04()), 4, teamData:GetFoeScaleRate04()) )
            newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID05(), teamData:GetFoeColor05(), uniformLevel or teamData:GetFoeLevel05(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility05()), 5, teamData:GetFoeScaleRate05()) )
            newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID06(), teamData:GetFoeColor06(), uniformLevel or teamData:GetFoeLevel06(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility06()), 6, teamData:GetFoeScaleRate06()) )
            teams[#teams + 1] = newBattleTeam
        end
    end

    return teams
end

-- 通过爬塔关卡队伍数据来创建队伍(静态数据) --
function BattleUtility.CreateBattleTeamsByTowerLevelID(id)
    local levelData = require "StaticData.Tower.TowerLevels":GetData(id)

    -- 统一等级和阶设置
    local uniformLevel
    local uniformStage

    local lv = levelData:GetMonsterLevel()
    if lv > 0 then
        uniformLevel = lv
    end
    lv = nil

    local stage = levelData:GetMonsterStage()
    if stage > 0 then
        uniformStage = stage
    end
    stage = nil

    -- 获取队伍数据
    local teamData = require "StaticData.FoeTeam":GetData(levelData:GetTeamid())

    local teams = {}
    local newBattleTeam = BattleTeamParameter.New()
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID01(), teamData:GetFoeColor01(), uniformLevel or teamData:GetFoeLevel01(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility01()), 1, teamData:GetFoeScaleRate01()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID02(), teamData:GetFoeColor02(), uniformLevel or teamData:GetFoeLevel02(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility02()), 2, teamData:GetFoeScaleRate02()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID03(), teamData:GetFoeColor03(), uniformLevel or teamData:GetFoeLevel03(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility03()), 3, teamData:GetFoeScaleRate03()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID04(), teamData:GetFoeColor04(), uniformLevel or teamData:GetFoeLevel04(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility04()), 4, teamData:GetFoeScaleRate04()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID05(), teamData:GetFoeColor05(), uniformLevel or teamData:GetFoeLevel05(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility05()), 5, teamData:GetFoeScaleRate05()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID06(), teamData:GetFoeColor06(), uniformLevel or teamData:GetFoeLevel06(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility06()), 6, teamData:GetFoeScaleRate06()) )
    teams[1] = newBattleTeam

    return teams
end

-- 通过BOSS关卡队伍数据来创建队伍(静态数据) --
function BattleUtility.CreateBattleTeamsByBossLevelID(id)
    local levelData = require "StaticData.Tower.TowerBoss":GetData(id)
    
    -- 统一等级和阶设置
    local uniformLevel
    local uniformStage

    local lv = levelData:GetMonsterLevel()
    if lv > 0 then
        uniformLevel = lv
    end
    lv = nil

    local stage = levelData:GetMonsterStage()
    if stage > 0 then
        uniformStage = stage
    end
    stage = nil

    -- 获取队伍数据
    local teamData = require "StaticData.FoeTeam":GetData(levelData:GetTeamid())

    local teams = {}
    local newBattleTeam = BattleTeamParameter.New()
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID01(), teamData:GetFoeColor01(), uniformLevel or teamData:GetFoeLevel01(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility01()), 1, teamData:GetFoeScaleRate01()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID02(), teamData:GetFoeColor02(), uniformLevel or teamData:GetFoeLevel02(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility02()), 2, teamData:GetFoeScaleRate02()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID03(), teamData:GetFoeColor03(), uniformLevel or teamData:GetFoeLevel03(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility03()), 3, teamData:GetFoeScaleRate03()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID04(), teamData:GetFoeColor04(), uniformLevel or teamData:GetFoeLevel04(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility04()), 4, teamData:GetFoeScaleRate04()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID05(), teamData:GetFoeColor05(), uniformLevel or teamData:GetFoeLevel05(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility05()), 5, teamData:GetFoeScaleRate05()) )
    newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID06(), teamData:GetFoeColor06(), uniformLevel or teamData:GetFoeLevel06(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility06()), 6, teamData:GetFoeScaleRate06()) )
    teams[1] = newBattleTeam

    return teams
end

-- 设置队伍指定单位血量和最大血量
function BattleUtility.SetCustomHpParameterInTeam(battleTeamParameter, location, curHp, maxHp)
    local count = battleTeamParameter:Count()
    for i = 1, count do 
        local unitParameter = battleTeamParameter:GetUnit(i)
        if unitParameter ~= nil and unitParameter:GetLocation() == location then
            unitParameter:SetCurHp(curHp)
            unitParameter:SetMaxHp(maxHp)
            return true
        end
    end
    return false
end

-- 获取唯一值 (这个其实没啥用!!)
function BattleUtility.GetBattleUnitHash(id, position, uid, side)
    utility.ASSERT(type(id) == "number", "参数 id 必须是有效数字类型")
    utility.ASSERT(type(position) == "number", "参数 position 必须是有效数字类型")
    utility.ASSERT(type(side) == "number", "参数 side 必须是有效的数字类型")
    local t = {}
    if side == Side_Left then
        t[1] = "L"
    else
        t[1] = "R"
    end
    t[2] = id
    t[3] = position
    t[4] = uid or 0
    return table.concat(t, "_")
end

-- 获取BattleUnit的池名字
function BattleUtility.GetBattleUnitPoolName(id)
    return string.format("BattleUnit-%d", id)
end

-- 排序单位(战斗时使用 外部不使用)
function BattleUtility.SortBattleUnits(unitTable)
    for i = 1, #unitTable do
        local max = unitTable[i]:GetSpeed()
        local maxIndex = i
        for j = i + 1, #unitTable do
            local cur = unitTable[j]:GetSpeed()
            if cur > max then
                max = cur
                maxIndex = j
            elseif cur == max and unitTable[j]:GetLocation() < unitTable[maxIndex]:GetLocation() then
                maxIndex = j
            end
        end

        if maxIndex ~= i then
            local tmp = unitTable[i]
            unitTable[i] = unitTable[maxIndex]
            unitTable[maxIndex] = tmp
        end
    end
end

--[[
    @desc: 通过protobuf来构建BattleUnitParameter和Game.Role 以及 BattleTeamParameter
    --@cards: [Network.PB.FightingCardData]
    return 返回战斗队伍
]]
function BattleUtility.GetBattleTeamByProtobufCards(cards)
    local max = #cards

    local battleTeamParameter = BattleTeamParameter.New()

    for i = 1, max do
        local fightingCardData = cards[i]
        local battleUnitParameter = BattleUnitParameter.New()
        battleUnitParameter:InitByProtobuf(fightingCardData)
        battleTeamParameter:AddUnit(battleUnitParameter)
    end

    return battleTeamParameter
end

--[[
    @desc: 通过protobuf来构建一个BattleTeamParameter(每个BattleUnitParameter 和 Game.Role)
    --@wave: CardItemWaveData
    return BattleTeamParameter
]]
function BattleUtility.GetBattleTeamByProtobufTeam(wave)
    local battleTeamParameter = BattleTeamParameter.New()
    battleTeamParameter:InitByProtobuf(wave)
    return battleTeamParameter
end

--[[
    @desc: 通过protobuf来构建多个BattleTeamParameter(每个BattleUnitParameter 和 Game.Role)  用于NPC敌人!
    --@wave: [CardItemWaveData]
    return [BattleTeamParameter]
]]
function BattleUtility.GetBattleTeamsByProtobufTeams(waves)
    local waveCount = #waves

    local retTeams = {}

    for i = 1, waveCount do
        local currentWaveData = waves[i]
        local battleTeamParameter = BattleTeamParameter.New()
        battleTeamParameter:InitByProtobuf(currentWaveData)
        retTeams[#retTeams + 1] = battleTeamParameter
    end

    return retTeams
end


-- 创建第一场战斗的数据 --
function BattleUtility.CreateFirstFightParameters()
    -- 总配置 --
    local firstFight = require "StaticData.FirstFight.FirstFight":GetData(1)

    local mapID = firstFight:GetMapID()

    -- 关卡数据 --
    local levelData = require "StaticData.ChapterLevel":GetData(mapID)

    -- @敌人队伍 --
    local battleUtility = require "Utils.BattleUtility"
    local leftTeams = battleUtility.CreateBattleTeamsByLevelID(mapID)

    -- @己方队伍 --
    local firstFightArmy = require "StaticData.FirstFight.FirstFightArmy":GetData(1)

    local rightTeam = BattleTeamParameter.New()
    rightTeam:AddUnit( CreateStaticBattleUnitParameter(firstFightArmy:GetArmyID01(), firstFightArmy:GetArmyColor01(), firstFightArmy:GetArmyLevel01(), 5, GetTableFromArray(firstFightArmy:GetArmyAbility01()), 1) )
    rightTeam:AddUnit( CreateStaticBattleUnitParameter(firstFightArmy:GetArmyID02(), firstFightArmy:GetArmyColor02(), firstFightArmy:GetArmyLevel02(), 5, GetTableFromArray(firstFightArmy:GetArmyAbility02()), 2) )
    rightTeam:AddUnit( CreateStaticBattleUnitParameter(firstFightArmy:GetArmyID03(), firstFightArmy:GetArmyColor03(), firstFightArmy:GetArmyLevel03(), 5, GetTableFromArray(firstFightArmy:GetArmyAbility03()), 3) )
    rightTeam:AddUnit( CreateStaticBattleUnitParameter(firstFightArmy:GetArmyID04(), firstFightArmy:GetArmyColor04(), firstFightArmy:GetArmyLevel04(), 5, GetTableFromArray(firstFightArmy:GetArmyAbility04()), 4) )
    rightTeam:AddUnit( CreateStaticBattleUnitParameter(firstFightArmy:GetArmyID05(), firstFightArmy:GetArmyColor05(), firstFightArmy:GetArmyLevel05(), 5, GetTableFromArray(firstFightArmy:GetArmyAbility05()), 5) )
    rightTeam:AddUnit( CreateStaticBattleUnitParameter(firstFightArmy:GetArmyID06(), firstFightArmy:GetArmyColor06(), firstFightArmy:GetArmyLevel06(), 5, GetTableFromArray(firstFightArmy:GetArmyAbility06()), 6) )

    -- @允许播放波数 --
    local ableSkillWaves = GetTableFromArray(firstFight:GetAbleSkillWave())

    -- @地图ID --
    local sceneID = levelData:GetSceneID()

    -- @剧本ID --
    local scriptID = levelData:GetPlotID()

    return leftTeams, rightTeam, ableSkillWaves, sceneID, scriptID
end

-- 通过teamID创建队伍数组
function BattleUtility.CreateBattleTeamsByIDs(uniformLevel, uniformStage, ...)
    local teamIds = {...} -- 输入的ID列表
    local foeTeamMgr = require "StaticData.FoeTeam"

    -- 参数处理.
    if type(uniformLevel) ~= "number" or uniformLevel <= 0 then
        uniformLevel = nil
    end

    if type(uniformStage) ~= "number" or uniformStage <= 0 then
        uniformStage = nil
    end

    -- 收集队伍.
    local retTeams = {}

    local maxTeamCount = table.maxn(teamIds)

    for i = 1, maxTeamCount do
        if type(teamIds[i]) == "number" and teamIds[i] > 0 then
            local teamData = foeTeamMgr:GetData(teamIds[i])
            if teamData ~= nil then
                local newBattleTeam = BattleTeamParameter.New()
                newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID01(), teamData:GetFoeColor01(), uniformLevel or teamData:GetFoeLevel01(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility01()), 1, teamData:GetFoeScaleRate01()) )
                newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID02(), teamData:GetFoeColor02(), uniformLevel or teamData:GetFoeLevel02(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility02()), 2, teamData:GetFoeScaleRate02()) )
                newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID03(), teamData:GetFoeColor03(), uniformLevel or teamData:GetFoeLevel03(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility03()), 3, teamData:GetFoeScaleRate03()) )
                newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID04(), teamData:GetFoeColor04(), uniformLevel or teamData:GetFoeLevel04(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility04()), 4, teamData:GetFoeScaleRate04()) )
                newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID05(), teamData:GetFoeColor05(), uniformLevel or teamData:GetFoeLevel05(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility05()), 5, teamData:GetFoeScaleRate05()) )
                newBattleTeam:AddUnit( CreateStaticBattleUnitParameter(teamData:GetFoeID06(), teamData:GetFoeColor06(), uniformLevel or teamData:GetFoeLevel06(), uniformStage or 0, GetTableFromArray(teamData:GetFoeAbility06()), 6, teamData:GetFoeScaleRate06()) )
                retTeams[#retTeams + 1] = newBattleTeam
            end
        end
    end

    return retTeams
end

return BattleUtility

