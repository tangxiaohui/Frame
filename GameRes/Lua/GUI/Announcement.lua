local windowNodeCls = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local UserDataType = require "Framework.UserDataType"
local messageGuids = require "Framework.Business.MessageGuids"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local Announcement = Class(windowNodeCls)
windowUtility.SetMutex(Announcement, true)


local moveSpeed = 12

function Announcement:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function Announcement:OnInit()
	utility.LoadNewGameObjectAsync('UI/Prefabs/Announcement', function(go)
		self:BindComponent(go)
	end)
end

function Announcement:OnComponentReady()
	self:InitControls()

end

function Announcement:OnEnter()
	Announcement.base.OnEnter(self)
end

function Announcement:OnExit()
	Announcement.base.OnExit(self)
	self:RemoveObserver()
end

function Announcement:GetRootHangingPoint()
	return self:GetUIManager():GetForegroundLayer()	
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
function Announcement:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
    self:AddObserver()

	self.isRolling = false
	self.isLabaMsg = true
	self.msgQueue = {}

	self.controls = {}
	self.controls.AnnouncementImageTransform = transform:Find("AnnouncementBase"):GetComponent(typeof(UnityEngine.UI.Image))
	self.controls.AnnouncementLabelTransform = transform:Find("AnnouncementBase/TheMainAnnouncementLabel")
	self.controls.AnnouncementLabelText =  self.controls.AnnouncementLabelTransform:GetComponent(typeof(UnityEngine.UI.Text))
	self.announcementInitPosition = self.controls.AnnouncementLabelTransform.localPosition
	self.resetPosition = self.announcementInitPosition
	self.BattleSeceneParse = require "Game.GamePhase".Battle
	self:ScheduleUpdate(self.Update)

	self.gameObject = transform.gameObject

end

function Announcement:Update()
	if self.game:GetCurrentPhase() == self.BattleSeceneParse then
		self:OnAnnouncementHide()
		return
	else
		self:OnAnnouncementShow()
	end
	self:MoveAnnouncementCtrl()
end

local function OnEnterLobby(self)
	self:ShowPlayNotice()
end

local function ExitLobbyScene(self)
	self:ClosePlayNotice()
end

function Announcement:AddObserver()
    self:RegisterEvent('PlayNoticeRoll',self.PlayNoticeRoll)
    self:RegisterEvent('ClosePlayNotice',self.ClosePlayNotice)
    self:RegisterEvent('ShowPlayNotice',self.ShowPlayNotice)
    self:RegisterEvent(messageGuids.EnterLobbyScene, OnEnterLobby)
    self:RegisterEvent(messageGuids.ExitLobbyScene, ExitLobbyScene)
end

function Announcement:RemoveObserver()
	self:UnregisterEvent('PlayNoticeRoll',self.PlayNoticeRoll)
	self:UnregisterEvent('ClosePlayNotice',self.ClosePlayNotice)
	self:RegisterEvent('ShowPlayNotice',self.ShowPlayNotice)
	self:UnregisterEvent(messageGuids.EnterLobbyScene, OnEnterLobby)
	self:UnregisterEvent(messageGuids.ExitLobbyScene, ExitLobbyScene)
end

function Announcement:OnEnterLobby()
	self:ShowPlayNotice()
end

function Announcement:ExitLobbyScene()
	self:ClosePlayNotice()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function Announcement:ClosePlayNotice()
	self.gameObject:SetActive(false)
end
function Announcement:ShowPlayNotice()
	self.gameObject:SetActive(true)
end

-- # 播放滚动条
function Announcement:PlayNoticeRoll(msg)
	for i = 1, #msg.msgItem do
        self:PlayNotice(msg.msgItem[i].msg,msg.msgItem[i].repeatedNum,msg.msgItem[i].isInsertBefore)
     end
end

-- # 开始播放
function Announcement:PlayNotice(msg,repeatedNum,isInsertBefore)
	
	utility.ASSERT(not (msg == nil or type(msg) ~= "string") ,"argument 'msg' is nil or invalid")
	utility.ASSERT(not (repeatedNum == nil or type(repeatedNum) ~= "number" ),"argument 'repeatedNum' is nil or invalid")
	utility.ASSERT(not (isInsertBefore == nil or type(isInsertBefore) ~= "number" ),"argument 'isInsertBefore' is nil or invalid")

	self:InsertToMsgQueue(msg,repeatedNum,isInsertBefore)
	self:OnAnnouncementShow()
	if not (self.isRolling) then
		if #self.msgQueue > 0 then	
			self:OnMsgResume()
		end
	end
	
end

-- # 向消息队列中插入消息
function Announcement:InsertToMsgQueue(msg,repeatedNum,isInsertBefore)
	if repeatedNum == 0 then
		-- if self.isLabaMsg then
		-- 	self.isLabaMsg = false
		-- else 
		-- 	table.insert(self.msgQueue,msg)
		-- 	self.isLabaMsg = true
		-- end
		table.insert(self.msgQueue,msg)
	end
	for i=1,repeatedNum do
		if isInsertBefore == 1 then
			self:DoInsertWithPriority(msg)
		else
			table.insert(self.msgQueue,msg)	
		end
	end
end

-- # 优先向消息队列中插入消息
function Announcement:DoInsertWithPriority(msg)
		if self.isRolling then
			table.insert(self.msgQueue,2,msg)			
		else
			table.insert(self.msgQueue,1,msg)	
		end	
end

-- # 从消息队列中删除信息
function Announcement:DeleteFromMsgQueue()
	table.remove(self.msgQueue,1)
end

-- # 控制公告条移动
function Announcement:MoveAnnouncementCtrl()
    if	#self.msgQueue > 0 then
    	if self.controls.AnnouncementLabelTransform.gameObject.activeSelf == false then
    		self:OnAnnouncementShow()
    	end
    	if self.controls.AnnouncementLabelTransform.localPosition.x >= (-self.resetPosition.x ) then
        	self.controls.AnnouncementLabelTransform:Translate(Vector3.left * Time.deltaTime * moveSpeed)
    	else
    		self:DeleteFromMsgQueue()
    		self:OnMsgResume()
    		self.isRolling = false    	
    	end
    else
    	self:OnHideContentLabel()      		
    end
end

-- # 显示进度条
function Announcement:OnAnnouncementShow()
    self.controls.AnnouncementImageTransform.gameObject:SetActive(true)
    self.controls.AnnouncementLabelTransform.gameObject:SetActive(true)
end

function Announcement:OnAnnouncementHide()
	self.controls.AnnouncementImageTransform.gameObject:SetActive(false)
    self.controls.AnnouncementLabelTransform.gameObject:SetActive(false)
end

function Announcement:OnHideContentLabel()
    self.controls.AnnouncementLabelTransform.gameObject:SetActive(false)
end

-- # 重置消息播放
function Announcement:OnMsgResume()
	self.isRolling = true
	self.controls.AnnouncementLabelText.text = self.msgQueue[1]
	local  temp = Vector3.zero
	temp.x = (self.announcementInitPosition.x + self.controls.AnnouncementLabelText.preferredWidth)/2
	self.resetPosition = temp
	self.controls.AnnouncementLabelTransform.localPosition = self.resetPosition
end
return Announcement