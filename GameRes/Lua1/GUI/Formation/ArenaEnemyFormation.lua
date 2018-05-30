local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Collection.OrderedDictionary"

local ArenaEnemyFormationCls = Class(BaseNodeClass)
windowUtility.SetMutex(ArenaEnemyFormationCls, true)

function ArenaEnemyFormationCls:Ctor()
end

function ArenaEnemyFormationCls:OnWillShow(uid,data,zhanli,func,arg)
	self.uid = uid
	self.data = data
	self.zhanli = zhanli

	--确定按钮方法
	utility.ASSERT(type(func) == "function","参数func类型需为function")
	utility.ASSERT(type(arg) == "table","table")
	self.func = func
	self.arg = arg
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ArenaEnemyFormationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ArenaEnemyFormation', function(go)
		self:BindComponent(go)
	end)
end

function ArenaEnemyFormationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ArenaEnemyFormationCls:OnResume()
	-- 界面显示时调用
	ArenaEnemyFormationCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:GetCardData()
	self.isClicked = false

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function ArenaEnemyFormationCls:OnPause()
	-- 界面隐藏时调用
	ArenaEnemyFormationCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ArenaEnemyFormationCls:OnEnter()
	-- Node Enter时调用
	ArenaEnemyFormationCls.base.OnEnter(self)
end

function ArenaEnemyFormationCls:OnExit()
	-- Node Exit时调用
	ArenaEnemyFormationCls.base.OnExit(self)
end

function ArenaEnemyFormationCls:IsTransition()
    return true
end

function ArenaEnemyFormationCls:OnExitTransitionDidStart(immediately)
	ArenaEnemyFormationCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ArenaEnemyFormationCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ArenaEnemyFormationCls:InitControls()
	local transform = self:GetUnityTransform()

	self.transform = transform
	self.ArenaEnemyFormationConfirmButton = transform:Find('Base/ArenaEnemyFormationConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.heroCardLayout = transform:Find('Base/LayoutFront')
	self.heroCardLayoutBack = transform:Find('Base/LayoutBack')
	self.tweenObjectTrans = transform:Find('Base')
	self.ReturnButton = transform:Find('Base/ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.zhanliLabel = transform:Find('Base/Strength/StrengthNumLabelMine'):GetComponent(typeof(UnityEngine.UI.Text))
	self.confirmLabel = transform:Find('Base/ArenaEnemyFormationConfirmButton/TitleText'):GetComponent(typeof(UnityEngine.UI.Text))

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	self.myGame = utility:GetGame()
end


function ArenaEnemyFormationCls:RegisterControlEvents()
	-- 注册 ArenaEnemyFormationConfirmButton 的事件
	self.__event_button_onArenaEnemyFormationConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaEnemyFormationConfirmButtonClicked, self)
	self.ArenaEnemyFormationConfirmButton.onClick:AddListener(self.__event_button_onArenaEnemyFormationConfirmButtonClicked__)

	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function ArenaEnemyFormationCls:UnregisterControlEvents()
	-- 取消注册 ArenaEnemyFormationConfirmButton 的事件
	if self.__event_button_onArenaEnemyFormationConfirmButtonClicked__ then
		self.ArenaEnemyFormationConfirmButton.onClick:RemoveListener(self.__event_button_onArenaEnemyFormationConfirmButtonClicked__)
		self.__event_button_onArenaEnemyFormationConfirmButtonClicked__ = nil
	end

	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function ArenaEnemyFormationCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CPlayerSimpleInfoQueryResult, self, self.OnPlayerSimpleInfoQueryResponse)
end

function ArenaEnemyFormationCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CPlayerSimpleInfoQueryResult, self, self.OnPlayerSimpleInfoQueryResponse)
end

function ArenaEnemyFormationCls:OnPlayerSimpleInfoQueryRequest(uid)
	-- 查询玩家信息 请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".PlayerSimpleInfoQueryRequest(uid))
end

function ArenaEnemyFormationCls:OnPlayerSimpleInfoQueryResponse(msg)
	-- 查询玩家信息 请求Response
	self.zhanli = msg.playerSimpleInfo.zhanli
	self:ResetCardView(msg.playerSimpleInfo.items)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ArenaEnemyFormationCls:OnArenaEnemyFormationConfirmButtonClicked()
	--ArenaEnemyFormationConfirmButton控件的点击事件处理
	if not self.isClicked then
		self.isClicked = true
		self:Close()
		self.func(self.arg)
	end
end

function ArenaEnemyFormationCls:OnReturnButtonClicked()
	self:Close()
end


function ArenaEnemyFormationCls:GetCardData()
	-- 请求数据
	if self.data == nil then
		self.confirmStr = "确定"
		self:OnPlayerSimpleInfoQueryRequest(self.uid)		
	else
		self.confirmStr = "挑战"
		self:ResetCardView(self.data)
	end

	self.transform:SetAsLastSibling()
end


function ArenaEnemyFormationCls:ResetCardView(data)
	-- 显示上阵卡牌
	local dict = OrderedDictionary.New()
	for i = 1 ,#data do
		local key = data[i].cardPos
		local velue = data[i]
		dict:Add(key,velue)
	end

	local nodeCls = require "GUI.Arena.FormationItem"
	local EmptyNodeCls = require "GUI.Arena.EmptyFormationNode"
	local node
	local layout

	for i = 1,6 do

		if i < 4 then
			layout = self.heroCardLayout
		else
			layout = self.heroCardLayoutBack
		end

		local itemData = dict:GetEntryByKey(i)
		if itemData == nil then
			node = EmptyNodeCls.New(layout)
		else
			node = nodeCls.New(layout,i,true)
			node:ResetViewByData(itemData)
		end
		
		self:AddChild(node)
	end
	self.confirmLabel.text = self.confirmStr
	self.zhanliLabel.text = self.zhanli
end


return ArenaEnemyFormationCls