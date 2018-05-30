require "Object.LuaObject"
require "Battle.Battlefield"
require "Battle.Parameters.BattleParameter"
require "Const"

local net = require "Network.Net"
local probability = require "Utils.Probability"
local BattleUtility = require "Utils.BattleUtility"
local LocalDataType = require "LocalData.LocalDataType"
local NodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

local BattleSpeedSettingsClass = require "Battle.BattleSpeedSettings"

local BattleNode = Class(NodeClass)


-- # 清除事件 # --
local function CancelBattlefieldEvents(self)
    local battleResultAnimator = self.battlefield:GetBattleResultsAnimator()
    battleResultAnimator:Play("BattleInit")

    local uiManager = require "Utils.Utility".GetUIManager()
    local battleCanvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()

    local transform = battleCanvasTransform:Find("HpGroup").transform
    local childCount = transform.childCount

    for i = 0, childCount - 1 do
        local t = transform:GetChild(i)
        UnityEngine.Object.Destroy(t.gameObject)
    end

    _G.ClearCameraPathEventHandler()
    _G.ClearBattleUnitEventHandler()
    _G.ClearBattleUnitCollisionEventHandler()

    self.battleOrderStateMachine:Close()

    if self.battleRecorder ~= nil then
        self.battleRecorder:Close()
    end

    if self.bossRecorder ~= nil then
        self.bossRecorder:Close()
    end

    -- 恢复速度 & 保存设置 --
    self.battlefield:SaveSettings()
    self.battlefield:RestoreSpeed()
end

function BattleNode:CancelBattlefieldEvents()
    CancelBattlefieldEvents(self)
end

-- # 发送战斗记录 # --
local function StopBattleStartTimeout(self)
    if self.coBattleStartTimeout ~= nil then
        self:StopCoroutine(self.coBattleStartTimeout)
        self.coBattleStartTimeout = nil
    end
end

local OnSendFightResponseTimeout
local SendBattleStartProtocol

OnSendFightResponseTimeout = function(self)
    coroutine.wait(30)
    SendBattleStartProtocol(self)
end

SendBattleStartProtocol = function(self)
    -- debug_print("send battle start!!")
    utility.GetGame():SendNetworkMessage(self:GetBattleParams():GetBattleStartProtocol())
    StopBattleStartTimeout(self)
    self.isSendingBattleStartProtocol = true
    self.coBattleStartTimeout = self:StartCoroutine(OnSendFightResponseTimeout)
end

local function OnGameReconnected(self)
    if self.isSendingBattleStartProtocol == true then
        SendBattleStartProtocol(self)
    end
end

function BattleNode:SendBattleRecord(isWin)
    local battleParams = self:GetBattleParams()
    local msg, prototype = battleParams:GetBattleStartProtocol()

    local fightRecord = msg.fightRecord

    if fightRecord ~= nil then

        -- TODO 胜利条件处理
        -- local conditionId = battleParams:GetBattleCustomConditionId()
        -- local customConditionRoutine = nil
        -- if type(customConditionRoutine) == "function" then
        --     isWin = customConditionRoutine(isWin, self.battlefield)
        -- end

        fightRecord.isWin = isWin
        fightRecord.isPVP = false

        -- 设置 --
        local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
        local UserDataType = require "Framework.UserDataType"
        local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)
        fightRecord.sourcePlayerUID = playerData:GetUid()

        self.battleRecorder:CopyToProtobuf(fightRecord)
        self.lastFightRecordMessage = fightRecord
    end

    if msg.hit ~= nil then
        -- TODO 世界BOSS特殊处理!
        msg.hit = self.bossRecorder:GetTotalLosedHp()    
    end

    -- debug_print("@BossRecorder", "Boss总伤血量", self.bossRecorder:GetTotalLosedHp())
    
    SendBattleStartProtocol(self)

    self.communicationPanel:Show()
    
    -- debug_print("发送协议!")
end

function BattleNode:FightResponse()
    if self.isSendingBattleStartProtocol == true then
        -- debug_print("Fight Response!!")
        StopBattleStartTimeout(self)
        self.isSendingBattleStartProtocol = nil
        self.communicationPanel:Hide()
    end
end

-- ## 是否为第一场战斗 ##
function BattleNode:IsFirstFight()
	return self.firstFightConfig ~= nil
end


---------------
-- ### 第一场战斗图片 & 通用底图隐藏 ### ---


-- @ 第一场战斗 600话的图片 @ --
function BattleNode:ShowFirstFightStartImage(duration)
    self.firstStartImage:CrossFadeAlpha(0, 0, true)
	self.firstStartImage:CrossFadeAlpha(1, duration, true)
end

function BattleNode:HideFirstFightStartImage(duration)
	self.firstStartImage:CrossFadeAlpha(0, duration, true)
