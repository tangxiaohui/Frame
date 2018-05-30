
local WindowNodeClass = require "Framework.Base.WindowNode"
local windowUtility = require "Framework.Window.WindowUtility"
local utility = require "Utils.Utility"

local TweenUtility = require "Utils.TweenUtility"

local RaidAwardItemClass = require "GUI.Modules.Raid.RaidAwardItem"


local CheckpointRaidModule = Class(WindowNodeClass)

-- # 设置为唯一
windowUtility.SetMutex(CheckpointRaidModule, true)

-- 初始化界面
function CheckpointRaidModule:OnInit()
    -- 加载 登录界面
    utility.LoadNewGameObjectAsync('UI/Prefabs/CheckpointRaid', function(go)
        self:BindComponent(go)
    end)
end

-- 指定为Module层!
function CheckpointRaidModule:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function CheckpointRaidModule:OnWillShow(msg)
    self.sweepResult = msg
end

function CheckpointRaidModule:OnComponentReady()
    self:InitControls()
end

-----------------------------------------------------------------------
--- 用动画显示扫荡结果
-----------------------------------------------------------------------
local function PrepareShowResult(self)
    print('********* PrepareShowResult **********')
    self.scrollView.verticalNormalizedPosition = 1

    coroutine.step(1)

    local sweepCount = self.sweepResult.sweepCount

    if sweepCount > 10 then
        error("现在没有处理扫荡次数大于10的情况!")
    end

    local currentAwardItem

    for i = 1, sweepCount do
        currentAwardItem = self.awardItems[i]
        currentAwardItem:SetData(self.sweepResult, i)
        self:AddChild(currentAwardItem)


--        print('>>>>>>> Reward ---- 1', i)
        -- 第一步骤是显示整个控件 -> 布局控件
        repeat
            coroutine.step(1)
        until(currentAwardItem:IsLayoutFinished())

--        print('>>>>>>> Reward ---- 2', i)

        -- 第二步是移动滚动条到最下边
        if utility.VScrollingNeeded(self.scrollView) then
            local moveSource = 1
            local moveTarget = 0
            if moveSource ~= moveTarget then
                local t = 0
                local finished = false
                local totalTime = 0.1515
                local passedTime = 0
                repeat
                    t = passedTime / totalTime
                    if t >= 1 then
                        t = 1
                        finished = true
                    end
                    self.scrollView.verticalNormalizedPosition = TweenUtility.Linear(moveSource, moveTarget, t)
                    passedTime = passedTime + UnityEngine.Time.unscaledDeltaTime
                    coroutine.step(1)
                until(finished)
            end
        end

        coroutine.step(1)

--        print('>>>>>>> Reward ---- 3', i)

        -- 显示图标
        self.awardItems[i]:ShowIcons()
        coroutine.wait(0.1)
        repeat
            coroutine.step(1)
        until(self.awardItems[i]:IsShowIconFinished())

        coroutine.wait(0.1)
    end

    -- 完成后 可以让用户干涉! --
    self.contentCanvasGroup.blocksRaycasts = true
    self.contentCanvasGroup.interactable = true

--    print("显示完毕!!!!!")

    self.CloseButtonObject:SetActive(true)
end

function CheckpointRaidModule:OnResume()
    CheckpointRaidModule.base.OnResume(self)
    self:BringToFront()
    self:RegisterControlEvents()

    -- 初始不能显示按钮
    self.CloseButtonObject:SetActive(false)

    -- 首先不能让用户干涉 --
    self.contentCanvasGroup.blocksRaycasts = false
    self.contentCanvasGroup.interactable = false

    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
    end)

    self:StartCoroutine(PrepareShowResult, self)

--    -- 开始任务 --
--    self.taskContext = {}
--    self.taskContext.play = true
--    self.taskContext.currentPos = 1
--    self.taskContext.passedTime = 0
--    self.taskContext.status = 0 -- 0. 显示 1. 显示等待 2. 移动 3.显示图标
--    self:ScheduleUpdate(self.OnExecuteAnimation)
end

function CheckpointRaidModule:OnPause()
    CheckpointRaidModule.base.OnPause(self)
    self:BringToBack()
    self:UnregisterControlEvents()

    for i = 1, #self.awardItems do
        self:RemoveChild(self.awardItems[i])
    end
end

function CheckpointRaidModule:OnExitTransitionDidStart(immediately)
    CheckpointRaidModule.base.OnExitTransitionDidStart(self, immediately)
    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function CheckpointRaidModule:IsTransition()
    return true
end


function CheckpointRaidModule:InitControls()
    local transform = self:GetUnityTransform()

    self.tweenObjectTrans = transform:Find("TweenObject")

    self.scrollView = transform:Find("TweenObject/Scroll View"):GetComponent(typeof(UnityEngine.UI.ScrollRect))

    self.contentCanvasGroup = transform:Find("TweenObject/Scroll View/Viewport"):GetComponent(typeof(UnityEngine.CanvasGroup))

    -- 已有的awarditems控件 最大有10个 --
    self.awardItems = {
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward1")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward2")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward3")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward4")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward5")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward6")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward7")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward8")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward9")),
        RaidAwardItemClass.New(transform:Find("TweenObject/Scroll View/Viewport/Content/CheckpointRaidAward10")),
    }

    -- 按钮
    local closeButtonTrans = transform:Find("TweenObject/AnnouncementConfirmButton")
    self.CloseButtonObject = closeButtonTrans.gameObject
    self.CloseButton = closeButtonTrans:GetComponent(typeof(UnityEngine.UI.Button))

    --背景按钮
    self.BackgroundButton = transform:Find('Background'):GetComponent(typeof(UnityEngine.UI.Button))
end

function CheckpointRaidModule:RegisterControlEvents()
    self.__event_button_CloseButton_Clicked__ = UnityEngine.Events.UnityAction(self.OnCloseButtonClicked, self)
    self.CloseButton.onClick:AddListener(self.__event_button_CloseButton_Clicked__)

    -- 注册 BackgroundButton 的事件
    self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCloseButtonClicked,self)
    self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function CheckpointRaidModule:UnregisterControlEvents()
    if self.__event_button_CloseButton_Clicked__ then
        self.CloseButton.onClick:RemoveListener(self.__event_button_CloseButton_Clicked__)
        self.__event_button_CloseButton_Clicked__ = nil
    end
    -- 取消注册 BackgroundButton 的事件
    if self.__event_backgroundButton_onButtonClicked__ then
       self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
       self.__event_backgroundButton_onButtonClicked__ = nil
    end

end

function CheckpointRaidModule:OnCloseButtonClicked()
    self:Close()
end

return CheckpointRaidModule
