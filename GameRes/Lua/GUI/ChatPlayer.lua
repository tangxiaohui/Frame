local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local ChatPlayerCls = Class(BaseNodeClass)
windowUtility.SetMutex(ChatPlayerCls, true)

function ChatPlayerCls:Ctor()
end

function ChatPlayerCls:OnWillShow(msg,friendData)
	self.fromPlayerUID = msg
	self.friendData = friendData
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ChatPlayerCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ChatPlayer', function(go)
		self:BindComponent(go)
	end)
end

function ChatPlayerCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ChatPlayerCls:OnResume()
	-- 界面显示时调用
	ChatPlayerCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:OnFriendsQueryRequest(100,self.fromPlayerUID) 
	self:SetAddFriend(self.fromPlayerUID)
	--self:InitView()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function ChatPlayerCls:OnPause()
	-- 界面隐藏时调用
	ChatPlayerCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ChatPlayerCls:OnEnter()
	-- Node Enter时调用
	ChatPlayerCls.base.OnEnter(self)
end

function ChatPlayerCls:OnExit()
	-- Node Exit时调用
	ChatPlayerCls.base.OnExit(self)
end

function ChatPlayerCls:IsTransition()
    return true
end

function ChatPlayerCls:OnExitTransitionDidStart(immediately)
	ChatPlayerCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ChatPlayerCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ChatPlayerCls:InitControls()
	local transform = self:GetUnityTransform()
	self.GrayFarme = transform:Find('Base/WindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatPlayerRetrunButton = transform:Find('Base/ChatPlayerRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChatPlayerNameLabel = transform:Find('Base/ChatPlayerNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.HeadBase = transform:Find('Base/Head/HeadBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatPlayerHeadIcon = transform:Find('Base/Head/Mask/ChatPlayerHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatPlayerLvLabel = transform:Find('Base/Lv/ChatPlayerLvLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Lv_Title = transform:Find('Base/Lv/Lv_Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatPlayerStartChattingButton = transform:Find('Base/ChatPlayerStartChattingButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChatPlayerBlacklistButton = transform:Find('Base/ChatPlayerBlacklistButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.JoinGuildButton = transform:Find('Base/Layout/JoinGuildButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.AddAsFriendButton = transform:Find('Base/Layout/AddAsFriendButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.tweenObjectTrans = transform:Find("Base")
	self.firstAdd = 0
	self.myGame = utility:GetGame()
end


function ChatPlayerCls:RegisterControlEvents()
	-- 注册 ChatPlayerRetrunButton 的事件
	self.__event_button_onChatPlayerRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatPlayerRetrunButtonClicked, self)
	self.ChatPlayerRetrunButton.onClick:AddListener(self.__event_button_onChatPlayerRetrunButtonClicked__)

	-- 注册 ChatPlayerStartChattingButton 的事件
	self.__event_button_onChatPlayerStartChattingButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatPlayerStartChattingButtonClicked, self)
	self.ChatPlayerStartChattingButton.onClick:AddListener(self.__event_button_onChatPlayerStartChattingButtonClicked__)

	-- 注册 ChatPlayerBlacklistButton 的事件
	self.__event_button_onChatPlayerBlacklistButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatPlayerBlacklistButtonClicked, self)
	self.ChatPlayerBlacklistButton.onClick:AddListener(self.__event_button_onChatPlayerBlacklistButtonClicked__)

	-- 注册 JoinGuildButton 的事件
	self.__event_button_onJoinGuildButtonClicked__ = UnityEngine.Events.UnityAction(self.OnJoinGuildButtonClicked, self)
	self.JoinGuildButton.onClick:AddListener(self.__event_button_onJoinGuildButtonClicked__)

	-- 注册 AddAsFriendButton 的事件
	self.__event_button_onAddAsFriendButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAddAsFriendButtonClicked, self)
	self.AddAsFriendButton.onClick:AddListener(self.__event_button_onAddAsFriendButtonClicked__)
end

function ChatPlayerCls:UnregisterControlEvents()
	-- 取消注册 AddAsFriendButton 的事件
	if self.__event_button_onAddAsFriendButtonClicked__ then
		self.AddAsFriendButton.onClick:RemoveListener(self.__event_button_onAddAsFriendButtonClicked__)
		self.__event_button_onAddAsFriendButtonClicked__ = nil
	end

	-- 取消注册 JoinGuildButton 的事件
	if self.__event_button_onJoinGuildButtonClicked__ then
		self.JoinGuildButton.onClick:RemoveListener(self.__event_button_onJoinGuildButtonClicked__)
		self.__event_button_onJoinGuildButtonClicked__ = nil
	end

	-- 取消注册 ChatPlayerRetrunButton 的事件
	if self.__event_button_onChatPlayerRetrunButtonClicked__ then
		self.ChatPlayerRetrunButton.onClick:RemoveListener(self.__event_button_onChatPlayerRetrunButtonClicked__)
		self.__event_button_onChatPlayerRetrunButtonClicked__ = nil
	end

	-- 取消注册 ChatPlayerStartChattingButton 的事件
	if self.__event_button_onChatPlayerStartChattingButtonClicked__ then
		self.ChatPlayerStartChattingButton.onClick:RemoveListener(self.__event_button_onChatPlayerStartChattingButtonClicked__)
		self.__event_button_onChatPlayerStartChattingButtonClicked__ = nil
	end

	-- 取消注册 ChatPlayerBlacklistButton 的事件
	if self.__event_button_onChatPlayerBlacklistButtonClicked__ then
		self.ChatPlayerBlacklistButton.onClick:RemoveListener(self.__event_button_onChatPlayerBlacklistButtonClicked__)
		self.__event_button_onChatPlayerBlacklistButtonClicked__ = nil
	end
end

function ChatPlayerCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CFriendsQueryResult,self,self.OnFriendsQueryResponse)
	self.myGame:RegisterMsgHandler(net.S2CTalkAddToBlackResult,self,self.TalkAddToBlackResult)
end

function ChatPlayerCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsQueryResult,self,self.OnFriendsQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CTalkAddToBlackResult,self,self.TalkAddToBlackResult)
end
function ChatPlayerCls:TalkAddToBlackResult(msg)
	
