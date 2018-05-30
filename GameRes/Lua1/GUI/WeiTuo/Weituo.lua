local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local WeituoCls = Class(BaseNodeClass)

function WeituoCls:Ctor()
end
local weiTuoItemHeight = 120
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function WeituoCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Weituo', function(go)
		self:BindComponent(go)
	end)
end

function WeituoCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function WeituoCls:OnResume()
	-- 界面显示时调用
	WeituoCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function WeituoCls:OnPause()
	-- 界面隐藏时调用
	WeituoCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function WeituoCls:OnEnter()
	-- Node Enter时调用
	WeituoCls.base.OnEnter(self)
end

function WeituoCls:OnExit()
	-- Node Exit时调用
	WeituoCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function WeituoCls:InitControls()
	local transform = self:GetUnityTransform()
	--self.GuixianrenImage = transform:Find('Base/GuixianrenImage'):GetComponent(typeof(UnityEngine.UI.Image))

	self.Layout = transform:Find('Main/Content/Scroll View/Viewport/Content')
	--返回按钮
	self.BackButton = transform:Find('Back/BackButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.Text = transform:Find('Talk/TalkBaseImage/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Scroll_View= transform:Find('Main/Content/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))

	self:InitViews()
end

-----------------------------------------------------------------------
-- # 初始化界面
function WeituoCls:InitViews()

	local SubQuestCls = require "StaticData.WeiTuo.SubQuest"
	local keys = SubQuestCls:GetKeys()

	self.weiTuoItem={}
	self.weiTuoHeroPanel={}
	for i=0,keys.Length-1 do

		
--		hzj_print(subQuestData:GetOpenLevel())
		local weiTuoHeroPanelCls = require "GUI.WeiTuo.weiTuoHeroPanel".New(self.Layout)
		self.weiTuoHeroPanel[#self.weiTuoHeroPanel + 1] = weiTuoHeroPanelCls
		local weiTuoItemCls = require "GUI.WeiTuo.WeituoItem".New(self.Layout,i,self.weiTuoHeroPanel[#self.weiTuoHeroPanel])
		
		self:AddChild(weiTuoItemCls)
		self.weiTuoItem[#self.weiTuoItem + 1] = weiTuoItemCls
		self.weiTuoItem[#self.weiTuoItem]:SetCallBack(self,self.ItemDidCallBack)
		self:AddChild(weiTuoHeroPanelCls)
	end
end

local function DelayTime(self,index)
	coroutine.step()
	self.Layout.transform.localPosition=Vector3(0, weiTuoItemHeight*(index-1), 0)
end



function WeituoCls:ItemDidCallBack(self,table,flag)
	
	for i=1,#self.weiTuoHeroPanel do
		self.weiTuoHeroPanel[i]:Show(false)
	end
	local index = 0
	for i=1,#self.weiTuoItem do
		if self.weiTuoItem[i]== table then
			index=i
			--hzj_print(i)	
			if flag then
				self.weiTuoItem[i].onClickTime=1	
			else
				self.weiTuoItem[i].onClickTime=0	
			end
		else
			self.weiTuoItem[i].onClickTime=0	
		end
	end
	self:StartCoroutine(DelayTime,index)
end

function WeituoCls:RegisterControlEvents()
	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

	-- 注册 BackButton 的事件
	self.__event_button_onBackButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackButtonClicked, self)
	self.BackButton.onClick:AddListener(self.__event_button_onBackButtonClicked__)
end

function WeituoCls:UnregisterControlEvents()
	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

	-- 取消注册 BackButton 的事件
	if self.__event_button_onBackButtonClicked__ then
		self.BackButton.onClick:RemoveListener(self.__event_button_onBackButtonClicked__)
		self.__event_button_onBackButtonClicked__ = nil
	end

end

function WeituoCls:RegisterNetworkEvents()
end

function WeituoCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function WeituoCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end
function WeituoCls:OnBackButtonClicked()
	local sceneManager =  utility:GetGame():GetSceneManager()
    sceneManager:PopScene()
	
end
return WeituoCls
