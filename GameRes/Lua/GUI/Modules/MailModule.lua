local WindowNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local UserDataType = require "Framework.UserDataType"
local GameTools = require"Utils.GameTools"
require "Collection.OrderedDictionary"


local MailModule = Class(WindowNodeClass)
-- # 设置为唯一
windowUtility.SetMutex(MailModule, true)

require "GUI.Spine.SpineController"
function MailModule:Ctor()
	local ctrl = SpineController.New()
	self.ctrl = ctrl
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function MailModule:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Mail', function(go)
		self:BindComponent(go)
	end)
end

-- 指定为Module层!
function MailModule:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function MailModule:OnWillShow(text)
	--print(text)
end

function MailModule:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function MailModule:OnResume()
	-- 界面显示时调用
	MailModule.base.OnResume(self)

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_MailView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	---淡入效果
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	
	self:InitSpineShow()

	self:OnMailRequest()
end

function MailModule:OnPause()
	-- 界面隐藏时调用
	MailModule.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:CloseSpine()
end

function MailModule:OnEnter()
	-- Node Enter时调用
	MailModule.base.OnEnter(self)
end

function MailModule:OnExit()
	-- Node Exit时调用
	MailModule.base.OnExit(self)
end

function MailModule:IsTransition()
    return true
end

function MailModule:OnExitTransitionDidStart(immediately)
	MailModule.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function MailModule:InitSpineShow()
	self.ctrl:SetData(self.skeletonGraphic,self.spineLabel,3)
end

