local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local GuildTributeCls = Class(BaseNodeClass)
local LegionDonateData = require "StaticData.LegionDonate"
require "System.LuaDelegate"

function GuildTributeCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildTributeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildTribute', function(go)
		self:BindComponent(go)
	end)
end

function GuildTributeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildTributeCls:OnResume()
	-- 界面显示时调用
	GuildTributeCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildTributeCls:OnPause()
	-- 界面隐藏时调用
	GuildTributeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildTributeCls:OnEnter()
	-- Node Enter时调用
	GuildTributeCls.base.OnEnter(self)
end

function GuildTributeCls:OnExit()
	-- Node Exit时调用
	GuildTributeCls.base.OnExit(self)
end

function GuildTributeCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function GuildTributeCls:OnSetCallBack(table,callBack)
	if callBack ~=nil then
        self.callBack = LuaDelegate.New()
        self.callBack:Set(table, callBack)
    end
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildTributeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find('Base')
	self.CrossButton = self.base:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	self.TitleText = {}
	self.Base = {}
	self.Icon = {}
	self.TributeLabel = {}
	self.TributeButton = {}
	self.TributeNumLabel = {}
	for i=1,3 do
		self.TitleText[i] = self.base:Find('Layout/'..i..'/TitleBase/TitleText'):GetComponent(typeof(UnityEngine.UI.Text))
		self.Base[i] = self.base:Find('Layout/'..i..'/Base'):GetComponent(typeof(UnityEngine.UI.Image))
		self.Icon[i] = self.base:Find('Layout/'..i..'/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
		self.TributeLabel[i] = self.base:Find('Layout/'..i..'/TributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		self.TributeButton[i] = self.base:Find('Layout/'..i..'/TributeButton'):GetComponent(typeof(UnityEngine.UI.Button))
		self.TributeNumLabel[i] = self.base:Find('Layout/'..i..'/TributeButton/TributeNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	end

	self:InitView()
end

function GuildTributeCls:InitView()
	for i=1,3 do
		local data = LegionDonateData:GetData(i)
		self.TributeLabel[i].text = "获得军团币"..data:GetCoinNum()
		self.TributeNumLabel[i].text = data:GetPriceNum()
	end
end

function GuildTributeCls:RegisterControlEvents()
	-- 注册 TributeButton 的事件
	self.__event_button_onTributeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTributeButtonClicked, self)
	self.TributeButton[1].onClick:AddListener(self.__event_button_onTributeButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 TributeButton1 的事件
	self.__event_button_onTributeButton1Clicked__ = UnityEngine.Events.UnityAction(self.OnTributeButton1Clicked, self)
	self.TributeButton[2].onClick:AddListener(self.__event_button_onTributeButton1Clicked__)

	-- 注册 TributeButton2 的事件
	self.__event_button_onTributeButton2Clicked__ = UnityEngine.Events.UnityAction(self.OnTributeButton2Clicked, self)
	self.TributeButton[3].onClick:AddListener(self.__event_button_onTributeButton2Clicked__)

	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)
end

function GuildTributeCls:UnregisterControlEvents()
	-- 取消注册 TributeButton 的事件
	if self.__event_button_onTributeButtonClicked__ then
		self.TributeButton[1].onClick:RemoveListener(self.__event_button_onTributeButtonClicked__)
		self.__event_button_onTributeButtonClicked__ = nil
	end

	-- 取消注册 TributeButton1 的事件
	if self.__event_button_onTributeButton1Clicked__ then
		self.TributeButton[2].onClick:RemoveListener(self.__event_button_onTributeButton1Clicked__)
		self.__event_button_onTributeButton1Clicked__ = nil
	end

	-- 取消注册 TributeButton2 的事件
	if self.__event_button_onTributeButton2Clicked__ then
		self.TributeButton[3].onClick:RemoveListener(self.__event_button_onTributeButton2Clicked__)
		self.__event_button_onTributeButton2Clicked__ = nil
	end

	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function GuildTributeCls:RegisterNetworkEvents()

end

function GuildTributeCls:UnregisterNetworkEvents()

end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildTributeCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildTributeCls:OnExitTransitionDidStart(immediately)
    GuildTributeCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildTributeCls:OnCrossButtonClicked()
	self:Close()
end

function GuildTributeCls:OnTributeButtonClicked()
	self:Tribute(1)
end

function GuildTributeCls:OnTributeButton1Clicked()
	self:Tribute(2)
end

function GuildTributeCls:OnTributeButton2Clicked()
	self:Tribute(3)
end

function GuildTributeCls:Tribute(typeIndex)
	local selfUID = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetUid()
	utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHUpdateRequest(2, typeIndex, selfUID, ""))

	if  self.callBack ~=nil then
        self.callBack:Invoke(LegionDonateData:GetData(typeIndex):GetCoinNum())
    end

	self:Close()
end

return GuildTributeCls