end

-- 渐隐 通用底图 --
function BattleNode:HideFightBaseImage(duration)
    self.baseImage:CrossFadeAlpha(1, 1, true)
    self.baseImage:CrossFadeAlpha(0, duration, true)
end

function BattleNode:ShowFightBaseImage(duration)
    self.baseImage:CrossFadeAlpha(0, 0, true)
    self.baseImage:CrossFadeAlpha(1, duration, true)
end

----------------

-- @ 各种切换Group的私有函数 @ --

-- @ 模式1. 隐藏所有UI
local function InactiveAllGroups(self)
    self.group1Object:SetActive(false)
    self.group2Object:SetActive(false)
end

-- @ 模式2. 激活UI组1
local function ActivateGroup1(self)
    self.group1Object:SetActive(true)
    self.group2Object:SetActive(false)
    self.skillVideoImageObject:SetActive(false)
    self.firstStartImageObject:SetActive(false)
    self.baseImageObject:SetActive(false)
end

-- @ 模式3. 激活UI组2 (不改变子)
local function ActivateGroup2(self)
    self.group1Object:SetActive(false)
    self.group2Object:SetActive(true)
end

-- @ 模式4. 激活UI组里的VideoImage
local function ActivateVideoInGroup2(self, active)
    ActivateGroup2(self)

    if active == nil then
        active = true
    end

    self.skillVideoImageObject:SetActive(active)
    self.firstStartImageObject:SetActive(false)
    self.baseImageObject:SetActive(false)
end

-- @ 模式5. 激活UI组里的600话的图片 --
local function ActivateFirstStartImageInGroup2(self, active)
    ActivateGroup2(self)

    if active == nil then
        active = true
    end

    self.skillVideoImageObject:SetActive(false)
    self.firstStartImageObject:SetActive(true)
    self.baseImageObject:SetActive(false)
end

-- @ 模式6. 激活UI组里的通用背景 --
local function ActivateCommonBaseImageInGroup2(self, active)
    ActivateGroup2(self)

    if active == nil then
        active = true
    end

    self.skillVideoImageObject:SetActive(false)
    self.firstStartImageObject:SetActive(false)
    self.baseImageObject:SetActive(active)
end


----------------

function BattleNode:GetCameraBloomData()
    local sceneID = self.BattleParams:GetSceneID()
	local sceneData = require "StaticData.Scene":GetData(sceneID)
	local bloomId = sceneData:GetCameraBloom()
	
	print("sceneID: ",sceneID,"bloomId: ", bloomId)
    if bloomId > 0 then
        local BloomMgr = Data.Bloom.Manager.Instance()
        return BloomMgr:GetObject(bloomId)
    end
    return nil
end

function BattleNode:IsReplayMode()
    return self.isReplayMode
end

function BattleNode:IsPVPMode()
    return self:GetBattleParams():IsPVPMode()
end

function BattleNode:IsSkillRestricted()
    return self:GetBattleParams():IsSkillRestricted()
end

function BattleNode:IsUnlimitedRage()
    return self:GetBattleParams():GetUnlimitedRage()
end

function BattleNode:GetApRate(side)
    return self:GetBattleParams():GetApRate(side)
end

function BattleNode:GetDamageRate(side)
    return self:GetBattleParams():GetDamageRate(side)
end

function BattleNode:HasManuallyOperationDisabled()
    return self:GetBattleParams():HasManuallyOperationDisabled()
end

function BattleNode:GetManuallyOperationData()
    if self:IsReplayMode() then
        local lastFightRecordMessage = self:GetLastBattleRecordMessage()
        if lastFightRecordMessage ~= nil then
            return lastFightRecordMessage.fightingData.moData
        end
    end
    return nil
end

function BattleNode:GetMaxAvailableRounds()
    local battleParams = self:GetBattleParams()
    return battleParams:GetMaxBattleRounds()
end

function BattleNode:GetBattleResultWhenReachMaxRounds()
    local battleParams = self:GetBattleParams()
    return battleParams:GetBattleResultWhenReachMaxRounds()
end

function BattleNode:GetCustomWinCondition()
    return self:GetBattleParams():GetWinCondition()
end


function BattleNode:GetLastBattleRecordMessage()
    return self.lastFightRecordMessage
end

function BattleNode:GetBattleParams()
    return self.BattleParams
end

function BattleNode:GetFirstFightConfig()
    return self.firstFightConfig
end


-- >>> 视频控制 <<< --
local function OnHandleFirstVideoTimeout(self)
	coroutine.wait(23)
    self:GetVideoPlayerManager():Stop()
    self:GetVideoPlayerManager():ClearShowTarget()

	self.skillVideoImage.enabled = false
	self.isFirstVideoPlaying = nil
	self.coFirstVideoTimeout = nil
	self:ResumeBackgroundMusic()
