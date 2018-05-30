local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local WeituoItemCls = Class(BaseNodeClass)
require "System.LuaDelegate"
function WeituoItemCls:Ctor(parent,index,weiTuoPanel)
	self.parent=parent
	self.weiTuoPanel=weiTuoPanel	
	self.index=index

	--hzj_print(subQuestData)
	
end
function WeituoItemCls:SetCallBack(table,callBack)
	self.callback = LuaDelegate.New()
	self.callback:Set(table,callBack)
	self.table=table

end




-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function WeituoItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/WeituoItem', function(go)
		self:BindComponent(go, false)
	end)
end

function WeituoItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent, true)

	--self:LinkComponent(self.parent)
end

function WeituoItemCls:OnResume()
	-- 界面显示时调用
	WeituoItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.onClickTime=0
end

function WeituoItemCls:OnPause()
	-- 界面隐藏时调用
	WeituoItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function WeituoItemCls:OnEnter()
	-- Node Enter时调用
	WeituoItemCls.base.OnEnter(self)
end

function WeituoItemCls:OnExit()
	-- Node Exit时调用
	WeituoItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function WeituoItemCls:InitControls()
	local transform = self:GetUnityTransform()
	-- transform:SetParent(self.parent)
	self.WeituoItem = transform:Find('Button'):GetComponent(typeof(UnityEngine.UI.Button))
	--未开启状态
	self.Lock= transform:Find('Lock')
	self.LockTitle=transform:Find('Lock/TitleText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OpenLevelText=transform:Find('Lock/OpenLevelText'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.Lock.gameObject:SetActive(false)
	--开启状态
	self.Open= transform:Find('Open')
	--self.Open.gameObject:SetActive(false)

	self:InitViews()

end

function WeituoItemCls:InitViews()

	local SubQuestCls = require "StaticData.WeiTuo.SubQuest"
	self.subQuestData = SubQuestCls:GetData(self.index+1)

	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local needLevel = self.subQuestData:GetOpenLevel()
    if userData:GetLevel()>=needLevel then

    	self.Open.gameObject:SetActive(true)
		self.Lock.gameObject:SetActive(false)
		--表示未委托（点击是进入委托界面）
		if self.index ==1 then
			self.isOpen=false
		--表示已委托 未完成（点击是弹出）
		elseif self.index ==2 then
		
		--表示已委托 已完成（点击是领取）
		elseif self.index ==3 then
			self.isOpen=false

		end


	else
		--是否可以点开
		self.isOpen=false
		self.Open.gameObject:SetActive(false)
		self.Lock.gameObject:SetActive(true)
		self.LockTitle.text="第"..self.index.."委托槽"
		self.OpenLevelText.text=needLevel.."级开启"
    end

end


function WeituoItemCls:RegisterControlEvents()
	-- 注册 WeituoItem 的事件
	self.__event_button_onWeituoItemClicked__ = UnityEngine.Events.UnityAction(self.OnWeituoItemClicked, self)
	self.WeituoItem.onClick:AddListener(self.__event_button_onWeituoItemClicked__)
end

function WeituoItemCls:UnregisterControlEvents()
	-- 取消注册 WeituoItem 的事件
	if self.__event_button_onWeituoItemClicked__ then
		self.WeituoItem.onClick:RemoveListener(self.__event_button_onWeituoItemClicked__)
		self.__event_button_onWeituoItemClicked__ = nil
	end
end

function WeituoItemCls:RegisterNetworkEvents()
end

function WeituoItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function WeituoItemCls:OnWeituoItemClicked()
	--WeituoItem控件的点击事件处理
	if self.index ==1 then
		self.isOpen=false
	    local sceneManager = self:GetGame():GetSceneManager()
		local HeroSceneClass = require "GUI.WeiTuo.Zhenrong"
		sceneManager:PushScene(HeroSceneClass.New())
		--表示已委托 未完成（点击是弹出）
	elseif self.index ==2 then
		
		--表示已委托 已完成（点击是领取）
	elseif self.index ==3 then
			self.isOpen=false

	end


	if self.isOpen==false then	
		return
	end
	self.onClickTime=self.onClickTime+1
	if self.onClickTime%2==1 then
		self.callback:Invoke(self.table,self,true)

		self.weiTuoPanel:Show(true)
	else
		self.callback:Invoke(self.table,self,false)

		self.weiTuoPanel:Show(false)

	end

end

return WeituoItemCls
