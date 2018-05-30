require "Object.LuaComponent"
local collision = require "Event.CollisionEventHandler"
require "Enum"
require "Battle.BattleUnitController_AnimatorState"
require "Battle.BattleUnitController_UI"
require "Battle.BattleUnitController_Camera"
require "Const"

local utility = require "Utils.Utility"
local MessageGuids = require "Framework.Business.MessageGuids"
local cos3dGame = utility.GetGame()

LastCommand = {
	"None", 
	"Attack", 
	"Skill"
}
LastCommand = Enum(LastCommand)

function BattleUnitController:Ctor()
	local unitEvnt = require "Event.BattleUnitEventHandler"
	unitEvnt:RegisterEventHandler(self)
	self.lastCommand = LastCommand.None
	self:ResetAnimator()
end

local function GetBattlefield(self)
	return self:GetBattlefield()
end

function BattleUnitController:GetBattlefield()
	if self.battlefield == nil then
		self.battlefield = self.luaGameObject:GetParent():GetParent()
	end
	return self.battlefield
end

function BattleUnitController:Clear()
	-- 清除事件 --
	local unitEvnt = require "Event.BattleUnitEventHandler"
	unitEvnt:UnRegisterEventHandler(self)
	self:ResetColliderTarget()

	-- 清除摄像机 bloom 效果 --
	self:ClearSkillCameraBloomEffect()
end

function BattleUnitController:GetId()
    return self.luaGameObject:GetId()
end

function BattleUnitController:ToString()
	return "BattleUnitController"
end

function BattleUnitController:OnSetLuaGameObject()
	if self.luaGameObject == nil then
		print("BattleUnitController:OnSetLuaGameObject failed, cause luaGameObject is nil.")
		return
	end

	-- 初始化组件 --
	local luaGameObject = self.luaGameObject
	self.motionCtrl = luaGameObject:GetComponent("MotionController")
	self.gameObject = luaGameObject:GetGameObject()
	self.transform = self.gameObject.transform
	self.animator = self.gameObject:GetComponent(typeof(UnityEngine.Animator))
	self.colliderListener = self.gameObject:GetComponent(typeof(BattleUnitColliderListener))
	self.animationEventListener = self.gameObject:GetComponent(typeof(AnimationEventListener))
	self.originalAnimatorSpeed = self.animator.speed
	
	-- 初始化动作!
	self.animator:Play(AnimatorStateName.Breath, 0, 0)
    self.animator:Update(0)

	-- 初始化Camera和CameraPath
	self:OnInitCamera()
end

function BattleUnitController:Pause()
	-- debug_print("@Pause, BattleUnitController:Pause, name:", self:GetGameObject().name)
	self.animator.speed = 0
end

function BattleUnitController:Resume()
	-- debug_print("@Resume, BattleUnitController:Resume, name:", self:GetGameObject().name)
	self.animator.speed = self.originalAnimatorSpeed
	-- debug_print("@Resume, BattleUnitController:Resume, name:", self:GetGameObject().name, self.animator.speed)
end

-- 获得指定挂点 --
function BattleUnitController:GetHitTransform(parentName)
	return self:GetChildTransform(parentName) or self.transform
end

function BattleUnitController:GetChildTransform(name)
	return self.transform:Find(name)
end


-- @ 1. 被动技能
local function ExecutePassiveSkill(self)
	local passiveSkill = self.luaGameObject:GetPassiveSkill()
	if passiveSkill ~= nil then
		passiveSkill:OnBattleStart()
	end
end


-- 添加天赋
local function AddTalentProperties(unit, talentData)
	unit:AddExtraApValue(talentData:GetAp())
	unit:AddExtraApRate(talentData:GetApRate())
	unit:AddExtraHpLimitValue(talentData:GetHpLimit())
	unit:AddExtraHpLimitRate(talentData:GetHpLimitRate())
	unit:AddExtraDpValue(talentData:GetDp())
	unit:AddRage(talentData:GetAngerNum())
	unit:AddExtraCritRate(talentData:GetCritRate())
	unit:AddExtraCritDamageRate(talentData:GetCritDamage())
	unit:AddExtraAvoidRate(talentData:GetAvoidRate())
	unit:AddExtraVamRate(talentData:GetVamRate())
	unit:AddExtraAttackDamageValue(talentData:GetAttackDamage())
	unit:AddExtraSkillDamageValue(talentData:GetSkillDamage())
	unit:AddExtraDecritRate(talentData:GetDecritRate())
	unit:AddExtraSpeedValue(talentData:GetSpeed())
	unit:AddExtraHitRate(talentData:GetHitRate())
end


