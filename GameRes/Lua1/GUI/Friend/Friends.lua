local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local UserDataType = require "Framework.UserDataType"
local messageGuids = require "Framework.Business.MessageGuids"
require "Collection.OrderedDictionary"
require "Collection.DataQueue"

local FriendState 	    = 1
local StaminaState		= 2
local AddFriendState	= 3
local WaitFriendState	= 4
-----------------------------------------------------------------------
local FriendCls = Class(BaseNodeClass)
windowUtility.SetMutex(FriendCls, true)

function FriendCls:Ctor()
end

function FriendCls:OnWillShow()
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function FriendCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Friend', function(go)
		self:BindComponent(go)
	end)
end

function FriendCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function FriendCls:OnResume()
	-- 界面显示时调用
	FriendCls.base.OnResume(self)

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_FriendView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:StateChangeCtrl(FriendState)
	self:RedDotStateQuery()
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function FriendCls:OnPause()
	-- 界面隐藏时调用
	FriendCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function FriendCls:OnEnter()
	-- Node Enter时调用
	FriendCls.base.OnEnter(self)
end

function FriendCls:OnExit()
	-- Node Exit时调用
	FriendCls.base.OnExit(self)
end

function FriendCls:IsTransition()
    return true
end

function FriendCls:OnExitTransitionDidStart(immediately)
	FriendCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function FriendCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function FriendCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find("Base")
	self.nodePoint = transform:Find('Base/Scroll View/Viewport/Content')

	self.closeButton = transform:Find('Base/Base/RetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FriendButton = transform:Find('Base/FriendButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.StaminaButton = transform:Find('Base/StaminaButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.AddButton = transform:Find('Base/AddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.WaitButton = transform:Find('Base/ListButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SearchButton = transform:Find('Base/SearchButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.RefereshButton = transform:Find('Base/RefereshButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SendAllButton = transform:Find('Base/SendAllButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.GetAllButton = transform:Find('Base/GetAllButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.inputLabel = transform:Find('Base/InputField'):GetComponent(typeof(UnityEngine.UI.InputField))
	--self.Frame = transform:Find('Base/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.ShopRetrunButton = 
	self.myGame = utility:GetGame()
	self.nodePoolQueue = DataQueue.New()
	self.activeNodeDict = OrderedDictionary.New()

	self.tiliRedImage = transform:Find('Base/StaminaButton/RedImage').gameObject
	self.listRedImage = transform:Find('Base/ListButton/RedImage').gameObject

	self.NoMailTip = transform:Find('Base/NoMailTip').gameObject

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.StateSyncTable = {false,false,false,false}
end


function FriendCls:RegisterControlEvents()
	-- 注册 CloseButton 的事件
	self.__event_button_onCloseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCloseButtonClicked, self)
	self.closeButton.onClick:AddListener(self.__event_button_onCloseButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCloseButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 FriendButton 的事件
	self.__event_button_onFriendButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFriendButtonClicked, self)
	self.FriendButton.onClick:AddListener(self.__event_button_onFriendButtonClicked__)

	-- 注册 StaminaButton 的事件
	self.__event_button_onStaminaButtonClicked__ = UnityEngine.Events.UnityAction(self.OnStaminaButtonClicked, self)
	self.StaminaButton.onClick:AddListener(self.__event_button_onStaminaButtonClicked__)

	-- 注册 AddButton 的事件
	self.__event_button_onAddButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAddButtonClicked, self)
	self.AddButton.onClick:AddListener(self.__event_button_onAddButtonClicked__)

	-- 注册 WaitButton 的事件
	self.__event_button_onWaitButtonClicked__ = UnityEngine.Events.UnityAction(self.OnWaitButtonClicked, self)
	self.WaitButton.onClick:AddListener(self.__event_button_onWaitButtonClicked__)

	-- 注册 SearchButton 的事件
	self.__event_button_onSearchButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSearchButtonClicked, self)
	self.SearchButton.onClick:AddListener(self.__event_button_onSearchButtonClicked__)

	-- 注册 RefereshButton 的事件
	self.__event_button_onRefereshButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRefereshButtonClicked, self)
	self.RefereshButton.onClick:AddListener(self.__event_button_onRefereshButtonClicked__)

	-- 注册 SendAllButton 的事件
	self.__event_button_onSendAllButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSendAllButtonClicked, self)
	self.SendAllButton.onClick:AddListener(self.__event_button_onSendAllButtonClicked__)

	-- 注册 GetAllButton 的事件
	self.__event_button_onGetAllButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGetAllButtonClicked, self)
	self.GetAllButton.onClick:AddListener(self.__event_button_onGetAllButtonClicked__)
