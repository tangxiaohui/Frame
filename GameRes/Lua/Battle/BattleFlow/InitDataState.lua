--
-- User: fenghao
-- Date: 5/16/17
-- Time: 8:28 PM
--

-- 到 场景预览的Transition
local TransitionClass = require "Framework.FSM.Transition"

local InitData2ScenePreviewTransition = Class(TransitionClass)

function InitData2ScenePreviewTransition:Ctor()
end

function InitData2ScenePreviewTransition:IsTriggered(_, data)
    return data.needToPreviewScene == true
end

function InitData2ScenePreviewTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.ScenePreviewState")
end

-- 到 战斗游戏的Transition
local InitData2BattleEndTransition = Class(TransitionClass)

function InitData2BattleEndTransition:Ctor()
end

function InitData2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function InitData2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end


-- 数据初始化 状态
local StateClass = require "Framework.FSM.State"

local unityUtils = require "Utils.Unity"
local utility = require "Utils.Utility"

local InitDataState = Class(StateClass)

function InitDataState:Ctor()
    self:AddTransition(InitData2ScenePreviewTransition.New())
    self:AddTransition(InitData2BattleEndTransition.New())
end

--------------------------------------------------------------------------------
--- @@@@ 初始化摄像机
--------------------------------------------------------------------------------
local function SetupCameras(_, owner, data)
    local battlefield = owner:GetBattlefield()

        data.cameras = {}
        data.cameras.showOffAtBeginning 	= battlefield:GetCameraShowOffAtBeginning()
        
        -- 技能选择的摄像机 --
        data.cameras.skillSelection = battlefield:GetSkillSelectionCamera()
        data.cameras.skillSelection:SetActive(false)

        data.cameras.currentCamera = data.cameras.showOffAtBeginning

        data.cameraPaths = {}
        data.cameraPaths.showOffAtBeginning = battlefield:GetCameraPathShowOffAtBeginning()
        data.cameraPaths.showOffAtBeginning:SendMessage("Seek",0)
        data.cameraPaths.showOffAtBeginning:SendMessage("LateUpdate")
        data.cameraPaths.showOffAtBeginning:SetActive(false)

        -- 技能选择的摄像机路径 --
        data.cameraPaths.skillSelection = battlefield:GetCameraPathSkillSelection()

        -- 存储原始的摄像机的位置和旋转
        local showOffTrans = data.cameras.currentCamera.transform
        data.showOffAtBeginningPosition = showOffTrans.position
        data.showOffAtBeginningRotation = showOffTrans.rotation
end

--------------------------------------------------------------------------------
--- @@@@ 初始化UI效果
--------------------------------------------------------------------------------
local function SetupUIElements(_, _, data)
    local uiManager = require "Utils.Utility".GetUIManager()
    local battleCanvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()

    -- 获取开始战斗UI文字的Animator, 这样可以播放UI显示效果 (之后有资源管理了需要删除)
    data.uiElements = {}
    data.uiElements.battleStartAnimator = battleCanvasTransform:Find("BattleStart"):GetComponent(typeof(UnityEngine.Animator))

    -- 战斗胜利或失败 --
    data.uiElements.battleResultsAnimator = battleCanvasTransform:Find("BattleResults"):GetComponent(typeof(UnityEngine.Animator))
end

function InitDataState:Enter(owner, data)
    -- print("InitDataState:Enter >>>>>")

    -- @1. 初始化摄像机
    SetupCameras(self, owner, data)

    -- @2. 初始化UI元素
    SetupUIElements(self, owner, data)

    -- @3. 发送进入战斗事件
    local messageGuids = require "Framework.Business.MessageGuids"
    local myGame = utility.GetGame()
    myGame:DispatchEvent(messageGuids.FightFightEnter, nil)

    -- @3. 切换到场景预览状态
    data.needToPreviewScene = true
end

function InitDataState:Update(_, _)
end

function InitDataState:Exit(_, data)
    -- print("InitDataState:Exit >>>>>")
    data.needToPreviewScene = nil
end

return InitDataState
