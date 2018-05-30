require "Game.Role"
require "Battle.BattleUnitController"
require "Object.Component.MotionController"
require "Battle.BattleUnitSelector"
local probability = require "Utils.Probability"
require "Collection.OrderedDictionary"
require "Const"

local utility = require "Utils.Utility"
local unityUtils = require "Utils.Unity"
local BattleUtility = require "Utils.BattleUtility"
local MessageGuids = require "Framework.Business.MessageGuids"
local cos3dGame = utility.GetGame()

BattleUnit = Class(LuaGameObject)
require "Battle.BattleUnit_State"
require "Battle.BattleUnit_UI"

local Rate2Ratio = 0.01
local Ratio2Rate = 100

local function GetDefaultNumber(num)
	if type(num) == "number" and num > 0 then
	-- if type(num) == "number" and num >= 0 then -- 如果当num >= 0时我可以默认以0开始!
		return num
	end
	return nil
end

function BattleUnit:GetInitMaxHp()
	return GetDefaultNumber(self.unitParameter:GetMaxHp()) or self.role:GetHp()
end

function BattleUnit:GetInitCurHp()
	return GetDefaultNumber(self.unitParameter:GetCurHp()) or self.role:GetHp()
end

-- FIXME: 静态属性, 放在这里加成
function BattleUnit:UpdateStaticData()
	-- debug_print("@@ 原始血量", self.maxHp, self.maxHp, self:GetGameObject().name, self.extraHpLimitValue)
	self.maxHp = (self.maxHp + self.extraHpLimitValue)
	self.curHp = (self.curHp + self.extraHpLimitValue)
	if self.curHp > self.maxHp then
		self.curHp = self.maxHp
	end
	-- debug_print("@@ 加成后的血量", self.maxHp, self.maxHp, self:GetGameObject().name, self.extraHpLimitValue)
end


local function Reset(self)
	self.rage = 0
	
	local battlefield = self:GetBattlefield()
	if battlefield:IsUnlimitedRage() then
		self.rage = 5	 						  -- 无限怒气 --
	else
		self:AddRage(self.role:GetInitAngerNum()) -- 获得初始的怒气值 --
	end
	
	self.maxHp		= self:GetInitMaxHp()
	self.curHp		= self:GetInitCurHp()

	-- debug_print("@血量数据", self:GetGameObject().name, "当前血量", self.curHp, "最大血量", self.maxHp)

	self.losedHp 	= 0
	self.curSpeed	= self.role:GetSpeed()
	
	-- 飞行物 --
	self.bullets = {}
	
	-- 目标选择 --
	self.currentTargets = nil
	self.previousTargets = nil
	
	-- 伤害源 -- 
	local DamageSourceInfoClass = require "Battle.BattleDamageSourceInfo"
	self.currentDamageSourceInfo = DamageSourceInfoClass.New(self)
	self.previousDamageSourceInfo = DamageSourceInfoClass.New(self)
	
	-- @@@@ 额外属性值 @@@@ --
	self.extraApRate			= 0		-- 增加攻击力系数
	self.extraApValue			= 0		-- 增加攻击力点数
	self.extraDpRate			= 0		-- 增加防御力系数
	self.extraDpValue			= 0		-- 增加防御力点数
	self.extraHpLimitRate		= 0		-- 增加血量上限系数
	self.extraHpLimitValue		= 0		-- 增加血量上限点数
	self.extraSpeedRate		    = 0		-- 增加速度系数
	self.extraSpeedValue		= 0		-- 增加速度点数
	self.extraCritRate			= 0		-- 增加暴击率
	self.extraCritDamageRate	= 0		-- 增加暴击伤害系数
	self.extraDecritRate		= 0		-- 增加抗暴率
	self.extraAvoidRate		    = 0		-- 增加闪避率
	self.extraHitRate			= 0		-- 增加命中率
	self.extraVamRate			= 0		-- 增加吸血率
	self.extraAttackDamageValue = 0		-- 增加普攻额外伤害点数
	self.extraSkillDamageValue	= 0		-- 增加技攻额外伤害点数
	
	-- @@@@ 人物的行为属性 @@@@ --
	self:ResetAllActionProperties()
end

-- >>>>>>>>> 额外值的设置 <<<<<<<<<< --
-- @@ apRate @@
local function ResetExtraApRate(self)
	self.extraApRate = 0
end

function BattleUnit:GetExtraApRate()
	return self.extraApRate
end

function BattleUnit:AddExtraApRate(apRate)
	self.extraApRate = self.extraApRate + apRate
end

-- @@ apValue @@ --
local function ResetExtraApValue(self)
	self.extraApValue = 0
end

function BattleUnit:GetExtraApValue()
	return self.extraApValue
end

function BattleUnit:AddExtraApValue(apValue)
	self.extraApValue = self.extraApValue + apValue
end

-- @@ DpRate @@ --
local function ResetExtraDpRate(self)
	self.extraDpRate = 0
end

function BattleUnit:GetExtraDpRate()
	return self.extraDpRate
end

function BattleUnit:AddExtraDpRate(dpRate)
	self.extraDpRate = self.extraDpRate + dpRate
end

-- @@ dpValue @@ --
local function ResetExtraDpValue(self)
	self.extraDpValue = 0
end

function BattleUnit:GetExtraDpValue()
	return self.extraDpValue
end

function BattleUnit:AddExtraDpValue(dpValue)
	self.extraDpValue = self.extraDpValue + dpValue
end

-- @@ hpLimitRate @@ --
local function ResetExtraHpLimitRate(self)
	self.extraHpLimitRate = 0
end

function BattleUnit:GetExtraHpLimitRate()
	return self.extraHpLimitRate
end

