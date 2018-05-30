
local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local game = utility.GetGame()
local probability = require "Utils.Probability"

local PlayerCreatedScene = Class(BaseNodeClass)

function PlayerCreatedScene:Ctor()
    self.photographIcons = {}
end

function PlayerCreatedScene:OnInit()
    -- 加载登录页面
    utility.LoadNewGameObjectAsync('UI/Prefabs/PlayerCreated', function(go)
        self:BindComponent(go)
    end)
end

-----------------------------------------------------------------------
--- 卡牌选择(私有函数)
-----------------------------------------------------------------------
local function SelectCardById(self, cardId)
    self.selectedCardID = cardId
end

local function GetSelectedCardID(self)
    return self.selectedCardID
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function PlayerCreatedScene:OnComponentReady()
    self:InitControls()
end

function PlayerCreatedScene:OnEnter()
    probability:SetSeed(os.time())
    PlayerCreatedScene.base.OnEnter(self)

    -- 设置当前阶段为注册!
    local GamePhase = require "Game.GamePhase"
    self:GetGame():SetGamePhase(GamePhase.Register)
end

function PlayerCreatedScene:OnResume()
    PlayerCreatedScene.base.OnResume(self)
    self:RefreshStatus()
    self:RegisterControlEvents()
    self:RegisterMessages()

    -- video image --
    self:GetVideoPlayerManager():SetShowTarget(self.videoImage)
end

function PlayerCreatedScene:OnPause()
    PlayerCreatedScene.base.OnPause(self)

    self:UnregisterControlEvents()
    self:UnregisterMessages()

    --- 停止视频 ---
    self:GetVideoPlayerManager():Stop()
    self:GetVideoPlayerManager():ClearShowTarget()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------

-- # 跳过视频相关
local function StopPassButton(self)
    if self.coPassVideoHandle ~= nil then
        self:StopCoroutine(self.coPassVideoHandle)
        self.coPassVideoHandle = nil
        self.PassVideoButton.gameObject:SetActive(false)
    end
end

local function AutoHidePassButton(self)
    coroutine.wait(6)
    StopPassButton(self)
 end
 
function PlayerCreatedScene:OnShowPassVideoButtonClicked()
     StopPassButton(self)
     self.PassVideoButton.gameObject:SetActive(true)
     self.coPassVideoHandle = self:StartCoroutine(AutoHidePassButton)
end

local function OnVideoDelayEnd(self)
    StopPassButton(self)
    -- group1 该出来了! --
    self.group1Object:SetActive(true)

    -- videoImage 慢慢消失 --
    self.videoImage:CrossFadeAlpha(1, 0, true)
    self.videoImage:CrossFadeAlpha(0, 0.2, true)

    coroutine.wait(0.3)

    -- group2 该消失了! --
    self.group2Object:SetActive(false)

    self:GetAudioManager():FadeInBGM(1003)
end

function PlayerCreatedScene:OnPassVideoButtonClicked()
    --- 停止视频 ---
    self:GetVideoPlayerManager():Stop()
    self:StartCoroutine(OnVideoDelayEnd)
end

-- 视频播放器 事件 --
local function OnVideoEndReached(self, _)
    self:StartCoroutine(OnVideoDelayEnd)    
end

local function OnVideoPrepared(self, _)
    self.videoImage.color = UnityEngine.Color(1, 1, 1, 1)
end

local function OnVideoError(self, _)
end

local function PlaySplashVideo(self)
    self.videoImage.color = UnityEngine.Color(0, 0, 0, 1)

    coroutine.step(1)

    local videoPath = "Videos/COS.mp4"
    self:GetVideoPlayerManager():Play(videoPath)
end


