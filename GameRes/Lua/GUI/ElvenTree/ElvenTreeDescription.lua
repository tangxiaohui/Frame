local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"

local windowUtility = require "Framework.Window.WindowUtility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeDescriptionCls = Class(BaseNodeClass)
windowUtility.SetMutex(ElvenTreeDescriptionCls, true)

function ElvenTreeDescriptionCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeDescriptionCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTreeDescription', function(go)
		self:BindComponent(go)
	end)
end

function ElvenTreeDescriptionCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ElvenTreeDescriptionCls:OnResume()
	-- 界面显示时调用
	ElvenTreeDescriptionCls.base.OnResume(self)
	self:RegisterControlEvents()
--	self:RegisterNetworkEvents()

 	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
    end)
end

function ElvenTreeDescriptionCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeDescriptionCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function ElvenTreeDescriptionCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeDescriptionCls.base.OnEnter(self)
end

function ElvenTreeDescriptionCls:OnExit()
	-- Node Exit时调用
	ElvenTreeDescriptionCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeDescriptionCls:InitControls()
	local transform = self:GetUnityTransform()
	-- self.TranslucentLayer = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BigFarme = transform:Find('SmallWindowBase/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.UpperBorder = transform:Find('SmallWindowBase/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GrayFarme = transform:Find('SmallWindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BlackTitleBase = transform:Find('SmallWindowBase/BlackTitleBase'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Title = transform:Find('SmallWindowBase/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ElvenTreeDescriptionLabel = transform:Find('Scroll View/Viewport/Content/ElvenTreeDescriptionLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ElvenTreeDescriptionButton = transform:Find('ElvenTreeDescriptionButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ElvenTreeDescriptionCrossButton = transform:Find('SmallWindowBase/CheckInDescriptionRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))

	--背景按钮
	self.BackgroundButton = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	local id = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_ElvenTreeID):GetDescriptionInfo()[0]
	local hintStr = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
	local str = string.gsub(hintStr,"\\n","\n")
	self.ElvenTreeDescriptionLabel.text = str
end


function ElvenTreeDescriptionCls:RegisterControlEvents()
	-- 注册 ElvenTreeDescriptionButton 的事件
	self.__event_button_onElvenTreeDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButtonClicked, self)
	self.ElvenTreeDescriptionButton.onClick:AddListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButtonClicked, self)
	self.ElvenTreeDescriptionCrossButton.onClick:AddListener(self.__event_button_onElvenTreeDescriptionCrossButtonClicked__)
end

function ElvenTreeDescriptionCls:UnregisterControlEvents()
	-- 取消注册 ElvenTreeDescriptionButton 的事件
	if self.__event_button_onElvenTreeDescriptionButtonClicked__ then
		self.ElvenTreeDescriptionButton.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)
		self.__event_button_onElvenTreeDescriptionButtonClicked__ = nil
	end

	if self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ then
		self.ElvenTreeDescriptionCrossButton.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionCrossButtonClicked__)
		self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ElvenTreeDescriptionCls:OnElvenTreeDescriptionButtonClicked()
	--ElvenTreeDescriptionButton控件的点击事件处理
	self:UnregisterControlEvents()
	self:Hide()
end
function ElvenTreeDescriptionCls:OnReturnButtonClicked()
	self:Close()
end
return ElvenTreeDescriptionCls

