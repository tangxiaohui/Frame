local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeSnatchCls = Class(BaseNodeClass)

function ElvenTreeSnatchCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeSnatchCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTreeSnatch', function(go)
		self:BindComponent(go)
	end)
end
function ElvenTreeSnatchCls:OnWillShow(enemy,num)
--	print("/////////////")
	self.enemy=enemy
	self.remainNum=num
end
function ElvenTreeSnatchCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ElvenTreeSnatchCls:OnResume()
	-- 界面显示时调用
	ElvenTreeSnatchCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:InitViews()
--	self:RegisterNetworkEvents()
end

function ElvenTreeSnatchCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeSnatchCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function ElvenTreeSnatchCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeSnatchCls.base.OnEnter(self)
end

function ElvenTreeSnatchCls:OnExit()
	-- Node Exit时调用
	ElvenTreeSnatchCls.base.OnExit(self)
end

function ElvenTreeSnatchCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
--移除当前显示 但是新的enemy里面没有物体
local function RemoveOwnEnemy(self)
	local flag = false
--	local temp = -1
	for i=1,#self.enemyItemsPlayerUID do
		flag = false
	--	temp = -1
		for j=1,#self.enemy do
		--	print(self.enemy[j].playerUID,self.enemyItemsPlayerUID[i])
			if  self.enemy[j].playerUID==self.enemyItemsPlayerUID[i] then 
				flag=true				
				break
			end
		end
		if not flag then
		 self:RemoveChild(self.enemyItems[i])	
		end
	end
end 
local function HasOwnItem(self, id)
--	print(id)
	for i=1,#self.enemyItems do
		if self.enemyItemsPlayerUID[i]==id then
			return true
			end
		end
	--print("return false")
    return false
end
local function HideCallBack(table)
	table:Hide()
	-- body
end 
function ElvenTreeSnatchCls:InitViews()
	--判断当前时候在enemy里面不包含但是已经显示的物体 移除出去
	self.remainText.text=self.remainNum

	RemoveOwnEnemy(self)
		--print("/////////////////////////")
	--print(table.maxn(self.enemy))
	for i=1,# self.enemy do
		--如果当前
		if not HasOwnItem(self,self.enemy[i].playerUID) then
		self.enemyItems[i]=require"GUI.ElvenTree.ElvenTreeSnatchPlayer".New(self.ElvenTreeSnatchPlayerListTrans,self.enemy[i])	
		self.enemyItemsPlayerUID[i]=self.enemy[i].playerUID	
		--print(type(HideCallBack))
		self.enemyItems[i]:SetCallback(self,HideCallBack)
		self:AddChild(self.enemyItems[i])	
		end
	end
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeSnatchCls:InitControls()
	local transform = self:GetUnityTransform()
	--返回按钮
	self.ElvenTreeSnatchReturnButton = transform:Find('ElvenTreeSnatchReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--Scrollbar
--	self.ElvenTreeSnatchListScrollbar = transform:Find('List/Scroll View/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	--父类transform
	self.ElvenTreeSnatchPlayerListTrans = transform:Find('List/Scroll View/Viewport/Content')
	self.remainText = transform:Find('TImes/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--背景按钮
	self.BackgroundButton = transform:Find('WhiteWindowBase (1)/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	--当前显示的
	self.enemyItems={}
	self.enemyItemsPlayerUID={}

	
	




end


function ElvenTreeSnatchCls:RegisterControlEvents()
	-- 注册 ElvenTreeSnatchReturnButton 的事件
	self.__event_button_onElvenTreeSnatchReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeSnatchReturnButtonClicked, self)
	self.ElvenTreeSnatchReturnButton.onClick:AddListener(self.__event_button_onElvenTreeSnatchReturnButtonClicked__)


	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
	-- -- 注册 ElvenTreeSnatchListScrollbar 的事件
	-- self.__event_scrollbar_onElvenTreeSnatchListScrollbarValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnElvenTreeSnatchListScrollbarValueChanged, self)
	-- self.ElvenTreeSnatchListScrollbar.onValueChanged:AddListener(self.__event_scrollbar_onElvenTreeSnatchListScrollbarValueChanged__)


end

function ElvenTreeSnatchCls:UnregisterControlEvents()

	-- 取消注册 ElvenTreeSnatchReturnButton 的事件
	if self.__event_button_onElvenTreeSnatchReturnButtonClicked__ then
		self.ElvenTreeSnatchReturnButton.onClick:RemoveListener(self.__event_button_onElvenTreeSnatchReturnButtonClicked__)
		self.__event_button_onElvenTreeSnatchReturnButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

	-- -- 取消注册 ElvenTreeSnatchListScrollbar 的事件
	-- if self.__event_scrollbar_onElvenTreeSnatchListScrollbarValueChanged__ then
	-- 	self.ElvenTreeSnatchListScrollbar.onValueChanged:RemoveListener(self.__event_scrollbar_onElvenTreeSnatchListScrollbarValueChanged__)
	-- 	self.__event_scrollbar_onElvenTreeSnatchListScrollbarValueChanged__ = nil
	-- end


end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ElvenTreeSnatchCls:OnElvenTreeSnatchReturnButtonClicked()
	--ElvenTreeSnatchReturnButton控件的点击事件处理
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[1].systemGuideID,self)
	
	self:Close()

end

function ElvenTreeSnatchCls:OnReturnButtonClicked()
	self:Close()
end

-- function ElvenTreeSnatchCls:OnElvenTreeSnatchListScrollbarValueChanged(value)
-- 	--ElvenTreeSnatchListScrollbar控件的点击事件处理
-- end



return ElvenTreeSnatchCls
