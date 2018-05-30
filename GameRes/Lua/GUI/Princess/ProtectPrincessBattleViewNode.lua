--
-- User: fenghao
-- Date: 03/07/2017
-- Time: 7:49 PM
--

local BaseNodeClass = require "Framework.Base.Node"
require "Collection.DataStack"
require "Collection.DataQueue"
local utility = require "Utils.Utility"
local TweenUtility = require "Utils.TweenUtility"
require "Const"
local messageGuids = require "Framework.Business.MessageGuids"

local ProtectPrincessBattleViewNode = Class(BaseNodeClass)

local gHeadRatios = {
    1,
    0.71,
    0.433,
    0.223,
    0
}

local gMinScale = 0.7
local gMaxScale = 1


local function InitControls(self)
    local transform = self:GetUnityTransform()

    -->> 贝塞尔曲线构造 <<--
    -- ## 1. 构造控制点列表 ##
    local ControlPoints = {}
    local ControlPointsTrans = transform:Find("TopCanvas/ControlPoints")
    local childCount = ControlPointsTrans.childCount
    for i = 0, childCount - 1 do
        local child = ControlPointsTrans:GetChild(i)
        ControlPoints[#ControlPoints + 1] = child.localPosition
    end
    ControlPointsTrans.gameObject:SetActive(false)

    -- ## 2. 构造BezierPath
    local BezierPathClass = require "Framework.Bezier.BezierPath"
    self.bezierPath = BezierPathClass.New(ControlPoints, 0.05)

    -->> 控件列表 <<--
    self.headPlayerPool = DataStack.New()
    local ProtectPrincessHeadNodeClass = require "GUI.Princess.ProtectPrincessHeadNode"
    self.headPlayerPool:Push(ProtectPrincessHeadNodeClass.New(transform:Find("TopCanvas/Items/Head1")))
    self.headPlayerPool:Push(ProtectPrincessHeadNodeClass.New(transform:Find("TopCanvas/Items/Head2")))
    self.headPlayerPool:Push(ProtectPrincessHeadNodeClass.New(transform:Find("TopCanvas/Items/Head3")))
    self.headPlayerPool:Push(ProtectPrincessHeadNodeClass.New(transform:Find("TopCanvas/Items/Head4")))
    self.headPlayerPool:Push(ProtectPrincessHeadNodeClass.New(transform:Find("TopCanvas/Items/Head5")))

    -->> 当前的显示队列 <<--
    self.headPlayerQueue = DataQueue.New()

    self.useTweenMove = false
end

local function OnProtectDone(self)
    -- TODO : 战斗完成 --
end

local function ResetAllHeadNodes(self)
    self.headPlayerQueue:Foreach(function(headNode, _)
        self.headPlayerPool:Push(headNode)
--        headNode:Clear()
        self:RemoveChild(headNode)
    end)
    self.headPlayerQueue:Clear()
end

local function OnProtectDataQueryUpdate(self, msg)

    self.protectMsg = msg


    local curGate = msg.curGate
    local maxControls = #gHeadRatios
    local totalGateCount = #msg.gateInfo

    ResetAllHeadNodes(self)

    print("当前关卡>>", msg.curGate)
    print("当前关卡状态>>", msg.gateState)
    print("总共关卡>>", totalGateCount)
    print("SID>>", msg.head.sid)

    utility.ASSERT(msg.gateState >= kProtectPrincessGateStatus_None and msg.gateState <= kProtectPrincessGateStatus_Received,
        string.format("状态超过预期的值了 state: %d", msg.gateState))

    if curGate > totalGateCount then
        print("OnProtectDataQueryUpdate >>> 1")
        OnProtectDone(self)
    else
        print("OnProtectDataQueryUpdate >>> 2")
        for i = 1, maxControls do
            local currentGate = curGate + i - 1
            if currentGate > totalGateCount then
                break
            end

            local currentGateInfo = msg.gateInfo[currentGate]

            local headNode = self.headPlayerPool:Pop()

            print("OnProtectDataQueryUpdate >>> 3")
            -- 设置值 --
            headNode:SetGateID(currentGateInfo)

            if currentGateInfo.gateID ~= msg.curGate then
                print("OnProtectDataQueryUpdate >>> 4")
                -- 如果不是当前关卡 显示战斗状态 , 显示玩家头像等级等信息 --
                headNode:SetMode(kProtectPrincessHeadMode_Fight)
                headNode:SetSelected(false)
            else
                print("OnProtectDataQueryUpdate >>> 5")
                headNode:SetSelected(true)
                -- 过滤不可能的状态
                if msg.gateState == kProtectPrincessGateStatus_Received then
                    error("箱子状态不可能是这个! 因为已经获取后 不会再走这里!")
                end

                -- 如果可以领了 但还没领 --
                if msg.gateState == kProtectPrincessGatetatus_NotReceiveYet then
                    headNode:SetMode(kProtectPrincessGatetatus_NotReceiveYet)
                else
                    -- 设置其他状态为 显示人物头像信息 --
                    headNode:SetMode(kProtectPrincessHeadMode_Fight)
                end
            end

            if headNode:GetMode() == kProtectPrincessHeadMode_Fight then
                print("OnProtectDataQueryUpdate >>> 6")
                -- 头像战斗的模式 还需要设置其他属性, 而箱子模式却只需要ID即可! --
                --headNode:SetLevel(headIcon)
                headNode:SetLevel(currentGateInfo.level)
                headNode:SetHeadCardID(currentGateInfo.headCardID)
                headNode:SetWaveNum(currentGateInfo.gateID)
                headNode:SetRatio(gHeadRatios[i])
            end
            print("OnProtectDataQueryUpdate >>> 7")
            self.headPlayerQueue:Enqueue(headNode)
            self:AddChild(headNode)
        end

        self.headPlayerQueue:Foreach(function(headNode, pos)
            print("OnProtectDataQueryUpdate >>> 8")
            headNode:SetPosition(self.bezierPath:Point(gHeadRatios[pos]))
            headNode:SetScale(TweenUtility.Linear(gMinScale, gMaxScale, gHeadRatios[pos]))
        end)

    end

    print("OnProtectDataQueryUpdate >>> 9")
end

local function OnProtectDataNextGate(self, msg)

    --debug_print("@@ OnProtectDataNextGate 1 @@")

    if self.headPlayerQueue:Count() == 0 then
        return
    end

    -- 隐藏掉第一个 --
    local frontHeadNode = self.headPlayerQueue:Dequeue()
    self:RemoveChild(frontHeadNode)
    self.headPlayerPool:Push(frontHeadNode)

    -- 设置其他的 --

    local totalGateCount = #msg.gateInfo
    local newGate = msg.curGate + self.headPlayerQueue:Count()
    local currentGateInfo = msg.gateInfo[newGate]
    if newGate <= totalGateCount and currentGateInfo ~= nil then
        local newHeadNode = self.headPlayerPool:Pop()
        newHeadNode:SetMode(kProtectPrincessHeadMode_Fight)
        newHeadNode:SetSelected(false)

        newHeadNode:SetLevel(currentGateInfo.level)
        newHeadNode:SetHeadCardID(currentGateInfo.headCardID)
        newHeadNode:SetWaveNum(currentGateInfo.gateID)
--        newHeadNode:SetRatio(gHeadRatios[i])

        self.headPlayerQueue:Enqueue(newHeadNode)
        self:AddChild(newHeadNode)
    end

    self.headPlayerQueue:Foreach(function(headNode, pos)
        if pos == 1 then
            headNode:SetSelected(true)
        end
        headNode:SetRatio(gHeadRatios[pos])
        headNode:SetPosition(self.bezierPath:Point(gHeadRatios[pos]))
        headNode:SetScale(TweenUtility.Linear(gMinScale, gMaxScale, gHeadRatios[pos]))
    end)

    -- 发送消息 告知完成 --
    self:DispatchEvent(messageGuids.ProtectDataNextGateAnimFinished, nil, msg)
end


function ProtectPrincessBattleViewNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function ProtectPrincessBattleViewNode:OnResume()

    self:RegisterEvent(messageGuids.ProtectDataQueryUpdate, OnProtectDataQueryUpdate, nil)
    self:RegisterEvent(messageGuids.ProtectDataNextGate, OnProtectDataNextGate, nil)

end

function ProtectPrincessBattleViewNode:OnPause()

    self:UnregisterEvent(messageGuids.ProtectDataQueryUpdate, OnProtectDataQueryUpdate, nil)
    self:UnregisterEvent(messageGuids.ProtectDataNextGate, OnProtectDataNextGate, nil)

end

return ProtectPrincessBattleViewNode
