require "Event.EventHandler"
require "Battle.Bullet"

local messageGuids = require "Framework.Business.MessageGuids"
local utility = require "Utils.Utility"
local myGame = utility.GetGame()
require "Const"

BattleUnitEventHandler = Class(EventHandler)

function BattleUnitEventHandler:ToString()
	return "BattleUnitEventHandler"
end

local unitEvent = BattleUnitEventHandler.New()

--==============================--
-- 伤害处理相关
--==============================--
local function GetTeamOfAttackeeShieldTarget(attacker)
	local team = attacker:GetParent():GetFoeTeam()
	return team:GetLastShield()
end

-->> 真实伤害的实现 <<--
function _G.OnReceiveDamageRealImplementation(damageSource, target, skillDamageRateReplacement)
	local isLastAction = damageSource:IsLastAttack()
	-- debug_print("@@伤害事件帧#", damageSource:GetGameObject().name, isLastAction)
	local damageValue, isCritDamage = damageSource:CalculateDamage(target, skillDamageRateReplacement)
	myGame:DispatchEvent(messageGuids.FightAddDamageRecord, nil, damageSource.luaGameObject, damageValue)
	target:OnReceiveDamage(damageSource, damageValue, isCritDamage, isLastAction)
end

--> 仅播放一次动作 不处理伤害 <--
local function OnReceiveDamageActionOnce(damageSource)
	
	if GetTeamOfAttackeeShieldTarget(damageSource.luaGameObject) ~= nil then
		return
	end

	local targetInfo = damageSource:GetTargets()
	if targetInfo ~= nil then
		for i = 1, targetInfo:Count() do
			local target = targetInfo:GetTarget(i)
			if target ~= nil then
				target:OnReceiveDamageActionOnce(damageSource)
			end
		end
	end
end

--> 循环播放动作 不处理伤害(间隔时间在Skill表里)
local function OnReceiveDamageActionLoop(damageSource)

	if GetTeamOfAttackeeShieldTarget(damageSource.luaGameObject) ~= nil then
		return
	end

	local targetInfo = damageSource:GetTargets()
	if targetInfo ~= nil then
		for i = 1, targetInfo:Count() do
			local target = targetInfo:GetTarget(i)
			if target ~= nil then
				target:OnReceiveDamageActionLoop(damageSource)
			end
		end
	end
end

--> 不播放动作 只播放特效 不处理伤害
local function OnReceiveDamageNoAction(damageSource)

	if GetTeamOfAttackeeShieldTarget(damageSource.luaGameObject) ~= nil then
		return
	end

	local targetInfo = damageSource:GetTargets()
	if targetInfo ~= nil then
		for i = 1, targetInfo:Count() do
			local target = targetInfo:GetTarget(i)
			if target ~= nil then
				target:OnReceiveDamageNoAction(damageSource)
			end
		end
	end
end

--> 播放动作 处理伤害
local function OnReceiveDamageNormal(damageSource)

	-- debug_print("@@伤害事件帧", damageSource:GetGameObject().name)

	damageSource:NextAttack()

	local shieldTarget = GetTeamOfAttackeeShieldTarget(damageSource.luaGameObject)
	if shieldTarget ~= nil then
		_G.OnReceiveDamageRealImplementation(damageSource, shieldTarget)
		return
	end

	local targetInfo = damageSource:GetTargets()
	if targetInfo ~= nil then
		for i = 1, targetInfo:Count() do
			local target = targetInfo:GetTarget(i)
			if target ~= nil then
				_G.OnReceiveDamageRealImplementation(damageSource, target)
			end
		end
	end
end

local function OnNotifyDamage(handler, srcGameObject, intParam)
	if handler:GetGameObject() ~= srcGameObject then
		return
	end

	-- debug_print("@@##伤害事件帧", handler:GetGameObject().name)

	if intParam == kBattleReceiveDamageParam_ActionOnce then
		OnReceiveDamageActionOnce(handler)
	elseif intParam == kBattleReceiveDamageParam_ActionLoop then
		OnReceiveDamageActionLoop(handler)
	elseif intParam == kBattleReceiveDamageParam_NoAction then
		OnReceiveDamageNoAction(handler)
	else
		OnReceiveDamageNormal(handler)
	end
end