end

function FriendCls:UnregisterControlEvents()
	--取消注册 GetAllButton 的事件
	if self.__event_button_onGetAllButtonClicked__ then
		self.GetAllButton.onClick:RemoveListener(self.__event_button_onGetAllButtonClicked__)
		self.__event_button_onGetAllButtonClicked__ = nil
	end

	--取消注册 SendAllButton 的事件
	if self.__event_button_onSendAllButtonClicked__ then
		self.SendAllButton.onClick:RemoveListener(self.__event_button_onSendAllButtonClicked__)
		self.__event_button_onSendAllButtonClicked__ = nil
	end


	--取消注册 CloseButton 的事件
	if self.__event_button_onCloseButtonClicked__ then
		self.closeButton.onClick:RemoveListener(self.__event_button_onCloseButtonClicked__)
		self.__event_button_onCloseButtonClicked__ = nil
	end

	--取消注册 FriendButton 的事件
	if self.__event_button_onFriendButtonClicked__ then
		self.FriendButton.onClick:RemoveListener(self.__event_button_onFriendButtonClicked__)
		self.__event_button_onFriendButtonClicked__ = nil
	end

	--取消注册 StaminaButton 的事件
	if self.__event_button_onStaminaButtonClicked__ then
		self.StaminaButton.onClick:RemoveListener(self.__event_button_onStaminaButtonClicked__)
		self.__event_button_onStaminaButtonClicked__ = nil
	end

	--取消注册 AddButton 的事件
	if self.__event_button_onAddButtonClicked__ then
		self.AddButton.onClick:RemoveListener(self.__event_button_onAddButtonClicked__)
		self.__event_button_onAddButtonClicked__ = nil
	end

	--取消注册 WaitButton 的事件
	if self.__event_button_onWaitButtonClicked__ then
		self.WaitButton.onClick:RemoveListener(self.__event_button_onWaitButtonClicked__)
		self.__event_button_onWaitButtonClicked__ = nil
	end

	--取消注册 SearchButton 的事件
	if self.__event_button_onSearchButtonClicked__ then
		self.SearchButton.onClick:RemoveListener(self.__event_button_onSearchButtonClicked__)
		self.__event_button_onSearchButtonClicked__ = nil
	end

	--取消注册 RefereshButton 的事件
	if self.__event_button_onRefereshButtonClicked__ then
		self.RefereshButton.onClick:RemoveListener(self.__event_button_onRefereshButtonClicked__)
		self.__event_button_onRefereshButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function FriendCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CFriendsQueryResult, self, self.FriendsQueryResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendsAddResult, self, self.FriendsAddResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendSearchResult, self, self.FriendSearchResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendsApplyListResult, self, self.FriendApplyListResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendsDealResult, self, self.FriendDealResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendsDelResult, self, self.FriendDelResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendTiliSendResult, self, self.FriendTiliSendResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendTiliQueryResult, self, self.FriendTiliQueryResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendTiliDrawResult, self, self.FriendTiliDrawResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendsUpdateFlush, self, self.FriendsUpdateFlushResponse)
	self.myGame:RegisterMsgHandler(net.S2CFriendsViewListResult, self, self.FriendsViewListResponse)
	self.myGame:RegisterMsgHandler(net.S2CTalkAddToBlackResult,self,self.TalkAddToBlackResult)

end

function FriendCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsQueryResult, self, self.FriendsQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsAddResult, self, self.FriendsAddResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendSearchResult, self, self.FriendSearchResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsApplyListResult, self, self.FriendApplyListResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsDealResult, self, self.FriendDealResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsDelResult, self, self.FriendDelResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendTiliSendResult, self, self.FriendTiliSendResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendTiliQueryResult, self, self.FriendTiliQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendTiliDrawResult, self, self.FriendTiliDrawResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsUpdateFlush, self, self.FriendsUpdateFlushResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsViewListResult, self, self.FriendsViewListResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CTalkAddToBlackResult,self,self.TalkAddToBlackResult)
end




function FriendCls:TalkAddToBlackResult(msg)
	local cached = self:GetLocalCachedData()
	local uid = msg.playerUID
	local data = cached:DeletedDataByUid(FriendState,uid)
	--cached:UpdateDataByUid(FriendState,uid,data)
	-- if msg.type == 1 then
		
	-- 	cached:UpdateSendState(FriendState,uid,not msg.isSendTili)
	-- end
	local node = self:GetActiveNode(uid)
	if node ~= nil then
		self:RemoveChild(node)
		self:RemoveActivenode(uid)
	end
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function FriendCls:OnFriendsQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendsQueryRequest(1,"1"))
end

function FriendCls:OnFriendsAddRequest(playerUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendsAddRequest(playerUID))
end

function FriendCls:OnFriendSearchRequest(playerName)
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendSearchRequest(playerName))
end

function FriendCls:OnFriendsApplyListRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendsApplyListRequest())
end

function FriendCls:OnFriendsDealRequest(playerUID,type)
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendsDealRequest(playerUID,type))
end

function FriendCls:OnFriendsDelRequest(playerUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendsDelRequest(playerUID))
end

function FriendCls:OnFriendTiliSendRequest(playerUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendTiliSendRequest(playerUID))
end

function FriendCls:OnFriendTiliQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendTiliQueryRequest())
end

function FriendCls:OnFriendTiliDrawRequest(playerUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendTiliDrawRequest(playerUID))
end

function FriendCls:OnFriendsViewListRequest(sid)
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendsViewListRequest(sid))
end

function FriendCls:FriendsQueryResponse(msg)
	self.friendData = msg.list
	if not self:GetStateIsSync(FriendState) then
		self:SetStateSync(FriendState)
	end
	self:ReciveResponse(msg,FriendState)
end

function FriendCls:FriendsAddResponse(msg)
	local uid = msg.playerUID
	local node = self:GetActiveNode(uid)
	if node ~= nil then
		self:RemoveChild(node)
		self:RemoveActivenode(uid)
	end
	--local cached = self:GetLocalCachedData()
	--cached:UpdateSendState(FriendState,uid,false)
end

function FriendCls:FriendSearchResponse(msg)
	self:HideNodes()
	self.inputLabel.text = ""
	self:ShowItem(msg.frieds,AddFriendState)
	--self:ReciveResponse(msg,FriendState)
end

function FriendCls:FriendApplyListResponse(msg)
	if not self:GetStateIsSync(WaitFriendState) then
		self:SetStateSync(WaitFriendState)
	end
	self:ReciveResponse(msg,WaitFriendState)
end

function FriendCls:FriendDealResponse(msg)
	local cached = self:GetLocalCachedData()
	local uid = msg.playerUID
	local data = cached:DeletedDataByUid(WaitFriendState,uid)
	if msg.type == 1 then
		cached:UpdateDataByUid(FriendState,uid,data)
		cached:UpdateSendState(FriendState,uid,not msg.isSendTili)
	end
	local node = self:GetActiveNode(uid)
	if node ~= nil then
		self:RemoveChild(node)
		self:RemoveActivenode(uid)
	end
end

function FriendCls:FriendDelResponse(msg)
	local cached = self:GetLocalCachedData()
	local uid = msg.playerUID
	local node = self:GetActiveNode(uid)
	if node ~= nil then
		self:RemoveChild(node)
		self:RemoveActivenode(uid)
	end
	cached:DeletedDataByUid(FriendState,uid)
	self:CheckFriendIsNull()
end

