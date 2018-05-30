require "Framework.GameSubSystem"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"

-----------------------------------------------------------------------
--- 窗口信息
-----------------------------------------------------------------------
local WindowInfo = Class()

-- 拿到当前 HANDLE 的 互斥体 信息
local function GetLimitCount(HANDLE)
    local mutex = windowUtility.GetMutex(HANDLE)
    local limitCount = 0
    if mutex then
        if type(mutex) == "boolean" then
            limitCount = 1
        elseif type(mutex) == "number" then
            if mutex > 0 then
                limitCount = mutex
            end
        elseif type(mutex) == "function" then
            local t = mutex()
            if type(t) == "number" and t > 0 then
                limitCount = t
            end
        end
    end
    return limitCount
end

function WindowInfo:Ctor(HANDLE)
    hzj_print("dskhfskjdfksjdhfkjshfs",HANDLE,debug.traceback())
    self.prototype = HANDLE
    self.limitCount = GetLimitCount(HANDLE)

    self.inactivatedWindows = {}
    self.spawnedCount = 0
end

function WindowInfo:HasLimitReached()
--    print('limitCount', self.limitCount, 'spawnedCount', self.spawnedCount)
    if self.limitCount > 0 and self.spawnedCount >= self.limitCount then
        return true
    end
    return false
end

function WindowInfo:CreateWindow()
    if self:HasLimitReached() then
        print('limit reached!')
        return nil
    end

    local freeCount = #self.inactivatedWindows
    local instance

    if freeCount > 0 then
        instance = self.inactivatedWindows[freeCount]
        self.inactivatedWindows[freeCount] = nil
    else
        instance = self.prototype.New()
    end

    -- 分发了一个!
    self.spawnedCount = self.spawnedCount + 1

    return instance
end

