local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local messageGuids = require "Framework.Business.MessageGuids"

local AchievementCls = Class(BaseNodeClass)

local AchievementState = 2  -- 成就

function AchievementCls:Ctor()

end


function AchievementCls:OnInit()
	-- 加载界面(只走一次)

	utility.LoadNewGameObjectAsync('UI/Prefabs/Achievement', function(go)
		self:BindComponent(go)
	end)
end

function AchievementCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	--self:LinkComponent(self.parent)
	--self:LinkComponent(self.parent)
	self:InitControls()
end

function AchievementCls:OnResume()
	-- 界面显示时调用
	AchievementCls.base.OnResume(self)
	require "Utils.GameAnalysisUtils".EnterScene("成就界面")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_AchievementView)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	--self:RefreshContentPanel()
	self:RedDotStateQuery()
	self:LoadCotent()
	self:InitContent()
	self:RegisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function AchievementCls:OnPause()
	-- 界面隐藏时调用
	AchievementCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function AchievementCls:OnEnter()
	-- Node Enter时调用
	AchievementCls.base.OnEnter(self)
end

function AchievementCls:OnExit()
	-- Node Exit时调用
	AchievementCls.base.OnExit(self)
end

function AchievementCls:InitControls()
	local transform = self:GetUnityTransform()
	-- 垂直布局
	self.Point = transform:Find('Content/Viewport/Point')
	
	-- 退出按钮
	self.titleButton = transform:Find('ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))	

	-- 成就挂点
	self.AchievementScrollNodePoint = transform:Find('Species/Layout')
	self.myGame = utility:GetGame()

end

function AchievementCls:LoadCotent()
	self:LoadAchievementContent()
end

function AchievementCls:InitContent()
	self:ShowAchievementPanel()
end


function AchievementCls:RegisterControlEvents()

	-- 注册 退出事件
    self.__event_button_onTitleButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTitleButtonClicked, self)
    self.titleButton.onClick:AddListener(self.__event_button_onTitleButtonClicked__)
end

function AchievementCls:UnregisterControlEvents()
	
	-- 取消注册 退出事件
	 if self.__event_button_onTitleButtonClicked__ then
        self.titleButton.onClick:RemoveListener(self.__event_button_onTitleButtonClicked__)
        self.__event_button_onTitleButtonClicked__ = nil
    end
end

function AchievementCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CChengjiuQueryResult, self, self.OnChengjiuQueryResponse)
	self.myGame:RegisterMsgHandler(net.S2CChengjiuDrawResult, self, self.OnChengjiuDrawResponse)
	self.myGame:RegisterMsgHandler(net.TuJianQueryResultMessage,self, self.OnTuJianQueryResponse)
	self.myGame:RegisterMsgHandler(net.TuJianDrawResultMessage,self, self.OnTuJianDrawResponse)
end

function AchievementCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CChengjiuQueryResult, self, self.OnChengjiuQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CChengjiuDrawResult, self, self.OnChengjiuDrawResponse)
	self.myGame:UnRegisterMsgHandler(net.TuJianQueryResultMessage,self, self.OnTuJianQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.TuJianDrawResultMessage,self, self.OnTuJianDrawResponse)
end

---------------------------------------------------------------------
function AchievementCls:OnChengjiuDrawRequest(cid,key)
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChengjiuDrawRequest(cid,key))
end

function AchievementCls:OnChengjiuQueryRequest(sonid,typeId)
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChengjiuQueryRequest(sonid,typeId))
end