function BattleUnit:AddExtraHpLimitRate(hpLimitRate)
	self.extraHpLimitRate = self.extraHpLimitRate + hpLimitRate
end

-- @@ hpLimitValue @@ --
local function ResetExtraHpLimitValue(self)
	self.extraHpLimitValue = 0
end

function BattleUnit:GetExtraHpLimitValue()
	return self.extraHpLimitValue
end

function BattleUnit:AddExtraHpLimitValue(hpLimitValue)
	self.extraHpLimitValue = self.extraHpLimitValue + hpLimitValue
end

-- @@ speedRate @@ --
local function ResetExtraSpeedRate(self)
	self.extraSpeedRate = 0
end

function BattleUnit:GetExtraSpeedRate()
	return self.extraSpeedRate
end

function BattleUnit:AddExtraSpeedRate(speedRate)
	self.extraSpeedRate = self.extraSpeedRate + speedRate
end

-- @@ speedValue @@ --
local function ResetExtraSpeedValue(self)
	self.extraSpeedValue = 0
end

function BattleUnit:GetExtraSpeedValue()
	return self.extraSpeedValue
end

function BattleUnit:AddExtraSpeedValue(speedValue)
	self.extraSpeedValue = self.extraSpeedValue + speedValue
end

-- @@ critRate @@ --
local function ResetExtraCritRate(self)
	self.extraCritRate = 0
end

function BattleUnit:GetExtraCritRate()
	return self.extraCritRate
end

function BattleUnit:AddExtraCritRate(critRate)
	self.extraCritRate = self.extraCritRate + critRate
end

-- @@ critDamageRate @@ --
local function ResetExtraCritDamageRate(self)
	self.extraCritDamageRate = 0
end

function BattleUnit:GetExtraCritDamageRate()
	return self.extraCritDamageRate
end

function BattleUnit:AddExtraCritDamageRate(critDamageRate)
	self.extraCritDamageRate = self.extraCritDamageRate + critDamageRate
end

-- @@ decritRate @@ --
local function ResetExtraDecritRate(self)
	self.extraDecritRate = 0
end

function BattleUnit:GetExtraDecritRate()
	return self.extraDecritRate
end

function BattleUnit:AddExtraDecritRate(decritRate)
	self.extraDecritRate = self.extraDecritRate + decritRate
end

-- @@ avoidRate @@ --
local function ResetExtraAvoidRate(self)
	self.extraAvoidRate = 0
end

function BattleUnit:GetExtraAvoidRate()
	return self.extraAvoidRate
end

function BattleUnit:AddExtraAvoidRate(avoidRate)
	self.extraAvoidRate = self.extraAvoidRate + avoidRate
end

-- @@ hitRate @@ --
local function ResetExtraHitRate(self)
	self.extraHitRate = 0
end

function BattleUnit:GetExtraHitRate()
	return self.extraHitRate
end

function BattleUnit:AddExtraHitRate(hitRate)
	self.extraHitRate = self.extraHitRate + hitRate
end

-- @@ vamRate @@ --
local function ResetExtraVamRate(self)
	self.extraVamRate = 0
end

function BattleUnit:GetExtraVamRate()
	return self.extraVamRate
end

function BattleUnit:AddExtraVamRate(vamRate)
	self.extraVamRate = self.extraVamRate + vamRate
end

-- @@ attackDamage @@ --
local function ResetExtraAttackDamageValue(self)
	self.extraAttackDamageValue = 0
end

function BattleUnit:GetExtraAttackDamageValue()
	return self.extraAttackDamageValue
end

function BattleUnit:AddExtraAttackDamageValue(attackDamageValue)
	self.extraAttackDamageValue = self.extraAttackDamageValue + attackDamageValue
end

-- @@ skillDamage @@ --
local function ResetExtraSkillDamageValue(self)
	self.extraSkillDamageValue = 0
end

function BattleUnit:GetExtraSkillDamageValue()
	return self.extraSkillDamageValue
end

function BattleUnit:AddExtraSkillDamageValue(skillDamageValue)
	self.extraSkillDamageValue = self.extraSkillDamageValue + skillDamageValue
end

-- @@@@@@@@@@@@@@@ --
-- 人物行为的属性开始 --

-- # 重置所有行为属性到初始值 # --
function BattleUnit:ResetAllActiveActionProperties()
	self:ResetSkillDamageRate()
	self:ResetKillerMark()
	self:ResetHitMark()
	self:ResetCritMark()
	self:ResetMustBeCritMark()
	self:ResetMustBeHitMark()
end

function BattleUnit:ResetAllPassiveActionProperties()
	self:ResetDamageReductionRate()
	self:ResetAvoidMark()
end

function BattleUnit:ResetAllActionProperties()
	self:ResetAllActiveActionProperties()
	self:ResetAllPassiveActionProperties()
end

-- @@ 减伤系数 @@ --
function BattleUnit:ResetDamageReductionRate()
	self.damageReductionRate = 100
end

function BattleUnit:GetDamageReductionRate()
	return self.damageReductionRate
end

function BattleUnit:SetDamageReductionRate(newDamageReductionRate)
	self.damageReductionRate = newDamageReductionRate
end

-- @@ 技能自身伤害系数 @@ --
function BattleUnit:ResetSkillDamageRate()
	self.skillDamageRate = 100
end

function BattleUnit:GetSkillDamageRate()
	return self.skillDamageRate
end

function BattleUnit:SetSkillDamageRate(newDamageRate)
	self.skillDamageRate = newDamageRate
end

-- @ 是否暴击 @ --
function BattleUnit:ResetCritMark()
	self.isCritMarked = false
end

function BattleUnit:HasCrited()
	return self.isCritMarked
end

function BattleUnit:MarkAsCrit()
	self.isCritMarked = true
end

