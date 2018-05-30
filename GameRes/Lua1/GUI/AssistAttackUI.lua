require "Object.LuaObject"
local unityUtils = require "Utils.Unity"
local utility = require "Utils.Utility"


local animationPrefabNames = {}
animationPrefabNames[1107] = 'Prefabs/AssistAttacks/Huolong'
animationPrefabNames[1029] = 'Prefabs/AssistAttacks/Shalaoshi'
animationPrefabNames[1048] = 'Prefabs/AssistAttacks/Qiaoba'
animationPrefabNames[1041] = 'Prefabs/AssistAttacks/Heiyueya'
animationPrefabNames[1073] = 'Prefabs/AssistAttacks/Yinshi'
animationPrefabNames[1063] = 'Prefabs/AssistAttacks/Sunwukong'


local animatorDuration = 1

local StartAnimationName = 'Start'
local InitAnimation = 'Empty'

AssistAttackUI = Class(LuaObject)

local function GetOrCreateValidInstantiateObject(self, id)
    -- 没有配置
    if not animationPrefabNames[id] then
        return nil
    end

    -- 初始化表
    if not self.animatorObjects[id] then
        self.animatorObjects[id] = {}
    end

    -- 搜索有效的 --
    for i = 1, #self.animatorObjects do
        local go = self.animatorObjects[i]
        -- 只找没有激活的
        if not go.activeSelf then
            go:SetActive(true)
            return go
        end
    end

    -- 如果没有找到, 就实例化新的 --
    local Object = UnityEngine.Object
    local gameObject = Object.Instantiate(utility.LoadResourceSync(animationPrefabNames[id], typeof(UnityEngine.GameObject)))
    gameObject.transform:SetParent(self.uiRoot.transform)
    gameObject.transform.localScale = Vector3.New(1, 1, 1)
    gameObject.transform.offsetMin = Vector2.New(0, 0)
    gameObject.transform.offsetMax = Vector2.New(0, 0)
    gameObject:SetActive(true)
    -- 加入到表中 --
    self.animatorObjects[#self.animatorObjects + 1] = gameObject

    return gameObject
end

function AssistAttackUI:Ctor()
    local uiManager = require "Utils.Utility".GetUIManager()
    local battleCanvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()


    self.animatorObjects = {}
    self.uiRoot = battleCanvasTransform:Find('AssistAttackUI')
    if not self.uiRoot then
        error('ui root找不到')
    end
end

local function DelayPlay(gameObject, animator, delay)
    --gameObject:SetActive(true)
    coroutine.wait(delay)
    animator:Play(StartAnimationName)
    coroutine.wait(animatorDuration)
    animator:Play(InitAnimation)
    gameObject:SetActive(false)
end

function AssistAttackUI:Play(id, delay)
    -- 先找一个id所对应的 实例对象!
    local gameObject = GetOrCreateValidInstantiateObject(self, id)
    if gameObject ~= nil then
        local animator = gameObject:GetComponent(typeof(UnityEngine.Animator))
        if animator ~= nil then
            coroutine.start(DelayPlay, gameObject, animator, delay)
        end
    end
end

--function AssistAttackUI:Ctor()
--    animatorGroup[1107] = FindAndInvisibleObject('UIGroup/Canvas/AssistAttackUI/Huolong')    -- 火龙纳兹
--    animatorGroup[1029] = FindAndInvisibleObject('UIGroup/Canvas/AssistAttackUI/Shalaoshi')  -- 杀老师
--    animatorGroup[1048] = FindAndInvisibleObject('UIGroup/Canvas/AssistAttackUI/Qiaoba')     -- 乔巴
--    animatorGroup[1041] = FindAndInvisibleObject('UIGroup/Canvas/AssistAttackUI/Heiyueya')   -- 黑月牙
--    animatorGroup[1073] = FindAndInvisibleObject('UIGroup/Canvas/AssistAttackUI/Yinshi')     -- 银时
--    animatorGroup[1063] = FindAndInvisibleObject('UIGroup/Canvas/AssistAttackUI/Sunwukong')     -- 孙悟空
--end

--local function DelayPlay(gameObject, animator, delay)
--    gameObject:SetActive(true)
--    coroutine.wait(delay)
--    animator:Play(StartAnimationName)
--    coroutine.wait(animatorDuration)
--    animator:Play(InitAnimation)
--    gameObject:SetActive(false)
--end
--
--function AssistAttackUI:Play(id, delay)
--    if animatorGroup[id] ~= nil then
--        local gameObject = animatorGroup[id]
--        if not gameObject.activeSelf then
--            local animator = gameObject:GetComponent(typeof(UnityEngine.Animator))
--            if animator ~= nil then
--                coroutine.start(DelayPlay, gameObject, animator, delay)
--            end
--        end
--    end
--end