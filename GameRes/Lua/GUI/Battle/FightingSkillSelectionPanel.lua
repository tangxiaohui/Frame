--
-- User: fbmly
-- Date: 4/27/17
-- Time: 5:27 PM
--

-- FightingSkillSelectionPanelClass
require "Const"
require "Battle.BattleTargetInfo"
local BaseNodeClass = require "Framework.Base.Node"
local messageGuids = require "Framework.Business.MessageGuids"

local FightingSkillSelectionPanel = Class(BaseNodeClass)
local utility = require "Utils.Utility"

function FightingSkillSelectionPanel:Ctor(transform, owner)
	self.owner = owner
    self:BindComponent(transform.gameObject, false)
    self:InitControls()
end

local function InitMode(self)
    -- 默认单人选择 --
    self.maxSelectedNumber = 1
    self.selectionMode = kTargetSelectionMode_Number

    print("InitMode -- 1")

    -- 全体模式 --
    if self.isAll then
        print("InitMode -- 2")
        self.selectionMode = kTargetSelectionMode_All
        return
    end

    local currentTargetInfo = self:GetFirstTargetInfo()

    print("InitMode -- 3")

    print("技能选择目标类型", currentTargetInfo:GetTargetType())

    -- 前后排模式 --
    if currentTargetInfo:CompareTargetType(kSkillTarget_BackrowMembers) or
       currentTargetInfo:CompareTargetType(kSkillTarget_BackrowMembers) or
       currentTargetInfo:CompareTargetType(kSkillTarget_FrontrowFoes) or
       currentTargetInfo:CompareTargetType(kSkillTarget_BackrowFoes) then
        print("InitMode -- 4")
        self.selectionMode = kTargetSelectionMode_FrontRowOrBackRow
        return
    end

    -- 连带模式 (暂时无法测试) --
    if currentTargetInfo:CompareTargetType(kSkillTarget_MembersByDirection) or
       currentTargetInfo:CompareTargetType(kSkillTarget_FoesByDirection) then

        print("InitMode -- 5")

        local param = currentTargetInfo:GetTargetParam()

        if param == kSkillLinearType_Horizontal then
            self.selectionMode = kTargetSelectionMode_Horizontal
        elseif param == kSkillLinearType_Vertical then
            self.selectionMode = kTargetSelectionMode_Vertical
        elseif param == kSkillLinearType_Cross then
            self.selectionMode = kTargetSelectionMode_Cross
        end

        return
    end

    print("InitMode -- 6")

    -- 多人随机 --
    if currentTargetInfo:CompareTargetType(kSkillTarget_RandomMembers) or
       currentTargetInfo:CompareTargetType(kSkillTarget_RandomFoes) or
       currentTargetInfo:CompareTargetType(kSkillTarget_FoesLowestHP) or
       currentTargetInfo:CompareTargetType(kSkillTarget_FoesHighestHP) or
       currentTargetInfo:CompareTargetType(kSkillTarget_FoesHighestPercentHP) or
       currentTargetInfo:CompareTargetType(kSkillTarget_FoesLowestPercentHP) then

        print("InitMode -- 7")

        self.selectionMode = kTargetSelectionMode_Number

        local param = currentTargetInfo:GetTargetParam()
        if type(param) == "number" and param > 0 then
            self.maxSelectedNumber = param
        else
            self.maxSelectedNumber = 1
        end

        return
    end

    print("InitMode -- 8")
end

function FightingSkillSelectionPanel:GetFirstTargetInfo()
    return self.activeSkill.luaGameObject:GetTargets()
end


-- something code about guide --
local function ShowFirstFightGuide(self)
	if self.owner:IsFirstFight() then
		local guideMgr = utility.GetGame():GetGuideManager()
		if not self.firstFightFlag then
			guideMgr:AddGuideEvnt(kGuideEvnt_FirstFightSkillClick)
			guideMgr:SortGuideEvnt()
			guideMgr:ShowGuidance()
			self.firstFightFlag = true
			return true
		end
	end
	return false
end

local function OnGuideEventDone(self, stepId)
	--if stepId > 0 then
	--	local newPlayerGuideStepData = require "StaticData.NewPlayerGuideStep":GetData(stepId)
	--	local eventId = newPlayerGuideStepData:GetGuideEvent()
	--	if eventId == kGuideEvnt_FirstFightSkillClick then
			--local guidePlayerPrefs = require "Utils.PlayerPrefsUtils"
			--guidePlayerPrefs:SetGuideEvntDone(eventId)
	--	end	
	--end
