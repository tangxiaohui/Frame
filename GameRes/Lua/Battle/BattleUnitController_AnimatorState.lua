local unitEvent = require "Event.BattleUnitEventHandler"
local unityUtils = require "Utils.Unity"
local utility = require "Utils.Utility"
local MessageGuids = require "Framework.Business.MessageGuids"
local cos3dGame = utility.GetGame()

BattleUnitController = Class(LuaComponent)

AnimatorStateName = {
    ShowOff = "Show Off", 
    Breath = "Breath", 
    Run = "Run", 
    Attack = "Attack", 
    JumpBack = "Jump Back",
    PrepareSkill = "Prepare Skill",
    Skill01 = "Skill01",
    Skill02 = "Skill02",
    Skill = "Skill",
    UnderAttack = "Under Attack", 
    Die = "Die", 
    StrikeBack = "Strike Back", 
    Faint = "Faint",
}

-- 状态的 shortNameHash, 调试用
--ShowOff   		-134167279
--Breath 			1033325269
--Run				1748754976
--Attack			1080829965
--JumpBack		    -2059420618
--PrepareSkill	    1003784298
--Skill01 		    -941258041
--Skill02			1592580989
--Skill			    -1610822797
--UnderAttack		-1020194701
--Die				20298039
--StrikeBack		-1736874225
--Faint 			2031864113


-- 技能01和技能02, 分别为蓄力和跑
local skill01_state_id = UnityEngine.Animator.StringToHash(AnimatorStateName.Skill01)
local skill02_state_id = UnityEngine.Animator.StringToHash(AnimatorStateName.Skill02)


local PLAYER_LAYER = 'Toon'
local PLAYER_SKILL_LAYER = 'SkillAnimation'
local PLAYER_INVISIBLE_LAYER = 'Invisible'


local function ResetAllTriggers(self)
    self.animator:ResetTrigger("Breath2Run")
    self.animator:ResetTrigger("Breath2Attack")
    self.animator:ResetTrigger("Breath2Under Attack")
    self.animator:ResetTrigger("Breath2Show Off")
    self.animator:ResetTrigger("Run2Attack")
    self.animator:ResetTrigger("Attack2Jump Back")
    self.animator:ResetTrigger("Jump Back2Breath")
    self.animator:ResetTrigger("Attack2Breath")
    self.animator:ResetTrigger("Under Attack2Breath")
    self.animator:ResetTrigger("Under Attack2Strike Back")
    self.animator:ResetTrigger("Strike Back2Breath")
    self.animator:ResetTrigger("Under Attack2Die")
    self.animator:ResetTrigger("Under Attack2Faint")
    self.animator:ResetTrigger("Faint2Breath")
    self.animator:ResetTrigger("Skill2Breath")
    self.animator:ResetTrigger("Breath2Skill")
    self.animator:ResetTrigger("Run2Skill")
    self.animator:ResetTrigger("Skill2Jump Back")
    self.animator:ResetTrigger("Faint2Under Attack")
    self.animator:ResetTrigger("Strike Back2Faint")
    self.animator:ResetTrigger("Under Attack2Under Attack")
end

--==============================--
-- 所有 动画 Trigger 切换的函数 --
--==============================--

local function SetTrigger(self, name)
    ResetAllTriggers(self)
    self.animator:SetTrigger(name)

    self.previousTriggerName = self.currentTriggerName
    self.currentTriggerName = name
end

local function Attack2Breath(self)
    --debug_print("@@@* Attack2Breath", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Attack)
    SetTrigger(self, "Attack2Breath")
end

local function Attack2JumpBack(self)
    --debug_print("@@@* Attack2JumpBack", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Attack)
    SetTrigger(self, "Attack2Jump Back")
end

local function Any2UnderAttack(self)
    --debug_print("@@@* Any2UnderAttack", self:GetGameObject().name)
    ResetAllTriggers(self)
    self.animator:CrossFade(AnimatorStateName.UnderAttack, 0, 0, 0)
end

local function Breath2PrepareSkill(self)
    --debug_print("@@@* Breath2PrepareSkill", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Breath)
    SetTrigger(self, "Breath2Prepare Skill")
