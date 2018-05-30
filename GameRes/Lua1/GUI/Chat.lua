local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local UserDataType = require "Framework.UserDataType"
require "Collection.DataQueue"

local WorldState 	    = 1
local GuildState		= 2
local WhisperingState	= 3
local LoudspeakerState	= 4
-----------------------------------------------------------------------
local ChatCls = Class(BaseNodeClass)
windowUtility.SetMutex(ChatCls, true)

function ChatCls:Ctor()
end

function ChatCls:OnWillShow(personName)
	self.personName = personName
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ChatCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Chat', function(go)
		self:BindComponent(go)
	end)
end

function ChatCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ChatCls:OnResume()
	-- 界面显示时调用
	ChatCls.base.OnResume(self)
	self:OnFriendsQueryRequest()
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:AddObserver()
	
	self:InitSpeakerNode()
	
	self:OnTalkQueryRequest()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
    self:ScheduleUpdate(self.Update)
end

--更新时间
function ChatCls:Update()
	if self.reaminTime ~=nil then
		local countFlag = false
		if os.time()-self.lastT>=1 then
			self.lastT=os.time()
			countFlag=true
		end
		if countFlag then			
			self.reaminTime=self.reaminTime-1000
		end		
	end
	if self.currPanelState ~= nil and self.currPanelState == WorldState then	
		--hzj_print(self.currPanelState,self.reaminTime)

		
		
			if self.reaminTime<=0 then
				self.SendButtonText.text="发送"			
			else
				
				self.SendButtonText.text=math.ceil(self.reaminTime/1000)
			end	
		
	else
		self.SendButtonText.text="发送"	
	end


end

function ChatCls:OnPause()
	-- 界面隐藏时调用
	ChatCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:RemoveObserver()
end

function ChatCls:OnEnter()
	-- Node Enter时调用
	ChatCls.base.OnEnter(self)
end

function ChatCls:OnExit()
	-- Node Exit时调用
	ChatCls.base.OnExit(self)
end

function ChatCls:IsTransition()
    return true
end

