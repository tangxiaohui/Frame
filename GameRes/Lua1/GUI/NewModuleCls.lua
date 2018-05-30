local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local messageGuids = require "Framework.Business.MessageGuids"
require "LUT.StringTable"

local NewModuleCls = Class(BaseNodeClass)
windowUtility.SetMutex(NewModuleCls,true)

function NewModuleCls:OnWillShow(id)
	self.id = id
end

function NewModuleCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/GoNewModule", function(prefab)
		self:BindComponent(prefab)
	end)
end

function NewModuleCls:OnComponentReady()
	self:InitControls()
end

function NewModuleCls:OnResume()
	NewModuleCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
        if transform.localScale == Vector3(1, 1, 1) and self.Effect == nil then
        	local path = "Effect/Effects/UI/UI_tiaozhhuan"
        	local Resources = UnityEngine.Resources
        	local Object = UnityEngine.Object
        	self.Effect = Object.Instantiate(utility.LoadResourceSync(path, typeof(UnityEngine.GameObject))) 
        	self.Effect.transform:SetParent(self.base)
        	self.Effect.transform.localPosition = self.base.localPosition
        	self.Effect:SetActive(true)
		end
    end)

    local guideMgr = utility.GetGame():GetGuideManager()
    guideMgr:AddGuideEvnt(kGuideEvnt_GetReadyEquipGideTips)
    guideMgr:AddGuideEvnt(kGuideEvnt_SelectInitialHero)
	guideMgr:SortGuideEvnt()
    guideMgr:ShowGuidance()
	self:RegisterControlEvents()
	self:ShowPanel()
end

function NewModuleCls:OnPause()
	NewModuleCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function NewModuleCls:OnEnter()
	NewModuleCls.base.OnEnter(self)
end

function NewModuleCls:OnExit()
	NewModuleCls.base.OnExit(self)
end

function NewModuleCls:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end

function NewModuleCls:Update()
	self:ImageRotate()
end

function NewModuleCls:InitControls()
	local transform = self:GetUnityTransform()
	self:ScheduleUpdate(self.Update)
	self.base = transform:Find("TweenObject")
	self.BgImage = self.base:Find("Light")
	self.icon = self.base:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text = transform:Find("TweenObject/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.gotoButton = transform:Find("TweenObject/Button"):GetComponent(typeof(UnityEngine.UI.Button))
end

function  NewModuleCls:RegisterControlEvents()
	self._event_button_onGotoButton_ = UnityEngine.Events.UnityAction(self.OnGotoButtonClicked,self)
	self.gotoButton.onClick:AddListener(self._event_button_onGotoButton_)
end

function  NewModuleCls:UnregisterControlEvents()
	if self._event_button_onGotoButton_ then
		self.gotoButton.onClick:RemoveListener(self._event_button_onGotoButton_)
		self._event_button_onGotoButton_ = nil
	end
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function NewModuleCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function NewModuleCls:OnExitTransitionDidStart(immediately)
    NewModuleCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            self.base.localScale = Vector3(s, s, s)
        end)
    end
end

local speed = 40
function NewModuleCls:ImageRotate()
	self.BgImage:RotateAround(self.BgImage.position,Vector3.forward , Time.deltaTime * speed)
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

	debug_print("@ 新模块开启:", "准备回调了~~~!!!!")

	utility.PopToRootScene(func)
end

function  NewModuleCls:OnGotoButtonClicked()
	local newModuleData = require "StaticData.NewModule"
	local data = newModuleData:GetData(self.id)
	local path = data:GetModulePath()
	local backModule = data:GetBackModule()

	-- debug_print("@@@ 开始跳转 @@@", path)

	if type(path) == "string" and string.len(path) > 0 then
		-- note: 这里不能使用 StartCoroutine, 战斗后会关闭窗口导致Node管理的协程关闭.
		coroutine.start(OnDelayWait, self, function()
			debug_print("@ 新模块开启:", "backModule", backModule, "id", self.id)
			self:HideAll(true)
			self:LoadPanel(path, backModule, self.id)
		end)
	else
		self:Hide()
	end
end

function NewModuleCls:HideAll(immediately)
	local windowManager = self:GetGame():GetWindowManager()
	windowManager:HideAll(immediately)
end

function NewModuleCls:LoadPanel(path, backModule, newModuleID)
	-- debug_print("@@@ 新模块开启 @@@", path, backModule, newModuleID)
	if backModule == 1 then
		local sceneManager = utility.GetGame():GetSceneManager()
		sceneManager:PushScene(require (path).New())
	else
		local windowManager = utility.GetGame():GetWindowManager()
		if newModuleID ~= 20 then
			windowManager:Show(require (path))
		else
		--商店
			windowManager:Show(require (path),1)
		end
	end
end

function NewModuleCls:Hide()
	self:Close(true)
end

function NewModuleCls:ShowPanel()
	local configInfoData = require "StaticData.SystemConfig.SystemBasisInfo"
	local data = configInfoData:GetData(self.id)
	self.Text.text = data:GetName()
	local newModuleData = require "StaticData.NewModule":GetData(self.id)
	local path = string.format("UI/Atlases/TheMain/%s",newModuleData:GetIcon())
	utility.LoadSpriteFromPath(path,self.icon)
end

return NewModuleCls