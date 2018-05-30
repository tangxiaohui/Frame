
require "Framework.GameSubSystem"
local myGame = require "Utils.Utility".GetGame()
local messageGuids = require "Framework.Business.MessageGuids"
local utility = require "Utils.Utility"

local VideoPlayerManager = Class(GameSubSystem)

-----------------------------------------------------------------------
--- 内部初始化函数
-----------------------------------------------------------------------
local function LoadVideoManager(self)
	local UnityEngine = UnityEngine
	local Object = UnityEngine.Object
	local prefab = utility.LoadResourceSync("Prefabs/VideoManager", typeof(UnityEngine.GameObject))
	self.gameObject = Object.Instantiate(prefab)
	self.gameObject.name = prefab.name
	Object.DontDestroyOnLoad(self.gameObject)
	self.transform = self.gameObject.transform
	self.simpleVideoPlayer = self.transform:GetComponent(typeof(SimpleVideoPlayer))
end

-----------------------------------------------------------------------
--- 处理函数
-----------------------------------------------------------------------

local function OnVideoReady(self)
	self.simpleVideoPlayer:Play()
end

local function OnVideoFirstFrameReady(self)
	myGame:DispatchEvent(messageGuids.VideoPrepared, nil, self)
end

local function OnVideoEnd(self)
	myGame:DispatchEvent(messageGuids.VideoEndReached, nil, self)
	self.simpleVideoPlayer:Unload()
end

local function OnVideoError(self)
	myGame:DispatchEvent(messageGuids.VideoError, nil, self)
end


-----------------------------------------------------------------------
--- 构造函数
-----------------------------------------------------------------------
function VideoPlayerManager:SetShowTarget(rawImage)
	self.simpleVideoPlayer:SetTargetMaterial(0, rawImage.gameObject)
end

function VideoPlayerManager:ClearShowTarget()
	self.simpleVideoPlayer:SetTargetMaterial(0, nil)
end

function VideoPlayerManager:Play(url)
	self.simpleVideoPlayer:Load(url)
end

function VideoPlayerManager:Stop()
	self.simpleVideoPlayer:Unload()
end

function VideoPlayerManager:GetUrl()
	return self.simpleVideoPlayer.url
end


-----------------------------------------------------------------------
--- 实现 GameSubSystem 的接口
-----------------------------------------------------------------------
local function RegisterMessages(self)
	-- onReady
	self.__event_onReady__ = UnityEngine.Events.UnityAction(OnVideoReady, self)
	self.simpleVideoPlayer.onReady:AddListener(self.__event_onReady__)

	-- onFirstFrameReady
	self.__event_onFirstFrameReady__ = UnityEngine.Events.UnityAction(OnVideoFirstFrameReady, self)
	self.simpleVideoPlayer.onFirstFrameReady:AddListener(self.__event_onFirstFrameReady__)

	-- onEnd
	self.__event_onEnd__ = UnityEngine.Events.UnityAction(OnVideoEnd, self)
	self.simpleVideoPlayer.onEnd:AddListener(self.__event_onEnd__)

	-- onError
	self.__event_onError__ = UnityEngine.Events.UnityAction(OnVideoError, self)
	self.simpleVideoPlayer.onError:AddListener(self.__event_onError__)

end

local function UnregisterMessages(self)
	-- onReady
	if self.__event_onReady__ then
		self.simpleVideoPlayer.onReady:RemoveListener(self.__event_onReady__)
		self.__event_onReady__ = nil
	end

	-- onFirstFrameReady
	if self.__event_onFirstFrameReady__ then
		self.simpleVideoPlayer.onFirstFrameReady:RemoveListener(self.__event_onFirstFrameReady__)
		self.__event_onFirstFrameReady__ = nil
	end

	-- onEnd
	if self.__event_onEnd__ then
		self.simpleVideoPlayer.onEnd:RemoveListener(self.__event_onEnd__)
		self.__event_onEnd__ = nil
	end

	-- onError
	if self.__event_onError__ then
		self.simpleVideoPlayer.onError:RemoveListener(self.__event_onError__)
		self.__event_onError__ = nil
	end
end


function VideoPlayerManager:GetGuid()
    return require "Framework.SubsystemGUID".VideoPlayerManager
end

function VideoPlayerManager:Startup()
    LoadVideoManager(self)
    RegisterMessages(self)
end

function VideoPlayerManager:Shutdown()
	UnregisterMessages(self)
end

function VideoPlayerManager:Restart()
end

function VideoPlayerManager:Update()
end

return VideoPlayerManager
