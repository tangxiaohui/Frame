--local game = require "Game.Main"
local myGame = require "Game.Cos3DGame"
--local test = require "UnitTest.Test"
local utility = require "Utils.Utility"

local scheduleManager

-----------------------------------------------------------------------
--- 初始化相关
-----------------------------------------------------------------------
local assetPrefabNames = {
	"UI/Prefabs/Active.prefab",
	"UI/Prefabs/New_Login.prefab",
	"UI/Prefabs/PlayerCreated.prefab",
	"UI/Prefabs/TheMainPanel.prefab",
	"UI/Prefabs/Zhuchangjing.prefab",
	"UI/Prefabs/CurrencyBarPanel.prefab",
	"UI/Prefabs/Announcement.prefab",
	"UI/Prefabs/CardDrawResultEffect.prefab",
	"UI/Prefabs/Arena.prefab",
	"UI/Prefabs/HeroCardItem.prefab",
	"UI/Prefabs/ArenaRivalFormationItem.prefab",
	"UI/Prefabs/Fighting.prefab",
	"UI/Prefabs/Checkpoint.prefab",
	"UI/Prefabs/BattleResult.prefab",
	"UI/Prefabs/Levelup.prefab",
	"UI/Prefabs/NeoCardInfoKai.prefab",
	"UI/Prefabs/Formation.prefab",
	"UI/Prefabs/SinGemCombine.prefab",
	"UI/Prefabs/Tarot.prefab",
	"UI/Prefabs/TarotCard.prefab",
	"UI/Prefabs/TarotCardActiveModule.prefab",
	"UI/Prefabs/TarotLineUpItem.prefab",
	"Audios/Bgm/Arena.mp3",
	"Audios/Bgm/CardDraw.mp3",
	"Audios/Bgm/stage_select_bgm.mp3",
	"Audios/Bgm/Login.mp3",
	"Audios/Bgm/SelectHero.mp3",
	"Audios/Bgm/Battle.mp3",
	"Audios/SE/Battle/10010003/sfx_10010003_pugong.mp3",
	"Audios/SE/Battle/10000061/sfx_10000061_pugong.mp3",
	"Audios/SE/Battle/10000064/sfx_10000064_pugong.mp3",
	"Audios/SE/Battle/10000112/sfx_10000112_pugong.mp3",
	"Audios/SE/Battle/10000002/sfx_10000002_pugong.mp3",
	"Audios/SE/Battle/10000105/sfx_10000105_pugong.mp3",
	"Audios/SE/Battle/10010002/sfx_10010002_pugong.mp3",
	"Audios/SE/Battle/10000014/sfx_10000014_pugong.mp3",
	"Audios/SE/Battle/10000112/1000011204.mp3",
	"Audios/SE/Battle/10000112/sfx_10000112_jineng.mp3",
	"Audios/SE/Battle/10000105/1000010504.mp3",
	"Audios/SE/Battle/10000105/sfx_10000105_jineng.mp3",
	"Audios/SE/Battle/10000064/sfx_10000064_jineng.mp3",
	"Audios/SE/Battle/10000064/1000006404.mp3",
	"Audios/SE/Battle/10000002/sfx_10000002_jineng.mp3",
	"Audios/SE/Battle/10000002/1000000204.mp3",
	"Audios/SE/Battle/10000014/sfx_10000014_jineng.mp3",
	"Audios/SE/Battle/10000014/1000001404.mp3",
	"Audios/SE/Battle/10000028/sfx_10000028_pugong.mp3",
	"Audios/SE/Battle/10000028/1000002804.mp3",
	"Audios/SE/Battle/10000028/sfx_10000028_jineng.mp3",
	"Audios/SE/Battle/10000061/sfx_10000061_jineng01.mp3",
	"Audios/SE/Battle/10000061/sfx_10000061_jineng02.mp3",
	"Audios/SE/Battle/10000061/1000006104.mp3",
	"Audios/SE/Battle/10000061/sfx_10000061_jineng03.mp3",
	"Audios/SE/Battle/10000051/sfx_10000051_pugong.mp3",
	"Audios/SE/Battle/10000107/sfx_10000107_pugong.mp3",
	"Audios/SE/Battle/10000051/sfx_10000051_jineng.mp3",
	"Audios/SE/Battle/10000051/1000005104.mp3",
	"Audios/SE/Battle/10000107/sfx_10000107_jineng.mp3",
	"Audios/SE/Battle/10000107/1000010704.mp3",
	"Audios/SE/Battle/BattlePortrait.mp3",
	"Audios/SE/UI/sfx_ui_dianji.mp3",
	"Audios/ME/Battle/battle_win.mp3",
	"Audios/ME/Battle/battle_failed.mp3"
}