end

local function UnderAttack2Die(self)
    --debug_print("@@@* UnderAttack2Die", self:GetGameObject().name, debug.traceback())
    self.animator:Play(AnimatorStateName.UnderAttack)
    SetTrigger(self, "Under Attack2Die")
end

local function UnderAttack2StrikeBack(self)
    --debug_print("@@@* UnderAttack2StrikeBack", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.UnderAttack)
    SetTrigger(self, "Under Attack2Strike Back")
end

local function UnderAttack2Faint(self)
    --debug_print("@@@* UnderAttack2Faint", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.UnderAttack)
    SetTrigger(self, "Under Attack2Faint")
end

local function UnderAttack2Breath(self)
    --debug_print("@@@* UnderAttack2Breath", self:GetGameObject().name, debug.traceback())
    self.animator:Play(AnimatorStateName.UnderAttack)
    SetTrigger(self, "Under Attack2Breath")
end

local function StrikeBack2Faint(self)
    --debug_print("@@@* StrikeBack2Faint", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.StrikeBack)
    SetTrigger(self, "Strike Back2Faint")
end

local function StrikeBack2Breath(self)
    --debug_print("@@@* StrikeBack2Breath", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.StrikeBack)
    SetTrigger(self, "Strike Back2Breath")
end

-- 只会在一开始的时候调用, 所以这里改动只会影响一处.
-- note: 当有一天影响不只一处的时候 需要重新审视代码!
function BattleUnitController:Breath2ShowOff()
    --debug_print("@@@* Breath2ShowOff", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.ShowOff, 0, 0)
    self.animator:Update(0)
end

function BattleUnitController:Breath2Run()
    --debug_print("@@@* Breath2Run", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Breath)
    SetTrigger(self, "Breath2Run")
end

function BattleUnitController:Breath2Attack()
    --debug_print("@@@* Breath2Attack", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Breath)
    SetTrigger(self, "Breath2Attack")
end

function BattleUnitController:Breath2Skill()
    --debug_print("@@@* Breath2Skill", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Breath)
    SetTrigger(self, "Breath2Skill")
end

function BattleUnitController:PrepareSkill2Skill()
    --debug_print("@@@* PrepareSkill2Skill", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.PrepareSkill)
    SetTrigger(self, "Prepare Skill2Skill")
end

function BattleUnitController:PrepareSkill2Run()
    --debug_print("@@@* PrepareSkill2Run", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.PrepareSkill)
    SetTrigger(self, "Prepare Skill2Run")
end

function BattleUnitController:Run2Skill()
    --debug_print("@@@* Run2Skill", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Run)
    SetTrigger(self, "Run2Skill")
end

function BattleUnitController:Run2Attack()
    --debug_print("@@@* Run2Attack", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Run)
    SetTrigger(self, "Run2Attack")
end

function BattleUnitController:JumpBack2Breath()
    --debug_print("@@@* JumpBack2Breath", self:GetGameObject().name)
    SetTrigger(self, "Jump Back2Breath")
end

function BattleUnitController:Skill2Breath()
    --debug_print("@@@* Skill2Breath", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Skill)
    SetTrigger(self, "Skill2Breath")
end

function BattleUnitController:Faint2Breath()
    --debug_print("@@@* Faint2Breath", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Faint)
    SetTrigger(self, "Faint2Breath")
end

function BattleUnitController:Skill2JumpBack()
    --debug_print("@@@* Skill2JumpBack", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Skill)
    SetTrigger(self, "Skill2Jump Back")
end

function BattleUnitController:Breath2Skill01()
    --debug_print("@@@* Breath2Skill01", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Breath)
    SetTrigger(self, "Breath2Skill01")
end

function BattleUnitController:Skill022Skill()
    --debug_print("@@@* Skill022Skill", self:GetGameObject().name)
    self.animator:Play(AnimatorStateName.Skill02)
    SetTrigger(self, "Skill022Skill")
end



--==============================--
--==============================--

local function HasState(self, id)
    return self.animator:HasState(0, id)
