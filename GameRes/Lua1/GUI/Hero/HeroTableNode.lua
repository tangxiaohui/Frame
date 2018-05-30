--
-- User: fenghao
-- Date: 14/06/2017
-- Time: 5:51 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local HeroTableNode = Class(BaseNodeClass)

require "Collection.OrderedDictionary"
require "Collection.DataStack"
require "Const"

local utility = require "Utils.Utility"

local UnityEngine_Color = UnityEngine.Color

function HeroTableNode:GetSelectedItemID()
    if self.currentSelectedItem ~= nil then
        return self.currentSelectedItem:GetID()
    end
    return 0
end

function HeroTableNode:GetSelectedItemUID()
    if self.currentSelectedItem ~= nil then
        return self.currentSelectedItem:GetUID()
    end
    return 0
end

local function OnHeroCardItemClicked(self, heroCardItem)
    local mode = heroCardItem:GetMode()
    if mode == kCardItemMode_Got or mode == kCardItemMode_NotGetYet then
        if self.currentSelectedItem ~= heroCardItem then
            -- 处理选中逻辑 --
            if self.currentSelectedItem ~= nil then self.currentSelectedItem:SetSelected(false) end
            self.currentSelectedItem = heroCardItem
            if self.currentSelectedItem ~= nil then self.currentSelectedItem:SetSelected(true) end

            local previousID = self.defaultSelectionID
            self.defaultSelectionID = self.currentSelectedItem:GetID()

            -- 发送进入详细页面的消息 --
            local UserDataType = require "Framework.UserDataType"
            local cardBagData = self:GetCachedData(UserDataType.CardBagData)
            -- debug_print(self.currentSelectedItem:GetID(),"self.currentSelectedItem:GetID()")
            local userRoleData = cardBagData:GetRoleById(self.currentSelectedItem:GetID())

            local messageGuids = require "Framework.Business.MessageGuids"
            local needToRefresh = previousID ~= self.defaultSelectionID
            self:DispatchEvent(messageGuids.HeroDetailViewRefresh, nil, self.currentSelectedItem:GetID(), userRoleData, needToRefresh, needToRefresh)
        end

        if mode == kCardItemMode_NotGetYet then
            if heroCardItem:GetCurrentFragmentNumber() >= heroCardItem:GetRequiredFragmentNumber() then
                local fragmentID = require "StaticData.Role":GetData(heroCardItem:GetID()):GetScrapId()
                self:GetGame():SendNetworkMessage( require "Network.ServerService".CardSuipianBuildRequest(fragmentID) )
            end
        end
    end
end

local function ResortHeroCard(self)
    self.heroCardIndexDictionary:Sort(function(entry1, entry2)
        local UserDataType = require "Framework.UserDataType"
        local cardBagData = self:GetCachedData(UserDataType.CardBagData)
        local userRoleData1 = cardBagData:GetRoleById(entry1:GetID())
        local userRoleData2 = cardBagData:GetRoleById(entry2:GetID())
        return utility.CompareCardByRoleData(userRoleData1, userRoleData2)
    end)


    local spawnedCount = self.heroCardIndexDictionary:Count()
    for i = 1, spawnedCount do
        local node = self.heroCardIndexDictionary:GetEntryByIndex(i)
        node:SetSiblingIndex(i)
    end
end


local function CompareFragments(entry1, entry2)
    local entry1Finished = entry1:GetCurrentFragmentNumber() >= entry1:GetRequiredFragmentNumber()
    local entry2Finished = entry2:GetCurrentFragmentNumber() >= entry2:GetRequiredFragmentNumber()

    if entry1Finished then
        if not entry2Finished then
            return true
        end
    end

    if entry2Finished then
        if not entry1Finished then
            return false
        end
    end

    return entry1:GetCurrentFragmentNumber() > entry2:GetCurrentFragmentNumber()
end

local function ResortHeroCardFragment(self)
    self.heroFragmentIndexDictionary:Sort(CompareFragments)

    local spawnedCount = self.heroFragmentIndexDictionary:Count()
    for i = 1, spawnedCount do
        local node = self.heroFragmentIndexDictionary:GetEntryByIndex(i)
        node:SetSiblingIndex(i)
    end
end