function ChatCls:OnExitTransitionDidStart(immediately)
	ChatCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ChatCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ChatCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find("Base")

	self.closeButton = transform:Find('Base/ChatRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChatWhisperingButton = transform:Find('Base/ChatWhisperingButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChatGuildButton = transform:Find('Base/ChatGuildButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChatLoudspeakerButton = transform:Find('Base/ChatLoudspeakerButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChatWorldButton = transform:Find('Base/ChatWorldButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SendButton = transform:Find('Base/Send/ChatSendButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SendButtonText = transform:Find('Base/Send/ChatSendButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 普通
	self.ChatInputFieldObj = transform:Find('Base/ChatInputField').gameObject
	self.normalInputLabel = transform:Find('Base/ChatInputField'):GetComponent(typeof(UnityEngine.UI.InputField))

	-- 私聊
	self.ChatEnterFriendObj = transform:Find('Base/ChatEnterFriend').gameObject
	self.privatePersonLabel = transform:Find('Base/ChatEnterFriend/PersonLabel'):GetComponent(typeof(UnityEngine.UI.InputField))
	self.privateContentLabel = transform:Find('Base/ChatEnterFriend/ContentLabel'):GetComponent(typeof(UnityEngine.UI.InputField))
	self.FrientButton = transform:Find('Base/ChatEnterFriend/ChatFrirendBtn'):GetComponent(typeof(UnityEngine.UI.Button))

	self.FreeTimeLabel = transform:Find('Base/FreeTime'):GetComponent(typeof(UnityEngine.UI.Text))

	self.ChatLayoutContent = transform:Find("Base/ChatList/ChatLayout/Mask/Content")
	self.ChatScrollbar = transform:Find("Base/ChatList/ChatLayout/Scrollbar Vertical"):GetComponent(typeof(UnityEngine.UI.Scrollbar))

	self.ChatSpeakerLayout = transform:Find("Base/ChatList/ChatSpeakerLayout/Mask/Content")
	self.ChatSpeakerGroup = self.ChatSpeakerLayout:GetComponent(typeof(UnityEngine.UI.ToggleGroup))

	self.chatRaycast = transform:Find('Base/ChatList/ChatLayout/Mask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.chatLoudspeakerRaycast = transform:Find('Base/ChatList/ChatSpeakerLayout/Mask'):GetComponent(typeof(UnityEngine.UI.Image))

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()
	self.nodeQueue = DataQueue.New()
	self.speakerNodeTable = {}
	self.activeNodeDict = OrderedDictionary.New()
    self.userData = self:GetUserData()
    self.broadcastID = 0
end


function ChatCls:RegisterControlEvents()
	-- 注册 CloseButton 的事件
	self.__event_button_onCloseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCloseButtonClicked, self)
	self.closeButton.onClick:AddListener(self.__event_button_onCloseButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCloseButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 ChatWhisperingButton 的事件
	self.__event_button_onChatWhisperingButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatWhisperingButtonClicked, self)
	self.ChatWhisperingButton.onClick:AddListener(self.__event_button_onChatWhisperingButtonClicked__)

	-- 注册 ChatGuildButton 的事件
	self.__event_button_onChatGuildButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatGuildButtonClicked, self)
	self.ChatGuildButton.onClick:AddListener(self.__event_button_onChatGuildButtonClicked__)

	-- 注册 ChatLoudspeakerButton 的事件
	self.__event_button_onChatLoudspeakerButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatLoudspeakerButtonClicked, self)
	self.ChatLoudspeakerButton.onClick:AddListener(self.__event_button_onChatLoudspeakerButtonClicked__)

	-- 注册 ChatWorldButton 的事件
	self.__event_button_onChatWorldButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatWorldButtonClicked, self)
	self.ChatWorldButton.onClick:AddListener(self.__event_button_onChatWorldButtonClicked__)

	-- 注册 SendButton 的事件
	self.__event_button_onSendButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSendButtonClicked, self)
	self.SendButton.onClick:AddListener(self.__event_button_onSendButtonClicked__)

	-- 注册 FrientButton 的事件
	self.__event_button_onFrientButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFrientButtonClicked, self)
	self.FrientButton.onClick:AddListener(self.__event_button_onFrientButtonClicked__)
end

function ChatCls:UnregisterControlEvents()
	--取消注册 CloseButton 的事件
	if self.__event_button_onCloseButtonClicked__ then
		self.closeButton.onClick:RemoveListener(self.__event_button_onCloseButtonClicked__)
		self.__event_button_onCloseButtonClicked__ = nil
	end

	--取消注册 ChatWhisperingButton 的事件
	if self.__event_button_onChatWhisperingButtonClicked__ then
		self.ChatWhisperingButton.onClick:RemoveListener(self.__event_button_onChatWhisperingButtonClicked__)
		self.__event_button_onChatWhisperingButtonClicked__ = nil
	end

	--取消注册 ChatGuildButton 的事件
	if self.__event_button_onChatGuildButtonClicked__ then
		self.ChatGuildButton.onClick:RemoveListener(self.__event_button_onChatGuildButtonClicked__)
		self.__event_button_onChatGuildButtonClicked__ = nil
	end

	--取消注册 ChatLoudspeakerButton 的事件
	if self.__event_button_onChatLoudspeakerButtonClicked__ then
		self.ChatLoudspeakerButton.onClick:RemoveListener(self.__event_button_onChatLoudspeakerButtonClicked__)
		self.__event_button_onChatLoudspeakerButtonClicked__ = nil
	end

	--取消注册 ChatWorldButton 的事件
	if self.__event_button_onChatWorldButtonClicked__ then
		self.ChatWorldButton.onClick:RemoveListener(self.__event_button_onChatWorldButtonClicked__)
		self.__event_button_onChatWorldButtonClicked__ = nil
	end

	--取消注册 SendButton 的事件
	if self.__event_button_onSendButtonClicked__ then
		self.SendButton.onClick:RemoveListener(self.__event_button_onSendButtonClicked__)
		self.__event_button_onSendButtonClicked__ = nil
	end

	--取消注册 FrientButton 的事件
	if self.__event_button_onFrientButtonClicked__ then
		self.FrientButton.onClick:RemoveListener(self.__event_button_onFrientButtonClicked__)
		self.__event_button_onFrientButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function ChatCls:RegisterNetworkEvents()
	 self.myGame:RegisterMsgHandler(net.S2CTalkQueryResult, self, self.OnTalkQueryResult)
	 self.myGame:RegisterMsgHandler(net.S2CFriendsQueryResult,self,self.OnFriendsQueryResponse)
