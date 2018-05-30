--
-- User: fbmly
-- Date: 5/1/17
-- Time: 7:35 PM
--

local StateMachineClass = require "Framework.FSM.StateMachine"
require "Collection.DataStack"
require "Collection.DataQueue"


local utility = require "Utils.Utility"
local MessageGuids = require "Framework.Business.MessageGuids"
local cos3dGame = utility.GetGame()

local BattleOrderStateMachine = Class(StateMachineClass)

--[[
                                           InitState
                                               ↓
        DisappearState ← FrameDelayState ← IdleState
              ↓                                ↑
        MoveDownState  →→→→→→→→→→→→→→→→→→→ AppearState
]]

function BattleOrderStateMachine:Ctor()
    self.data.unitsToDisappear = {}
    cos3dGame:RegisterEvent(MessageGuids.BattleTakeAction, self, self.OnBattleTakeAction)
    cos3dGame:RegisterEvent(MessageGuids.BattleUnitDead, self, self.OnBattleUnitDead)
    cos3dGame:RegisterEvent(MessageGuids.BattleInitFightingHeads, self, self.OnBattleInitFightingHeads)
end

function BattleOrderStateMachine:Close()
    BattleOrderStateMachine.base.Close(self)
    cos3dGame:UnregisterEvent(MessageGuids.BattleTakeAction, self, self.OnBattleTakeAction)
    cos3dGame:UnregisterEvent(MessageGuids.BattleUnitDead, self, self.OnBattleUnitDead)
    cos3dGame:UnregisterEvent(MessageGuids.BattleInitFightingHeads, self, self.OnBattleInitFightingHeads)
end


local function AddUnitToDisappearList(self, unit)
    if unit ~= nil then
        for i = 1, #self.data.unitsToDisappear do
            if self.data.unitsToDisappear[i] == unit then
                return
            end
        end
        self.data.unitsToDisappear[#self.data.unitsToDisappear + 1] = unit
    end
end

--- 事件处理
function BattleOrderStateMachine:OnBattleUnitDead(unit)
    AddUnitToDisappearList(self, unit)
end

function BattleOrderStateMachine:OnBattleTakeAction(unit, isUsingSkill)
    AddUnitToDisappearList(self, unit)
end

function BattleOrderStateMachine:OnBattleInitFightingHeads(unitArray)
    print("BattleOrderStateMachine:OnBattleInitFightingHeads")

    -- 先把所有View归还
    self.data.SpawnedHeadViews:Foreach(function(headView, _)
        if headView == nil then
            return
        end
        headView:Clear()
        self.data.HeadViewPool:Push(headView)
    end)
    self.data.SpawnedHeadViews:Clear()


    local data = self.data

    data.allOrderedArray = DataQueue.New(unitArray)

    -- 选择小的那一个 --
    local childCount = data.allOrderedArray:Count()
    childCount = math.min(childCount, data.MaxVisibleNum)

    -- 循环加入到可见队列 --
    data.allOrderedArray:Foreach(function(battleUnit, pos)

        if pos > childCount then
            return
        end

        -- 获取当前索引的值 --
        local bezierPathPos = pos

        local ratio = self.data.ListPosRatios[bezierPathPos]

        local locationPos = self.data.bezierPath:Point(ratio)

        local headView = data.HeadViewPool:Pop() -- 取出控件
        if headView == nil then
            return
        end

        -- 设置当前的HeadView的数据 --
        headView:SetData(battleUnit)
        headView:SetPosition(locationPos)
        headView:SetBezierPathPos(bezierPathPos)
        headView:SetAlpha(1)

        -- 加到可视控件中 --
        data.SpawnedHeadViews:Enqueue(headView)
    end)

    data.SpawnedHeadViews:Front():SetScale(1.2)

    -- 让状态开始执行 --
    self.data.isStarting = true
end

return BattleOrderStateMachine
