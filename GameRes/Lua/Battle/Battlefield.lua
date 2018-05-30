require "Battle.Battlefield_Camera"
require "Battle.BattlefieldController"
local unityUtils = require "Utils.Unity"
local utility = require "Utils.Utility"
require "GUI.AssistAttackUI"
require "Effects.SkillBackgroundEffects"
require "Enum"
require "System.LuaDelegate"
require "Const"
local resPathMgr = require "StaticData.ResPath"

local function SetupUIElements(self)
	-- ui manager
	local uiManager = require "Utils.Utility".GetUIManager()
	local battleCanvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()

	-- 获取开始战斗UI文字的Animator, 这样可以播放UI显示效果 (之后有资源管理了需要删除)
	self.uiElements = {}
	self.uiElements.battleStartAnimator = battleCanvasTransform:Find("BattleStart"):GetComponent(typeof(UnityEngine.Animator))

	-- 战斗胜利或失败 --
	self.uiElements.battleResultsAnimator = battleCanvasTransform:Find("BattleResults"):GetComponent(typeof(UnityEngine.Animator))

	-- 联动的UI --
	self.uiElements.assistAttackUI = AssistAttackUI.New()

	-- 技能背景 --
--	self.uiElements.skillBackgroundEffect = SkillBackgroundEffects.New()
end

local function SetupLeftTeam(self)
	local leftTeam = BattleTeam.New(Side.Left, unityUtils:GetTransformByObjectName("Pos/LFront"), unityUtils:GetTransformByObjectName("Pos/LCenter"))
	leftTeam:SetParent(self)
	self.leftTeam = leftTeam
end

local function SetupRightTeam(self)
	local rightTeam = BattleTeam.New(Side.Right, unityUtils:GetTransformByObjectName("Pos/RFront"), unityUtils:GetTransformByObjectName("Pos/RCenter"))
	rightTeam:SetData(self.parameter:GetRightTeam())
	rightTeam:SetParent(self)
	self.rightTeam = rightTeam
end

local function SetupComponents(self)
	local ctrl = BattlefieldController.New(self.leftTeam, self.rightTeam)
	self:AddComponent(ctrl)
	self.ctrl = ctrl
end

function Battlefield:Ctor(parameter, owner)
	self.owner = owner
	self.onBattleFinished = LuaDelegate.New()

	self.parameter = parameter
	self.numRound = 0	-- 当前回合
	self.numWave = 0    -- 当前波数

	self:SetupCameras()

	-- 初始化敌方队伍 --
	SetupLeftTeam(self)

	-- 初始化己方队伍 --
	SetupRightTeam(self)

	-- 初始化组件 --
	SetupComponents(self)

	-- 初始化UI --
	SetupUIElements(self)

	-- 读取设置 --
	self:LoadSettings()
end

function Battlefield:Pause()
	-- debug_print("@Pause, Battlefield:Pause >>")
	self.ctrl:Pause()
end

function Battlefield:Resume()
	debug_print("@Resume, Battlefield:Resume >>")
	self.ctrl:Resume()
end

function Battlefield:Clear()
	self.leftTeam:Clear()
	self.rightTeam:Clear()
end

-- 创建自己人 --
function Battlefield:SetupRight(callback)
	-- 加载人物 --
	self.rightTeam:Setup()
	callback()
end

local function OnNewWave(self)
	self.rightTeam:OnNewWave(self.numWave)
end

-- 新的波数
function Battlefield:NextWave(callback)
	-- 切换到下一波
	local wave = self.numWave + 1
	utility.ASSERT(wave <= self:GetNumberOfLeftTeam(), "调用错误, 现在已经下一波敌人了!")
	self.numWave = wave

	OnNewWave(self)

	-- >>> 设置敌方 <<< --
	-- 清除队伍数据和状态 --
	self.leftTeam:Clear()
	-- 构造队伍数据
	self.leftTeam:SetData(self.parameter:GetLeftTeam(self.numWave))

	-- 加载人物 --
	self.leftTeam:Setup()
	callback()
end

function Battlefield:HasNextFoeTeam()
	local wave = self.numWave + 1
	return wave <= self:GetNumberOfLeftTeam()
end

function Battlefield:GetWaveNumber()
	return self.numWave
end

function Battlefield:GetBattleParameter()
	return self.parameter
end

function Battlefield:GetNumberOfLeftTeam()
	return self.parameter:NumberOfLeftTeam()
end

function Battlefield:IsSkillRestricted()
	return self.owner:IsSkillRestricted()
end

function Battlefield:IsUnlimitedRage()
	return self.owner:IsUnlimitedRage()
end

function Battlefield:GetApRate(side)
	return self.owner:GetApRate(side)
end

function Battlefield:GetDamageRate(side)
	return self.owner:GetDamageRate(side)
end

function Battlefield:StartBattle()
	self.ctrl:StartBattle()
end

function Battlefield:SetCallbackOnBattleFinished(table, func)
	self.onBattleFinished:Set(table, func)
end