local function PreloadSomething()
	local AtlasesLoader = require "Utils.AtlasesLoader"
	print('preload', AtlasesLoader:PreloadAtlas("UI/Atlases/Common"))
end

local function SetupCanvasSettings()
	local uiManager = myGame:GetUIManager()
	uiManager:GetBattleUICanvas():HideRoot()
	uiManager:GetMainSceneUICanvas():HideRoot()
end

local function CoLoadAssets(func)
	local ProgressBarUtils = require "Utils.ProgressBarUtils"
	ProgressBarUtils.Display("正在突破次元壁", "正在加载资源...", 0)
	local totalCount = #assetPrefabNames
	for i = 1, totalCount do
		_G.AssetManager.LoadAsset(assetPrefabNames[i])
		ProgressBarUtils.Display("正在突破次元壁", "正在加载资源...", i / totalCount)
		coroutine.step(1)
	end
	ProgressBarUtils.Clear()
	func()
end

local function PreloadAssets()
	coroutine.start(CoLoadAssets, function() 
		utility.LoadNormalScene()
		SetupCanvasSettings()
		myGame:RunLoginScene()
	end)
end


function _G.Start()
	PreloadSomething()
	myGame:Start()
	scheduleManager = myGame:GetScheduleManager()

	-- 预加载资源 --
	PreloadAssets()
end


local gmConsoleWindowHandle
function _G.OnShowGMConsoleOverlay(isShow)
	--EnableInput
	local uiManager = myGame:GetUIManager()
	if isShow then
		uiManager:DisableInput()
	else
		uiManager:EnableInput()
	end
end


function _G.OnShowSDKQuitGameDialog()
	local windowManager = utility.GetGame():GetWindowManager()
    local SDKQuitGameModuleClass = require "GUI.Modules.SDK.SDKQuitGameModule"
    windowManager:Show(SDKQuitGameModuleClass)
end

-----------------------------------------------------------------------
--- Mono 相关
-----------------------------------------------------------------------

function _G.OnSceneLoaded(scene, mode)
	scheduleManager:TriggerOnSceneLoaded(scene, mode)
end

function _G.Update()
	myGame:Update()
	scheduleManager:TriggerUpdate()
end

function _G.FixedUpdate()
	scheduleManager:TriggerFixedUpdate()
end

function _G.LateUpdate()
	scheduleManager:TriggerLateUpdate()
end

function _G.OnApplicationFocus(hasFocus)
	scheduleManager:TriggerOnFocus(hasFocus)
end

function _G.OnApplicationPause(pauseStatus)
	scheduleManager:TriggerOnPause(pauseStatus)
end

function _G.OnApplicationQuit()
	myGame:Close()
end

function _G.OnPlayGameSound(id)
	local audioManager = myGame:GetAudioManager()
	audioManager:PlaySE(id)
end

function _G.PlayGameME(id)
	local audioManager = myGame:GetAudioManager()
	audioManager:PlayME(id)
end

function _G.OnShakeCameraEvent(gameObject, id)
	local MessageGuids = require "Framework.Business.MessageGuids"
	myGame:DispatchEvent(MessageGuids.ShakeCameraEvent, nil, gameObject, id)
end

-----------------------------------------------------------------------
--- 网络状态相关
-----------------------------------------------------------------------
function _G.OnSessionStateChanged(code)
	-- print('session state:', code)
	myGame:OnSessionStateChanged(code)
end

function _G.Reconnect()
--	game:Reconnect()
end