end

local function OnDelayPlayVideo(self, videoPath, targetPosition)

    coroutine.wait(0.5)

    -- 推镜头的时候 走模糊效果 --
    local realTargetPosition = targetPosition
    realTargetPosition.y = realTargetPosition.y + 1

    self:DispatchEvent(messageGuids.BattleStartCameraZoomUp, nil, realTargetPosition, false)
    self.skillVideoCamera = self.battlefield:EnableRadiarBlur()

    coroutine.wait(0.6)

    self:PauseBackgroundMusic()
    self.battlefield:SetActiveCurrentCameraObject(false)
    self:GetUIManager():GetBattleUICanvas():HideRoot()
    ActivateVideoInGroup2(self)
    self.skillVideoImage.color = UnityEngine.Color(0, 0, 0, 1)
    
    coroutine.wait(0.1)

    self:GetVideoPlayerManager():SetShowTarget(self.skillVideoImage)
    self:GetVideoPlayerManager():Play(videoPath)
end

-- 准备播放视频！
function BattleNode:PrepareFirstFightVideo(wave, pos, battleUnit)
    if self.firstFightConfig == nil then
        return false
    end
	
	utility.ASSERT(self.isFirstVideoPlaying ~= true, "状态冲突!")

    local firstSkillWaves = self.firstFightConfig:GetAbleSkillWave()
	
    for i = 1, #firstSkillWaves do
	
        if firstSkillWaves[i] == wave then
		
            local firstFightSkillData = require "StaticData.FirstFight.FirstFightSkill":GetData(wave)
			
            if firstFightSkillData:IsValid() then
			
                if firstFightSkillData:GetSkillWave() == wave and firstFightSkillData:GetSkillPosition() == pos then

                    -- 正在播放 --
                    self.isFirstVideoPlaying = true

                    -- 启动协程 --
                    local targetPosition = battleUnit:GetGameObject().transform.position
                    local videoPath = string.format("%s.mp4", firstFightSkillData:GetVideoPath())
                    self:StartCoroutine(OnDelayPlayVideo, videoPath, targetPosition)
                    
					return true
                end
            end

            break
        end
    end
	return false
end

-- 视频是否完成!
local function IsVideoFinished(self)
	return self.isFirstVideoPlaying ~= true
end

function BattleNode:IsFirstVideoFinished()
	return IsVideoFinished(self)
end

local function WaitingForWhiteScreenImage(self)

    -- 显示白屏 隐藏视频 --
    self.skillWhiteImageObject:SetActive(true)
    self.skillVideoImageObject:SetActive(false)

    coroutine.step(1)

    self.battlefield:SetActiveCurrentCameraObject(true)

    -- 花费n秒淡出 --
    self.skillWhiteImage:CrossFadeAlpha(1, 0, true)
    self.skillWhiteImage:CrossFadeAlpha(0, 1.5, true)

    coroutine.wait(0.2)

    -- -- 隐藏白屏 --
    -- self.skillWhiteImageObject:SetActive(false)
    -- self.skillWhiteImage:CrossFadeAlpha(1, 0, true)

    -- 震屏
    local shakeObject = self.battlefield:GetRootCameraParent()
    if shakeObject ~= nil then
        local cameraShakerComponent = shakeObject:GetComponent(typeof(EZCameraShake.CameraShaker))
        if cameraShakerComponent == nil then
            cameraShakerComponent = shakeObject:AddComponent(typeof(EZCameraShake.CameraShaker))
        end
        cameraShakerComponent:Shake(4, true)
    end

    -- 显示普通时候的UI --
    ActivateGroup1(self)
    self:GetUIManager():GetBattleUICanvas():ShowRoot()
    
    -- 白屏结束后, 才显示 --
    self.isFirstVideoPlaying = nil

    coroutine.wait(0.5)
    self:ResumeBackgroundMusic()

    -- 隐藏白屏 --
    self.skillWhiteImageObject:SetActive(false)
    self.skillWhiteImage:CrossFadeAlpha(1, 0, true)
end

local function OnHandleVideoEnd(self)
    if self.isFirstVideoPlaying == true then
        self:GetVideoPlayerManager():ClearShowTarget()
        -- 等待白屏 --
        self:StartCoroutine(WaitingForWhiteScreenImage)
    end
end

-- 视频播放器 事件 --
local function OnVideoEndReached(self, _)
    print("@@@ OnVideoEndReached @@@")
    OnHandleVideoEnd(self)
end

local function OnVideoPrepared(self, _)
    -- @ 视频准备好后 显示出来 @ --
    self.skillVideoImage.color = UnityEngine.Color(1, 1, 1, 1)
    self:DispatchEvent(messageGuids.BattleEndCameraZoomUp, nil)

    self.battlefield:DisableRadiarBlur(self.skillVideoCamera)
    self.skillVideoCamera = nil