-- @ 是否击杀敌人 @ --
function BattleUnit:ResetKillerMark()
	self.isKillerMarked = false
end

function BattleUnit:IsKiller()
	return self.isKillerMarked
end

function BattleUnit:MarkAsKiller()
	self.isKillerMarked = true
end

-- @ 是否必暴击 @ --
function BattleUnit:ResetMustBeCritMark()
	self.isMustBeCritMarked = false
end

function BattleUnit:IsMustBeCrit()
	return self.isMustBeCritMarked
end

function BattleUnit:MarkAsMustBeCrit()
	self.isMustBeCritMarked = true
end

-- @ 是否必命中 @ --
function BattleUnit:ResetMustBeHitMark()
	self.isMustBeHitMarked = false
end

function BattleUnit:IsMustBeHit()
	return self.isMustBeHitMarked
end

function BattleUnit:MarkAsMustBeHitMark()
	self.isMustBeHitMarked = true
end

-- @ 死亡次数(如果复活这个字段会累加!) @ --
function BattleUnit:GetDeathTimes()
	return self.unitDeathTimes or 0
end

function BattleUnit:MarkAsDead()
	self.unitDeathTimes = self:GetDeathTimes() + 1
end

-- @ 是否闪避(被动) @ --
function BattleUnit:ResetAvoidMark()
	self.isAvoidMarked = false
end

function BattleUnit:HasAvoided()
	return self.isAvoidMarked
end

function BattleUnit:MarkAsAvoid()
	self.isAvoidMarked = true
end

-- @ 是否命中(主动) @ --
function BattleUnit:ResetHitMark()
	self.isHitMarked = false
end

function BattleUnit:HasHit()
	return self.isHitMarked
end

function BattleUnit:MarkAsHit()
	self.isHitMarked = true
end

-- @@@@@@@@@@@@@@@ --

local function ResetToOriginalScale(self)
	if self.transform ~= nil then
		self.transform.localScale = Vector3(self.originalScale, self.originalScale, self.originalScale)
	end
end

local function ResetToDefaultTransform(self)
	if self.transform ~= nil then
		self.transform.localPosition = self.defaultPos
		self.transform.localRotation = self.defaultRotation
	end
end

function BattleUnit:SetModelScale(scale)
	local s = self.originalScale * scale
	debug_print("@设置缩放", self:GetGameObject().name, scale)
	self.transform.localScale = Vector3(s, s, s)
end

function BattleUnit:Ctor(unitParameter, needPrepareSkill, extraScale)
	self.needPrepareSkill = needPrepareSkill
	self.unitParameter = unitParameter
	self.location = self.unitParameter:GetLocation()
	self.role = self.unitParameter:GetRole()
	self.originalScale = self.role:GetModelScale() * extraScale * 0.01 -- 原始缩放
end

local function SetupGameObjectNew(self)
	-- 初始化GameObject本身
	self.gameObject = cos3dGame:GetPoolManager():Spawn(BattleUtility.GetBattleUnitPoolName(self.role:GetId()))
	self.transform = self.gameObject.transform

	-- Reparent
	self.transform:SetParent(self:GetBattlefield():GetBattleUnitParentTransform())

	-- 初始化默认的位置
	local virtualPositionTransform = self:GetBattlefield():GetBattleUnitVirtualTransform(self:OnGetSide(), self:GetLocation())
	self.defaultPos = virtualPositionTransform.localPosition
	self.defaultRotation = virtualPositionTransform.localRotation

	-- 重置缩放
	ResetToOriginalScale(self)

	-- 重置位置和旋转
	ResetToDefaultTransform(self)

	-- AddComponent
	unityUtils:AddComponentIfMissing(self.gameObject, typeof(AnimationEventListener))
	unityUtils:AddComponentIfMissing(self.gameObject, typeof(BattleUnitColliderListener))
end

local function SetupComponents(self)
	local motion = MotionController.New(self.transform, self.role:GetMoveTime())
	self:AddComponent(motion)

	local selector = BattleUnitSelector.New()
	self:AddComponent(selector)
	self.selector = selector

	local ctrl = BattleUnitController.New()
	self:AddComponent(ctrl)
	self.ctrl = ctrl

	self.attackSkill = self.role:GetAttackSkill()
	self.activeSkill = self.role:GetActiveSkill()
	self.passiveSkill = self.role:GetPassiveSkill()

	-- 普攻
	self:AddComponent(self.attackSkill)

	-- 技能
	self:AddComponent(self.activeSkill)

	-- 被动
	self:AddComponent(self.passiveSkill)
end

function BattleUnit:Setup()
	SetupGameObjectNew(self)
	SetupComponents(self)

	-- 初始化buff处理
	self:InitStateManager()
	-- 初始化UI
	self:SetupUIs()
	Reset(self)
	self:UpdateHpBar()
end

function BattleUnit:Clear()
	self.ctrl:Clear()
	self:ClearUI()
	self:CloseStateManager()

	if self.gameObject ~= nil then
		cos3dGame:GetPoolManager():Despawn(BattleUtility.GetBattleUnitPoolName(self.role:GetId()), self.gameObject)
		self.gameObject = nil
	end
end

function BattleUnit:Pause()
	-- debug_print("@Pause, BattleUnit:Pause, name:", self:GetGameObject().name)
	self.ctrl:Pause()
end

function BattleUnit:Resume()
	-- debug_print("@Resume, BattleUnit:Resume, name:", self:GetGameObject().name)
	self.ctrl:Resume()
end

function BattleUnit:GetRoleData()
	return self.role
end

function BattleUnit:GetId()
	return self.role:GetId()
end

function BattleUnit:GetUid()
	return self.role:GetUid()
end

function BattleUnit:GetStaticInfo()
	return self.role:GetInfo()