end

function ChatCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CTalkQueryResult, self, self.OnTalkQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CFriendsQueryResult,self,self.OnFriendsQueryResponse)

end

function ChatCls:OnTalkQueryRequest()
	-- 聊天请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".TalkQueryRequest())
end

function ChatCls:OnTalkRequest(msgs,msgType,toPlayerUID,toPlayerName,gonghuiID,broadcastID)
	-- 发送聊天请求
	local  msg ,prototype = require"Network/ServerService".TalkRequest(msgs,msgType,toPlayerUID,toPlayerName,gonghuiID,broadcastID)
	msg.head.sid = 100
	self.myGame:SendNetworkMessage(msg,prototype)
end

function ChatCls:OnFriendsQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".FriendsQueryRequest(1,"1"))
end

function ChatCls:OnTalkQueryResult(msg)
	-- 聊天请求结果
	hzj_print(msg.remainFreeWorldTalk,msg.remainNeedCharge,msg.nextWoldTalkCharge)
	local freeCount = msg.remainNeedCharge
	self.reaminTime=msg.remainFreeWorldTalk
	self.lastT=0
	self:ResetHintPanel(freeCount)
end

function ChatCls:OnFriendsQueryResponse(msg)
	self.friendData = msg.list
	if self.personName ~= nil then
		self:LaunchToChatMessage(self.personName)
	else
		self:StateChangeCtrl(WorldState)
	end
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function ChatCls:ShopQueryRequest(ShopType)
	--self.myGame:SendNetworkMessage( require"Network/ServerService".ShopQueryRequest(ShopType))
end
--------------------------------------------------
function ChatCls:AddObserver()
    self:RegisterEvent('ChangeChatMessage',self.ChangeChatMessage)
    self:RegisterEvent('ChangeChatSpeakMessage',self.ChangeChatSpeakMessage)
    self:RegisterEvent('LaunchToChatMessage',self.LaunchToChatMessage)
end

function ChatCls:RemoveObserver()
	self:UnregisterEvent('ChangeChatMessage',self.ChangeChatMessage)
	self:UnregisterEvent('ChangeChatSpeakMessage',self.ChangeChatSpeakMessage)
	self:UnregisterEvent('LaunchToChatMessage',self.LaunchToChatMessage)
end

local function ShowErrorDialog(self,content)
	local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
	local windowManager = self.myGame:GetWindowManager()
   	windowManager:Show(ErrorDialogClass, content)
end

function ChatCls:ChangeChatMessage(msg)
	if msg.retState == require "Network.PB.S2CTalkResult".success then
		if msg.msgItem == nil then
			return
		end
		
		if self.currPanelState == LoudspeakerState then
			self:StateChangeCtrl(WorldState)
		else
			local datas =self:GetCachedOrRequest(self.currPanelState,true)
			self:ShowMessages(datas)
		end
	else
		local str = ""
		if msg.retState == require "Network.PB.S2CTalkResult".sendTooFast then
			str = "消息发送的速度太快了"
		elseif msg.retState == require "Network.PB.S2CTalkResult".msgTooLong then
			str = "消息太长了"
		end
		ShowErrorDialog(self,str)
	end
end

