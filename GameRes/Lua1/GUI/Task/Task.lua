local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Collection.OrderedDictionary"
require "GUI.Spine.SpineController"
--require "Const"
--require "LUT.StringTable"



-----------------------------------------------------------------------
local TaskCls = Class(BaseNodeClass)
windowUtility.SetMutex(TaskCls, true)

function TaskCls:Ctor()
	local ctrl = SpineController.New()
	self.ctrl = ctrl
end
function TaskCls:OnWillShow()

end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TaskCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Task', function(go)
		self:BindComponent(go)
	end)
end

function TaskCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitVariable()
	self:InitControls()
end

function TaskCls:OnResume()
	-- 界面显示时调用
	TaskCls.base.OnResume(self)

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_MissionView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:InitSpineShow()
	self:OnTaskQueryRequest()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[10].systemGuideID,self)

end

function TaskCls:OnPause()
	-- 界面隐藏时调用
	TaskCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:CloseSpine()
end

function TaskCls:OnEnter()
	-- Node Enter时调用
	TaskCls.base.OnEnter(self)
end

function TaskCls:OnExit()
	-- Node Exit时调用
	TaskCls.base.OnExit(self)
end


function TaskCls:IsTransition()
    return false
end

function TaskCls:OnExitTransitionDidStart(immediately)
	TaskCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function TaskCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function TaskCls:InitSpineShow()
	self.ctrl:SetData(self.skeletonGraphic,self.speakerLabel,5)
end

function TaskCls:CloseSpine()
	self.ctrl:Stop()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function TaskCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	-- 返回按钮
 	self.RetrunButton = transform:Find('Base/RetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))

 	-- 挂点
 	self.nodePoint = transform:Find('Base/Scroll View/Viewport/Content')
 	self.speakerLabel = transform:Find("Base/Frame/Text"):GetComponent(typeof(UnityEngine.UI.Text))
 	self.skeletonGraphic = transform:Find('Base/jianba/SkeletonGraphic (jianba)'):GetComponent(typeof(Spine.Unity.SkeletonGraphic))

 	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
end

function TaskCls:InitVariable()
	self.myGame = utility:GetGame()
	-- 子类管理
	self.NodeCtrlDict = OrderedDictionary.New()
end


function TaskCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function TaskCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function TaskCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
	self.myGame:RegisterMsgHandler(net.S2CTaskDrawResult, self, self.OnTaskDrawResponse)
end

function TaskCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CTaskDrawResult, self, self.OnTaskDrawResponse)
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function TaskCls:OnTaskQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".TaskQueryRequest())
end

function TaskCls:OnTaskDrawRequest(ctype,taskid)
	self.myGame:SendNetworkMessage( require"Network/ServerService".TaskDrawRequest(ctype,taskid))
end

function TaskCls:OnTaskQueryResponse(msg)
	-- 任务Query 结果
	self:RefreshItemNode(msg)
end

function TaskCls:OnTaskDrawResponse(msg)
	require "Utils.GameAnalysisUtils".TaskDrawDone(msg.taskid, msg.type)
	self:OnDrewResult(msg.taskid)
end

-----------------------------------------------------------------------
function TaskCls:RefreshItemNode(msg)
	local nodeCls = require "GUI.Task.TaskItemNode"

	--子类排序列表
	self.NodeSortDict = OrderedDictionary.New()

	for i = 1 ,#msg.dailyTasks do
		
		local node = nodeCls.New(self.nodePoint)
		local id = msg.dailyTasks[i].id

		if not self.NodeCtrlDict:Contains(id) then
			
			self:AddChild(node)
			node:SetCallback(self,self.NodeItemCallback)
			node:RefreshItem(msg.dailyTasks[i])
			self.NodeCtrlDict:Add(id,node)

		else 
			local hasNode = self.NodeCtrlDict:GetEntryByKey(id)
			hasNode:RefreshItem(msg.dailyTasks[i])
		end

		if msg.dailyTasks[i].state == 1 then
			self.NodeSortDict:Add(id,node)
		end
	end

	-- 排序
	-- local sortIndex = 0
	-- local keys = self.NodeSortDict:GetKeys()
	-- for i = 1 ,#keys do
	-- 	local sortNode = self.NodeSortDict:GetEntryByKey(keys[i])
	-- 	sortNode:SetSortFunc(sortIndex)
	-- 	sortIndex = sortIndex + 1
	-- end
end

function TaskCls:OnDrewResult(id)
	-- 领取结束刷新	
	local items = self:GetItemsTables(id)

	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,items)

	local contains = self.NodeCtrlDict:Contains(id)
	if contains then
		local node = self.NodeCtrlDict:GetEntryByKey(id)
		self:RemoveChild(node)
		self.NodeCtrlDict:Remove(id)
		self.NodeSortDict:Remove(id)
	end
end

function TaskCls:GetItemsTables(id)
	
	local staticData = require "StaticData.Task":GetData(id)
	local items = {}
	local itemID_1 = staticData:GetItemID_1()
	local itemID_2 = staticData:GetItemID_2() 
	if itemID_1 ~= 0 then
		local count = staticData:GetItemNum_1()
		items[#items + 1] = self:GetItemTable(itemID_1,count)
	end
	if itemID_2 ~= 0 then
		local count = staticData:GetItemNum_2()
		items[#items + 1] = self:GetItemTable(itemID_2,count)
	end

	return items
end

function TaskCls:GetItemTable(id,count)
	
	local gametool = require "Utils.GameTools"
	local item = {}
	item.id = id
	item.count = count
	local _,data,_,_,itype = gametool.GetItemDataById(id)
	item.color = gametool.GetItemColorByType(itype,data)
	return item
end

function TaskCls:OnRetrunButtonClicked()
	-- 返回事件
	self:Close()
end

function TaskCls:NodeItemCallback(id,completed,Done)
	-- 点击回调
	if Done then
		self:Close()
		return
	end
	
	if completed then
		self:OnTaskDrawRequest(1,id)
	end
end


return TaskCls