function AchievementCls:OnTuJianQueryRequest(sonid,typeId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".TuJianQueryRequest(sonid,typeId))
end

function AchievementCls:OnTuJianDrawRequest(oid,typeId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".TuJianDrawRequest(oid,typeId))
end

function AchievementCls:OnTuJianQueryResponse(msg)
	if #msg.tujian ~= 0 then
		-- print("图鉴ID:",msg.tujian[2].id)
		self:RefreshCollectionNode(msg.tujian)
	self.CollectionScrollNode:UpdateScrollContent(self.CollectionPoolDict:Count(),self.CollectionPoolDict)
	end
	if #msg.tuJianPoint ~= 0 then
		local tables = self:GetAwardNodeTables()
		print("刷新奖励",msg.tuJianAwardNum)
		self:RefreshAwardNode(tables,msg)
		self.AwardScrollNodeCls:UpdateScrollContent(self.AwardPoolDoct:Count(),self.AwardPoolDoct)
		self:SetPanel(msg)
	end
end

function AchievementCls:OnTuJianDrawResponse(msg)

end

function AchievementCls:OnChengjiuQueryResponse(msg)
	-- 成就网络回调
	self:SetAchievementData(msg)
	self:SetAchievementDataCallBack()
end

function AchievementCls:OnChengjiuDrawResponse(msg)

	self:UpdateAchievementData(self.AchievementSonIndex,msg.Chengjiu)
	self:SetAchievementDataCallBack()
	self:ShowAwardItem(msg.Chengjiu.id)
end


function AchievementCls:RedDotStateQuery()
	local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
	if RedDotData ~= nil then
		-- local achieve = RedDotData:GetModuleRedState(S2CGuideRedResult.chengjiu_tongyong)
		-- local collection = RedDotData:GetModuleRedState(S2CGuideRedResult.big_tujian)
		-- local award = RedDotData:GetModuleRedState(S2CGuideRedResult.big_jiangli)
		-- self.achieveRedDotImage:SetActive(achieve == 1)
		-- self.collectionRedDotImage:SetActive(collection == 1)
		-- self.awardRedDotImage:SetActive(award == 1)
		self.redDot = RedDotData:GetChengjiu()
		self:SetAchievementRedDot(self.redDot)
	end
end

--红点更新
function AchievementCls:RedDotStateUpdated(moduleId,moduleState)
	 local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
	 local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
	local redDot = RedDotData:GetChengjiu()
	local achieveState = {}
	local libraryDataCls = require "StaticData.Achievement.Achievement"
	self:GetDropDataDict(AchievementState)
	-- self:LoadAchievementContent()
	if redDot ~= nil then
		-- debug_print(#redDot)
		local count = #redDot
		-- debug_print(#self.achieveSonId)
		for i = 1,count do
			for j = 1,#self.achieveSonId do
				if redDot[i].sonid == self.achieveSonId[j] then
					local name = libraryDataCls:GetData(redDot[i].sonid):GetName()
					-- debug_print("aaaaaaaaaaaaaaaaaa"..name)
					achieveState[i] = {}
					achieveState[i].faName = self.faName[j]
					achieveState[i].sonid = self.achieveSonId[j]
					achieveState[i].name = name
					achieveState[i].red= redDot[i].red
				end
			end
		end
		-- debug_print(#achieveState)
		self.AchievementNodeCls:SetRedDotInfo(achieveState)
		-- if self.currPanelState == AchievementState then
			-- self:ShowAchievementPanel()
			-- self:SetAchievementRedDot(self.redDot)
		-- end
	end
	 -- if moduleId == S2CGuideRedResult.chengjiu_tongyong then
		-- self.achieveRedDotImage:SetActive(moduleState == 1)
	 -- elseif moduleId == S2CGuideRedResult.big_tujian then
		-- self.collectionRedDotImage:SetActive(moduleState == 1)
	 -- elseif moduleId == S2CGuideRedResult.big_jiangli then
		-- self.awardRedDotImage:SetActive(moduleState == 1)
	 -- end
end

----------------------------------------------------------------------
function AchievementCls:GetDropDataDict(state)
	-- 获取下拉菜单数据
	local dataDict = OrderedDictionary.New()

	-- 字典类静态数据
	local libraryDataCls = require "StaticData.Achievement.Achievement"

	local libraryKeys = libraryDataCls:GetKeys()
	local Length = libraryKeys.Length -1

	-- 获取父类
	local parentTable = {}
	for i = 0,Length do
		
		local temp = libraryKeys[i]
		temp = math.floor(temp / 100)
		if temp == state then
			parentTable[#parentTable + 1] = libraryKeys[i]
		end
	end
	self.achieveSonId = {}
	self.faName = {}
	-- 获取子类
	for i = 1 ,#parentTable do
		local sonDict = OrderedDictionary.New()
		local contrast = parentTable[i]
		for j = 0,Length do
			local key = libraryKeys[j]
			local temp = math.floor(key / 100)
			if contrast == temp then
				local name = libraryDataCls:GetData(key):GetName()
				sonDict:Add(key,name)
				if state == AchievementState then
					self.achieveSonId[#self.achieveSonId + 1] = key
					local parentName = libraryDataCls:GetData(parentTable[i]):GetName()
					self.faName[#self.faName + 1] = parentName
				end
			end
		end
		local parentName = libraryDataCls:GetData(parentTable[i]):GetName()
		dataDict:Add(parentName,sonDict)
	end
	return dataDict
end


-----------------------------------------------------------------------
---  成就
-----------------------------------------------------------------------
local function DelayWaitShow(self,dropNode)
	while (not self:IsReady()) do
    	coroutine.step(1)
   	end
   	dropNode:Show()

end

function AchievementCls:LoadAchievementContent()
	-- 加载成就

	-- local dataDict = OrderedDictionary.New()

	-- -- 字典类静态数据
	-- local libraryDataCls = require "StaticData.BigLibrary.BigLibrary"

	-- local libraryKeys = libraryDataCls:GetKeys()
	-- local Length = libraryKeys.Length -1

	-- -- 获取父类
	-- local parentTable = {}
	-- for i = 0,Length do
		
	-- 	local temp = libraryKeys[i]
	-- 	temp = math.floor(temp / 100)
	-- 	if temp == AchievementState then
	-- 		parentTable[#parentTable + 1] = libraryKeys[i]
	-- 	end
	-- end

	-- -- 获取子类
	-- for i = 1 ,#parentTable do
	-- 	local sonDict = OrderedDictionary.New()
	-- 	local contrast = parentTable[i]

	-- 	for j = 0,Length do
	-- 		local key = libraryKeys[j]
	-- 		local temp = math.floor(key / 100)
	-- 		if contrast == temp then
	-- 			local name = libraryDataCls:GetData(key):GetName()
	-- 			sonDict:Add(key,name)
	-- 		end
	-- 	end
	
	-- 	local parentName = libraryDataCls:GetData(parentTable[i]):GetName()
	-- 	dataDict:Add(parentName,sonDict)
	-- end
	local dataDict = self:GetDropDataDict(AchievementState)
	local achieveState = {}
	local libraryDataCls = require "StaticData.Achievement.Achievement"
	if self.redDot ~= nil then
		for i = 1,#self.redDot do
			for j = 1,#self.achieveSonId do
				if self.redDot[i].sonid == self.achieveSonId[j] then
					local name = libraryDataCls:GetData(self.redDot[i].sonid):GetName()
					achieveState[i] = {}
					achieveState[i].faName = self.faName[j]
					achieveState[i].sonid = self.achieveSonId[j]
					achieveState[i].name = name
					achieveState[i].red= self.redDot[i].red
					-- debug_print("红点red："..self.redDot[i].red)
				end
			end
		end
	end
	self.AchievementNodeCls = require "GUI.Dropdown.DropdownCtrl".New(self.Point,dataDict,achieveState)
	self.AchievementNodeCls:SetCallback(self,self.OnAchievementToggleValueChanged)
	self.AchievementScrollNode = require "GUI.Achievement.AchievementScorllNodeCls".New(self.AchievementScrollNodePoint,self,self.OnAchievementItemClicked)
	-- debug_print("成就"..dataDict:Count())
end

function AchievementCls:SetAchievementRedDot(redDot)
	-- self.AchievementNodeCls:SetRedDot(redDot)
end

function AchievementCls:OnAchievementItemClicked(id,key)
	local numberId = tonumber(id)
	self:OnChengjiuDrawRequest(numberId,key)
end


function AchievementCls:ShowAchievementPanel()
	-- 成就激活
	-- debug_print("加载成就")
	self:AddChild(self.AchievementNodeCls)
	-- coroutine.start(DelayWaitShow,self,self.AchievementNodeCls)
	self:StartCoroutine(DelayWaitShow, self.AchievementNodeCls)
	self:AddChild(self.AchievementScrollNode)
end

function AchievementCls:FillAchievementPanelData(id,labelId)
	-- 设置成就数据
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.PlayerAchievementData)

	if data ~= nil then
		-- 数据不为空
		
		local dataDict = data:GetData(labelId)

		if dataDict == nil or dataDict:Count() then
			-- 指定数据为空
			self:OnChengjiuQueryRequest(id,labelId)
		else
			local count = dataDict:Count()
			
			local dict = dataDict:GetItemDict()
			self.AchievementScrollNode:UpdateScrollContent(count,dataDict)
			self.AchievementScrollNode:ResetVerticalOffset(1)
		end

	end

end

function AchievementCls:SetAchievementData(msg)
	local UserDataType = require "Framework.UserDataType"
	local dataCacheMgr = self.myGame:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.PlayerAchievementData, function(oldData)

        require "Data.Achievement.PlayerAchievement"
        if oldData == nil then        
            oldData = PlayerAchievemenData.New()
        end

        oldData:SetAllData(msg)

        return oldData
    end)

end

function AchievementCls:SetAchievementDataCallBack()
	local UserDataType = require "Framework.UserDataType"
	local playerData = self:GetCachedData(UserDataType.PlayerAchievementData)
	
	local data = playerData:GetData(self.AchievementSonIndex)

	local count = data:Count()
	local dataDict = data:GetItemDict()
	self.AchievementScrollNode:UpdateScrollContent(count,dataDict)
	--self.AchievementScrollNode:ResetVerticalOffset(1)
end

function AchievementCls:UpdateAchievementData(typeId,data)
	local UserDataType = require "Framework.UserDataType"
	local playerData = self:GetCachedData(UserDataType.PlayerAchievementData)
	
	if playerData ~= nil then
		playerData:UpdateData(typeId,data)
	end
end

function AchievementCls:ClearAchievementData()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.PlayerAchievementData)

	if data ~= nil then
		data:Clear()
	end
end

function AchievementCls:HideAchievementPanel()
	-- 成就hide
	self.AchievementSonIndex = nil
	self:ClearAchievementData()
	self.AchievementNodeCls:Hide()
	self:RemoveChild(self.AchievementNodeCls,true)
	self:RemoveChild(self.AchievementScrollNode,true)
end

function AchievementCls:OnAchievementToggleValueChanged(index)
	-- 成就子标签回调
	print("成就子标签回调 **********",index)
	if self.AchievementSonIndex == nil then
		self:OnChengjiuQueryRequest(index,index)
	else
		self:FillAchievementPanelData(index,index)
		self.AchievementScrollNode:ResetVerticalOffset(1)
	end
	self.AchievementSonIndex = index
end

function AchievementCls:ShowAwardItem(awardId)
	-- 获得奖励
	local staticData = require "StaticData.Achievement.AchievementInfo":GetData(awardId)
	local gametool = require "Utils.GameTools"

	local id = staticData:GetItemID_1()
	local count = staticData:GetItemNum_1()
	local _,data,_,_,itype = gametool.GetItemDataById(id)
	local color = gametool.GetItemColorByType(itype,data)

	local item = {}
	item.id = id
	item.count = count
	item.color = color

	local items = {}
	items[1] = item

	local windowManager = self:GetGame():GetWindowManager()
  	local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,items)

end

function AchievementCls:OnTitleButtonClicked()
	-- 标题按钮点击事件

	local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
end

return AchievementCls