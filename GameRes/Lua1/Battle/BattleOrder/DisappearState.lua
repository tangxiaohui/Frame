--
-- User: fbmly
-- Date: 5/1/17
-- Time: 4:17 PM
--

-- Transition Disappear 2 MoveDown.
local TransitionClass = require "Framework.FSM.Transition"

local Disappear2MoveDownTransition = Class(TransitionClass)

function Disappear2MoveDownTransition:Ctor()
end

function Disappear2MoveDownTransition:IsTriggered(_, data)
    return data.__DisappearAnimFinished == true
end

function Disappear2MoveDownTransition:GetTargetState(_, data)
    return data.BattleOrderStatePool:Get(require "Battle.BattleOrder.MoveDownState")
end



-- State Disappear.
local StateClass = require "Framework.FSM.State"

local utility = require "Utils.Utility"

local TweenUtility = require "Utils.TweenUtility"

local DisappearState = Class(StateClass)

function DisappearState:Ctor()
    self:AddTransition(Disappear2MoveDownTransition.New())
    self.disappearingViews = {}
end

local function DelayStartDisappearing(self)
    coroutine.wait(0.1)
    self.isDisappearing = true
end

function DisappearState:Enter(_, data)
    print("BattleOrderState, DisappearState:Enter")

    self.bezierPath = data.bezierPath

    -- 移除上一次的 --
    utility.ClearArrayTableContent(self.disappearingViews)

    -- 获取要消失的单位 --
    local count = #data.unitsToDisappear

    local frontHeadView = data.SpawnedHeadViews:Front()

    for i = 1, count do
        local battleUnit = data.unitsToDisappear[i]
        if battleUnit ~= nil then
            -- # 先删除 / 或放在队列末尾 --
            if data.allOrderedArray:Remove(function(unit) return unit == battleUnit end) then
                -- 如果活着 就加到队列后边
                if battleUnit:IsAlive() then
                    data.allOrderedArray:Enqueue(battleUnit)
                end
            end

            -- # 加入消失列表 # --
            data.SpawnedHeadViews:Remove(function(viewHead)
                local viewUnit = viewHead:GetBattleUnit()

                if viewUnit == battleUnit then
                    viewHead:SetFrame2Enabled(false)

                    if not battleUnit:IsAlive() then
                        viewHead:PlayDeadAnimation()
                    end
                    self.disappearingViews[#self.disappearingViews + 1] = viewHead
                    return true
                end
                return false
            end)
        end
    end

    -- 原数据清除掉 (可以让初始状态重新接收)
    utility.ClearArrayTableContent(data.unitsToDisappear)

    -- 初始化动画
    --    self.isDisappearing = true
    self.sourcePosX = 200
    self.targetPosX = 320
    self.totalTime = 0.15
    self.passedTime = 0

    self.frontHeadView = frontHeadView
    coroutine.start(DelayStartDisappearing, self)
end


local function DelayAnimFinish(self, data)
    coroutine.wait(0.5)
    data.__DisappearAnimFinished = true
end

local function UpdateMoveDownFront(self, ratio, data, t)
    local currentPos = data.bezierPath:Point(ratio)
    local sourceScale = 1.2
    local targetScale = 2.25
    local scale = TweenUtility.Linear(sourceScale, targetScale, t)
    self.frontHeadView:SetPosition(currentPos)
    self.frontHeadView:SetScale(scale)
end

function DisappearState:Update(_, data)
    if not self.isDisappearing then
        return
    end

    if #self.disappearingViews == 0 and not self.needToDisappearFrontHeadView then
        data.__DisappearAnimFinished = true
        return
    end

    local t = self.passedTime / self.totalTime
    local finished
    if t >= 1 then
        t = 1
        finished = true
    end

    for i = 1, #self.disappearingViews do
        local view = self.disappearingViews[i]
        if view == self.frontHeadView and view:GetBattleUnit() ~= nil and view:GetBattleUnit():IsAlive() then
            local sourceBezierRatio = data.ListPosRatios[self.frontHeadView:GetBezierPathPos()]
            local targetBezierRatio = 1
            --        print("移动:::", tostring(sourcePos), tostring(targetPos), t)
            UpdateMoveDownFront(self, TweenUtility.Linear(sourceBezierRatio, targetBezierRatio, t), data, t)
        else
            view:SetPositionX(TweenUtility.Linear(self.sourcePosX, self.targetPosX, t))
        end
    end



    self.passedTime = self.passedTime + Time.unscaledDeltaTime

    -- 完成了!
    if finished then
        coroutine.start(DelayAnimFinish, self, data)
        self.isDisappearing = false
    end
end

function DisappearState:Exit(_, data)
    print("BattleOrderState, DisappearState:Exit")

    self.isDisappearing = false
    data.__DisappearAnimFinished = nil

    -- 归还
    for i = 1, #self.disappearingViews do
        local viewHead = self.disappearingViews[i]
        viewHead:Clear()
        data.HeadViewPool:Push(viewHead)
    end

    utility.ClearArrayTableContent(self.disappearingViews)
end

return DisappearState