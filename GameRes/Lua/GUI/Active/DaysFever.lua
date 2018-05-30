local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
require "LUT.StringTable"

local DaysFeverCls = Class(BaseNodeClass)
windowUtility.SetMutex(DaysFeverCls, true)


function  DaysFeverCls:Ctor()
end

function DaysFeverCls:OnWillShow(msg)
	-- self.day = 4
	-- self.tableStatus = {}
	-- self.sevenDay = {}
	-- self.sevenDayLiBao = {}
	-- self.sevenDayProgress = {}
	-- self.countDown = 500125
	self.msg = msg
	-- self.sevenDay = msg.sevenDay
	-- self.sevenDayLiBao = msg.sevenDayLiBao
	-- self.sevenDayProgress = msg.sevenDayProgress
	-- self.day = msg.day
	-- self.countDown = msg.countDown
	-- self.progress = msg.progres
	-- -- self.tableStatus = msg.state
end

function  DaysFeverCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/7DayFever",function(go)
		self:BindComponent(go)
	end)
end

function DaysFeverCls:OnComponentReady()
	self:InitControls()
end

function DaysFeverCls:OnResume()
	DaysFeverCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RedDotStateQuery()
	self:ShowPanel()
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
	-- self:ActivitySevenDayHappyRequest()
end

function DaysFeverCls:OnPause()
	DaysFeverCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function DaysFeverCls:OnEnter()
	DaysFeverCls.base.OnEnter(self)
end

function DaysFeverCls:OnExit()
	DaysFeverCls.base.OnExit(self)
end

function DaysFeverCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  DaysFeverCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find("Base")
	self.returnButton = self.base:Find("CrossButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.point = self.base:Find("Box/Scroll View/Viewport/Content")

	self.daysButton = {}
	self.daysButtonOn = {}
	self.daysButtonOff = {}
	self.RedDotImage = {}
	self.closeImage = {}
	for i=1,7 do
		self.daysButton[i] = self.base:Find("Buttons/Day"..i):GetComponent(typeof(UnityEngine.UI.Button))
		self.daysButtonOn[i] = self.daysButton[i].transform:Find("On").gameObject
		self.daysButtonOff[i] = self.daysButton[i].transform:Find("Off").gameObject
		self.RedDotImage[i] = self.daysButton[i].transform:Find("RedDotImage").gameObject
		self.closeImage[i] = self.daysButton[i].transform:Find("CloseImage").gameObject
		self.closeImage[i]:SetActive(true)
		self.RedDotImage[i]:SetActive(false)
	end

	self.feverButton = {}
	self.feverButtonOn = {}
	for i=1,2 do
		self.feverButton[i] = self.base:Find("Box/Tag/FeverButton"..i.."/Off"):GetComponent(typeof(UnityEngine.UI.Button))
		self.feverButtonOn[i] = self.base:Find("Box/Tag/FeverButton"..i.."/On")
	end
	self.progressButton = self.base:Find("ProgressButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.Tag = self.base:Find("Box/Tag").gameObject
	self.ProgressBox = self.base:Find("ProgressBox").gameObject
	self.progressPoint = self.ProgressBox.transform:Find("Scroll View/Viewport/Content")
	self.timeLabel = self.base:Find("Time/TimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))

	--进度条
	self.progressFill = self.ProgressBox.transform:Find("Progress/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	self.progressText = self.ProgressBox.transform:Find("Progress/Text"):GetComponent(typeof(UnityEngine.UI.Text))

	--红点
	self.progressRedImage = self.progressButton.transform:Find("RedDotImage").gameObject
	self.progressRedImage:SetActive(false)

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()
	self.buttonId = nil
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function DaysFeverCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function DaysFeverCls:OnExitTransitionDidStart(immediately)
    DaysFeverCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function  DaysFeverCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)

	self._event_button_onProgressButtonClicked_ = UnityEngine.Events.UnityAction(self.OnFeverButton3Clicked,self)
	self.progressButton.onClick:AddListener(self._event_button_onProgressButtonClicked_)

	self._event_button_onDaysButtonClicked_ = {}
	self.OnDaysButtonClicked = {}
	self.OnDaysButtonClicked[1] = self.OnDaysButton1Clicked
	self.OnDaysButtonClicked[2] = self.OnDaysButton2Clicked
	self.OnDaysButtonClicked[3] = self.OnDaysButton3Clicked
	self.OnDaysButtonClicked[4] = self.OnDaysButton4Clicked
	self.OnDaysButtonClicked[5] = self.OnDaysButton5Clicked
	self.OnDaysButtonClicked[6] = self.OnDaysButton6Clicked
	self.OnDaysButtonClicked[7] = self.OnDaysButton7Clicked
	for i=1,#self.OnDaysButtonClicked do
		self._event_button_onDaysButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnDaysButtonClicked[i],self)
		self.daysButton[i].onClick:AddListener(self._event_button_onDaysButtonClicked_[i])
	end

	self._event_button_onFerverButtonClicked_ = {}
	self.OnFeverButtonClicked = {}
	self.OnFeverButtonClicked[1] = self.OnFeverButton1Clicked
	self.OnFeverButtonClicked[2] = self.OnFeverButton2Clicked
	-- self.OnFeverButtonClicked[3] = self.OnFeverButton3Clicked
	for i=1,#self.OnFeverButtonClicked do
		self._event_button_onFerverButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnFeverButtonClicked[i],self)
		self.feverButton[i].onClick:AddListener(self._event_button_onFerverButtonClicked_[i])
	end

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)


