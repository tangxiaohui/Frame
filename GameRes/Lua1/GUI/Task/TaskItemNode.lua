local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
require "LUT.StringTable"

local UnityEngine_Color = UnityEngine.Color
local ShaDowColor = UnityEngine_Color(0.5,0.5,0.5,1)
local NormalColor = UnityEngine_Color(1,1,1,1)


local TaskItemNodeCls = Class(BaseNodeClass)

function TaskItemNodeCls:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
end


function TaskItemNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TaskItemNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/TaskElement', function(go)
		self:BindComponent(go,false)
	end)
end

function TaskItemNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
	self:LoadAwardItem()
end

function TaskItemNodeCls:OnResume()
	-- 界面显示时调用
	TaskItemNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function TaskItemNodeCls:OnPause()
	-- 界面隐藏时调用
	TaskItemNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function TaskItemNodeCls:OnEnter()
	-- Node Enter时调用
	TaskItemNodeCls.base.OnEnter(self)
end

function TaskItemNodeCls:OnExit()
	-- Node Exit时调用
	TaskItemNodeCls.base.OnExit(self)
end



-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function TaskItemNodeCls:InitControls()
	local transform = self:GetUnityTransform()


	
	-- button
	self.itemButton = transform:GetComponent(typeof(UnityEngine.UI.Button))

	-- 背景图片
	self.itemBgImage = transform:GetComponent(typeof(UnityEngine.UI.Image))
	
	-- 完成图标
	self.statusImageObj = transform:Find('TaskElementStatus').gameObject

	-- 名称
	self.titleNameLabel = transform:Find('Title/TaskElementNameLable'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 内容
	self.descriptionLabel = transform:Find('Title/TaskElementBriefingLable'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 进度条图片
	self.progressImage = transform:Find('TaskElementProgressBar/BigLibrarySpeciesProgressBarMask/Base'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 进度Label
	self.progressLabel = transform:Find('TaskElementProgressBar/BigLibrarySpeciesProgressBarNumLable'):GetComponent(typeof(UnityEngine.UI.Text))	

	-- 进度obj
	self.progressObj = transform:Find('TaskElementProgressBar').gameObject

	-- 奖励挂点
	self.AwardPoint = transform:Find('Award')

	-- 红点
	self.redDot = transform:Find("RedDotImage").gameObject

	self.AwardItemTable = {}
end


function TaskItemNodeCls:RegisterControlEvents()
	-- -- 注册 BackpackRetrunButton 的事件
	self.__event_button_onitemButtonClicked__ = UnityEngine.Events.UnityAction(self.OnitemButtonClicked, self)
	self.itemButton.onClick:AddListener(self.__event_button_onitemButtonClicked__)
end

function TaskItemNodeCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onitemButtonClicked__ then
		self.itemButton.onClick:RemoveListener(self.__event_button_onitemButtonClicked__)
		self.__event_button_onitemButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function DelayRefreshItem(self,data)
	-- 刷新
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.ItemID = data.id
	local staticData = require "StaticData.Task":GetData(self.ItemID)
	
	-- 名字
	local name = staticData:GetName()
	self.titleNameLabel.text = name

	-- 描述
	local description = staticData:GetDescription()
	self.descriptionLabel.text = description
	
	-- 完成状态
	local complete = data.state
	-- 进度
	local done = data.done
	-- 是否完成
	local IsCompleted
	self.IsCompleted = nil
	self.completeState = 0
	-- 状态颜色
	local bgColor = NormalColor
	-- 是否前往
	local isDoneButton

	if complete == -1 then

		-- 未完成不可领取
		bgColor = ShaDowColor
		self.progressImage.fillAmount = 0
		self.progressLabel.text = CommonStringTable[6]
		self.completeState = -1
	elseif complete == 0 then

		-- 未完成
		local limit = staticData:GetLimit()
		self.progressImage.fillAmount = done / limit
		self.progressLabel.text = string.format("%s%s%s",done,"/",limit)
		isDoneButton = true
		self.completeState = 0
	elseif complete == 1 then

		-- 已完成未领取
		IsCompleted = true
		self.IsCompleted = true
		self.completeState = 1	
	end

	self.statusImageObj:SetActive(IsCompleted)
	self.redDot:SetActive(IsCompleted)
	self.progressObj:SetActive(not IsCompleted)
	self.itemBgImage.color = bgColor

	-- 处理奖励
	local AwardItemID_1 = staticData:GetItemID_1() 
debug_print(self.ItemID,"   ++++++++++++++   ",data.state,AwardItemID_1)
	if AwardItemID_1 ~= 0 then
		
		local node = self.AwardItemTable[1]
		local active = node:GetActive()
		if not active then
			self:AddChild(node)
			node:SetActive(true)
		end

		local count = staticData:GetItemNum_1()
		node:RefreshItem(AwardItemID_1,count)
	end

	local AwardItemID_2 = staticData:GetItemID_2() 

	if AwardItemID_2 ~= 0 then
		
		local node = self.AwardItemTable[2]
		local active = node:GetActive()
		if not active then
			self:AddChild(node)
			node:SetActive(true)
		end
		local count = staticData:GetItemNum_2()
		node:RefreshItem(AwardItemID_2,count)
	else
		local node = self.AwardItemTable[2]
		if node:GetActive() then
			node:SetActive(false)
			self:RemoveChild(node)
		end
	end

end

function TaskItemNodeCls:RefreshItem(data)
	-- 刷新
	-- coroutine.start(DelayRefreshItem,self,data)
	self:StartCoroutine(DelayRefreshItem, data)
end

function TaskItemNodeCls:SetSortFunc(index)
	self:SetSiblingIndex(index)
	--self:GetUnityTransform():SetSiblingIndex(index)
end

function TaskItemNodeCls:GetID()
	return self.ItemID
end


function TaskItemNodeCls:LoadAwardItem()
	-- 加载奖励预制体
	local nodeCls = require "GUI.Task.TaskAwardItem"
	local labelTheme = {}
	labelTheme.fontSize = 23
	labelTheme.fontColor = UnityEngine.Color(1,1,1,1)
	labelTheme.fonteffectColor = UnityEngine.Color(0,0,0,1)
	labelTheme.effectDistance = Vector2(2,-2)

	for i = 1 ,2 do
		local node = nodeCls.New(self.AwardPoint,true,labelTheme)
		self.AwardItemTable[#self.AwardItemTable + 1] = node
	end
end
----------------------------------------------------------------


function TaskItemNodeCls:OnitemButtonClicked()
	debug_print("id  ++++++  " )
	
	local done = (self.completeState == 0 and self.ItemID ~=2101)
	self.callback:Invoke(self.ItemID,self.IsCompleted,done)
	debug_print(self.IsCompleted,"self.IsCompleted",self.completeState,done)
	if done then
		self:GotoAssignScene(self.ItemID)
	end
end

function TaskItemNodeCls:GotoAssignScene(id)
	
	local windowManager = self:GetGame():GetWindowManager()
	local sceneManager = utility:GetGame():GetSceneManager()
	local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"       
	debug_print("id  ++++++  ",id )
	if id == 101 or id == 102 then		
   		local windowManager = self:GetGame():GetWindowManager()
   		 windowManager:Show(require "GUI.Deposit.Deposit")
    	

	elseif id == 401 then

		-- 装备强化
		 windowManager:Show(require "GUI.Knapsack.Knapsack")
	elseif id == 501 then

		-- 英雄升级
   		local HeroSceneClass = require "Scenes.HeroScene"
    	sceneManager:PushScene(HeroSceneClass.New())
    	
	elseif id == 601 then

		-- 主线副本
		local CheckpointSceneClass = require "Scenes.CheckpointScene"
    	sceneManager:PushScene(CheckpointSceneClass.New())
	elseif id == 701 then

		-- 支线副本
		local CheckpointSceneClass = require "Scenes.CheckpointScene"
    	sceneManager:PushScene(CheckpointSceneClass.New())
	elseif id == 801 then

		-- 孵化宠物
		local ElvenTreeCls = require "GUI.ElvenTree.ElvenTree"
    	sceneManager:PushScene(ElvenTreeCls.New())
	elseif id == 901 then

		-- 抢夺成功
		local ElvenTreeCls = require "GUI.ElvenTree.ElvenTree"
    	sceneManager:PushScene(ElvenTreeCls.New())
	elseif id == 1001 then

		-- 保卫公主
	    local ProtectPrincessClass = require "Scenes.ProtectThePrincessScene"
    	sceneManager:PushScene(ProtectPrincessClass.New())
		
	elseif id == 1101 then

		-- 竞技勇者
		local ArenaCls = require "GUI.Arena.Arena"
   		sceneManager:PushScene(ArenaCls.New())
	elseif id == 1201 then

		-- 军团征兵
    	sceneManager:PushScene(require "GUI.Guild.Guild".New(0))
	elseif id == 1401 then
		-- 点石成金
		local messageGuids = require "Framework.Business.MessageGuids"
		self:DispatchEvent(messageGuids.OnCoinBuyWithDiamond)		
	elseif id == 1301 then

		-- 军团副本
		sceneManager:PushScene(require "GUI.Guild.Guild".New(0))
	elseif id == 1501 then

		-- 神秘龙穴
	local SelectChallengdungeonCls = require "GUI.Explore.Explore"
	sceneManager:PushScene(SelectChallengdungeonCls.New())
	elseif id == 1601 then

		-- 骷髅海
		local SelectChallengdungeonCls = require "GUI.Explore.Explore"
	sceneManager:PushScene(SelectChallengdungeonCls.New())
	elseif id == 1701 then

		-- 魔力战场
		local SelectChallengdungeonCls = require "GUI.Explore.Explore"
	sceneManager:PushScene(SelectChallengdungeonCls.New())
	elseif id == 1801 then

		-- 绝境求生
		local SelectChallengdungeonCls = require "GUI.Explore.Explore"
	sceneManager:PushScene(SelectChallengdungeonCls.New())
	elseif id == 1901 then

		-- 国战
		windowManager:Show(ErrorDialogClass, "国战系统暂未开放")
	elseif id == 2001 then
 		
 		 local GemCombineCls = require "GUI.Tower.Tower"
   		 sceneManager:PushScene(GemCombineCls.New())
	end

end


return TaskItemNodeCls