function MailModule:CloseSpine()
	self.ctrl:Stop()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function MailModule:InitControls()
    self.myGame = utility.GetGame()	
	self.dataCacheMgr = self.myGame:GetDataCacheManager()
	
	self.curSelectMailData = nil
	
	local transform = self:GetUnityTransform()
	self.delMail = {}
	---关闭按钮
	self.MailRetrunButton = transform:Find('TweenObj/MailRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
    --内容区域的root
	self.ContentAreaRoot = transform:Find('TweenObj/ContentArea')
	
	--没有邮件时候的提示
	self.NoMailTip =  transform:Find('TweenObj/NoMailTip'):GetComponent(typeof(UnityEngine.UI.Text))
	---内容区域小箭头
	self.ContentArrow = transform:Find('TweenObj/ContentArea/ContentArrow'):GetComponent(typeof(UnityEngine.UI.Image))
    ---内容区域底部线
	self.Linebelow = transform:Find('TweenObj/ContentArea/Linebelow'):GetComponent(typeof(UnityEngine.UI.Image))

	--邮件标题
	self.MailContentTitleLabel = transform:Find('TweenObj/ContentArea/Title/MailContentTitleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--邮件发件人
	self.MailContentSenderLabel = transform:Find('TweenObj/ContentArea/Sender/MailContentSenderLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--邮件内容带附件
	self.ContentTextLabel = transform:Find('TweenObj/ContentArea/ContentScrollView/ContentViewport/AreaContent/ContentTextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
    self.ContentTextElement = self.ContentTextLabel.transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))
    self.MailContentItemRoot = transform:Find('TweenObj/ContentArea/AnnexLayout')
    --背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

    --邮件奖励ICON
    self.MailAnnexContentIcons = {
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent01/MailAnnexContentIcon01'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent02/MailAnnexContentIcon02'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent03/MailAnnexContentIcon03'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent04/MailAnnexContentIcon04'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent05/MailAnnexContentIcon05'):GetComponent(typeof(UnityEngine.UI.Image)),
    }
    
    
    self.MailItemCountLabels = {
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent01/ItemNumLabel01'):GetComponent(typeof(UnityEngine.UI.Text)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent02/ItemNumLabel02'):GetComponent(typeof(UnityEngine.UI.Text)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent03/ItemNumLabel03'):GetComponent(typeof(UnityEngine.UI.Text)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent04/ItemNumLabel04'):GetComponent(typeof(UnityEngine.UI.Text)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent05/ItemNumLabel05'):GetComponent(typeof(UnityEngine.UI.Text)),
    }

    self.ColorList = {
    	transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent01/ColorFrame'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent02/ColorFrame'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent03/ColorFrame'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent04/ColorFrame'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ContentArea/AnnexLayout/MailAnnexContent05/ColorFrame'):GetComponent(typeof(UnityEngine.UI.Image)),
	}

	self.HslMaterial = self.ColorList[1].material

	--奖励领取按钮
	self.ReceiveButton = transform:Find('TweenObj/ContentArea/ReceiveButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--删除邮件按钮
	self.AutoReceiveButton = transform:Find('TweenObj/ContentArea/AutoReceiveButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.Viewport = transform:Find('TweenObj/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.ArrowList = transform:Find('TweenObj/ArrowList'):GetComponent(typeof(UnityEngine.UI.Image))
	
    -- 获取 ToggleGroup 组件
    self.MailToggle = transform:Find('TweenObj/MailToggleGroup')
    self.MailToggleGroup = self.MailToggle:GetComponent(typeof(UnityEngine.UI.ToggleGroup))

	-- 获取 item挂点transform
	self.MailListLayout = transform:Find('TweenObj/Viewport/MailList/MailListLayout')
	
	--邮件滚动条
	self.MailScrollRect = transform:Find('TweenObj/Viewport/MailList'):GetComponent(typeof(UnityEngine.UI.ScrollRect))

	--邮件内容滚动条
	self.MailContentScrollRect = transform:Find('TweenObj/ContentArea/ContentScrollView'):GetComponent(typeof(UnityEngine.UI.ScrollRect))	
	
	self.tweenObjectTrans = transform:Find('TweenObj')

    --不带附件的邮件内容和scrollview
    self.ContentTextLabelText = transform:Find('TweenObj/ContentArea/ContentScrollViewText/ContentViewportText/AreaContentText/ContentTextLabelText'):GetComponent(typeof(UnityEngine.UI.Text))
    self.ContentTextLabelElement = self.ContentTextLabelText.transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))

    --邮件内容滚动条
	self.MailContentScrollRectText = transform:Find('TweenObj/ContentArea/ContentScrollViewText'):GetComponent(typeof(UnityEngine.UI.ScrollRect))	

	self.spineLabel = transform:Find("TweenObj/Frame/Text"):GetComponent(typeof(UnityEngine.UI.Text))	
	self.skeletonGraphic = transform:Find('TweenObj/dianhuachong/SkeletonGraphic (dianhuachong)'):GetComponent(typeof(Spine.Unity.SkeletonGraphic))
end

local function IsAllMailComponentsReady(self)
	local keys = self.mailToggleItemDict:GetKeys()
    for i = 1, #keys do
    	local node = self.mailToggleItemDict:GetEntryByKey(keys[i])
        if not node:HasUnityGameObject() then
            return false
        end
    end
    return true
end

local function WaitForFinished(self)
    while(not IsAllMailComponentsReady(self))
    do
        coroutine.step(1)
    end

    local keys = self.mailToggleItemDict:GetKeys()
    if #keys > 0 then
    	local node = self.mailToggleItemDict:GetEntryByKey(keys[1])
        local firstItem = node
        firstItem:SetSelected(true)
    end

    coroutine.step(1)


    self.MailScrollRect.verticalNormalizedPosition = 1
 
    

    print('**** Mail Component Finished! ****')
end

local function MailComps(a,b)
	---邮件排序
	if (tonumber(a.readTime) > 0 and tonumber(b.readTime) >0) 
	or  (tonumber(a.readTime) == 0 and tonumber(b.readTime) ==0) then
	    return tonumber(a.timeStamp) > tonumber(b.timeStamp) 
	else
		return tonumber(a.readTime) == 0
	end
end

--初始化邮件列表视图
function MailModule:InitMailItemListView(mailItems)
	if #mailItems>0 then
		self.NoMailTip.text = ""
	else
		self.NoMailTip.text = "打开邮箱一看，空空如也"  -- 没有邮件时候的提示
	end
    self.ContentAreaRoot.gameObject:SetActive(#mailItems>0) --- 没有邮件隐藏右边内容区域

	self.mailToggleItemDict = OrderedDictionary.New()
	self.alreadyDeletedTable = {}
	table.sort(mailItems,MailComps)
	local MailItemNodeClass = require "GUI.MailItemNode"
	
	--- 创建左边邮件item
	for key, value in pairs(mailItems) do
		---print('key '..key)
		if type(key) == "number" then
		    local newItem = MailItemNodeClass.New(value,self.MailToggleGroup,self.MailListLayout)
		    newItem:SetCallBack(self,self.OnMailItemSelected)
		    self:AddChild(newItem)
		   	self.mailToggleItemDict:Add(value.timeStamp,newItem)
		   	
		end
	end
	-- coroutine.start(WaitForFinished, self)
	self:StartCoroutine(WaitForFinished)
end 

local function  SetAwardIcon(self,iconIndex,award,drawReward)
	local itemID = award.itemID
	local itemNum = award.itemNum
	local itemColor = award.itemColor

	local _,itemData,_,iconPath,itemType = GameTools.GetItemDataById(itemID)

	self.MailItemCountLabels[iconIndex].text = 'X'..tostring(award.itemNum)
	local iconImage = self.MailAnnexContentIcons[iconIndex]
	utility.LoadSpriteFromPath(iconPath,iconImage)

	local PropUtility = require "Utils.PropUtility"
    local color = GameTools.GetItemColorByType(itemType,itemData)
    local hslColor = PropUtility.GetRGBColorValue(color)
    self.ColorList[iconIndex].color = hslColor
end

local function GetHadDeleted(self,ids)
	for i = 1 ,#self.alreadyDeletedTable do
		if self.alreadyDeletedTable[i] == ids then
			return true
		end
	end
	return false
end

--- 点开一封邮件的处理
function MailModule:OnMailItemSelected(data,markImage,node)
	if self.currSelectNode == node then
		return
	end
	self.currSelectNode = node
	self.markImage = markImage
	self.curSelectMailData = data
	S2CMailResultClass = require "Network.PB.S2CMailResult"
	
	self.MailContentTitleLabel.text = data.title

	
	if tonumber(self.curSelectMailData.readTime) == 0 then
		--查看时间为零表示没查看，发送设置为已读请求
		---print('邮件未读发送设置已读消息'..data.timeStamp)
		self:MailSetReadRequest()
		
	end
	
	if #self.curSelectMailData.mailAward < 1 then
		if self.curSelectMailData.deleteType == S2CMailResultClass.delAfterRead then
			if not GetHadDeleted(self,data.timeStamp) then
				-- self:OnMailDelRequest()
			end
	    end
	end
    
    --设置发件人
    if self.curSelectMailData.senderType == S2CMailResultClass.systemSender then
    	self.MailContentSenderLabel.text = '系統'
    elseif self.curSelectMailData.senderType == S2CMailResultClass.arenaSender then
    	self.MailContentSenderLabel.text = '竞技场'
    elseif self.curSelectMailData.senderType == S2CMailResultClass.navHuhangSender then
    	self.MailContentSenderLabel.text = '大航海'
    elseif self.curSelectMailData.senderType == S2CMailResultClass.ghfbSender then
   		self.MailContentSenderLabel.text = '工会'
    elseif self.curSelectMailData.senderType == S2CMailResultClass.vipLevelupSender then
    	self.MailContentSenderLabel.text = 'VIP'
    elseif self.curSelectMailData.senderType == S2CMailResultClass.rechargeBackSender then
    	self.MailContentSenderLabel.text = '双倍返还'
    end
    

    --- 没有删除功能，隐藏删除按钮
    --self.AutoReceiveButton.gameObject:SetActive(false)
    local drawReward = true
    print('mail award count ' .. #data.mailAward)
    --- 是否有附件，设置附件按钮，和附件内容
	self.ReceiveButton.gameObject:SetActive(#data.mailAward > 0)	
	self.MailContentItemRoot.gameObject:SetActive(#data.mailAward > 0)
	self.MailContentScrollRect.gameObject:SetActive(#data.mailAward > 0)
	self.MailContentScrollRectText.gameObject:SetActive(#data.mailAward < 1)
	if #data.mailAward > 0 then
		--- 设置邮件内容
	    self.ContentTextLabel.text = data.msg
	    self.ContentTextElement.preferredHeight = self.ContentTextLabel.preferredHeight
        self.ContentArrow.transform.localPosition = Vector3(-3.5,-185,0)
        self.Linebelow.transform.localPosition = Vector3(3.5,-169,0)
		for i=1,#self.delMail do
			if self.delMail[i] == self.curSelectMailData.timeStamp then
				self.ReceiveButton.gameObject:SetActive(false)
                drawReward = false
				print('set false')
			end
		end
	else
        self.ContentTextLabelText.text = data.msg
        self.ContentTextLabelElement.preferredHeight = self.ContentTextLabelText.preferredHeight
        self.ContentArrow.transform.localPosition = Vector3(-3.5,-215,0)
        self.Linebelow.transform.localPosition = Vector3(3.5,-200,0)
	end

	for i=1,#self.MailAnnexContentIcons do
		if i<=#data.mailAward then
			self.MailAnnexContentIcons[i].transform.parent.gameObject:SetActive(true)
			SetAwardIcon(self,i,data.mailAward[i],drawReward)

			if drawReward then
    	       self.MailAnnexContentIcons[i].material = utility.GetCommonMaterial()
    	       self.ColorList[i].material = self.HslMaterial
            else
               self.MailAnnexContentIcons[i].material = utility.GetGrayMaterial()
               --self.ColorList[i].material = utility.GetGrayMaterial()
               self.ColorList[i].color = GameTools.GetGrayColor()
            end
        --获取item
		else
			self.MailAnnexContentIcons[i].transform.parent.gameObject:SetActive(false)

		end
	end

    self.MailContentScrollRect.verticalNormalizedPosition = 1
    self.MailContentScrollRectText.verticalNormalizedPosition = 1
end

function MailModule:RegisterControlEvents()
	-- 注册 MailRetrunButton 的事件
	self.__event_button_onMailRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMailRetrunButtonClicked, self)
	self.MailRetrunButton.onClick:AddListener(self.__event_button_onMailRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMailRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 ReceiveButton 的事件
	self.__event_button_onReceiveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReceiveButtonClicked, self)
	self.ReceiveButton.onClick:AddListener(self.__event_button_onReceiveButtonClicked__)

	-- 注册 AutoReceiveButton 的事件
	self.__event_button_onAutoReceiveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAutoReceiveButtonClicked, self)
	self.AutoReceiveButton.onClick:AddListener(self.__event_button_onAutoReceiveButtonClicked__)
	
	
	-- 注册 MailScrollRect 的事件
    self.__event_scrollrect_onScrollValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScrollValueChanged, self)
    self.MailScrollRect.onValueChanged:AddListener(self.__event_scrollrect_onScrollValueChanged__)
	
    -- 注册 MailContentScrollRect 的事件
    self.__event_scrollrect_onContentScrollValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnContentScrollValueChanged, self)
    self.MailContentScrollRect.onValueChanged:AddListener(self.__event_scrollrect_onContentScrollValueChanged__)

    self.__event_scrollrect_onContentScrollValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnContentScrollValueChanged, self)
    self.MailContentScrollRectText.onValueChanged:AddListener(self.__event_scrollrect_onContentScrollValueChanged__)
end

function MailModule:UnregisterControlEvents()
	-- 取消注册 MailRetrunButton 的事件
	if self.__event_button_onMailRetrunButtonClicked__ then
		self.MailRetrunButton.onClick:RemoveListener(self.__event_button_onMailRetrunButtonClicked__)
		self.__event_button_onMailRetrunButtonClicked__ = nil
		self:RemoveAllChildren(true)
	end

	-- 取消注册 ReceiveButton 的事件
	if self.__event_button_onReceiveButtonClicked__ then
		self.ReceiveButton.onClick:RemoveListener(self.__event_button_onReceiveButtonClicked__)
		self.__event_button_onReceiveButtonClicked__ = nil
	end

	-- 取消注册 AutoReceiveButton 的事件
	if self.__event_button_onAutoReceiveButtonClicked__ then
		self.AutoReceiveButton.onClick:RemoveListener(self.__event_button_onAutoReceiveButtonClicked__)
		self.__event_button_onAutoReceiveButtonClicked__ = nil
	end
	
	
	-- 取消注册 MailScrollRect 的事件
    if self.__event_scrollrect_onScrollValueChanged__ then
        self.MailScrollRect.onValueChanged:RemoveListener(self.__event_scrollrect_onScrollValueChanged__)
        self.__event_scrollrect_onScrollValueChanged__ = nil
    end
	
	-- 取消注册 MailContentScrollRect 的事件
    if self.__event_scrollrect_onContentScrollValueChanged__ then
        self.MailScrollRect.onValueChanged:RemoveListener(self.__event_scrollrect_onContentScrollValueChanged__)
        self.MailContentScrollRectText.onValueChanged:RemoveListener(self.__event_scrollrect_onContentScrollValueChanged__)
        self.__event_scrollrect_onContentScrollValueChanged__ = nil
    end

    -- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function MailModule:RemoveAllChild()
	if self.mailToggleItemDict == nil then return end
	local keys = self.mailToggleItemDict:GetKeys()
	for i = 1 ,#keys do
		local key = keys[i]
		local node = self.mailToggleItemDict:GetEntryByKey(key)
		self:RemoveChild(node)
	end
end

function MailModule:OnMailRetrunButtonClicked()
	--点击返回按钮，关闭当前面板
	self:RemoveAllChild()
	self:Close()
end

function MailModule:OnReceiveButtonClicked()
	--领取附件按钮点击
	self:OnMailDraw()
end

function MailModule:OnAutoReceiveButtonClicked()
    ---一键领取	
	self.myGame:SendNetworkMessage( require"Network/ServerService".MailDrawAllRequest())
end


function MailModule:OnScrollValueChanged(posXY)
	--- 左边可拖动区域 下方小箭头
    local alpha = Mathf.Clamp01(posXY.y)
    local color = self.ArrowList.color
    color.a = alpha
    self.ArrowList.color = color
end

function MailModule:OnContentScrollValueChanged(posXY)
	--- 右边边可拖动区域 下方小箭头
	local alpha = Mathf.Clamp01(posXY.y)
    local color = self.ContentArrow.color
    color.a = alpha
    self.ContentArrow.color = color
end	

-----------------------------------------------------------------------
--- 网络相关事件
-----------------------------------------------------------------------
function MailModule:RegisterNetworkEvents()
	-- 注册网络事件
	self.myGame:RegisterMsgHandler(net.S2CMailResult,self,self.OnMailResult)
	self.myGame:RegisterMsgHandler(net.S2CMailSetReadResult,self,self.OnMailSetReadResult)
	self.myGame:RegisterMsgHandler(net.S2CMailDrawResult,self,self.OnMailDrawResult)
	self.myGame:RegisterMsgHandler(net.S2CMailDelResult,self,self.OnMailDelResult)
	self.myGame:RegisterMsgHandler(net.S2CMailDrawAllResult,self,self.MailDrawAllResult)
end

function MailModule:UnregisterNetworkEvents()
	-- 注销网络事件
	self.myGame:UnRegisterMsgHandler(net.S2CMailResult,self,self.OnMailResult)
	self.myGame:UnRegisterMsgHandler(net.S2CMailSetReadResult,self,self.OnMailSetReadResult)
	self.myGame:UnRegisterMsgHandler(net.S2CMailDrawResult,self,self.OnMailDrawResult)
	self.myGame:UnRegisterMsgHandler(net.S2CMailDelResult,self,self.OnMailDelResult)
	self.myGame:UnRegisterMsgHandler(net.S2CMailDrawAllResult,self,self.MailDrawAllResult)
end

function MailModule:OnMailDraw()
	--- 邮件领取附件请求
	local  msg ,prototype = require"Network/ServerService".MailDrawRequest(self.curSelectMailData.timeStamp)
	self.myGame:SendNetworkMessage(msg,prototype)
end


function MailModule:OnMailRequest()
	--邮件请求
	self.myGame:SendNetworkMessage(require"Network/ServerService".MailRequest())
end

function MailModule:OnMailDelRequest()
	--邮件删除
	local  msg ,prototype = require"Network/ServerService".MailDelRequest(self.curSelectMailData.timeStamp)
	self.myGame:SendNetworkMessage(msg,prototype)
	print('--邮件删除  '..self.curSelectMailData.timeStamp)
	
end

function MailModule:MailSetReadRequest()
    --邮件设置已读
	local  msg ,prototype = require"Network/ServerService".MailSetReadRequest(tostring(self.curSelectMailData.timeStamp))
	self.myGame:SendNetworkMessage(msg,prototype)
end

function MailModule:OnMailDrawResult(msg)
	---邮件附件领取结果
	-- debug_print("@@@@@@邮件附件领取结果")
	self.ReceiveButton.gameObject:SetActive(false)
	
    --local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
	--local windowManager = self.myGame:GetWindowManager()
   	--windowManager:Show(ErrorDialogClass, '邮件附件领取成功')
   	local items = {}
   	for i = 1 ,#msg.awards do
		local item = {}
		item.id = msg.awards[i].itemID
		item.count = msg.awards[i].itemNum
		item.color = msg.awards[i].itemColor
		items[#items + 1] = item
   	end

   	local windowManager = self:GetGame():GetWindowManager()
   	local AwardCls = require "GUI.Task.GetAwardItem"
   	windowManager:Show(AwardCls,items)

	table.insert(self.delMail,self.curSelectMailData.timeStamp)
	if self.curSelectMailData.deleteType == S2CMailResultClass.delAfterDraw then
		self:OnMailDelRequest()
	end
    --self:OnMailItemSelected(self.curSelectMailData,self.markImage)
end


function MailModule:OnMailResult(msg)
	-- 邮件请求结果	
	local mailItems = {}
	mailItems = msg.mailItems
	---print("mail count " .. #msg.mailItems)
	self:InitMailItemListView(mailItems)
end

local function GetResetNode(self,ids)
	local keys = self.mailToggleItemDict:GetKeys()
	local index
	for i = 1 ,#keys do
		if keys[i] == ids then
			index = i
			break
		end
	end
	local result
	if index ~= nil then
		if keys[index + 1] ~= nil then
			result = index + 1
		else
			result = index - 1
		end
	end
	if result ~= nil and result > 0 then
		return self.mailToggleItemDict:GetEntryByKey(keys[result])
	end
	return nil
end

local function SetNoneNodeView(self)
	self.ContentAreaRoot.gameObject:SetActive(false)
	self.NoMailTip.text = "打开邮箱一看，空空如也"
end

local function DeletedNode(self,msg)
	local resetNode = GetResetNode(self,msg.ids[1])
	if resetNode ~= nil then
		resetNode:SetSelected(true)
	else
		SetNoneNodeView(self)
	end

	local deletedNode = self.mailToggleItemDict:GetEntryByKey(msg.ids[1])
	self:RemoveChild(deletedNode)
	self.mailToggleItemDict:Remove(msg.ids[1])
end

function MailModule:OnMailDelResult(msg)
	if GetHadDeleted(self,msg.ids[1]) then
		return
	end

	--- 邮件删除结果 ，收到返回后移除缓存中该邮件数据
	local dataCacheMgr = self.myGame:GetDataCacheManager()
	local UserDataType = require "Framework.UserDataType"
    dataCacheMgr:UpdateData(UserDataType.MailMessageData, function(oldData)
        require "Data.MailMessageData"
        if oldData == nil then
            oldData = MailMessageData.New()
        end
	
        oldData:RemoveMailMessageById(msg.ids[1])
        return oldData
    end)	
    
    self.markImage.material = utility.GetGrayMaterial()
	self.alreadyDeletedTable[#self.alreadyDeletedTable + 1] = msg.ids[1]
	DeletedNode(self,msg)
end

function MailModule:OnMailSetReadResult(msg)
    --- 邮件设置已读请求结果 缓存到本地
    local dataCacheMgr = self.myGame:GetDataCacheManager()
	local UserDataType = require "Framework.UserDataType"
    dataCacheMgr:UpdateData(UserDataType.MailMessageData, function(oldData)
        require "Data.MailMessageData"
        if oldData == nil then
            oldData = MailMessageData.New()
        end
		---print('mailId '..msg.mailId .. ' readTime '..msg.readTime)
        oldData:UpdateMailMessageReadType(msg.mailId,msg.readTime)
        return oldData
    end)	
	---print("on mail set read result")
end

local function DeleteCached(self,id)
	local dataCacheMgr = self.myGame:GetDataCacheManager()
	local UserDataType = require "Framework.UserDataType"
    dataCacheMgr:UpdateData(UserDataType.MailMessageData, function(oldData)
        require "Data.MailMessageData"
        if oldData == nil then
            oldData = MailMessageData.New()
        end
	
        oldData:RemoveMailMessageById(id)
        return oldData
    end)	
end

function MailModule:MailDrawAllResult(msg)
	if msg.mailId == "" then
		return
	end
	for i=1,#msg.awards do
		debug_print("MailDrawAllResult",msg.awards[i].itemID,msg.awards[i].itemNum,msg.awards[i].itemColor)
	end
	local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Tower.TowerSweepAward",msg.awards,3)

	local list = utility.Split(msg.mailId,",")
	-- if #list > 0 then
	-- 	utility.ShowErrorDialog("已经成功领取邮件奖励")
	-- end

	for k,v in pairs(list) do
		local deletedNode = self.mailToggleItemDict:GetEntryByKey(v)
		self:RemoveChild(deletedNode)
		self.mailToggleItemDict:Remove(v)
		DeleteCached(self,v)
	end

	local count = self.mailToggleItemDict:Count()
	if count > 0 then
		local resetNode = self.mailToggleItemDict:GetEntryByIndex(1)
		resetNode:SetSelected(true)
	else
		SetNoneNodeView(self)
	end
end

return MailModule