end

local function OnVideoError(self, _)
    print("@@@ OnVideoError @@@")
    OnHandleVideoEnd(self)
end

local function PlayBackgroundMusic(self)
	local sceneID = self.BattleParams:GetSceneID()
	if sceneID > 0 then
		local sceneData = require "StaticData.Scene":GetData(sceneID)
		local bgmId = sceneData:GetBgm()
		if bgmId > 0 then
            local audioManager = self:GetGame():GetAudioManager()
            audioManager:FadeInBGM(bgmId)
		end
	end
end

function BattleNode:StopBackgroundMusic()
    self:GetGame():GetAudioManager():FadeOutBGM()
end

function BattleNode:SetBackgroundVolume(volume)
	local audioManager = self:GetGame():GetAudioManager()
    audioManager:SetBGMVolume(volume)
end

-- pause background
function BattleNode:PauseBackgroundMusic()
	local audioManager = self:GetGame():GetAudioManager()
	audioManager:PauseBGM()
end

-- play background
function BattleNode:ResumeBackgroundMusic()
	local audioManager = self:GetGame():GetAudioManager()
	audioManager:ResumeBGM()
end



-- # 速度相关函数
local function CanSetDoubleSpeed(checkOnly)
	return utility.IsCanOpenModule(KSystemBasis_DoubleSpeed, checkOnly)
end

local function OnSpeedOne(self)
    debug_print("speed 1")
    self.speedImage.text = "x1"
    return true
end

local function OnSpeedTwoOrThree(self, _, speed, force)
    -- debug_print("speed ", speed, force)
    if force or CanSetDoubleSpeed() then
        self.speedImage.text = string.format("x%d", speed)
        return true
    end
    return false
end

local function InitSpeedSettings(self)
    self.speedSettings = BattleSpeedSettingsClass.New(self)
    self.speedSettings:Add(1, 1, OnSpeedOne)
    self.speedSettings:Add(2, 1.5, OnSpeedTwoOrThree)
    self.speedSettings:Add(3, 2, OnSpeedTwoOrThree)

    -- debug_print("@@@@ speedSettings", self.speedSettings)
end

local function SwitchNextSpeedLevel(self)
    self.speedSettings:SwitchNextLevel()
end

local function LoadSpeedSettings(self)
    self.speedSettings:Load()
end

function BattleNode:GetCurrentSpeed()
    return self.speedSettings:GetCurrentRealSpeed()
end

-- # 剧情相关函数
local function IsLevelAlreadyPassed(levelId)
    return require "Utils.ChapterLevelUtils".GetUserLevelStarFromLevelId(levelId) > 0
end

local function IsScriptLevelAlreadyPassed(self)
    return IsLevelAlreadyPassed(require "Utils.ScriptUtility".GetMapId(self:GetBattleParams():GetScriptID()))
end

local function HasValidScript(self)
    return self:GetBattleParams():HasScript() and not IsScriptLevelAlreadyPassed(self)
end

local function InitScriptState(self)
    self._isScriptEnabled = HasValidScript(self)
end

function BattleNode:IsScriptEnabled()
    return self._isScriptEnabled
end


