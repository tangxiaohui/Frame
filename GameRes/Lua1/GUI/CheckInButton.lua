local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CheckInButtonCls = Class(BaseNodeClass)

function CheckInButtonCls:Ctor(parent)
	self.Parent=parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CheckInButtonCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CheckInButton', function(go)
		self:BindComponent(go)
	end)
end

function CheckInButtonCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CheckInButtonCls:OnResume()
	-- 界面显示时调用
	CheckInButtonCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function CheckInButtonCls:OnPause()
	-- 界面隐藏时调用
	CheckInButtonCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function CheckInButtonCls:OnEnter()
	-- Node Enter时调用
	CheckInButtonCls.base.OnEnter(self)
end

function CheckInButtonCls:OnExit()
	-- Node Exit时调用
	CheckInButtonCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CheckInButtonCls:InitControls()
	local transform = self:GetUnityTransform()
	 self.game = utility.GetGame()
	self.CheckInButton = transform:Find(''):GetComponent(typeof(UnityEngine.UI.Button))
	print(self.Parent)
	transform:SetParent(self.Parent)
end


function CheckInButtonCls:RegisterControlEvents()
	-- 注册 CheckInButton 的事件
	self.__event_button_onCheckInButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInButtonClicked, self)
	self.CheckInButton.onClick:AddListener(self.__event_button_onCheckInButtonClicked__)
end

function CheckInButtonCls:UnregisterControlEvents()
	-- 取消注册 CheckInButton 的事件
	if self.__event_button_onCheckInButtonClicked__ then
		self.CheckInButton.onClick:RemoveListener(self.__event_button_onCheckInButtonClicked__)
		self.__event_button_onCheckInButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CheckInButtonCls:OnCheckInButtonClicked()
	--CheckInButton控件的点击事件处理
	  local windowManager = self.game:GetWindowManager()
      windowManager:Show(require "GUI.CheckIn")
end

return CheckInButtonCls