end

function  DaysFeverCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end

	if self._event_button_onProgressButtonClicked_ then
		self.progressButton.onClick:RemoveListener(self._event_button_onProgressButtonClicked_)
		self._event_button_onProgressButtonClicked_ = nil
	end

	for i=1,#self._event_button_onDaysButtonClicked_ do
		if self._event_button_onDaysButtonClicked_[i] then
			self.daysButton[i].onClick:RemoveListener(self._event_button_onDaysButtonClicked_[i])
			self._event_button_onDaysButtonClicked_[i] = nil
		end
	end	

	for i=1,#self._event_button_onFerverButtonClicked_ do
		if self._event_button_onFerverButtonClicked_[i] then
			self.feverButton[i].onClick:RemoveListener(self._event_button_onFerverButtonClicked_[i])
			self._event_button_onFerverButtonClicked_[i] = nil
		end
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function DaysFeverCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CActivitySevenDayHappyResult,self,self.ActivitySevenDayHappyResult)
	self.myGame:RegisterMsgHandler(net.S2CActivitySevenDayAwardResult,self,self.OnActivityGetAwardResult)
end

function DaysFeverCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CActivitySevenDayHappyResult,self,self.ActivitySevenDayHappyResult)
	self.myGame:UnRegisterMsgHandler(net.S2CActivitySevenDayAwardResult,self,self.OnActivityGetAwardResult)
end

function  DaysFeverCls:OnActivityGetAwardResult(msg)
	-- debug_print("收到回复",msg.tid)
	if msg.status then
		-- self:ShowAwardPanel(1)
		self:ShowAwardPanel(msg.tid,msg.activityId)
	-- 	local activeData = require "StaticData.Activity.NewServerFever":GetData(msg.activityId)
	-- 	local day = activeData:GetDay()
	-- 	self:ShowDaysInfo(day)
		-- local activeData = require "StaticData.Activity.ActivityConsumption":GetData(msg.activityId)
		-- local id = activeData:GetActivityId()
		self:ActivitySevenDayHappyRequest(msg.tid)
		-- self:LoadItem()
	end
end

function DaysFeverCls:ActivitySevenDayHappyResult(msg)
	-- self.day = msg.day
	self.buttonId = nil
	-- self.tableStatus = msg.state
	self.msg = msg
	-- debug_print(msg.hid)
	-- self.sevenDay = msg.sevenDay
	-- self.sevenDayLiBao = msg.sevenDayLiBao
	-- self.sevenDayProgress = msg.sevenDayProgress
	if msg.hid ~= 3 then
		self:ShowDaysInfo(self.msgDay,msg.hid)
	else
		self:ShowProgressPanel()
	end
end

function DaysFeverCls:ActivitySevenDayHappyRequest(hid)
	self.myGame:SendNetworkMessage( require "Network.ServerService".ActivitySevenDayHappyRequest(hid))
end

function DaysFeverCls:OnDaysButton1Clicked()
	self:ShowDaysInfo(1)
end

function DaysFeverCls:OnDaysButton2Clicked()
	self:ShowDaysInfo(2)
end

function DaysFeverCls:OnDaysButton3Clicked()
	self:ShowDaysInfo(3)
end

function DaysFeverCls:OnDaysButton4Clicked()
	self:ShowDaysInfo(4)
end

function DaysFeverCls:OnDaysButton5Clicked()
	self:ShowDaysInfo(5)
end

function DaysFeverCls:OnDaysButton6Clicked()
	self:ShowDaysInfo(6)
end

function DaysFeverCls:OnDaysButton7Clicked()
	self:ShowDaysInfo(7)
end

function DaysFeverCls:OnReturnButtonClicked()
	self:Close(true)
end

function DaysFeverCls:OnFeverButton1Clicked()
	-- self:ActivitySevenDayHappyRequest(1)
	self:ShowFeverItem(1)