end

function BattleUnit:GetLevel()
	return self.role:GetLv()
end

function BattleUnit:GetStage()
	return self.role:GetStage()
end

function BattleUnit:GetColor()
	return self.role:GetColor()
end

function BattleUnit:GetHash()
	return BattleUtility.GetBattleUnitHash(self:GetId(), self:GetLocation(), self:GetUid(), self:OnGetSide())
end


-- 重置伤害源 --
local function ResetCurrentDamageSourceInfo(self)
	local tempSourceInfo = self.currentDamageSourceInfo
	self.currentDamageSourceInfo = self.previousDamageSourceInfo
	self.previousDamageSourceInfo = tempSourceInfo
	self.currentDamageSourceInfo:Clear()
	-- debug_print("@重置源", self:GetGameObject().name, debug.traceback())
end


function BattleUnit:NewRound()
	debug_print("@@@@ 新回合!", self:GetGameObject().name)
	self.isMoved			= false	--行动标记
	self.isAssistMarked	= false	--协助攻击标记
	self.isSkillRestricted	= false --主动技能使用受限标记
	self.isNotifiedReset	= false --通知复位标记
	self.notifiedResetUnits = {} -- 已通知重置的单位
	self.hasHandledDeadUnits = {}	--处理过的死亡目标!
	self.isReset			= true  --复位标记
	

	-- 目标 --
	-- self:SetTargets(nil)
	-- 伤害源 --
	ResetCurrentDamageSourceInfo(self)
	
	-- 飞行物 --
	utility.ClearArrayTableContent(self.bullets)
	
	self:ResetStateData()
	
end

function BattleUnit:OnNewWave(wave)
	-- debug_print("wave!!", wave)
	if wave > 1 then
		-- debug_print("@rage: 多阶战斗 恢复怒气3点", self:GetGameObject().name)
		self:AddRage(3)
		self:AddHp(math.floor(self:GetMaxHp() * 0.15), false)
	end
end

function BattleUnit:NotifySkillStateExit()
	-- TODO 只有ActiveSkill使用到 需要做第一次战斗测试, 如果通过则可以去掉此函数
	-- self.ctrl:NotifySkillStateExit()
end

function BattleUnit:NotifyDamageSourceReset()
	local units = self.currentDamageSourceInfo:GetUnits()
	for i = 1, #units do
		local attacker = units[i]
		if attacker ~= nil then
			attacker:NotifiedReset(self)
		end
	end
end

function BattleUnit:ToString()
	return self.role:ToString()
end

function BattleUnit:AddRage(addition)
	-- 无限怒气模式的怒气中途不变! --
	local battlefield = self:GetBattlefield()
	if battlefield:IsUnlimitedRage() then
		return
	end
	
	local changedValue = addition
	if changedValue + self.rage > 5 then
		changedValue = 5 - self.rage
	end
	self.rage = self.rage + changedValue
	self:SetRageForUI(self.rage)
	if self.ctrl ~= nil then
		self.ctrl:OnRageChanged(changedValue, self.rage)
	end
end

function BattleUnit:GetRage()
	return self.rage
end

function BattleUnit:GetHitTransform(name)
	return self.ctrl:GetHitTransform(name)
end

function BattleUnit:OnBattleStarted()
	self.ctrl:OnBattleStarted()
end

function BattleUnit:GetLocation()
	return self.location
end

function BattleUnit:GetCurHp()
	return self.curHp
end

function BattleUnit:GetMaxHp()
	return self.maxHp
end

function BattleUnit:GetHpRate()
	return self.curHp / self.maxHp * 100
end

function BattleUnit:IsShield()
	return false
end

function BattleUnit:IsAlive()
	return self.curHp > 0
end

function BattleUnit:IsDamaged()
	return self:GetCurHp() < self:GetMaxHp()
end

function BattleUnit:GetSpeed()
	return self.curSpeed + self:GetExtraSpeedValue()
end

local function OnLostHp(self)
	local maxHp = self:GetMaxHp()
	local losedHp = self.losedHp

	local limit = math.floor(maxHp * 0.4)

	while(losedHp >= limit)
	do
		-- debug_print("@rage: 累计伤血量达到20%时 恢复1点怒气", self:GetGameObject().name)
		self:AddRage(1)
		losedHp = losedHp - limit
	end

	self.losedHp = losedHp
end

function BattleUnit:LoseHp(value, isCrit, isLastAction)
	-- debug_print("@@@ 丢失血量", self:GetGameObject().name, value, debug.traceback())
	if value <= 0 then
		value = 1
	end
	
	local oldHp = self.curHp
	local newHp = oldHp - value
	if newHp <= 0 then
		newHp = 0
	end

	local errorHp = oldHp - newHp

	-- 发送消息
	cos3dGame:DispatchEvent(MessageGuids.BattleUnitLoseHp, nil, self, errorHp)

	self.losedHp = self.losedHp + errorHp
	self.curHp = newHp
	OnLostHp(self)
	self.ctrl:OnHpChanged(-value, self.curHp, isCrit, isLastAction)
end

function BattleUnit:AddHp(value, isCrit)
	-- debug_print("@@@ 获得血量", self:GetGameObject().name, value)
	if value < 0 then
		return
	end
	self.curHp = self.curHp + value
	local maxHp = self:GetMaxHp()
	if self.curHp > maxHp then
		self.curHp = maxHp
	end
	self.ctrl:OnHpChanged(value, self.curHp, isCrit)
end

function BattleUnit:IsMoved()
	return self.isMoved
end

function BattleUnit:IsAssistMarked()
	return self.isAssistMarked
end

function BattleUnit:TakeAction()
	ResetCurrentDamageSourceInfo(self)
	self.ctrl:TakeAction()
end

