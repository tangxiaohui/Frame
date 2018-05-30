local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"
local windowUtility = require "Framework.Window.WindowUtility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local WorldBossShowCls = Class(BaseNodeClass)

windowUtility.SetMutex(WorldBossShowCls, true)

function WorldBossShowCls:Ctor()
end
function WorldBossShowCls:OnWillShow(id)

	debug_print("WorldBossShowCls",id)
	self.id=id

end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function WorldBossShowCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/WorldBossShow', function(go)
		self:BindComponent(go)
	end)
end

function WorldBossShowCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self.transform.gameObject:SetActive(false)
end

function WorldBossShowCls:OnResume()
	-- 界面显示时调用
	WorldBossShowCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function WorldBossShowCls:OnPause()
	-- 界面隐藏时调用
	WorldBossShowCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function WorldBossShowCls:OnEnter()
	-- Node Enter时调用
	WorldBossShowCls.base.OnEnter(self)
end

function WorldBossShowCls:OnExit()
	-- Node Exit时调用
	WorldBossShowCls.base.OnExit(self)
end
local function SetLayerRecursively(gameObject, name)
    local layer = LayerMask.NameToLayer(name)
    if not layer then
        print(string.format('层 ％s 没有找到!', name))
        return
    end
    gameObject.layer = layer
    local trans = gameObject.transform
    local childCount = trans.childCount
    for i = 1, childCount do
        local child = trans:GetChild(i - 1)
        if child then
            SetLayerRecursively(child.gameObject, name)
        end
    end
end
--显示warning
local function ShowWarning(self)
    local uiManager = require "Utils.Utility".GetUIManager()
    self.screenParticleWarningEffect = require "Framework.UI.UIScreenWarning".New(uiManager.effectUICanvas)
    debug_print("ShowWarning  开始")
    coroutine.wait(3.1)
    self.Base.gameObject:SetActive(true)
	self.TranslucentLayer.gameObject:SetActive(true)
	local objParent = UnityEngine.GameObject.Instantiate(utility.LoadResourceSync("UI/Prefabs/ShowWorldBoss", typeof(UnityEngine.GameObject)))
	self.objParent=objParent
	local objParentTrans = objParent.transform:Find('Point')
	self.objParentTrans=objParentTrans



	self.transform.gameObject:SetActive(true)

	local obj = UnityEngine.GameObject.Instantiate(utility.LoadResourceSync("Effect/Effects/UI/WorldBossShow_Effect", typeof(UnityEngine.GameObject)))
	debug_print(self.objParentTrans,"self.objParentTrans")
	SetLayerRecursively(obj,"UI")
	obj.transform:SetParent(self.Base)
	obj.transform.localPosition=Vector3(0,-249,0)
	--obj:AddComponent(typeof(RendererDepthReorderer))
	-- obj.transform.localEulerAngles=Vector3(rotation.x, rotation.y, rotation.z)
	obj.transform.localScale=Vector3(8,8,8)
    debug_print("ShowWarning  结束")

	self:InitViews()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function WorldBossShowCls:InitControls()
	local transform = self:GetUnityTransform()
	
	self.transform=transform
	self.TranslucentLayer = transform:Find('TranslucentLayer')
	--self.Sinbol = transform:Find('Base/Sinbol'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.Chara = transform:Find('Base/Chara'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ReturnButton = transform:Find('Base/ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FightButton = transform:Find('Base/FightButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Base = transform:Find('Base/')
	self.NameLabel = transform:Find('Base/Name/NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LvLabel = transform:Find('Base/Name/LvLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--ShowWarning(self)
	self.Base.gameObject:SetActive(false)
	--self.TranslucentLayer.gameObject:SetActive(false)
	-- coroutine.start(ShowWarning,self)
	self:StartCoroutine(ShowWarning)
	
end

function WorldBossShowCls:InitViews()
	local GameObject= UnityEngine.GameObject
			--boss数据
	local WorldBossLevelData = require "StaticData.Boss.WorldBossLevel":GetData(self.id)
	self.bossId = WorldBossLevelData:GetBossID()
	local resPathMgr = require "StaticData.ResPath"
	local prefabName = resPathMgr:GetData(self.bossId):GetPath()
	local obj = GameObject.Instantiate(utility.LoadResourceSync(prefabName, typeof(UnityEngine.GameObject)))
	local position =WorldBossLevelData:GetBossPosition()
	local rotation =WorldBossLevelData:GetBossRotation()
	local scale =WorldBossLevelData:GetBossScale()
	--debug_print(position.x, position.y, position.z,"angle",rotation.x, rotation.y, rotation.z,"Scale",scale.x, scale.y, scale.z)
	obj.transform:SetParent(self.objParentTrans)
	obj.transform.localPosition=Vector3(position.x, position.y, position.z)
	obj.transform.localEulerAngles=Vector3(rotation.x, rotation.y, rotation.z)
	obj.transform.localScale=Vector3(scale.x, scale.y, scale.z)

	--获取boss名字
	local roleMgr = require "StaticData.Role"
    local roleData = roleMgr:GetData(self.bossId)
	self.NameLabel.text=roleData:GetInfo()
	--获取人物的级别
	local UserDataType = require "Framework.UserDataType"
	local userData = self:GetCachedData(UserDataType.PlayerData)
	self.LvLabel.text="Lv."..userData:GetLevel()
	self.animator = obj.transform:GetComponent(typeof(UnityEngine.Animator))

	self.animator:CrossFade(WorldBossLevelData:GetBossAnimation(), 0);


end


function WorldBossShowCls:RegisterControlEvents()
	-- 注册 ReturnButton 的事件
	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

	-- 注册 FightButton 的事件
	self.__event_button_onFightButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFightButtonClicked, self)
	self.FightButton.onClick:AddListener(self.__event_button_onFightButtonClicked__)

end

function WorldBossShowCls:UnregisterControlEvents()
	-- 取消注册 ReturnButton 的事件
	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end

	-- 取消注册 FightButton 的事件
	if self.__event_button_onFightButtonClicked__ then
		self.FightButton.onClick:RemoveListener(self.__event_button_onFightButtonClicked__)
		self.__event_button_onFightButtonClicked__ = nil
	end

end

function WorldBossShowCls:RegisterNetworkEvents()
end

function WorldBossShowCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function WorldBossShowCls:OnReturnButtonClicked()
	--ReturnButton控件的点击事件处理
	UnityEngine.Object.Destroy(self.objParent)
	self:Close()
end

local function IsNormalSceneLoaded(self)
	local activeScene = UnityEngine.SceneManagement.SceneManager.GetActiveScene()
	return activeScene ~= nil and activeScene.name == "Normal" and not self:GetGame():GetSceneManager():IsLocked()
end

local function OnDelayWait(self, func)
	self:DispatchEvent(messageGuids.JumpToNormalScene, nil)
	-- 等待场景是Normal场景 --
	repeat
		coroutine.step()
	until(IsNormalSceneLoaded(self))
	utility.PopToRootScene(func)
end

function WorldBossShowCls:OnFightButtonClicked()
	--FightButton控件的点击事件处理
	-- 这里不能用 self:StartCoroutine
	coroutine.start(OnDelayWait, self, function()
		local sceneManager = utility:GetGame():GetSceneManager()
		sceneManager:PopToRootScene()
		local scene = require "GUI.Boss.Boss"
		sceneManager:PushScene(scene.New())

		local windowManager = self:GetGame():GetWindowManager()
		windowManager:CloseAll(true)
		UnityEngine.Object.Destroy(self.objParent)
		self:Close()
	end)
end

return WorldBossShowCls