end

function DaysFeverCls:OnFeverButton2Clicked()
	-- self:ActivitySevenDayHappyRequest(2)
	self:ShowFeverItem(2)
end

function DaysFeverCls:OnFeverButton3Clicked()
	-- self:ActivitySevenDayHappyRequest(3)
	self:ShowProgressPanel()
end

function DaysFeverCls:ShowPanel()
	self:OnDaysButton1Clicked()
	self:SetTime(self.msg.countDown)
	self:LoadButtonState()
end 

function DaysFeverCls:ShowFeverItem(index)
	self:HideFeverButton()
	self:HideProgressPanel(false)
	self.feverButtonOn[index].gameObject:SetActive(true)
	self.feverButton[index].gameObject:SetActive(false)
	self:RemoveItem()
	self:ShowItemInfo(index,self.buttonId)
end

function DaysFeverCls:ShowProgressPanel()
	self:ShowDaysInfo(8)
	self:HideProgressPanel(true)
	self:RemoveItem()
	self:LoadProgressItem()
	self:LoadProgressFill(self.msg.progres)
end

function DaysFeverCls:LoadButtonState()
	for i=1,#self.closeImage do
		if self.msg.day >= i then
			self.closeImage[i]:SetActive(false)
		end
	end
end

function DaysFeverCls:LoadProgressFill(count)
	local progress = require "StaticData.Activity.NewServerFeverMain":GetProgress()
	self.progressFill.fillAmount = count/progress
	self.progressText.text = count.."/"..progress
end

