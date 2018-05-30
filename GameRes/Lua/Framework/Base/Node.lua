require "Object.LuaObject"
local utility = require "Utils.Utility"

local Node = Class(LuaObject)

function Node:Ctor()
    self.__internal__ =  {}

    self.__internal__.parentNode = nil               -- 是否有父节点
    self.__internal__.unityGameObject = nil          -- 是否创建了 unity gameObject
    self.__internal__.unityTransform = nil           -- 缓存的 gameobject的 Transform
    self.__internal__.isRunning = false              -- 是否进入了Enter
    self.__internal__.isTransitionFinished = false   -- 动画是否过渡完毕
    self.__internal__.children = {}                  -- 所有的子node
    self.__internal__.hasEntered = false             -- 是否已经Enter过
    self.__internal__.hasComponentReady = false      -- 是否已经绑定过控件

    require "Collection.OrderedDictionary"
    self.__internal__.allCoroutines = OrderedDictionary.New()


    -- 缓存 schedule --
    self.__internal_game__ = utility.GetGame()
    self.__internal_localDataManager = self.__internal_game__:GetLocalDataManager()
    self.__internal_windowManager = self.__internal_game__:GetWindowManager()
    self.__internal_dataCacheManager = self.__internal_game__:GetDataCacheManager()
    self.__internal_audioManager = self.__internal_game__:GetAudioManager()
    self.__internal_videoManager = self.__internal_game__:GetVideoPlayerManager()
    self.__internal_eventManager = self.__internal_game__:GetEventManager()
    self.__internal_uiManager__ = self.__internal_game__:GetUIManager()
    self.__internal_timeManager = self.__internal_game__:GetTimeManager()
    self.__internal_schedule__ = self.__internal_game__:GetScheduleManager()
    self.__internal_systemGuideManager__ = self.__internal_game__:GetSystemGuideManager()
    self.__internal_guideManager__ = self.__internal_game__:GetGuideManager()
    self.__internal_sdkManager__ = self.__internal_game__:GetSDKManager()
end

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function GetAllCoroutines(self)
    return self.__internal__.allCoroutines
end

local function GetChildren(self)
    return self.__internal__.children
end

local function SetParentNode(self, parentNode)
    self.__internal__.parentNode = parentNode
end

local function SetRunning(self, running)
    self.__internal__.isRunning = running
end

-----------------------------------------------------------------------
--- 获取全局参数的函数
-----------------------------------------------------------------------
function Node:GetLocalDataManager()
    return self.__internal_localDataManager
end

function Node:GetSDKManager()
    return self.__internal_sdkManager__
end

function Node:GetCachedData(name)
    return self.__internal_dataCacheManager:GetData(name)
end

function Node:GetWindowManager()
    return self.__internal_windowManager
end

function Node:GetTimeManager()
    return self.__internal_timeManager
end

function Node:GetGuideManager()
    return self.__internal_guideManager__
end

function Node:GetSystemGuideManager()
    return self.__internal_systemGuideManager__
end

function Node:GetGame()
    return self.__internal_game__
end

function Node:GetAudioManager()
    return self.__internal_audioManager
end

function Node:GetVideoPlayerManager()
    return self.__internal_videoManager
end

function Node:GetUIManager()
    return self.__internal_uiManager__
end

function Node:BringToFront()
    local transform = self:GetUnityTransform()
    if transform then
        transform:SetAsLastSibling()
    end
end

function Node:BringToBack()
    local transform = self:GetUnityTransform()
    if transform then
        transform:SetAsFirstSibling()
    end
end

function Node:SetSiblingIndex(pos)
    local transform = self:GetUnityTransform()
    transform:SetSiblingIndex(pos - 1)
end

