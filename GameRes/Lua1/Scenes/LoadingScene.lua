local SceneCls = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
require "System.LuaDelegate"

local LoadingScene = Class(SceneCls)
windowUtility.SetMutex(LoadingScene, true)

function LoadingScene:Ctor()
	self.callbackOnFinished = LuaDelegate.New()
end

function LoadingScene:OnInit()
end

function LoadingScene:OnWillShow(sceneName)
	self.sceneName = sceneName
	self.loadCtrl = _G.LoadingScene.LoadingSceneCtrl.GetInstance()
	self.loadCtrl:InitLoadCanvas (1,100)

	self:AyncLoadScene()
	self:ScheduleUpdate(self.Update)
	self.displayProgress = 0
	self.toProgress = 0 
end

function LoadingScene:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function LoadingScene:OnResume()
	-- 界面显示时调用
	LoadingScene.base.OnResume(self)
end

function LoadingScene:SetCallbackOnFinished(table, func)
	self.callbackOnFinished:Set(table, func)
end

function LoadingScene:OnEnter()
    LoadingScene.base.OnEnter(self)
end

function LoadingScene:InitControls()

end

function LoadingScene:AyncLoadScene()
	self.AsyncOperation = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(self.sceneName)
	self.AsyncOperation.allowSceneActivation = false
end

function LoadingScene:Update()
	self:UpdateLoadScene()
end

local function WaitingForFinished(self)
	repeat
		coroutine.step(1)
	until(self.AsyncOperation.isDone)
	self.loadCtrl:LoadingFinished()
	self.callbackOnFinished:Invoke()
	self:Close()
end

function LoadingScene:UpdateLoadScene()
	-- 加载场景
	if self.AsyncOperation == nil then
		return
	end
	if self.AsyncOperation.progress < 0.89 then
		self.toProgress = string.format("%.2f",self.AsyncOperation.progress) * 100
	else
		self.toProgress = 100
	end

	if self.displayProgress < self.toProgress then
		self.displayProgress = self.displayProgress + 1
		
		local value = tonumber(self.displayProgress)
		self.loadCtrl:RefreshLoadingValue(value)
	else
		if self.toProgress == 100 then
			self.AsyncOperation.allowSceneActivation = true
			self:StartCoroutine(WaitingForFinished)
		end
	end
end

return LoadingScene