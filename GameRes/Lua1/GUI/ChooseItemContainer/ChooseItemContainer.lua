local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"

require "Collection.OrderedDictionary"
require "System.LuaDelegate"
-----------------------------------------------------------------------
-----------------------------------------------------------------------
local ChooseItemContainerCls = Class(BaseNodeClass)
windowUtility.SetMutex(ChooseItemContainerCls, true)

function ChooseItemContainerCls:Ctor()
	self.chooseDict = OrderedDictionary.New()
	self.callback = LuaDelegate.New()
end
function ChooseItemContainerCls:OnWillShow(ctable,func,itemCls,data,confirmFunc,maxSelectCount,activeNodeDict,closeFunc)
	
	--- @ctable,func:点击回调方法 itemCls:显示的item类 data:要显示数据的字典 confirmFunc:确定按钮方法
	--- maxSelectCount:最大可以同时选中的数量 1单选 nil没有限制 activeNodeDict:初始化需要显示选中的字典,key为item在显示数据中的位置索引
	--- 
	self.itemCls = itemCls
	self.data = data

	-- 确定方法
	utility.ASSERT(type(confirmFunc) == "function","参数 confirmFunc 必须是 function 类型!")
	self.confirmFunc = confirmFunc
	--utility.ASSERT(type(closeFunc) == "function","参数 closeFunc 必须是 function 类型!")
	self.closeFunc=closeFunc
	-- 最大选择数量
	self.maxSelectCount = maxSelectCount

	-- 激活的字典
	self.activeNodeDict = activeNodeDict
	
	self.callback:Set(ctable,func)
	self.ctable = ctable
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ChooseItemContainerCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ChooseItemContainer', function(go)
		self:BindComponent(go)
	end)
end

function ChooseItemContainerCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LoadBagScrollContent()
end

function ChooseItemContainerCls:OnResume()
	-- 界面显示时调用
	ChooseItemContainerCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RefreshPanel()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)

    self:BringToFront()
end

function ChooseItemContainerCls:OnPause()
	-- 界面隐藏时调用
	ChooseItemContainerCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self.ScrollNode:ClearSelectedState()
end

function ChooseItemContainerCls:OnEnter()
	-- Node Enter时调用
	ChooseItemContainerCls.base.OnEnter(self)
end

function ChooseItemContainerCls:OnExit()
	-- Node Exit时调用
	ChooseItemContainerCls.base.OnExit(self)
end


function ChooseItemContainerCls:IsTransition()
    return false
end

function ChooseItemContainerCls:OnExitTransitionDidStart(immediately)
	ChooseItemContainerCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ChooseItemContainerCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ChooseItemContainerCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	
	-- 背包返回按钮
	self.BackpackReturnButton = transform:Find('Base/CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	-- 确定按钮
	self.ConferButton = transform:Find('Base/ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 背包挂点
	self.scrollTrans = transform:Find('Base/Layout')


	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()
end


function ChooseItemContainerCls:RegisterControlEvents()
	-- 注册 背包返回按钮 的事件
    self.__event_button_onBackpackReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackReturnButtonClicked, self)
    self.BackpackReturnButton.onClick:AddListener(self.__event_button_onBackpackReturnButtonClicked__)

    	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

    -- 注册 确定按钮 的事件
    self.__event_button_onConferButtonButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonButtonClicked, self)
    self.ConferButton.onClick:AddListener(self.__event_button_onConferButtonButtonClicked__)
end

function ChooseItemContainerCls:UnregisterControlEvents()
	 -- 取消注册 背包返回按钮 的事件
    if self.__event_button_onBackpackReturnButtonClicked__ then
        self.BackpackReturnButton.onClick:RemoveListener(self.__event_button_onBackpackReturnButtonClicked__)
        self.__event_button_onBackpackReturnButtonClicked__ = nil
    end

     -- 取消注册 确定按钮 的事件
    if self.__event_button_onConferButtonButtonClicked__ then
        self.ConferButton.onClick:RemoveListener(self.__event_button_onConferButtonButtonClicked__)
        self.__event_button_onConferButtonButtonClicked__ = nil
    end

    -- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------