function FriendCls:FriendTiliSendResponse(msg)
	-- print_debug(msg.playerUID)
	if msg.playerUID ~= "0" then
		local node = self:GetActiveNode(msg.playerUID)
		if node ~= nil then
			node:SetHideSendButton()
		end
		local cached = self:GetLocalCachedData()
		cached:UpdateSendState(FriendState,msg.playerUID,false)
	else
		for i=1,self.activeNodeDict:Count() do
			local node = self.activeNodeDict:GetEntryByIndex(i)
			if node ~= nil then
				node:SetHideSendButton()
			end
			local cached = self:GetLocalCachedData()
			local key = self.activeNodeDict:GetKeyFromIndex(i)
			cached:UpdateSendState(FriendState,key,false)
		end
		
	end
end

function FriendCls:FriendTiliQueryResponse(msg)
	if not self:GetStateIsSync(StaminaState) then
		self:SetStateSync(StaminaState)
	end
	self:ReciveResponse(msg,StaminaState)
end

function FriendCls:FriendTiliDrawResponse(msg)
	if msg.playerUID ~= "0" then
		local uid = msg.playerUID
		local node = self:GetActiveNode(uid)
		if node ~= nil then
			self:RemoveChild(node)
			self:RemoveActivenode(uid)
		end
		local cached = self:GetLocalCachedData()
		cached:DeletedDataByUid(StaminaState,uid)
	else
		for i=1,self.activeNodeDict:Count() do
			local uid = self.activeNodeDict:GetKeyFromIndex(i)
			local node = self:GetActiveNode(uid)
			if node ~= nil then
				self:RemoveChild(node)
				self:RemoveActivenode(uid)
			end
			local cached = self:GetLocalCachedData()
			cached:DeletedDataByUid(StaminaState,uid)
		end
		
	end
end

function FriendCls:FriendsUpdateFlushResponse(msg)
	local cached = self:GetLocalCachedData()
	local uid = msg.playerUID
	if msg.operationType == 1 then
		cached:UpdateData(WaitFriendState,msg.blackItem)
		if self.currPanelState == WaitFriendState then
			self:ShowItem(msg.blackItem,WaitFriendState)
		end
	elseif msg.operationType == 2 then
		local sendState = not msg.isSendTili
		cached:UpdateData(FriendState,msg.blackItem)
		cached:UpdateSendState(FriendState,uid,sendState)
		if self.currPanelState == FriendState then
			self:ShowItem(msg.blackItem,FriendState,sendState)
		end
	elseif msg.operationType == 3 then
		cached:DeletedDataByUid(FriendState,uid)
		if self.currPanelState == FriendState then
			local node = self:GetActiveNode(uid)
			if node ~= nil then
				self:RemoveChild(node)
				self:RemoveActivenode(uid)
			end
		end
	elseif msg.operationType == 4 then
		cached:UpdateData(StaminaState,msg.blackItem)
		if self.currPanelState == StaminaState then
			self:ShowItem(msg.blackItem,StaminaState)
		end		
	end
	self:CheckFriendIsNull()
end

function FriendCls:FriendsViewListResponse(msg)
	if not self:GetStateIsSync(FriendState) then
		self:SetStateSync(AddFriendState)
	end
	debug_print("@@@@@@@ 好友啊",#msg.list)
	for i=1,#msg.list do
		hzj_print(msg.list[i].playerUID)
	end
	self:ReciveResponse(msg,AddFriendState)
end

function FriendCls:SendRequest(modle)
	if modle == FriendState then
		self:OnFriendsQueryRequest()
	elseif modle == StaminaState then
		self:OnFriendTiliQueryRequest()
	elseif modle == AddFriendState then
		self:OnFriendsViewListRequest(1)
	elseif modle == WaitFriendState then
		self:OnFriendsApplyListRequest()
	end
end

function FriendCls:ReciveResponse(msg,modle)
	self:SetCached(msg,modle)
	self:GetFriendCached(modle,true)
end

function FriendCls:RedDotStateQuery()
    -- 查询红点提示
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)

    if RedDotData ~= nil then
        -- 好友
        local freendTiliState = RedDotData:GetModuleRedState(S2CGuideRedResult.havefriendtili)
        local freendApplyState = RedDotData:GetModuleRedState(S2CGuideRedResult.friend_apply)
     	self.tiliRedImage:SetActive(freendTiliState == 1)
     	self.listRedImage:SetActive(freendApplyState == 1)
    end
