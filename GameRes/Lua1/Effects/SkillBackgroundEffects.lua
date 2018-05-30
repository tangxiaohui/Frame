--
-- User: fbmly
-- Date: 1/4/17
-- Time: 3:09 PM
--

require "Object.LuaObject"
local unityUtils = require "Utils.Unity"
local utility = require "Utils.Utility"

SkillBackgroundEffects = Class(LuaObject)

local effectPrefabs =
{
    [1] = 'Effect/Effects/Effect_Scene/Scenes_beijing_hong',
    [2] = 'Effect/Effects/Effect_Scene/Scenes_beijing_lan'
}

local effectConfigs = {}
----effectConfigs[1002] = 1 -- 鼬
--effectConfigs[1107] = 1 -- 火龙纳兹
--effectConfigs[1029] = 1 -- 杀老师
--effectConfigs[1048] = 1 -- 乔巴
--effectConfigs[1041] = 1 -- 黑月牙
--effectConfigs[1073] = 2 -- 银时
--effectConfigs[1063] = 1 -- 孙悟空
--effectConfigs[1064] = 1 -- 地缚喵
----effectConfigs[1105] = 1 -- 山治
--effectConfigs[1124] = 1


function SkillBackgroundEffects:Ctor()
    self.effectObjects = {}
    self.root = unityUtils:FindGameObject('SkillBackgroundRoot')
    if not self.root then
        error('SkillBackgroundRoot 找不到!')
    end
end

local function GetOrCreateEffect(self, id)
    -- 该人物不需要背景
    if not effectConfigs[id] then
        return nil
    end

    local prefabId = effectConfigs[id]
    -- 该人物没有对应的背景特效id
    if not effectPrefabs[prefabId] then
        return nil
    end

    -- 如果存在则返回
    if self.effectObjects[prefabId] ~= nil then
        return self.effectObjects[prefabId]
    end

    -- 没找到则创建新的
    local Object = UnityEngine.Object
    --local Resources = UnityEngine.Resources
    local gameObject = Object.Instantiate(utility.LoadResourceSync(effectPrefabs[prefabId], typeof(UnityEngine.GameObject)))
    gameObject.transform:SetParent(self.root.transform)
    gameObject.transform.localScale = Vector3.New(1, 1, 1)
    gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.effectObjects[prefabId] = gameObject
    return gameObject
end

function SkillBackgroundEffects:SetActive(unit, active)
    local playerId = unit:GetId()
    local gameObject = GetOrCreateEffect(self, playerId)
    if gameObject ~= nil then
        local transform = unit:GetGameObject().transform
        local pos = transform.position
        local rot = transform.rotation
        gameObject.transform.position = pos
        gameObject.transform.rotation = rot
        gameObject:SetActive(active)
    end
end



