local NodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"

local WindowNode = Class(NodeClass)

function WindowNode:Ctor()
    -- fade参数的上下文
    self.__internal_fade_context = {}
end

function WindowNode:OnWillShow()
end

function WindowNode:OnBeforeTransformParentChanged(isUnload)
    if not isUnload then
        local gameObject = self:GetUnityGameObject()
        local graphicRaycaster = gameObject:GetComponent(typeof(UnityEngine.UI.GraphicRaycaster))
        if graphicRaycaster == nil then
            graphicRaycaster = gameObject:AddComponent(typeof(UnityEngine.UI.GraphicRaycaster))
        end
    end
end

-- 子类可以重载所使用的WindowManager.
function WindowNode:GetWindowManager()
    return self:GetGame():GetWindowManager()
end

-- 子可以重载挂点!!
function WindowNode:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end

-- 仅隐藏
function WindowNode:Hide(immediately)
    self:GetWindowManager():Hide(self, immediately)
end

-- 会删除
function WindowNode:Close(immediately)
    self:GetWindowManager():Close(self, immediately)
end

function WindowNode:IsEnterTransition()
    return false
end

function WindowNode:IsExitTransition()
    return false
end

-----------------------------------------------------------------------
--- 动画相关函数
-----------------------------------------------------------------------
-- 子类需要调用这个执行函数(需要的时候去注册Update)
function WindowNode:OnAnimationUpdate()
    if self:IsFadeAnimating() then
        local finished
        local t = self.__internal_fade_context.passedTime / self.__internal_fade_context.totalTime
        if t >= 1 then
            t = 1
            finished = true
        end

        self.__internal_fade_context.fadeFunction(self, t, finished)
        self.__internal_fade_context.passedTime = self.__internal_fade_context.passedTime + UnityEngine.Time.unscaledDeltaTime

        if finished then
            if self.__internal_fade_context.isFadeInPlaying then
                self.__internal_fade_context.isFadeInPlaying = false
                self:OnEnterTransitionDidFinish()
            else
                self.__internal_fade_context.isFadeOutPlaying = false
                self:OnExit()
            end
        end
    end
end

function WindowNode:IsFadeAnimating()
    return self.__internal_fade_context.isFadeInPlaying or self.__internal_fade_context.isFadeOutPlaying
end

function WindowNode:GetFadeInTotalTime()
    return 0.3
end

function WindowNode:GetFadeOutTotalTime()
    return 0.25
end

function WindowNode:FadeIn(tweenFunction)
    if self:IsFadeAnimating() then
        return
    end

    if self:IsTransitionFinished() then
        return
    end

    if self:IsTransition() or self:IsEnterTransition() then
        utility.ASSERT(type(tweenFunction) == "function", "参数 tweenFunction 必须是 function 类型!")

        self.__internal_fade_context.isFadeInPlaying = true
        self.__internal_fade_context.passedTime = 0
        self.__internal_fade_context.totalTime = self:GetFadeInTotalTime()
        self.__internal_fade_context.fadeFunction = tweenFunction
    end
end

function WindowNode:FadeOut(tweenFunction)
    if self:IsFadeAnimating() then
        return
    end

    if not self:IsRunning() then
        return
    end

    if self:IsTransition() or self:IsExitTransition() then
        utility.ASSERT(type(tweenFunction) == "function", "参数 tweenFunction 必须是 function 类型!")

        self.__internal_fade_context.isFadeOutPlaying = true
        self.__internal_fade_context.passedTime = 0
        self.__internal_fade_context.totalTime = self:GetFadeOutTotalTime()
        self.__internal_fade_context.fadeFunction = tweenFunction
    end
end

function WindowNode:StopAnimation()
    if self:IsFadeAnimating() then
        -- Fixme
        --self.__internal_fade_context.lastPassedTime = self.__internal_fade_context.passedTime
        self.__internal_fade_context.isFadeInPlaying = false
        self.__internal_fade_context.isFadeOutPlaying = false
        self.__internal_fade_context.passedTime = 0
        self.__internal_fade_context.fadeFunction = nil
    end
end

return WindowNode