end

function FriendCls:RedDotStateUpdated(moduleId,moduleState)
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    if moduleId == S2CGuideRedResult.havefriendtili then
        self.tiliRedImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.friend_apply then
    	self.listRedImage:SetActive(moduleState == 1)
    end
end
--------------------------------------------------
function FriendCls:GetFriendCached(modle,recive)
	local dataCacheMgr = self.myGame:GetDataCacheManager()
	local datas = dataCacheMgr:GetData(UserDataType.FriendData)
	if datas ~= nil  then
		local data = datas:GetData(modle)
		if data ~= nil then
			local cached = data:GetData()
			if cached ~= nil then
				self:ShowItemsByCache(cached,modle)
			else
				if recive then
					return
				end
				self:SendRequest(modle)
			end
		else
			self:SendRequest(modle)
		end
	else
		if recive then
				return
			end
		self:SendRequest(modle)
	end
end

function FriendCls:SetCached(msg,modle)
    local dataCacheMgr = self.myGame:GetDataCacheManager()
    dataCacheMgr:UpdateData(UserDataType.FriendData, function(oldData)
        require "Data.Friend.FriendData"
        if oldData == nil then
            oldData = TotalFriendData.New()
        end
        
        local datas = msg.list
        oldData:SetDataByModle(datas,modle)

       	if modle == FriendState then
       		local uids = utility.Split(msg.alerySendUID,",")
       		oldData:UpdateAlreadySend(FriendState,uids)
       	end
       	return oldData
    end)
end

function FriendCls:GetLocalCachedData()
	local dataCacheMgr = self.myGame:GetDataCacheManager()
	local cached = dataCacheMgr:GetData(UserDataType.FriendData)
    if cached == nil then
        require "Data.Friend.FriendData"
        cached = TotalFriendData.New()
    end
    return cached
end

function FriendCls:CheckFriendIsNull()
	if self.currPanelState ~= FriendState then
		return
	end
	local cached = self:GetLocalCachedData()
	local count  = cached:GetModleCount(FriendState)
	local active = (count == 0)
	self.NoMailTip:SetActive(active)
end
-------------------------------------------------
function FriendCls:ItemCallBack(modle,uid,playerName)
	if modle == 1 then
		self:OnFriendsDelRequest(uid)
	elseif modle == 2 then
		self:Close()
		local windowManager = self:GetGame():GetWindowManager()
   		windowManager:Show(require "GUI.Chat",playerName)
	elseif modle == 3 then
		self:OnFriendTiliSendRequest(uid)
	elseif modle == 4 then
		self:OnFriendTiliDrawRequest(uid)
	elseif modle == 5 then
		self:OnFriendsAddRequest(uid)
	elseif modle == 6 then
		self:OnFriendsDealRequest(uid,1)
	elseif modle == 7 then
		self:OnFriendsDealRequest(uid,2)
	end
end

function FriendCls:GetItemNode(modle)
	local nodeCls = require "GUI.Friend.FriendItem"
	local node = self.nodePoolQueue:Dequeue()
	--Enqueue

	if node == nil then		
		node = nodeCls.New(self.nodePoint,self.friendData)
		node:SetCallback(self,self.ItemCallBack)
	end
	return node
end

function FriendCls:GetActiveNode(key)
	if self.activeNodeDict == nil then
		return
	end
	return self.activeNodeDict:GetEntryByKey(key)
end

function FriendCls:RemoveActivenode(key)
	if self.activeNodeDict == nil then
		return
	end
	if self.activeNodeDict:Contains(key) then
		local node = self.activeNodeDict:GetEntryByKey(key)
		self.nodePoolQueue:Enqueue(node)
		self.activeNodeDict:Remove(key)
	end
end

