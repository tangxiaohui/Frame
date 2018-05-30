require "Object.LuaGameObject"
require "LUT.ArrayString"
require "Battle.Skill.BattleSkill"
require "Battle.Skill.Attack"
require "Battle.Skill.ActiveSkill"
require "Const"
local RoleUtility = require "Utils.RoleUtility"

local Rate2Ratio = 0.01
local Ratio2Rate = 100

Role = Class(LuaGameObject)

function Role:Ctor()
	self.equipmentProperties = require "Game.Property.PropertySet".New()   -- 装备
	self.tarotProperties = require "Game.Property.PropertySet".New()       -- 塔罗牌
	self.elvenTreeProperties = require "Game.Property.PropertySet".New()   -- 精灵树
	self.zodiacProperties = require "Game.Property.PropertySet".New() 	   -- 小宇宙
	self.breakProperties = require "Game.Property.PropertySet".New() 	   -- 突破
end

local function AddTalentStateIntoArray(array, talent)
	if talent == nil or talent <= 0 then
		return
	end
	array[#array + 1] = talent
end

local function GetActualAttackSkill(self, defaultAttackId)
	local skillIdToUse = defaultAttackId

	-- 选择要替代的技能ID --
	local skillIds = self.skillTalents:GetExtendIDs()
	if #skillIds > 0 and skillIds[1] > 0 then
		skillIdToUse = skillIds[1]
	end

	-- 返回技能引用 --
	local skillMgr = require "StaticData.Skill"
	return Attack.New(skillMgr:GetData(skillIdToUse))
end

local function InitStaticData(self)
	-- 静态表数据
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.id)

	-- 进阶表
	local addMgr = require "StaticData.RoleImprove"
	self.roleImproveMgr = addMgr

	-- 静态技能配置
	local skillMgr = require "StaticData.Skill"
	local skillId = self.data:GetSkill()

	-- ### 个人天赋 ### --
	self.immunityTalents = RoleUtility.GetRoleTalents(self.talents, kTalentType_Immunity)
	self.propertyTalents = RoleUtility.GetRoleTalents(self.talents, kTalentType_Property)
	self.skillTalents = RoleUtility.GetRoleTalents(self.talents, kTalentType_Skill)
	self.cardGroupTalents = RoleUtility.GetRoleTalents(self.talents, kTalentType_CardGroup)
	self.raceTalents = RoleUtility.GetRoleTalents(self.talents, kTalentType_Race)

	-- ### 团队天赋 ### --
	self.teamRaceTalents = RoleUtility.GetRoleTalents(self.teamTalents, kTalentType_Race)

	-- 技能初始化 --
	self.attackSkill = GetActualAttackSkill(self, skillId:get_Item(0))				-- 普攻
	self.activeSkill = ActiveSkill.New(skillMgr:GetData(skillId:get_Item(1)))		-- 主动
	self.passiveSkill = BattleSkill.New(skillMgr:GetData(skillId:get_Item(2)))		-- 被动
	
	local zodiacMgr = require "StaticData.Zodiac.Zodiac"
	self.zodiac = zodiacMgr:GetData(self.data:GetZodiac())
end

local function UpdateEquipData(self)
	self.equipmentProperties:ClearAll()

	local equipDataUtils = require "Utils.EquipDataUtils"
	equipDataUtils.GetPropertySetOnCard(self, self.equipmentProperties)
end

function Role:SetEquipDataList(equipDataList)
	if self.equipDataList ~= equipDataList then
		self.equipDataList = equipDataList
		UpdateEquipData(self)
	end
end

function Role:GetEquipDataList()
	return self.equipDataList
end

function Role:UpdateForStatic(id, color, lv, stage, talents)
	self.uid = ""
	self.id = id
	self.level = lv
	self.color = color
	self.exp = 0
	self.stage = stage or 0
	self.playerID = 0

	-- 天赋
	self.talents = talents or {}

	InitStaticData(self)
end


local function InitEquipData(self)
	if self.uid == nil or self.uid == "" then
		return
	end

	local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
	local equipBagMgr = dataCacheMgr:GetData(UserDataType.EquipBagData)
	if equipBagMgr ~= nil then
		self.equipDataList = equipBagMgr:GetAllEquipsOnCard(self.uid)
		UpdateEquipData(self)
	end
end

-- 塔罗牌
local function UpdateTarotProperties(self)
	self.tarotProperties:ClearAll()

	local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
	local tarotData = dataCacheMgr:GetData(UserDataType.TarotData)
	if tarotData ~= nil then
		tarotData:GetAllProperies(self.tarotProperties)
	end