function Battlefield:ClearCallbackOnBattleFinished()
	self.onBattleFinished:Clear()
end

function Battlefield:ToString()
	return "Battlefield"
end

function Battlefield:GetBattleStarter()
	return self.parameter:GetStarter()
end

-- 回合数+1
function Battlefield:AddRoundNumber()
	self.numRound = self.numRound + 1
end

-- 获得回合数
function Battlefield:GetRoundNumber()
	return self.numRound
end

-- 返回输赢 --
function Battlefield:GetBattleResult()
	-- TODO : 处理战斗胜利条件

	if self.rightTeam:IsAllDead() then
		debug_print("己方全员死亡, 失败!")
        -- 失败
        return 0
    end
	
	if self.leftTeam:IsAllDead() then
		debug_print("敌方全员死亡, 胜利!")
        -- 成功
        return 1
    end

    return false
end

-- 战斗完成
function Battlefield:IsBattleFinished()
	return self.ctrl:IsBattleFinished()
end

function Battlefield:OnRoundContinued()
	self.ctrl:OnRoundContinued()
end

function Battlefield:GetLeftTeam()
	return self.leftTeam
end

function Battlefield:GetRightTeam()
	return self.rightTeam
end

-- 获取敌方队伍
function Battlefield:GetFoeTeam(team)
	if team:Equals(self.leftTeam) then
		return self.rightTeam
	end
		
	return self.leftTeam
end

function Battlefield:GetBattleStartAnimator()
	return self.uiElements.battleStartAnimator
end

function Battlefield:GetBattleResultsAnimator()
    return self.uiElements.battleResultsAnimator
end

function Battlefield:PlayAssistAttackAnimation(id, delay)
    self.uiElements.assistAttackUI:Play(id, delay)
end

function Battlefield:SetSkillBackgroundActive(unit, active)
--    self.uiElements.skillBackgroundEffect:SetActive(unit, active)
end

-- 通告上层 战斗完成
function Battlefield:DispatchBattleFinished(isWin)
	self.onBattleFinished:Invoke(isWin)
end


-- 获取 回放参数
function Battlefield:IsReplayMode()
	return self.owner:IsReplayMode()
end

function Battlefield:GetCameraBloomData()
	return self.owner:GetCameraBloomData()
end


-- first video

function Battlefield:PrepareFirstFightVideo(wave, pos, unit)
	return self.owner:PrepareFirstFightVideo(wave, pos, unit)
end

function Battlefield:IsFirstVideoFinished()
	return self.owner:IsFirstVideoFinished()
end


function Battlefield:GetSkillSelectionData(wave, round, pos)
	-- self.lastFightRecordMessage.fightingData.moData
	local moData = self.owner:GetManuallyOperationData()
	if moData ~= nil then
		for i = 1, #moData do
			local currentInputData = moData[i]
			if currentInputData ~= nil and currentInputData.wave == wave and currentInputData.round == round and currentInputData.pos == pos then
				return currentInputData
			end
		end
	end

	return nil
end

function Battlefield:GetMaxAvailableRounds()
	return self.owner:GetMaxAvailableRounds()
end

function Battlefield:GetBattleResultWhenReachMaxRounds()
	return self.owner:GetBattleResultWhenReachMaxRounds()
end

function Battlefield:GetCustomWinCondition()
	return self.owner:GetCustomWinCondition()
end

--------
local BattleModePrefs_Key = "9eea2b09-deaf-4920-8fc3-df9fbee5f0c1" .. utility.GetUserUID()
-- debug_print("@@@@@AAAAA@@@@@", BattleModePrefs_Key)

function Battlefield:IsFirstFight()
	return self.owner:IsFirstFight()
end

function Battlefield:LoadSettings()
	local mode = UnityEngine.PlayerPrefs.GetInt(BattleModePrefs_Key, kBattleMode_Manual)
	
	if self.owner:IsFirstFight() then
		mode = kBattleMode_Manual
	else
		-- 其他战斗如果禁用了手动, 默认的模式应该是自动 --
		if self.owner:HasManuallyOperationDisabled() then
			mode = kBattleMode_Auto
		end
	end
	self:SetBattleMode(mode, true)
end

function Battlefield:SaveSettings()
	UnityEngine.PlayerPrefs.Save()
end

-- 设置战斗模式
function Battlefield:SetBattleMode(mode, ignoreSet)
	if self.battleMode ~= mode then
		self.battleMode = mode

		if not ignoreSet then
			UnityEngine.PlayerPrefs.SetInt(BattleModePrefs_Key, mode)
		end
	end
end

function Battlefield:GetBattleMode()
	return self.battleMode
end

function Battlefield:CanSetDoubleSpeed(checkOnly)
	return utility.IsCanOpenModule(KSystemBasis_DoubleSpeed, checkOnly)
end

-- 恢复速度(退出的时候调用)
function Battlefield:RestoreSpeed()
	UnityEngine.Time.timeScale = 1
end

function Battlefield:GetBattleSpeed()
	return self.owner:GetCurrentSpeed()
end