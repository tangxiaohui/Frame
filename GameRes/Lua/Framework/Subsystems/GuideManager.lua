require "Framework.GameSubSystem"
local game = require "Game.Cos3DGame"
local utility = require "Utils.Utility"
local unityUtils = require "Utils.Unity"
local newPlayerGuideStepData = require "StaticData.NewPlayerGuideStep"
local playerPrefsUtils = require "Utils.PlayerPrefsUtils"
local GuideStepInfoData = require "StaticData.GuideStepInfo"

local GuideManager = Class(GameSubSystem)

function GuideManager:Ctor()
	self.stepIdx = 0
	self.stepId = 0
	self.guideEvntId = {}
	self.guideEvntList = {}
	
	self.stepInfo = {}	--读取excel表的一行数据
	self.isWaitingUI = false

	self.isAllDone = false

	self.Pause = false
end

---------------------------------------------------------------------------
------- 实现 GameSubSystem 的接口
---------------------------------------------------------------------------
function GuideManager:GetGuid()
    return require "Framework.SubsystemGUID".GuideManager
end

function GuideManager:Startup()
	local net = require "Network.Net"
    game:RegisterMsgHandler(net.S2CGuideStateResult, self, self.GuideStateResult)
    game:RegisterMsgHandler(net.S2CGuideDoneResult, self, self.GuideDoneResult)
    game:RegisterMsgHandler(net.S2CGuideAwardResult, self, self.GuideDoneAwardResultMessage)
end

function GuideManager:Shutdown()
	local net = require "Network.Net"
    game:UnRegisterMsgHandler(net.S2CGuideStateResult, self, self.GuideStateResult)
    game:UnRegisterMsgHandler(net.S2CGuideDoneResult, self, self.GuideDoneResult)
    game:UnRegisterMsgHandler(net.S2CGuideAwardResult, self, self.GuideDoneAwardResultMessage)
end

function GuideManager:Restart()
end

function GuideManager:Update()
end

---------------------------------------------------------------------------
------- 处理消息
---------------------------------------------------------------------------
function GuideManager:GuideStateResult(msg)
	
	debug_print("@@ GuideStateResult @@")
	self.first=true
	self.stepId = msg.step
	if self.stepId==0 then
		-- print("傻逼新手引导结束了")
		self.isAllDone = true
		return
	end


	local stepInfo = newPlayerGuideStepData:GetData(self.stepId)
	self.stepInfo = stepInfo
	-- print(self.stepInfo)
	-- print(self.stepId,self.stepInfo:GetGuideEvent(),"$$$$$$$$$$$$$$$$")
	local keys = newPlayerGuideStepData:GetKeys()

	self.stepIdx=self.stepInfo:GetGuideEvent()
	-- for i=0,keys.Length-1 do
	-- 	print(keys[i],"       $$$$$$$$$$$$$$$$$$$")
	-- end


--self:ShowGuidance()
	-- local keyLength = keys.Length
	-- local i = self.stepIdx
	-- while ((i < keyLength) and (keys[i] < self.stepId)) do
	-- 	print("@@@@@ GuideStateResult", keys[i])
	-- 	playerPrefsUtils:SetGuideEvntDone(keys[i])
		
	-- 	i = i + 1
	-- end
	-- print("当前State self.stepIdx",self.stepIdx)
	-- if i > self.stepIdx then
	-- 	self.stepIdx = i
	-- end
end