end

function Role:UpdateTarotCache()
	UpdateTarotProperties(self)
end

-- 精灵树
local function UpdateElvenTreeProperties(self)
	self.elvenTreeProperties:ClearAll()

	local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
	local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)
	if playerData ~= nil then
		local treeLevel = playerData:GetTreeLevel()
		require "Utils.Utility".GetTreeUpAddProperty(treeLevel, self.elvenTreeProperties)
	end
end

function Role:UpdateElvenTreeCache()
	UpdateElvenTreeProperties(self)
end

-- 小宇宙
local function UpdateZodiacProperties(self)
	self.zodiacProperties:ClearAll()
	require "Utils.RoleUtility".GetAllZodiacProperties(self, self.zodiacProperties)
end

local function UpdateBreakProperties(self)
	self.breakProperties:ClearAll()
	require "StaticData.BreakThrough.BreakTrough":GetData(self.breakLevel):GetAllProperties(self.breakProperties)
end

function Role:Update(data)
	-- 基本属性
	self.uid = data.uid
	self.id = data.id
	self.level = data.level
	self.color = data.color
	self.exp = data.exp
	self.stage = data.stage
	self.playerID = data.playerID
	self.alrLigSpot = data.alrLigSpot

	--突破
	self.breakLevel = data.breakLevel or 0
	self.breakExp = data.breakExp

	-- 天赋
	self.talents = {}
	AddTalentStateIntoArray(self.talents, data.talent1)
	AddTalentStateIntoArray(self.talents, data.talent2)
	AddTalentStateIntoArray(self.talents, data.talentA)
	AddTalentStateIntoArray(self.talents, data.talentB)
	AddTalentStateIntoArray(self.talents, data.talentC)

	--团队天赋
	self.teamTalents = {}
	AddTalentStateIntoArray(self.teamTalents, data.teamTalentA)
	AddTalentStateIntoArray(self.teamTalents, data.teamTalentB)
	AddTalentStateIntoArray(self.teamTalents, data.teamTalentC)

	-- 初始化静态数据
	InitStaticData(self)

	-- 计算额外属性
	InitEquipData(self)
	UpdateTarotProperties(self) 		-- 塔罗牌
	UpdateElvenTreeProperties(self)		-- 精灵树
	UpdateZodiacProperties(self)		-- 小宇宙
	UpdateBreakProperties(self)			-- 突破
end

function Role:ToString()
	return self.data:ToString()..string.format(" 颜色= %s, 等级= %s, 血量= %s, 攻击力= %s, 防御力= %s, 速度= %s, 闪避率= %s, 技能= [%s-%s-%s]", 
								Color[self.color], self.level, self:GetHp(), self:GetAp(), self:GetDp(), self:GetSpeed(), self:GetAvoidRate(),
								self.attackSkill:GetId(), self.activeSkill:GetId(), self.passiveSkill:GetId())
end

function Role:IsImmuneToState(id)
	return self.immunityTalents:IsImmuneToState(id)
end

function Role:GetCardGroupTalents()
	return self.cardGroupTalents
end

function Role:GetRaceTalents()
	return self.raceTalents
end

function Role:GetTeamRaceTalents()
	return self.teamRaceTalents
end

function Role:GetNeedCardSuipianNum()
	if self.color >= KCardColorType_Purple and self.stage >= 0 and self.stage < KCardStageMax then
		local RoleImproveMgr = require "StaticData.RoleImprove"
		local improveData = RoleImproveMgr:GetData(self.stage)
		if improveData ~= nil then
			return improveData:GetNeedCardSuipianNum()
		end
	end
	return nil
end

function Role:GetStaticData()
	return self.data
end

function Role:GetUid()
	return self.uid
end

function Role:GetId()
	return self.id
end

function Role:GetZodiac()
	return self.zodiac
end

function Role:GetActivedZodiacSpot()
	return self.alrLigSpot
end

function Role:GetExp()
	return self.exp
end

function Role:GetStage()
	return self.stage
end

function Role:GetPlayerID()
	return self.playerID
end

--获取人物天赋
function Role:GetTalentByStage(stage)
	return self.talents[stage]
end

function Role:GetTalentCount()
	return #self.talents
end
--获取人物团队天赋
function Role:GetTeamTalentByStage(stage)
	return self.teamTalents[stage]
end

