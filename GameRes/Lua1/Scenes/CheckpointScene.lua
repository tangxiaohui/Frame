local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CheckpointScene = Class(BaseNodeClass)


-- TODO 这里是第一个章节, 这里需去遍历 但是需要知道根节点!!!!
local firstChapterID = 10900001


-- TODO 这些写常量记得到时候要配表!
local MaxTotalScore = 15

-- end
local function IsChapterFinished(self, chapterId)
    print("IsChapterFinished::::", chapterId)
    local chapterMgr = require "StaticData.Chapter"
    local chapterData = chapterMgr:GetData(chapterId)

    -- 第一个关卡ID --
    local levelID = chapterData:GetFirstLevelID()

    local levelMgr = require "StaticData.ChapterLevel"
    local currentLevelData

    while(levelID > 0)
    do
        currentLevelData = levelMgr:GetData(levelID)

        -- 遍历结束了
        if currentLevelData:GetChapterId() ~= chapterId then
            break
        end

        -- 获取动态数据
        local UserDataType = require "Framework.UserDataType"
        local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
        local star = playerChapterData:GetLevelStar(chapterId, currentLevelData:GetId())
        if star <= 0 then
            -- print("@@@@@@@ ", chapterId, currentLevelData:GetId())
            return false
        end

        levelID = currentLevelData:GetNextLevelId()
    end

    return true
end



local function GetDefaultChapterID(self)
    local chapterID = firstChapterID
    local prevChapterID = chapterID
    local nextChapterID = nil

    local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)
    local playerLevel = playerData:GetLevel()

    repeat
        -- 拿到当前关卡的数据 --
        local ChapterMgr = require "StaticData.Chapter"
        local currentChapterData = ChapterMgr:GetData(chapterID)

        -- 等级不够 选择上一个章节的
        if currentChapterData:GetChapterLv() > playerLevel then
            return prevChapterID
        end

        -- 如果当前的关卡没有完成 --
        if not IsChapterFinished(self, currentChapterData:GetId()) then
            return currentChapterData:GetId()
        end

        -- 获取下一个章节ID --
        nextChapterID = currentChapterData:GetNextChapterID()
        if nextChapterID <= 0 then
            break
        end

        prevChapterID = chapterID
        chapterID = nextChapterID
        nextChapterID = nil

    until(false)

    return chapterID
end

local function InitDefaultChapterID(self)
    -- FIXME: 代码可以运行 但是挺难受的 需要重构!
    if type(self.defaultChapterID) == "number" then
        return
    end

    local LocalDataType = require "LocalData.LocalDataType"
    local localDataEntry = utility.DropLocalData(LocalDataType.FBBattleResult)
    if localDataEntry ~= nil then
        local msg = localDataEntry:GetMainData()
        if msg ~= nil then
            local ChapterLevelUtils = require "Utils.ChapterLevelUtils"
            self.defaultChapterID = ChapterLevelUtils.GetChapterIdFromLevelId(msg.fbID)
            if type(self.defaultChapterID) == "number" and self.defaultChapterID > 0 then
                return
            end
        end
    end

    self.defaultChapterID = GetDefaultChapterID(self)
end

local function InitLevelIDToFight(self, levelIDToFight)
    if type(levelIDToFight) == "number" and levelIDToFight > 0 then
        local UserDataType = require "Framework.UserDataType"
        local userData = self:GetCachedData(UserDataType.PlayerData)
        local playerLevel = userData:GetLevel()

        local ChapterLevelUtils = require "Utils.ChapterLevelUtils"
        if (ChapterLevelUtils.CanPlayTheLevel(levelIDToFight, playerLevel)) then
            self.defaultChapterID = require "StaticData.ChapterLevel":GetData(levelIDToFight):GetChapterId()
            self.autoOpenLevelId = levelIDToFight
        end
    end
end

function CheckpointScene:Ctor(levelIDToFight)
    -- print("CheckpointScene:Ctor", self)
    self.selectedChapter = nil
    InitLevelIDToFight(self, levelIDToFight)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CheckpointScene:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/Checkpoint', function(go)
        self:BindComponent(go)
    end)
