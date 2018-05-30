--
-- User: fenghao
-- Date: 26/06/2017
-- Time: 8:05 PM
--

local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"

local SplashScene = Class(BaseNodeClass)


function SplashScene:Ctor()
end

function SplashScene:OnInit()
    -- 加载欢迎页面 --
    utility.LoadNewGameObjectAsync('UI/Prefabs/TheSplashPanel', function(go)
        self:BindComponent(go)
    end)
end

local function OnVideoEnd(_)
    local game = utility.GetGame()
    game:RunLoginScene()
end


local function OnMainButtonClicked(self)
    OnVideoEnd(nil)
end

local function OnDelayEnd(self)
    coroutine.wait(96)
    OnVideoEnd(nil)
end

function SplashScene:OnResume()
    SplashScene.base.OnResume(self)

    self.__event_button_mainButtonClicked__ = UnityEngine.Events.UnityAction(OnMainButtonClicked, self)
    self.mainButton.onClick:AddListener(self.__event_button_mainButtonClicked__)
end

function SplashScene:OnPause()
    SplashScene.base.OnPause(self)

    if self.__event_button_mainButtonClicked__ then
        self.mainButton.onClick:RemoveListener(self.__event_button_mainButtonClicked__)
        self.__event_button_mainButtonClicked__ = nil
    end

    --- 停止视频 ---
    if self.videoPlayer ~= nil then
        self.videoPlayer:Stop()
    end
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    self.mainButton = transform:Find("RawImage"):GetComponent(typeof(UnityEngine.UI.Button))

    self.videoPlayer = transform:Find("Video Player"):GetComponent(typeof(UnityEngine.Video.VideoPlayer))
    local videoPath = string.format("%s/%s", UnityEngine.Application.streamingAssetsPath, "Videos/Open.mp4")
    self.videoPlayer.url = videoPath
--    self.videoPlayer.loopPointReached = UnityEngine.Video.VideoPlayer.EventHandler(OnVideoEnd, self)
    self.videoPlayer:Play();

    self:StartCoroutine(OnDelayEnd)
end

function SplashScene:OnComponentReady()
    InitControls(self)
end

return SplashScene
