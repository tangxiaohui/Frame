local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ChatContentCls = Class(BaseNodeClass)

function ChatContentCls:Ctor(parent,msg)
	self.parent = parent
	self.msg = msg
end


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


	self:ScheduleUpdate(self.Update)

end

function ChatContentCls:OnPause()
	-- 界面隐藏时调用
	ChatContentCls.base.OnPause(self)
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

function ChatContentCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Frame = transform:Find('Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HeadFrame = transform:Find('Head/HeadFrame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatContentHeadIcon = transform:Find('Head/ChatContentHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChatContentTimeLabel = transform:Find('ChatContentTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentChannelLabel = transform:Find('ChatContentChannelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentNameLabel = transform:Find('ChatContentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChatContentDiscourseLabel = transform:Find('ChatContentDiscourseLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.Element = transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))
	--[[
	self.context.msg 
	self.context.fromPlayerUID 
	self.context.fromPlayerName
 	self.context.sendTime
  	self.context.headID
  	self.context.playerLevel
	]]
	self.context = {}

	print("修改前")
	self.ChatContentDiscourseLabel.text = self.msg 
	print(self.ChatContentDiscourseLabel.text)
	print(self.ChatContentDiscourseLabel.preferredHeight)

	self.ChatContentDiscourseLabel.text = "1"
	print("修改后")
	print(self.ChatContentDiscourseLabel.text)
	print(self.ChatContentDiscourseLabel.preferredHeight)
end

return ChatContentCls