end

function FightingSkillSelectionPanel:Show(activeSkill, isAll, targetSide, callback)
    self:Close()
    self.activeSkill = activeSkill
    self.isAll = isAll
    self.targetSide = targetSide
    self.callback = callback
    self:UpdateView()
    self:RegisterEvents()
    InitMode(self)
    self.currentSelectedNumbers = 0
	
    local gameObject = self:GetUnityGameObject()
    gameObject:SetActive(true)

    -- 显示 --
    local unit = self.activeSkill.luaGameObject
    unit:GetBattlefield():PlaySkillSelectionCameraPath(unit)
	
	local fullName = string.format("UI/Textures/Fighting/%d/%d", 10, 10)
    utility.LoadSpriteFromPath(fullName,self.countdownNumImg)

	
	if ShowFirstFightGuide(self) then
		print("@@@@@@ ShowFirstFightGuide >>> true")
		return
	end
	print("@@@@@@ ShowFirstFightGuide >>> false")
	self:StartCountdown()
end

function FightingSkillSelectionPanel:UpdateView()
    -- 技能目标信息
    local targetInfo = self.activeSkill.luaGameObject:GetTargets()

    -- 目标单位
    local targetUnit = targetInfo:GetTarget(1)

    -- 属于哪一队的
    local members = targetUnit:GetMembers()

    if targetUnit:OnGetSide() == 1 then
        for i = 1, 6 do
            if members[i] ~= nil then
                self.Targets[i]:SetData(members[i])
            else
                self.Targets[i]:Close()
            end
        end
    else
        for i = 1, 6 do
            local realPos = 6 - i + 1
            if members[i] ~= nil then
                self.Targets[realPos]:SetData(members[i])
            else
                self.Targets[realPos]:Close()
            end
        end
    end

end