end

----------------------------------------------------------------------
function ChatPlayerCls:OnTalkQueryRequest(id)
	-- 聊天请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".TalkAddToBlackRequest(tostring(id)))
end

function ChatPlayerCls:OnFriendsQueryRequest(queryType,playerUid)
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendsQueryRequest(queryType,playerUid))
end

function ChatPlayerCls:OnFriendsQueryResponse(msg)
	self.ghID = msg.ghID
	local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
	if self.ghID ~= 0 and ghId == 0 then
		self.JoinGuildButton.gameObject:SetActive(true)
	else
		self.JoinGuildButton.gameObject:SetActive(false)
	end
	local playerName
	local headID
	local playerLevel
	local headColor 
	if msg.head.sid == 100 then
		for i=1,#msg.list do
			playerName = msg.list[i].playerName
			headID = msg.list[i].headID
			playerLevel = msg.list[i].playerLevel
			headColor = msg.list[i].headColor
		end

	end
	
	self.ChatPlayerNameLabel.text = playerName
	self.ChatPlayerLvLabel.text = playerLevel
	utility.LoadPlayerHeadIcon(headID,self.ChatPlayerHeadIcon)

end


function ChatPlayerCls:SetAddFriend(uid)
	if self.friendData ~= nil then
		for i = 1, #self.friendData do
			if uid == self.friendData[i].playerUID then
				self.AddAsFriendButton.gameObject:SetActive(false)
				break
			else
				self.AddAsFriendButton.gameObject:SetActive(true)
			end
		end
	end
end

function ChatPlayerCls:GetFriendList()
	local dataCacheMgr = self.myGame:GetDataCacheManager()
	local UserDataType = require "Framework.UserDataType"
	local datas = dataCacheMgr:GetData(UserDataType.FriendData)
	local uidTable = {}
	if datas ~= nil  then
		local data = datas:GetData(1)
		if data ~= nil then
			local cached = data:GetData()
			if cached ~= nil then
				for i = 1 ,cached:Count() do
					local playerData = cached:GetEntryByIndex(i)
					uidTable[#uidTable + 1] = playerData:GetUid()
				end
			end
		end
	end
	return uidTable
end

--------------
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ChatPlayerCls:OnChatPlayerRetrunButtonClicked()
	--ChatPlayerRetrunButton控件的点击事件处理
	self:Close()
end

function ChatPlayerCls:OnChatPlayerStartChattingButtonClicked()
	--ChatPlayerStartChattingButton控件的点击事件处理
	self:Close()
	print(self.fromPlayerName)
	local eventMgr = self.myGame:GetEventManager()
 	eventMgr:PostNotification('LaunchToChatMessage', nil, self.ChatPlayerNameLabel.text)
end

local function AddToBlack(self)
	self:OnTalkQueryRequest(self.fromPlayerUID)
	self:Close()
end

function ChatPlayerCls:OnChatPlayerBlacklistButtonClicked()
	--ChatPlayerBlacklistButton控件的点击事件处理
	local windowManager = utility:GetGame():GetWindowManager()

	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if self.fromPlayerUID == userData:GetUid() then 
    	local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
    	windowManager:Show(ErrorDialogClass, "不能将自己加入黑名单")
    else 
    	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
		windowManager:Show(ConfirmDialogClass, "确定加入黑名单吗？",self, AddToBlack)
	end
	
end

local firstJoin = 0
function ChatPlayerCls:OnJoinGuildButtonClicked()
	if firstJoin == 0 then
		firstJoin = firstJoin + 1
		utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHJoinRequest(self.ghID))
		self.JoinGuildButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
	end
end

function ChatPlayerCls:OnAddAsFriendButtonClicked()
	if self.firstAdd == 0 then
		self.firstAdd = self.firstAdd + 1
		utility:GetGame():SendNetworkMessage( require"Network/ServerService".FriendsAddRequest(self.fromPlayerUID))
		self.AddAsFriendButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
	end
	-- local UserDataType = require "Framework.UserDataType"
	-- local dataCacheMgr = self:GetGame():GetDataCacheManager()
	-- local datas = dataCacheMgr:GetData(UserDataType.FriendData)
	
end

--------------------------------------------------------------------------
function ChatPlayerCls:InitView()
	--self.ChatPlayerNameLabel.text = self.msg.fromPlayerName
	--self.ChatPlayerLvLabel.text = self.msg.playerLevel
end




return ChatPlayerCls