end

local function IsRightSide(self)
    return self:OnGetSide() == 1
end

local function IsCameraPathEnable()
    return utility.IsCameraPathEnable()
end

local function CanPlaySkillCameraAnimation(self)
    return IsRightSide(self) and IsCameraPathEnable()
end

local function CanStopSkillCameraAnimation(self)
    return IsRightSide(self)
end

-- FIXME: 暂时保留旧接口
local function GetBattlefield(self)
    return self:GetBattlefield()
end

function BattleUnitController:ResetAnimator()
    --self.isBreath2UnderAttack = false
    --self.isFaint2UnderAttack = false
	self.isUnderAttackExit = false
	-- self.isAttackerSkillExit = false
end

function BattleUnitController:HasStateSkill01()
    return HasState(self, skill01_state_id)
end

function BattleUnitController:HasStateSkill02()
    return HasState(self, skill02_state_id)
end

function BattleUnitController:GetCurrentStateShortHash()
    local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
    return stateInfo.shortNameHash
end

function BattleUnitController:HasNextStateInfo()
    local nextStateInfo = self.animator:GetNextAnimatorStateInfo(0)
    return nextStateInfo ~= nil and nextStateInfo.shortNameHash ~= 0
end

function BattleUnitController:IsCurAnimatorStateBreath()
    local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)

    local nextStateInfo = self.animator:GetNextAnimatorStateInfo(0)
    local nextHash = 0
    if nextStateInfo ~= nil then
        nextHash = nextStateInfo.shortNameHash
    end

    --print("@@ 动画机状态 ", self:GetGameObject().name, stateInfo.shortNameHash, "next hash", nextHash)
    if stateInfo:IsName(AnimatorStateName.Breath) then
        return true
    end
    
    return false
end

function BattleUnitController:IsCurAnimatorStateSkill02()
    local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)

    if stateInfo:IsName(AnimatorStateName.Skill02) then
        return true
    end

    return false
end

function BattleUnitController:IsCurAnimatorStateSkill01()
    local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
    if stateInfo:IsName(AnimatorStateName.Skill01) then
        return true
    end

    return false
end

function BattleUnitController:IsCurAnimatorStateUnderAttack()
    local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
    if stateInfo:IsName(AnimatorStateName.UnderAttack) then
        return true
    end
    return false
end

function BattleUnitController:IsCurAnimatorStateRun()
    local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
    if stateInfo:IsName(AnimatorStateName.Run) then
        return true
    end

    return false
end



-- 获取当前主动技能(技能/攻击)
local function GetCurrentActiveSkill(self)
    local unit = self.luaGameObject

    if unit:IsUsingSkill() then
        return unit:GetActiveSkill()
    else
        return unit:GetAttackSkill()
    end
end

local function OnDelayDestroy(gameObject)
    coroutine.wait(10)
    if gameObject ~= nil then
        UnityEngine.Object.Destroy(gameObject)
    end
end

function BattleUnitController:PlayUnderAttackEffect(damageSrc, isDamage)
    local currentSkill = GetCurrentActiveSkill(damageSrc)

    -- 拿到特效ID --
    local effectID
    if isDamage then
        effectID = currentSkill:GetUnderAttackDamageEffectSpecialID()
    else
        effectID = currentSkill:GetUnderAttackEffectSpecialID()
    end

    print("受击特效ID >>>", effectID)

    if effectID > 0 then
        local parentName = currentSkill:GetUnderAttackParentName()
        utility.ASSERT(type(parentName) == "string", string.format("技能: %d 没有一个合法的受击挂点名",  currentSkill:GetId()))

        local specialEffectMgr = require "StaticData.SpecialEffect"
        local specialEffectData = specialEffectMgr:GetData(effectID)
        local effectIds = specialEffectData:GetEffectIDs()
        for i = 1, #effectIds do
            if effectIds[i] > 0 then
