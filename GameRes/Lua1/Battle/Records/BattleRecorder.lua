--
-- User: fenghao
-- Date: 6/1/17
-- Time: 11:30 AM
--

-- 战斗记录器 用于记录战斗的情况 --

require "Object.LuaObject"
require "Collection.OrderedDictionary"
local utility = require "Utils.Utility"

local messageGuids = require "Framework.Business.MessageGuids"

local BattleRecorder = Class(LuaObject)

local DamageCardItemDataClass = require "Battle.Records.DamageCardItemData"

local DamageCardWaveDataClass = require "Battle.Records.DamageCardWaveData"

local myGame = utility.GetGame()

function BattleRecorder:Ctor(owner)

    -- battleNode
    self.owner = owner

    ------ ## 伤害总值记录 ## ------

    -- 记录己方所有人的伤害输出的情况 --
    -- [pos => DamageCardItemData]
    self.selfDamageCardDict = OrderedDictionary.New()

    -- [EnemyCardWaveData]
    -- 记录所有波敌人的伤害输出的情况 --
    self.enemyDamageWaves = {}

    ------ ## ----------- ## ------

    ------ ## 卡牌最终结果记录 ## ------

    -- TODO 还应该在OnFightExit时收集己方所有卡牌的最终数据
    self.selfCardItemResults = {}

    -- TODO 应该在OnWaveExit时收集当前波次的敌人卡牌数据
    self.enemyCardWaveResults = {}

    ------ ## -------------  ## ------

    -- 手动选择记录
    self.manuallyOperationDataList = {}

    ------ ## -------------  ## ------


    -- 当前波数 初始值为0 --
    self.currentWave = 0

    -- 当前回合, 初始化值为 0 --
    self.currentRound = 0
end

--- 处理消息 ---

-- # 处理己方的伤害输出添加 # --
local function HandleAddFriendDamage(self, pos, damageValue)
    local damageData = self.selfDamageCardDict:GetEntryByKey(pos)
    if damageData == nil then
        damageData = DamageCardItemDataClass.New(pos)
        self.selfDamageCardDict:Add(pos, damageData)
    end
    damageData:AddDamage(damageValue)
end

-- # 处理敌方的伤害输出添加 # --
local function HandleAddEnemyDamage(self, pos, damageValue)
    print("敌人波次伤害", self.currentWave, damageValue)
    local damageWaveData = self.enemyDamageWaves[self.currentWave]
    if damageWaveData == nil then
        error(string.format("没有通知更新当前波次, 导致记录时 拿不到数据"))
    end
    -- 增加伤害值
    damageWaveData:AddDamage(pos, damageValue)
end

-- # 添加伤害 # --
-- # A 打 B  50滴血 , 那么unit是A , damageValue为50滴血 --
local function OnAddDamage(self, sourceUnit, damageValue)
    if damageValue < 0 then
        return
    end

    if damageValue == 0 then
        damageValue = 1
    end

    print("伤害值 >>>>>>> ", damageValue)

    local pos = sourceUnit:GetLocation()
    local friend = (sourceUnit:OnGetSide() == 1)
    if friend then
        HandleAddFriendDamage(self, pos, damageValue)
    else
        HandleAddEnemyDamage(self, pos, damageValue)
    end
end