function Role:GetTeamTalentCount()
	return #self.teamTalents
end

function Role:GetInfo()
	return self.data:GetInfo()
end

function Role:GetColor()
	return self.color
end

function Role:GetLv()
	return self.level
end

function Role:GetBreakLevel()
	return self.breakLevel
end

function Role:GetBreakExp()
	return self.breakExp
end


---------------------------------------------------------
-------------- ####### 血量相关计算 ####### --------------
---------------------------------------------------------

-- 基础血量计算：(((1+基础属性系数*3) *600* (0.2+人物等级/100) -70))*血系数*成长值
local function GetBasicHp(data, color, level, stage)
	return data:GetBasicHp(color, level, stage)
end

-- 获得人物血量
function Role:GetHpValue(color, level, stage)
	local v1 = GetBasicHp(self.data, color or self.color, level or self.level, stage or self.stage)
	local v2 = self.propertyTalents:GetTotalHpLimit()
	local v3 = self.equipmentProperties:GetValue(kPropertyID_HpLimit)
	local v4 = self.tarotProperties:GetValue(kPropertyID_HpLimit)
	local v5 = self.elvenTreeProperties:GetValue(kPropertyID_HpLimit)
	local v6 = self.zodiacProperties:GetValue(kPropertyID_HpLimit)
	local v7 = self.breakProperties:GetValue(kPropertyID_HpLimit)
	--debug_print(string.format("[血量固定值] >>>> 角色ID: %s, 基础: %s, 个人属性天赋: %s, 装备: %s, 塔罗牌: %s, 精灵树: %s, 星座: %s", self.id, v1, v2, v3, v4, v5, v6))
	return v1 + v2 + v3 + v4 + v5 + v6 + v7
end

function Role:GetHpRate()
	local r1 = self.data:GetHpRatio() * Ratio2Rate
	local r2 = self.propertyTalents:GetTotalHpLimitRate()
	local r3 = self.equipmentProperties:GetValue(kPropertyID_HpLimitRate)
	local r4 = self.tarotProperties:GetValue(kPropertyID_HpLimitRate)
	local r5 = self.elvenTreeProperties:GetValue(kPropertyID_HpLimitRate)
	local r6 = self.zodiacProperties:GetValue(kPropertyID_HpLimitRate)
	local r7 = self.breakProperties:GetValue(kPropertyID_HpLimitRate)
	--debug_print(string.format("[血量百分比] >>>> 角色ID: %s, 基本: %s%%, 个人属性天赋: %s%%, 装备: %s%%, 塔罗牌: %s%%, 精灵树: %s%%, 星座: %s%%", self.id, r1, r2, r3, r4, r5, r6))
	return r1 + r2 + r3 + r4 + r5 + r6 + r7
end

-- #### 获取当前最大血量 #### --
function Role:GetHp(color, level, stage)
	return math.floor(self:GetHpValue(color, level, stage) * self:GetHpRate() * Rate2Ratio)
end

-- 获得人物下一品的血量
function Role:GetNextColorHp()
	local color = math.min(self.color + 1, KCardColorType_Purple)
	return self:GetHp(color)
end

-- 获得人物下一阶的血量
function Role:GetNextStageHp()
	return self:GetHp(nil, nil, self.stage + 1)
end


-------------- ### 攻击力相关计算 ### --------------

-- 基础攻击力计算：((1-基础属性系数*4)*100*(0.2+人物等级/100))*攻击系数*成长值
local function GetBasicAp(data, color, level, stage)
	return data:GetBasicAp(color, level, stage)
end

function Role:GetApValue(color, level, stage)
	local v1 = GetBasicAp(self.data, color or self.color, level or self.level, stage or self.stage)
	local v2 = self.propertyTalents:GetTotalAp()
	local v3 = self.equipmentProperties:GetValue(kPropertyID_Ap)
	local v4 = self.tarotProperties:GetValue(kPropertyID_Ap)
	local v5 = self.elvenTreeProperties:GetValue(kPropertyID_Ap)
	local v6 = self.zodiacProperties:GetValue(kPropertyID_Ap)
	local v7 = self.breakProperties:GetValue(kPropertyID_Ap)
	--debug_print(string.format("[攻击固定值] >>>> 角色ID: %s, 基础: %s, 个人属性天赋: %s, 装备: %s, 塔罗牌: %s, 精灵树: %s, 星座: %s", self.id, v1, v2, v3, v4, v5, v6))
	return v1 + v2 + v3 + v4 + v5 + v6 + v7