--                print("创建受击特效" ,effectIds[i], self.luaGameObject:GetGameObject().name)
                local go = ResCtrl.EffectPool.Instance():Pop(effectIds[i])
				if go ~= nil then
					local transform = go.transform
					local parentTransform = self:GetHitTransform(parentName)
					utility.ASSERT(parentTransform ~= nil, string.format("人物 '%s' 不存在挂点 '%s', 技能id: %d", self.luaGameObject:GetGameObject().name, parentName, currentSkill:GetId()))
					transform:SetParent(parentTransform, true)
					transform.localScale = Vector3(1, 1, 1)
					transform.localPosition = Vector3(0, 0, 0)
                    transform.localRotation = Quaternion.identity
                    coroutine.start(OnDelayDestroy, go)
				end
            end
        end
    end
end

function BattleUnitController:OnNotifySkipAttackOnce()
    self.luaGameObject:OnNotifySkipAttackOnce()
end

function BattleUnitController:OnReceiveDamage(damageSrc, isDamage, stopLoop, isLastAction)

    self:PlayUnderAttackEffect(damageSrc, isDamage)

    -- 停止之前的 --
    if stopLoop then
        if self._coLastDamageLoop ~= nil then
            coroutine.stop(self._coLastDamageLoop)
            self._coLastDamageLoop = nil
        end
    end
	
	self.isUnderAttackExit = false

    Any2UnderAttack(self)

    -- debug_print("@伤害事件帧%",damageSrc:GetGameObject().name, isDamage, isLastAction)

    if isDamage then
        self:OnHandleDamageLogic(isLastAction)
    end
end

function BattleUnitController:OnReceiveDamageActionOnce(damageSrc)
    self:OnReceiveDamage(damageSrc, false, true)
end

local function OnCoReceiveDamageLoop(self, internal, damageSrc, isDamage)
    repeat
        coroutine.wait(internal)
        self:OnReceiveDamage(damageSrc, isDamage, false)
    until(false)
end

function BattleUnitController:OnReceiveDamageActionLoop(damageSrc)
    self:OnReceiveDamage(damageSrc, false, true)

    -- 读表 --
    local currentSkill = GetCurrentActiveSkill(damageSrc)
    if currentSkill == nil then
        return
    end

    local internal = currentSkill:GetUnderAttackEffectInterval()

    if internal <= 0 then return end

    self._coLastDamageLoop = coroutine.start(OnCoReceiveDamageLoop, self, internal, damageSrc, false)
end

function BattleUnitController:OnReceiveDamageNoAction(damageSrc)
    -- 停止之前的 --
    if stopLoop then
        if self._coLastDamageLoop ~= nil then
            coroutine.stop(self._coLastDamageLoop)
            self._coLastDamageLoop = nil
        end
    end

    self:PlayUnderAttackEffect(damageSrc, false)
end

local function OnDelaySlowMotion(self, cameraObject)
	coroutine.wait(2 * UnityEngine.Time.timeScale)
	-- 恢复速度
	local speed = GetBattlefield(self):GetBattleSpeed()
	UnityEngine.Time.timeScale = speed
	GetBattlefield(self):DisableRadiarBlur(cameraObject)
	self.isSlowMotion = nil
end

local function OnHandlePreDie(self)    
	if self:OnGetSide() == 1 then
		return
	end

	if self.isSlowMotion then
		return
	end
		
	local battlefield = GetBattlefield(self)
	local result = battlefield:GetBattleResult()
	
	if type(result) == "number" and result == 1 and not battlefield:HasNextFoeTeam() then
		self.isSlowMotion = true
		UnityEngine.Time.timeScale = 0.3
		local cameraObject = battlefield:EnableRadiarBlur()
		coroutine.start(OnDelaySlowMotion, self, cameraObject)
	end
end

function BattleUnitController:OnHandlePreDie()
	OnHandlePreDie(self)
end

local function IsAllAttackerSkillExit(self)
    local units = self.luaGameObject:GetLastDamageSources():GetUnits()
    for i = 1, #units do
        -- debug_print("@技能攻击者攻击情况", "是否为最后一次攻击", units[i]:GetGameObject().name, units[i]:IsLastAttack())
        if not units[i]:IsLastAttack() then
            return false
        end
    end
    return true