function WindowInfo:Despawn(hwnd, nowWhat)
    self.spawnedCount = self.spawnedCount - 1
    utility.ASSERT(self.spawnedCount >= 0, 'spawnedCount 不能 小于 0')
    if not nowWhat then
        self.inactivatedWindows[#self.inactivatedWindows + 1] = hwnd
    else
        hwnd:OnCleanup()
    end
end

function WindowInfo:IsEmpty()
    return self.spawnedCount <= 0 and #self.inactivatedWindows == 0
end

-----------------------------------------------------------------------
--- 过渡信息
-----------------------------------------------------------------------
local TransitionInfo = Class()

function TransitionInfo:Ctor(hwnd, HANDLE, now_what)
    self.now_what = now_what
    self.HANDLE = HANDLE
    self.hwnd = hwnd
end

function TransitionInfo:GetHwnd()
    return self.hwnd
end

function TransitionInfo:GetHANDLE()
    return self.HANDLE
end

function TransitionInfo:GetNowWhat()
    return self.now_what
end

-----------------------------------------------------------------------
--- 窗口管理
-----------------------------------------------------------------------
local WindowManager = Class(GameSubSystem)

function WindowManager:Ctor(parentTransform)
    self.parentTransform = parentTransform

    self.windowInfoDict = {}       -- 维护窗口总体 和 可用窗口信息
    self.activatedWindows = {}     -- 打开的窗体

    self.fadeInWindows = {}        -- 正在 FadeIn 的窗体
    self.fadeOutWindows = {}       -- 正在 FadeOut 的窗体

    self.isUpdating = false        -- 是否正在 Update
end

function WindowManager:Show(WindowNodeClass, ...)
    utility.ASSERT(type(WindowNodeClass) == "table", "参数 WindowNodeClass 必须是 table 类型!")

    -- 获取当前的窗口信息
    local windowInfo
    if self.windowInfoDict[WindowNodeClass] ~= nil then
        windowInfo = self.windowInfoDict[WindowNodeClass]
    else
        windowInfo = WindowInfo.New(WindowNodeClass)
        self.windowInfoDict[WindowNodeClass] = windowInfo
    end

    local newHwnd = windowInfo:CreateWindow()
    if newHwnd == nil then
        -- FIXME: 已知问题, 当有正在关闭的窗口时 是不是可以有个选项 强制重新激活他呢?!
        return nil
    end

    newHwnd:OnWillShow(...)

    utility.ASSERT(self.activatedWindows[newHwnd] == nil, '应该是一个全新的窗口!')
    self.activatedWindows[newHwnd] = WindowNodeClass

    -- 加入到这里
    self.fadeInWindows[#self.fadeInWindows + 1] = TransitionInfo.New(newHwnd, false)

    return newHwnd
end

local function OnRemove(self, windowNode, HANDLE, nowWhat)
    local windowInfo = self.windowInfoDict[HANDLE]
    windowInfo:Despawn(windowNode, nowWhat)

    if windowInfo:IsEmpty() then
        self.windowInfoDict[HANDLE] = nil
    end
end

local function HideOrClose(self, hwnd, isClose, immediately)
    utility.ASSERT(self.isUpdating == false, "限制: 不能在 Update 中执行!!")
    utility.ASSERT(type(hwnd) == "table", "参数 hwnd 必须是 table 类型!")

    -- 查一下是否有正在关闭的窗口, 如果有则不处理 --
    for i = #self.fadeOutWindows, 1, -1 do
        if self.fadeOutWindows[i]:GetHwnd() == hwnd then
            print('ignore -- 1')
            return
        end
    end

    -- 查一下是否已经在显示窗口里
    if self.activatedWindows[hwnd] == nil then
        print('ignore -- 2')
        return
    end

    -- 查一下是否当前窗口正在fadeIn, 如果有则从fadeInWindow中删除 --
    for i = #self.fadeInWindows, 1, -1 do
        if self.fadeInWindows[i]:GetHwnd() == hwnd then
            -- fixme stop
            hwnd:StopAnimation()
            self.fadeInWindows[i] = self.fadeInWindows[#self.fadeInWindows]
            self.fadeInWindows[#self.fadeInWindows] = nil
        end
    end

    local HANDLE = self.activatedWindows[hwnd]
    self.activatedWindows[hwnd] = nil

    if not immediately then
        -- 把此hwnd丢到fadeOutWindows里
        self.fadeOutWindows[#self.fadeOutWindows + 1] = TransitionInfo.New(hwnd, HANDLE, isClose)
        hwnd:OnExitTransitionDidStart()
    else
        hwnd:OnExitTransitionDidStart(true)
        hwnd:OnExit()
        OnRemove(self, hwnd, HANDLE, isClose)
    end

    return true
end

function WindowManager:Hide(hwnd, immediately)
    return HideOrClose(self, hwnd, false, immediately)
end

function WindowManager:Close(hwnd, immediately)
    return HideOrClose(self, hwnd, true, immediately)
end

function WindowManager:CloseAll(immediately)
    local allKey = {}
    for k, _ in pairs(self.activatedWindows) do
        allKey[#allKey + 1] = k
    end

    for i = 1, #allKey do
        self:Close(allKey[i], immediately)
    end
end

function WindowManager:HideAll(immediately)
    local allKey = {}
    for k, _ in pairs(self.activatedWindows) do
        allKey[#allKey + 1] = k
    end

    for i = 1, #allKey do
        self:Hide(allKey[i], immediately)
    end
end

function WindowManager:Startup()
end

function WindowManager:Shutdown()
    self:CloseAll(true)
end

function WindowManager:Restart()
end

function WindowManager:Update()
    if self.isUpdating then
        return
    end

    self.isUpdating = true

    local currentTransitionInfo
    local windowNode

    -- fadeIn
    for i = #self.fadeInWindows, 1, -1 do
        currentTransitionInfo = self.fadeInWindows[i]

        windowNode = currentTransitionInfo:GetHwnd()

        -- 处理初始化和动画 --
        if not windowNode:IsRunning() then
            windowNode:OnEnter()
            if (not windowNode:IsTransition()) and (not windowNode:IsEnterTransition()) then
                windowNode:OnEnterTransitionDidFinish()
            end
        end

        -- 处理动画结束 --
        if windowNode:IsTransitionFinished() then
            print('fadeIn__done!')
            self.fadeInWindows[i] = self.fadeInWindows[#self.fadeInWindows]
            self.fadeInWindows[#self.fadeInWindows] = nil
        else
            windowNode:OnAnimationUpdate()
        end
    end


    -- fadeOut
    for i = #self.fadeOutWindows, 1, -1 do
        currentTransitionInfo = self.fadeOutWindows[i]

        windowNode = currentTransitionInfo:GetHwnd()

        -- 处理动画 --
        if (not windowNode:IsTransition()) and (not windowNode:IsExitTransition()) then
            windowNode:OnExit()
        end

        -- 归还
        if not windowNode:IsRunning() then
            print('fadeOut__done!')

            self.fadeOutWindows[i] = self.fadeOutWindows[#self.fadeOutWindows]
            self.fadeOutWindows[#self.fadeOutWindows] = nil

            local HANDLE = currentTransitionInfo:GetHANDLE()

            OnRemove(self, windowNode, HANDLE, currentTransitionInfo:GetNowWhat())
        else
            windowNode:OnAnimationUpdate()
        end
    end

    self.isUpdating = false
end

function WindowManager:GetGuid()
    return require "Framework.SubsystemGUID".WindowManager
end

return WindowManager