-- 获取 transform
function Node:GetParentTransform()
    -- 首先看自己有没有挂点
    local parentTransform

    -- 如果没有就找父Node
    local parentNode = self:GetParent()
    while(parentNode ~= nil) do
        -- 找父 标记的 挂点
        local hangingPoint = parentNode:GetMainHangingPoint()

        -- 如果父挂点有效
        if hangingPoint ~= nil then
            -- 就用这个挂点
            parentTransform = hangingPoint
            break
        end
        -- 没找到就继续向父找!
        parentNode = parentNode:GetParent()
    end

    -- 如果始终没找到
    if not parentTransform then
        -- 使用 root 挂点 --
        parentTransform = self:GetRootHangingPoint()
    end

    return parentTransform
end

-- 获取 主挂点 (可重载),  这个是子node要挂的地方!!
function Node:GetMainHangingPoint()
    if self:HasUnityGameObject() then
        return self:GetUnityTransform()
    end
    return nil
end

function Node:GetRootHangingPoint()
    return nil
end

-- 获取 parent
function Node:GetParent()
    return self.__internal__.parentNode
end

-- 是否准备好
function Node:IsSelfReady(ignoreParent)
    local transform = self:GetUnityTransform()
    if transform ~= nil then
        if not ignoreParent then
            return transform.parent ~= nil
        end
        return true
    end
    return false
end

function Node:HasComponentReady()
    if not self:HasSelfComponentReady() then
        return false
    end

    local children = GetChildren(self)
    for i = 1, #children do
        if not children[i]:HasComponentReady() then
            return false
        end
    end

    return true
end

function Node:HasSelfComponentReady()
    return self.__internal__.hasComponentReady
end

function Node:IsReady(ignoreParent)
    if not self:IsSelfReady(ignoreParent) then
        return false
    end

    local children = GetChildren(self)
    for i = 1, #children do
        if not children[i]:IsReady(ignoreParent) then
            return false
        end
    end

    return true
end

-- 是否创建了 unity gameObject (prefab)
function Node:HasUnityGameObject()
    return self.__internal__.unityGameObject ~= nil
end

-- 获取 gameObject
function Node:GetUnityGameObject()
    return self.__internal__.unityGameObject
end

-- 获取 transform
function Node:GetUnityTransform()
    return self.__internal__.unityTransform
end

-- 是否进入了 Enter
function Node:IsRunning()
    return self.__internal__.isRunning
end

-- 动画是否过渡完毕
function Node:IsTransitionFinished()
    return self.__internal__.isTransitionFinished
end

function Node:IsTransition()
    return false
end

-----------------------------------------------------------------------
--- Protoected 事件
-----------------------------------------------------------------------
function Node:OnInit()
end

function Node:OnPause()
    self:InactiveComponent()
end

function Node:OnResume()
    self:ActiveComponent()

    local guideManager = self:GetGuideManager()
    if guideManager:IsWaiting() and guideManager:IsLoadedUi(self:GetUnityGameObject().name) then
        guideManager:ShowGuidance()
    end
end

function Node:OnAttach()
end

function Node:OnDetach()
end

function Node:OnBeforeTransformParentChanged()
end

function Node:OnTransformParentChanged()
end

function Node:OnComponentReady()
end
-----------------------------------------------------------------------
--- Public 事件
-----------------------------------------------------------------------
function Node:OnEnter()
    self.__internal__.isTransitionFinished = false

    if not self.__internal__.hasEntered then
        -- 第一次 Enter 时 调用!
        self:OnInit()
    end

    -- 如果绑定了控件则进入
    if self:HasUnityGameObject() then
        if not self.__internal__.hasComponentReady then
            self.__internal__.hasComponentReady = true
            self:OnComponentReady()
        end
        self:OnResume()
    end

    local children = GetChildren(self)
    for i = 1, #children do
        children[i]:OnEnter()
    end

    SetRunning(self, true)

    self.__internal__.hasEntered = true
end

function Node:OnEnterTransitionDidFinish()
    self.__internal__.isTransitionFinished = true

    local children = GetChildren(self)
    for i = 1, #children do
        children[i]:OnEnterTransitionDidFinish()
    end
end

function Node:OnExit()
    if self:HasUnityGameObject() then
        self:OnPause()
    end

    self:UnscheduleAllCallbacks()
    self:UnregisterAllEvents()
    self:StopAllCoroutines()

    SetRunning(self, false)

    local children = GetChildren(self)
    for i = 1, #children do
        children[i]:OnExit()
    end