end

function BattleUnitController:HandleUnitDie(isResetLogic, isUnderAttack)
    if not self.luaGameObject:IsAlive() then
        self.luaGameObject:GetPassiveSkill():OnDead()
        self.luaGameObject:MarkAsDead()  -- 标识死亡!

        if not self.luaGameObject:IsAlive() then
            if isResetLogic then self:OnHandleResetLogic() end
            if isUnderAttack then self.luaGameObject:OnUnderAttackExit() end
            UnderAttack2Die(self)
            return true
        end
    end
    return false
end

local function OnHandleUnderAttackExit(self)

    -- debug_print(self:GetGameObject().name, "isUnderAttackExit", self.isUnderAttackExit, "isAttackerSkillExit", self.isAttackerSkillExit)

	if self.isUnderAttackExit and IsAllAttackerSkillExit(self) then
	
        self:ResetAnimator()
		
		-- 停止之前的 --
		if self._coLastDamageLoop ~= nil then
			coroutine.stop(self._coLastDamageLoop)
			self._coLastDamageLoop = nil
		end
    
        self.luaGameObject:GetPassiveSkill():OnUnderAttackExit()
        
        if self:HandleUnitDie(true, true) then
            return true
        end
        
        UnderAttack2Breath(self)
        self:OnHandleResetLogic()
        self.luaGameObject:OnUnderAttackExit()
        return false
    end

    UnderAttack2Breath(self)
	return false
end

local function NotifySkillStateExit(self)
    local targetInfo = self.luaGameObject:GetTargets()
    if targetInfo ~= nil then
        local count = targetInfo:Count()
        for i = 1, count do
            local unit = targetInfo:GetTarget(i)
            debug_print("@NotifySkillStateExit ", self:GetGameObject().name, unit:GetGameObject().name)
            unit:OnAttackerSkillStateExit(self.luaGameObject)
        end
    end
end

function BattleUnitController:NotifySkillStateExit()
	NotifySkillStateExit(self)
end

function BattleUnitController:OnAttackerSkillStateExit(attacker)
    -- debug_print("@通知结束", "攻击者", attacker:GetGameObject().name, "自己", self:GetGameObject().name)

	-- self.isAttackerSkillExit = true
	
	-- -- 停止之前的 --
	-- if self._coLastDamageLoop ~= nil then
	-- 	coroutine.stop(self._coLastDamageLoop)
	-- 	self._coLastDamageLoop = nil
	-- end
	
	-- OnHandleUnderAttackExit(self)
end

-- function BattleUnitController:OnAttackStateExit()
--     print("BattleUnitController:OnAttackStateExit "..self.gameObject.name)
	
-- 	NotifySkillStateExit(self)
	
--     if self.luaGameObject:GetAttackSkill():IsLongRange() then
--         Attack2Breath(self)
--     else
--         Attack2JumpBack(self)
--     end
-- end

function BattleUnitController:OnAttackStateExit()
    print("BattleUnitController:OnAttackStateExit "..self.gameObject.name)
	
    if self.luaGameObject:GetAttackSkill():IsLongRange() then
        Attack2Breath(self)
    else
        Attack2JumpBack(self)
    end

    NotifySkillStateExit(self)
end

function BattleUnitController:OnJumpBackStateEnter()
    --print("BattleUnitController:OnJumpBackStateEnter "..self.gameObject.name)

    local stateInfo = self.animator:GetNextAnimatorStateInfo(0)
    if stateInfo.shortNameHash == 0 then
        stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
    end

    -- print('Jump Back Role:', self.gameObject.name, 'defaultPos:', tostring(self.luaGameObject:GetDefaultPosition()), 'now pos:', tostring(self.gameObject.transform.position))

    self.motionCtrl:MoveToPositionOnTime(self.luaGameObject:GetDefaultPosition(), self, stateInfo.length)
end



local function DelayPrepareSkill(self)
    coroutine.wait(0.5)
    Breath2PrepareSkill(self)
end

function BattleUnitController:OnCameraPathFinished(name)
--    print('camera path name :', name)
    
