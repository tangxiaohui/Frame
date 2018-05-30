
local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local TweenUtility = require "Utils.TweenUtility"
require "Collection.DataStack"
require "Collection.OrderedDictionary"
require "LUT.StringTable"

local EquipmentScene = Class(BaseNodeClass)
local net = require "Network.Net"

local LeftDir = 1
local RightDir = -1

local TotalTime = 0.3

-- 端点记录
local LeftPosX = 335
local RightPosX = -335

-- 英雄选择页面的类型
local HeroSceneTabGroup = 10

local HeroSceneTab_HeroCard = 1
local HeroSceneTab_HeroCrap = 2

function EquipmentScene:Ctor(defaultDirection, cantMove)
    self.acceptDirection = utility.Sign(defaultDirection or LeftDir)
    self.canMoveUI = not cantMove

    self.animatePlaying = false
    self.heroListScrollingNeeded = false

    -- 对象池
    self.heroCardPool = DataStack.New()
    self.heroCardSpawnedDictionary = OrderedDictionary.New()

    -- 英雄卡包 --
    self.heroCardDictionary = OrderedDictionary.New()

    -- 英雄碎片 --
    self.heroCrapDictionary = OrderedDictionary.New()

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipmentScene:OnInit()
    utility.LoadNewGameObjectAsync(
        'UI/Prefabs/CardBasis',
        function(go)
            self:BindComponent(go)
        end
    )
end

function EquipmentScene:OnComponentReady()
    self:InitControls()
end

function EquipmentScene:OnResume()
    EquipmentScene.base.OnResume(self)
    self:SetCanMoveUI_Internal(self.canMoveUI)
    self:SetDirection_Internal(self.acceptDirection)
    self:RegisterControlEvents()
    self:RegisterNetworkEvents()
    self:RegisterMessages()
end

function EquipmentScene:OnPause()
    EquipmentScene.base.OnPause(self)

    self:UnregisterControlEvents()
    self:UnregisterNetworkEvents()
    self:UnregisterMessages()
end