function ChatCls:ChangeChatSpeakMessage(broadcastID,isSelected,contentStr)
	self.broadcastID = broadcastID
	if isSelected then
		self.normalInputLabel.text = contentStr
	else
		self.normalInputLabel.text = ""
	end
end

function ChatCls:LaunchToChatMessage(personName)
	self:StateChangeCtrl(WhisperingState)
	self.privatePersonLabel.text = personName
end
--------------------------------------------------
function ChatCls:GetUserData()
	local UserDataType = require "Framework.UserDataType"
    return self:GetCachedData(UserDataType.PlayerData)
end

function ChatCls:GetCached()
	local dataCacheMgr = self.myGame:GetDataCacheManager()
	local cached = dataCacheMgr:GetData(UserDataType.ChatMessageData)
	return cached
end

function ChatCls:UpdateMsgData(msg)
	local dataCacheMgr = self.myGame:GetDataCacheManager()
	dataCacheMgr:UpdateData(UserDataType.ChatMessageData, function(oldData)
        require "Data.ChatMessageCache"
        if oldData == nil then
            oldData = ChatMessageCache.New()
        end
        oldData:AddMessage(msg)
        return oldData
    	end)
end

function ChatCls:GetCachedOrRequest(currPanelState,isRecieve)
	local cached = self:GetCached()
	if cached == nil then
		if not isRecieve then
			self:OnTalkQueryRequest()
			return nil
		end
		return nil
	else
		return cached:GetData(currPanelState)
	end
end

local function CompareIsOther(mineUid,otherUid)
	return mineUid ~= otherUid
end