end

function Role:GetApRate()
	local r1 = self.data:GetApRatio() * Ratio2Rate
	local r2 = self.propertyTalents:GetTotalApRate()
	local r3 = self.equipmentProperties:GetValue(kPropertyID_ApRate)
	local r4 = self.tarotProperties:GetValue(kPropertyID_ApRate)
	local r5 = self.elvenTreeProperties:GetValue(kPropertyID_ApRate)
	local r6 = self.zodiacProperties:GetValue(kPropertyID_ApRate)
	local r7 = self.breakProperties:GetValue(kPropertyID_ApRate)
	--debug_print(string.format("[攻击百分比] >>>> 角色ID: %s, 基本: %s%%, 个人属性天赋: %s%%, 装备: %s%%, 塔罗牌: %s%%, 精灵树: %s%%, 星座: %s%%", self.id, r1, r2, r3, r4, r5, r6))
	return r1 + r2 + r3 + r4 + r5 + r6 + r7
end


function Role:GetAp(color, level, stage)
	return math.floor(self:GetApValue(color, level, stage) * self:GetApRate() * Rate2Ratio)
end

-- 获取下一品攻击力
function Role:GetNextColorAp()
	local nextColor = math.min(self.color + 1 , KCardColorType_Purple)
	return self:GetAp(nextColor)
end

-- 获取下一阶攻击力
function Role:GetNextStageAp()
	local nextStage = math.min(self.stage + 1,KCardStageMax + 1)
	return self:GetAp(nil, nil, nextStage)
end

-------------- ### 防御力相关计算 ### --------------

-- 基础防御力计算：(1+基础属性系数*3)*速度系数*人物等级*24
local function GetBasicDp(data, color, level)
	return data:GetBasicDp(color, level)
end

-- 获得人物的防御力(最终的)
-- local function GetRoleDp(self, data, color, lv)
-- 	local ret = (GetBasicDp(data, color, lv) + self.propertyTalents:GetTotalDp()) * self.data:GetDpRatio()
-- 	return math.floor(ret)
-- end

function Role:GetDpValue(color, level)
	local v1 = GetBasicDp(self.data, color or self.color, level or self.level)
	local v2 = self.propertyTalents:GetTotalDp()
	local v3 = self.equipmentProperties:GetValue(kPropertyID_Dp)
	local v4 = self.tarotProperties:GetValue(kPropertyID_Dp)
	local v5 = self.elvenTreeProperties:GetValue(kPropertyID_Dp)
	local v6 = self.zodiacProperties:GetValue(kPropertyID_Dp)
	local v7 = self.breakProperties:GetValue(kPropertyID_Dp)
	--debug_print(string.format("[防御固定值] >>>> 角色ID: %s, 基础: %s, 个人属性天赋: %s, 装备: %s, 塔罗牌: %s, 精灵树: %s, 星座: %s", self.id, v1, v2, v3, v4, v5, v6))
	return v1 + v2 + v3 + v4 + v5 + v6 + v7
end

function Role:GetDpRate()
	local r1 = self.data:GetDpRatio() * Ratio2Rate
	local r2 = self.equipmentProperties:GetValue(kPropertyID_DpRate)
	local r3 = self.tarotProperties:GetValue(kPropertyID_DpRate)
	local r4 = self.elvenTreeProperties:GetValue(kPropertyID_DpRate)
	local r5 = self.zodiacProperties:GetValue(kPropertyID_DpRate)
	local r6 = self.breakProperties:GetValue(kPropertyID_DpRate)
	--debug_print(string.format("[防御百分比] >>>> 角色ID: %s, 基本: %s%%, 装备: %s%%, 塔罗牌: %s%%, 精灵树: %s%%, 星座: %s%%", self.id, r1, r2, r3, r4, r5))
	return r1 + r2 + r3 + r4 + r5 + r6
end

function Role:GetDp(color, level, stage)
	return math.floor(self:GetDpValue(color, level, stage) * self:GetDpRate() * Rate2Ratio)
end

-- 获取下一品防御力
function Role:GetNextColorDp()
	local nextColor = math.min(self.color + 1 , KCardColorType_Purple)
	return self:GetDp(nextColor)
end

function Role:GetNextStageDp()
	return self:GetDp()
end

-------------- ### 速度相关计算 ### --------------

