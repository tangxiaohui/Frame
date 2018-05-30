--
-- User: fenghao
-- Date: 11/07/2017
-- Time: 5:52 PM
--

local NodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

local BattleUISkillAnimationEffectNode = Class(NodeClass)

local function GetParentTransform(self)
    if self.parentTransform == nil then
        local uiManager = require "Utils.Utility".GetUIManager()
        local canvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()
        self.parentTransform = canvasTransform:Find("UIAnimationGroup")
    end
    return self.parentTransform
end

local function Reparent(self, gameObject)
    local parentTransform = GetParentTransform(self)
    local transform = gameObject.transform
    transform:SetParent(parentTransform, true)
    transform.localScale = Vector3(1, 1, 1)
    transform.localPosition = Vector3(0, 0, 0)
    transform.localRotation = Quaternion.identity
end

local function ActiveAnimationImpl(animator, active)
    if active then
        animator:Play("Start", 0, 0)
    else
        animator:Play("Empty", 0, 0)
    end
end

local function OnLoadGameObject(self, gameObject, skillID, active, reparent)
    local animator = gameObject:GetComponent(typeof(UnityEngine.Animator))
    utility.ASSERT(animator ~= nil, string.format("UI技能动画资源 必须包含Animator组件, skill id : %d", skillID))
    if reparent then Reparent(self, gameObject) end
    self.animations[skillID] = animator
    return ActiveAnimationImpl(animator, active)
end

local function OnActivateUISkillAnimation(self, skillID, active)
    local animator = self.animations[skillID]
    if animator ~= nil then
        return ActiveAnimationImpl(animator, active)
    end
	
	if not active then
		return
	end

    local skillData = require "StaticData.Skill":GetData(skillID)
    local uiAnimationID = skillData:GetUiAnimationResID()

    if uiAnimationID > 0 then
        local path = require "StaticData.ResPath":GetData(uiAnimationID):GetPath()
		
        -- 如果能找得到 重新绑定! --
        local pathSections = utility.Split(path, "/")
        local lastName = pathSections[#pathSections]
        
		
        local parentTransform = GetParentTransform(self)
        local child = parentTransform:Find(lastName)
        if child ~= nil then
            return OnLoadGameObject(self, child.gameObject, skillID, active, false)
        end

        -- 加载完毕 --
        utility.LoadNewPureGameObjectAsync(path, function(gameObject)
			if gameObject == nil then
				return
			end
			
            gameObject.name = lastName
            return OnLoadGameObject(self, gameObject, skillID, active, true)
        end)
    end
end

function BattleUISkillAnimationEffectNode:Ctor(owner)
    self.owner = owner -- BattleNode
    self.animations = {}
end

function BattleUISkillAnimationEffectNode:OnCleanup()
    BattleUISkillAnimationEffectNode.base.OnCleanup(self)
    utility.DestroyChildrenInTransform(GetParentTransform(self))
end

function BattleUISkillAnimationEffectNode:OnEnter()
	BattleUISkillAnimationEffectNode.base.OnEnter(self)
	self:RegisterEvent(messageGuids.BattleActivateUISkillAnimation, OnActivateUISkillAnimation, nil)
end

function BattleUISkillAnimationEffectNode:OnExit()
	BattleUISkillAnimationEffectNode.base.OnExit(self)
	self:UnregisterEvent(messageGuids.BattleActivateUISkillAnimation, OnActivateUISkillAnimation, nil)
end

return BattleUISkillAnimationEffectNode