-----------------------------------------------------------------------
function ChooseItemContainerCls:LoadBagScrollContent()
	-- 加载背包滑动控件
	local itemCls = require "GUI.Knapsack.SellItemNode"
	self.ScrollNode = require "GUI.ChooseItemContainer.ItemContainerScrollNode".New(self.scrollTrans,self,self.OnItemClicked,self.itemCls)
	self:AddChild(self.ScrollNode)
end

function ChooseItemContainerCls:OnItemClicked(index,active,...)
	-- local  arg = { ... }

	-- for i=1,#arg do
	-- 	debug_print(arg[i],"背包点击")
	-- end

	-- -- 背包点击
		

 -- 	arg = { ... }
	-- for i=1,#arg do
	-- 	debug_print(arg[i],"OnItemClicked")
	-- end


	self:RefreshChooseItem(index,active)
	
	self.callback:Invoke(...)

end

local function DelayRefreshActiveNode(self)
	-- 设置显示
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	if self.activeNodeDict == nil then
		return
	end
	local keys = self.activeNodeDict:GetKeys()
	for i = 1,#keys do
		self:RefreshChooseItem(keys[i],true)
	end

end

function ChooseItemContainerCls:RefreshPanel()
	-- 更新数据
	local count = self.data:Count()
	self.ScrollNode:UpdateScrollContent(count,self.data)
	self.ScrollNode:ResetVerticalOffset(1)

	-- coroutine.start(DelayRefreshActiveNode,self)
	self:StartCoroutine(DelayRefreshActiveNode)
end


function ChooseItemContainerCls:RefreshChooseItem(index,active)
	debug_print(index,active,"RefreshChooseItem")
	-- 刷新选择
	if self.maxSelectCount == 1 then
		self:RefreshSingleChoose(index,active)
	elseif self.maxSelectCount == nil then
		self.ScrollNode:AddSelectedState(index,active)
		self.ScrollNode:SetItemSelecetdState()
	else
		self:RefreshMultiplyChoose(index,active)		
	end
	
end

function ChooseItemContainerCls:RefreshMultiplyChoose(index,active)
	-- 多选
	debug_print("多选",index,active)
	if active then
		if not self.chooseDict:Contains(index) then
		self.chooseDict:Add(index,active)
		end
	else
		if self.chooseDict:Contains(index) then
			self.chooseDict:Remove(index)
		end

		--self.chooseDict:Remove(index)
	end
	
	local hasCount = self.chooseDict:Count()
	debug_print(hasCount , self.maxSelectCount)
	if hasCount > self.maxSelectCount then
		local keys = self.chooseDict:GetKeys()
		local removekey = keys[#keys]
		debug_print(">>>>>removekey>>>>>>",removekey,keys)
		self.chooseDict:Remove(removekey)
		self.ScrollNode:AddSelectedState(removekey,false)
		debug_print(">>>>>removekey>>>>>>",self.chooseDict:Count())
	else
		debug_print(">>>>>addkey>>>>>>",index,active)

		self.ScrollNode:AddSelectedState(index,active)
	end
	--设置item的Active
	self.ScrollNode:SetItemSelecetdState()
end

function ChooseItemContainerCls:RefreshSingleChoose(index,active)
	-- 单选
	self.ScrollNode:ClearSelectedState()
	self.ScrollNode:AddSelectedState(index,active)
	self.ScrollNode:SetItemSelecetdState()
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ChooseItemContainerCls:OnBackpackReturnButtonClicked()
	-- 返回
	if self.closeFunc ~= nil then
		self.closeFunc(self.ctable)
	end
	self:Close()
end

function ChooseItemContainerCls:OnReturnButtonClicked()
	self:Close()
end


function ChooseItemContainerCls:OnConferButtonButtonClicked()
	-- 确定
	self.confirmFunc(self.ctable)
	self:Close()
end

return ChooseItemContainerCls