function Role:GetSpeedValue()
	local v1 = self.propertyTalents:GetTotalSpeed()
	local v2 = self.data:GetSpeed()
	local v3 = self.equipmentProperties:GetValue(kPropertyID_Speed)
	local v4 = self.tarotProperties:GetValue(kPropertyID_Speed)
	local v5 = self.elvenTreeProperties:GetValue(kPropertyID_Speed)
	local v6 = self.zodiacProperties:GetValue(kPropertyID_Speed)
	local v7 = self.breakProperties:GetValue(kPropertyID_Speed)
	return v1 + v2 + v3 + v4 + v5 + v6 + v7
end

function Role:GetSpeedRate()
	return 100 -- 基本速度系数
end

function Role:GetSpeed()
	return math.floor(self:GetSpeedValue() * self:GetSpeedRate() * Rate2Ratio)
end


-- # 命中率 # --
function Role:GetHitRate()
	local r1 = self.data:GetHitRate()
	local r2 = self.propertyTalents:GetTotalHitRate()
	local r3 = self.equipmentProperties:GetValue(kPropertyID_HitRate)
	local r4 = self.tarotProperties:GetValue(kPropertyID_HitRate)
	local r5 = self.elvenTreeProperties:GetValue(kPropertyID_HitRate)
	local r6 = self.zodiacProperties:GetValue(kPropertyID_HitRate)
	local r7 = self.breakProperties:GetValue(kPropertyID_HitRate)
	--debug_print(string.format("[命中率] >>>> 角色ID:%s, r1:%s, r2:%s, r3:%s, r4:%s, r5:%s, r6:%s", self.id, r1, r2, r3, r4, r5, r6))
	return r1 + r2 + r3 + r4 + r5 + r6 + r7
end

-- # 闪避率 # --
function Role:GetAvoidRate()
	local r1 = self.data:GetAvoidRate()
	local r2 = self.propertyTalents:GetTotalAvoidRate()
	local r3 = self.equipmentProperties:GetValue(kPropertyID_AvoidRate)
	local r4 = self.tarotProperties:GetValue(kPropertyID_AvoidRate)
	local r5 = self.elvenTreeProperties:GetValue(kPropertyID_AvoidRate)
	local r6 = self.zodiacProperties:GetValue(kPropertyID_AvoidRate)
	local r7 = self.breakProperties:GetValue(kPropertyID_AvoidRate)
	--debug_print(string.format("[闪避率] >>>> 角色ID:%s, r1:%s, r2:%s, r3:%s, r4:%s, r5:%s, r6:%s", self.id, r1, r2, r3, r4, r5, r6))
	return r1 + r2 + r3 + r4 + r5 + r6 + r7
end

-- # 暴击率 # --
function Role:GetCritRate()
	local r1 = self.data:GetCritRate()
	local r2 = self.propertyTalents:GetTotalCritRate()
	local r3 = self.equipmentProperties:GetValue(kPropertyID_CritRate)
	local r4 = self.tarotProperties:GetValue(kPropertyID_CritRate)
	local r5 = self.elvenTreeProperties:GetValue(kPropertyID_CritRate)
	local r6 = self.zodiacProperties:GetValue(kPropertyID_CritRate)
	local r7 = self.breakProperties:GetValue(kPropertyID_CritRate)
	--debug_print(string.format("[暴击率] >>>> 角色ID:%s, r1:%s, r2:%s, r3:%s, r4:%s, r5:%s, r6:%s", self.id, r1, r2, r3, r4, r5, r6))
	return r1 + r2 + r3 + r4 + r5 + r6 + r7
end

-- # 抗暴率 # --
function Role:GetDecritRate()
	local r1 = self.data:GetDecritRate()
	local r2 = self.propertyTalents:GetTotalDecritRate()
	local r3 = self.equipmentProperties:GetValue(kPropertyID_DecritRate)
	local r4 = self.tarotProperties:GetValue(kPropertyID_DecritRate)
	local r5 = self.elvenTreeProperties:GetValue(kPropertyID_DecritRate)
	local r6 = self.zodiacProperties:GetValue(kPropertyID_DecritRate)
	local r7 = self.breakProperties:GetValue(kPropertyID_DecritRate)
	--debug_print(string.format("[抗暴率] >>>> 角色ID:%s, r1:%s, r2:%s, r3:%s, r4:%s, r5:%s, r6:%s", self.id, r1, r2, r3, r4, r5, r6))
	return r1 + r2 + r3 + r4 + r5 + r6 + r7
end

function Role:GetRace()
	return self.data:GetRace()
end