end

function Node:OnExitTransitionDidStart()
    local children = GetChildren(self)
    for i = 1, #children do
        children[i]:OnExitTransitionDidStart()
    end
end

-- >>> 垃圾回收 <<< --
local __garbage_count__ = 0     -- 当前计数
local COLLECTION_GARBAGE_COUNT = 3  -- 达到多少次进行回收 --

local function ForceCollectionGarbage()
    utility.CollectionGarbage()
    utility.PrintTotalMemoryInUse()
    __garbage_count__ = 0
end

local function CollectionGarbage(self)
    if self:GetParent() == nil then
        __garbage_count__ = __garbage_count__ + 1
        if __garbage_count__ >= COLLECTION_GARBAGE_COUNT then
            ForceCollectionGarbage()
            return true
        end
    end
    return false
end

function Node:ForceCollectionGarbage()
    ForceCollectionGarbage()
end

function Node:OnCleanup()
    local children = GetChildren(self)
    for i = 1, #children do
        children[i]:OnCleanup()
    end
    self:CleanupComponent()
    utility.ClearArrayTableContent(children)
    self.__internal__.hasEntered = false
    return CollectionGarbage(self)
end

local function SetSiblingIndex(node, pos)
    local transform = node:GetUnityTransform()
    transform:SetSiblingIndex(pos - 1)
end

function Node:Sort(sortFunction, ignoreParent)
    if not self:IsReady(ignoreParent) then
        error("排序错误, 并没有全部布局好, 不能排序")
        return
    end

    local children = GetChildren(self)
    table.sort(children, sortFunction)

    for i = 1, #children do
        SetSiblingIndex(children[i], i)
    end