local function AddTargetToUnits(units, battleUnit)
    if battleUnit ~= nil and battleUnit:IsAlive() then
        units[#units + 1] = battleUnit
    end
end

local function OnSelectionTarget(self, _, targetItem)
    local mode = self.selectionMode

    --print('目标选择模式', mode, self.activeSkill.luaGameObject:GetGameObject().name)
	-- debug_print("手動選擇:", mode)

    -- 全体模式(已测) --
    if mode == kTargetSelectionMode_All then
        self:Close(true)
        self.callback(self.activeSkill, kTargetSelection_Skill)
        return
    end

    local battleUnit = targetItem:GetBattleUnit()
    local battleUnitLocation = battleUnit:GetLocation()
    local targetUnits = battleUnit:GetMembers()

    -- 前后排模式(已测) --
    if mode == kTargetSelectionMode_FrontRowOrBackRow then

        local targets = {}

        local targetType

        -- 前排
        if battleUnitLocation == 1 or battleUnitLocation == 2 or battleUnitLocation == 3 then
            AddTargetToUnits(targets, targetUnits[1])
            AddTargetToUnits(targets, targetUnits[2])
            AddTargetToUnits(targets, targetUnits[3])

            if self.targetSide == 1 then
                targetType = kSkillTarget_FrontrowMembers
            else
                targetType = kSkillTarget_FrontrowFoes
            end

        else
        --后排
            AddTargetToUnits(targets, targetUnits[4])
            AddTargetToUnits(targets, targetUnits[5])
            AddTargetToUnits(targets, targetUnits[6])

            if self.targetSide == 1 then
                targetType = kSkillTarget_BackrowMembers
            else
                targetType = kSkillTarget_BackrowFoes
            end
        end

        local targetInfo = BattleTargetInfo.New(targets, targetType, 0)


        self:Close(true)
        self.callback(self.activeSkill, kTargetSelection_Skill, targetInfo)
        return
    end

    -- TODO 横向连带 --
    if mode == kTargetSelectionMode_Horizontal then
        local targets = {}

        -- 自己肯定先加进去
        AddTargetToUnits(targets, targetUnits[battleUnitLocation])

        if battleUnitLocation == 1 then
            AddTargetToUnits(targets, targetUnits[2])
        elseif battleUnitLocation == 2 then
            AddTargetToUnits(targets, targetUnits[1])
            AddTargetToUnits(targets, targetUnits[3])
        elseif battleUnitLocation == 3 then
            AddTargetToUnits(targets, targetUnits[2])
        elseif battleUnitLocation == 4 then
            AddTargetToUnits(targets, targetUnits[5])
        elseif battleUnitLocation == 5 then
            AddTargetToUnits(targets, targetUnits[4])
            AddTargetToUnits(targets, targetUnits[6])
        elseif battleUnitLocation == 6 then
            AddTargetToUnits(targets, targetUnits[5])
        end

        local targetType
        if self.targetSide == 1 then
            targetType = kSkillTarget_MembersByDirection
        else
            targetType = kSkillTarget_FoesByDirection
        end

        local targetInfo = BattleTargetInfo.New(targets, targetType, kSkillLinearType_Horizontal)

        self:Close(true)
        self.callback(self.activeSkill, kTargetSelection_Skill, targetInfo)
        return
    end

    -- TODO 纵向连带 --
    if mode == kTargetSelectionMode_Vertical then
        local targets = {}

        -- 自己肯定先加进去
        AddTargetToUnits(targets, targetUnits[battleUnitLocation])

        if battleUnitLocation == 1 then
            AddTargetToUnits(targets, targetUnits[4])
        elseif battleUnitLocation == 2 then
            AddTargetToUnits(targets, targetUnits[5])
        elseif battleUnitLocation == 3 then
            AddTargetToUnits(targets, targetUnits[6])
        elseif battleUnitLocation == 4 then
            AddTargetToUnits(targets, targetUnits[1])
        elseif battleUnitLocation == 5 then
            AddTargetToUnits(targets, targetUnits[2])
        elseif battleUnitLocation == 6 then
            AddTargetToUnits(targets, targetUnits[3])
        end

        local targetType
        if self.targetSide == 1 then
            targetType = kSkillTarget_MembersByDirection
        else
            targetType = kSkillTarget_FoesByDirection
        end

        local targetInfo = BattleTargetInfo.New(targets, targetType, kSkillLinearType_Vertical)

        self:Close(true)
        self.callback(self.activeSkill, kTargetSelection_Skill, targetInfo)
        return
    end

    -- TODO 十字连带 --
    if mode == kTargetSelectionMode_Cross then
        local targets = {}

        -- 自己肯定先加进去
        AddTargetToUnits(targets, targetUnits[battleUnitLocation])

        if battleUnitLocation == 1 then
            AddTargetToUnits(targets, targetUnits[2])
            AddTargetToUnits(targets, targetUnits[4])
        elseif battleUnitLocation == 2 then
            AddTargetToUnits(targets, targetUnits[1])
            AddTargetToUnits(targets, targetUnits[3])
            AddTargetToUnits(targets, targetUnits[5])
        elseif battleUnitLocation == 3 then
            AddTargetToUnits(targets, targetUnits[2])
            AddTargetToUnits(targets, targetUnits[6])
        elseif battleUnitLocation == 4 then
            AddTargetToUnits(targets, targetUnits[1])
            AddTargetToUnits(targets, targetUnits[5])
        elseif battleUnitLocation == 5 then
            AddTargetToUnits(targets, targetUnits[2])
            AddTargetToUnits(targets, targetUnits[4])
            AddTargetToUnits(targets, targetUnits[6])
        elseif battleUnitLocation == 6 then
            AddTargetToUnits(targets, targetUnits[3])
            AddTargetToUnits(targets, targetUnits[5])
        end

        local targetType
        if self.targetSide == 1 then
            targetType = kSkillTarget_MembersByDirection
        else
            targetType = kSkillTarget_FoesByDirection
        end

        local targetInfo = BattleTargetInfo.New(targets, targetType, kSkillLinearType_Cross)

        self:Close(true)
        self.callback(self.activeSkill, kTargetSelection_Skill, targetInfo)
        return
    end

    -- TODO 多人选择 --
    if mode == kTargetSelectionMode_Number then
        targetItem:SetSelected(true)
        self.currentSelectedNumbers = self.currentSelectedNumbers + 1

        local aliveCount = 0
        for i = 1, #self.Targets do
            if self.Targets[i]:IsAlive() then
                aliveCount = aliveCount + 1
            end
        end

        self.maxSelectedNumber = math.min(aliveCount, self.maxSelectedNumber)

        if self.currentSelectedNumbers >= self.maxSelectedNumber then

            local selectedUnits = {}
            for i = 1, #self.Targets do
                if self.Targets[i]:IsSelected() then
                    AddTargetToUnits(selectedUnits, self.Targets[i]:GetBattleUnit())
                end
            end

            print(#selectedUnits, self.maxSelectedNumber, self.currentSelectedNumbers)

            local targetType
            if self.targetSide == 1 then
                targetType = kSkillTarget_RandomMembers
            else
                targetType = kSkillTarget_RandomFoes
            end

            local targetInfo = BattleTargetInfo.New(selectedUnits, targetType, self.maxSelectedNumber)

            self:Close(true)
            self.callback(self.activeSkill, kTargetSelection_Skill, targetInfo)
        end
        return
    end

end

function FightingSkillSelectionPanel:InitControls()
    local transform = self:GetUnityTransform()

    -- 提示文本
    self.tipLabel = transform:Find("Tip/Description"):GetComponent(typeof(UnityEngine.UI.Text))
    self.tipLabel.text = "请选择目标"

    -- 倒数计时
    self.countdownNumImg = transform:Find("Progress/CountdownNum"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 普攻按钮
    self.AttackButton = transform:Find("Target/AttackButton"):GetComponent(typeof(UnityEngine.UI.Button))


    local FightingTargetClass = require "GUI.Battle.FightingTarget"
    -- targets
    self.Targets = {}
    self.Targets[3] = FightingTargetClass.New(transform:Find("Target/FightingTarget01"))
    self.Targets[2] = FightingTargetClass.New(transform:Find("Target/FightingTarget02"))
    self.Targets[1] = FightingTargetClass.New(transform:Find("Target/FightingTarget03"))
    self.Targets[6] = FightingTargetClass.New(transform:Find("Target/FightingTarget04"))
    self.Targets[5] = FightingTargetClass.New(transform:Find("Target/FightingTarget05"))
    self.Targets[4] = FightingTargetClass.New(transform:Find("Target/FightingTarget06"))

    for i = 1, #self.Targets do
        self.Targets[i]:SetCallback(self, OnSelectionTarget)
    end
end

function FightingSkillSelectionPanel:Close()
--    self.tipLabel.text = ""

    self:UnregisterEvents()

    for i = 1, #self.Targets do
        self.Targets[i]:Close()
    end

    if self.roCountdown ~= nil then
        coroutine.stop(self.roCountdown)
        self.roCountdown = nil
    end

    if self.activeSkill ~= nil then
        self.activeSkill.luaGameObject:GetBattlefield():ResetSkillSelectionCameraPath()
    end


    local gameObject = self:GetUnityGameObject()
    gameObject:SetActive(false)
end

local function OnCountdown(self)
    local AtlasesLoader = require "Utils.AtlasesLoader"

    local time = 10.0

    local lastCount = 99

    while(time > 0)
    do
        local count = math.ceil(time)
        -- 没有0的 --
        if count > 0 and lastCount ~= count then
			local fullName = string.format("UI/Textures/Fighting/%d/%d", count, count)
			utility.LoadSpriteFromPath(fullName,self.countdownNumImg)
            lastCount = count
        end

        time = math.max(0, time - Time.unscaledDeltaTime)
        coroutine.step(1)
    end

    self.roCountdown = nil

    -- 完成 自动完成 普攻 --
    self:OnAttackButtonClicked()
end

function FightingSkillSelectionPanel:StartCountdown()
    self.roCountdown = self:StartCoroutine(OnCountdown)
end

function FightingSkillSelectionPanel:RegisterEvents()
    --按钮事件注册
    self.__event_button_AttackButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAttackButtonClicked, self)
    self.AttackButton.onClick:AddListener(self.__event_button_AttackButtonClicked__)
	
	
	
	self:RegisterEvent(messageGuids.PlayerGuideEventDone, OnGuideEventDone, nil)
end

function FightingSkillSelectionPanel:UnregisterEvents()
    if self.__event_button_AttackButtonClicked__ then
        self.AttackButton.onClick:RemoveListener(self.__event_button_AttackButtonClicked__)
        self.__event_button_AttackButtonClicked__ = nil
    end
	
	self:UnregisterEvent(messageGuids.PlayerGuideEventDone, OnGuideEventDone, nil)
end


-- 普通攻击
function FightingSkillSelectionPanel:OnAttackButtonClicked()
    self:Close(true)
    self.callback(self.activeSkill, kTargetSelection_Attack)
end

return FightingSkillSelectionPanel