function Role:GetMajorAttr()
	return self.data:GetMajorAttr()
end

function Role:GetGender()
	return self.data:GetGender()
end

-- 攻击
function Role:GetAttackSkill()
	return self.attackSkill
end

-- 技能
function Role:GetActiveSkill()
	return self.activeSkill
end

-- 被动
function Role:GetPassiveSkill()
	return self.passiveSkill
end


function Role:GetLinkageRate()
	return self.data:GetLinkageRate()
end

function Role:GetCritDamage()
	return self.data:GetCritDamage() 
		+ (
			self.propertyTalents:GetTotalCritDamage() 
			+ self.equipmentProperties:GetValue(kPropertyID_CritDamageRate) 
			+ self.tarotProperties:GetValue(kPropertyID_CritDamageRate) 
			+ self.elvenTreeProperties:GetValue(kPropertyID_CritDamageRate)
			+ self.zodiacProperties:GetValue(kPropertyID_CritDamageRate)
			+ self.breakProperties:GetValue(kPropertyID_CritDamageRate)
		) / 100
end

function Role:GetSkillDamage()
	return self.data:GetSkillDamage() 
			+ self.propertyTalents:GetTotalSkillDamage() 
			+ self.equipmentProperties:GetValue(kPropertyID_SkillDamage) 
			+ self.tarotProperties:GetValue(kPropertyID_SkillDamage) 
			+ self.elvenTreeProperties:GetValue(kPropertyID_SkillDamage)
			+ self.zodiacProperties:GetValue(kPropertyID_SkillDamage)
			+ self.breakProperties:GetValue(kPropertyID_SkillDamage)
end

function Role:GetAttackDamage()
	return self.data:GetAttackDamage() 
			+ self.propertyTalents:GetTotalAttackDamage() 
			+ self.equipmentProperties:GetValue(kPropertyID_AttackDamage) 
			+ self.tarotProperties:GetValue(kPropertyID_AttackDamage) 
			+ self.elvenTreeProperties:GetValue(kPropertyID_AttackDamage)
			+ self.zodiacProperties:GetValue(kPropertyID_AttackDamage)
			+ self.breakProperties:GetValue(kPropertyID_AttackDamage)
end

function Role:GetVamRate()
	return self.data:GetVamRate() 
			+ self.propertyTalents:GetTotalVamRate() 
			+ self.equipmentProperties:GetValue(kPropertyID_VamRate) 
			+ self.tarotProperties:GetValue(kPropertyID_VamRate) 
			+ self.elvenTreeProperties:GetValue(kPropertyID_VamRate)
			+ self.zodiacProperties:GetValue(kPropertyID_VamRate)
			+ self.breakProperties:GetValue(kPropertyID_VamRate)
end

function Role:GetMoveTime()
	return self.data:GetMoveTime()
end

function Role:GetStar()
	return self.data:GetStar()
end

function Role:GetRarity()
	return self.data:GetRarity()
end

function Role:GetModelScale()
	return self.data:GetModelScale()
end

-- 进攻能力计算：(攻击*攻击系数)*(1+(暴击率/100)*(暴击伤害-1)*暴击系数)*(1+(命中率/100)*命中系数)*(1+速度*速度系数)*角色进攻调节系数+技攻伤害*技能伤害系数+普攻伤害*普攻伤害系数
local function GetOffenseAbillity(self,ap)
	local mgr = require "StaticData.PowerRatio"
	local powerRatio = mgr:GetData(0)

	local roleAp = ap or self:GetAp()
	local t1 = roleAp * powerRatio:GetApRatio()     -- (攻击*攻击系数)

	-- double t2= 1 + (fightData.getBaojiProp()/100.0)* ((fightData.getBaojiHurt() - 1)*fightDataCalXishuConfig.getBaoji());
	local t2 = 1 + (self:GetCritRate()/100) * ((self:GetCritDamage() - 1) * powerRatio:GetCritRatio()) -- (1+(暴击率/100)*(暴击伤害-1)*暴击系数)

	-- double t3= 1 + fightData.getMingzhongProp()/100.0*fightDataCalXishuConfig.getMingzhong();
	local t3 = 1 + self:GetHitRate() / 100 * powerRatio:GetHitRatio() -- (1+(命中率/100)*命中系数)*

	-- 1 + fightData.getSpeed() * fightDataCalXishuConfig.getSudu();
	local t4 = 1 + self:GetSpeed() * powerRatio:GetSpeedRatio()  -- (1+速度*速度系数)

	-- fightData.getOffenseRatio();
	local t5 = self.data:GetOffenseRatio()  -- *角色进攻调节系数

	-- double t6= fightData.getJigongHurt()*fightDataCalXishuConfig.getJigong();
	local t6 = self:GetSkillDamage() * powerRatio:GetSkillDamageRatio()		-- (技攻伤害*技能伤害系数)

	-- double t7= fightData.getPugongHurt()*fightDataCalXishuConfig.getPugong();
	local t7 = self:GetAttackDamage() * powerRatio:GetAttackDamageRatio()	-- (普攻伤害*普攻伤害系数)

    -- debug_print(
	-- 	string.format(
	-- 		"[进攻能力计算] >>>> 角色ID:%s, t1:%f, t2:%f, t3:%f, t4:%f, t5:%f, t6:%f, t7:%f, 总值:%f",
	-- 		self.id,
	-- 		t1,t2,t3,t4,t5,t6,t7,
	-- 		t1 * t2 * t3 * t4 * t5 + t6 + t7
	-- 	)
	-- )

	return t1 * t2 * t3 * t4 * t5 + t6 + t7
