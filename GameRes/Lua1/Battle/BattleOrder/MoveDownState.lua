--
-- User: fbmly
-- Date: 5/1/17
-- Time: 4:16 PM
--

-- Transition MoveDown 2 Appear.
local TransitionClass = require "Framework.FSM.Transition"

local MoveDown2AppearTransition = Class(TransitionClass)

function MoveDown2AppearTransition:Ctor()
end

function MoveDown2AppearTransition:IsTriggered(_, data)
    return data.__MoveDownAnimFinished == true
end

function MoveDown2AppearTransition:GetTargetState(_, data)
    return data.BattleOrderStatePool:Get(require "Battle.BattleOrder.AppearState")
end


local __TotalTime__ = 0.15


-- State MoveDown.
local StateClass = require "Framework.FSM.State"

local MoveDownState = Class(StateClass)

local TweenUtility = require "Utils.TweenUtility"

function MoveDownState:Ctor()
    self:AddTransition(MoveDown2AppearTransition.New())
end

function MoveDownState:Enter(_, _)
    print("BattleOrderState, MoveDownState:Enter")
    -- 初始化动画
    self.isMovingDown = true
    self.passedTime = 0
end

function MoveDownState:Update(_, data)
    if not self.isMovingDown then
        return
    end

    if data.SpawnedHeadViews:Count() == 0 then
        data.__MoveDownAnimFinished = true
        return
    end

    local t = self.passedTime / __TotalTime__
    local finished = false
    if t >= 1 then
        t = 1
        finished = true
    end

    data.SpawnedHeadViews:Foreach(function(headView, pos)
        local sourcePos = headView:GetPosition()

        local targetRatio = data.ListPosRatios[headView:GetBezierPathPos() - 1]
        if targetRatio == nil then
            return
        end

        local targetPos = data.bezierPath:Point(targetRatio)

        local x = TweenUtility.EaseOutBack(sourcePos.x, targetPos.x, t)
        local y = TweenUtility.EaseOutBack(sourcePos.y, targetPos.y, t)

        headView:SetPosition(Vector3(x,y,0))
    end)

    self.passedTime = self.passedTime + Time.unscaledDeltaTime

    -- 完成了!
    if finished then
        data.__MoveDownAnimFinished = true
    end
end

function MoveDownState:Exit(_, data)
    print("BattleOrderState, MoveDownState:Exit")
    self.isMovingDown = false
    data.__MoveDownAnimFinished = nil
end

return MoveDownState