function BattleUnit:NeedSkipAction()
	-- @@ 未活着 && 联动过 && 中buff不能行动 @@ --
	if(not self:IsAlive()) or self.isAssistMarked or self:HasCannotMoveState() then
		return true
	end
	
	return false
end

function BattleUnit:UnitMoved()
	debug_print("@@@@@@@>>>>>> BattleUnit:UnitMoved >>>> ", self:GetGameObject().name, debug.traceback())
	
	-- 执行当前主动技能&被动的行动后
	self:GetCurrentSkill():OnActionExit()
	self:GetPassiveSkill():OnActionExit()
	
	-- 执行buff的行动后阶段
	self:ExecuteUnitStateAction(kUnitState_Phase_ActionExit)
	
	self.isMoved = true
	self:ResetAllActionProperties()
	
	--self:SetTargets(nil)
	ResetCurrentDamageSourceInfo(self)
	
	self:RestoreRotation()
	self:GetParent():UnitReset(self)
end

function BattleUnit:NeedPrepareSkill()
	return false
end

function BattleUnit:GetCurrentSkill()
	if self:IsUsingSkill() then
		return self:GetActiveSkill()
	else
		return self:GetAttackSkill()
	end
end

function BattleUnit:CanUseActiveSkill()
	-- 本次是否限制使用技能 --
	if self.isSkillRestricted then
		return false
	end
	
	local battlefield = self:GetBattlefield()
	-- 禁魔 战场
	if battlefield:IsSkillRestricted() then
		return false
	end

	-- TODO 人物属性本身是否禁魔(装备)

	
	-- nil 判断
	local activeSkill = self:GetActiveSkill()
	if activeSkill == nil then
		return false
	end
	
	return activeSkill:CanUse()
end

function BattleUnit:CanUseAttackSkill()
	
	local attackSkill = self:GetAttackSkill()
	if attackSkill == nil then
		return false
	end
	
	return attackSkill:CanUse()
	
end


function BattleUnit:UseActiveSkill()
	self.isReset = false
	self:GetActiveSkill():Use()
end

-- 主动发送攻击
function BattleUnit:UseAttackSkill()
	self.isReset = false
	-- debug_print("@rage: 普攻恢复怒气 2点", self:GetGameObject().name)
	self:AddRage(2)
	self:GetAttackSkill():Use()
	
	-- 当前单位行动! --
	cos3dGame:DispatchEvent(MessageGuids.BattleTakeAction, nil, self, false)
	
	-- 处理联动 --
	self:GetParent():AssistAttack(self)
end

-- 联动 被带动发动攻击 (note: 防止以后会加需求 现在分两个函数处理.)
local function UseAssistAttack(self, leaderUnit)
	self.isReset = false
	-- debug_print("@rage: 联动恢复怒气 2点", self:GetGameObject().name)
	self:AddRage(2)
	self:GetAttackSkill():Use()
	
	-- 当前单位行动! --
	cos3dGame:DispatchEvent(MessageGuids.BattleTakeAction, nil, self, false)
end

function BattleUnit:ManualSkillDiscarded()
	self.ctrl:ManualSkillDiscarded()
end

-- 技能使用次数
function BattleUnit:IsLastAttack()
	return self.ctrl:IsLastAttack()
end

-- 联动发动攻击
function BattleUnit:OnAssistAttack(leaderUnit)
	-- 标志为联动, 接下来这个人 当前回合 不能再行动
	self.isAssistMarked = true
	self.ctrl:OnAssistAttack(leaderUnit)
	UseAssistAttack(self, leaderUnit)
end

function BattleUnit:OnUnderAttackExit()
	if self.currentDamageSourceInfo:Count() > 0 then
		ResetCurrentDamageSourceInfo(self)
	end
end

function BattleUnit:CanAssistAttack()
	if self:NeedSkipAction() then
		return false
	end
	
	if self:CanUseActiveSkill() then
		return false
	end
	
	if not self:CanUseAttackSkill() then
		return false
	end
	
	if not probability:Hit(self:GetLinkageRate()) then
		return false
	end
	
	return true
end


function BattleUnit:GetLinkageRate()
	return self.role:GetLinkageRate()
end

function BattleUnit:OnPlayAssistAttackEffect(order)
	-- print('Play Assist Attack:' , self.gameObject.name)
	-- -- TODO : 播放助攻特效, order是顺序从1开始
	-- local isFriendSide = (self:OnGetSide() == 1)
	-- if isFriendSide then
	--     local delay = 0.1 * (order - 1)
	--     self:GetParent():PlayAssistAttackAnimation(self:GetId(), delay)
	-- end
end

function BattleUnit:SetTargets(targets)
	-- debug_print("set targets", targets, self:GetGameObject().name, targets, self.previousTargets, self.currentTargets, debug.traceback())
	self.previousTargets = self.currentTargets
	self.currentTargets = targets
end

function BattleUnit:GetTargets()
	return self.currentTargets
end

