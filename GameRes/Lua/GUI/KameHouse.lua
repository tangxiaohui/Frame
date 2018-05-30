local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

require "GUI.Spine.SpineController"

-----------------------------------------------------------------------
local KameHouseCls = Class(BaseNodeClass)
--windowUtility.SetMutex(KameHouseCls, true)

function KameHouseCls:Ctor()
	local ctrl = SpineController.New()
	self.ctrl = ctrl
end

-- function KameHouseCls:OnWillShow()
-- end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function KameHouseCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/KameHouse', function(go)
		self:BindComponent(go)
	end)
end

function KameHouseCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

local function SetControls(self)
	self.tarotRedDotImage.enabled = require "Utils.TarotUtils".HasRedDot()
	self.zodiacRedDotImage.enabled = require "Utils.RedDotUtils".HasZodiacRedDot()
end

local function OnModuleRedDotChanged(self, moduleId)
	local guideRed = require "Network.PB.S2CGuideRedResult"
	if type(moduleId) == "number" and moduleId == guideRed.star then
		self.zodiacRedDotImage.enabled = require "Utils.RedDotUtils".HasZodiacRedDot()
	end
end

function KameHouseCls:OnResume()

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_KameHouseView)

	-- 界面显示时调用
	KameHouseCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:InitSpineShow()
	SetControls(self)
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[14].systemGuideID,self)

end

function KameHouseCls:OnPause()
	-- 界面隐藏时调用
	KameHouseCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:CloseSpine()
end

function KameHouseCls:InitSpineShow()
	self.ctrl:SetData(self.skeletonGraphic,self.speakerLabel,1)
end

function KameHouseCls:CloseSpine()
	self.ctrl:Stop()
end
----------------------------------------------------------------------
function KameHouseCls:GetRootHangingPoint()
    return self:GetUIManager():GetBackgroundLayer()
end


function KameHouseCls:OnreturnButtonClicked()
	local sceneManager =  utility:GetGame():GetSceneManager()
    sceneManager:PopScene()
end

function KameHouseCls:OngemCombineButtonClicked()
	-- 宝石合成
	local isOpen = utility.IsCanOpenModule(KSystemBasis_GemCombine)
    if not isOpen then
        return
    end
   	local sceneManager =  utility:GetGame():GetSceneManager()
  --  sceneManager:PopScene()
	
    local GemCombineCls = require "GUI.GemCombine.GemCombineCls"
    sceneManager:PushScene(GemCombineCls.New())
end

function KameHouseCls:OnCrystalButtonClicked()
	utility.ShowErrorDialog("该系统暂未开放")
end

function KameHouseCls:OnShopButtonClicked()
	if not utility.IsCanOpenModule(kSystemBasis_Tarot) then
		return
	end
	local sceneManager =  utility:GetGame():GetSceneManager()
	local TarotSceneClass = require "GUI.Tarot.TarotScene"
	sceneManager:PushScene(TarotSceneClass.New())
end

function KameHouseCls:OnZodiacDrawButtonClicked()
	local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(kSystemBasis_Star):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return
    end

	local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Zodiac.ZodiacDraw")
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function KameHouseCls:InitControls()
	local transform = self:GetUnityTransform()

	-- 返回按钮
	self.returnButton = transform:Find('Base/ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- @宝石合成
	-- 说明
	self.stateObj = transform:Find('Base/GemButton/Base').gameObject
	-- 合成按钮
	self.gemCombineButton = transform:Find('Base/GemButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.speakerLabel = transform:Find("Base/Frame/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.skeletonGraphic = transform:Find('Base/guixianren/SkeletonGraphic (guixianren)'):GetComponent(typeof(Spine.Unity.SkeletonGraphic))

	self.CrystalButton = transform:Find('Base/CrystalButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ShopButton = transform:Find('Base/ShopButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.zodiacDrawButton = transform:Find("Base/ZodiacDrawButton"):GetComponent(typeof(UnityEngine.UI.Button))

	-- 红点控件
	self.tarotRedDotImage = transform:Find("Base/ShopButton/RedDot"):GetComponent(typeof(UnityEngine.UI.Image))
	self.zodiacRedDotImage = transform:Find("Base/ZodiacDrawButton/RedDot"):GetComponent(typeof(UnityEngine.UI.Image))
end

function KameHouseCls:RegisterControlEvents()
	-- 注册 返回 的事件
	self.__event_button_onreturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnreturnButtonClicked, self)
	self.returnButton.onClick:AddListener(self.__event_button_onreturnButtonClicked__)

	-- 注册 宝石合成 的事件
	self.__event_button_ongemCombineButtonClicked__ = UnityEngine.Events.UnityAction(self.OngemCombineButtonClicked, self)
	self.gemCombineButton.onClick:AddListener(self.__event_button_ongemCombineButtonClicked__)

	-- 注册 炼化 的事件
	self.__event_button_onCrystalButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrystalButtonClicked, self)
	self.CrystalButton.onClick:AddListener(self.__event_button_onCrystalButtonClicked__)

	-- 注册 祈祷 的事件
	self.__event_button_onShopButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopButtonClicked, self)
	self.ShopButton.onClick:AddListener(self.__event_button_onShopButtonClicked__)
	
	-- 注册 猎魂 的事件
	self.__event_button_onZodiacDrawButtonClicked__ = UnityEngine.Events.UnityAction(self.OnZodiacDrawButtonClicked, self)
	self.zodiacDrawButton.onClick:AddListener(self.__event_button_onZodiacDrawButtonClicked__)


	self:RegisterEvent(messageGuids.ModuleRedDotChanged, OnModuleRedDotChanged)
end

function KameHouseCls:UnregisterControlEvents()
	-- 取消注册 返回 的事件
	if self.__event_button_onreturnButtonClicked__ then
		self.returnButton.onClick:RemoveListener(self.__event_button_onreturnButtonClicked__)
		self.__event_button_onreturnButtonClicked__ = nil
	end

	-- 取消注册 宝石合成 的事件
	if self.__event_button_ongemCombineButtonClicked__ then
		self.gemCombineButton.onClick:RemoveListener(self.__event_button_ongemCombineButtonClicked__)
		self.__event_button_ongemCombineButtonClicked__ = nil
	end

	-- 取消注册 炼化 的事件
	if self.__event_button_onCrystalButtonClicked__ then
		self.CrystalButton.onClick:RemoveListener(self.__event_button_onCrystalButtonClicked__)
		self.__event_button_onCrystalButtonClicked__ = nil
	end

	-- 取消注册 祈祷 的事件
	if self.__event_button_onShopButtonClicked__ then
		self.ShopButton.onClick:RemoveListener(self.__event_button_onShopButtonClicked__)
		self.__event_button_onShopButtonClicked__ = nil
	end
	
	-- 取消注册 猎魂 的事件
	if self.__event_button_onZodiacDrawButtonClicked__ then
		self.zodiacDrawButton.onClick:RemoveListener(self.__event_button_onZodiacDrawButtonClicked__)
		self.__event_button_onZodiacDrawButtonClicked__ = nil
	end

	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, OnModuleRedDotChanged)
end

return KameHouseCls