local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local FirstChargeButton = Class(BaseNodeClass)
local messageGuids = require "Framework.Business.MessageGuids"

function FirstChargeButton:Ctor(parent)
	self.Parent=parent
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function FirstChargeButton:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/FirstChargeButton', function(go)
		self:BindComponent(go)
	end)
end

function FirstChargeButton:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function FirstChargeButton:OnResume()
	-- 界面显示时调用
	FirstChargeButton.base.OnResume(self)
	self:RegisterControlEvents()
	self:RedDotStateQuery()
	self:RegisterNetworkEvents()
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
	-- self:ActivitySevenDayHappyRequest()
end

function FirstChargeButton:OnPause()
	-- 界面隐藏时调用
	FirstChargeButton.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function FirstChargeButton:OnEnter()
	-- Node Enter时调用
	FirstChargeButton.base.OnEnter(self)
end

function FirstChargeButton:OnExit()
	-- Node Exit时调用
	FirstChargeButton.base.OnExit(self)
	
end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function FirstChargeButton:InitControls()
	local transform = self:GetUnityTransform()
	 self.game = utility.GetGame()
	self.NovicePacksAwardButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
	self.RedDotImage = transform:Find('RedDotImage')

	self.RedDotImage.gameObject:SetActive(false)
	transform:SetParent(self.Parent)
	self:RedDotStateQuery()
	

end


function FirstChargeButton:RegisterControlEvents()
	-- 注册 NovicePacksAwardButton 的事件
	self.__event_button_onNovicePacksAwardButtonClicked__ = UnityEngine.Events.UnityAction(self.DayFerverButtonClicked, self)
	self.NovicePacksAwardButton.onClick:AddListener(self.__event_button_onNovicePacksAwardButtonClicked__)
end

function FirstChargeButton:UnregisterControlEvents()
	-- 取消注册 NovicePacksAwardButton 的事件
	if self.__event_button_onNovicePacksAwardButtonClicked__ then
		self.NovicePacksAwardButton.onClick:RemoveListener(self.__event_button_onNovicePacksAwardButtonClicked__)
		self.__event_button_onNovicePacksAwardButtonClicked__ = nil
	end
end

function FirstChargeButton:RegisterNetworkEvents()
	self:GetGame():RegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
end

function FirstChargeButton:UnregisterNetworkEvents()
	self:GetGame():UnRegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function FirstChargeButton:DayFerverButtonClicked()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
	local windowManager = self.game:GetWindowManager()
	local state
	if userData:GetPayState() == 1 and not userData:GetFirstChargeAward() then
		state = true
	else
		state = false
	end
    windowManager:Show(require "GUI.Active.ActivityFirstChargeCls",state)
end

function FirstChargeButton:RedDotStateQuery()
	local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)

    if RedDotData ~= nil then
		local firstChargeState = RedDotData:GetModuleRedState(S2CGuideRedResult.shouchongAward)
       debug_print(firstChargeState,"firstChargeState")
        self.RedDotImage.gameObject:SetActive(firstChargeState == 1)
    end
    
end

function FirstChargeButton:RedDotStateUpdated(moduleId,moduleState)
	self:RedDotStateQuery()
end

function FirstChargeButton:OnActivityGetAwardResult(msg)
	if msg.status then
		self:CleanupComponent()
	end
end

return FirstChargeButton