function BattleUnit:GetTargetsGameObject()
	local targetInfo = self:GetTargets()
	
	local objTable = {}
	
	for i = 1, targetInfo:Count() do
		local target = targetInfo:GetTarget(i)
		if target ~= nil then
			objTable[#objTable + 1] = target:GetGameObject()
		end
	end

	return objTable
end

-- @@ 获取最近一次选择的目标 @@ --
function BattleUnit:GetLastTargets()
	return self.currentTargets or self.previousTargets
end

function BattleUnit:GetHitRate() 
	return self.role:GetHitRate() + self:GetStateManager():GetHitRate() + self:GetExtraHitRate()
end

function BattleUnit:GetAvoidRate()
	return self.role:GetAvoidRate() + self:GetStateManager():GetAvoidRate() + self:GetExtraAvoidRate()
end


--[[
    @desc: 计算攻击力
    author:{author}
    time:2017-09-20 20:30:37
    return
]]
local function GetApValue(self)
	local v1 = self.role:GetApValue()
	local v2 = self:GetExtraApValue()
	return v1 + v2
end

local function GetApRate(self)
	local r1 = self.role:GetApRate()
	local r2 = self:GetExtraApRate()
	local r3 = self:GetStateManager():GetApRate()
	return r1 + r2 + r3
end

-- 获取原始攻击力 (value * rate / 100)
local function GetRawAp(self)
	return GetApValue(self) * GetApRate(self) * Rate2Ratio
end

local function GetBattleApRatio(self)
	return self:GetBattlefield():GetApRate(self:OnGetSide()) * Rate2Ratio
end

-- 获取最终攻击力
function BattleUnit:GetAp()
	-- debug_print("@攻击力参数", self:GetGameObject().name, "原始攻击力", GetRawAp(self), "攻击倍数", GetBattleApRatio(self))
	return math.floor(GetRawAp(self) * GetBattleApRatio(self))
end

--[[
    @desc: 计算防御力
    author:{author}
    time:2017-09-20 20:30:37
    return
]]
local function GetDpValue(self)
	local v1 = self.role:GetDpValue()
	local v2 = self:GetExtraDpValue()
	return v1 + v2
end

local function GetDpRate(self)
	local r1 = self.role:GetDpRate()
	local r2 = self:GetExtraDpRate()
	local r3 = self:GetStateManager():GetDpRate()
	return r1 + r2 + r3
end

function BattleUnit:GetDp()
	return math.floor(GetDpValue(self) * GetDpRate(self) * Rate2Ratio)
end

function BattleUnit:GetCritRate()
	return self.role:GetCritRate() + self:GetExtraCritRate() + self:GetStateManager():GetCritRate()
end

function BattleUnit:GetDecritRate()
	return self.role:GetDecritRate() + self:GetExtraDecritRate() + self:GetStateManager():GetDecritRate()
end

function BattleUnit:GetVamRate()
	return self.role:GetVamRate() + self:GetExtraVamRate() + self:GetStateManager():GetVamRate()
end

function BattleUnit:GetCritDamageRatio()
	return self.role:GetCritDamage() *(100 + self:GetExtraCritDamageRate() + self:GetStateManager():GetCritDamageRate()) / 100
end

-- 获取当前单位的普攻额外伤害
function BattleUnit:GetAttackDamage()
	return self.role:GetAttackDamage() + self:GetExtraAttackDamageValue()
end

-- 获取当前单位的技能额外伤害
function BattleUnit:GetSkillDamage()
	return self.role:GetSkillDamage() + self:GetExtraSkillDamageValue()
end

-- 获取种族
function BattleUnit:GetRace()
	return self.role:GetRace()
end

--获取主属性
function BattleUnit:GetMajorAttr()
	return self.role:GetMajorAttr()
end

-- 获取性别
function BattleUnit:GetGender()
	return self.role:GetGender()
end

function BattleUnit:GetHeadIcon()
	return self.role:GetHeadIcon()
end

function BattleUnit:GetPortraitImage()
	return self.role:GetPortraitImage()
end

function BattleUnit:OnCallShield(id)
	self:GetParent():OnCallShield(self, id)
end

function BattleUnit:OnNotifySkipAttackOnce()	
	-- 不是最后一次攻击?
	if not self.ctrl:IsLastAttack() then
		return
	end

	self:NotifiedReset(self)

	-- debug_print("?>>>>>>@@@目标数:", self:GetTargets():Count(), self.isNotifiedReset)
end

function BattleUnit:OnReceiveHeal(healSrc, heal, isCritHeal)
	self.currentDamageSourceInfo:Add(healSrc, heal, isCritHeal, true)
	
	self.isReset = false
	
	self:OnHandleDamage()
end

function BattleUnit:OnReceiveDamage(damageSrc, damage, isCritDamage, isLastAction)
	-- 缓存伤害值 --
	self.currentDamageSourceInfo:Add(damageSrc, damage, isCritDamage, false)
	
	self.isReset = false
	
	self.ctrl:OnReceiveDamage(damageSrc, true, true, isLastAction)
end

function BattleUnit:OnReceiveDamageActionOnce(damageSrc)
	self.ctrl:OnReceiveDamageActionOnce(damageSrc)
end

function BattleUnit:OnReceiveDamageActionLoop(damageSrc)
	self.ctrl:OnReceiveDamageActionLoop(damageSrc)
end

function BattleUnit:OnReceiveDamageNoAction(damageSrc)
	self.ctrl:OnReceiveDamageNoAction(damageSrc)
end

local function IsHitTarget(self, target)
	-- self 是攻击者  target 挨打者
	if target == nil then
		return false
	end
	
	-- 计算命中率 --
	local prop =(self:GetHitRate() + 100) - target:GetAvoidRate()
	
	-- 负数和0是必闪避 --
	if prop <= 0 then
		return self:IsMustBeHit()
	end
	
	if prop >= 100 then
		print("@@@@<攻击者>必中!!")
		return true
	end
	
	-- 大于等于100% 或者随机命中就代表 命中! --
	if probability:Hit(prop) then
		return true
	end
	
	-- 否则按闪避处理! --
	return self:IsMustBeHit()
end

local function IsCritDamage(self, target)
	-- target 是否免疫暴击
	if target:IsImmuneToState(kStateFlag_Crit) then
		debug_print("@免疫暴击 ", target:GetGameObject().name)
		return false
	end


	if self:IsMustBeCrit() then
		return true
	end

	local prop = self:GetCritRate() - target:GetDecritRate()
	
	-- 负数不暴击 --
	if prop <= 0 then
		return false
	end
	
	-- 暴击100% 或者  随机到   就是暴击 --
	if prop >= 100 or probability:Hit(prop) then
		return true
	end
	
	return false
end

local function GetRealSkillDamageRate(self, skillDamageRateReplacement)
	return skillDamageRateReplacement or self:GetSkillDamageRate()
end

function BattleUnit:CalculateDamage(target, skillDamageRateReplacement)
	-- self 是攻击者  target 挨打者
	-- @data: 1. 无敌状态, 统一掉血1
	if target:HasGodState() then
		return 0, false
	end
	
	-- @data: 2. 闪避结果检查
	if not IsHitTarget(self, target) then
		target:MarkAsAvoid()
		return -1, false
	end
	
	-- @data: 3. 判断暴击(免疫暴击 > 必暴击)
	local critDamageRatio = 1
	local isCritDamage = IsCritDamage(self, target)
	if isCritDamage then
		self:MarkAsCrit()
		critDamageRatio = self:GetCritDamageRatio()
	end
	
	-- @data: 普攻伤害：[(攻击者攻击力-受击者防御力)*普攻伤害系数] * 暴击伤害系数 + 普攻额外伤害					
	-- @data: 技能伤害：[(攻击者攻击力-受击者防御力)*技攻伤害系数] * 暴击伤害系数 + 技攻额外伤害					
	local rawDamage =(self:GetAp() - target:GetDp()) * (GetRealSkillDamageRate(self, skillDamageRateReplacement) / 100) *((100 + self:GetStateManager():GetDamageRate()) / 100)

	-- 乘上暴击伤害
	rawDamage = rawDamage * critDamageRatio

	-- 加上技能or普攻额外伤害
	if self:IsUsingSkill() then
		rawDamage = rawDamage + self:GetSkillDamage()
	else
		rawDamage = rawDamage + self:GetAttackDamage()
	end

	-- 乘上减伤系数
	rawDamage = rawDamage * target:GetDamageReductionRate() / 100
	
	-- 乘上伤害系数
	rawDamage = rawDamage * self:GetBattlefield():GetDamageRate(self:OnGetSide()) * Rate2Ratio

	local damage = math.max(10, rawDamage)

	local attackCount = self:GetCurrentSkill():GetAttackCount()
	damage = utility.ToInteger(damage / attackCount)
	
	-- debug_print(
	-- ">>> 伤害信息",
	-- "攻击者",
	-- self:GetGameObject().name,
	-- "受击者",
	-- target:GetGameObject().name,
	-- "是否为主动技能",
	-- self:IsUsingSkill(),
	-- "攻击者攻击力",
	-- self:GetAp(),
	-- "受击者防御力",
	-- target:GetDp(),
	-- "技能本身伤害系数",
	-- GetRealSkillDamageRate(self, skillDamageRateReplacement),
	-- "状态的额外伤害系数",
	-- self:GetStateManager():GetDamageRate(),
	-- "是否暴击",
	-- isCritDamage,
	-- "暴击伤害系数",
	-- critDamageRatio,
	-- "主动技能额外伤害",
	-- self:GetSkillDamage(),
	-- "普攻额外伤害",
	-- self:GetAttackDamage(),
	-- "攻击次数",
	-- attackCount,
	-- "最终伤害值",
	-- damage,
	-- "伤害系数替代值",
	-- skillDamageRateReplacement
	-- )
	
	return damage, isCritDamage
end

local function IsCritHeal(self)
	return probability:Hit(self:GetCritRate())
end

function BattleUnit:CalculateHeal(damageRate)
	local damageRatio = 1
	local isCritHeal = IsCritHeal(self)
	if isCritHeal then
		damageRatio = self:GetCritDamageRatio()
	end
	local damage = self:GetAp() * damageRatio * (GetRealSkillDamageRate(self, damageRate) / 100)

	-- debug_print("@加血", self:GetAp(), GetRealSkillDamageRate(self, damageRate), damage)
	return math.floor(damage), isCritHeal
end

function BattleUnit:OnHandleDamage(isLastAction)
	local damageEntry = self.currentDamageSourceInfo:Next()
	
	-- # 没有伤害 # --
	if damageEntry == nil then
		return
	end
	
	local battleUnitController = damageEntry:GetUnitController()
	local damageValue = damageEntry:GetDamageValue()
	local isCrit = damageEntry:IsCrit()
	local isHeal = damageEntry:IsHeal()
	
	-- battleUnitController 是攻击/治疗 源对象的BattleUnitController
	utility.ASSERT(battleUnitController ~= nil, "battleUnitController为nil!")
	
	if isHeal then
		self:AddHp(damageValue, isCrit)
		
		-- # 自己发治疗技能依赖的是自己的动作结束
		-- # 别人被治疗依赖的是治疗事件帧
		-- # 自己被自己治疗依赖的依然是动作结束
		-- debug_print("@重置加血!!", self:GetGameObject().name)
		if battleUnitController ~= self.ctrl then
			self.ctrl:OnHandleResetLogic()
		end
	else
		if damageValue < 0 then
			self.ctrl:OnMiss()
		else
			self:LoseHp(damageValue, isCrit, isLastAction)

			-- 加吸血
			local vam = damageValue * battleUnitController.luaGameObject:GetVamRate() / 100
			if vam > 0 then
				battleUnitController.luaGameObject:AddHp(vam)
			end

			
			if isCrit then
				self.ctrl:OnCritDamage()
			end
		end
	end
end


-- @@ 获取最后一次的目标源 @@ --
function BattleUnit:GetLastDamageSources()
	if self.currentDamageSourceInfo:Count() > 0 then
		return self.currentDamageSourceInfo
	end
	return self.previousDamageSourceInfo
end

function BattleUnit:IsReset()
	return self.isReset
end

local function AddNotifiedResetUnit(self, attackee)
	if attackee ~= nil then
		for i = 1, #self.notifiedResetUnits do
			if self.notifiedResetUnits[i] == attackee then
				-- 不重复添加!
				return
			end
		end
		self.notifiedResetUnits[#self.notifiedResetUnits + 1] = attackee
	end
end

local function IsAllNotifiedUnitReset(self)
	return #self.notifiedResetUnits >= self:GetTargets():Count()
end

function BattleUnit:NotifiedReset(attackee)
	-- 通常单位的处理 --
	if not attackee:IsShield() then
		debug_print("@ 被打者重置", attackee:GetGameObject().name, self:GetGameObject().name, debug.traceback())
		if not attackee:IsAlive() and self.hasHandledDeadUnits[attackee] ~= true then
			-- 击杀状态 & 击杀恢复怒气
			self:MarkAsKiller()
			self.hasHandledDeadUnits[attackee] = true
			self:AddRage(1)
		end

		AddNotifiedResetUnit(self, attackee)
		if not IsAllNotifiedUnitReset(self) then
			return
		end
	end

	self.isNotifiedReset = true
	
	if not self.isMoved and self.isReset then
		self:UnitMoved()
	end
end

function BattleUnit:Reset()
	self.isReset = true

	debug_print("自身动作重置", self:GetGameObject().name, self.isMoved, self.isNotifiedReset)
	
	if(not self.isMoved) and self.isNotifiedReset then
		self:UnitMoved()
	end
end

-- @@@@ 处理人物死亡的逻辑 @@@@ ---
function BattleUnit:HandleUnitDie(isResetLogic, isUnderAttack)
	return self.ctrl:HandleUnitDie(isResetLogic, isUnderAttack)
end

-- 是否使用技能 --
function BattleUnit:IsUsingSkill()
	return self.ctrl:IsUsingSkill()
end

function BattleUnit:GetAttackSkill()
	return self.attackSkill
end

function BattleUnit:GetActiveSkill()
	return self.activeSkill
end

function BattleUnit:GetPassiveSkill()
	return self.passiveSkill
end

function BattleUnit:OnGetSide()
	return self:GetParent():OnGetSide()
end

function BattleUnit:GetFoeCenter()
	return self:GetParent():GetFoeCenter()
end

function BattleUnit:GetCenter()
	return self:GetParent():GetCenter()
end

function BattleUnit:GetFront()
	return self:GetParent():GetFront()
end

function BattleUnit:GetFoes()
	return self:GetParent():GetFoes()
end

function BattleUnit:GetMembers()
	return self:GetParent():GetMembers()
end

function BattleUnit:GetBattlefield()
	return self:GetParent():GetParent()
end

function BattleUnit:SetSkillRestrict(value)
	self.isSkillRestricted = value
end

function BattleUnit:GetActionRatio(action, params)
	if(action == kSkillAction_Damage) or(action == kSkillAction_Healing) then
		return params:get_Item(0)
	elseif action == kSkillAction_RandomDamage then
		local index = probability:Random(params.Count)
		return params:get_Item(index)
	elseif action == kSkillAction_DamagePlusAttr then
		local base = params:get_Item(0)
		local attrType = params:get_Item(1)
		if attrType == 1 then
			base = base + self:GetAvoidRate() / 100
		end
		return base
	end
end

function BattleUnit:GetAliveMate()
	return self.selector:GetTargets(kSkillTarget_AllMembers)
end

function BattleUnit:Update()
	BattleUnit.base.Update(self)
	
	for i = #self.bullets, 1, - 1 do
		if self.bullets[i] ~= nil then
			self.bullets[i]:Update()
		end
	end

	self:UpdateAllUIControls()
end

function BattleUnit:GetDefaultPosition()
	return self.defaultPos
end

function BattleUnit:AddBullet(bullet)
	local table = self.bullets
	table[#table + 1] = bullet
end

function BattleUnit:RemoveBullet(bullet)
	local table = self.bullets
	for i = 1, #table do
		if table[i] == bullet then
			table[i] = table[#table]
			table[#table] = nil
			break
		end
	end
end

function BattleUnit:GetBulletCount()
	return #self.bullets
end

function BattleUnit:OnShowRole()
	self.gameObject:SetActive(true)
	self.ctrl:Breath2ShowOff()
end

function BattleUnit:SetSkillBackgroundActive(active)
	return self:GetParent():SetSkillBackgroundActive(self, active)
end

function BattleUnit:GetMoveTimeScaler(battleUnit)
	local location = battleUnit:GetLocation()
	if(self.location == 4) or(self.location == 5) or(self.location == 6) then
		if(location == 1) or(location == 2) or(location == 3) then
			return 0.6
		else
			return 1
		end
	else
		if(location == 1) or(location == 2) or(location == 3) then
			return 0.5
		else
			return 0.6
		end
	end
end

function BattleUnit:RotateToTarget(gameObject)
	if self.gameObject == gameObject then
		return
	end
	
	local relative = self.transform:InverseTransformPoint(gameObject.transform.position)
	local angle = Mathf.Atan2(relative.x, relative.z) * Mathf.Rad2Deg
	self.transform:Rotate(0, angle, 0)
end

function BattleUnit:RestoreRotation()
	self.transform.localRotation = self.defaultRotation
end


-- 动作状态判断 --
function BattleUnit:IsBreathState()
	return self.ctrl:IsCurAnimatorStateBreath() and not self.ctrl:HasNextStateInfo()
end

-- 新加的事件函数
function BattleUnit:OnAttackerSkillStateExit(attacker)
	self.ctrl:OnAttackerSkillStateExit(attacker)
end