function PlayerCreatedScene:InitControls()
    local transform = self:GetUnityTransform()

    -- group1
    self.group1Object = transform:Find("Group1").gameObject
    self.group1Object:SetActive(false)

    -- group2
    self.group2Object = transform:Find("Group2").gameObject
    self.group2Object:SetActive(true)

    -- group2 视频跳过按钮
    self.ShowPassVideoButton = transform:Find("Group2/ShowPassVideoButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.PassVideoButton = transform:Find("Group2/PassVideoButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.coPassVideoHandle = nil -- 自动隐藏的句柄

    -- 所选英雄的名字
    self.SelectedHeroFirstNameLabel = transform:Find("Group1/HeroIntroduction/FirstNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.SelectedHeroLastNameLabel = transform:Find("Group1/HeroIntroduction/NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 所选英雄的种族 --
    self.selectedHeroRacialIcon = transform:Find("Group1/HeroIntroduction/RacialIcon"):GetComponent(typeof(UnityEngine.UI.Image))
  
    -- 所选英雄的描述
--    self.SelectedHeroDescLabel = transform:Find('HeroIntroduction/PlayerCreatedHeroIntroductionLabel'):GetComponent(typeof(UnityEngine.UI.Text))


    -- 立绘图片
    self.photographImageControl = transform:Find("Group1/FakeGroup/RawImage"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 姓名输入框
    self.PlayerNameInputField = transform:Find("Group1/Name/PlayerNameInputField"):GetComponent(typeof(UnityEngine.UI.InputField))

    -- 进入游戏按钮
    self.PlayerCreatedEnterButton = transform:Find("Group1/PlayerCreatedEnterButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 随机姓名按钮!
    self.PlayerCreatedRandomButton = transform:Find("Group1/Name/PlayerCreatedRandomButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 进来的时候 初始随机名字
    self:OnPlayerCreatedRandomButtonClicked()


    local InitialCardItemNodeClass = require "GUI.InitialCardItemNode"

    -- 五个 toggle
    local InitialCardItem1 = InitialCardItemNodeClass.New(1, transform:Find("Group1/HeroList/HeroButton1"))
    InitialCardItem1:SetCallback(self, self.OnInitialCardSelected)
    self:AddChild(InitialCardItem1)

    local InitialCardItem2 = InitialCardItemNodeClass.New(2, transform:Find("Group1/HeroList/HeroButton2"))
    InitialCardItem2:SetCallback(self, self.OnInitialCardSelected)
    self:AddChild(InitialCardItem2)

    local InitialCardItem3 = InitialCardItemNodeClass.New(3, transform:Find("Group1/HeroList/HeroButton3"))
    InitialCardItem3:SetCallback(self, self.OnInitialCardSelected)
    self:AddChild(InitialCardItem3)

    local InitialCardItem4 = InitialCardItemNodeClass.New(4, transform:Find("Group1/HeroList/HeroButton4"))
    InitialCardItem4:SetCallback(self, self.OnInitialCardSelected)
    self:AddChild(InitialCardItem4)

    local InitialCardItem5 = InitialCardItemNodeClass.New(5, transform:Find("Group1/HeroList/HeroButton5"))
    InitialCardItem5:SetCallback(self, self.OnInitialCardSelected)
    self:AddChild(InitialCardItem5)


    -- 初始默认
    self.InitialCardItem3 = InitialCardItem3


    -- 视频 --
    self.videoImage = transform:Find("Group2/VideoImage"):GetComponent(typeof(UnityEngine.UI.RawImage))

    -- 播放视频 --
    self:StartCoroutine(PlaySplashVideo)

    
end

local function DelaySelecteItem(_, item)
    coroutine.step(1)
    item:SetSelected(true)
end

function PlayerCreatedScene:RefreshStatus()
    -- coroutine.start(DelaySelecteItem, self.InitialCardItem3)
    self:StartCoroutine(DelaySelecteItem, self.InitialCardItem3)
end

function PlayerCreatedScene:RegisterControlEvents()
    -- 注册 PlayerCreatedEnterButton 的事件
    self.__event_button_onPlayerCreatedEnterButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPlayerCreatedEnterButtonClicked, self)
    self.PlayerCreatedEnterButton.onClick:AddListener(self.__event_button_onPlayerCreatedEnterButtonClicked__)

    -- 注册 PlayerCreatedRandomButton 的事件
    self.__event_button_onPlayerCreatedRandomButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPlayerCreatedRandomButtonClicked, self)
    self.PlayerCreatedRandomButton.onClick:AddListener(self.__event_button_onPlayerCreatedRandomButtonClicked__)

    -- 注册 ShowPassVideoButton 的事件
    self.__event_button_showPassVideoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShowPassVideoButtonClicked, self)
    self.ShowPassVideoButton.onClick:AddListener(self.__event_button_showPassVideoButtonClicked__)

    -- 注册 PassVideoButton 的事件
    self.__event_button_passVideoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPassVideoButtonClicked, self)
    self.PassVideoButton.onClick:AddListener(self.__event_button_passVideoButtonClicked__)
end

function PlayerCreatedScene:UnregisterControlEvents()
    -- 取消注册 PlayerCreatedEnterButton 的事件
    if self.__event_button_onPlayerCreatedEnterButtonClicked__ then
        self.PlayerCreatedEnterButton.onClick:RemoveListener(self.__event_button_onPlayerCreatedEnterButtonClicked__)
        self.__event_button_onPlayerCreatedEnterButtonClicked__ = nil
    end

    -- 取消注册 PlayerCreatedRandomButton 的事件
    if self.__event_button_onPlayerCreatedRandomButtonClicked__ then
        self.PlayerCreatedRandomButton.onClick:RemoveListener(self.__event_button_onPlayerCreatedRandomButtonClicked__)
        self.__event_button_onPlayerCreatedRandomButtonClicked__ = nil
    end

    -- 取消注册 ShowPassVideoButton 的事件
    if self.__event_button_showPassVideoButtonClicked__ then
        self.ShowPassVideoButton.onClick:RemoveListener(self.__event_button_showPassVideoButtonClicked__)
        self.__event_button_showPassVideoButtonClicked__ = nil
    end

    -- 取消注册 PassVideoButton 的事件
    if self.__event_button_passVideoButtonClicked__ then
        self.PassVideoButton.onClick:RemoveListener(self.__event_button_passVideoButtonClicked__)
        self.__event_button_passVideoButtonClicked__ = nil
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function LoadImageImpl(self, id, portraitImage)
    self.photographImageControl:CrossFadeAlpha(0, 0, true)
    utility.LoadRolePortraitImage(id, self.photographImageControl)
	self.photographImageControl:CrossFadeAlpha(1, 0.2, true)
end

function PlayerCreatedScene:OnInitialCardSelected(id, name, desc, portraitImage)
    SelectCardById(self, id)

    LoadImageImpl(self, id, portraitImage)

    local stringUtility = require "Utils.StringUtility"

    local nameArray = stringUtility.CreateArray(name)

    self.SelectedHeroFirstNameLabel.text = nameArray[1]
    self.SelectedHeroLastNameLabel.text = stringUtility.ToString(nameArray, nil, 2, nil)

    -- 加载种族 --
    local roleData = require "StaticData.Role":GetData(id)
    utility.LoadRaceIcon(roleData:GetRace(), self.selectedHeroRacialIcon)
    
end

local function OnCreateTimeOut(self)
    coroutine.wait(6)
    self.PlayerCreatedEnterButton.interactable = true
end

function PlayerCreatedScene:OnPlayerCreatedEnterButtonClicked()
    --PlayerCreatedEnterButton控件的点击事件处理

    local cardID = GetSelectedCardID(self)

    local nickName = self.PlayerNameInputField.text
    -- TODO check name valid
    local ServerService = require "Network.ServerService"

    print('card id ', cardID, 'nickname', nickName)
    local msg, prototype = ServerService.ChoosePlayer(cardID, nickName)
    game:SendNetworkMessage(msg, prototype)

    self.PlayerCreatedEnterButton.interactable = false
    self:StartCoroutine(OnCreateTimeOut)
end

function PlayerCreatedScene:OnPlayerCreatedRandomButtonClicked()
    local Utility = require "Utils.Utility"
    self.PlayerNameInputField.text = Utility.GetNameRandomly()
end

-----------------------------------------------------------------------
--- 网络事件相关
-----------------------------------------------------------------------
local function StartFirstFight(self)
    utility.StartFirstBattle()
end

local function JumpToMainScene(self)
    -- 构建第一场战斗 --
    StartFirstFight(self)
end

function PlayerCreatedScene:RegisterMessages()
    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.LoadAllUserDataFinished, JumpToMainScene)

    ---- >>> video player 
    self:RegisterEvent(messageGuids.VideoEndReached, OnVideoEndReached, nil)
    self:RegisterEvent(messageGuids.VideoPrepared, OnVideoPrepared, nil)
    self:RegisterEvent(messageGuids.VideoError, OnVideoError, nil)
end

function PlayerCreatedScene:UnregisterMessages()
    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.LoadAllUserDataFinished, JumpToMainScene)

    -- >>> video player 
    self:UnregisterEvent(messageGuids.VideoEndReached, OnVideoEndReached, nil)
    self:UnregisterEvent(messageGuids.VideoPrepared, OnVideoPrepared, nil)
    self:UnregisterEvent(messageGuids.VideoError, OnVideoError, nil)
end

return PlayerCreatedScene