function DaysFeverCls:LoadProgressItem()
	local dayFeverData = require "StaticData.Activity.NewServerFeverProgress"
	local keys = dayFeverData:GetKeys()
	local idTabel = {} 
	for i=0,(keys.Length - 1) do
		local data = dayFeverData:GetData(keys[i])
		idTabel[#idTabel + 1] = data:GetID()
	end
	self.node = {}
	self:Sort(self.msg.sevenDayProgress)
	for i=1,#self.msg.sevenDayProgress do
		self.AcitveAwardItemCls = require "GUI.Active.DaysFeverAwardList".New(self.progressPoint,self.msg.sevenDayProgress[i].id,self.msg.sevenDayProgress,3)
		self:AddChild(self.AcitveAwardItemCls)
		self.node[i] = self.AcitveAwardItemCls
	end
end

function DaysFeverCls:SetTableState(data)
	if data == 1 then
		data = 2
	elseif data == 2 then
		data = 0
	elseif data == 0 then
		data = 1
	end
	return data
end

function DaysFeverCls:Sort(data)
	table.sort(data,function(a,b)
		if self:SetTableState(a.status) == self:SetTableState(b.status) then
			return a.id < b.id
		else
			return self:SetTableState(a.status) > self:SetTableState(b.status)
		end
		end)
end

function DaysFeverCls:HideProgressPanel(isHide)
	self.Tag:SetActive(not isHide)
	self.ProgressBox:SetActive(isHide)
	self.progressButton.transform:Find("On").gameObject:SetActive(isHide)
	self.progressButton.transform:Find("Off").gameObject:SetActive(not isHide)
end


function DaysFeverCls:ShowDaysInfo(index,hid)
	if hid == nil then
		hid = 1
	end
	if index <= 7 and self.buttonId ~= index then
		if index <= self.msg.day  and index ~= nil and self.msg.day ~= nil then
			self:HideAllButton()
			self.daysButtonOn[index]:SetActive(true)
			self.daysButtonOff[index]:SetActive(false)
			self:SetButtonState(self.msg.day)
			self.buttonId = index
			self.msgDay = index
			self:ShowFeverItem(hid)
		
		end
	elseif index > 7 and self.buttonId ~= index then
		self.buttonId = index
		self:HideAllButton()
	end
end

function DaysFeverCls:ShowItemInfo(index,day)
	local tableStatus = {}
	local dayFeverData
	if index == 1 then
		dayFeverData = require "StaticData.Activity.NewServerFever"
		tableStatus = self.msg.sevenDay	
	elseif index == 2 then
		dayFeverData = require "StaticData.Activity.NewServerFeverGift"
		tableStatus = self.msg.sevenDayLiBao
	end
	-- local keys = dayFeverData:GetKeys()
	-- local idTabel = {} 
	-- for i=0,(keys.Length - 1) do
	-- 	local data = dayFeverData:GetData(keys[i])
	-- 	if data:GetDay() == day then
	-- 		idTabel[#idTabel + 1] = data:GetID()
	-- 	end
	-- end
	local table = {}
	for i=#tableStatus,1,-1 do
		local data = dayFeverData:GetData(tableStatus[i].id)
		if data:GetDay() == day then
			table[#table + 1] = tableStatus[i]
		end
	end
	self.node = {}
	self:Sort(table)
	
	for i=1,#table do
		self.AcitveAwardItemCls = require "GUI.Active.DaysFeverAwardList".New(self.point,table[i].id,table,index)
		self:AddChild(self.AcitveAwardItemCls)
		self.node[i] = self.AcitveAwardItemCls
	end
end

function DaysFeverCls:RemoveItem()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
end

function DaysFeverCls:HideFeverButton()
	for i=1,#self.feverButton do
		self.feverButton[i].gameObject:SetActive(true)
		self.feverButtonOn[i].gameObject:SetActive(false)
	end
end
--重置7天所有的Button
function DaysFeverCls:HideAllButton()
	for i=1,#self.daysButtonOn do
		self.daysButtonOn[i]:SetActive(false)
		self.daysButtonOff[i]:SetActive(true)
	end
end

function DaysFeverCls:SetButtonState(day)
	for i=1,#self.daysButton do
		if i > day then
			self.daysButtonOff[i].transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
		else
			self.daysButtonOff[i].transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetCommonMaterial()
		end
	end
end

function DaysFeverCls:ShowAwardPanel(tid,activeId)
	if activeId ~= nil then
		local activeData
		if tid == 1 then
			activeData = require "StaticData.Activity.NewServerFever":GetData(activeId)
		elseif tid == 2 then
			activeData = require "StaticData.Activity.NewServerFeverGift":GetData(activeId)
		elseif tid == 3 then
			activeData = require "StaticData.Activity.NewServerFeverProgress":GetData(activeId)
		end
		local itemstables = {}
		local gametool = require "Utils.GameTools"
		local itemId = activeData:GetItemID()
		local itemNum = activeData:GetItemNum()
		local colors = {}
		for i=0,itemId.Count - 1 do
			local _,data,_,_,itype = gametool.GetItemDataById(itemId[i])
			local color = gametool.GetItemColorByType(itype,data)
			colors[i] = color
		end
	
		for i=0,itemId.Count - 1 do
			itemstables[i + 1] = {}
			itemstables[i + 1].id = itemId[i]
			itemstables[i + 1].count = itemNum[i]
			itemstables[i + 1].color = colors[i]
		end

		local windowManager = self:GetGame():GetWindowManager()
    	local AwardCls = require "GUI.Task.GetAwardItem"
    	windowManager:Show(AwardCls,itemstables)
    else
    	debug_print("服务器返回活动ID为空")
    end
end


function DaysFeverCls:SetTime(time)
	local times = self:GetLocalTime(time)
	local timesTable = utility.Split(times,":")
	if #timesTable == 3 then
		text = string.format(ActivityStringTable[0],timesTable[1],timesTable[2],timesTable[3])
	end
	self.timeLabel.text = text
end

function DaysFeverCls:GetLocalTime(time)
	local dayChange = 60*60*24
	local hourChange = 60*60
	local minChange = 60
	local day,lastTime = math.modf(time/dayChange)
	local hour
	lastTime = lastTime * dayChange
	hour,lastTime = math.modf(lastTime/hourChange)
	lastTime = lastTime * hourChange
	local min = math.ceil(lastTime/minChange)
	return day..":"..hour..":"..min
end

--红点
function DaysFeverCls:RedDotStateQuery()
	debug_print("RedDotStateQuery DaysFeverCls")
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
    local activeRed
	local activeInfo = RedDotData:GetServerDayInfo()
	local day = {}
	local progressFlag = false
	for i=1,#activeInfo do
		debug_print(activeInfo[i].activityID,activeInfo[i].red,activeInfo[i].subID)
		if activeInfo[i].activityID ~= 0 then
			if activeInfo[i].activityID == 3 then
				--进度
				if progressFlag == false then
					if activeInfo[i].red == 1 then
						progressFlag= true
					end
				end
			elseif activeInfo[i].activityID == 1 and activeInfo[i].red == 1 then
				--七日狂欢
				local activeData = require "StaticData.Activity.NewServerFever":GetData(activeInfo[i].subID)
				day[#day + 1] = activeData:GetDay()
			end
		end
	end
	self.progressRedImage:SetActive(progressFlag)
	for i=1,#self.RedDotImage do
	
		self.RedDotImage[i].gameObject:SetActive(false)
	end
	for i=1,#day do
	
		self.RedDotImage[day[i]].gameObject:SetActive(true)
	end
end

function DaysFeverCls:RedDotStateUpdated(moduleId,moduleState)
	self:RedDotStateQuery()
end

return DaysFeverCls