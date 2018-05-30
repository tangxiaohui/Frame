local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local DayFerverButtonCls = Class(BaseNodeClass)
local messageGuids = require "Framework.Business.MessageGuids"

function DayFerverButtonCls:Ctor(parent)
	self.Parent=parent
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function DayFerverButtonCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/7DayFerverButton', function(go)
		self:BindComponent(go)
	end)
end

function DayFerverButtonCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function DayFerverButtonCls:OnResume()
	-- 界面显示时调用
	DayFerverButtonCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RedDotStateQuery()
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
	-- self:ActivitySevenDayHappyRequest()
end

function DayFerverButtonCls:OnPause()
	-- 界面隐藏时调用
	DayFerverButtonCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function DayFerverButtonCls:OnEnter()
	-- Node Enter时调用
	DayFerverButtonCls.base.OnEnter(self)
end

function DayFerverButtonCls:OnExit()
	-- Node Exit时调用
	DayFerverButtonCls.base.OnExit(self)
	
end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function DayFerverButtonCls:InitControls()
	local transform = self:GetUnityTransform()
	 self.game = utility.GetGame()
	self.NovicePacksAwardButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
	self.RedDotImage = transform:Find('RedDotImage')

	self.RedDotImage.gameObject:SetActive(false)
	transform:SetParent(self.Parent)

end


function DayFerverButtonCls:RegisterControlEvents()
	-- 注册 NovicePacksAwardButton 的事件
	self.__event_button_onNovicePacksAwardButtonClicked__ = UnityEngine.Events.UnityAction(self.DayFerverButtonClicked, self)
	self.NovicePacksAwardButton.onClick:AddListener(self.__event_button_onNovicePacksAwardButtonClicked__)
end

function DayFerverButtonCls:UnregisterControlEvents()
	-- 取消注册 NovicePacksAwardButton 的事件
	if self.__event_button_onNovicePacksAwardButtonClicked__ then
		self.NovicePacksAwardButton.onClick:RemoveListener(self.__event_button_onNovicePacksAwardButtonClicked__)
		self.__event_button_onNovicePacksAwardButtonClicked__ = nil
	end
end
function DayFerverButtonCls:RegisterNetworkEvents()
	 self.game:RegisterMsgHandler(net.S2CActivitySevenDayHappyResult, self, self.ActivitySevenDayHappyResult)
	
end

function DayFerverButtonCls:UnregisterNetworkEvents()
	 self.game:UnRegisterMsgHandler(net.S2CActivitySevenDayHappyResult, self, self.ActivitySevenDayHappyResult)
	
end
function DayFerverButtonCls:ActivitySevenDayHappyRequest(hid)
	self.game:SendNetworkMessage( require "Network.ServerService".ActivitySevenDayHappyRequest(hid))
end

--七日狂欢红点
function DayFerverButtonCls:ActivitySevenDayHappyResult(msg)
    -- debug_print("七日狂欢"..msg.day)
    self.msg = msg
    local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.Active.DaysFever",msg)
    -- for i=1,#msg.state do
    --     if msg.state[i].status == 1 then
    --         self.RedDotImage.gameObject:SetActive(true)
    --         break
    --     else
    --         self.RedDotImage.gameObject:SetActive(false)
    --     end
    -- end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function DayFerverButtonCls:DayFerverButtonClicked()
	local keys = require "StaticData.Activity.NewServerFeverMain":GetKeys()
	local id = keys[0]
	self:ActivitySevenDayHappyRequest(id)
end

function DayFerverButtonCls:RedDotStateQuery()
	local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
    local activeRed
	local activeInfo = RedDotData:GetServerDayInfo()
	for i=1,#activeInfo do
		if activeInfo[i].activityID ~= 0 and activeInfo[i].red == 1 then
				activeRed = activeInfo[i].red
				break
		end
	end
	self.RedDotImage.gameObject:SetActive(activeRed == 1)
end

function DayFerverButtonCls:RedDotStateUpdated(moduleId,moduleState)
	self:RedDotStateQuery()
end

return DayFerverButtonCls