end

function CheckpointScene:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    self:InitControls()
    self:InitChapterListView()
end

local function RefreshBoxStatus(button, effectGameObject, redIcon, status)
    if status == kChapterBoxStatus_Unavailable then
        button.interactable = true
        button.targetGraphic.material = utility.GetGrayMaterial()
        effectGameObject:SetActive(false)
        redIcon:SetActive(false)
    elseif status == kChapterBoxStatus_NotReceiveYet then
        button.interactable = true
        button.targetGraphic.material = utility.GetCommonMaterial()
        effectGameObject:SetActive(true)
        redIcon:SetActive(true)
    elseif status == kChapterBoxStatus_Received then
        button.interactable = false
        button.targetGraphic.material = utility.GetGrayMaterial()
        effectGameObject:SetActive(false)
        redIcon:SetActive(false)
    else
        error(string.format("传了未知的状态: %d", status))
    end
end

local function RefreshCompleteStatus(self, chapterId)
--    print(">>>>> 刷新状态111 <<<<<", debug.traceback())

    -- 刷新得分描述
    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    local score = playerChapterData:GetChapterTotalScore(chapterId)
    self.ChapterStarLabel.text = string.format("%d/%d", score, MaxTotalScore)

    -- 刷新进度条
    local ratio = Mathf.Clamp01(score / MaxTotalScore)
    self.ChapterFillFrameSprite.fillAmount = ratio
    -- hzj_print("RefreshCompleteStatus kSystem_Guide[3].systemGuideID")
    -- if playerChapterData:GetChapterCompleteStatus(chapterId, 1) == kChapterBoxStatus_NotReceiveYet then
    --      utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[3].systemGuideID,self)

    -- end

    -- 刷新箱子 --
    RefreshBoxStatus(self.GiftButton05, self.GiftButton05Effect, self.GiftButton05RedIcon, playerChapterData:GetChapterCompleteStatus(chapterId, 1))
    RefreshBoxStatus(self.GiftButton10, self.GiftButton10Effect, self.GiftButton10RedIcon, playerChapterData:GetChapterCompleteStatus(chapterId, 2))
    RefreshBoxStatus(self.GiftButton15, self.GiftButton15Effect, self.GiftButton15RedIcon, playerChapterData:GetChapterCompleteStatus(chapterId, 3))

end