--    if self.luaGameObject:NeedPrepareSkill() then
--        local f1, f2 = string.find(name, "Camera_Path_S_RPos"..self.luaGameObject:GetLocation())
--        if (f1 == 1) and (f2 == string.len(name)) then
--            --print("battleUnitController:OnCameraPathFinished "..name)
--            coroutine.start(DelayPrepareSkill, self)
--        end
--    end
end

-- 调试输出
local function GetCameraName(camera)
    if camera then
        return camera.name
    end
    return '<nil>'
end

local function SetLayerRecursively(gameObject, name)
    local layer = LayerMask.NameToLayer(name)
    if not layer then
        print(string.format('层 ％s 没有找到!', name))
        return
    end
    gameObject.layer = layer
    local trans = gameObject.transform
    local childCount = trans.childCount
    for i = 1, childCount do
        local child = trans:GetChild(i - 1)
        if child then
            SetLayerRecursively(child.gameObject, name)
        end
    end
end

function BattleUnitController:OnSkillShowTargets()
    local canPlaySkillAnimation = CanPlaySkillCameraAnimation(self)
    if canPlaySkillAnimation then
        -- 隐藏技能背景
        self.luaGameObject:SetSkillBackgroundActive(false)

        -- -- 显示场景
        -- if self.skillSceneObject ~= nil then
        --     self.skillSceneObject:SetActive(true)
        -- end

        -- 显示目标
        local targetInfo = self:GetTargets()
        for i = 1, targetInfo:Count() do
            local target = targetInfo:GetTarget(i)
            if target ~= nil and target:IsAlive() then
                -- debug_print("@ 显示目标", target:GetGameObject().name)
                SetLayerRecursively(target:GetGameObject(), PLAYER_LAYER)
            end
        end
    end
end

function BattleUnitController:HideHpBar()
    if CanPlaySkillCameraAnimation(self) then
        self.luaGameObject:SetHpGroupActive(false)
        self.luaGameObject:GetStateManager():SetVisible(false)
    end
end

-- 激活指定摄像机
function BattleUnitController:OnActivePlayerCamera(id)
    local canPlaySkillAnimation = CanPlaySkillCameraAnimation(self)
    --如果是敌军 or 不播放技能动画  那就不处理
    if not canPlaySkillAnimation then
        return
    end

    self:ActivateSpecialCameraObjectByNumber(id)
end

local function PlaySkillAnimation(self)
    if self:PlayMainCameraPathAnimation() then
        -- 播放技能 UI Animator
        local currentSkill = GetCurrentActiveSkill(self)
        cos3dGame:DispatchEvent(MessageGuids.BattleActivateUISkillAnimation, nil, currentSkill:GetId(), true)

        -- 播放技能
        -- self.luaGameObject:SetSkillBackgroundActive(true)

        self.luaGameObject:SetHpGroupActive(false)
        self.luaGameObject:GetStateManager():SetVisible(false)

        -- 设置当前的层(只显示玩家自己, 隐藏场景 和 目标 和 己方其他人)
        local members = self.luaGameObject:GetMembers()
        local memberCount = table.maxn(members)
        for i = 1, memberCount do
            if members[i] ~= nil and members[i] ~= self.luaGameObject then
                SetLayerRecursively(members[i]:GetGameObject(), PLAYER_INVISIBLE_LAYER)
            end
        end

        -- 隐藏所有敌人
        local foes = self.luaGameObject:GetFoes()
        local foeCount = table.maxn(foes)
        for i = 1, foeCount do
            if foes[i] ~= nil then
                SetLayerRecursively(foes[i]:GetGameObject(), PLAYER_INVISIBLE_LAYER)
            end
        end
    end
end


