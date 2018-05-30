
require "Object.LuaGameObject"
require "Collection.OrderedDictionary"
local utility = require "Utils.Utility"

local Shield = Class(LuaGameObject)

function Shield:Ctor(id, team)
    self.data = require "StaticData.Shield":GetData(id)
    self.battleTeam = team
    self.units = OrderedDictionary.New()
    self.passedRounds = 0
    self.maxHp = 0
    self.curHp = 0
end

local function GetBattlefield(self)
    return self.battleTeam:GetParent()
end

local function GetAverageLevel(self)
    local count = self.units:Count()
    if count <= 0 then
        return 0
    end

    local sum = 0
    for i = 1, count do
        local currentUnit = self.units:GetEntryByIndex(i)
        if currentUnit ~= nil then
            sum = sum + currentUnit:GetLevel()
        end
    end
    return sum / count
end

local function OnPowerChanged(self)
    local maxHp = self.data:GetBasicHp() + GetAverageLevel(self) * self.data:GetHpRate()
    self.maxHp = math.floor(maxHp)
    self.curHp = self.maxHp
end

local function IsRoundDone(self)
    local rounds = self.data:GetRounds()
    return rounds > 0 and self.passedRounds >= rounds
end

local function IsUnitDead(self)
    return self.curHp <= 0
end

function Shield:IsImmuneToState()
    return false
end

function Shield:GetCurHp()
    return self.curHp
end

function Shield:GetMaxHp()
    return self.maxHp
end

function Shield:ToString()
    return string.format(
        "id: %d, basicHp: %d, hpRate: %d, rounds: %d, resPath: %s, attacked effect path: %s",
        self.data:GetId(),
        self.data:GetBasicHp(),
        self.data:GetHpRate(),
        self.data:GetRounds(),
        self.data:GetResPath(),
        self.data:GetAttackedEffectPath()
    )
end

-- 播放飘字效果
function Shield:PlayTextEffect(loseHp, isCrit)
	local uiManager = utility.GetGame():GetUIManager()

	local prefab

	if isCrit then
		prefab = uiManager:GetCritEffectTextObject()
	else
		prefab = uiManager:GetEffectTextObject()
	end

	self:ShowEffect(prefab, EffectTextItem,
			function(effectComponent)
                effectComponent.target = self.gameObject.transform
                effectComponent.offset = Vector2(0, 100)
				effectComponent:SetValue(loseHp)
				effectComponent:Play(1)
	end)
end

-- 处理显示效果的创建
function Shield:ShowEffect(prefab, componentType, handler)
	
	local battlefield = GetBattlefield(self)

	-- 当前的世界摄像机对象
	local cameraObject = battlefield:GetCurrentCamera()
	local worldCamera = cameraObject:GetComponent(typeof(UnityEngine.Camera))
	
	-- 获取UI摄像机
	local uiManager = utility.GetGame():GetUIManager()
	local canvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()
	local uiCamera = uiManager:GetBattleUICanvas():GetCamera()
	
	-- 实例化(这个地方的接口需要变更)
	local instancedObject = UnityEngine.GameObject.Instantiate(prefab)
	instancedObject:SetActive(true)
	
	-- 获取组件
	local effectComponent = instancedObject:GetComponent(typeof(componentType))
	
	-- 缓存transform
	local trans = effectComponent.cachedTrans

	-- 设置缩放
	trans:SetParent(canvasTransform, true)
	trans.localPosition = Vector3(0,0,0)
	trans.localRotation = Quaternion.identity
	trans.localScale = Vector3(1,1,1)
	
	effectComponent.worldCamera = worldCamera
	effectComponent.uiCamera = uiCamera
	
	-- 调用处理函数把组件传给上层去处理
	handler(effectComponent)
end


local function LoseHp(self, damage, isCrit)
    local curHp = self.curHp - damage
    self.curHp = self.curHp - damage
    if self.curHp < 0 then
        self.curHp = 0
    end
    self:PlayTextEffect(damage, isCrit)
end

function Shield:Append(unit)
    if unit == nil then
        return
    end

    if not self.units:Contains(unit) then
        self.units:Add(unit, unit)
        OnPowerChanged(self)
    end
end

function Shield:Show(transform)
    local path = self.data:GetResPath()
    utility.LoadResourceAsync(path, typeof(UnityEngine.GameObject), function(prefab)
        local go = UnityEngine.Object.Instantiate(prefab)
        local trans = go.transform
        trans:SetParent(transform, true)
        trans.localPosition = Vector3(0,0,0)
        trans.localRotation = Quaternion.identity
        trans.localScale = Vector3(1,1,1)
        self.gameObject = go
    end)
end

function Shield:Hide()
    if self.gameObject ~= nil then
        UnityEngine.GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end
end

function Shield:IsBroken()
    return IsRoundDone(self) or IsUnitDead(self)
end

function Shield:NewRound()
    self.passedRounds = self.passedRounds + 1
end

-- 相关事件
function Shield:OnReceiveDamage(damageSrc, damage, isCritDamage, isLastAction)
    LoseHp(self, damage, isCritDamage)
    damageSrc.luaGameObject:NotifiedReset(self)
end

-- 相关属性
function Shield:GetGameObject()
    return self.gameObject
end

function Shield:IsShield()
    return true
end

function Shield:IsAlive()
    return true
end

function Shield:HasGodState()
    return false
end

function Shield:GetAvoidRate()
    return 0
end

function Shield:GetDecritRate()
    return 0
end

function Shield:GetDp()
    return 0
end

function Shield:GetDamageReductionRate()
    return 100
end

return Shield