function FriendCls:HideNodes()
	if self.activeNodeDict == nil then
		return
	end
	local keys = self.activeNodeDict:GetKeys()
	for i = 1 ,#keys do
		local key = keys[i]
		local node = self.activeNodeDict:GetEntryByKey(key)
		self:RemoveChild(node)
		self.activeNodeDict:Remove(key)
		self.nodePoolQueue:Enqueue(node)
	end
end

function FriendCls:ShowItemsByCache(datas,modle)
	local length = datas:Count()
	for i = 1 ,length do
		local node = self:GetItemNode(modle)
		local playerData = datas:GetEntryByIndex(i)
		local uid = playerData:GetUid()
		if not self.activeNodeDict:Contains(uid) and uid ~= "" then
			hzj_print("ShowItemsByCache",uid)
			node:SetUid(uid)
			node:SetPlayerLevel(playerData:GetPlayerLevel())
			node:SetPlayerName(playerData:GetPlayerName())
			node:SetZhanli(playerData:GetZhanli())
			node:SetHeadID(playerData:GetHeadID())
			if self.state == modle then
			if modle == FriendState then
				node:SetState(playerData:GetState())
			end
			node:SetPattern(modle)
		
		
			self:AddChild(node)
			self.activeNodeDict:Add(uid,node)
			end
		end
	end

	self:CheckFriendIsNull()
end

function FriendCls:ShowItem(data,state,sendState)
	local node
	local uid = data.playerUID
	local isAdd
	if self.activeNodeDict:Contains(uid) then
		node = self.activeNodeDict:GetEntryByKey(uid)
	else
		node = self:GetItemNode(state)	
		isAdd = true
	end
	hzj_print("ShowItem",uid)
	node:SetUid(uid)
	node:SetPlayerLevel(data.playerLevel)
	node:SetPlayerName(data.playerName)
	node:SetZhanli(data.zhanli)
	node:SetHeadID(data.headID)
	node:SetPattern(state)
	if sendState ~= nil then
		node:SetState(sendState)
	end

	if isAdd then
		self:AddChild(node)
		self.activeNodeDict:Add(uid,node)
	else
		node:ResetView()
	end

	self:CheckFriendIsNull()
end
--------------------------------------------------
--------------------------------------------------
--- 状态管理
--------------------------------------------------
function FriendCls:StateChangeCtrl(state)
	-- 状态切换
	if self.currPanelState == state then		
		return 
	end

	if self.currPanelState ~= nil then
		self:OnPanelStateExit(self.currPanelState)
	end
	self.state = state
	self:OnPanelStateEnter(state)
end

function FriendCls:OnPanelStateEnter(state)
	-- 状态进入
	self.currPanelState = state
	
	if state == FriendState then		
		self:ChangeButtonTheme(self.FriendButton)
		self:OnFriendStateEnter()

	elseif state == StaminaState then
		self:ChangeButtonTheme(self.StaminaButton)
		self:OnStaminaStateEnter()

	elseif state == AddFriendState then
		self:ChangeButtonTheme(self.AddButton)
		self:OnAddFriendStateEnter()

	elseif state == WaitFriendState then
		self:ChangeButtonTheme(self.WaitButton)
		self:OnWaitFriendStateEnter()
	end

end

function FriendCls:OnPanelStateExit(state)
	-- 状态退出

	if state == FriendState then
		self:OnFriendStateExit()
	elseif state == StaminaState then
		self:OnStaminaStateExit()
	elseif state == AddFriendState then
		self:OnAddFriendStateExit()
	elseif state == WaitFriendState then
		self:OnWaitFriendStateExit()
	end

	self.currPanelState = nil
end
-------------------------------------------------
function FriendCls:GetStateIsSync(modle)
	return self.StateSyncTable[modle]
end

function FriendCls:SetStateSync(modle)
	self.StateSyncTable[modle] = true
end

function FriendCls:GetCachedShow(modle)
	if self:GetStateIsSync(modle) then
		hzj_print("self:GetStateIsSync(modle)",self:GetStateIsSync(modle),modle)
		self:GetFriendCached(modle)
	else
		hzj_print("self:GetStateIsSync(modle)",modle)
		self:SendRequest(modle)
	end
end

