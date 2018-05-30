local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ChatSpeakerCls = Class(BaseNodeClass)

function ChatSpeakerCls:Ctor(parent,group,number,contentStr,price)
	self.parent = parent
	self.group = group
	self.number = number
	self.contentStr = contentStr
	self.price = price
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ChatSpeakerCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ChatSpeaker', function(go)
		self:BindComponent(go,false)
	end)
end

function ChatSpeakerCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

local function CoroutineReset(self)
	repeat
	coroutine.step(1)
	until(self:IsReady())

	self.ChatSpeakerContentLabel.text = self.contentStr
	self.ChatSpeakerDiamondNumLabel.text = tostring(self.price)
end 

function ChatSpeakerCls:OnResume()
	-- 界面显示时调用
	ChatSpeakerCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
	-- coroutine.start(CoroutineReset,self)
	self:StartCoroutine(CoroutineReset)
end

function ChatSpeakerCls:OnPause()
	-- 界面隐藏时调用
	ChatSpeakerCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function ChatSpeakerCls:OnEnter()
	-- Node Enter时调用
	ChatSpeakerCls.base.OnEnter(self)
end

function ChatSpeakerCls:OnExit()
	-- Node Exit时调用
	ChatSpeakerCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ChatSpeakerCls:InitControls()
	local transform = self:GetUnityTransform()
	self.ChatSpeakerBase = transform:Find('ChatSpeakerBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CheckBase = transform:Find('Check/CheckBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatSpeakerCheckImage = transform:Find('Check/ChatSpeakerCheckImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DiamondImage = transform:Find('DiamondImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatSpeakerDiamondNumLabel = transform:Find('ChatSpeakerDiamondNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatSpeakerContentLabel = transform:Find('ChatSpeakerContentLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.ToggleCompoment = transform:GetComponent(typeof(UnityEngine.UI.Toggle))
	self.ToggleCompoment.group = self.group

	self.myGame = utility:GetGame()
end


function ChatSpeakerCls:RegisterControlEvents()
	 self.__event_ToggleCompoment_onChapterToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggleValueChanged, self)
    self.ToggleCompoment.onValueChanged:AddListener(self.__event_ToggleCompoment_onChapterToggleValueChanged__)
end

function ChatSpeakerCls:UnregisterControlEvents()
	if self.__event_ToggleCompoment_onChapterToggleValueChanged__ then
        self.ToggleCompoment.onValueChanged:RemoveListener(self.__event_ToggleCompoment_onChapterToggleValueChanged__)
        self.__event_ToggleCompoment_onChapterToggleValueChanged__ = nil
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ChatSpeakerCls:OnToggleValueChanged()
	local eventMgr = self.myGame:GetEventManager()
  	eventMgr:PostNotification('ChangeChatSpeakMessage', nil, self.number,self.ToggleCompoment.isOn,self.contentStr)
end

function ChatSpeakerCls:CancelSelected()
	self.ToggleCompoment.isOn = false
end


return ChatSpeakerCls