local function OnUpdatedCard(self, userRoleData)
	
	print("OnUpdatedCard >>>>> 1")

	if userRoleData == nil then
		return
	end	
	
	print("OnUpdatedCard >>>>> 2")

	if not userRoleData:IsShowInCollection() then
        return
    end
	
	print("OnUpdatedCard >>>>> 3")
	
	--if self.currentSelectedItem ~= nil and self.currentSelectedItem:GetID() == userRoleData:GetId() and self.currentSelectedItem:GetUID() == userRoleData:GetUid() then
	local entry = self.heroCardIndexDictionary:GetEntryByKey(userRoleData:GetId())
	if entry ~= nil and entry:GetMode() == kCardItemMode_Got then
		entry:SetLevel(userRoleData:GetLv())
		entry:SetColorID(userRoleData:GetColor())
		-- 排序 --
		ResortHeroCard(self)
		
		-- 发消息 --
		local messageGuids = require "Framework.Business.MessageGuids"
        debug_print("local messageGuids = require")
		self:DispatchEvent(messageGuids.HeroDetailViewRefresh, nil, self.currentSelectedItem:GetID(), userRoleData, true , true, true)
	end
	--end
	
end

local function OnAddedNewCard(self, userRoleData)
    if not userRoleData:IsShowInCollection() then
        return
    end

    local cardId = userRoleData:GetId()

    local entry = self.heroFragmentIndexDictionary:GetEntryByKey(cardId)

    if entry ~= nil and entry:GetMode() == kCardItemMode_NotGetYet then
        -- 重新设置模式 --
        entry:SetMode(kCardItemMode_Got)
        entry:SetID(userRoleData:GetId())
        entry:SetUID(userRoleData:GetUid())
        entry:SetRaceID((userRoleData:GetRace()))
        entry:SetLevel(userRoleData:GetLv())
        entry:SetColorID(userRoleData:GetColor())
        entry:SetStar(userRoleData:GetStar())
		entry:SetRarity(userRoleData:GetRarity())
        entry:SetIconName(userRoleData:GetHeadIcon())
        entry:SetRequiredFragmentNumber(0)
        entry:SetCurrentFragmentNumber(0)
        entry:SetCustomName(string.format("HeroCardItem%d", self.heroCardIndexDictionary:Count() + 1))
        entry:SetParentTransform(self.heroGotGridListTrans)

        -- 从碎片字典中移除
        self.heroFragmentIndexDictionary:Remove(entry:GetID())

        -- 重新加入到卡牌字典
        self.heroCardIndexDictionary:Add(entry:GetID(), entry)

        -- 排序 --
        ResortHeroCard(self)

        -- 发消息 --
        local messageGuids = require "Framework.Business.MessageGuids"
        debug_print("Framework.Business.MessageGuids")
        self:DispatchEvent(messageGuids.HeroDetailViewRefresh, nil, self.currentSelectedItem:GetID(), userRoleData, self.currentSelectedItem:GetID() ~= entry:GetID() , true)
    end
end

local function OnAddedCardCrap(self, cardFragmentData)
    local roleID = require "StaticData.RoleCrap":GetData(cardFragmentData:GetId()):GetRoleId()
    local entry = self.heroFragmentIndexDictionary:GetEntryByKey(roleID)
    if entry ~= nil then
        entry:SetCurrentFragmentNumber(cardFragmentData:GetNumber())
        ResortHeroCardFragment(self)
    end
end

local function OnUpdatedCardCrap(self, cardFragmentData)
    local roleID = require "StaticData.RoleCrap":GetData(cardFragmentData:GetId()):GetRoleId()
    local entry = self.heroFragmentIndexDictionary:GetEntryByKey(roleID)
    if entry ~= nil then
        entry:SetCurrentFragmentNumber(cardFragmentData:GetNumber())
        ResortHeroCardFragment(self)
    end
end

