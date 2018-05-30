--
-- User: fenghao
-- Date: 5/17/17
-- Time: 2:49 PM
--

-- 战斗结束 状态

local StateClass = require "Framework.FSM.State"

local utility = require "Utils.Utility"

local BattleEndState = Class(StateClass)

function BattleEndState:Ctor()
end

local function UnloadBattleScene(self, owner)
    local ProgressBarUtils = require "Utils.ProgressBarUtils"
    ProgressBarUtils.Display("正在突破次元壁","正在退出战斗...", 0)

    -- 开启逻辑锁
    utility.GetGame():GetSceneManager():SetLogicLock()


    -- 提前获取数组, 为了统计总数
    local array = owner:GetBattleUnitPreloadSet()

    local passedCount = 0
    -- # 释放池(1), 资源(#array), 加载Normal场景(1), 切换场景并等待完成(1), 伪进度(5)
    local totalCount = 1 + #array + 1 + 1 + 5

    -- @1. 释放战斗的资源池
    utility.GetGame():GetPoolManager():DestroyPoolsByTag(kPoolTag_Battle)
    passedCount = passedCount + 1
    ProgressBarUtils.Display("正在突破次元壁","正在退出战斗...", passedCount/totalCount) -- >>更新进度
    coroutine.step(2)
    debug_print("progress:", passedCount, totalCount)

    -- @2. 释放预制体资源
    for i = 1, #array do
        local unit = array[i]
        local resPathMgr = require "StaticData.ResPath"
        local prefabName = resPathMgr:GetData(unit:GetId()):GetPath()
        utility.UnloadResource(prefabName, typeof(UnityEngine.GameObject))
        passedCount = passedCount + 1
        ProgressBarUtils.Display("正在突破次元壁","正在退出战斗...", passedCount/totalCount) -- >>更新进度
        debug_print("progress:", passedCount, totalCount)
        debug_print("@@ 释放资源 @@", prefabName)
        coroutine.step(2)
    end

    -- @3. 加载Normal场景
    local operation = utility.LoadBattleSceneAsync("Normal")
    repeat
        coroutine.step()
    until(operation.isDone and operation.progress >= 1)
    passedCount = passedCount + 1
    ProgressBarUtils.Display("正在突破次元壁","正在退出战斗...", passedCount/totalCount) -- >>更新进度
    debug_print("progress:", passedCount, totalCount)
    coroutine.step(2)

    -- @4. 界面切换&等待完毕
    if owner:IsFirstFight() then
        debug_print("切换场景1")
        -- 第一场战斗不太一样 需要切换到Main
        utility.JumpScene(function()
            debug_print("切换场景1~1")
            local sceneManager = utility.GetGame():GetSceneManager()
            local MainSceneClass = require "Scenes.MainScene"
            sceneManager:ReplaceScene(MainSceneClass.New())
            sceneManager:ClearAllScenesExceptWorkingScenes()
        end)
    else
        debug_print("切换场景2")
        -- 切回上一个即可
        utility.PopToPreviousScene()
    end

    -- > 等待界面切换完毕
    repeat
        coroutine.step()
    until(not utility.GetGame():GetSceneManager():IsSwitching())

    debug_print("切换场景2~2")

    passedCount = passedCount + 1
    ProgressBarUtils.Display("正在突破次元壁","正在退出战斗...", passedCount/totalCount) -- >>更新进度
    debug_print("progress:", passedCount, totalCount)
    coroutine.step(2)

    -- 关闭逻辑锁
    utility.GetGame():GetSceneManager():ResetLogicLock()

    -- @5. 伪进度
    for i = passedCount, totalCount do
        ProgressBarUtils.Display("正在突破次元壁","正在退出战斗...", i/totalCount) -- >>更新进度
        debug_print("progress:", i, totalCount)
        coroutine.wait(0.3)
    end

    -- >> 取消进度条的显示
    ProgressBarUtils.Clear()
end

function BattleEndState:Enter(owner, data)
    -- debug_print("BattleEndState:Enter >>>>>>>")

    -- 新手引导 --
    if not owner:IsFirstFight() then
		local guideMgr = utility.GetGame():GetGuideManager()
	    guideMgr:AddGuideEvnt(kGuideEvnt_Dungeon2MainPanel)
	    guideMgr:SortGuideEvnt()
    end
    owner:GetBattlefield():Clear()

    -- @ 隐藏所有二级界面
    
    utility.GetGame():GetWindowManager():HideAll(true)

    debug_print("@@ 战斗结束, 准备进入进入条阶段")
    coroutine.start(UnloadBattleScene, self, owner)
end

function BattleEndState:Update(owner, data)
end

function BattleEndState:Exit(owner, data)
    debug_print("BattleEndState:Exit >>>>>>>>")
end

return BattleEndState