local function StopSkillAnimation(self)
    if self:StopMainCameraPathAnimation() then

        -- # 隐藏技能UI动画 # --
        local currentSkill = GetCurrentActiveSkill(self)
        cos3dGame:DispatchEvent(MessageGuids.BattleActivateUISkillAnimation, nil, currentSkill:GetId(), false)

        self.luaGameObject:GetStateManager():SetVisible(true)

        -- 设置当前的层(只显示玩家自己, 隐藏场景 和 目标 和 己方其他人)
        local members = self.luaGameObject:GetMembers()
        local memberCount = table.maxn(members)
        for i = 1, memberCount do
            if members[i] ~= nil and members[i] ~= self.luaGameObject then
                SetLayerRecursively(members[i]:GetGameObject(), PLAYER_LAYER)
            end
        end

        -- 显示所有敌人 --
        local foes = self.luaGameObject:GetFoes()
        local foeCount = table.maxn(foes)
        for i = 1, foeCount do
            if foes[i] ~= nil then
                SetLayerRecursively(foes[i]:GetGameObject(), PLAYER_LAYER)
            end
        end
    end

    self.luaGameObject:SetHpGroupActive(true)
end

-- # 技能开始
function BattleUnitController:OnSkillStateEnter()
    local canPlaySkillAnimation = CanPlaySkillCameraAnimation(self)
    if canPlaySkillAnimation then
        PlaySkillAnimation(self)
    end
    cos3dGame:DispatchEvent(MessageGuids.BattleSkillBlackBoardBlack,nil,1,0.4)
end

-- # 技能退出
function BattleUnitController:OnSkillStateExit()
    debug_print("@OnSkillStateExit 1", self:GetGameObject().name)
    local canPlaySkillAnimation = CanStopSkillCameraAnimation(self)
    if canPlaySkillAnimation then
        StopSkillAnimation(self)
    end
    
    debug_print("@OnSkillStateExit 2", self:GetGameObject().name)
    cos3dGame:DispatchEvent(MessageGuids.BattleSkillBlackBoardWhite,nil,0.2,1)

    -- # 重置为默认摄像机
    GetBattlefield(self):ResetToDefaultCameraObject()

    debug_print("@OnSkillStateExit 3", self:GetGameObject().name)

    -- # 按照技能距离的判定 来决定是跳回还是其他! 
    if self.luaGameObject:GetActiveSkill():IsLongRange() then
        self:Skill2Breath()
    else
        self:Skill2JumpBack()
        self.motionCtrl:MoveToPosition(self.luaGameObject:GetDefaultPosition(), self)
    end

    debug_print("@OnSkillStateExit 4", self:GetGameObject().name)

    -- # 通知受击者我的技能播放结束 可以处理接下来的逻辑了!
    NotifySkillStateExit(self)
    
    debug_print("@OnSkillStateExit 5", self:GetGameObject().name)
end

-- # 三段技能 第二段跑动的事件
function BattleUnitController:OnSkill02StateEnter()
    -- print('****** OnSkill02StateEnter ******', self.luaGameObject:GetGameObject().name)
    self.luaGameObject:GetActiveSkill():MoveToTarget()
end

-- # 震屏
function BattleUnitController:OnShakeCamera(id)
    local shakeObject = self:GetCameraShakeObject()

    if shakeObject ~= nil then
        local cameraShakerComponent = shakeObject:GetComponent(typeof(EZCameraShake.CameraShaker))
        if cameraShakerComponent == nil then
            cameraShakerComponent = shakeObject:AddComponent(typeof(EZCameraShake.CameraShaker))
        end
        cameraShakerComponent:Shake(id, true)
    end
end


function BattleUnitController:OnUnderAttackStateExit()
    -- debug_print("@@@@ BattleUnitController:OnUnderAttackStateExit", self:GetGameObject().name)
	
	self.isUnderAttackExit = true
	
	OnHandleUnderAttackExit(self) 
end

function BattleUnitController:OnDieStateExit()
    --print("BattleUnitController:OnDieStateExit "..self.gameObject.name)
    unitEvent:UnRegisterEventHandler(self)
	--self:OnHandleResetLogic()
	local gameObject = self.luaGameObject:GetGameObject()
    if gameObject ~= nil then
        gameObject:SetActive(false)
    end
end

function BattleUnitController:OnStrikeBackStateExit()
    if self:IsFaint() then
        StrikeBack2Faint(self)
    else
        StrikeBack2Breath(self)
    end
end