-- 处理切换的逻辑
local function OnSelectHero(self, selected)
    if selected then
        self.heroButtonText.color = UnityEngine_Color(1,1,1,1)
        self.heroButton.targetGraphic.color = UnityEngine_Color(1,1,1,1)
        self.heroButtonOutline.enabled = true
        self.heroCardGroup:SetActive(true)

        -- 从Pool中拿取, 显示英雄卡牌 --
        local UserDataType = require "Framework.UserDataType"
        local cardBagData = self:GetCachedData(UserDataType.CardBagData)

        local ownedCount = cardBagData:RoleCount() -- # 拥有的个数 # --

        local selectedItem

        local haveValidSelectionID = type(self.defaultSelectionID) == "number" and self.defaultSelectionID > 0

        local ownedItems = {}

        --- ### 创建拥有的卡牌 ### ---
        for i = 1, ownedCount do
            local userCardData = cardBagData:GetRoleByPos(i)
            if userCardData ~= nil and userCardData:IsShowInCollection() then
                local node = self.heroCardPool:Pop()
                node:SetMode(kCardItemMode_Got)
                node:SetSelectionMode(kCardItemSelectionMode_Radio)
                node:SetID(userCardData:GetId())
                node:SetUID(userCardData:GetUid())
                node:SetRaceID((userCardData:GetRace()))
                node:SetLevel(userCardData:GetLv())
                node:SetColorID(userCardData:GetColor())
                node:SetStar(userCardData:GetStar())
				node:SetRarity(userCardData:GetRarity())
                node:SetIconName(userCardData:GetHeadIcon())
                node:SetRequiredFragmentNumber(0)
                node:SetCurrentFragmentNumber(0)
                node:SetSelected(false)
                node:SetCustomName(string.format("HeroCardItem%d", self.heroCardIndexDictionary:Count() + 1))
                node:SetParentTransform(self.heroGotGridListTrans)

                if not haveValidSelectionID then
                    if selectedItem == nil then
                        selectedItem = node
                    end
                else
                    if node:GetID() == self.defaultSelectionID and selectedItem == nil then
                        selectedItem = node
                    end
                end

                -- 加入到子控件中 --
                self:AddChild(node)

                -- 英雄索引存储 --
                self.heroCardSpawnedDictionary:Add(node:GetID(), node)
                self.heroCardIndexDictionary:Add(node:GetID(), node)

                ownedItems[node:GetID()] = true
            end
        end

        --- ### 创建未拥有的卡牌 ### ---
        local fragmentBagData = self:GetCachedData(UserDataType.CardChipBagData)
        local roleManager = Data.Role.Manager.Instance()
        local keys = roleManager:GetKeys()
        local keyLength = keys.Length
        for i = 1, keyLength do
            local heroID = keys[i - 1]
            if not ownedItems[heroID] then
                local staticRole = require "StaticData.Role":GetData(heroID)
                if staticRole ~= nil and staticRole:IsShowInCollection() then
                    local node = self.heroCardPool:Pop()
                    node:SetMode(kCardItemMode_NotGetYet)
                    node:SetSelectionMode(kCardItemSelectionMode_Radio)
                    node:SetID(staticRole:GetId())
                    node:SetUID("")
                    node:SetRaceID((staticRole:GetRace()))
                    node:SetLevel(1)
                    node:SetColorID(staticRole:GetColorID())
                    node:SetStar(staticRole:GetStar())
					node:SetRarity(staticRole:GetRarity())
                    node:SetIconName(staticRole:GetHeadIcon())
                    node:SetRequiredFragmentNumber(staticRole:GetComposeNum())
                    node:SetCurrentFragmentNumber(fragmentBagData:GetCardChipCount(staticRole:GetScrapId()))
                    node:SetSelected(false)
                    node:SetParentTransform(self.heroNotGetYetGridListTrans)

                    if not haveValidSelectionID then
                        if selectedItem == nil then
                            selectedItem = node
                        end
                    else
                        if node:GetID() == self.defaultSelectionID and selectedItem == nil then
                            selectedItem = node
                        end
                    end

--                    -- 加入到子控件中 --
--                    self:AddChild(node)

                    -- 英雄索引存储 --
                    self.heroCardSpawnedDictionary:Add(node:GetID(), node)
                    self.heroFragmentIndexDictionary:Add(node:GetID(), node)
                end
            end
        end

        -- 排序并且加入到Child中 --
        self.heroFragmentIndexDictionary:Sort(CompareFragments)
        local spawnedCount = self.heroFragmentIndexDictionary:Count()
        for i = 1, spawnedCount do
            local node = self.heroFragmentIndexDictionary:GetEntryByIndex(i)
            self:AddChild(node)
        end

        if selectedItem ~= nil then
            OnHeroCardItemClicked(self, selectedItem)
        end
    else
        self.heroButtonText.color = UnityEngine_Color(0,0,0,1)
        self.heroButton.targetGraphic.color = UnityEngine_Color(0.6039216, 0.6039216, 0.6039216, 1)
        self.heroButtonOutline.enabled = false

        -- 需要把控件归还到Pool中 --
        local spawnedCount = self.heroCardSpawnedDictionary:Count()
        for i = 1, spawnedCount do
            local node = self.heroCardSpawnedDictionary:GetEntryByIndex(i)
            self:RemoveChild(node)
            node:UnlinkComponent(self.cardItemPoolTrans)
            self.heroCardPool:Push(node)
        end
        self.heroCardSpawnedDictionary:Clear()
        self.heroCardIndexDictionary:Clear()
        self.heroFragmentIndexDictionary:Clear()

