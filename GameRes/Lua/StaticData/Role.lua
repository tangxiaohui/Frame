require "StaticData.Manager"
require "LUT.ArrayString"
require "Const"

RoleData = Class(LuaObject)

-- 默认装备槽
local DefaultEquipmentTypeSlots = {
	KEquipType_EquipWeapon,
	KEquipType_EquipArmor,
	KEquipType_EquipAccessories,
	KEquipType_EquipShoesr,
	KEquipType_EquipPet,
	KEquipType_EquipSpar,
	KEquipType_EquipFashion,
	--KEquipType_Public,
	--KEquipType_EquipInvalid, -- 坐骑(暂不开启!)
	KEquipType_EquipWing
}

local function InitStaticRoleEquipmentTypeSlots(self)
	local maxSlots = #DefaultEquipmentTypeSlots
	local weaponCount = math.min(self:GetCarriedWeapon(), maxSlots)
	
	-- 如果只有一件物品的话 就进行重用local 否则就创建新的table --
	if weaponCount == 1 then
		self.staticEquipmentTypeSlots = DefaultEquipmentTypeSlots
		return
	end

	self.staticEquipmentTypeSlots = {}
	
	local startPos = 1
	if weaponCount == 0 then
		self.staticEquipmentTypeSlots[1] = KEquipType_EquipArmor
		startPos = 2
	end

	for i = startPos, maxSlots do
		if i <= weaponCount then
			self.staticEquipmentTypeSlots[#self.staticEquipmentTypeSlots + 1] = KEquipType_EquipWeapon
		else
			self.staticEquipmentTypeSlots[#self.staticEquipmentTypeSlots + 1] = DefaultEquipmentTypeSlots[i]
		end
	end
end

function RoleData:Ctor(id)
	local roleMgr = Data.Role.Manager.Instance()
	local infoMgr = Data.RoleInfo.Manager.Instance()

	self.data = roleMgr:GetObject(id)
	if self.data == nil then
		error(string.format("角色数据初始化失败，角色ID: %s 不存在", id))
		return
	end
	self.info = infoMgr:GetObject(self.data.info)

	self.critDamage = self.data.critDamage 		-- 基础暴击伤害系数
	self.critRate = self.data.critRate 			-- 基础暴击率
	self.decritRate = self.data.decritRate 		-- 基础抗暴率
	self.hitRate = self.data.hitRate			-- 基础命中率
	self.avoidRate = self.data.avoidRate		-- 基础闪避率
	self.vamRate = self.data.vamRate			-- 基础吸血率

	self.attackDamage = self.data.attackDamage  -- 普攻伤害
	self.skillDamage = self.data.skillDamage	-- 技攻伤害

	InitStaticRoleEquipmentTypeSlots(self)
end

function RoleData:ToString()
	return string.format("角色= %s, id= %s, 性别= %s, 主属性= %s, 种族= %s, 星级= %s", 
	self.info.name, self.data.id, Gender[self.data.gender], MajorAttr[self.data.majorAttr], Race[self.data.race], self.data.star)
end

function RoleData:GetId()
	return self.data.id
end

function RoleData:GetInfoId()
	return self.data.info
end

function RoleData:GetInfo()
	local info = self.info
	return info.name, info.desc, info.passiveSkillName, info.passiveSkillDesc, info.activeSkillName, info.activeSkillDesc
end

function RoleData:GetGender()
	local index = self.data.gender
	return index, Gender[index]
end

function RoleData:GetAttrRatio()
	return self.data.attrRatio / 10000
end

-- 对应成长值表里的id
function RoleData:GetGrow()
	return self.data.grow
end

function RoleData:GetMajorAttr()
	local index = self.data.majorAttr
	return index, MajorAttr[index]
end

function RoleData:GetRace()
	local index = self.data.race
	return index, Race[index]
end

function RoleData:GetApRatio()
	return self.data.apRatio
end

function RoleData:GetDpRatio()
	return self.data.dpRatio
end

function RoleData:GetHpRatio()
	return self.data.hpRatio
end

function RoleData:GetSpeed()
	return self.data.speed
end

function RoleData:GetCarriedWeapon()
	return self.data.carriedWeapon
end

function RoleData:GetLinkageRate()
	return self.data.linkageRate
end

function RoleData:GetSkill()
	return self.data.skill
end

function RoleData:GetCritDamage()
	return self.critDamage
end

function RoleData:GetCritRate()
	return self.critRate
end

function RoleData:GetDecritRate()
	return self.decritRate
end

function RoleData:GetHitRate()
	return self.hitRate
end

function RoleData:GetAvoidRate()
	return self.avoidRate
end

function RoleData:GetVamRate()
	return self.vamRate
end

function RoleData:GetAttackDamage()
	return self.attackDamage
end

function RoleData:GetSkillDamage()
	return self.skillDamage
end

function RoleData:GetFinalApRatio()
	return self.data.finalApRatio
end

function RoleData:GetFinalDpRatio()
	return self.data.finalDpRatio
end

function RoleData:GetFinalHpRatio()
	return self.data.finalHpRatio
end

function RoleData:GetMoveTime()
	return self.data.moveTime
end

function RoleData:GetStar()
	return self.data.star
end

function RoleData:GetRarity()
	local rarityData = require "StaticData.StartoSSR":GetData(self.data.star)
	return rarityData:GetSSR()
end

function RoleData:GetModelScale()
	return self.data.modelScale
end

function RoleData:GetOffenseRatio()
	return self.data.offenseRatio
end

function RoleData:GetDefenseRatio()
	return self.data.defenseRatio
end

function RoleData:GetHeadIcon()
	return self.data.headIcon
end

function RoleData:GetPortraitImage()
	return self.data.portraitImage
end

function RoleData:GetMonolog()
	return self.info.monolog
end

function RoleData:GetDecomposeNum()
	return self.data.decomposeNum
end

function RoleData:GetComposeNum()
	return self.data.composeNum
end

function RoleData:GetScrapId()
	return self.data.scrapId
end

function RoleData:GetColorID()
	return self.data.colorID
end

function RoleData:GetColor()
	return self:GetColorID()
end

function RoleData:GetTalent1()
	return self.data.talent1
end

function RoleData:GetTalent2()
	return self.data.talent2
end

function RoleData:GetTalent3()
	return self.data.talent3
end

function RoleData:GetTalent4()
	return self.data.talent4
end

function RoleData:GetTalent5()
	return self.data.talent5
end

function RoleData:GetTalent()
	local talents = {}
	talents[1] = self.data.talent1
	talents[2] = self.data.talent2
	talents[3] = self.data.talent3
	talents[4] = self.data.talent4
	talents[5] = self.data.talent5
	return talents
end

function RoleData:GetTeamTalent()
	return self.data.teamTalent
end

function RoleData:IsShowInCollection()
	return self.data.ShowInCollection ~= 0
end

function RoleData:GetDarwShowPro()
	return self.data.darwShowPro
end

-- 获取装备类型槽, 最大10个 --
function RoleData:GetEquipmentTypeSlots()
	return self.staticEquipmentTypeSlots
end

-- 获得指定穿戴位置的装备类型 --
function RoleData:GetEquipmentTypeByPos(pos)
	return self.staticEquipmentTypeSlots[pos]
end

-- 获取装备槽类型 --
function RoleData:GetEquipmentSlotCount()
	return #self.staticEquipmentTypeSlots
end

-- 获取翅膀ID
function RoleData:GetbeishiID()
	return self.data.beishiID
end

function RoleData:GetZodiac()
	return self.data.zodiac
end


---- >>>>> ## 数值相关 ## <<<<< ----

-- 力, 敏, 智 所影响的 血量, 攻击, 速度系数
local function GetMajorAttrRatio(self)
	local mgr = require "StaticData.MajorAttrRatio"
	return mgr:GetData(self:GetMajorAttr())
end

-- 品级成长值 = 品级成长值(PB.GrowFactor) + 进阶成长值(PB.RoleImprove)
local function GetGrowFactor(self, color, stage)
	local mgr = require "StaticData.GrowFactor"
	local addValue = 0
	if stage > 0 then
		local arg = stage - 1 
		if arg < 0 then
			arg = 0
		end
		
		local stageArg = math.min(arg,KCardStageMax)
		local addMgr = require "StaticData.RoleImprove"
		addValue = addMgr:GetData(stageArg):GetGraceAddValue()
	end

	return mgr:GetData(self:GetGrow()):GetValue(color) + addValue
end


-- 基础攻击力计算：((1-基础属性系数*4)*100*(0.2+人物等级/100))*攻击系数*成长值
function RoleData:GetBasicAp(color, level, stage)
	local t1 = 1 - self:GetAttrRatio() * 4
	local t2 = 0.2 + (level / 100)
	local t3 = t1 * 100 * t2
	local t4 = GetMajorAttrRatio(self):GetApRatio()
	local t5 = GetGrowFactor(self, color, stage)
	-- debug_print(string.format("[基础攻击计算] >>> 角色ID: %s, t1:%s, t2:%s, t3:%s, t4:%s, t5:%s, 返回值: %s", self:GetId(), t1, t2, t3, t4, t5, (t3 * t4 * t5)))
	return t3 * t4 * t5
end

-- 基础血量计算：(((1+基础属性系数*3) *600* (0.2+人物等级/100) -70))*血系数*成长值
function RoleData:GetBasicHp(color, level, stage)
	local t1 = 1 + self:GetAttrRatio() * 3
	local t2 = 0.2 + (level / 100)
	local t3 = t1 * 600 * t2 - 70
	local t4 = GetMajorAttrRatio(self):GetHpRatio()
	local t5 = GetGrowFactor(self, color, stage)
	-- debug_print(string.format("[基础血量计算] >>> 角色ID: %s, t1:%s, t2:%s, t3:%s, t4:%s, t5:%s, 返回值: %s", self:GetId(), t1, t2, t3, t4, t5, (t3 * t4 * t5)))
	return t3 * t4 * t5
end

-- 基础防御力计算：(1+基础属性系数*3)*速度系数*人物等级*24
function RoleData:GetBasicDp(color, level)
	local t1 = 1 + self:GetAttrRatio() * 3
	local t2 = GetMajorAttrRatio(self):GetSpeedRatio()
	-- debug_print(string.format("[基础防御计算] >>> 角色ID: %s, t1:%s, t2:%s, 返回值:%s", self:GetId(), t1, t2, (t1 * t2 * level * 24)))
	return t1 * t2 * level * 24
end


RoleDataManager = Class(DataManager)

local roleDataManager = RoleDataManager.New(RoleData)
return roleDataManager