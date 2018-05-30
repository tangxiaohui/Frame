local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local ArenaRankCls = Class(BaseNodeClass)
require "Const"
windowUtility.SetMutex(ArenaRankCls, true)

function ArenaRankCls:Ctor()
	
end
function ArenaRankCls:OnWillShow(rankState)
	-- self.parent = parent
	self.rankState = rankState
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ArenaRankCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ArenaRank', function(go)
		self:BindComponent(go)
	end)
end

function ArenaRankCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ArenaRankCls:OnResume()
	-- 界面显示时调用
	ArenaRankCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:LoadPanel()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function ArenaRankCls:OnPause()
	-- 界面隐藏时调用
	ArenaRankCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ArenaRankCls:OnEnter()
	-- Node Enter时调用
	ArenaRankCls.base.OnEnter(self)
end

function ArenaRankCls:OnExit()
	-- Node Exit时调用
	ArenaRankCls.base.OnExit(self)
end

function ArenaRankCls:IsTransition()
    return false
end

function ArenaRankCls:OnExitTransitionDidStart(immediately)
	ArenaRankCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ArenaRankCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ArenaRankCls:InitControls()
	local transform = self:GetUnityTransform()
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.BigFarme = transform:Find('Base/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.UpperBorder = transform:Find('Base/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.LowerBorder = transform:Find('Base/LowerBorder'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.BalckBase = transform:Find('Base/BalckBase'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.FightTitle = transform:Find('Base/FightTitle'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.GrayFarme = transform:Find('Base/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ArenaRankReturnButton = transform:Find('Base/ArenaRankReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.WhiteBase = transform:Find('Base/WhiteBase'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.ArenaRankTextLabel = transform:Find('Base/ArenaRankTextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.RankListLayout = transform:Find('Base/RankListLayout'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	--self.Viewport = transform:Find('Base/RankListLayout/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.RankListLayout = transform:Find('Base/RankListLayout/Viewport/Content')
	self.tweenObjectTrans = transform:Find('Base')
	self.myGame = utility:GetGame()

	self.items = {}
end


function ArenaRankCls:RegisterControlEvents()
	-- 注册 ArenaRankReturnButton 的事件
	self.__event_button_onArenaRankReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaRankReturnButtonClicked, self)
	self.ArenaRankReturnButton.onClick:AddListener(self.__event_button_onArenaRankReturnButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaRankReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function ArenaRankCls:UnregisterControlEvents()
	-- 取消注册 ArenaRankReturnButton 的事件
	if self.__event_button_onArenaRankReturnButtonClicked__ then
		self.ArenaRankReturnButton.onClick:RemoveListener(self.__event_button_onArenaRankReturnButtonClicked__)
		self.__event_button_onArenaRankReturnButtonClicked__ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function ArenaRankCls:RegisterNetworkEvents()
	-- 注册 竞技场Top50 请求 Response
	self.myGame:RegisterMsgHandler(net.S2CArenaTop50QueryResult, self, self.OnArenaTop50QueryResponse)

	-- 注册 公会积分战Top50 请求 Response
	self.myGame:RegisterMsgHandler(net.S2CGHPointTop50QueryResult, self, self.GHPointTop50QueryResult)

	-- 注册 爬塔rank 请求 Response
	self.myGame:RegisterMsgHandler(net.S2CTowerRankQueryResult, self, self.OnTowerRankQueryResult)

end

function ArenaRankCls:UnregisterNetworkEvents()
	-- 取消注册 竞技场Top50 请求 Response
	self.myGame:UnRegisterMsgHandler(net.S2CArenaTop50QueryResult, self, self.OnArenaTop50QueryResponse)

	-- 取消注册 公会积分战Top50 请求 Response
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointTop50QueryResult, self, self.GHPointTop50QueryResult)

	-- 取消注册 爬塔rank 请求 Response
	self.myGame:UnRegisterMsgHandler(net.S2CTowerRankQueryResult, self, self.OnTowerRankQueryResult)
end

----------------------------------------------------------------------
function ArenaRankCls:OnArenaTop50QueryRequest()
	-- 竞技场Top50 请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".ArenaTop50QueryRequest())
end

function ArenaRankCls:OnGHPointTop50QueryRequest()
	-- 公会积分战Top50 请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".GHPointTop50QueryRequest())
end

function ArenaRankCls:OnTowerRankQueryRequest()
	--爬塔排行请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".TowerRankQueryRequest())
end

function ArenaRankCls:OnArenaTop50QueryResponse(msg)
	self.msg = msg
	self:InitRankView()
end

function ArenaRankCls:GHPointTop50QueryResult(msg)
	self.msg = msg
	self:InitRankView()
end

function ArenaRankCls:OnTowerRankQueryResult(msg)
	self.msg = msg
	self:InitRankView()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ArenaRankCls:OnArenaRankReturnButtonClicked()
	--ArenaRankReturnButton控件的点击事件处理
	self:Close(true)
end


------------------------------------------------------------------------

function ArenaRankCls:LoadPanel()
	if self.rankState == kGuildFightRank then
		print("公会积分战")
		self:OnGHPointTop50QueryRequest()
	elseif self.rankState == kArenaRank then
		self:OnArenaTop50QueryRequest()
	elseif  self.rankState == kTowerRank then
		self:OnTowerRankQueryRequest()
	end
end

function ArenaRankCls:InitRankView()

	local count = #self.msg.rankItems
	print(count.."创建处理"..#self.items)
	-- if count ~= #self.items then
		-- self:RemoveAll()
		self:LoadRankItem(count)
	-- else
	-- 	self:ResetRankItemView()
	-- end
	
end

function ArenaRankCls:LoadRankItem(count)
	local rankItem = require "GUI.Arena.ArenaRankItem"
	for index=1,count do
		--for index=1,5 do
		local node = rankItem.New(self.RankListLayout,index)
		self:AddChild(node)
		-- self.items[#self.items + 1] = node
		node:ResetView(self.msg.rankItems[index],self.rankState)
	end
end

function ArenaRankCls:ResetRankItemView()
	-- 刷新Item信息
	for i=1,#self.items do
		--for i=1,5 do
		-- self:RemoveChild(self.items[i],true)
		self.items[i]:ResetView(self.msg.rankItems[i],self.rankState)
	end
end

function ArenaRankCls:ResetRankIndexItem(index)
	self.items[index]:ResetView(self.msg.rankItems[index],self.rankState)
end

function ArenaRankCls:RemoveAll()
	if self.items ~= nil then
		for i=1,#self.items do
		--for i=1,5 do
			self:RemoveChild(self.items[i],true)
		 
		end
		self.items = {}
	end
end



return ArenaRankCls