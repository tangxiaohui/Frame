local SceneClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local game = utility.GetGame()
local messageGuids = require "Framework.Business.MessageGuids"
require "Const"
require "Collection.DataStack"
local ServerSelectionPanelClass = require "GUI.ServerSelectionPanel"
local ServerNoticePanelClass = require "GUI.ServerNoticePanel"
local ServerStatusNodeClass = require "GUI.ServerStatusNode"

local firstFightFlag = "02404519-499a-4568-8642-6411123ce17f"

local LoginScene = Class(SceneClass)

function LoginScene:Ctor(isReconnect)
	self.skipOpFlag = 0
    self.isReconnect = isReconnect
end

function LoginScene:OnInit()
    utility.LoadNewGameObjectAsync("UI/Prefabs/New_Login", function(go)
        self:BindComponent(go)
    end)
end

local function AutoStartLogin(self)
    debug_print("@@@ AutoStartLogin~~", "isFuckingSDK?", self:GetSDKManager():IsFuckingSDK(), "SessionEmpty?", self:GetSDKManager():IsSessionEmpty(), "CurrentState", self:GetGame():GetGameServer().currentState)
    if self:GetSDKManager():IsFuckingSDK() and self:GetSDKManager():IsSessionEmpty() and (not self:GetGame():GetGameServer():IsTheState(kLoginState_None)) then
        -- 显示qq/微信界面
        debug_print("AutoStartLogin!!")
        self.TXChoiceObject:SetActive(true)
    else
        debug_print("StartChannelLogin")
        self:GetGame():StartChannelLogin()
    end
end

local function StartLogout(self)
    self:GetGame():StartLogout()
end

local function OnVideoEnd(self)
    debug_print("OnVideoEnd 1")

    coroutine.wait(1)

    debug_print("OnVideoEnd 2")

    self.loginUIObject:SetActive(true)

    coroutine.wait(1)

    debug_print("OnVideoEnd 3")

    AutoStartLogin(self)

    debug_print("OnVideoEnd 4")
end

local function OnDelayEnd(self, delay)
    debug_print("OnDelayEnd 1")

    if type(delay) == "number" then
        coroutine.wait(delay)
    end

    debug_print("OnDelayEnd 2")

    self.videoImage:CrossFadeAlpha(0, 0.2, true)
    self.loginBaseObject:SetActive(true)
    coroutine.wait(1)
    self.videoCanvasObject:SetActive(false)
    
    debug_print("OnDelayEnd 3")
    
    -- 看完后设置成跳出 --
    UnityEngine.PlayerPrefs.SetInt(firstFightFlag, 1)
    
    self:GetAudioManager():FadeInBGM(1001)

    debug_print("OnDelayEnd 4")

    OnVideoEnd(self)
end

local function OnDelayShowLogo(self, delay)
    coroutine.wait(delay)
    self.logoImage:CrossFadeAlpha(0, 0, true)
    self.logoImage:CrossFadeAlpha(1, 1, true)
end


-- video player events --
local function OnVideoEndReached(self, _)
    print("nothing to do!")
end

local function OnVideoPrepared(self, _)
    print("@@@@@ OnVideoPrepared @@@@@")
    self.videoImage.color = UnityEngine.Color(1,1,1,1)

    self:StartCoroutine(OnDelayEnd, 58)
    self:StartCoroutine(OnDelayShowLogo, 54)
end

local function OnVideoError(self, _)
    print("@@@@@ OnVideoError @@@@@")
end


-- 开始播放视频 --
local function PlayVideo(self)
	self.videoImage.color = UnityEngine.Color(0,0,0,1)

    local videoPath = "Videos/Splash.mp4"
    self:GetVideoPlayerManager():Play(videoPath)

    debug_print("Play Video!!")
end

local function CreateServerViewPool(self, count)
    self.serverSelectionPanel:InitPool(count)
end



-- 账户
local function OnAccountButtonClicked(self)
    print("账户!")
    StartLogout(self)
end

-- 选择服务器
local function OnSelectServerButtonClicked(self)
    local gameServer = self:GetGame():GetGameServer()

    -- 服务器数据为空! --
    if gameServer:ServerCount() <= 0 then
        print("没有服务器数据!")
        return
    end
    
    self.serverSelectionPanel:Show()
end

-- 公告
local function OnNoticeButtonClicked(self)
    if self:GetGame():GetGameServer():GetServerNoticeCount() > 0 then
        self.serverNoticePanel:Show()
    end