--        self.currentSelectedItem = nil

        self.heroCardGroup:SetActive(false)
    end
end

local function OnSelectFragment(self, selected)
    if selected then
        self.fragmentButtonText.color = UnityEngine_Color(1,1,1,1)
        self.fragmentButton.targetGraphic.color = UnityEngine_Color(1,1,1,1)
        self.fragmentButtonOutline.enabled = true
        self.heroFragmentGroup:SetActive(true)

        -- 需要从Pool中拿取, 显示英雄碎片 --
        local UserDataType = require "Framework.UserDataType"
        local fragmentBagData = self:GetCachedData(UserDataType.CardChipBagData)
        local ownedFragmentCount = fragmentBagData:GetCount()

        for i = 1, ownedFragmentCount do
            local fragmentUserData = fragmentBagData:GetDataByIndex(i)

            -- 拿到用户碎片数据
            if fragmentUserData ~= nil then

                local fragmentID = fragmentUserData:GetId()

                local staticFragment = require "StaticData.RoleCrap":GetData(fragmentID)
                -- 拿到静态碎片数据 --
                if staticFragment ~= nil then

                    local roleID = staticFragment:GetRoleId()
                    local staticRole = require "StaticData.Role":GetData(roleID)
                    if staticRole ~= nil and staticRole:IsShowInCollection() then

                        -- 可以显示! --
                        local node = self.heroCardPool:Pop()
                        node:SetMode(kCardItemMode_Fragment)
                        node:SetSelectionMode(kCardItemSelectionMode_None)
                        node:SetID(staticRole:GetId())
                        node:SetUID("")
                        node:SetRaceID((staticRole:GetRace()))
                        node:SetLevel(1)
                        node:SetColorID(staticRole:GetColorID())
                        node:SetStar(staticRole:GetStar())
						node:SetRarity(staticRole:GetRarity())
                        node:SetIconName(staticRole:GetHeadIcon())
                        node:SetRequiredFragmentNumber(staticRole:GetComposeNum())
                        node:SetCurrentFragmentNumber(fragmentBagData:GetCardChipCount(staticRole:GetScrapId()))
                        node:SetSelected(false)
                        node:SetParentTransform(self.heroFragmentGridListTrans)

                        -- 加入到子控件中 --
                        self:AddChild(node)

                        -- 加入到已生成列表
                        self.heroCardSpawnedDictionary:Add(node:GetID(), node)

                        -- 加入到碎片列表
                        self.heroFragmentIndexDictionary:Add(node:GetID(), node)
                    end

                end
            end
        end

    else
        self.fragmentButtonText.color = UnityEngine_Color(0,0,0,1)
        self.fragmentButton.targetGraphic.color = UnityEngine_Color(0.6039216, 0.6039216, 0.6039216, 1)
        self.fragmentButtonOutline.enabled = false

        -- 需要把控件归还到Pool中 --
        local spawnedCount = self.heroCardSpawnedDictionary:Count()
        for i = 1, spawnedCount do
            local node = self.heroCardSpawnedDictionary:GetEntryByIndex(i)
            self:RemoveChild(node)
            node:UnlinkComponent(self.cardItemPoolTrans)
            self.heroCardPool:Push(node)
        end
        self.heroCardSpawnedDictionary:Clear()
        self.heroCardIndexDictionary:Clear()
        self.heroFragmentIndexDictionary:Clear()

--        self.currentSelectedItem = nil

        self.heroFragmentGroup:SetActive(false)
    end
end

-- 处理点击的
local function GoToHeroTable(self)
    self.currentTableType = kHeroSceneTableType_Hero
    OnSelectFragment(self, false)
    OnSelectHero(self, true)
end

local function GoToFragmentTable(self)
    self.currentTableType = kHeroSceneTableType_Fragment
    OnSelectHero(self, false)
    OnSelectFragment(self, true)
end

local function CacheControls(self)
    -- 预先创建池
    local HeroCardItemNodeClass = require "GUI.HeroCardItemNode"
    local roleManager = Data.Role.Manager.Instance()
    local keys = roleManager:GetKeys()
    local length = keys.Length
    for i = 1, length do
        local roleData = roleManager:GetObject(keys[i - 1])
        if roleData ~= nil and roleData.ShowInCollection ~= 0 then
            local node = HeroCardItemNodeClass.New()
            self.heroCardPool:Push(node)
        end
    end