function _G.BattleUnitOnNotifyDamage(srcGameObject, intParam)
	unitEvent:Dispatch(OnNotifyDamage, srcGameObject, intParam)
end

--==============================--
-- 治疗处理相关
--==============================--
local function OnNotifyHeal(handler, srcGameObject)
	if handler:GetGameObject() ~= srcGameObject then
		return
	end
	
	local healSource = handler

	healSource:NextAttack()

	local targetInfo = healSource:GetTargets()
	for i = 1, targetInfo:Count() do
		local target = targetInfo:GetTarget(i)
		if target ~= nil then
			target:OnReceiveHeal(healSource, healSource:CalculateHeal())
		end
	end
end

function _G.BattleUnitOnNotifyHeal(srcGameObject)
	unitEvent:Dispatch(OnNotifyHeal, srcGameObject)
end

--==============================--
-- 跳过一次攻击次数(不执行任何东西, 可选择性播放特效)
--==============================--
local function OnNotifySkipOnce(handler, srcGameObject)
	if handler:GetGameObject() ~= srcGameObject then
		return
	end
	handler:NextAttack()

	handler:OnNotifySkipAttackOnce()

	--debug_print("Skip this time!")

end

function _G.BattleUnitOnNotifySkipOnce(srcGameObject)
	unitEvent:Dispatch(OnNotifySkipOnce, srcGameObject)
end