end

local function CanSkipTheOp(self)
	return self.skipOpFlag ~= 0
end

-- 视频按钮
local function OnVideoButtonClicked(self)
    debug_print("跳过视频!")

    -- print("skip", CanSkipTheOp(self))
    if not CanSkipTheOp(self) then
        return
    end

    -- stop
    self:GetVideoPlayerManager():Stop()
    self:GetVideoPlayerManager():ClearShowTarget()

    self.videoCanvasObject:SetActive(false)
    self.logoImage:CrossFadeAlpha(1, 0.2, true)
    self:StopAllCoroutines()
    self:StartCoroutine(OnDelayEnd)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- # Logo # --
    self.logoImage = transform:Find("Login_UI/Logo"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # UI按钮 # --

    -- 账号按钮 --
    self.accountButton = transform:Find("Login_UI/Enter/AccountButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 选择服务器按钮 --
    self.selectServerButton = transform:Find("Login_UI/Enter/SelectServerButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 服务器状态控件相关 --
    self.serverStatusNode = ServerStatusNodeClass.New(transform:Find("Login_UI/Enter/SelectServerStatus"), self, OnSelectServerButtonClicked)
    self:AddChild(self.serverStatusNode)

    -- 公告按钮 --
    self.noticeButton = transform:Find("Login_UI/Enter/NoticeButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 点击区域 --
    self.enterButton = transform:Find("Login_UI/Enter/EnterButton1"):GetComponent(typeof(UnityEngine.UI.Button))

    -- # 视频控件 # --

    -- 按钮 --
    self.videoImage = transform:Find("VideoCanvas/RawImage"):GetComponent(typeof(UnityEngine.UI.RawImage))
    
    -- 跳过组
    self.videoSkipNode = require "GUI.Controls.SkipButtonNode".New(
        transform:Find("VideoCanvas/RawImage"):GetComponent(typeof(UnityEngine.UI.Button)),
        transform:Find("VideoCanvas/SkipButton"):GetComponent(typeof(UnityEngine.UI.Button))
    )
    self.videoSkipNode:SetCallback(self, OnVideoButtonClicked)
    self:AddChild(self.videoSkipNode)

    -- 文字图片提示
    self.connectingImage = transform:Find("Login_UI/Enter/ConnectingImage"):GetComponent(typeof(UnityEngine.UI.Image))
    self.enterGameImage = transform:Find("Login_UI/Enter/EnterButton"):GetComponent(typeof(UnityEngine.UI.Image))

    self.connectingImage.enabled = true
    self.enterGameImage.enabled = false

    -- # GameObject # --
    self.videoCanvasObject = transform:Find("VideoCanvas").gameObject
    self.loginBaseObject = transform:Find("LoginBase").gameObject
    self.loginUIObject = transform:Find("Login_UI/Enter").gameObject

    self.selectServerPoolTrans = transform:Find("Login_UI/Enter/SelectServerPool")

    self.VersionText = transform:Find("Login_UI/Enter/VersionText"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 服务器选择面板 --
    self.serverSelectionPanel = ServerSelectionPanelClass.New(transform:Find("Login_UI/Enter/SelectServerPanel"), self.selectServerPoolTrans)
    self:AddChild(self.serverSelectionPanel)

    -- 公告面板
    self.serverNoticePanel = ServerNoticePanelClass.New(transform:Find("Login_UI/Enter/NewNoticePanel"))
    self:AddChild(self.serverNoticePanel)

    -- #  # --
    self.logoImage:CrossFadeAlpha(0, 0, true)

    -- FIXME: 可恶的应用宝处理!
    self.TXChoiceObject = transform:Find("Login_UI/Enter/TXChoice").gameObject
    self.qqButton = transform:Find("Login_UI/Enter/TXChoice/TweenObject/QQButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.wechatButton = transform:Find("Login_UI/Enter/TXChoice/TweenObject/WechatButton"):GetComponent(typeof(UnityEngine.UI.Button))


    -- 创建服务器控件 --

    -- CreateServerViews(self)
	
	-- 如果想要每次都跳过 就用下面那一行!!!
    -- self.skipOpFlag = UnityEngine.PlayerPrefs.GetInt(firstFightFlag, 0)
    self.skipOpFlag = 1
	debug_print("@@@@@@@ skipOpFlag", self.skipOpFlag)

    if not self.isReconnect then
        -- # # --
        self.videoCanvasObject:SetActive(true)
        self.loginBaseObject:SetActive(false)
        self.loginUIObject:SetActive(false)

        -- # logo # --
        self.logoImage:CrossFadeAlpha(0, 0, true)

        PlayVideo(self)
    else
        self.videoCanvasObject:SetActive(false)
        self.loginBaseObject:SetActive(true)
        self.loginUIObject:SetActive(true)

        -- # logo # --
        self.logoImage:CrossFadeAlpha(1, 0, true)
    end
end



local function OnEnterButtonClicked(self)
    self:GetGame():Connect()
end


local function DelayNextGameServerState(self, gameServer)
    coroutine.step(1)
    AutoStartLogin(self)
end

local function OnGameServerSelectionNodeClicked(self, serverId)
    self.serverSelectionPanel:Hide()

    local gameServer = self:GetGame():GetGameServer()
    self.serverStatusNode:Set(gameServer:GetCurrentServerReadonly())
end
local function ErrorCallBack(self)
   AutoStartLogin(self)
end
local function OnGameServerStateChanged(self, gameServer, errorMessage)

    debug_print("@@@@ state", gameServer.currentState, errorMessage)
    self.serverStatusNode:Set(gameServer:GetCurrentServerReadonly())

    if gameServer:IsTheState(kLoginState_Notice) then
        self.serverNoticePanel:Show(self, AutoStartLogin)
    end

	if gameServer:IsTheState(kLoginState_WaitingForConnect) then
        self.enterGameImage.enabled = true
        self.connectingImage.enabled = false
	else
        self.enterGameImage.enabled = false
        self.connectingImage.enabled = true
    end

    if errorMessage then
        local windowManager = utility:GetGame():GetWindowManager()
        local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"       
        windowManager:Show(ConfirmDialogClass,errorMessage,self,ErrorCallBack)
    else
        if gameServer:IsTheState(kLoginState_RequestRoleList) then
            -- 请求角色页面 --
            local poolCount = gameServer:GetMaxAvailableServerCount()
            CreateServerViewPool(self, poolCount)
        elseif gameServer:IsTheState(kLoginState_Connected) then
			debug_print("@@@@@@@ skipOpFlag = ", self.skipOpFlag)
			if self.skipOpFlag == 0 then
				UnityEngine.PlayerPrefs.Save()
			end
        elseif gameServer:IsTheState(kLoginState_Notice) then
            -- FIXME: 
            return
        end
		
        self:StartCoroutine(DelayNextGameServerState, gameServer)
    end
end


-------------------------------------------------------------------------
----- 网络事件相关
-------------------------------------------------------------------------
local function OnJumpToMainScene(self)
    -- 跳转到主页面! --
    local sceneManager = self:GetGame():GetSceneManager()
    local MainSceneClass = require "Scenes.MainScene"
    sceneManager:ReplaceScene(MainSceneClass.New())
end

local function OnYYBQQLoginClicked(self)
    self:GetSDKManager():SetSessionType("Login")
    self.TXChoiceObject:SetActive(false)
    AutoStartLogin(self)
end

local function OnYYBWechatLoginClicked(self)
    self:GetSDKManager():SetSessionType("Loginwx")
    self.TXChoiceObject:SetActive(false)
    AutoStartLogin(self)
end

local function RegisterEvents(self)
    self.__event_accountButtonClicked__ = UnityEngine.Events.UnityAction(OnAccountButtonClicked, self)
    self.accountButton.onClick:AddListener(self.__event_accountButtonClicked__)

    self.__event_selectServerButtonClicked__ = UnityEngine.Events.UnityAction(OnSelectServerButtonClicked, self)
    self.selectServerButton.onClick:AddListener(self.__event_selectServerButtonClicked__)

    self.__event_noticeButtonClicked__ = UnityEngine.Events.UnityAction(OnNoticeButtonClicked, self)
    self.noticeButton.onClick:AddListener(self.__event_noticeButtonClicked__)

    self.__event_enterButtonClicked__ = UnityEngine.Events.UnityAction(OnEnterButtonClicked, self)
    self.enterButton.onClick:AddListener(self.__event_enterButtonClicked__)


    -- QQ和微信登录!
    self.__event_qqButtonClicked__ = UnityEngine.Events.UnityAction(OnYYBQQLoginClicked, self)
    self.qqButton.onClick:AddListener(self.__event_qqButtonClicked__)

    self.__event_wechatButtonClicked__ = UnityEngine.Events.UnityAction(OnYYBWechatLoginClicked, self)
    self.wechatButton.onClick:AddListener(self.__event_wechatButtonClicked__)


    -- 消息
    self:RegisterEvent(messageGuids.GameServerStateChangedNotify, OnGameServerStateChanged, nil)
    self:RegisterEvent(messageGuids.GameServerSelectionNodeClicked, OnGameServerSelectionNodeClicked, nil)
    self:RegisterEvent(messageGuids.LoadAllUserDataFinished, OnJumpToMainScene, nil)

    ---- >>> video player 
    self:RegisterEvent(messageGuids.VideoEndReached, OnVideoEndReached, nil)
    self:RegisterEvent(messageGuids.VideoPrepared, OnVideoPrepared, nil)
    self:RegisterEvent(messageGuids.VideoError, OnVideoError, nil)
end

local function UnregisterEvent(self)
    if self.__event_accountButtonClicked__ then
        self.accountButton.onClick:RemoveListener(self.__event_accountButtonClicked__)
        self.__event_accountButtonClicked__ = nil
    end

    if self.__event_selectServerButtonClicked__ then
        self.selectServerButton.onClick:RemoveListener(self.__event_selectServerButtonClicked__)
        self.__event_selectServerButtonClicked__ = nil
    end

    if self.__event_noticeButtonClicked__ then
        self.noticeButton.onClick:RemoveListener(self.__event_noticeButtonClicked__)
        self.__event_noticeButtonClicked__ = nil
    end

    if self.__event_enterButtonClicked__ then
        self.enterButton.onClick:RemoveListener(self.__event_enterButtonClicked__)
        self.__event_enterButtonClicked__ = nil
    end

    -- QQ和微信登录!
    if self.__event_qqButtonClicked__ then
        self.qqButton.onClick:RemoveListener(self.__event_qqButtonClicked__)
        self.__event_qqButtonClicked__ = nil
    end

    if self.__event_wechatButtonClicked__ then
        self.wechatButton.onClick:RemoveListener(self.__event_wechatButtonClicked__)
        self.__event_wechatButtonClicked__ = nil
    end

    -- 消息
    self:UnregisterEvent(messageGuids.GameServerStateChangedNotify, OnGameServerStateChanged, nil)
    self:UnregisterEvent(messageGuids.GameServerSelectionNodeClicked, OnGameServerSelectionNodeClicked, nil)
    self:UnregisterEvent(messageGuids.LoadAllUserDataFinished, OnJumpToMainScene, nil)

    ---- >>> video player 
    self:UnregisterEvent(messageGuids.VideoEndReached, OnVideoEndReached, nil)
    self:UnregisterEvent(messageGuids.VideoPrepared, OnVideoPrepared, nil)
    self:UnregisterEvent(messageGuids.VideoError, OnVideoError, nil)
end

function LoginScene:OnComponentReady()
    InitControls(self)
end

function LoginScene:OnEnter()
    LoginScene.base.OnEnter(self)

    -- 设置当前阶段为登录
    local GamePhase = require "Game.GamePhase"
    self:GetGame():SetGamePhase(GamePhase.Login)
end

function LoginScene:OnResume()
    LoginScene.base.OnResume(self)

    self.VersionText.text = string.format("版本号:%s", _G.Constant._version)

    self:GetAudioManager():FadeOutBGM()
    RegisterEvents(self)

    if not self.isReconnect then
        -- 设置显示控件 --
        self:GetVideoPlayerManager():SetShowTarget(self.videoImage)
    else
        -- # auto start login # --
        AutoStartLogin(self)
    end

    -- 设置FOV为25 --
    local uiManager = self:GetUIManager()
    uiManager:GetMainUICanvas():SetFieldOfView(25)
end

function LoginScene:OnPause()
    LoginScene.base.OnPause(self)

    UnregisterEvent(self)

    local uiManager = self:GetUIManager()
    uiManager:GetMainUICanvas():SetFieldOfView(60)

    --- 停止视频 ---
    self:GetVideoPlayerManager():Stop()
    self:GetVideoPlayerManager():ClearShowTarget()

    self:GetAudioManager():FadeOutBGM()
end

return LoginScene