-- 套牌
local function ExecuteRoleCardGroupTalents(self, units)

	local role = self.luaGameObject:GetRoleData()
	
	local cardGroupTalents = role:GetCardGroupTalents()
	
	local count = cardGroupTalents:Count()
	
	for i = 1, count do
		local talentData = cardGroupTalents:Get(i)
		
		for _, v in pairs(units) do
		
			local roleTalents = v:GetRoleData():GetCardGroupTalents()
			if roleTalents:Exists(talentData:GetId()) then
				AddTalentProperties(v, talentData)
			end
			
		end
	
	end
	
end

-- 种族
local function ExecuteRoleRaceTalents(self, units)
	local role = self.luaGameObject:GetRoleData()

	local raceTalents = role:GetRaceTalents()

	local count = raceTalents:Count()

	for i = 1, count do
		local talentData = raceTalents:Get(i)
		
		for _, v in pairs(units) do

			if talentData:GetExtendID() > 0 and talentData:GetExtendID() == v:GetRace() then
				AddTalentProperties(v, talentData)
			end
			
		end
	end
end

-- 团队天赋(种族)
local function ExecuteTeamRaceTalents(self, units)
	local role = self.luaGameObject:GetRoleData()
	local teamRaceTalents = role:GetTeamRaceTalents()

	local count = teamRaceTalents:Count()
	for i = 1, count do
		local talentData = teamRaceTalents:Get(i)

		for _, v in pairs(units) do
			if talentData:GetExtendID() == 0 or talentData:GetExtendID() == v:GetRace() then
				debug_print("@团队天赋加成@", "条件种族ID", talentData:GetExtendID(), "目标", v:GetGameObject().name, "种族", v:GetRace())
				AddTalentProperties(v, talentData)
			end
		end
	end
end

-- @ 2. 天赋(套牌/种族)
local function ExecuteRoleTalents(self)
	
	local allMates = self.luaGameObject:GetMembers()

	-- 套牌 --
	ExecuteRoleCardGroupTalents(self, allMates)

	-- 种族 --
	ExecuteRoleRaceTalents(self, allMates)

	-- 团队天赋(种族) --
	ExecuteTeamRaceTalents(self, allMates)
end

function BattleUnitController:OnBattleStarted()
	if self.started then
		return
	end

	-- @ 1. 被动技能(羁绊)
	ExecutePassiveSkill(self)
	
	-- @ 2. 天赋
	ExecuteRoleTalents(self)

	-- @ 3. 更新数值
	self.luaGameObject:UpdateStaticData()

	-- 血条
	self.luaGameObject:InitHpBar()
	self.luaGameObject:GetStateManager():SetVisible(true)
	
	-- 防止一个人 重复执行! --
	self.started = true
end

function BattleUnitController:OnRageChanged(changedValue, value)
	-- if changedValue > 0 then
	-- 	self:PlayRageUpEffect()
	-- end
end

function BattleUnitController:OnHpChanged(changedValue, value, isCrit, isLastAction)
	local isDamaged = changedValue < 0

	local valueToShow = math.abs(changedValue)

	if isDamaged then
		self:PlayTextEffect(valueToShow, isCrit)
		self:PlayDamageWordEffect()

		if not self.luaGameObject:IsAlive() then
			if isLastAction then
				self:OnHandlePreDie()
			end
			cos3dGame:DispatchEvent(MessageGuids.BattleUnitDead, nil, self.luaGameObject)
			return
		end
	else
		self:PlayHealTextEffect(valueToShow)
	end
	
	self.luaGameObject:UpdateHpBar()
end


function BattleUnitController:OnAssistAttack(leaderUnit)
	self.lastCommand = LastCommand.Attack
	self:ResetAttackTimes()
end

function BattleUnitController:ManualSkillDiscarded()
	if self.lastCommand == LastCommand.Skill then
		self.lastCommand = LastCommand.Attack
	end
end

local function PrepareSkill(self)
end

-- 技能使用次数
function BattleUnitController:ResetAttackTimes()
	self.usedAttackTimes = 0
	debug_print("@技能使用次数", "重置", self.luaGameObject:GetGameObject().name, self.usedAttackTimes)
end

function BattleUnitController:NextAttack()
	debug_print("@技能使用次数", self.luaGameObject:GetGameObject().name, self.usedAttackTimes, self.usedAttackTimes + 1)
	self.usedAttackTimes = self.usedAttackTimes + 1
end

function BattleUnitController:IsLastAttack()
	debug_print("@技能使用次数", self.luaGameObject:GetGameObject().name, self.usedAttackTimes, self.luaGameObject:GetCurrentSkill():GetAttackCount(), debug.traceback())
	return self.usedAttackTimes >= self.luaGameObject:GetCurrentSkill():GetAttackCount()
end

