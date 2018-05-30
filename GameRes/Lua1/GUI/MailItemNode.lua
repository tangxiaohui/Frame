local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local MailItemNode = Class(BaseNodeClass)

function MailItemNode:Ctor(data,toggleGroup,parent)
	self.callback = LuaDelegate.New()
	self.lastToggleState = false
	self.mailData = data
	self.toggleGroup = toggleGroup
	

	self.parent = parent
end

function MailItemNode:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MailListContent', function(go)
		self:BindComponent(go,false)
		end)
end

function MailItemNode:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
	
end

function MailItemNode:SetSelected(isSelect)
	self.MailContentToggle.isOn = isSelect
end

function MailItemNode:SetCallBack(table,func)
	self.callback:Add(table,func)
end


function MailItemNode:OnResume()
	-- 界面显示时调用
	MailItemNode.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function MailItemNode:OnPause()
	-- 界面隐藏时调用
	MailItemNode.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function MailItemNode:InitControls()
	local transform = self:GetUnityTransform()
	self.MailContentToggle = transform:Find('MailContentToggle'):GetComponent(typeof(UnityEngine.UI.Toggle)):GetComponent(typeof(UnityEngine.UI.Toggle))
	
	--邮件已读标识图
	self.MailListContentIconRead = transform:Find('MailContentToggle/MailListContentIconRead'):GetComponent(typeof(UnityEngine.UI.Image))
	--未读
	self.MailListContentIconUnRead = transform:Find('MailContentToggle/MailListContentIconUnRead'):GetComponent(typeof(UnityEngine.UI.Image))
	--邮件标题label
	self.MailListContentTitleLabel = transform:Find('MailContentToggle/MailListContentTitleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--邮件发件人
	self.MailListContentSenderLabel = transform:Find('MailContentToggle/MailListContentSenderLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--邮件时间label
	self.MailListContentTimeLabel = transform:Find('MailContentToggle/MailListContentTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self:DrawMailItem()
	

	self.MailContentToggle.group = self.toggleGroup
end

function MailItemNode:DrawMailItem()
	self.MailListContentTitleLabel.text = self.mailData.title

    S2CMailResultClass = require "Network.PB.S2CMailResult"


    if self.mailData.senderType == S2CMailResultClass.systemSender then
    self.MailListContentSenderLabel.text = '发件人:系統'
    elseif self.mailData.senderType == S2CMailResultClass.arenaSender then
    self.MailListContentSenderLabel.text = '发件人:竞技场'
    elseif self.mailData.senderType == S2CMailResultClass.navHuhangSender then
    self.MailListContentSenderLabel.text = '发件人:大航海'
    elseif self.mailData.senderType == S2CMailResultClass.ghfbSender then
    self.MailListContentSenderLabel.text = '发件人:工会'
    elseif self.mailData.senderType == S2CMailResultClass.vipLevelupSender then
    self.MailListContentSenderLabel.text = '发件人:VIP'
    elseif self.mailData.senderType == S2CMailResultClass.rechargeBackSender then
    self.MailListContentSenderLabel.text = '发件人:双倍返还'
    end
    
    local timeTable = utility.GetLocalTimeTableFromTimeStamp(self.mailData.timeStamp/1000)
	local time = string.format("%s-%s-%s %s:%s",timeTable.year,timeTable.month,timeTable.day,timeTable.hour,timeTable.min)
	self.MailListContentTimeLabel.text = time
	self.MailListContentIconRead.gameObject:SetActive(tonumber(self.mailData.readTime) > 0)
	self.MailListContentIconUnRead.gameObject:SetActive(tonumber(self.mailData.readTime) ==0)

	self.deleteType = self.mailData.deleteType
end


function MailItemNode:RegisterControlEvents()
	-- 注册 MailContentToggle 的事件
	self.__event_toggle_onMailContentToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnMailContentToggleValueChanged, self)
	self.MailContentToggle.onValueChanged:AddListener(self.__event_toggle_onMailContentToggleValueChanged__)
end

function MailItemNode:UnregisterControlEvents()
	-- 取消注册 MailContentToggle 的事件
	if self.__event_toggle_onMailContentToggleValueChanged__ then
		self.MailContentToggle.onValueChanged:RemoveListener(self.__event_toggle_onMailContentToggleValueChanged__)
		self.__event_toggle_onMailContentToggleValueChanged__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function MailItemNode:OnMailContentToggleValueChanged(isToggle)
	--MailContentToggle控件的点击事件处理

	self.MailListContentIconRead.gameObject:SetActive(true)
	self.MailListContentIconUnRead.gameObject:SetActive(false)
	self.callback:Invoke(self.mailData,self.MailListContentIconRead,self)
	-- if self.lastToggleState ~= isToggle then
	-- 	self.lastToggleState = isToggle
	-- 	if isToggle then
			
	-- 	end
	-- end
end

function MailItemNode:GetDeletedType()
	return deleteType
end

return MailItemNode