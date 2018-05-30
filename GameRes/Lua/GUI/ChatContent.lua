local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ChatContentCls = Class(BaseNodeClass)

function ChatContentCls:Ctor(parent,scrollBar)
	self.parent = parent
	--self.msg = msg
	self.ChatScrollbar = scrollBar
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ChatContentCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ChatContent', function(go)
		self:BindComponent(go, false)
	end)
end

function ChatContentCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()

end

function ChatContentCls:OnResume()
	-- 界面显示时调用
	ChatContentCls.base.OnResume(self)
	--self.gameObject:SetActive(false)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)
	
	--self:InitMessage(self.msg)
	--self:InitContentFormat()
	--self.gameObject:SetActive(false)
end

function ChatContentCls:OnPause()
	-- 界面隐藏时调用
	ChatContentCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnRegisterNetworkEvents()
end

function ChatContentCls:OnEnter()
	-- Node Enter时调用
	ChatContentCls.base.OnEnter(self)
end

function ChatContentCls:OnExit()
	-- Node Exit时调用
	ChatContentCls.base.OnExit(self)
end

function ChatContentCls:Update()
	
end

local function CoroutineOnReset(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.gameObject:SetActive(true)
	if self.isOther then
		self.otherContent:SetActive(true)
		self.myContent:SetActive(false)

		self.Frame = self.FrameOther  
		self.HeadFrame = self.HeadFrameOther
		self.ChatContentHeadIcon = self.ChatContentHeadIconOther
		self.ChatContentTimeLabel = self.ChatContentTimeLabelOther
		self.ChatContentChannelLabel = self.ChatContentChannelLabelOther
		self.ChatContentNameLabel =self.ChatContentNameLabelOther
		self.ChatContentNameButton = self.ChatContentNameButtonOther
		self.ChatContentDiscourseLabel = self.ChatContentDiscourseLabelOther
		
	else
		self.otherContent:SetActive(false)
		self.myContent:SetActive(true)

		self.Frame = self.FrameMe 
		self.HeadFrame = self.HeadFrameMe 
		self.ChatContentHeadIcon = self.ChatContentHeadIconMe 
		self.ChatContentTimeLabel = self.ChatContentTimeLabelMe
		self.ChatContentChannelLabel = self.ChatContentChannelLabelMe
		self.ChatContentNameLabel =self.ChatContentNameLabelMe
		self.ChatContentNameButton = self.ChatContentNameButtonMe
		self.ChatContentDiscourseLabel = self.ChatContentDiscourseLabelMe
		
	end
	
	self:InitContentFormat()
end


function ChatContentCls:OnReset(msg,isOther,friendData)
	self.msg = msg
	self.isOther = isOther
	self.friendData = friendData
	-- coroutine.start(CoroutineOnReset,self)
	self:StartCoroutine(CoroutineOnReset)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ChatContentCls:InitControls()
	local transform = self:GetUnityTransform()
	self.gameObject = self:GetUnityGameObject()
	self.myGame = utility:GetGame()

	self.myContent = transform:Find('ChatContentMe').gameObject
	self.otherContent = transform:Find('ChatContentOther').gameObject

	self.FrameMe = transform:Find('ChatContentMe/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HeadFrameMe = transform:Find('ChatContentMe/Head/Mask/HeadFrame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatContentHeadIconMe = transform:Find('ChatContentMe/Head/ChatContentHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatContentTimeLabelMe = transform:Find('ChatContentMe/ChatContentTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentChannelLabelMe = transform:Find('ChatContentMe/ChatContentChannelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentNameLabelMe = transform:Find('ChatContentMe/ChatContentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentNameButtonMe = transform:Find('ChatContentMe/ChatContentNameLabel'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChatContentDiscourseLabelMe = transform:Find('ChatContentMe/ChatContentDiscourseLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.chatIconButtonMe = self.HeadFrameMe:GetComponent(typeof(UnityEngine.UI.Button))

	self.FrameOther = transform:Find('ChatContentOther/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HeadFrameOther = transform:Find('ChatContentOther/Head/Mask/HeadFrame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatContentHeadIconOther = transform:Find('ChatContentOther/Head/ChatContentHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatContentTimeLabelOther = transform:Find('ChatContentOther/ChatContentTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentChannelLabelOther = transform:Find('ChatContentOther/ChatContentChannelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentNameLabelOther = transform:Find('ChatContentOther/ChatContentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentNameButtonOther =  transform:Find('ChatContentOther/Head/ChatContentHeadIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChatContentDiscourseLabelOther = transform:Find('ChatContentOther/ChatContentDiscourseLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Element = transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))
	self.chatIconButtonOther = self.HeadFrameOther:GetComponent(typeof(UnityEngine.UI.Button))

	self:InitPosition()
	self.context = {}
	--self.context.customHeight = 52
	self.context.customHeight = math.abs(self.ChatContentDiscourseLabelOther.transform.localPosition.y)
end

function ChatContentCls:RegisterControlEvents()
	self.__event_button_onChatContentNameButtonClicked__ = UnityEngine.Events.UnityAction( function() self:OnChatContentNameButtonClicked() end)
	-- self.ChatContentNameButtonMe.onClick:AddListener(self.__event_button_onChatContentNameButtonClicked__)
	self.ChatContentNameButtonOther.onClick:AddListener(self.__event_button_onChatContentNameButtonClicked__)
	self.chatIconButtonMe.onClick:AddListener(self.__event_button_onChatContentNameButtonClicked__)
	self.chatIconButtonOther.onClick:AddListener(self.__event_button_onChatContentNameButtonClicked__)
end

function ChatContentCls:UnregisterControlEvents()
	if self.__event_button_onChatContentNameButtonClicked__ then
		-- self.ChatContentNameButtonMe.onClick:RemoveListener(self.__event_button_onChatContentNameButtonClicked__)
		self.ChatContentNameButtonOther.onClick:RemoveListener(self.__event_button_onChatContentNameButtonClicked__)
		self.chatIconButtonMe.onClick:RemoveListener(self.__event_button_onChatContentNameButtonClicked__)
		self.chatIconButtonOther.onClick:RemoveListener(self.__event_button_onChatContentNameButtonClicked__)
		self.__event_button_onChatContentNameButtonClicked__ = nil
	end
end

function ChatContentCls:RegisterNetworkEvents()

end

function ChatContentCls:UnRegisterNetworkEvents()
	
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

function ChatContentCls:OnChatContentNameButtonClicked()
	local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)
    playerUid = playerData:GetUid()
	if playerUid ~= self.msg.fromPlayerUID then
		local windowManager = self.myGame:GetWindowManager()
		windowManager:Show(require "GUI.ChatPlayer",self.msg.fromPlayerUID,self.friendData)
	 end
end
------------------------------------------------------------------------
local function CoroutineResetScrollBarValue(self)
	coroutine.wait(Time.deltaTime)
	self.ChatScrollbar.value = 0
end

local function CoroutineInitContent(self)
	-- 下一帧去执行 否者preferredHeight 值不重置 为错误值
	coroutine.wait(Time.deltaTime)
	
	local textRect = self.ChatContentDiscourseLabel.rectTransform.sizeDelta

	textRect.y = self.ChatContentDiscourseLabel.preferredHeight
	self.ChatContentDiscourseLabel.rectTransform.sizeDelta = textRect


	local sizeDelta = self.Frame.rectTransform.sizeDelta
	sizeDelta.y = textRect.y + 23
	self.Frame.rectTransform.sizeDelta = sizeDelta

	self:GetUnityTransform():GetComponent(typeof(UnityEngine.UI.LayoutElement)).preferredHeight = 
		self.context.customHeight + self.ChatContentDiscourseLabel.preferredHeight


	self:GetUnityTransform():SetAsLastSibling()
	-- coroutine.start(CoroutineResetScrollBarValue,self)
	self:StartCoroutine(CoroutineResetScrollBarValue)
end

function ChatContentCls:InitContentFormat()
	
	self:InitMessage()
	-- coroutine.start(CoroutineInitContent,self) 
	self:StartCoroutine(CoroutineInitContent)
end

local function OnLoadHeadIcon(self,headImage,id)
	--local  dataInfo,data,name,iconPath,itemTypeStr = require "Utils.GameTools":GetItemDataById(id)

	local tempIconName = require"StaticData/PlayerHead":GetData(id):GetIcon()
	local iconPath = "UI/Atlases/CardHead/"..tostring(tempIconName)
	utility.LoadSpriteFromPath(iconPath,headImage)
end

function ChatContentCls:InitMessage()
	self.ChatContentDiscourseLabel.text = self.msg.msg
	self.ChatContentTimeLabel.text = utility.GetLocalTimeFromTimeStamp("%X",self.msg.sendTime)
	self.ChatContentNameLabel.text = self.msg.fromPlayerName

	if self.msg.type == 1 then 
		self.ChatContentChannelLabel.text = "世界"
	elseif self.msg.type == 2 then
		self.ChatContentChannelLabel.text = "工会"
	elseif self.msg.type == 3 then
		self.ChatContentChannelLabel.text = "密语"
	end

	utility.LoadPlayerHeadIcon(self.msg.headID,self.HeadFrame)
end

function ChatContentCls:InitPosition()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    self.ChatContentNameLabelMe.text = userData:GetName()
end

function ChatContentCls:SetActive(isShow)
	--self.gameObject:SetActive(isShow)
end


return ChatContentCls