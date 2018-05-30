--
-- User: fbmly
-- Date: 5/1/17
-- Time: 4:17 PM
--

-- Transition Appear 2 Idle.
local TransitionClass = require "Framework.FSM.Transition"

local Appear2IdleTransition = Class(TransitionClass)

function Appear2IdleTransition:Ctor()
end

function Appear2IdleTransition:IsTriggered(owner, data)
    return data.__AppearAnimFinished == true
end

function Appear2IdleTransition:GetTargetState(_, data)
    return data.BattleOrderStatePool:Get(require "Battle.BattleOrder.IdleState")
end


-- State Appear.
local StateClass = require "Framework.FSM.State"

local AppearState = Class(StateClass)

function AppearState:Ctor()
    self:AddTransition(Appear2IdleTransition.New())
end

function AppearState:Enter(owner, data)
    print("BattleOrderState, AppearState:Enter")
end

function AppearState:Update(owner, data)
    if data.allOrderedArray:Count() == 0 then
        -- TODO 一个都没有时候的处理
        data.__AppearAnimFinished = true
        return
    end

    -- 先把所有View归还
    data.SpawnedHeadViews:Foreach(function(headView, _)
        headView:Clear()
        data.HeadViewPool:Push(headView)
    end)
    data.SpawnedHeadViews:Clear()

    -- 选择小的那一个 --
    local childCount = data.allOrderedArray:Count()
    childCount = math.min(childCount, data.MaxVisibleNum)

    data.allOrderedArray:Foreach(function(battleUnit, pos)
        if pos > childCount then
            return
        end

        -- 获取当前索引的值 --
        local bezierPathPos = pos

        local ratio = data.ListPosRatios[bezierPathPos]

        local locationPos = data.bezierPath:Point(ratio)

        local headView = data.HeadViewPool:Pop() -- 取出控件
        if headView == nil then
            return
        end

        -- 设置当前的HeadView的数据 --
        headView:Clear()
        headView:SetData(battleUnit)
        headView:SetPosition(locationPos)
        headView:SetBezierPathPos(bezierPathPos)
        headView:SetAlpha(1)

        data.SpawnedHeadViews:Enqueue(headView)
    end)

    data.SpawnedHeadViews:Front():SetScale(1.2)

    data.__AppearAnimFinished = true
end

function AppearState:Exit(owner, data)
    print("BattleOrderState, AppearState:Exit")
    data.__AppearAnimFinished = nil
end

return AppearState