--==============================--
-- 攻击结束
--==============================--
local function OnAttackStateExit(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnAttackStateExit()
end

function _G.BattleUnitOnAttackStateExit(gameObject)
	unitEvent:Dispatch(OnAttackStateExit, gameObject)
end

--==============================--
-- 技能开始 (或3段)
--==============================--
local function OnSkillStateEnter(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnSkillStateEnter()
end

function _G.BattleUnitOnSkillStateEnter(gameObject)
	unitEvent:Dispatch(OnSkillStateEnter, gameObject)
end

--==============================--
-- 技能结束 (或3段)
--==============================--
local function OnSkillStateExit(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	debug_print("skill state skill", gameObject)
	handler:OnSkillStateExit()
end

function _G.BattleUnitOnSkillStateExit(gameObject)
	debug_print("raw skill state exit", gameObject.name)
	unitEvent:Dispatch(OnSkillStateExit, gameObject)
end

--==============================--
-- 技能2段开始
--==============================--
local function OnSkill02StateEnter(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnSkill02StateEnter()
end

function _G.BattleUnitOnSkill02StateEnter(gameObject)
	unitEvent:Dispatch(OnSkill02StateEnter, gameObject)
end

--==============================--
-- 再次显示目标
--==============================--
local function OnSkillShowTargets(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnSkillShowTargets()
end

function _G.BattleUnitOnSkillShowTargets(gameObject)
	unitEvent:Dispatch(OnSkillShowTargets, gameObject)
end

--==============================--
-- 处理伤害逻辑(已废弃)
--==============================--
function _G.BattleUnitHandleDamageLogic(gameObject)
end

--==============================--
-- 受击状态结束
--==============================--
local function OnUnderAttackStateExit(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	debug_print("@受击事件帧", handler:GetGameObject().name, debug.traceback())
	handler:OnUnderAttackStateExit()
end

function _G.BattleUnitUnderAttackStateExit(gameObject)
	-- debug_print("@原始受击事件帧", gameObject.name)
	unitEvent:Dispatch(OnUnderAttackStateExit, gameObject)
end

--==============================--
-- 死亡状态结束
--==============================--
local function OnDieStateExit(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnDieStateExit()
end

function _G.BattleUnitDieStateExit(gameObject)
	unitEvent:Dispatch(OnDieStateExit, gameObject)
end

--==============================--
-- 反击逻辑(未实现) 
--==============================--
function _G.BattleUnitHandleStrikeBackLogic(gameObject)
end

--==============================--
-- 反击状态结束(未实现)
--==============================--
function _G.BattleUnitStrikeBackStateExit(gameObject)
end

--==============================--
-- 重置状态逻辑
--==============================--
local function OnHandleResetLogic(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end
	debug_print("handle reset logic", gameObject.name)
	handler:OnHandleResetLogic()
end

function _G.BattleUnitHandleResetLogic(gameObject)
	debug_print("raw handle reset logic", gameObject.name)
	unitEvent:Dispatch(OnHandleResetLogic, gameObject)
end

--==============================--
-- 跳回状态开始
--==============================--
local function OnJumpBackStateEnter(handler, gameObject)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnJumpBackStateEnter()
end

function _G.BattleUnitJumpBackStateEnter(gameObject)
	unitEvent:Dispatch(OnJumpBackStateEnter, gameObject)
end

--==============================--
-- 飞行物
--==============================-- 
local function OnMoveAttackEffect(handler, sourceGameObject, effectId)
	if handler:GetGameObject() ~= sourceGameObject then
		return
	end

	local sourceUnitController = handler

	sourceUnitController:NextAttack()

	local shieldTarget = GetTeamOfAttackeeShieldTarget(sourceUnitController.luaGameObject)
	if shieldTarget ~= nil then
		local bullet = Bullet.New(effectId, sourceUnitController)
		sourceUnitController:AddBullet(bullet)
		bullet:MoveToTarget(shieldTarget, bullet)
		return
	end

	local targetInfo = sourceUnitController:GetTargets()
	local targetCount = targetInfo:Count()
	for i = 1, targetCount do 
		local targetUnit = targetInfo:GetTarget(i)
		if targetUnit ~= nil then
			local bullet = Bullet.New(effectId, sourceUnitController)
			sourceUnitController:AddBullet(bullet)
			bullet:MoveToTarget(targetUnit, bullet)
		end
	end
end

function _G.MoveAttackEffect(effectId, sourceGameObject)
	unitEvent:Dispatch(OnMoveAttackEffect, sourceGameObject, effectId)
end

--==============================--
-- 缩放模型
--==============================-- 
local function OnBattleUnitScaleModel(handler, gameObject, scale)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	debug_print("@缩放模型", handler:GetGameObject().name, scale)
	handler:OnScaleModel(scale)
end

function _G.BattleUnitScaleModel(gameObject, scale)
	--debug_print("@缩放模型", "1", gameObject.name, scale)
	unitEvent:Dispatch(OnBattleUnitScaleModel, gameObject, scale)
end
--==============================--
-- 护盾
--==============================-- 
local function OnBattleUnitShield(handler, gameObject, id)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnCallShield(id)
end

function _G.BattleUnitShield(gameObject, id)
	unitEvent:Dispatch(OnBattleUnitShield, gameObject, id)
end

--==============================--
-- 判断是哪一波(以后会废弃)
--==============================--

function _G.BattleUnitGetSide(gameObject)
	local table = unitEvent.eventHandlerTable
	for i = 1, #table do
		if (table[i] ~= nil) and (table[i]:GetGameObject() == gameObject) then
			return table[i]:OnGetSide()
		end
	end
end

--==============================--
-- 返回目标table的GameObject列表
--==============================--
function _G.BattleUnitGetTargetsGameObject(gameObject)
	local table = unitEvent.eventHandlerTable
	for i = 1, #table do
		if (table[i] ~= nil) and (table[i]:GetGameObject() == gameObject) then
			return table[i]:GetTargetsGameObject()
		end
	end
end

--==============================--
-- 闪现
--==============================--
local function OnBlink(handler, gameObject, dest)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnBlink(dest)
end

function _G.BattleUnitBlink(gameObject, dest)
	unitEvent:Dispatch(OnBlink, gameObject, dest)
end

--==============================--
--- 激活指定摄像机序号(现在是1-2-3段时才使用)
--==============================--
local function OnActivePlayerCamera(handler, gameObject, id)
	if handler:GetGameObject() ~= gameObject then
		return
	end
	handler:OnActivePlayerCamera(id)
end

function _G.BattleActivePlayerCamera(gameObject, id)
	unitEvent:Dispatch(OnActivePlayerCamera, gameObject, id)
end

--==============================--
-- 震屏
--==============================--
local function OnShakeCamera(handler, gameObject, id)
	if handler:GetGameObject() ~= gameObject then
		return
	end

	handler:OnShakeCamera(id)
end

function _G.BattleUnitShakeCamera(gameObject, id)
	unitEvent:Dispatch(OnShakeCamera, gameObject, id)
end

--==============================--
-- 清除所有事件注册
--==============================--
function _G.ClearBattleUnitEventHandler()
	unitEvent:Clear()
end

return unitEvent