local function CompareSendtime(self,datas,sendTime)
	local lastTime = datas[#datas].sendTime
	return sendTime > lastTime
end

function ChatCls:ShowMessages(datas)
	if datas == nil then
		return
	end
	
	for i = #datas ,1 ,-1 do
		local msgData = datas[i]
		if not self.activeNodeDict:Contains(msgData.sendTime) then
			local node = self:GetNodeFromPool()
			local isOther = CompareIsOther(self.userData:GetUid(),msgData.fromPlayerUID)
			node:OnReset(msgData,isOther,self.friendData)
			self:AddChild(node)
			self.activeNodeDict:Add(msgData.sendTime,node)
		end
	end
end

function ChatCls:GetNodeFromPool()
	local node = self.nodeQueue:Dequeue()
	if node == nil then
		node = require"GUI/ChatContent".New(self.ChatLayoutContent,self.ChatScrollbar)
	end
	if self.activeNodeDict:Count() >= 20 then
		local keys = self.activeNodeDict:GetKeys()
		local key = keys[1]
		local deletedNode = self.activeNodeDict:GetEntryByKey(key)
		self:RemoveChild(deletedNode)
		self.nodeQueue:Enqueue(deletedNode)
		self.activeNodeDict:Remove(key)
	end

	return node
end

function ChatCls:HideAllNodes()
	local keys = self.activeNodeDict:GetKeys()
	if #keys <= 0 then
		return
	end

	for i = 1 ,#keys do
		local key = keys[i]
		local node = self.activeNodeDict:GetEntryByKey(key)
		self:RemoveChild(node)
		self.nodeQueue:Enqueue(node)
		self.activeNodeDict:Remove(key)
	end
end

function ChatCls:ResetHintPanel(freeCount)
	local str = ""
	if freeCount > 0 then
		str = string.format("免费(%s)",freeCount)
	else
		str = "消耗10钻石"
	end
	-- self.FreeTimeLabel.text = str
	self.chatFreeCount = freeCount
end

function ChatCls:InitSpeakerNode()
	local name = self.userData:GetName()
	local gonghuiName = self.userData:GetGonghuiName()
	local staticData = require "StaticData.Speaker"
	local length = staticData:GetKeys().Length
	for i = 1 ,length do
		local speakerData = staticData:GetData(i)
		local speakerType = speakerData:GetType()
		local speakerContent = speakerData:GetContent()
		local speakerPrice = speakerData:GetPrice()
		local content
		local isAdd = true
		if speakerType == 1 then
			content = string.gsub(speakerContent,"${string}",name)
		else
			content = string.gsub(speakerContent,"${string}",gonghuiName)
			if gonghuiName == "" then
				isAdd = false
			end
		end
		if isAdd then
			local node = require"GUI/ChatSpeaker".New(self.ChatSpeakerLayout,self.ChatSpeakerGroup,i,content,speakerPrice )
			self.speakerNodeTable[#self.speakerNodeTable+1] = node
		end
	end
end

function ChatCls:ShowSpeakNodes()
	local length = #self.speakerNodeTable
	for i = 1 ,length do
		local node = self.speakerNodeTable[i]
		self:AddChild(node)
	end
end

function ChatCls:HideSpeakNodes()
	local length = #self.speakerNodeTable
	for i = 1 ,length do
		local node = self.speakerNodeTable[i]
		node:CancelSelected()
		self:RemoveChild(node)
	end
end
--------------------------------------------------
--------------------------------------------------
--- 状态管理
--------------------------------------------------
function ChatCls:StateChangeCtrl(state)
	-- 状态切换
	if self.currPanelState == state then		
		return 
	end

	if self.currPanelState ~= nil then
		self:OnPanelStateExit(self.currPanelState)
	end

	self:OnPanelStateEnter(state)
end

function ChatCls:OnPanelStateEnter(state)
	
	-- 状态进入
	self.currPanelState = state
	if state == WorldState then		
		self:ChangeButtonTheme(self.ChatWorldButton)
		self:OnWorldStateEnter()

	elseif state == WhisperingState then
		self:ChangeButtonTheme(self.ChatWhisperingButton)
		self:OnWhisperingStateEnter()

	elseif state == GuildState then
		self:ChangeButtonTheme(self.ChatGuildButton)
		self:OnGuildStateEnter()

	elseif state == LoudspeakerState then
		self:ChangeButtonTheme(self.ChatLoudspeakerButton)
		self:OnLoudspeakerStateEnter()
	end
end

function ChatCls:OnPanelStateExit(state)
	-- 状态退出

	if state == WorldState then
		self:OnWorldStateExit()
	elseif state == WhisperingState then
		self:OnWhisperingStateExit()
	elseif state == GuildState then
		self:OnGuildStateExit()
	elseif state == LoudspeakerState then
		self:OnLoudspeakerStateExit()
	end

	self.currPanelState = nil
end
-------------------------------------------------
local function ShowMessagesByDatas(self)
	local datas = self:GetCachedOrRequest(self.currPanelState)
	if datas ~= nil then
		self:ShowMessages(datas)
	end
end

function ChatCls:OnWorldStateEnter()
	self.ChatInputFieldObj:SetActive(true)
	-- self.FreeTimeLabel.gameObject:SetActive(true)
	self:HideAllNodes()
	self.chatRaycast.raycastTarget = true
	ShowMessagesByDatas(self)
end

function ChatCls:OnWhisperingStateEnter()
	self.ChatEnterFriendObj:SetActive(true)
	self:HideAllNodes()
	self.chatRaycast.raycastTarget = true
	ShowMessagesByDatas(self)
end

function ChatCls:OnGuildStateEnter()
	self.ChatInputFieldObj:SetActive(true)
	self:HideAllNodes()
	self.chatRaycast.raycastTarget = true
	ShowMessagesByDatas(self)
end

function ChatCls:OnLoudspeakerStateEnter()
	self.ChatInputFieldObj:SetActive(false)
	self.chatLoudspeakerRaycast.raycastTarget = true
	self:ShowSpeakNodes()
end
---------------------------------------------------
function ChatCls:OnWorldStateExit()
	self.normalInputLabel.text = ""
	self.ChatInputFieldObj:SetActive(false)
	-- self.FreeTimeLabel.gameObject:SetActive(false)
	self.chatRaycast.raycastTarget = false
	self:HideAllNodes()
end

function ChatCls:OnWhisperingStateExit()
	self.privateContentLabel.text = ""
	self.privatePersonLabel.text = ""
	self.ChatEnterFriendObj:SetActive(false)
	self.chatRaycast.raycastTarget = false
	self:HideAllNodes()
end

function ChatCls:OnGuildStateExit()
	self.normalInputLabel.text = ""
	self.ChatInputFieldObj:SetActive(false)
	self.chatRaycast.raycastTarget = false
	self:HideAllNodes()
end

function ChatCls:OnLoudspeakerStateExit()
	self.normalInputLabel.text = ""
	self.ChatInputFieldObj:SetActive(false)
	self.chatLoudspeakerRaycast.raycastTarget = false
	self:HideSpeakNodes()
end
-------------------------------------------------
function ChatCls:OnChatWhisperingButtonClicked()
	self:StateChangeCtrl(WhisperingState)
end

function ChatCls:OnChatGuildButtonClicked()
	self:StateChangeCtrl(GuildState)
end

function ChatCls:OnChatLoudspeakerButtonClicked()
	self:StateChangeCtrl(LoudspeakerState)
end

function ChatCls:OnChatWorldButtonClicked()
	self:StateChangeCtrl(WorldState)
end

function ChatCls:OnSendButtonClicked()
	local content
	local toPlayerName
	local gonghuiID = self.userData:GetGonghuiID()

	if self.currPanelState == WhisperingState then
		content = self.privateContentLabel.text
		self.privateContentLabel.text = ""
		toPlayerName = self.privatePersonLabel.text
		if toPlayerName == self.userData:GetName() then
			ShowErrorDialog(self,"不能跟自己发私密消息")
			return
		end
	else
		
		debug_print("ChatCls:OnWorldStateExit(",self.currPanelState)
		content = self.normalInputLabel.text
		self.normalInputLabel.text = ""
		toPlayerName = ""
		if self.currPanelState == LoudspeakerState then
			for i=1,#self.speakerNodeTable do
				self.speakerNodeTable[i]:CancelSelected()
			end
		end
	end

	if content == "" then
		ShowErrorDialog(self,"发送消息不能为空")
	else
		self:OnTalkRequest(content,self.currPanelState,"",toPlayerName,gonghuiID,self.broadcastID)
		if self.currPanelState == WorldState then
			self:OnTalkQueryRequest()
		end	
	end
end

function ChatCls:OnFrientButtonClicked()
	-- local isOpen = utility.IsCanOpenModule(KSystemBasis_MailID)
    -- if not isOpen then
    --     return
    -- end
    self:Close()
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Friend.Friends")
end

function ChatCls:OnCloseButtonClicked()
	self:Close()
end
---------------------------------------------------
-------------------BUTTON 样式---------------------
-- button 选中颜色
local ButtonSelectedImageColor = UnityEngine.Color(1,1,1,1)
local ButtonNormalImageColor = UnityEngine.Color(0.537254,0.537254,0.537254,1)
------------------------------------------------------------------------
---  改变button 样式
------------------------------------------------------------------------
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
		label.fontSize = 42
		label.color = UnityEngine.Color(1,1,1,1)
		outLine.enabled = true
	else
		label.fontSize = 35
		label.color = UnityEngine.Color(0,0,0,1)
		outLine.enabled = false
	end
end 

function ChatCls:ChangeButtonTheme(targetButton)
	if targetButton == self.currClickBtn then
		return
	end

	-- 更改button按钮选中主题
	local gameTool = require "Utils.GameTools"
	
	local buttonImage = targetButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	buttonImage.color = ButtonSelectedImageColor
	ChangePosition(targetButton,-15)
	local textLabel = targetButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	SetLabelTheme(textLabel,true)

	if self.currClickBtn ~= nil then
		local onSelectButtonImage = self.currClickBtn.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
		onSelectButtonImage.color = ButtonNormalImageColor
		ChangePosition(self.currClickBtn,15)
		local textLabel = self.currClickBtn.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		SetLabelTheme(textLabel,false)
	end

	self.currClickBtn = targetButton
end



return ChatCls