function GuideManager:GuideDoneResult(msg)
	debug_print("@@ GuideDoneResult @@")
	if  self.guideEvntId[self.stepIdx] ~= nil  then
		return
	end
	if msg.step==0 then
		-- print("傻逼新手引导结束了")
		self.isAllDone = true
		return
	end


	self.first=true
	--utility:GetGame():SendNetworkMessage( require"Network/ServerService".GuideStateRequest())
	print("@@@@@@@@@@ GuideManager:GuideDoneResult"..msg.step)
	--local step = msg.step
	
	self.stepId=msg.step

	local stepInfo = newPlayerGuideStepData:GetData(self.stepId)
	self.stepInfo = stepInfo

	self.stepIdx=self.stepInfo:GetGuideEvent()

	-- local keys = newPlayerGuideStepData:GetKeys()




	-- local keyLength = keys.Length
	-- local i = self.stepIdx
	-- while ((i < keyLength) and (keys[i] < self.stepId)) do
	-- 	print("已经完成的步骤", keys[i],self.stepId)
	-- 	playerPrefsUtils:SetGuideEvntDone(keys[i])
		
	-- 	i = i + 1
	-- end
	-- if i > self.stepIdx then
	-- 	self.stepIdx = i
	-- end

	print("即将要做的步骤self.stepIdx",self.stepIdx,self.stepId)

	self:ShowGuidance()

end

function GuideManager:IsAllDone()
	return self.isAllDone
end

function GuideManager:GuideDoneAwardResultMessage(msg)
	local items = {}
	for i=1,#msg.awards do
		items[i] = {}
		items[i].id = msg.awards[i].itemID
		items[i].count = msg.awards[i].itemNum
		items[i].color = msg.awards[i].itemColor
	end
	utility:GetGame():GetWindowManager():Show(require "GUI.Task.GetAwardItem",items)
end

---------------------------------------------------------------------------
------- 实现功能
---------------------------------------------------------------------------
function GuideManager:IsGuideEvntDone(evntId)
	return playerPrefsUtils:IsGuideEvntDone(evntId)
end