end



-- 防御能力计算：(血量*血系数+防御*防御系数+攻击力*吸血/100*吸血系数)*(1+闪避率/100*闪避系数)*(1+抗暴率/100*(暴击伤害-1)*抗暴系数)*角色防御调节系数
local function GetDefenseAbillity(self,hp,ap,dp)
	local mgr = require "StaticData.PowerRatio"
	local powerRatio = mgr:GetData(0)
	local roleHp = hp or self:GetHp()
	local roleAp = ap or self:GetAp()
	local roleDp = dp or self:GetDp()
	local t1 = (roleHp * powerRatio:GetHpRatio()+ roleDp * powerRatio:GetDpRatio() + roleAp * (self:GetVamRate()/100) * powerRatio:GetVamRatio())
	local t2 = (1 + self:GetAvoidRate()/100 * powerRatio:GetAvoidRatio())
	local t3 = (1 + (self:GetDecritRate()/100) * (self:GetCritDamage()-1) * powerRatio:GetDecritRatio())
	local t4 = self.data:GetDefenseRatio()


    -- debug_print(
	-- 	string.format(
	-- 		"进攻能力, t3>>>>>>>>> 角色ID:%f, 命中率:%f, 命中系数:%f", 
	-- 		self.id,
	-- 		self:GetHitRate(),
	-- 		powerRatio:GetHitRatio()
	-- 	)
	-- )

	-- debug_print(
	-- 	string.format(
	-- 		"[防御能力计算] >>>> 角色ID:%s, t1:%s, t2:%s, t3:%s, t4:%s, 总值:%s",
	-- 		self.id,
	-- 		t1,t2,t3,t4,
	-- 		t1 * t2 * t3 * t4
	-- 	)
	-- )
	
	return t1 * t2 * t3 * t4
end

function Role:GetPower(hp,ap,dp)
	local v1 = GetOffenseAbillity(self,ap)
	local v2 = GetDefenseAbillity(self,hp,ap,dp)
	-- debug_print(string.format("[总战斗力] >>>> 角色ID:%s, 总值:%s",self.id,math.floor(v1 + v2)))
	return math.floor(v1 + v2)
end

---------------------获取下一品战斗力------------------------------
function Role:GetNextColorPower()
	local hp = self:GetNextColorHp()
	local ap = self:GetNextColorAp()
	local dp = self:GetNextColorDp()
	return self:GetPower(hp,ap,dp)
end
--------------------------------------------------------------------
---------------------获取下一阶战斗力---------------------------------
--------------------------------------------------------------------
function Role:GetNextStagePower()
	local hp = self:GetNextStageHp()
	local ap = self:GetNextStageAp()
	local dp = self:GetNextStageDp()
	return self:GetPower(hp,ap,dp)
end
--------------------------------------------------------------------

function Role:GetHeadIcon()
	return self.data:GetHeadIcon()
end

function Role:GetPortraitImage()
	return self.data:GetPortraitImage()
end

function Role:GetMonolog()
	return self.data:GetMonolog()
end

function Role:GetScrapId()
	return self.data:GetScrapId()
end

function Role:GetComposeNum()
	return self.data:GetComposeNum()
end

function Role:IsShowInCollection()
	return self.data:IsShowInCollection()
end

function Role:GetbeishiID()
	return self.data:GetbeishiID()