end

local function DelayGoToHeroTable(self)
    coroutine.step(1)
    -- 初始是英雄标签 --
    GoToHeroTable(self)
end

local function Init(self)
    -- 缓存 --
    CacheControls(self)

    -- 延时启动 --
    self:StartCoroutine(DelayGoToHeroTable)
end

-- 初始化控件 --
local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 英雄按钮 和 碎片按钮
    self.heroButton = transform:Find("HeroButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.heroButtonText = transform:Find("HeroButton/Text"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroButtonOutline = self.heroButtonText:GetComponent(typeof(UnityEngine.UI.Outline))

    self.fragmentButton = transform:Find("FragmentButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.fragmentButtonText = transform:Find("FragmentButton/Text"):GetComponent(typeof(UnityEngine.UI.Text))
    self.fragmentButtonOutline = self.fragmentButtonText:GetComponent(typeof(UnityEngine.UI.Outline))

    -- 英雄滚动条控件
    self.heroCardGroup = transform:Find("HeroScrollGroup").gameObject
    self.heroCardScrollView = transform:Find("HeroScrollGroup/Scroll View"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
    self.heroGotGridListTrans = transform:Find("HeroScrollGroup/Scroll View/Viewport/Content/CurrentHeroGridList")
    self.heroNotGetYetGridListTrans = transform:Find("HeroScrollGroup/Scroll View/Viewport/Content/NotGetHeroGridList")

    -- 碎片滚动条控件
    self.heroFragmentGroup = transform:Find("FragmentScrollGroup").gameObject
    self.heroFragmentScrollView = transform:Find("FragmentScrollGroup/Scroll View"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
    self.heroFragmentGridListTrans = transform:Find("FragmentScrollGroup/Scroll View/Viewport/Content")

    -- CardItemNode缓冲池的Transform
    self.cardItemPoolTrans = transform:Find("CardPool")

    Init(self)
end

function HeroTableNode:Ctor(parentTransform, rootAnimator)
    self.rootAnimator = rootAnimator

    -- 对象池
    self.heroCardPool = DataStack.New()

    -- 以生成字典
    self.heroCardSpawnedDictionary = OrderedDictionary.New()

    -- 英雄卡牌 --
    self.heroCardIndexDictionary = OrderedDictionary.New()

    -- 英雄碎片 --
    self.heroFragmentIndexDictionary = OrderedDictionary.New()

    -- 默认选中的ID --
    self.defaultSelectionID = nil

    -- 临时变量 当前选中的 Item
    self.currentSelectedItem = nil


    self:BindComponent(parentTransform.gameObject, false)
    InitControls(self)
end

local function OnHeroButtonClicked(self)
    if self.currentTableType == kHeroSceneTableType_Hero then
        return
    end
    GoToHeroTable(self)
end

local function OnFragmentButtonClicked(self)
    if self.currentTableType == kHeroSceneTableType_Fragment then
        return
    end
    GoToFragmentTable(self)
end


local function FoundCurrentHeroItemIndex(self)
    local count = self.heroCardIndexDictionary:Count()
    for i = 1, count do
        local entry = self.heroCardIndexDictionary:GetEntryByIndex(i)
        if entry == self.currentSelectedItem then
            return i
        end
    end
    return nil
end

local function OnHeroCardLeftSwitch(self)

    print("@@@>> OnHeroCardLeftSwitch .. 1")

    -- left
    if self.heroCardIndexDictionary:Count() <= 1 then
        return
    end

    print("@@@>> OnHeroCardLeftSwitch .. 2")

    -- 未找到位置
    local foundPos = FoundCurrentHeroItemIndex(self)
    if not foundPos then
        return
    end

    print("@@@>> OnHeroCardLeftSwitch .. 3")

    local count = self.heroCardIndexDictionary:Count()
    local nextPos = foundPos - 1
    if nextPos < 1 then
        nextPos = count
    end

    print("@@@>> OnHeroCardLeftSwitch .. 4")

    local currentItem = self.heroCardIndexDictionary:GetEntryByIndex(nextPos)
    OnHeroCardItemClicked(self, currentItem)
end

local function OnHeroCardRightSwitch(self)
    --> right <--
    if self.heroCardIndexDictionary:Count() <= 1 then
        return
    end

    -- 未找到位置
    local foundPos = FoundCurrentHeroItemIndex(self)
    if not foundPos then
        return
    end

    local count = self.heroCardIndexDictionary:Count()
    local nextPos = foundPos + 1
    if nextPos > count then
        nextPos = 1
    end

    local currentItem = self.heroCardIndexDictionary:GetEntryByIndex(nextPos)
    OnHeroCardItemClicked(self, currentItem)
end

function HeroTableNode:LocalRedDotChanged()
    
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
   
   -- hzj_print("HeroTableNode:LocalRedDotChanged",cardBagData:RoleCount())
    for i=1,cardBagData:RoleCount() do
        local userCardData = cardBagData:GetRoleByPos(i)
         -- hzj_print("HeroTableNode:LocalRedDotChanged",userCardData)
        if userCardData ~= nil then
            local roleID = userCardData:GetId()  
            --hzj_print(roleID,"HeroTableNode:LocalRedDotChanged")
            local currentItem = self.heroCardIndexDictionary:GetEntryByKey(roleID)
            if currentItem ~= nil then
               -- hzj_print(roleID,"HeroTableNode:LocalRedDotChanged")
                currentItem:UpdateRedDotStatus()
            end
        end
    end
end

local function RegisterEvents(self)
    -- hero
    self.__event_heroButtonClicked__ = UnityEngine.Events.UnityAction(OnHeroButtonClicked, self)
    self.heroButton.onClick:AddListener(self.__event_heroButtonClicked__)

    -- fragment
    self.__event_fragmentButtonClicked__ = UnityEngine.Events.UnityAction(OnFragmentButtonClicked, self)
    self.fragmentButton.onClick:AddListener(self.__event_fragmentButtonClicked__)


    -- 注册卡牌点击事件
    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.HeroCardItemClicked, OnHeroCardItemClicked, nil)

    -- 注册增加卡牌事件
    self:RegisterEvent(messageGuids.AddedOneCard, OnAddedNewCard, nil)
	self:RegisterEvent(messageGuids.UpdatedOneCard, OnUpdatedCard, nil)

    -- 左切/右切
    self:RegisterEvent(messageGuids.HeroCardLeftSwitch, OnHeroCardLeftSwitch, nil)
    self:RegisterEvent(messageGuids.HeroCardRightSwitch, OnHeroCardRightSwitch, nil)

    -- 注册碎片数量变更事件
    self:RegisterEvent(messageGuids.AddedOneCardCrap, OnAddedCardCrap, nil)
    self:RegisterEvent(messageGuids.UpdatedOneCardCrap, OnUpdatedCardCrap, nil)

    -- 红点状态更新
     self:RegisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)

end

local function UnregisterEvents(self)
    -- hero
    if self.__event_heroButtonClicked__ then
        self.heroButton.onClick:RemoveListener(self.__event_heroButtonClicked__)
        self.__event_heroButtonClicked__ = nil
    end

    -- fragment
    if self.__event_fragmentButtonClicked__ then
        self.fragmentButton.onClick:RemoveListener(self.__event_fragmentButtonClicked__)
        self.__event_fragmentButtonClicked__ = nil
    end

    -- 取消注册卡牌点击事件
    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.HeroCardItemClicked, OnHeroCardItemClicked, nil)

    -- 取消注册新增卡牌事件
    self:UnregisterEvent(messageGuids.AddedOneCard, OnAddedNewCard, nil)
	self:UnregisterEvent(messageGuids.UpdatedOneCard, OnUpdatedCard, nil)

    -- 左切/右切
    self:UnregisterEvent(messageGuids.HeroCardLeftSwitch, OnHeroCardLeftSwitch, nil)
    self:UnregisterEvent(messageGuids.HeroCardRightSwitch, OnHeroCardRightSwitch, nil)

    -- 取消注册碎片数量变更事件
    self:UnregisterEvent(messageGuids.AddedOneCardCrap, OnAddedCardCrap, nil)
    self:UnregisterEvent(messageGuids.UpdatedOneCardCrap, OnUpdatedCardCrap, nil)

    -- 取消红点更新事件
    self:UnregisterEvent(messageGuids.LocalRedDotChanged,self.LocalRedDotChanged)

end

function HeroTableNode:OnResume()
    HeroTableNode.base.OnResume(self)
    RegisterEvents(self)
end

function HeroTableNode:OnPause()
    HeroTableNode.base.OnPause(self)
    UnregisterEvents(self)
end


return HeroTableNode