function BattleUnitController:TakeAction()

	local battleUnit = self.luaGameObject
	self:ResetAttackTimes()

	-- @ check @ --
	if not self.luaGameObject:IsAlive() then
		error(string.format("当前角色已死亡, 不能行动! id: %d, side: %d, pos: %d", self:GetId(), self:OnGetSide(), battleUnit:GetLocation()))
	end

	debug_print("@@@@@@@@@##### 开始行动 #####@@@@@@@@@", self:GetGameObject().name, debug.traceback())

	-- @@ 准备行动 @@ --

	-- @ 1. 自己的buff执行 (时机是行动前)
	battleUnit:ExecuteUnitStateAction(kUnitState_Phase_ActionStart)

	-- @ 2. 是否不能行动 (眩晕, 死亡等状态)
	if battleUnit:NeedSkipAction() then
		cos3dGame:DispatchEvent(MessageGuids.BattleTakeAction, nil, self.luaGameObject, false)
		battleUnit:UnitMoved()
		return
	end

	-- @@ 判断 主动技能和攻击 哪一个可以使用! @@ --
	local canUseSkill = true

	if battleUnit:CanUseActiveSkill() then
		-- @ 3. 是否能发动主动技能 (condition, 怒气等条件判断)
		self.lastCommand = LastCommand.Skill
	elseif battleUnit:CanUseAttackSkill() then
		-- @ 4. 是否能发动攻击 (condition 判断)
		self.lastCommand = LastCommand.Attack
	else
		canUseSkill = false
	end

	-- @@ 不能使用任何技能, 跳过 @@ --
	if not canUseSkill then
		cos3dGame:DispatchEvent(MessageGuids.BattleTakeAction, nil, self.luaGameObject, false)
		battleUnit:UnitMoved()
		return
	end

	-- @@ 开始使用技能 @@ --
	if self.lastCommand == LastCommand.Skill then
		battleUnit:UseActiveSkill()
	else
		battleUnit:UseAttackSkill()
	end
end

function BattleUnitController:GetHash()
	return self.luaGameObject:GetHash()
end

function BattleUnitController:GetTargets()
	return self.luaGameObject:GetTargets()
end

function BattleUnitController:GetLastTargets()
	return self.luaGameObject:GetLastTargets()
end

function BattleUnitController:GetTargetsGameObject()
	return self.luaGameObject:GetTargetsGameObject()
end

function BattleUnitController:CalculateDamage(target, skillDamageRateReplacement)
	return self.luaGameObject:CalculateDamage(target, skillDamageRateReplacement)
end

function BattleUnitController:CalculateHeal()
	return self.luaGameObject:CalculateHeal()
end

function BattleUnitController:IsUsingSkill()
	return self.lastCommand == LastCommand.Skill
end

function BattleUnitController:OnHandleDamageLogic(isLastAction)
	self.luaGameObject:OnHandleDamage(isLastAction)
end

function BattleUnitController:OnMiss()
	self:PlayPropertyEffect(PropertyEffectItem.Status.Avoid)
end

function BattleUnitController:OnHandleResetLogic()
	local unit = self.luaGameObject

	if unit:IsReset() then
		return
	end

	unit:Reset()
	unit:NotifyDamageSourceReset()
end

function BattleUnitController:GetGameObject()
	return self.luaGameObject:GetGameObject()
end

function BattleUnitController:OnGetSide()
	return self.luaGameObject:OnGetSide()
end

function BattleUnitController:OnBlink(dest)
	if dest == 0 then
		local center = self.luaGameObject:GetFoeCenter()
		self.gameObject.transform.position = center.transform.position
	else
		-- TODO ：将物体放置于对应目标前
	end
end

-- 处理改变模型的缩放
function BattleUnitController:OnScaleModel(scale)
	self.luaGameObject:SetModelScale(scale)
end

function BattleUnitController:OnCallShield(id)
	-- 护盾
	self.luaGameObject:OnCallShield(id)
	self.isUnderAttackExit = true
	-- self.luaGameObject:NotifiedReset()
end

function BattleUnitController:OnCritDamage()
	--print("BattleUnitController:OnCritDamage "..self.gameObject.name)
	-- TODO : 处理暴击震屏
end

function BattleUnitController:OnHandleStrikeBackLogic()
	--print("BattleUnitController:OnHandleStrikeBackLogic"..self.gameObject.name)
	-- TODO :
end

function BattleUnitController:SetColliderTarget(gameObject)
	self.colliderListener.Target = gameObject
	collision:RegisterEventHandler(self)
end

function BattleUnitController:ResetColliderTarget()
	self.colliderListener.Target = nil
	collision:UnRegisterEventHandler(self)
end

function BattleUnitController:AddBullet(bullet)
	self.luaGameObject:AddBullet(bullet)
end

