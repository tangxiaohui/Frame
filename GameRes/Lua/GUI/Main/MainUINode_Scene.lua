--
-- User: fenghao
-- Date: 12/06/2017
-- Time: 2:36 PM
--

local UINodeClass = require "Framework.Base.UINode"

local utility = require "Utils.Utility"

local Main3DScene = Class(UINodeClass)

function Main3DScene:Ctor(scrollTransform, bubbleTransform)
    self.scrollTransform = scrollTransform
    self.bubbleTransform = bubbleTransform

    self.bubbles = {}
end

function Main3DScene:OnInit()
    utility.LoadNewGameObjectAsync('UI/Prefabs/Zhuchangjing', function(go)
        self:BindComponent(go, false)
        UnityEngine.Object.DontDestroyOnLoad(go)
    end)
end

-- 更新气泡位置
local function UpdateBubbleControls(self, ratio)
    for i = 1, #self.bubbles do
        self.bubbles[i]:Update(self.camera, ratio)
    end
end

-- 外部调用滚动事件(根据 0-1 来设置场景的移动)
local function OnScrollViewValueChanged(self, posXY)
    -- 先移动 --
    local TweenUtility = require "Utils.TweenUtility"
    local t = utility.Clamp01(posXY.x)
    local left = 1
    local right = -1.7
    local pos = self.transformToMove.localPosition
    pos.x = TweenUtility.Linear(left, right, t)
    self.transformToMove.localPosition = pos

    -- 再更新气泡的位置 --
    UpdateBubbleControls(self, t)
end

local function AddBubbleElement(self, sceneElementTransform, bubbleTransform, offset, startRatio, endRatio, messageGuid)
    local Main3DElementClass = require "GUI.Main.Main3DElement"
    local newMain3DElement = Main3DElementClass.New(sceneElementTransform, bubbleTransform, offset, startRatio, endRatio, messageGuid)
    self:AddChild(newMain3DElement)
    newMain3DElement:Update(self.camera, 0)
    self.bubbles[#self.bubbles + 1] = newMain3DElement
end

-- 初始化控件
local function InitBubbleControls(self)
    local messageGuids = require "Framework.Business.MessageGuids"

    local transform = self:GetUnityTransform()
    print("根节点", transform.name)

    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/Pit"), self.bubbleTransform:Find("Bubble9"), Vector2.New(160,80), -0.7, 0.7, messageGuids.EnterPitScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/Princess"), self.bubbleTransform:Find("Bubble10"), Vector2.New(-10,100), -0.7, 0.7, messageGuids.EnterProtectScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/House"), self.bubbleTransform:Find("Bubble1"), Vector2.New(-100,80), -0.7, 0.7, messageGuids.EnterCastleScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/ElvenTree"), self.bubbleTransform:Find("Bubble2"), Vector2.New(100, 80), -0.7, 0.7, messageGuids.EnterElvenTreeScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/Shop"), self.bubbleTransform:Find("Bubble3"), Vector2.New(80, 140), -0.7,0.7, messageGuids.EnterShopScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/Guild"), self.bubbleTransform:Find("Bubble4"), Vector2.New(100, 80), 0, 0, messageGuids.EnterGuildScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/Mail"), self.bubbleTransform:Find("Bubble5"), Vector2.New(100, 80), 0.3, 1.7, messageGuids.EnterMailScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/Chapter"), self.bubbleTransform:Find("Bubble6"), Vector2.New(90, 160), 0.5, 1.5, messageGuids.EnterChapterScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/Arena"), self.bubbleTransform:Find("Bubble7"), Vector2.New(-60, 50), 0.5, 1.5, messageGuids.EnterArenaScene)
    AddBubbleElement(self, transform:Find("Zhuchangjing1/zhucheng/Journey"), self.bubbleTransform:Find("Bubble8"), Vector2.New(-160, 80), 0.5, 1.5, messageGuids.EnterJourneyScene)
end

local function InitControls(self)
    -- 获取 parent上的ScrollRect
    self.scrollView = self.scrollTransform:GetComponent(typeof(UnityEngine.UI.ScrollRect))

    -- 初始化自己的控件 --
    local transform = self:GetUnityTransform()

    -- 获取摄像机 --
    self.camera = transform:GetComponent(typeof(UnityEngine.Camera))

    -- 需要移动的 transform --
    self.transformToMove = transform:Find("Zhuchangjing1")

    -- 初始化气泡控件
    InitBubbleControls(self)

    -- 设置到右边 --
    self.scrollView.horizontalNormalizedPosition = 1
end

function Main3DScene:OnComponentReady()
    InitControls(self)
end

local function OnMoveGuidePosition(self, dir)
    if dir == "left" then
        self.scrollView.horizontalNormalizedPosition = 0
    else
        self.scrollView.horizontalNormalizedPosition = 1
    end
end

function Main3DScene:OnResume()
    Main3DScene.base.OnResume(self)

    self:RegisterEvent("MoveGuidePosition", OnMoveGuidePosition, nil)

    -- 注册 ScrollView 的事件
    self.__event_scrollrect_onScrollViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(OnScrollViewValueChanged, self)
    self.scrollView.onValueChanged:AddListener(self.__event_scrollrect_onScrollViewValueChanged__)
end

function Main3DScene:OnPause()
    Main3DScene.base.OnPause(self)

    self:UnregisterEvent("MoveGuidePosition", OnMoveGuidePosition, nil)

    -- 取消注册 ScrollView 的事件
    if self.__event_scrollrect_onScrollViewValueChanged__ then
        self.scrollView.onValueChanged:RemoveListener(self.__event_scrollrect_onScrollViewValueChanged__)
        self.__event_scrollrect_onScrollViewValueChanged__ = nil
    end
end

return Main3DScene