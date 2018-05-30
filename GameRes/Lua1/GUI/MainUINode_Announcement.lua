local UINodeClass = require "Framework.Base.UINode"

local Announcement = Class(UINodeClass)

function Announcement:Ctor(gameobject)
	self:BindComponent(gameobject, false)
	self:InitControls(gameobject)
end

function Announcement:InitControls(gameobject)
	local transform = self:GetUnityTransform()
	self.isRunning = false
	--self.msgCount = 3
	self.msgQueue = {}
	self.announcement = gameobject;
	self.mainAnnouncementLabelTrans = transform:Find("AnnouncementBase/TheMainAnnouncementLabel")
	self.mainAnnouncementLabelText =  self.mainAnnouncementLabelTrans:GetComponent(typeof(UnityEngine.UI.Text))
	self.announcementInitPos = self.mainAnnouncementLabelTrans.localPosition
	self.resetPosition = self.announcementInitPos

	self:ScheduleUpdate(self.Update)

end

function Announcement:Update()
	self:MoveAnnouncementCtrl()
end

function Announcement:PlayNotice(msg,repeatedNum,isInsertBefore)
	-- ---------------- 
	-- *外部调用*
	-- ----------------
	if msg == nil or type(msg) ~= "string" then
		error("argument 'msg' is nil or invalid")
		return
	end
	if repeatedNum == nil or type(repeatedNum) ~= "number" then
		error("argument 'repeatedNum' is nil or invalid")
	end
	if isInsertBefore == nil or type(isInsertBefore) ~= "number" then
		error("argument 'isInsertBefore' is nil or invalid")
	end

	self:InsertToMsgQueue(msg,repeatedNum,isInsertBefore)
	
	self:OnAnnouncementShow()
	print(self.isRunning)
	if not (self.isRunning) then
		if #self.msgQueue > 0 then	
			self:OnMsgResume()
		end
	end
	
end

function Announcement:InsertToMsgQueue(msg,repeatedNum,isInsertBefore)
	for i=1,repeatedNum do
		if isInsertBefore == 1 then
			self:DoInsertWithPriority(msg)
		else
			table.insert(self.msgQueue,msg)	
		end
	end
end

function Announcement:DoInsertWithPriority(msg)
		if self.isRunning then
			table.insert(self.msgQueue,2,msg)			
		else
			table.insert(self.msgQueue,1,msg)	
		end	
end

function Announcement:DeleteFromMsgQueue()
	table.remove(self.msgQueue,1)
end

function Announcement:OnAnnouncementShow()
	self.announcement:SetActive(true)
end

function Announcement:OnAnnouncementHide()
	self.announcement:SetActive(false)
end

function Announcement:OnMsgResume()
	self.isRunning = true
	self.mainAnnouncementLabelText.text = self.msgQueue[1]
	local  temp = Vector3.zero
	temp.x = (self.announcementInitPos.x + self.mainAnnouncementLabelText.preferredWidth)/2
	self.resetPosition = temp
	self.mainAnnouncementLabelTrans.localPosition = self.resetPosition
end

function Announcement:OnMsgPause()

end

function Announcement:MoveAnnouncementCtrl()
    -- 控制公告条移动
    if	#self.msgQueue > 0 then
    	if self.mainAnnouncementLabelTrans.localPosition.x >= (-self.resetPosition.x ) then
        	self.mainAnnouncementLabelTrans:Translate(Vector3.left)
    	else
    		self.isRunning = false    	
    		self:DeleteFromMsgQueue()
    		self:OnMsgResume()      		
    	end
    else
    	self:OnAnnouncementHide()
    end
end

return Announcement