-- 英雄界面的刷新
local function OnHandleHeroCard(self, selected)
    -- 处理选中效果
    if selected then
        self.heroSelectTableImage.color = UnityEngine.Color(1, 1, 1, 1)
    else
        self.heroSelectTableImage.color = UnityEngine.Color(0.5, 0.5, 0.5, 1)
    end

    self.HeroTabGridListObject:SetActive(selected)

    --- 处理界面刷新
    if selected then
        local UserDataType = require "Framework.UserDataType"

        local cardBagData = self:GetCachedData(UserDataType.CardBagData)

        local ownedCount = cardBagData:RoleCount() -- # 拥有的个数

        local firstItem      -- # 先激活的是它

        local ownedItemIds = {}

        -- ### 创建拥有的 ### --
        for i = 1, ownedCount do
            local node = self.heroCardPool:Pop()
            node:SetIsCrap(false)
            node:SetHeroData(cardBagData:GetRoleByPos(i))
            node:SetParentTransform(self.CurrentHeroGridListTrans)
            node:SetHasOwned(true)
            node:SetCallback(self, self.OnCardItemClicked)

            -- 保存第一个item
            if firstItem == nil then
                firstItem = node
                node:SetSelected(true)
            end

            self:AddChild(node)
            self.heroCardSpawnedDictionary:Add(node:GetHeroId(), node)
            self.heroCardDictionary:Add(node:GetHeroId(), node)
            ownedItemIds[node:GetHeroId()] = true
        end

        -- ### 创建未拥有的 ### --
        local roleMgr = Data.Role.Manager.Instance()
        local keys = roleMgr:GetKeys()

        require "Game.Role"

        local length = keys.Length

        -- 首先加入 --
        local orderedNodes = {}

        -- 首先拿到控件列表 --
        for i = 0, length - 1 do
            local heroID = keys[i]
            if not ownedItemIds[heroID] then
                local currentRole = Role.New()
                currentRole:UpdateForStatic(keys[i], 1, 1)
                if currentRole:IsShowInCollection() then
                    local node = self.heroCardPool:Pop()
                    node:SetIsCrap(false)
                    node:SetHeroData(currentRole)
                    node:SetParentTransform(self.NotGetHeroGridListTrans)
                    node:SetHasOwned(false)
                    node:SetCallback(self, self.OnCardItemClicked)
                    node:SetSelected(false)
                    orderedNodes[#orderedNodes + 1] = node
                end
            end
        end

        -- 然后排序 --
        table.sort(orderedNodes, function(node1, node2)
            return node1:GetChipCount() > node2:GetChipCount()
        end)

        -- 再加入 --
        for i = 1, #orderedNodes do
            local node = orderedNodes[i]
            self.heroCardSpawnedDictionary:Add(node:GetHeroId(), node)
            self.heroCrapDictionary:Add(node:GetHeroId(), node)
            self:AddChild(node)            
        end

        -- 动画事件处理
        self.animatePlaying = false
        self.CardBasisFlipRightButton.gameObject:SetActive(true)

    else
        -- 将所有控件归还!
        local spawnedCount = self.heroCardSpawnedDictionary:Count()
        for i = 1, spawnedCount do
            local node = self.heroCardSpawnedDictionary:GetEntryByIndex(i)
            self:RemoveChild(node)
            node:Clear()
            self.heroCardPool:Push(node)
        end
        self.heroCardSpawnedDictionary:Clear()
        self.heroCardDictionary:Clear()
        self.heroCrapDictionary:Clear()

          -- 动画事件处理
        self.animatePlaying = true
        self.CardBasisFlipRightButton.gameObject:SetActive(false)
    end
end

local function OnHandleHeroCrap(self, selected)
    -- 处理选中效果
    if selected then
        self.heroCrapSelectImage.color = UnityEngine.Color(1, 1, 1, 1)
    else
        self.heroCrapSelectImage.color = UnityEngine.Color(0.5, 0.5, 0.5, 1)
    end

    self.CrapTabGridListObject:SetActive(selected)

    --- 处理界面刷新
    if selected then
        local UserDataType = require "Framework.UserDataType"

        local cardChipBagData = self:GetCachedData(UserDataType.CardChipBagData)
        local ownedCount = cardChipBagData:GetCount()

        local firstItem

        for i = 1, ownedCount do
            local node = self.heroCardPool:Pop()
            node:SetHeroCrapData(cardChipBagData:GetDataByIndex(i))
            node:SetParentTransform(self.HeroCrapGridListTrans)
            node:SetHasOwned(true)
            node:SetCallback(self, self.OnCardItemClicked)

            -- 保存第一个item
            if firstItem == nil then
                firstItem = node
                node:SetSelected(true)
            end

            self.heroCardSpawnedDictionary:Add(node:GetHeroId(), node)
            self.heroCrapDictionary:Add(node:GetHeroId(), node)
            self:AddChild(node)
        end
    else
        -- 将所有控件归还!
        local spawnedCount = self.heroCardSpawnedDictionary:Count()
        for i = 1, spawnedCount do
            local node = self.heroCardSpawnedDictionary:GetEntryByIndex(i)
            self:RemoveChild(node)
            node:Clear()
            self.heroCardPool:Push(node)
        end
        self.heroCardSpawnedDictionary:Clear()
        self.heroCardDictionary:Clear()
        self.heroCrapDictionary:Clear()
    end
end

local function OnHeroTabChanged(self, toggleNode)
    -- 判断选中 赋值当前所选的node
    local selected = toggleNode:IsSelected()
    if selected then
        if self.currentSelectedTabNode ~= nil then
            self.currentSelectedTabNode:SetSelect(false)
        end
        self.currentSelectedTabNode = toggleNode
    end

    -- 处理
    if toggleNode:GetTag() == HeroSceneTab_HeroCard then
        -- 选中/未选中
        OnHandleHeroCard(self, selected)

    else
        OnHandleHeroCrap(self, selected)
    end
end


local function InitCommonControls(self, transform)
    -- canvas group
    self.canvasGroup = transform:GetComponent(typeof(UnityEngine.CanvasGroup))

    -- pool trans
    self.poolTrans = transform:Find("Pool")

    -- 更多信息
    self.MoreInformation = transform:Find("MoveUI/List/MoreInformation"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 返回按钮
    self.CardBasisRetrunButton = transform:Find("CardBasisRetrunButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 选择英雄
    self.TitleHeroImage = transform:Find("Title/ChoosHerosTitle"):GetComponent(typeof(UnityEngine.UI.Image))
    self.TitleEquipmentImage = transform:Find("Title/EquipmentTitle"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 详细页面的transform
    self.heroDetailTrans = transform:Find("MoveUI/Equipment")

    -- 卡牌进阶按钮
    self.CardRiseButton = transform:Find('MoveUI/Equipment/EquipmentAdvancedButton'):GetComponent(typeof(UnityEngine.UI.Button))

    --- #### Toggle初始化 #### ---

    -- 英雄按钮 toggle
    self.heroSelectTableTrans = transform:Find("MoveUI/List/CardBasisHeroButton")
    self.heroSelectTableImage = self.heroSelectTableTrans:GetComponent(typeof(UnityEngine.UI.Image))

    -- 碎片按钮 toggle
    self.heroCrapSelectTrans = transform:Find("MoveUI/List/CardBasisDebrisButton")
    self.heroCrapSelectImage = self.heroCrapSelectTrans:GetComponent(typeof(UnityEngine.UI.Image))

    local ToggleNodeClass = require "GUI.ToggleNode"

    --- ## 卡牌 Toggle ## --
    self.heroCardToggle = ToggleNodeClass.New(self.heroSelectTableTrans, HeroSceneTabGroup, HeroSceneTab_HeroCard)
    self.heroCardToggle:SetCallback(self, OnHeroTabChanged)
    self:AddChild(self.heroCardToggle)


    --- ## 碎片 Toggle ## --
    self.heroCrapToggle = ToggleNodeClass.New(self.heroCrapSelectTrans, HeroSceneTabGroup, HeroSceneTab_HeroCrap)
    self.heroCrapToggle:SetCallback(self, OnHeroTabChanged)
    self:AddChild(self.heroCrapToggle)
end

local function InitHeroCardControls(self, transform)
    -- 需要移动的UI的Transform
    self.moveUITrans = transform:Find("MoveUI")

    -- Swipe 手势的控件
    self.swipeEventHandler = transform:Find("MoveUI/GestureRegions"):GetComponent(typeof(SwipeEventHandler))

    -- 右边的箭头按钮
    self.CardBasisFlipRightButton = transform:Find("CardBasisFlipRightButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.CardBasisFlipRightButtonObject = self.CardBasisFlipRightButton.gameObject

    -- 坐标的箭头按钮
    self.CardBasisFlipLeftButton = transform:Find("CardBasisFlipLeftButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.CardBasisFlipLeftButtonObject = self.CardBasisFlipLeftButton.gameObject

    -- 英雄Tab的滚动条
    self.HeroTabGridListObject = transform:Find("MoveUI/List/HeroList").gameObject

    -- 当前英雄列表的Transform
    self.CurrentHeroGridListTrans = transform:Find("MoveUI/List/HeroList/Scroll View/Viewport/Content/CurrentHeroGridList")

    -- 未拥有英雄列表的Transform
    self.NotGetHeroGridListTrans = transform:Find("MoveUI/List/HeroList/Scroll View/Viewport/Content/NotGetHeroGridList")

    -- 更多信息
    self.MoreInformation = transform:Find("MoveUI/List/MoreInformation"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 左边英雄列表的滚动条控件
    self.HeroListScrollView = transform:Find("MoveUI/List/HeroList/Scroll View"):GetComponent(typeof(UnityEngine.UI.ScrollRect))

    -- 默认显示状态
    self.CardBasisFlipLeftButtonObject:SetActive(false)
    self.CardBasisFlipRightButtonObject:SetActive(true)

    -- 口头禅
    self.HeroShowLabel = transform:Find("MoveUI/HeroShow/Bubble/HeroShowLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- # 图像
    self.heroPhotoGraphImage = transform:Find("MoveUI/HeroShow/HeroShowImage/FakeImage"):GetComponent(typeof(UnityEngine.UI.Image))

end

local function InitHeroCrapControls(self, transform)
    self.CrapTabGridListObject = transform:Find("MoveUI/List/CrapList").gameObject

    -- 拥有的碎片
    self.HeroCrapGridListTrans = transform:Find("MoveUI/List/CrapList/Scroll View/Viewport/Content/")
end

function EquipmentScene:InitControls()
    local transform = self:GetUnityTransform()

    --- ### 共同的
    InitCommonControls(self, transform)

    --- ### 英雄
    InitHeroCardControls(self, transform)

    --- ### 碎片
    InitHeroCrapControls(self, transform)

    --- ### 详细页面
    local EquipmentCardDetailClass = require "GUI.CardBasis.EquipmentCardDetail"
    local detailView = EquipmentCardDetailClass.New(self.heroDetailTrans)
    self.heroDetailView = detailView
    self:AddChild(detailView)

    --- # 预先创建池
    local HeroCardItemNodeClass = require "GUI.HeroCardItemNode"
    local roleMgr = Data.Role.Manager.Instance()
    local keys = roleMgr:GetKeys()
    local length = keys.Length
    for i = 1, length do
        local node = HeroCardItemNodeClass.New(self.poolTrans)
        self.heroCardPool:Push(node)
    end

    --- 激活页面 (默认是英雄标签页) --
    self.heroCardToggle:SetSelect(true)
--    self.heroCrapToggle:Dispatch() -- 碎片取消 --
end


-----------------------------------------------------------------------
--- 事件 注册/取消注册
-----------------------------------------------------------------------
function EquipmentScene:RegisterControlEvents()
    self.swipeEventHandler.onSwipe = System.Action_int(self.OnHandleSwipe, self)

    -- 注册 CardBasisFlipRightButton 的事件
    self.__event_button_onCardBasisFlipRightButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardBasisFlipRightButtonClicked, self)
    self.CardBasisFlipRightButton.onClick:AddListener(self.__event_button_onCardBasisFlipRightButtonClicked__)

    -- 注册 CardBasisFlipLeftButton 的事件
    self.__event_button_onCardBasisFlipLeftButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardBasisFlipLeftButtonClicked, self)
    self.CardBasisFlipLeftButton.onClick:AddListener(self.__event_button_onCardBasisFlipLeftButtonClicked__)


    -- 注册 CardBasisRetrunButton 的事件
    self.__event_button_onCardBasisRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardBasisRetrunButtonClicked, self)
    self.CardBasisRetrunButton.onClick:AddListener(self.__event_button_onCardBasisRetrunButtonClicked__)

    -- 注册卡牌进阶按钮的事件
     self.__event_button_onCardRiseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardRiseButtonClicked, self)
    self.CardRiseButton.onClick:AddListener(self.__event_button_onCardRiseButtonClicked__)

end

function EquipmentScene:RegisterNetworkEvents()
    -- 注册卡牌合成成功
    self:GetGame():RegisterMsgHandler(net.S2CCardSuipianBuildResult,self,self.OnCardDebrisBuildResponse)
end

function EquipmentScene:RegisterMessages()
    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.AddedOneCard, self.OnCardAddEvent)
    self:RegisterEvent(messageGuids.UpdatedOneCard, self.OnCardUpdateEvent)
end

function EquipmentScene:UnregisterControlEvents()
    self.swipeEventHandler.onSwipe = nil

    -- 取消注册 CardBasisFlipRightButton 的事件
    if self.__event_button_onCardBasisFlipRightButtonClicked__ then
        self.CardBasisFlipRightButton.onClick:RemoveListener(self.__event_button_onCardBasisFlipRightButtonClicked__)
        self.__event_button_onCardBasisFlipRightButtonClicked__ = nil
    end

    -- 取消注册 CardBasisFlipLeftButton 的事件
    if self.__event_button_onCardBasisFlipLeftButtonClicked__ then
        self.CardBasisFlipLeftButton.onClick:RemoveListener(self.__event_button_onCardBasisFlipLeftButtonClicked__)
        self.__event_button_onCardBasisFlipLeftButtonClicked__ = nil
    end

    -- 取消注册 CardBasisRetrunButton 的事件
    if self.__event_button_onCardBasisRetrunButtonClicked__ then
        self.CardBasisRetrunButton.onClick:RemoveListener(self.__event_button_onCardBasisRetrunButtonClicked__)
        self.__event_button_onCardBasisRetrunButtonClicked__ = nil
    end

    -- 取消注册卡牌进阶按钮的事件
    if self.__event_button_onCardRiseButtonClicked__ then
        self.CardRiseButton.onClick:RemoveListener(self.__event_button_onCardRiseButtonClicked__)
        self.__event_button_onCardRiseButtonClicked__ = nil
    end

end

function EquipmentScene:UnregisterNetworkEvents()
    -- 取消注册卡牌合成成功
    self:GetGame():UnRegisterMsgHandler(net.S2CCardSuipianBuildResult,self,self.OnCardDebrisBuildResponse)
end

function EquipmentScene:UnregisterMessages()
    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.UpdatedOneCard, self.OnCardUpdateEvent)
    self:UnregisterEvent(messageGuids.AddedOneCard, self.OnCardAddEvent)
end

-----------------------------------------------------------------------
--- 动画相关
-----------------------------------------------------------------------
function EquipmentScene:CanMove()
    return not self.animatePlaying and self.canMoveUI
end

-- 函数预先声明
local AnimationLerpUpdate

-- 内部调用
function EquipmentScene:SetDirection_Internal(dir)
    local startPosX = LeftPosX * dir
    local endPosX = RightPosX * dir
    self.acceptDirection = dir
    AnimationLerpUpdate(self, 0, startPosX, endPosX)
end

-- 内部调用
function EquipmentScene:SetCanMoveUI_Internal(canMove)
    if canMove then
        -- 根据方向显示箭头
        self.CardBasisFlipLeftButtonObject:SetActive(self.acceptDirection == RightDir)
        self.CardBasisFlipRightButtonObject:SetActive(self.acceptDirection == LeftDir)
    else

        self.CardBasisFlipRightButtonObject:SetActive(false)
        self.CardBasisFlipLeftButtonObject:SetActive(false)
    end
end

-- 函数定义
AnimationLerpUpdate = function(self, ratio, startPosX, endPosX)
    local posX = TweenUtility.EaseOutBack(startPosX, endPosX, ratio, 1.1)

    -- 移动!
    local pos = self.moveUITrans.localPosition
    pos.x = posX
    self.moveUITrans.localPosition = pos


    -- 显示
    local color

    if self.acceptDirection == RightDir then
        color = self.TitleHeroImage.color
        color.a = 1 - ratio
        self.TitleHeroImage.color = color

        color = self.TitleEquipmentImage.color
        color.a = ratio
        self.TitleEquipmentImage.color = color
    else
        color = self.TitleHeroImage.color
        color.a = ratio
        self.TitleHeroImage.color = color

        color = self.TitleEquipmentImage.color
        color.a = 1 - ratio
        self.TitleEquipmentImage.color = color
    end
end

local function OnMoveAnimation(self, startPosX, endPosX)
    --TweenUtility.
    local passedTime = 0
    local ratio
    local finished = false

    ratio = 0

    coroutine.step(1)

    repeat
        ratio = passedTime / TotalTime
        if ratio >= 1 then
            ratio = 1
            finished = true
        end

        AnimationLerpUpdate(self, ratio, startPosX, endPosX)
        passedTime = passedTime + Time.unscaledDeltaTime

        coroutine.step(1)
    until(finished)

    -- 移动后再次让玩家可以操作!
    self.canvasGroup.interactable = true

    self:SetCanMoveUI_Internal(self.canMoveUI)

    self.animatePlaying = false
end

local function PlayAnimate(self, dir)
    -- 播放!
    self.animatePlaying = true

    -- 再移动中不可以让用户操作
    self.canvasGroup.interactable = false

    self.CardBasisFlipLeftButtonObject:SetActive(false)
    self.CardBasisFlipRightButtonObject:SetActive(false)


    -- 向右走时 335 向左走时 -335
    local startPosX
    local endPosX

    -- 先设置下一次的接收方向! 以及 开始和结束的x坐标值
    startPosX = LeftPosX * dir
    endPosX = RightPosX * dir
    self.acceptDirection = -self.acceptDirection

    -- 开启协程 可以进行动画 --
    self:StartCoroutine(OnMoveAnimation, startPosX, endPosX)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function EquipmentScene:OnHandleSwipe(dir)
    print("方向", dir)
    if dir == 2 then
        dir = LeftDir
    else
        dir = RightDir
    end
    self:OnHandleMove(dir)
end

function EquipmentScene:OnHandleMove(dir)
    -- 是不是不能移动 --
    if not self:CanMove() then
        return
    end
    -- 是不是不需要移动 --
    if self.acceptDirection ~= dir then
        return
    end

    -- 开始移动 --
    PlayAnimate(self, dir)
end

function EquipmentScene:OnCardItemClicked(heroCardItemNode)
    if self.lastHeroItem == heroCardItemNode then
        return
    end

    if self.lastHeroItem ~= nil then
        self.lastHeroItem:SetSelected(false)
        self.lastHeroItem = nil
    end

    self.lastHeroItem = heroCardItemNode

    local heroData = heroCardItemNode:GetHeroData()

    -- 设置口头禅
    self.HeroShowLabel.text = heroData:GetMonolog()

    -- 设置属性页面 --
    self.heroDetailView:SetData(heroData)

    utility.LoadRolePortraitImage(heroData:GetPortraitImage(),self.heroPhotoGraphImage)

    self.currRiseNode = heroCardItemNode
end



function EquipmentScene:OnCardBasisRetrunButtonClicked()
    local myGame = self:GetGame()
    local sceneManager = myGame:GetSceneManager()
    sceneManager:PopScene()
end

function EquipmentScene:OnCardBasisFlipRightButtonClicked()
    self:OnHandleMove(self.acceptDirection)
end

function EquipmentScene:OnCardBasisFlipLeftButtonClicked()
    self:OnHandleMove(self.acceptDirection)
end

-- 消息处理 添加卡牌
function EquipmentScene:OnCardAddEvent(cardData)

    if not cardData:IsShowInCollection() then
        return
    end


    local cardId = cardData:GetId()

    local entry = self.heroCrapDictionary:GetEntryByKey(cardId)

    if entry ~= nil and not entry:IsCrapMode() then
        -- 移除控件
        self:RemoveChild(entry)

        -- 重新设置数据
        entry:SetIsCrap(false)
        entry:SetHeroData(cardData)
        entry:SetParentTransform(self.CurrentHeroGridListTrans)
        entry:SetHasOwned(true)

        -- 移除碎片
        self.heroCrapDictionary:Remove(cardId)

        -- 加到英雄数据里
        self.heroCardDictionary:Add(cardId, entry)

        -- 重新排序
        self:ResortHeroCard()
    end

end

-- 消息处理 卡牌升级
function EquipmentScene:OnCardUpdateEvent(cardData)
    if not cardData:IsShowInCollection() then
        return
    end

    local cardId = cardData:GetId()
    local entry = self.heroCardDictionary:GetEntryByKey(cardId)
    if entry ~= nil then
        entry:UpdateLevel()
        self:ResortHeroCard()
    end
end

function EquipmentScene:ResortHeroCard()
    -- 排序
    self.heroCardDictionary:Sort(function(node1, node2)
        return utility.CompareCardByRoleData(node1:GetHeroData(), node2:GetHeroData())
    end)

    -- 将所有控件归还!
    local spawnedCount = self.heroCardDictionary:Count()
    for i = 1, spawnedCount do
        local node = self.heroCardDictionary:GetEntryByIndex(i)
        self:RemoveChild(node)
    end

    -- 再放入 --
    for i = 1, spawnedCount do
        local node = self.heroCardDictionary:GetEntryByIndex(i)
        self:AddChild(node)
    end
end

function EquipmentScene:OnCardRiseButtonClicked()
    -- 卡牌进阶事件
   local hasOwned = self.currRiseNode:GetHasOwned()
   local data = self.currRiseNode:GetHeroData()

   if not hasOwned then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = utility:GetGame():GetWindowManager()
        windowManager:Show(ErrorDialogClass, CrapStringTable[1])
    else
        local windowManager = self:GetGame():GetWindowManager()
        windowManager:Show(require "GUI.CardRise.CardRise",data)
    end

end

function EquipmentScene:OnCardDebrisBuildResponse(msg)
    -- 卡牌合成 成功
   -- OnHandleHeroCard(self,true)
--    local data = require "StaticData.RoleCrap"
--
--    local cardId = data:GetData(msg.cardSuipianID):GetRoleId()
--
--    local node = self.heroCrapDictionary:GetEntryByKey(cardId)
--
--    if node ~= nil then
--        -- 合成成功, 从碎片中移除 --
--        self:RemoveChild(node)
--        node:Clear()
--        self.heroCrapDictionary:Remove(cardId)
--
--
--        -- suipian
--
--        -- self.heroCardPool:Push(node)
--
--    end
--
--    if node:IsCrapMode() then
--    end
--
--

----
----    local node = self.heroCardSpawnedDictionary:GetEntryByKey(cardId)
----    self:RemoveChild(node)
----    node:Clear()
----    self.heroCardPool:Push(node)
----    self.heroCardSpawnedDictionary:Remove(cardId)
--

    local data = require "StaticData.RoleCrap"
    local cardId = data:GetData(msg.cardSuipianID):GetRoleId()
    local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.GeneralCard.GetCardWin",cardId)
end

return EquipmentScene