-- # 构造函数
function BattleNode:Ctor(battleParams, leftTeams, rightTeam, firstFightConfig, battleScene)

    self.battleSceneNode = battleScene

    self.firstFightConfig = firstFightConfig

    --- > 首先缓存起来!! < ---
    self.BattleParams = battleParams

    --- #### 初始化随机数种子 #### ---
    self.battleRandomSeed = os.time()

    if battleParams:IsReplayMode() then
        self.lastFightRecordMessage = battleParams:GetReplayDataMessage()
        self.battleResponseMsg = battleParams:GetReplayDataResultResponseMsg()
        self.isReplayMode = true
        self.battleRandomSeed = self.lastFightRecordMessage.fightingData.seed
    end

    --- #### 第一场战斗种子 #### ---
    if self.firstFightConfig then
		self.battleRandomSeed = self.firstFightConfig:GetSeed()
    end
	
	-- # 自定义种子值 # --
    -- self.battleRandomSeed = 1511972950
    
    debug_print("战斗种子初始值: ", self.battleRandomSeed)

	self.lastRandomSeed = probability:GetSeed()
	probability:SetSeed(self.battleRandomSeed)
	
    --- #### 配置己方队伍数据 #### ---
    local rightTeamParameter = rightTeam

    -- 检查己方阵型是否为空 --
    utility.ASSERT(rightTeamParameter ~= nil and rightTeamParameter:Count() > 0, "己方阵型为空!")

    -- 检查敌方数据 --
    utility.ASSERT(#leftTeams > 0 and leftTeams[1]:Count() > 0, "敌人阵型为空!")


    ---> 配置战斗 <---
    local bp = BattleParameter.New()
    bp:SetLeftTeams(leftTeams)
    bp:SetRightTeam(rightTeamParameter)
    bp:SetStarter(Side.Right)

    ---> 创建战场 <---
    self.battlefield = Battlefield.New(bp, self)

    if not self:IsReplayMode() then
        print("战斗记录器初始化!")
        local msg = battleParams:GetBattleStartProtocol()
        if msg ~= nil and msg.fightRecord ~= nil then
            -- debug_print("@支持回放!")
            -- 战斗记录器
            local BattleRecorderClass = require "Battle.Records.BattleRecorder"
            self.battleRecorder = BattleRecorderClass.New(self)
            self.battleRecorder:Start()
        end
    end

    --->> 创建BOSS伤害记录器! <<---
    self.bossRecorder = require "Battle.Records.BossRecorder".New(self, kLocation_Boss)
    self.bossRecorder:Start()

    --->> 创建战斗流状态机 <<---
    local BattleFlowStateMachineClass = require "Battle.BattleFlow.BattleFlowStateMachine"
    local Pool = require "Framework.Pool.CommonStatePool".New()
    self.BattleFlowDataContext = {}
    self.BattleFlowDataContext.BattleFlowStatePool = Pool

    --->> 战斗结算 重赋值 <<---
    if self.battleResponseMsg ~= nil then
        self.BattleFlowDataContext.battleResultMsg = self.battleResponseMsg
    end

    self.battleFlowStateMachine = BattleFlowStateMachineClass.New(
        self,
        Pool:Get(require "Battle.BattleFlow.InitDataState"),
        self.BattleFlowDataContext
    )

    -- 初始化速度
    InitSpeedSettings(self)

    -- 初始化剧情状态
    InitScriptState(self)

    -- 注册 Update
    self:ScheduleUpdate(self.Update)
end

function BattleNode:GetRandomSeed()
    return self.battleRandomSeed
end

function BattleNode:GetBattlefield()
    return self.battlefield
end

function BattleNode:OnInit()
    utility.LoadNewGameObjectAsync(
        "UI/Prefabs/Fighting",
        function(go)
            self:BindComponent(go)
        end
    )
end

function BattleNode:GetBattleUnitPreloadSet()
    return self.battleSceneNode:GetBattleUnitPreloadSet()
end

function BattleNode:OnExit()
    BattleNode.base.OnExit(self)
    -- debug_print("@@@@ OnExit @@@@")
    self.battlefield:Clear()
    self:CancelBattlefieldEvents()
end

function BattleNode:OnComponentReady()
    self:InitControls()
end


function BattleNode:InitControls()
    local transform = self:GetUnityTransform()

    -- 战斗中三个组件的GameObject
    self.systemButtonListObject = transform:Find("Group1/BottomCanvas/SystemButtonList").gameObject
    self.InformationObject = transform:Find("Group1/BottomCanvas/Information").gameObject
    self.ProgressObject = transform:Find("Group1/BottomCanvas/Progress").gameObject

    -- 获取 hpGroup
    local uiManager = require "Utils.Utility".GetUIManager()
    local battleCanvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()
    self.uiHpGroupObject = battleCanvasTransform:Find("HpGroup").gameObject
    -- debug_print("@@@ HP UI Group @@@", self.uiHpGroupObject.name)


    self.speedButton = transform:Find("Group1/BottomCanvas/SystemButtonList/FightingSpeedButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.fightingModeButton = transform:Find("Group1/BottomCanvas/SystemButtonList/FightingModeSwitchButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 切换速度的图片
    self.speedImage = transform:Find("Group1/BottomCanvas/SystemButtonList/FightingSpeedButton/TextImage"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 切换战斗模式的图片
    self.fightingModeImage = transform:Find("Group1/BottomCanvas/SystemButtonList/FightingModeSwitchButton/TextImage"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 目标面板
    local SkillTargetTrans = transform:Find("Group1/TopCanvas/FightingNotice")
    local FightingSkillSelectionPanelClass = require "GUI.Battle.FightingSkillSelectionPanel"
    self.skillSelectionPanel = FightingSkillSelectionPanelClass.New(SkillTargetTrans, self)

    -- 正在通信控件
    self.communicationPanel = require "Battle.BattleUICommunication".New(transform:Find("Group1/TopCanvas/CommunicationGroup"))


    -- 获取n个头像 --
    self.ProgressLayoutTrans = transform:Find("Group1/BottomCanvas/Progress/ProgressLayout")
    self.ProgressControlPoints = transform:Find("Group1/BottomCanvas/Progress/ControlPoints")

    -- 文本
    self.FightingRoundLabel = transform:Find("Group1/BottomCanvas/Information/FightingRoundLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self:OnBattleRoundChanged(1)

    -- 跳过按钮 --
    self.skipButton = transform:Find("Group1/BottomCanvas/SkipButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.skipButtonObject = self.skipButton.gameObject
    self.skipButtonObject:SetActive(false)

	-- 技能特效 --
    self.particleSkillEffectObject = transform:Find("Group1/BaseCanvas/UI_zhandoubisha_touxiang").gameObject 
    

    -- 获取Group1 (正常战斗的UI组)
    self.group1Object = transform:Find("Group1").gameObject

    -- 获取Group2 (第一场战斗 600 话!)
    self.group2Object = transform:Find("Group2").gameObject

    ---- >>>> 获取第一场战斗的相关组件 ----
    self.skillVideoImage = transform:Find("Group2/VideoImage"):GetComponent(typeof(UnityEngine.UI.RawImage))
    self.skillVideoImageObject = self.skillVideoImage.gameObject

    self.skillWhiteImage = transform:Find("Group2/WhiteImage"):GetComponent(typeof(UnityEngine.UI.RawImage))
    self.skillWhiteImageObject = self.skillWhiteImage.gameObject

    self.firstStartImage = transform:Find("Group2/StartImage"):GetComponent(typeof(UnityEngine.UI.Image))
    self.firstStartImageObject = self.firstStartImage.gameObject


    -- 通用底框 --
    self.baseImage = transform:Find("Group2/BaseImage"):GetComponent(typeof(UnityEngine.UI.Image))
    self.baseImageObject = self.baseImage.gameObject

    -- 激活底图 --
    ActivateCommonBaseImageInGroup2(self)
    
    
	
    -- ##### 战斗顺序显示状态机 相关创建 ##### --
    local StateMachineClass = require "Battle.BattleOrder.BattleOrderStateMachine"

    local BattleOrderStatePoolClass = require "Battle.BattleOrder.BattleOrderStatePool"

    local pool = BattleOrderStatePoolClass.New()

    self.BattleOrderDataContext = {} -- 初始化 Data
    self.BattleOrderDataContext.BattleOrderStatePool = pool
    self.BattleOrderDataContext.ProgressLayoutTrans = self.ProgressLayoutTrans
    self.BattleOrderDataContext.ProgressControlPoints = self.ProgressControlPoints

    -- 初始状态
    local InitState = pool:Get(require "Battle.BattleOrder.InitState") -- 初始状态
    self.battleOrderStateMachine = StateMachineClass.New(self, InitState, self.BattleOrderDataContext)

    -- 创建下方行动栏
    local BattleActionInfoBarClass = require "Battle.ActionBar.BattleActionInfoBar"
    self:AddChild(BattleActionInfoBarClass.New(transform:Find("Group1/BottomCanvas/Attack")))

    -- 创建立绘效果
    local BattleSkillEffectNodeClass = require "Battle.BattleSkillEffectNode"
    self:AddChild(BattleSkillEffectNodeClass.New(transform:Find("Group1/MiddleCanvas/FightingEffect")))

    -- 创建气泡
    local BattleSkillBubbleNodeClass = require "Battle.BattleSkillBubbleNode"
    self:AddChild(BattleSkillBubbleNodeClass.New(transform:Find("Group1/BottomCanvas/SkillBubble")))

    -- 创建UI技能动画 --
    local BattleUISkillAnimationNodeClass = require "Battle.BattleUISkillAnimationEffectNode"
    self:AddChild(BattleUISkillAnimationNodeClass.New(self))

    -- 大招黑背板
    local BattleSkillBlackBoardNodeClass = require "Battle.BattleSkillBlackBoardNode"
    self:AddChild(BattleSkillBlackBoardNodeClass.New(self))
    print(transform.name,"==================")
   
    -- 联动效果 --
    local assistAttackSpeedLineImage = transform:Find("Group1/BottomCanvas/AssistSpeedLine"):GetComponent(typeof(UnityEngine.UI.Image))
    local BattleAssistCameraEffectNodeClass = require "Battle.BattleAssistCameraEffectNode"
    self:AddChild(BattleAssistCameraEffectNodeClass.New(self, assistAttackSpeedLineImage))

end

function BattleNode:OnResume()
    BattleNode.base.OnResume(self)

    require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_BattleView)

    self:SetControls()

    self:RegisterControlEvents()
    self:RegisterMessages()
	
	-- 播放背景音乐 --
	PlayBackgroundMusic(self)
end

function BattleNode:OnPause()
    BattleNode.base.OnPause(self)
    self:UnregisterControlEvents()
    self:UnregisterMessages()


    probability:SetSeed(self.lastRandomSeed)
    self.battleFlowStateMachine:Close()
    self.lastFightRecordMessage = nil
	
	
    self:GetVideoPlayerManager():Stop()
    self:GetVideoPlayerManager():ClearShowTarget()
end

function BattleNode:SetControls()
    self:RefreshBattleSpeedGraphic()
    self:RefreshBattleModeGraphic()

    -- print("SetControls ...... >>>> ")
    local battleParams = self:GetBattleParams()
    if battleParams:HasManuallyOperationDisabled() then
        -- print("Disabled! >>>")
        self.fightingModeButton.interactable = false
        self.fightingModeButton.targetGraphic.material = utility.GetGrayMaterial()
        self.fightingModeImage.material = utility.GetGrayMaterial("Text")
    else
        -- print("Enabled! >>>")
        self.fightingModeButton.interactable = true
        self.fightingModeButton.targetGraphic.material = utility.GetCommonMaterial()
        self.fightingModeImage.material = utility.GetCommonMaterial("Text")
    end
end


function BattleNode:RegisterControlEvents()
    -- speed button
    self.__event_button_speedButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChangeSpeedButtonClicked, self)
    self.speedButton.onClick:AddListener(self.__event_button_speedButtonClicked__)

    -- fighting button
    self.__event_button_fightingModeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChangeFightingModeButtonClicked, self)
    self.fightingModeButton.onClick:AddListener(self.__event_button_fightingModeButtonClicked__)

    -- skip button
    self.__event_button_skipButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSkipReplayButtonClicked, self)
    self.skipButton.onClick:AddListener(self.__event_button_skipButtonClicked__)
end

function BattleNode:UnregisterControlEvents()
    if self.__event_button_speedButtonClicked__ then
        self.speedButton.onClick:RemoveListener(self.__event_button_speedButtonClicked__)
        self.__event_button_speedButtonClicked__ = nil
    end

    if self.__event_button_fightingModeButtonClicked__ then
        self.fightingModeButton.onClick:RemoveListener(self.__event_button_fightingModeButtonClicked__)
        self.__event_button_fightingModeButtonClicked__ = nil
    end

    if self.__event_button_skipButtonClicked__ then
        self.skipButton.onClick:RemoveListener(self.__event_button_skipButtonClicked__)
        self.__event_button_skipButtonClicked__ = nil
    end
end

local function OnBattleActivateHpGroupObject(self, active)
    self.uiHpGroupObject:SetActive(active)
end

local function OnBattleActivateSystemButtonList(self, active)
    self.systemButtonListObject:SetActive(active)
end

local function OnActivateTopInformation(self, active)
    self.InformationObject:SetActive(active)
end

local function OnActivateRightProgress(self, active)
    self.ProgressObject:SetActive(active)
end

local function OnBattleUnitDead(self, battleUnit)
end

local function OnBattleUnitShakeCamera(_, gameObject, id)
    _G.BattleUnitShakeCamera(gameObject, id)
end

local function OnActiveReplayButton(self, active)
    self.skipButtonObject:SetActive(active)
end

local function OnPlaySkillHeadEffect(self)
	utility.PlayParticleSystem(self.particleSkillEffectObject, true, true)
end

function BattleNode:OnPlayerLevelUpResult(msg)
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.LevelUpPanel",msg)
end

function BattleNode:RegisterMessages()
    -- Session事件
    self:RegisterEvent(messageGuids.LoadAllUserDataFinished, OnGameReconnected)

    -- 战斗事件接收
    self:RegisterEvent(messageGuids.BattleUnitDead, OnBattleUnitDead)
    self:RegisterEvent(messageGuids.BattleRoundChanged, self.OnBattleRoundChanged)
    self:RegisterEvent(messageGuids.BattleSkillTargetSelection, self.OnBattleSkillTargetSelection)
    self:RegisterEvent(messageGuids.ShakeCameraEvent, OnBattleUnitShakeCamera)

    -- 战斗UI控制 --
    self:RegisterEvent(messageGuids.BattleActivateHpGroupObject, OnBattleActivateHpGroupObject)
 
    -- @ old @ --
    self:RegisterEvent(messageGuids.BattleActivateSystemButtonList, OnBattleActivateSystemButtonList)
    self:RegisterEvent(messageGuids.BattleActivateTopInformation, OnActivateTopInformation)
    self:RegisterEvent(messageGuids.BattleActivateRightProgress, OnActivateRightProgress)

    -- @@ new @@ --
    self:RegisterEvent(messageGuids.BattleInactivateAllGroups, InactiveAllGroups)
    self:RegisterEvent(messageGuids.BattleActiveGroup1, ActivateGroup1)
    self:RegisterEvent(messageGuids.BattleActivateVideoInGroup2, ActivateVideoInGroup2)
    self:RegisterEvent(messageGuids.BattleActivateFirstStartImageInGroup2, ActivateFirstStartImageInGroup2)
    self:RegisterEvent(messageGuids.BattleActivateCommonBaseImageInGroup2, ActivateCommonBaseImageInGroup2)

    utility.GetGame():RegisterMsgHandler(net.S2CPlayerLevelUpResult,self,self.OnPlayerLevelUpResult)

    self:RegisterEvent(messageGuids.BattleActiveReplayButton, OnActiveReplayButton)
	self:RegisterEvent(messageGuids.BattlePlaySkillHeadEffect, OnPlaySkillHeadEffect)


    ---- >>> video player 
    self:RegisterEvent(messageGuids.VideoEndReached, OnVideoEndReached, nil)
    self:RegisterEvent(messageGuids.VideoPrepared, OnVideoPrepared, nil)
    self:RegisterEvent(messageGuids.VideoError, OnVideoError, nil)
end

function BattleNode:UnregisterMessages()
    -- Session事件
    self:UnregisterEvent(messageGuids.LoadAllUserDataFinished, OnGameReconnected)

    -- 战斗事件接收
    self:UnregisterEvent(messageGuids.BattleUnitDead, OnBattleUnitDead)
    self:UnregisterEvent(messageGuids.BattleRoundChanged, self.OnBattleRoundChanged)
    self:UnregisterEvent(messageGuids.BattleSkillTargetSelection, self.OnBattleSkillTargetSelection)
    self:UnregisterEvent(messageGuids.ShakeCameraEvent, OnBattleUnitShakeCamera)

    self:UnregisterEvent(messageGuids.BattleActivateHpGroupObject, OnBattleActivateHpGroupObject)
    self:UnregisterEvent(messageGuids.BattleActivateSystemButtonList, OnBattleActivateSystemButtonList)
    self:UnregisterEvent(messageGuids.BattleActivateTopInformation, OnActivateTopInformation)
    self:UnregisterEvent(messageGuids.BattleActivateRightProgress, OnActivateRightProgress)

    self:UnregisterEvent(messageGuids.BattleActiveReplayButton, OnActiveReplayButton)
	
	self:UnregisterEvent(messageGuids.BattlePlaySkillHeadEffect, OnPlaySkillHeadEffect)

    utility.GetGame():UnRegisterMsgHandler(net.S2CPlayerLevelUpResult,self,self.OnPlayerLevelUpResult)

    -- >>> video player 
    self:UnregisterEvent(messageGuids.VideoEndReached, OnVideoEndReached, nil)
    self:UnregisterEvent(messageGuids.VideoPrepared, OnVideoPrepared, nil)
    self:UnregisterEvent(messageGuids.VideoError, OnVideoError, nil)
end


-----------------------------------------------------------------------
--- 战斗消息处理
-----------------------------------------------------------------------
-- # 回合数变更处理
function BattleNode:OnBattleRoundChanged(roundNum)
    self.FightingRoundLabel.text = string.format("%d/%d", roundNum, self:GetMaxAvailableRounds())
end

-------

-- # 处理用户选择技能
function BattleNode:OnBattleSkillTargetSelection(activeSkill, isAll, targetSide, callback)
--    print("弹出选择技能的面板")
    self.skillSelectionPanel:Show(activeSkill, isAll, targetSide, callback)
end


-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BattleNode:OnChangeSpeedButtonClicked()
    SwitchNextSpeedLevel(self)
end

function BattleNode:OnChangeFightingModeButtonClicked()
	if self:IsFirstFight() then
		return
	end

    local mode = self.battlefield:GetBattleMode()

    if mode == kBattleMode_Auto then
        self.battlefield:SetBattleMode(kBattleMode_Manual)
        self.fightingModeImage.text = "手动"
    else
        self.battlefield:SetBattleMode(kBattleMode_Auto)
        self.fightingModeImage.text = "自动"
    end
end

function BattleNode:OnSkipReplayButtonClicked()
    local windowManager = self:GetWindowManager()
    local BattlePauseModuleClass = require "GUI.Modules.Battle.BattlePauseModule"
    windowManager:Show(BattlePauseModuleClass, self)
end


function BattleNode:RefreshBattleSpeedGraphic()
    LoadSpeedSettings(self)
end

function BattleNode:RefreshBattleModeGraphic()
    local mode = self.battlefield:GetBattleMode()

    if mode == kBattleMode_Auto then
        self.fightingModeImage.text = "自动"
    else
        self.fightingModeImage.text = "手动"
    end
end


-- 切换回关卡页面 --
function BattleNode:OnSceneLoaded(scene, _)
end

function BattleNode:Update()
    -- 战斗流状态机
    self.battleFlowStateMachine:Update()
end

return BattleNode
