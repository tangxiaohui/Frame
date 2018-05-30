--
-- User: fbmly
-- Date: 5/1/17
-- Time: 4:00 PM
--
require "Collection.DataStack"
require "Collection.DataQueue"

-- 消息相关
--local utility = require "Utils.Utility"
--local MessageGuids = require "Framework.Business.MessageGuids"
--local cos3dGame = utility.GetGame()


-- Transition Init 2 Idle.
local TransitionClass = require "Framework.FSM.Transition"

local Init2IdleTransition = Class(TransitionClass)

function Init2IdleTransition:Ctor()
end

function Init2IdleTransition:IsTriggered(_, data)
    return data.__InitFinished == true
end

function Init2IdleTransition:GetTargetState(_, data)
    return data.BattleOrderStatePool:Get(require "Battle.BattleOrder.IdleState")
end



-- State Init.
local StateClass = require "Framework.FSM.State"

local InitState = Class(StateClass)

function InitState:Ctor()
    self.transition = Init2IdleTransition.New()
    self:AddTransition(self.transition)

    --data.isStarting = false
end

function InitState:Enter(_, data)
    print("BattleOrderStateMachine:InitState")
--    print("初始状态 》》》》》 ENTER")
    self.cachedData = data

    -- # 初始化 # --
    data.TotalViewNum = 6                       -- 一共的控件个数
    data.MaxVisibleNum = 6                    -- 最大可见数量
    data.HeadViewPool = DataStack.New()         -- 池
    data.SpawnedHeadViews = DataQueue.New()     -- 可见队列

    data.ListPosRatios = {
        0.496,
        0.388,
        0.293,
        0.197,
        0.102,
        0
    }

    -->> @@@ 贝塞尔曲线构造 @@@ <<--
    -- ## 1. 构造控制点列表 ##
    local ControlPoints = {}
    local ControlPointsTrans = data.ProgressControlPoints
    local childCount = ControlPointsTrans.childCount
    for i = 0, childCount - 1 do
        local child = ControlPointsTrans:GetChild(i)
        ControlPoints[#ControlPoints + 1] = child.localPosition
    end
    ControlPointsTrans.gameObject:SetActive(false)

    -- ## 2. 构造BezierPath
    local BezierPathClass = require "Framework.Bezier.BezierPath"
    data.bezierPath = BezierPathClass.New(ControlPoints, 0.05)

    -- 将控件放入池中 --
    local FightingProgressHeadClass = require "GUI.Battle.FightingProgressHead"
    local transform = data.ProgressLayoutTrans

    -- 循环获取控件 --
    for i = 1, 6 do
        local child = transform:Find(string.format("FightingProgressHead%d", i))
        local newHeadView = FightingProgressHeadClass.New(child)
        newHeadView:Clear()
        data.HeadViewPool:Push(newHeadView)
    end


--
--    -- 初始化数量 可视数量 池 可视队列 --
--    local childCount = data.ProgressLayoutTrans.childCount
----    print("一共的控件个数为 **************************", childCount)
--
--    data.TotalViewNum = childCount          -- 一共的控件个数
--    data.MaxVisibleNum = childCount - 1     -- 最大可见数量
--    data.HeadViewPool = DataStack.New()     -- 池
--    data.SpawnedHeadViews = DataQueue.New() -- 可见队列
--
--    -- 将控件放入池里 --
--    local FightingProgressHeadClass = require "GUI.Battle.FightingProgressHead"
--    for i = 1, childCount do
--        local trans = data.ProgressLayoutTrans:GetChild(i - 1)
--        local newHeadView = FightingProgressHeadClass.New(trans)
--        newHeadView:Clear()
--        data.HeadViewPool:Push(newHeadView)
--    end
end

function InitState:Update(_, data)
    if not data.isStarting then
        return
    end
    data.__InitFinished = true
end

function InitState:Exit(_, data)
--    print("初始状态 》》》》》 EXIT")
    -- 取消消息
    data.__InitFinished = nil
end


return InitState