function FriendCls:OnFriendStateEnter()
	self:GetCachedShow(FriendState)
	self:CheckFriendIsNull()
	self.SendAllButton.gameObject:SetActive(true)
	
end

function FriendCls:OnStaminaStateEnter()
	self:GetCachedShow(StaminaState)
	self.GetAllButton.gameObject:SetActive(true)
end

function FriendCls:OnAddFriendStateEnter()
	self:GetCachedShow(AddFriendState)
	self.SearchButton.gameObject:SetActive(true)
	self.inputLabel.gameObject:SetActive(true)
	self.RefereshButton.gameObject:SetActive(true)
end

function FriendCls:OnWaitFriendStateEnter()
	self:GetCachedShow(WaitFriendState)
end

function FriendCls:OnFriendStateExit()
	self:HideNodes()
	self.NoMailTip:SetActive(false)
	self.SendAllButton.gameObject:SetActive(false)
end

function FriendCls:OnStaminaStateExit()
	self:HideNodes()
	self.GetAllButton.gameObject:SetActive(false)
end

function FriendCls:OnAddFriendStateExit()
	self:HideNodes()
	self.SearchButton.gameObject:SetActive(false)
	self.inputLabel.gameObject:SetActive(false)
	self.RefereshButton.gameObject:SetActive(false)
end

function FriendCls:OnWaitFriendStateExit()
	self:HideNodes()
end
-------------------------------------------------
function FriendCls:OnFriendButtonClicked()
	self:StateChangeCtrl(FriendState)
end

function FriendCls:OnStaminaButtonClicked()
	self:StateChangeCtrl(StaminaState)
end

function FriendCls:OnAddButtonClicked()
	self:StateChangeCtrl(AddFriendState)
end

function FriendCls:OnWaitButtonClicked()
	self:StateChangeCtrl(WaitFriendState)
end

function FriendCls:OnSearchButtonClicked()
	local name = self.inputLabel.text
	self:OnFriendSearchRequest(name)
end

function FriendCls:OnRefereshButtonClicked()
	--debug_print("发送刷新")
	self:HideNodes()
	self:OnFriendsViewListRequest(100)
end

function FriendCls:OnSendAllButtonClicked()
	self:OnFriendTiliSendRequest(tostring(0))
end

function FriendCls:OnGetAllButtonClicked()
	self:OnFriendTiliDrawRequest(tostring(0))
end

function FriendCls:OnCloseButtonClicked()
	self:Close()
end
---------------------------------------------------
-------------------BUTTON 样式---------------------
-- button 选中颜色
local ButtonSelectedImageColor = UnityEngine.Color(1,1,1,1)
local ButtonNormalImageColor = UnityEngine.Color(0.537254,0.537254,0.537254,1)
local function ChangePosition(object,offset)
	-- 改变组件位置
	local transform = object.transform
	local tempPosition = transform.localPosition
	tempPosition.x = tempPosition.x + offset
	object.transform.localPosition = tempPosition
end

local function SetLabelTheme(label,OnShow)
	--设置文字样式
	local outLine = label:GetComponent(typeof(UnityEngine.UI.Outline))
	if OnShow then
		label.fontSize = 45
		label.color = UnityEngine.Color(1,1,1,1)
		outLine.enabled = true
	else
		label.fontSize = 36
		label.color = UnityEngine.Color(0,0,0,1)
		outLine.enabled = false
	end
end 

function FriendCls:ChangeButtonTheme(targetButton)
	-- 更改button按钮选中主题
	local gameTool = require "Utils.GameTools"	
	local buttonImage = targetButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	buttonImage.color = ButtonSelectedImageColor
	ChangePosition(targetButton,-30)
	local textLabel = targetButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	SetLabelTheme(textLabel,true)

	if self.OnSelectButton ~= nil then
		local onSelectButtonImage = self.OnSelectButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
		onSelectButtonImage.color = ButtonNormalImageColor
		ChangePosition(self.OnSelectButton,30)
		local textLabel = self.OnSelectButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		SetLabelTheme(textLabel,false)
	end

	self.OnSelectButton = targetButton
end



return FriendCls