local function WaitForFinished(self, pos)
    while(not utility.IsAllComponentsReady(self.chapterItems))
    do
        coroutine.step(1)
    end

    coroutine.step(1)

    if type(pos) ~= "number" then
        self.ChapterRotationScrollRect.verticalNormalizedPosition = 1
    else
        --local t = ((pos-1)*(1/#self.chapterItems))
        local tuningPos = math.max(0, pos - 3)
        local t = tuningPos * (1 / #self.chapterItems)
        self.ChapterRotationScrollRect.verticalNormalizedPosition = 1 - t
    end

    --print('**** Component Finished! ****')
end

local function RefreshView(self)

    InitDefaultChapterID(self)

    --print("@@@ 默认章节ID", self.defaultChapterID)

    local chapterCount = #self.chapterItems
    local verticalSegment = 1 / chapterCount
    local selectedPos

    -- # 章节Item # --
    for i = 1,  chapterCount do
        if self.chapterItems[i]:GetChapterData():GetId() == self.defaultChapterID then
            self:OnChapterItemSelected(self.chapterItems[i])
            selectedPos = i
            
        end
        self.chapterItems[i]:UpdateView()
    end

    self:StartCoroutine(WaitForFinished, selectedPos)
    

    -- # 关卡Item # --
    for i = 1, #self.levelItems do
        self.levelItems[i]:UpdateView()
    end

    -- # 刷新宝箱状态 # --
    if self.selectedChapter ~= nil then
        local data = self.selectedChapter:GetChapterData()

        -- 得到章节ID
        local chapterID = data:GetId()
        RefreshCompleteStatus(self, chapterID)
    end
 
end

local function OnDelayOpenFightModule(self, levelId)
    coroutine.step(1)
    local levelData = require "StaticData.ChapterLevel":GetData(levelId)
    local CheckpointFightModuleClass = require "GUI.Modules.CheckpointFightModule"
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(CheckpointFightModuleClass, levelData)
end

function CheckpointScene:OnResume()
    -- 界面显示时调用
    CheckpointScene.base.OnResume(self)
    self:RegisterControlEvents()
    self:RegisterNetworkEvents()
    self:RegisterLocalEvents()

    print("新手引导 OnResume >>>>>>> ")
    --- 新手引导
    local guideMgr = utility.GetGame():GetGuideManager()
    guideMgr:AddGuideEvnt(kGuideEvnt_DungeonTips)
    guideMgr:AddGuideEvnt(kGuideEvnt_Select1stDungeon)
    guideMgr:AddGuideEvnt(kGuideEvnt_2ndFBLevelSelect)
    guideMgr:AddGuideEvnt(kGuideEvnt_3rdFBLevelSelect)
     
    guideMgr:SortGuideEvnt()
    guideMgr:ShowGuidance()

    RefreshView(self)
    self:DoSystemGuide()
    
    
    if type(self.autoOpenLevelId) == "number" and self.autoOpenLevelId > 0 then
        self:StartCoroutine(OnDelayOpenFightModule, self.autoOpenLevelId)
        self.autoOpenLevelId = nil
    end

    require "Utils.GameAnalysisUtils".EnterScene("关卡界面")
    require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_ChapterView)

end

function CheckpointScene:OnPause()
    -- 界面隐藏时调用
    CheckpointScene.base.OnPause(self)
    self:UnregisterControlEvents()
    self:UnregisterNetworkEvents()
    self:UnregisterLocalEvents()
    self.defaultChapterID = nil
end

function CheckpointScene:OnEnter()
    -- Node Enter时调用
    CheckpointScene.base.OnEnter(self)
end

function CheckpointScene:OnExit()
    -- Node Exit时调用
    CheckpointScene.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CheckpointScene:InitControls()

    local transform = self:GetUnityTransform()

    local ChapterLevelItemNodeClass = require "GUI.ChapterLevelItemNode"

    print("@@@@ CheckpointScene:InitControls @@@")

    -- 自己缓存控件
    self.levelItems = {
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton01')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton02')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton03')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton04')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton05')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton06')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton07')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton08')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton09')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton10')),
        ChapterLevelItemNodeClass.New(transform:Find('Level/LevelList/CheckpointLevelButton11'))
    }

    for i = 1, #self.levelItems do
        self:AddChild(self.levelItems[i])
    end

    self.LevelScrollView = transform:Find('Level'):GetComponent(typeof(UnityEngine.UI.ScrollRect))

    self.CheckpointRetrunButton = transform:Find('Title/CheckpointReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))

    -- 获取章节滚动条
    self.ChapterRotationScrollRect = transform:Find('Chapter/ChapterRotation'):GetComponent(typeof(UnityEngine.UI.ScrollRect))

    -- 关卡滚动条
    self.LevelScrollRect = transform:Find('Level'):GetComponent(typeof(UnityEngine.UI.ScrollRect))

    -- 关卡右侧的箭头
    self.CheckpointFlipRightButtonImage = transform:Find('CheckpointFlipRightButton'):GetComponent(typeof(UnityEngine.UI.Image))

    -- 获取 transform 挂点
    self.ChapterListTrans = transform:Find('Chapter/ChapterRotation/ChapterList')

    -- 获取章节名字控件
    self.ChapterNameLabel = transform:Find('ChapterInformation/ChapterNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))

    -- 获取章节星级文本
    self.ChapterStarLabel = transform:Find('ChapterInformation/ChapterStarLabel'):GetComponent(typeof(UnityEngine.UI.Text))

    -- 获取章节星级进度条
    self.ChapterFillFrameSprite = transform:Find('ChapterInformation/ChapterSlider/ChapterSliderFillMask/FillFrame'):GetComponent(typeof(UnityEngine.UI.Image))


    -- 三个箱子
    self.GiftButton05 = transform:Find('ChapterInformation/StarAward5Button'):GetComponent(typeof(UnityEngine.UI.Button))
    self.GiftButton05Effect = transform:Find("ChapterInformation/StarAward5Button/EffectCanvas/UI_baoxiang").gameObject
    self.GiftButton05RedIcon = transform:Find("ChapterInformation/StarAward5Button/EffectCanvas/RedIcon").gameObject

    self.GiftButton10 = transform:Find('ChapterInformation/StarAward10Button'):GetComponent(typeof(UnityEngine.UI.Button))
    self.GiftButton10Effect = transform:Find("ChapterInformation/StarAward10Button/EffectCanvas/UI_baoxiang").gameObject
    self.GiftButton10RedIcon = transform:Find("ChapterInformation/StarAward10Button/EffectCanvas/RedIcon").gameObject

    self.GiftButton15 = transform:Find('ChapterInformation/StarAward15Button'):GetComponent(typeof(UnityEngine.UI.Button))
    self.GiftButton15Effect = transform:Find("ChapterInformation/StarAward15Button/EffectCanvas/UI_baoxiang").gameObject
    self.GiftButton15RedIcon = transform:Find("ChapterInformation/StarAward15Button/EffectCanvas/RedIcon").gameObject
end

function CheckpointScene:InitChapterListView()
    -- firstChapterID
    local ChapterMgr = require "StaticData.Chapter"

    local currentChapterData = ChapterMgr:GetData(firstChapterID)

    self.chapterItems = {}

    local ChapterItemNodeClass = require "GUI.ChapterItemNode"

    print("@@@ 默认关卡ID ", self.defaultChapterID)

    repeat
        -- 添加新的Item控件
        local newItem = ChapterItemNodeClass.New(currentChapterData, self.ChapterListTrans)

        newItem:SetCallback(self, self.OnChapterItemSelected)

        self.chapterItems[#self.chapterItems + 1] = newItem
        self:AddChild(newItem)

        local nextChapterID = currentChapterData:GetNextChapterID()
        if nextChapterID ~= 0 then
            currentChapterData = ChapterMgr:GetData(nextChapterID)
        else
            currentChapterData = nil
        end

    until( currentChapterData == nil )
end



-- # 当选中一个关卡后 # --
function CheckpointScene:OnChapterItemSelected(chapterItemNode)

    if chapterItemNode == nil then
        return
    end

    if self.selectedChapter == chapterItemNode then
        return
    end

    if self.selectedChapter ~= nil then
        self.selectedChapter:SetSelected(false)
        self.selectedChapter = nil
    end

    self.selectedChapter = chapterItemNode
    self.selectedChapter:SetSelected(true)

    self:RefreshChapter()

    self.LevelScrollRect.horizontalNormalizedPosition = 0
end

function CheckpointScene:RefreshChapter()
    local data = self.selectedChapter:GetChapterData()

    -- 赋值名字
    self.ChapterNameLabel.text = data:GetChapterInfo():GetName()

    -- 首先都重置
    for i = 1, #self.levelItems do
        self.levelItems[i]:SetData(nil)
    end

    -- 获取当前章节的第一个关卡ID
    local firstLevelID = data:GetFirstLevelID()

    -- 得到章节ID
    local chapterID = data:GetId()

    RefreshCompleteStatus(self, chapterID)

    -- 获取关卡管理器
    local ChapterLevelMgr = require "StaticData.ChapterLevel"

    -- 当前位置/最大位置
    local currentPos = 1
    local maxPos = 11


    local currentLevelData = ChapterLevelMgr:GetData(firstLevelID)

    -- 后置关卡ID
    local nextLevelID

    -- 支线关卡ID
    local branchLevelID

    -- 设置位置 --
    self.levelItems[currentPos]:SetData(currentLevelData)
    --    print(currentPos, '---->>')
    currentPos = currentPos + 1
    repeat
        if currentPos > maxPos then break end

        -- 获取两个ID
        nextLevelID = currentLevelData:GetNextLevelId()
        branchLevelID = currentLevelData:GetBranchLevelId()

        -- 设置为nil
        currentLevelData = nil

        -- 有后置关卡??
        if nextLevelID ~= 0 then
            currentLevelData = ChapterLevelMgr:GetData(nextLevelID)
            self.levelItems[currentPos]:SetData(currentLevelData)
            --            print(currentPos, '---->>')
            currentPos = currentPos + 1
            if currentPos > maxPos then break end

            if currentLevelData:GetChapterId() ~= chapterID then
                currentLevelData = nil
            end
        end

        -- 有支线关卡??
        if branchLevelID ~= 0 then
            local levelData = ChapterLevelMgr:GetData(branchLevelID)
            self.levelItems[currentPos]:SetData(levelData)
            --            print(currentPos, '---->>')
            currentPos = currentPos + 1
            if currentPos > maxPos then break end
        end

    until(currentLevelData == nil)
end

function CheckpointScene:RegisterControlEvents()
    -- 注册 CheckpointRetrunButton 的事件
    self.__event_button_onCheckpointRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckpointRetrunButtonClicked, self)
    self.CheckpointRetrunButton.onClick:AddListener(self.__event_button_onCheckpointRetrunButtonClicked__)

    -- 注册 LevelScrollRect 的事件
    self.__event_scrollrect_onLevelValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnLevelValueChanged, self)
    self.LevelScrollRect.onValueChanged:AddListener(self.__event_scrollrect_onLevelValueChanged__)

    -- GiftButton05
    self.__event_button_giftButton05Clicked__ = UnityEngine.Events.UnityAction(self.OnGiftButton05, self)
    self.GiftButton05.onClick:AddListener(self.__event_button_giftButton05Clicked__)

    -- GiftButton10
    self.__event_button_giftButton10Clicked__ = UnityEngine.Events.UnityAction(self.OnGiftButton10, self)
    self.GiftButton10.onClick:AddListener(self.__event_button_giftButton10Clicked__)

    -- GiftButton15
    self.__event_button_giftButton15Clicked__ = UnityEngine.Events.UnityAction(self.OnGiftButton15, self)
    self.GiftButton15.onClick:AddListener(self.__event_button_giftButton15Clicked__)
end

function CheckpointScene:UnregisterControlEvents()
    print('UnregisterControlEvents')
    -- 取消注册 CheckpointRetrunButton 的事件
    if self.__event_button_onCheckpointRetrunButtonClicked__ then
        self.CheckpointRetrunButton.onClick:RemoveListener(self.__event_button_onCheckpointRetrunButtonClicked__)
        self.__event_button_onCheckpointRetrunButtonClicked__ = nil
    end

    -- 取消注册 Level 的事件
    if self.__event_scrollrect_onLevelValueChanged__ then
        self.LevelScrollRect.onValueChanged:RemoveListener(self.__event_scrollrect_onLevelValueChanged__)
        self.__event_scrollrect_onLevelValueChanged__ = nil
    end

    -- GiftButton05
    if self.__event_button_giftButton05Clicked__ then
        self.GiftButton05.onClick:RemoveListener(self.__event_button_giftButton05Clicked__)
        self.__event_button_giftButton05Clicked__ = nil
    end

    -- GiftButton10
    if self.__event_button_giftButton10Clicked__ then
        self.GiftButton10.onClick:RemoveListener(self.__event_button_giftButton10Clicked__)
        self.__event_button_giftButton10Clicked__ = nil
    end

    -- GiftButton15
    if self.__event_button_giftButton15Clicked__ then
        self.GiftButton15.onClick:RemoveListener(self.__event_button_giftButton15Clicked__)
        self.__event_button_giftButton15Clicked__ = nil
    end
end

function CheckpointScene:RegisterNetworkEvents()
    print("注册网络事件 >>>>> 1")
    local net = require "Network.Net"
    self:GetGame():RegisterMsgHandler(net.S2CFBDrawCompleteAwardResult, self, self.OnDrawCompleteAwardResult)
	self:GetGame():RegisterMsgHandler(net.S2CPlayerLevelUpResult,self,self.OnPlayerLevelUpResult)
end

function CheckpointScene:UnregisterNetworkEvents()
    print("注册网络事件 >>>>>> 2")
    local net = require "Network.Net"
    self:GetGame():UnRegisterMsgHandler(net.S2CFBDrawCompleteAwardResult, self, self.OnDrawCompleteAwardResult)
	self:GetGame():UnRegisterMsgHandler(net.S2CPlayerLevelUpResult,self,self.OnPlayerLevelUpResult)
end

local function OnRefreshChapterView(self)
    --self:RefreshChapter()
    for i = 1, #self.chapterItems do
        self.chapterItems[i]:UpdateView()
    end
end

local function OnUpdatedAllMap(self, _)
    self:RefreshChapter()
    for i = 1, #self.chapterItems do
        if not self.chapterItems[i]:UpdateView() then
            break
        end
    end
end

function CheckpointScene:RegisterLocalEvents()
    local MessageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(MessageGuids.RefreshChapterView, OnRefreshChapterView)
    self:RegisterEvent(MessageGuids.UpdatedAllMapData, OnUpdatedAllMap)
end

function CheckpointScene:UnregisterLocalEvents()
    local MessageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(MessageGuids.RefreshChapterView, OnRefreshChapterView)
    self:UnregisterEvent(MessageGuids.UpdatedAllMapData, OnUpdatedAllMap)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

function CheckpointScene:OnCheckpointRetrunButtonClicked()
    --CheckpointRetrunButton控件的点击事件处理
    local myGame = self:GetGame()
    local sceneManager = myGame:GetSceneManager()
    sceneManager:PopScene()
end

function CheckpointScene:OnLevelValueChanged(posXY)
    local alpha = 1 - Mathf.Clamp01(posXY.x)
    local color = self.CheckpointFlipRightButtonImage.color
    color.a = alpha
    self.CheckpointFlipRightButtonImage.color = color
end


function CheckpointScene:OnGiftButton05()
    local data = self.selectedChapter:GetChapterData()
    local chapterID = data:GetId()

    local CheckpointStarBoxClass = require "GUI.Modules.CheckpointStarBox"
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(CheckpointStarBoxClass, chapterID, 1)
      self:DoSystemGuide()
end

function CheckpointScene:OnGiftButton10()
    local data = self.selectedChapter:GetChapterData()
    local chapterID = data:GetId()


    local CheckpointStarBoxClass = require "GUI.Modules.CheckpointStarBox"
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(CheckpointStarBoxClass, chapterID, 2)
end

function CheckpointScene:OnGiftButton15()
    local data = self.selectedChapter:GetChapterData()
    local chapterID = data:GetId()


    local CheckpointStarBoxClass = require "GUI.Modules.CheckpointStarBox"
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(CheckpointStarBoxClass, chapterID, 3)
end

function CheckpointScene:OnDrawCompleteAwardResult(msg)
    print("事件更新!!!!!!!!!>>")
    local data = self.selectedChapter:GetChapterData()
    local chapterID = data:GetId()
    RefreshCompleteStatus(self, chapterID)
  
    self.selectedChapter:UpdateRedDotStatus()
end

function CheckpointScene:DoSystemGuide()
    print("事件更新!!!!!!!!!>>")
    local data = self.selectedChapter:GetChapterData()
    local chapterId = data:GetId()



    -- 刷新得分描述
    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)

    hzj_print("DoSystemGuide kSystem_Guide[3].systemGuideID")
    
    if playerChapterData:GetChapterCompleteStatus(chapterId, 1) == kChapterBoxStatus_NotReceiveYet then
         utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[3].systemGuideID,self)

    end
   
end

function CheckpointScene:OnPlayerLevelUpResult(msg)
	local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.LevelUpPanel",msg)
end


return CheckpointScene