end

-- 输出到 Protobuf 中 (cardMsg = OneCardItem, equipsMsg = EquipOnCardStruct)
function Role:CopyToProtobuf(cardMsg, equipsMsg)
	cardMsg.id = self:GetId()
	cardMsg.uid = self:GetUid()

	cardMsg.color = self:GetColor()
	cardMsg.level = self:GetLv()

	cardMsg.exp = self:GetExp()
	cardMsg.stage = self:GetStage()

	cardMsg.talent1 = self.talents[1] or 0
	cardMsg.talent2 = self.talents[2] or 0
	cardMsg.talentA = self.talents[3] or 0
	cardMsg.talentB = self.talents[4] or 0
	cardMsg.talentC = self.talents[5] or 0

	cardMsg.playerID = self:GetPlayerID()


	-- TODO 装备先不序列化

end

function Role:InitByProtobuf(cardMsg, equipsMsg)
	self.id = cardMsg.id
	self.uid = cardMsg.uid

	self.color = cardMsg.color
	self.level = cardMsg.level

	self.exp = cardMsg.exp
	self.stage = cardMsg.stage

	self.talents = {}
	AddTalentStateIntoArray(self.talents, cardMsg.talent1)
	AddTalentStateIntoArray(self.talents, cardMsg.talent2)
	AddTalentStateIntoArray(self.talents, cardMsg.talentA)
	AddTalentStateIntoArray(self.talents, cardMsg.talentB)
	AddTalentStateIntoArray(self.talents, cardMsg.talentC)


	self.playerID = cardMsg.playerID

	-- TODO 装备信息不反序列化

	InitStaticData(self)
end

-- 获取装备类型槽, 最大10个 --
function Role:GetEquipmentTypeSlots()
	return self.data:GetEquipmentTypeSlots()
end

-- 获得指定穿戴位置的装备类型 --
function Role:GetEquipmentTypeByPos(pos)
	return self.data:GetEquipmentTypeByPos(pos)
end

-- 获取装备槽类型(10) --
function Role:GetEquipmentSlotCount()
	return self.data:GetEquipmentSlotCount()
end

function Role:GetInitAngerNum()
	local anger = 3
	anger = anger + self.propertyTalents:GetTotalAngerNum()
	if anger > 5 then
		anger = 5
	end
	return anger
end


-- 获取总的攻击附加值
function Role:GetBasicTalentAp()
    return self.propertyTalents:GetTotalAp()
end

-- 获取总的攻击系数
function Role:GetBasicTalentApRate()
	return self.propertyTalents:GetTotalApRate()
end

-- 获取总的血量上限附加值
function Role:GetBasicTalentHpLimit()
	return self.propertyTalents:GetTotalHpLimit()
end

-- 获得总的血量上限系数
function Role:GetBasicTalentHpLimitRate()
	return self.propertyTalents:GetTotalHpLimitRate()
end

-- 获得总的防御附加值
function Role:GetBasicTalentDp()
	return self.propertyTalents:GetTotalDp()
end

-- 获取总的怒气值
function Role:GetBasicTalentAngerNum()
	return self.propertyTalents:GetTotalAngerNum()
end

-- 获得总的暴击率
function Role:GetBasicTalentCritRate()
	return self.propertyTalents:GetTotalCritRate()
end

-- 获得总的暴击伤害系数
function Role:GetBasicTalentCritDamage()
	return self.propertyTalents:GetTotalCritDamage()
end

-- 获得总的闪避率
function Role:GetBasicTalentAvoidRate()
	return self.propertyTalents:GetTotalAvoidRate()
end

-- 获得总的吸血率
function Role:GetBasicTalentVamRate()
	return self.propertyTalents:GetTotalVamRate()
end

-- 获取总的普攻附加伤害值
function Role:GetBasicTalentAttackDamage()
	return self.propertyTalents:GetTotalAttackDamage()
end

-- 获取总的技攻附加伤害值
function Role:GetBasicTalentSkillDamage()
	return self.propertyTalents:GetTotalSkillDamage()
end

-- 获取总的抗暴率
function Role:GetBasicTalentDecritRate()
	return self.propertyTalents:GetTotalDecritRate()
end

-- 获取总速度附加值
function Role:GetBasicTalentSpeed()
	return self.propertyTalents:GetTotalSpeed()
end

-- 获取总命中率
function Role:GetBasicTalentHitRate()
	return self.propertyTalents:GetTotalHitRate()
end