end

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function ReparentChild(self, child)
    if child:GetParent() ~= nil then
        -- 将自己从原parent移除
        child:GetParent():DetachChild(child)
    end

    -- 重新赋值
    local children = GetChildren(self)
    children[#children + 1] = child

    SetParentNode(child, self)
    child:OnAttach()

    -- 如果已经Running了, 需要再次running
    if self:IsRunning() then
        -- 放置多次调用 Enter
        if not child:IsRunning() then
            child:OnEnter()
        end

        -- 放置调用多次 Transition
        if self:IsTransitionFinished() then
            if not child:IsTransitionFinished() then
                child:OnEnterTransitionDidFinish()
            end
        end
    end

    -- 放在child Enter之后 才连接  是如果在Enter里创建 绑定了组件 这里也应该自动绑定parent transform//
    -- TODO
    -- self:LinkComponent()
end

local function IsGrandfather(self, child)
    local item = self:GetParent()
    while(item ~= nil)
    do
        -- 要加的子node 竟然是我的爸爸或爷爷 那不能加
        if item == child then
            return true
        end
        item = item:GetParent()
    end
    return false
end

-----------------------------------------------------------------------
--- 添加函数
-----------------------------------------------------------------------
-- # 添加子node
function Node:AddChild(child)
    -- child为nil 不能加入
    if child == nil then
        error("argument 'child' is nil")
    end

    -- child 为自己不能加入
    if child == self then
        error("the child equals to this. It can't be added itself")
    end

    -- child已经是自己的子, 不重复加
    if child:GetParent() == self then
        print("the child already is the children. It can't be added again!")
        return
    end

    if IsGrandfather(self, child) then
        error("the child is my father or grandfather, you can't do this")
    end

    -- 加入child
    ReparentChild(self, child)
end

-----------------------------------------------------------------------
--- 移除函数
-----------------------------------------------------------------------
local function RemoveChildByIndex_Internal(self, index)
    local children = GetChildren(self)
    local child = children[index]
    if child ~= nil then
        -- # 移除
        children[index] = children[#children]
        children[#children] = nil
        return child
    end
    return nil
end

local function RemoveChildByIndex(self, index, cleanup)
    local child = RemoveChildByIndex_Internal(self, index)
    if child ~= nil then
        child:OnDetach()
        SetParentNode(child, nil)

        if self:IsRunning() then
            if child:IsRunning() then
                child:OnExitTransitionDidStart()
                child:OnExit()
            end
        end

        if cleanup then
            child:OnCleanup()
        end
    end
end

local function GetChildIndex(self, child)
    local children = GetChildren(self)
    for i = 1, #children do
        if children[i] == child then
            return i
        end
    end
    return -1
end

local function DetachChildByIndex(self, index)
    local removedChild = RemoveChildByIndex(self, index)
    if removedChild ~= nil then
        removedChild:OnDetach()
        SetParentNode(removedChild, nil)
    end
end

-- # 移除子node
function Node:RemoveChild(child, cleanup)
    -- 首先自己不能为nil.
    if child == nil then
        error("argument 'child' is nil")
    end

    if child:GetParent() == self then
        local index = GetChildIndex(self, child)
        if index ~= -1 then
            RemoveChildByIndex(self, index, cleanup)
        end
    end
end

-- # 移除所有的子node
function Node:RemoveAllChildren(cleanup)
    local count = #GetChildren(self)
    if count > 0 then
        for i = count, 1, -1 do
            RemoveChildByIndex(self, i, cleanup)
        end
    end
end

-- # 解除关联
function Node:DetachChild(child)
    -- 首先自己不能为nil.
    if child == nil then
        error("argument 'child' is nil")
    end

    if child:GetParent() == self then
        local index = GetChildIndex(self, child)
        if index ~= -1 then
            DetachChildByIndex(self, index)
        end
    end
end

function Node:BindComponent(gameObject, isAutoLink)
    if self:HasUnityGameObject() then
        error('已经绑定 gameobject 不能重复加载')
    end

    self.__internal__.unityGameObject = gameObject
    self.__internal__.unityTransform = gameObject.transform

    if isAutoLink == nil then
        isAutoLink = true
    end

    if isAutoLink then
        self:LinkComponent()
    end

    if self:IsRunning() then
        self.__internal__.hasComponentReady = true
        self:OnComponentReady()
        self:OnResume()
    end
end

function Node:UnbindComponent()
    if self:HasUnityGameObject() then
        self.__internal__.unityGameObject = nil
        self.__internal__.unityTransform = nil
        self.__internal__.hasComponentReady = false
    end
end

-- # Link
local function ResetAllCanvases(transform)
    local canvases = transform:GetComponentsInChildren(typeof(UnityEngine.Canvas))
    local count = canvases.Length
    for i = 0, count - 1 do
        local transform = canvases[i].transform
        if transform ~= nil then
            transform.anchorMin = Vector2(0, 0)
            transform.anchorMax = Vector2(1, 1)
            transform.offsetMin = Vector2(0, 0)
            transform.offsetMax = Vector2(0, 0)
        end
    end
end

function Node:LinkComponent(parentTransform, ignoreAnchorOffset)
    if self:HasUnityGameObject() then
        local transform = self:GetUnityTransform()
        local hangingPoint = parentTransform or self:GetParentTransform()
        if hangingPoint ~= nil then
            self:OnBeforeTransformParentChanged()

            transform:SetParent(hangingPoint, true)
            transform.localScale = Vector3(1, 1, 1)
            transform.localPosition = Vector3(0, 0, 0)
            transform.localRotation = Quaternion.identity

            if not ignoreAnchorOffset then
                transform.offsetMin = Vector2(0, 0)
                transform.offsetMax = Vector2(0, 0)
            end

            ResetAllCanvases(transform)

            self:OnTransformParentChanged()
        end
    end
end

function Node:UnlinkComponent(newParentTransform)
    if self:HasUnityGameObject() then
        local transform = self:GetUnityTransform()
        self:OnBeforeTransformParentChanged(true)
        transform:SetParent(newParentTransform, true)
        self:OnTransformParentChanged()
    end
end

function Node:CleanupComponent()
    local gameObject = self:GetUnityGameObject()
    if gameObject ~= nil then
        self:UnbindComponent()
        UnityEngine.Object.Destroy(gameObject)
    end
end

-- # TODO
function Node:ActiveComponent()
    local gameObject = self:GetUnityGameObject()
    if gameObject ~= nil then
        gameObject:SetActive(true)
    end
end

function Node:InactiveComponent()
    local gameObject = self:GetUnityGameObject()
    if gameObject ~= nil then
        gameObject:SetActive(false)
    end
end


-- ## Mono相关调度函数注册 ##
-- OnSceneLoaded
function Node:ScheduleOnSceneLoaded(func)
    self.__internal_schedule__:RegisterOnSceneLoaded(self, func)
end

function Node:UnscheduleOnSceneLoaded()
    self.__internal_schedule__:UnregisterOnSceneLoaded(self)
end

-- # Update
function Node:ScheduleUpdate(func)
    self.__internal_schedule__:RegisterUpdate(self, func)

end
function Node:UnscheduleUpdate()
    self.__internal_schedule__:UnregisterUpdate(self)
end

-- # FixedUpdate
function Node:ScheduleFixedUpdate(func)
    self.__internal_schedule__:RegisterFixedUpdate(self, func)
end

function Node:UnscheduleFixedUpdate()
    self.__internal_schedule__:UnregisterFixedUpdate(self)
end

-- # LateUpdate
function Node:ScheduleLateUpdate(func)
    self.__internal_schedule__:RegisterLateUpdate(self, func)
end

function Node:UnscheduleLateUpdate()
    self.__internal_schedule__:UnregisterLateUpdate(self)
end

-- # OnFocus
function Node:ScheduleOnFocus(func)
    self.__internal_schedule__:RegisterOnFocus(self, func)
end

function Node:UnscheduleOnFocus()
    self.__internal_schedule__:UnregisterOnFocus(self)
end

-- # OnPause
function Node:ScheduleOnPause(func)
    self.__internal_schedule__:RegisterOnPause(self, func)
end

function Node:UnscheduleOnPause()
    self.__internal_schedule__:UnregisterOnPause(self)
end

-- # All
function Node:UnscheduleAllCallbacks()
    self.__internal_schedule__:UnregisterAll(self)
end

-- 事件注册 相关
function Node:RegisterEvent(key, func, cipher)
    self.__internal_eventManager:AddObserver(key, self, func, cipher)
end

function Node:UnregisterEvent(key, func, cipher)
    self.__internal_eventManager:RemoveObserver(key, self, func, cipher)
end

function Node:UnregisterAllEvents()
    self.__internal_eventManager:RemoveObserver(nil, self)
end

function Node:DispatchEvent(name, cipher, ...)
    self.__internal_eventManager:PostNotification(name, cipher, ...)
end

function Node:DispatchEventReversely(name, cipher, ...)
    self.__internal_eventManager:PostNotificationReversely(name, cipher, ...)
end

-- 协程相关 --
local function OnCoroutineInternal(self, func, ...)
    local coroutineDict = GetAllCoroutines(self)
    local coRunning = coroutine.running()
    coroutineDict:Add(coRunning, coRunning)
    func(self, ...)
    coroutineDict:Remove(coRunning)
end

function Node:StartCoroutine(func, ...)
    return coroutine.start(OnCoroutineInternal, self, func, ...)
end

function Node:StopCoroutine(co)
    if co ~= nil then
        local coroutineDict = GetAllCoroutines(self)
        if coroutineDict:Remove(co) then
            coroutine.stop(co)
        end
    end
end

function Node:StopAllCoroutines()
    local coroutineDict = GetAllCoroutines(self)
    local count = coroutineDict:Count()
    for i = 1, count do
        local co = coroutineDict:GetEntryByIndex(i)
        if co ~= nil then
            coroutine.stop(co)
        end
    end
    coroutineDict:Clear()
end

function Node:IsCoroutineRunning(co)
    local coroutineDict = GetAllCoroutines(self)
    return coroutineDict:Contains(co)
end

return Node
