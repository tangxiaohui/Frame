local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CombiStyleCls = Class(BaseNodeClass)

function CombiStyleCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CombiStyleCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CombiStyle', function(go)
		self:BindComponent(go)
	end)
end
function CombiStyleCls:OnWillShow()
	
		
end
function CombiStyleCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CombiStyleCls:OnResume()
	-- 界面显示时调用
	CombiStyleCls.base.OnResume(self)
	self:GetGame():SendNetworkMessage( require"Network/ServerService".GenreQueryRequest())
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function CombiStyleCls:OnPause()
	-- 界面隐藏时调用
	CombiStyleCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end
function CombiStyleCls:GetRootHangingPoint()
    return self:GetUIManager():GetForegroundLayer()
end
function CombiStyleCls:OnEnter()
	-- Node Enter时调用
	CombiStyleCls.base.OnEnter(self)
end

function CombiStyleCls:OnExit()
	-- Node Exit时调用
	CombiStyleCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CombiStyleCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ReturnButton = transform:Find('Base/Title/ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.AccountButton = transform:Find('Base/AccountButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.layout = transform:Find('Base/Scroll View/Viewport/Content')

	-- local msg = {}
	-- msg.genreState={}
	-- msg.genreState[1]={}
	-- msg.genreState[1].id=1
	-- msg.genreState[1].state=0

	-- self:GenreQueryResult(msg)


end


function CombiStyleCls:RegisterControlEvents()
	-- 注册 ReturnButton 的事件
	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

	self.__event_button_onAccountButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAccountButtonClicked, self)
	self.AccountButton.onClick:AddListener(self.__event_button_onAccountButtonClicked__)
end

function CombiStyleCls:UnregisterControlEvents()
	-- 取消注册 ReturnButton 的事件
	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end

	if self.__event_button_onAccountButtonClicked__ then
		self.AccountButton.onClick:RemoveListener(self.__event_button_onAccountButtonClicked__)
		self.__event_button_onAccountButtonClicked__ = nil
	end

end

function CombiStyleCls:RegisterNetworkEvents()

	self:GetGame():RegisterMsgHandler(net.S2CGenreQueryResult, self, self.GenreQueryResult)

end

function CombiStyleCls:UnregisterNetworkEvents()

	self:GetGame():UnRegisterMsgHandler(net.S2CGenreQueryResult, self, self.GenreQueryResult)

end

function CombiStyleCls:GenreQueryResult(msg)
	debug_print("CombiStyleCls:GenreQueryResult(msg)")
	self.genreItems={}
	for i=1,#msg.genreState do
		local item = require "GUI.CombiStyle.CombiStyleItem".New(msg.genreState[i],self.layout)
		self.genreItems[#self.genreItems+1]=item
		self:AddChild(self.genreItems[#self.genreItems])

	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CombiStyleCls:OnAccountButtonClicked()
	--AccountButton控件的点击事件处理
	local str = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(1030):GetDescription()

	local windowManager = self:GetWindowManager()
	windowManager:Show(require "GUI.CommonDescriptionModule", str)
end

function CombiStyleCls:OnReturnButtonClicked()
	--ReturnButton控件的点击事件处理
	self:Close()
end

function CombiStyleCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

return CombiStyleCls