function BattleUnitController:RemoveBullet(bullet)
	self.luaGameObject:RemoveBullet(bullet)
end

function BattleUnitController:GetBulletCount()
	return self.luaGameObject:GetBulletCount()
end

function BattleUnitController:OnCollisionDetected(dst)
	if self.colliderListener.Target == dst then
		self.motionCtrl:Stop()
		self:ResetColliderTarget()
		if self.lastCommand == LastCommand.Attack then
			self.luaGameObject:GetAttackSkill():Arrived()
		else
			self.luaGameObject:GetActiveSkill():Arrived()
		end
	end
end

-- 播放飘字效果
function BattleUnitController:PlayTextEffect(loseHp, isCrit)
	local uiManager = utility.GetGame():GetUIManager()

	local prefab

	if isCrit then
		prefab = uiManager:GetCritEffectTextObject()
	else
		prefab = uiManager:GetEffectTextObject()
	end

	self:ShowEffect(
		prefab, 
		EffectTextItem,
		function(effectComponent)
				effectComponent.target = self.gameObject.transform
				effectComponent:SetValue(loseHp)
				effectComponent:Play(1)
		end
	)
end

function BattleUnitController:PlayHealTextEffect(hp)
	local uiManager = utility.GetGame():GetUIManager()
	
	local prefab = uiManager:GetHealEffectTextObject()

	self:ShowEffect(
		prefab,
		EffectTextItem,
		function(effectComponent)
			effectComponent.target = self.gameObject.transform
			effectComponent:SetValue(hp)
			effectComponent:Play(1)
		end
	)
end

-- 播放打击字效果
function BattleUnitController:PlayDamageWordEffect()
	local uiManager = utility.GetGame():GetUIManager()

	local prefab = uiManager:GetDamageWordEffectObject()

    self:ShowEffect(prefab, BaseHitEffect,
            function(effect_comp)
                effect_comp.target = self.gameObject.transform
				effect_comp.offset = Vector2(math.random(-120,40), math.random(-80,40))
                effect_comp:Play(1)
            end)
end

-- 播放怒气上升
function BattleUnitController:PlayRageUpEffect()
	self:PlayPropertyEffect(PropertyEffectItem.Status.RageUp)
end
-- 播放怒气下降
function BattleUnitController:PlayRageDownEffect()
	self:PlayPropertyEffect(PropertyEffectItem.Status.RageDown)
end
-- 播放怒气, 闪避等效果
-- status: PropertyEffectItem.Status (RageUp, RageDown, Avoid)
function BattleUnitController:PlayPropertyEffect(status)
	local uiManager = utility.GetGame():GetUIManager()

	local prefab = uiManager:GetPropertyEffectItemObject()

	self:ShowEffect(prefab, PropertyEffectItem,
			function(effect_comp)
				effect_comp.target = self.gameObject.transform
				effect_comp:SetStatus(status)
				effect_comp:Play(1)
			end)
end

-- 处理显示效果的创建
function BattleUnitController:ShowEffect(prefab, componentType, handler)
	
	local battlefield = self:GetBattlefield()

	-- 当前的世界摄像机对象
	local cameraObject = battlefield:GetCurrentCamera()
	local worldCamera = cameraObject:GetComponent(typeof(UnityEngine.Camera))
	
	-- 获取UI摄像机
	local uiManager = utility.GetGame():GetUIManager()
	local canvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()
	local uiCamera = uiManager:GetBattleUICanvas():GetCamera()
	
	-- 实例化(这个地方的接口需要变更)
	local instancedObject = UnityEngine.GameObject.Instantiate(prefab)
	instancedObject:SetActive(true)
	
	-- 获取组件
	local effectComponent = instancedObject:GetComponent(typeof(componentType))
	
	-- 缓存transform
	local trans = effectComponent.cachedTrans

	-- 设置缩放
	trans:SetParent(canvasTransform, true)
	trans.localPosition = Vector3(0,0,0)
	trans.localRotation = Quaternion.identity
	trans.localScale = Vector3(1,1,1)
	
	effectComponent.worldCamera = worldCamera
	effectComponent.uiCamera = uiCamera
	
	
	-- 调用处理函数把组件传给上层去处理
	handler(effectComponent)
end

function BattleUnitController:Arrived()
	print("BattleUnitController:Arrived "..self:GetGameObject().name, self.luaGameObject:IsAlive())
	--self.lastCommand = LastCommand.Arrived
	self.luaGameObject:RestoreRotation()
	self:JumpBack2Breath()
	-- TODO : 反击相关
end

function BattleUnitController:IsStrikeBack()
	-- TODO : 是否反击
	return false
end

function BattleUnitController:IsFaint()
	-- TODO : 是否处于眩晕状态
	return false
end