function GuideManager:AddGuideEvnt(evntId)
	-- if playerPrefsUtils:IsGuideEvntDone(evntId) then
	-- 	print("@@@@@ GuideManager:AddGuideEvnt GuideEvntDone", evntId)
	-- 	return
	-- end
	
	if self.guideEvntId[evntId] ~= nil then
		print("@@@@@ GuideManager:AddGuideEvnt GuideEvntExist", evntId)
		return
	end
	
	self.guideEvntId[evntId] = evntId
	self.guideEvntList[#self.guideEvntList + 1] = evntId
end

function GuideManager:RemoveGuideEvnt(evntId)
	-- if playerPrefsUtils:IsGuideEvntDone(evntId) then
	-- 	print("@@@@@ GuideManager:AddGuideEvnt GuideEvntDone", evntId)
	-- 	return
	-- end
	
	if self.guideEvntId[evntId] ~= nil then
		print("@@@@@ GuideManager:RemoveGuideEvnt GuideEvntExist", evntId)
		self.guideEvntId[evntId] = nil

		for i=1,#self.guideEvntList do
			if self.guideEvntList[i] == evntId then
				table.remove(self.guideEvntList, i)
				break
			end
		end

		return
	end
	
	
end

local function guideEvntListCompare(lhs, rhs)
	return lhs > rhs
end

function GuideManager:SortGuideEvnt()
	if #self.guideEvntList < 1 then
		print("数量少 无法排序",#self.guideEvntList)
		return
	end

	table.sort(self.guideEvntList, guideEvntListCompare)
	
	require "Utils.PrintTable"
	PrintTable(self.guideEvntList)
end

function GuideManager:PauseGuide(state)
	self.Pause = state
end

function GuideManager:ShowGuidance()
	if self.first ~=true then
		return
	end
	if self.Pause then
		return
	end

	if #self.guideEvntList <= 0 then
		self.isWaitingUI = false
		return
	end
	
	if self.stepId <= 0 then
		print("@@@@ 新手引导步骤ID为0, 不继续引导! >>傻逼新手引导结束了")
		return
	end
	local stepInfo = newPlayerGuideStepData:GetData(self.stepId)
	self.stepInfo = stepInfo

	local  ModulePath=stepInfo:GetModulePath()
	--print(ModulePath,"       ModulePath")
	if ModulePath~=nil and  ModulePath~=0 then
		local windowManager = utility.GetGame():GetWindowManager()
    		local windowCls = require "GUI.NewModuleCls"
    		windowManager:Show(windowCls,ModulePath)
    		print("ModulePath！=0",ModulePath)
		--return
	end

	-- for i=1,#self.guideEvntList do
	-- 	print(self.guideEvntList[i],"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	-- end
	local stepGuideEvnt = stepInfo:GetGuideEvent()
	while ((#self.guideEvntList > 0) and (self.guideEvntList[#self.guideEvntList] < stepGuideEvnt)) do
		self.guideEvntId[self.guideEvntList[#self.guideEvntList]] = nil
		self.guideEvntList[#self.guideEvntList] = nil
	end
	
	print(#self.guideEvntList == 0,(self.guideEvntList[#self.guideEvntList] ~= stepGuideEvnt),#self.guideEvntList,stepGuideEvnt,self.guideEvntList[#self.guideEvntList])


	for i=1,#self.guideEvntList do
		print(self.guideEvntList[i],"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	end



	if (#self.guideEvntList == 0) or (self.guideEvntList[#self.guideEvntList] ~= stepGuideEvnt) then
		return
	end
	
	--require "Utils.PrintTable"
	--PrintTable(self.guideEvntList)

	local ui2Load = stepInfo:GetNeedInterface()
	local isUiLoaded = unityUtils:FindGameObject(ui2Load)
	print(isUiLoaded)
	if isUiLoaded then
		self.isWaitingUI = false
		local windowManager = utility.GetGame():GetWindowManager()
		local hwnd = windowManager:Show(require "GUI.Guide", GuideStepInfoData:GetData(stepInfo:GetInfo()):GetContent(), 
							stepInfo:GetOperatingType(), stepInfo:GetTypeParam(), stepInfo:GetTypePos(), 
							stepInfo:GetHighlightSwitch(), stepInfo:GetHighlightPos(), 
							stepInfo:GetPortrait(), stepInfo:GetPortraitPosition(), stepInfo:GetFramePosition(),stepInfo:GetGuideVoice(),stepInfo:GetGuideLocateDelay(),stepInfo:GetModulePath())

		print("@@@@@ 显示窗口!!!", hwnd,stepInfo:GetModulePath())
	else
		self.isWaitingUI = true
		print("Waiting for ui "..ui2Load)
	end
	
	if stepInfo:GetWindowScroll()=='0' then
		utility:GetGame():GetEventManager():PostNotification('MoveGuidePosition', nil, 'left')
	elseif stepInfo:GetWindowScroll()=='1' then
		utility:GetGame():GetEventManager():PostNotification('MoveGuidePosition', nil, 'right')
	end
end

function GuideManager:FinishGuideStep()
	utility:GetGame():SendNetworkMessage(require"Network/ServerService".GuideDoneRequest(self.stepId))
	
	-- send event --
	local messageGuids = require "Framework.Business.MessageGuids"
	game:DispatchEvent(messageGuids.PlayerGuideEventDone, nil, self.stepId)
	
	self.stepId = self.stepInfo:GetNextId()
	if #self.guideEvntList > 0 then
		self.guideEvntId[self.guideEvntList[#self.guideEvntList]] = nil
		self.guideEvntList[#self.guideEvntList] = nil
	end
	
	-- print("@@@@@ GuideManager:FinishGuideStep", self.stepIdx)
	
	--local keys = newPlayerGuideStepData:GetKeys()
	--playerPrefsUtils:SetGuideEvntDone(keys[self.stepIdx])
	-- self.stepIdx = self.stepIdx + 1
	-- print(self.stepIdx,"self.stepIdx+1")
	-- self:ShowGuidance()
	self.first=false
end

function GuideManager:IsWaiting()
	return self.isWaitingUI
end

function GuideManager:IsLoadedUi(name)
	return self.stepInfo:GetNeedInterface() == name
end

return GuideManager