local function PrintDebugTest(self)
    -- 打印结果信息 --
    local stringTable = {}

    stringTable[#stringTable + 1] = ">>>> 玩家队伍的伤害信息 <<<<"

    local selfCount = self.selfDamageCardDict:Count()
    for i = 1, selfCount do
        local damageData = self.selfDamageCardDict:GetEntryByIndex(i)
        stringTable[#stringTable + 1] = damageData:ToString()
    end

    stringTable[#stringTable + 1] = ">>>> 敌人队伍的伤害信息 <<<<"

    for i = 1, #self.enemyDamageWaves do
        stringTable[#stringTable + 1] = string.format("****** 第 %d 波 ******", i)
        stringTable[#stringTable + 1] = self.enemyDamageWaves[i]:ToString()
        stringTable[#stringTable + 1] = "\n"
    end

    stringTable[#stringTable + 1] = ">>>>>>>>> 统计结束 <<<<<<<<<"

    print(table.concat(stringTable, "\n"))
end

-- # 到新的波次 # --
local function OnWaveEnter(self, wave)
    print(">>> OnWaveEnter <<<")

    -- 波次递增 --
    self.currentWave = self.currentWave + 1
    print(self.currentWave, wave)

    utility.ASSERT(self.currentWave == wave, "波次数不同步!")
    self.enemyDamageWaves[self.currentWave] = DamageCardWaveDataClass.New()
end

local function CollectionFoesCurrentWave(self)
    local EnemyCardWaveDataClass = require "Battle.Records.CardWaveStatusData"

    local enemyCardWaveData = self.enemyCardWaveResults[self.currentWave]
    if enemyCardWaveData == nil then
        local battlefield = self.owner:GetBattlefield()
        local members = battlefield:GetLeftTeam():GetMembers()
        if members ~= nil then
            enemyCardWaveData = EnemyCardWaveDataClass.New(members)
            self.enemyCardWaveResults[self.currentWave] = enemyCardWaveData
        end
    end
end

-- # 当前波次结束 # --
local function OnWaveExit(self)
    print(">>> OnWaveExit <<<")
    PrintDebugTest(self)
    CollectionFoesCurrentWave(self)
end


-- # 到达新的回合 # --
local function OnRoundEnter(self, round)
    print(">>> OnRoundEnter <<<")
    -- 回合递增 --
    self.currentRound = self.currentRound + 1
    utility.ASSERT(self.currentRound == round, "回合数不同步!")
    -- 暂时没有更新 --
end

local function OnRoundExit(self)
    print(">>> OnRoundExit <<<")
end

-- # 战斗开始/结束 # --
local function OnFightEnter(self)
    print(">>> OnFightEnter <<<")
end

local function OnFightExit(self)
    print(">>> OnFightExit <<<")

    -- 收集己方最终数据 --
    local CardItemDataClass = require "Battle.Records.CardStatusData"
    utility.ClearArrayTableContent(self.selfCardItemResults)

    local battlefield = self.owner:GetBattlefield()

    local members = battlefield:GetRightTeam():GetMembers()
    for _, v in pairs(members) do
        self.selfCardItemResults[#self.selfCardItemResults + 1] = CardItemDataClass.New(v)
    end

    -- 收集敌方数据(如果中途退出), 这句话加不加无关紧要 因为现在战斗是打完发战报!  中途退出不发战报
    -- 但是还是留着这个 --
    CollectionFoesCurrentWave(self)
end

local function OnRecordSkillSelection(self, wave, round, pos, retTargets, targetType, targetParam, discarded)
    print("记录技能选择 ---- ", wave, round, pos)

    local ManuallyOperationDataClass = require "Battle.Records.ManuallyOperationData"

    local manuallyOperationData = ManuallyOperationDataClass.New()
    manuallyOperationData:SetWave(wave)
    manuallyOperationData:SetRound(round)
    manuallyOperationData:SetPos(pos)
    manuallyOperationData:SetTargets(retTargets)
    manuallyOperationData:SetTargetType(targetType)
    manuallyOperationData:SetTargetParam(targetParam)
    manuallyOperationData:SetDiscard(discarded)

    self.manuallyOperationDataList[#self.manuallyOperationDataList + 1] = manuallyOperationData
end

-- 初始化函数
function BattleRecorder:Start()
    print("BattleRecorder:Start -- 1")

    -- 清除 --
    self.selfDamageCardDict:Clear()
    utility.ClearArrayTableContent(self.enemyDamageWaves)
    utility.ClearArrayTableContent(self.selfCardItemResults)
    utility.ClearArrayTableContent(self.enemyCardWaveResults)


    print("BattleRecorder:Start -- 2")
    -- 战斗 开始与结束
    --FightFightEnter
    myGame:RegisterEvent(messageGuids.FightFightEnter, self, OnFightEnter)
    myGame:RegisterEvent(messageGuids.FightFightExit, self, OnFightExit)

    print("BattleRecorder:Start -- 3")
    -- 波次 更新 注册
    myGame:RegisterEvent(messageGuids.FightWaveEnter, self, OnWaveEnter)
    myGame:RegisterEvent(messageGuids.FightWaveExit, self, OnWaveExit)

    print("BattleRecorder:Start -- 4")
    -- 回合 更新 注册
    myGame:RegisterEvent(messageGuids.FightRoundEnter, self, OnRoundEnter)
    myGame:RegisterEvent(messageGuids.FightRoundExit, self, OnRoundExit)

    print("BattleRecorder:Start -- 5")
    -- 添加伤害值记录(用于统计总伤害)
    myGame:RegisterEvent(messageGuids.FightAddDamageRecord, self, OnAddDamage)

    print("BattleRecorder:Start -- 6")
    -- 记录手动数据
    myGame:RegisterEvent(messageGuids.BattleSkillManuallySelection, self, OnRecordSkillSelection)

    print("****************************战斗记录初始化 ****************************")
end

-- 结束 函数
function BattleRecorder:Close()
    -- 战斗 开始与结束
    --FightFightEnter
    myGame:UnregisterEvent(messageGuids.FightFightEnter, self, OnFightEnter)
    myGame:UnregisterEvent(messageGuids.FightFightExit, self, OnFightExit)

    -- 波次 更新 注册
    myGame:UnregisterEvent(messageGuids.FightWaveEnter, self, OnWaveEnter)
    myGame:UnregisterEvent(messageGuids.FightWaveExit, self, OnWaveExit)

    -- 回合 更新 注册
    myGame:UnregisterEvent(messageGuids.FightRoundEnter, self, OnRoundEnter)
    myGame:UnregisterEvent(messageGuids.FightRoundExit, self, OnRoundExit)

    -- 添加伤害值记录(用于统计总伤害)
    myGame:UnregisterEvent(messageGuids.FightAddDamageRecord, self, OnAddDamage)

    -- 记录手动数据
    myGame:UnregisterEvent(messageGuids.BattleSkillManuallySelection, self, OnRecordSkillSelection)

end

---------------------------------------------------------------
-- 战斗记录的填充
---------------------------------------------------------------
local function Verify(self)
    utility.ASSERT(#self.selfCardItemResults > 0, "己方人物最终数据个数必须是大于0的")
    utility.ASSERT(self.currentWave > 0, "波次至少是1 才对!")

    utility.ASSERT(#self.enemyCardWaveResults == self.currentWave, "敌人卡牌波次数据未同步正确!")
    utility.ASSERT(#self.enemyDamageWaves == self.currentWave, "敌人伤害输出波次数据未同步正确!")
end

--- @@ 1. 填充己方卡牌数据 (msg = playerCardInfos)
local function CopySelfCardItemDataToProtobuf(self, msg)
    local count = #self.selfCardItemResults
    for i = 1, count do
        local itemData = self.selfCardItemResults[i]
        local pb = msg:add()
        itemData:CopyToProtobuf(pb)
    end
end

--- @@ 2. 填充敌方卡牌数据(多波) (msg = enemyCardWaveDatas)
local function CopyEnemyCardWaveDataToProtobuf(self, msg)
    local count = #self.enemyCardWaveResults
    for i = 1, count do
        local cardWaveResult = self.enemyCardWaveResults[i]
        local pbWaveData = msg:add() -- 新的一波怪 --
        cardWaveResult:CopyToProtobuf(pbWaveData.infos)
    end
end


--- @@ 3. 填充伤害输出结果

-- (msg = playerDamageData)
local function CopySelfDamageResultDataToProtobuf(self, msg)
    local count = self.selfDamageCardDict:Count()
    for i = 1, count do
        local damageData = self.selfDamageCardDict:GetEntryByIndex(i)
        local pb = msg:add()
        damageData:CopyToProtobuf(pb)
    end
end

-- (msg = enemyDamageWaveData)
local function CopyEnemyDamageResultWaveDataToProtobuf(self, msg)
    local count = #self.enemyDamageWaves
    for i = 1, count do
        local damageWaveData = self.enemyDamageWaves[i]
        local pbWaveData = msg:add()
        damageWaveData:CopyToProtobuf(pbWaveData.infos)
    end
end

-- (msg = damageResultData, DamageResultData)
local function CopyDamageResultDataToProtobuf(self, msg)
    -- >> 填充己方 << --
    CopySelfDamageResultDataToProtobuf(self, msg.playerDamageData)

    -- >> 填充敌方 << --
    CopyEnemyDamageResultWaveDataToProtobuf(self, msg.enemyDamageWaveData)
end

-------------------------------------------------------------------------------------

--- @@ 4. 填充详细行动序列 (msg = fightingData)
local function CopyProcessDataToProtobuf(self, msg)

    -- >> 1. 战斗用随机数种子
    msg.seed = self.owner:GetRandomSeed()

    -- >> 2. 战斗人物 信息 参数
    local battleParameter = self.owner:GetBattlefield():GetBattleParameter()
    battleParameter:CopyToProtobuf(msg)

    -- >> 3. 手动操作数据 (msg = fightingData)
    for i = 1, #self.manuallyOperationDataList do
        local currentMOData = self.manuallyOperationDataList[i]
        local pb = msg.moData:add()
        currentMOData:CopyToProtobuf(pb)

        print("记录手动数据", currentMOData.wave, currentMOData.round, currentMOData.pos)
    end

    -- >> 4. 战斗开始参数
    self.owner:GetBattleParams():CopyToProtobuf(msg.startParams)
end

-------------------------------------------------------------------------------------


-- 最终获得战斗记录的 --
function BattleRecorder:CopyToProtobuf(msg)
    Verify(self)

    -- @1. 填充己方卡牌数据
    CopySelfCardItemDataToProtobuf(self, msg.playerCardInfos)

    -- @2. 填充敌人卡牌数据(多波)
    CopyEnemyCardWaveDataToProtobuf(self, msg.enemyCardWaveDatas)

    -- @3. 填充伤害输出结果
    CopyDamageResultDataToProtobuf(self, msg.damageResultData)

    -- @4. 填充战斗流程数据
    CopyProcessDataToProtobuf(self, msg.fightingData)

end


return BattleRecorder
