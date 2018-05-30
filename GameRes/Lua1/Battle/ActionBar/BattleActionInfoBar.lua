--
-- User: fenghao
-- Date: 23/06/2017
-- Time: 4:03 PM
--

local NodeClass = require "Framework.Base.UINode"

local BattleActionInfoBar = Class(NodeClass)

local TweenUtility = require "Utils.TweenUtility"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

--require "Collection.OrderedDictionary"
local totalTime = 0.1

local function InitControls(self)
    local transform = self:GetUnityTransform()

    self.showedItems = {}

    -->> 贝塞尔曲线构造 <<--
    -- ## 1. 构造控制点列表 ##
    local ControlPoints = {}
    local ControlPointsTrans = transform:Find("ControlPoints")
    local childCount = ControlPointsTrans.childCount
    for i = 0, childCount - 1 do
        local child = ControlPointsTrans:GetChild(i)
        ControlPoints[#ControlPoints + 1] = child.localPosition
    end
    ControlPointsTrans.gameObject:SetActive(false)

    -- ## 2. 构造BezierPath
    local BezierPathClass = require "Framework.Bezier.BezierPath"
    self.bezierPath = BezierPathClass.New(ControlPoints, 0.05)

    -->> 行动列表 <<--
    local BattleUnitActionItemClass = require "Battle.ActionBar.BattleUnitActionItem"
    self.actionCardItems = {
        BattleUnitActionItemClass.New(transform:Find("Card1"), 0, 0.735),
        BattleUnitActionItemClass.New(transform:Find("Card2"), 0.053, 0.788),
        BattleUnitActionItemClass.New(transform:Find("Card3"), 0.106, 0.841),
        BattleUnitActionItemClass.New(transform:Find("Card4"), 0.159, 0.894),
        BattleUnitActionItemClass.New(transform:Find("Card5"), 0.212, 0.947),
        BattleUnitActionItemClass.New(transform:Find("Card6"), 0.265, 1)
    }

    -- ## 3. 联动 ## --
    self.assistTipObject = transform:Find("Infos/Combo").gameObject

    -- ## 4. 攻击 ## --
    self.attackTipObject = transform:Find("Infos/Attack").gameObject

    -- ## 5. 技能 ## --
    self.skillObject = transform:Find("Infos/Skill").gameObject
end

function BattleActionInfoBar:Ctor(transform)
    self.coHandler = nil
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

local function MoveToTarget(self, actionItem, delay, isLast, tipObject, isClear, isRightNow)
    self.showedItems[#self.showedItems + 1] = actionItem

    if delay > 0 then
        coroutine.wait(delay)
    end

    local passedTime = 0
    local finished = false

    local startRatio = actionItem:GetStartRatio()
    local endRatio = actionItem:GetEndRatio()

    if isRightNow then
        local localPosition = self.bezierPath:Point(endRatio)
        actionItem:SetLocalPosition(localPosition)
        return
    end

    repeat
        local t = passedTime / totalTime
        if t >= 1 then
            t = 1
            finished = true
        end

        local currentRatio = TweenUtility.Linear(startRatio, endRatio, t)
        local localPosition = self.bezierPath:Point(currentRatio)
        actionItem:SetLocalPosition(localPosition)

        passedTime = passedTime + UnityEngine.Time.unscaledDeltaTime

        coroutine.step(1)
    until(finished == true)

    if isLast then
        if isClear then
            self.coHandler = nil
        end

        if tipObject ~= nil then
            tipObject:SetActive(true)
        end
    end
end

local function DisappearAnim(self, actionItem, delay, isLast, isClear)
    if delay > 0 then
        coroutine.wait(delay)
    end

    local passedTime = 0
    local finished = false

    local startY = actionItem:GetLocalPositionY()
    local endY = startY - 300

    repeat
        local t = passedTime / totalTime
        if t >= 1 then
            t = 1
            finished = true
        end

        local currentPosY = TweenUtility.Linear(startY, endY, t)
        actionItem:SetLocalPositionY(currentPosY)

        passedTime = passedTime + UnityEngine.Time.unscaledDeltaTime

        coroutine.step(1)
    until(finished == true)

    actionItem:Clear()

    if isLast and isClear then
        self.coHandler = nil
    end
end


local function WaitForFinished(self)
    while(self.coHandler ~= nil)
        do
        coroutine.step(1)
    end
end

-- 开始联动 --
local function OnHandleBeginAssistAttack(self, assistAttackStarter, assistUnits)
    WaitForFinished(self)

    -- 开始联动 --
    utility.ClearArrayTableContent(self.showedItems)

    -- 首先拿带队那个人 --
    self.actionCardItems[1]:SetData(assistAttackStarter)
    self:StartCoroutine(MoveToTarget, self.actionCardItems[1], 0.35, false, self.assistTipObject, nil, true)

    -- 然后拿之后的人 --
    for i = 1, #assistUnits do
        self.actionCardItems[i + 1]:SetData(assistUnits[i])
        self.coHandler = self:StartCoroutine(MoveToTarget, self.actionCardItems[i + 1], 0.35 + i * 0.1, i == #assistUnits, self.assistTipObject, true)
    end
end

-- 结束联动 --
local function OnHandleEndAssistAttack(self)
    self.assistTipObject:SetActive(false)
    for i = 1, #self.showedItems do
        local item = self.showedItems[i]
        self.coHandler = self:StartCoroutine(DisappearAnim, item, (i - 1) * 0.1, i == #self.showedItems, true)
    end
    utility.ClearArrayTableContent(self.showedItems)
end

-- 普攻 --
local function OnHandleAttack(self, unit)
    WaitForFinished(self)

    self.coHandler = coroutine.running()

    utility.ClearArrayTableContent(self.showedItems)
    -- 设置
    self.actionCardItems[1]:Clear(unit)
    self.actionCardItems[1]:SetData(unit)
    MoveToTarget(self, self.actionCardItems[1], 0.5, true, nil, nil, true)
    self.attackTipObject:SetActive(true)
    coroutine.wait(1)
    self.attackTipObject:SetActive(false)
    DisappearAnim(self, self.actionCardItems[1], 0)
    utility.ClearArrayTableContent(self.showedItems)

    self.coHandler = nil
end

-- 技能 --
local function OnHandleSkill(self, unit)
    WaitForFinished(self)

    self.coHandler = coroutine.running()

    utility.ClearArrayTableContent(self.showedItems)
    -- 设置
    self.actionCardItems[1]:Clear()
    self.actionCardItems[1]:SetData(unit)
    MoveToTarget(self, self.actionCardItems[1], 0.5, true, nil, nil, true)
	self:DispatchEvent(messageGuids.BattlePlaySkillHeadEffect, nil)
    self.skillObject:SetActive(true)
    coroutine.wait(1)
    self.skillObject:SetActive(false)
    DisappearAnim(self, self.actionCardItems[1], 0)
    utility.ClearArrayTableContent(self.showedItems)

    self.coHandler = nil
end



local function OnBeginAssistAttack(self, assistAttackStarter, assistUnits)
    self:StartCoroutine(OnHandleBeginAssistAttack, assistAttackStarter, assistUnits)
end

local function OnEndAssistAttack(self)
    self:StartCoroutine(OnHandleEndAssistAttack)
end

local function OnTakeAttackAction(self, unit)
    self:StartCoroutine(OnHandleAttack, unit)
end

local function OnBattleSkillAction(self, unit, isUsingSkill)
    if isUsingSkill then
        -- 开始技能 --
        self:StartCoroutine(OnHandleSkill, unit)
    end
end

function BattleActionInfoBar:OnResume()
    BattleActionInfoBar.base.OnResume(self)

    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.BattleBeginAssistAttack, OnBeginAssistAttack, nil)
    self:RegisterEvent(messageGuids.BattleEndAssistAttack, OnEndAssistAttack, nil)
    self:RegisterEvent(messageGuids.BattleTakeAttackAction, OnTakeAttackAction, nil)
    self:RegisterEvent(messageGuids.BattleTakeAction, OnBattleSkillAction, nil)


end

function BattleActionInfoBar:OnPause()
    BattleActionInfoBar.base.OnPause(self)

    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.BattleBeginAssistAttack, OnBeginAssistAttack, nil)
    self:UnregisterEvent(messageGuids.BattleEndAssistAttack, OnEndAssistAttack, nil)
    self:UnregisterEvent(messageGuids.BattleTakeAttackAction, OnTakeAttackAction, nil)
    self:UnregisterEvent(messageGuids.BattleTakeAction, OnBattleSkillAction, nil)
end

return BattleActionInfoBar
