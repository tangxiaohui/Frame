local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local messageGuids = require "Framework.Business.MessageGuids"


--- 页签状态

local CollectionState  = 1  -- 卡牌

local EquipState = 2 --装备
-- local AchievementState = 2  -- 成就
local StrategyState    = 3  -- 攻略
local StotyState       = 4  -- 故事
local AwardState       = 5  -- 奖励

-- 父标签索引
local parentLabelIndex = 2
-- 子标签索引
local sonLabelIndex = 3 

-- button 选中颜色
local ButtonSelectedImageColor = UnityEngine.Color(1,1,1,1)
local ButtonNormalImageColor = UnityEngine.Color(0.537254,0.537254,0.537254,1)

---------------------------------------------
local BiglibraryCls = Class(BaseNodeClass)

function BiglibraryCls:Ctor()

end


function BiglibraryCls:OnInit()
	-- 加载界面(只走一次)

	utility.LoadNewGameObjectAsync('UI/Prefabs/BigLibrary', function(go)
		self:BindComponent(go)
	end)
end

function BiglibraryCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	--self:LinkComponent(self.parent)
	--self:LinkComponent(self.parent)
	self:InitControls()
end

function BiglibraryCls:OnResume()
	-- 界面显示时调用
	BiglibraryCls.base.OnResume(self)
	require "Utils.GameAnalysisUtils".EnterScene("图鉴界面")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_BigLibraryView)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	--self:RefreshContentPanel()
	self:RedDotStateQuery()
	self:LoadCotent()
	self:InitContent()
	self:RegisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function BiglibraryCls:OnPause()
	-- 界面隐藏时调用
	BiglibraryCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function BiglibraryCls:OnEnter()
	-- Node Enter时调用
	BiglibraryCls.base.OnEnter(self)
end

function BiglibraryCls:OnExit()
	-- Node Exit时调用
	BiglibraryCls.base.OnExit(self)
end

function BiglibraryCls:InitControls()
	local transform = self:GetUnityTransform()
	-- 垂直布局
	self.Point = transform:Find('Content/Viewport/Point')
	
	-- 退出按钮
	self.titleButton = transform:Find('BigLibraryReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))	

	-- 图鉴按钮
	self.CollectionButton = transform:Find('FeaturesBookmark/BigLibraryCollectionButton'):GetComponent(typeof(UnityEngine.UI.Button))	

	-- 成就按钮
	self.AchievementButton = transform:Find('FeaturesBookmark/BigLibraryAchievementButton'):GetComponent(typeof(UnityEngine.UI.Button))	

	-- 攻略按钮
	self.StrategyButton = transform:Find('FeaturesBookmark/BigLibraryStrategyButton'):GetComponent(typeof(UnityEngine.UI.Button))	

	-- 故事按钮
	self.StotyButton = transform:Find('FeaturesBookmark/BigLibraryStoryButton'):GetComponent(typeof(UnityEngine.UI.Button))	

	-- 奖励按钮
	self.AwardButton = transform:Find('FeaturesBookmark/BigLibraryAwardButton'):GetComponent(typeof(UnityEngine.UI.Button))	
	-- 流派按钮
	self.CombiButton = transform:Find('CombiButton'):GetComponent(typeof(UnityEngine.UI.Button))	

	--奖励界面
	self.awardPanel = transform:Find('AwardShow')
	self.awardCollection = transform:Find('CollectionPoint')
	self.awardNextPoint = self.awardCollection:Find('CollectionPointLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.awardPoint = self.awardPanel:Find('Scroll View')
	self.awardFill = self.awardCollection:Find("BarBase/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	--称号
	self.awardInfo = self.awardCollection:Find('TitleNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.base = self.awardCollection:Find('Base')
	--图鉴比例
	self.collectionPoint = self.base:Find('Label (2)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.collectionPointFill = self.base:Find('Fill (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	--奖励比例
	self.awardPointText = self.base:Find('Label (4)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.awardPointFill = self.base:Find('Fill (3)'):GetComponent(typeof(UnityEngine.UI.Image))
	--成就比例
	-- self.achievementPointText = self.base:Find('Label (1)'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.achievementPointFill = self.base:Find('Fill'):GetComponent(typeof(UnityEngine.UI.Image))
	--故事比例
	self.storyPointText = self.base:Find('Label (3)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.storyPointFill = self.base:Find('Fill (2)'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 成就挂点
	self.AchievementScrollNodePoint = transform:Find('Species/Layout')

	self.myGame = utility:GetGame()
	
	--红点
	self.achieveRedDotImage = self.AchievementButton.transform:Find('RedDotImage').gameObject
	self.collectionRedDotImage = self.CollectionButton.transform:Find('RedDotImage').gameObject
	self.awardRedDotImage = self.AwardButton.transform:Find('RedDotImage').gameObject

	-- 滑动content挂点
	self.scrollContent = transform:Find('Scroll View/Viewport/Content')
	self.collectionItemPoint = transform:Find('Collection/Viewport/Point')
	self.collectionItem = transform:Find('Collection').gameObject
	self.scrollViewRect = transform:Find('Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))	
	-- 攻略子对象 池子
	self.StrategyPoolDict = OrderedDictionary.New() 
	--图鉴子对象
	self.CollectionPoolDict = OrderedDictionary.New() 
	--奖励子对象
	self.AwardPoolDoct = OrderedDictionary.New()
end

function BiglibraryCls:LoadCotent()
	-- self:LoadEquipContent()
	self:LoadStrategyStateContent()
	-- self:LoadCollectionContent()
	self:LoadAwardContent()
end

function BiglibraryCls:InitContent()
	self:StateChangeCtrl(CollectionState)
end


function BiglibraryCls:RegisterControlEvents()

	-- 注册 退出事件
    self.__event_button_onTitleButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTitleButtonClicked, self)
    self.titleButton.onClick:AddListener(self.__event_button_onTitleButtonClicked__)

    -- 注册 图鉴按钮事件
    self.__event_button_onCollectionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCollectionButtonClicked, self)
    self.CollectionButton.onClick:AddListener(self.__event_button_onCollectionButtonClicked__)

    -- 注册 成就按钮事件
    self.__event_button_onAchievementButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAchievementButtonClicked, self)
    self.AchievementButton.onClick:AddListener(self.__event_button_onAchievementButtonClicked__)

    -- 注册 攻略按钮事件
    self.__event_button_onStrategyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnStrategyButtonClicked, self)
    self.StrategyButton.onClick:AddListener(self.__event_button_onStrategyButtonClicked__)

    -- 注册 故事按钮事件
    self.__event_button_onStotyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnStotyButtonClicked, self)
    self.StotyButton.onClick:AddListener(self.__event_button_onStotyButtonClicked__)

    -- 注册 奖励按钮事件
    self.__event_button_onAwardButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAwardButtonClicked, self)
    self.AwardButton.onClick:AddListener(self.__event_button_onAwardButtonClicked__)  
      -- 注册
    self.__event_button_onCombiButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCombiButtonClicked, self)
    self.CombiButton.onClick:AddListener(self.__event_button_onCombiButtonClicked__)

end

function BiglibraryCls:UnregisterControlEvents()

		-- 取消注册 流派
	 if self.__event_button_onCombiButtonClicked__ then
        self.CombiButton.onClick:RemoveListener(self.__event_button_onCombiButtonClicked__)
        self.__event_button_onCombiButtonClicked__ = nil
    end
	
	-- 取消注册 退出事件
	 if self.__event_button_onTitleButtonClicked__ then
        self.titleButton.onClick:RemoveListener(self.__event_button_onTitleButtonClicked__)
        self.__event_button_onTitleButtonClicked__ = nil
    end

    -- 取消注册 图鉴按钮事件
	 if self.__event_button_onCollectionButtonClicked__ then
        self.CollectionButton.onClick:RemoveListener(self.__event_button_onCollectionButtonClicked__)
        self.__event_button_onCollectionButtonClicked__ = nil
    end

    -- 取消注册 成就按钮事件
	 if self.__event_button_onAchievementButtonClicked__ then
        self.AchievementButton.onClick:RemoveListener(self.__event_button_onAchievementButtonClicked__)
        self.__event_button_onAchievementButtonClicked__ = nil
    end

    -- 取消注册 攻略按钮事件
	 if self.__event_button_onStrategyButtonClicked__ then
        self.StrategyButton.onClick:RemoveListener(self.__event_button_onStrategyButtonClicked__)
        self.__event_button_onStrategyButtonClicked__ = nil
    end

    -- 取消注册 故事按钮事件
	 if self.__event_button_onStotyButtonClicked__ then
        self.StotyButton.onClick:RemoveListener(self.__event_button_onStotyButtonClicked__)
        self.__event_button_onStotyButtonClicked__ = nil
    end

    -- 取消注册 奖励按钮事件
	 if self.__event_button_onAwardButtonClicked__ then
        self.AwardButton.onClick:RemoveListener(self.__event_button_onAwardButtonClicked__)
        self.__event_button_onAwardButtonClicked__ = nil
    end

end


function BiglibraryCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CChengjiuQueryResult, self, self.OnChengjiuQueryResponse)
	self.myGame:RegisterMsgHandler(net.S2CChengjiuDrawResult, self, self.OnChengjiuDrawResponse)
	self.myGame:RegisterMsgHandler(net.TuJianQueryResultMessage,self, self.OnTuJianQueryResponse)
	self.myGame:RegisterMsgHandler(net.TuJianDrawResultMessage,self, self.OnTuJianDrawResponse)
end

function BiglibraryCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CChengjiuQueryResult, self, self.OnChengjiuQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CChengjiuDrawResult, self, self.OnChengjiuDrawResponse)
	self.myGame:UnRegisterMsgHandler(net.TuJianQueryResultMessage,self, self.OnTuJianQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.TuJianDrawResultMessage,self, self.OnTuJianDrawResponse)
end
---------------------------------------------------------------------
function BiglibraryCls:OnChengjiuDrawRequest(cid,key)
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChengjiuDrawRequest(cid,key))
end

function BiglibraryCls:OnChengjiuQueryRequest(sonid,typeId)
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChengjiuQueryRequest(sonid,typeId))
end

function BiglibraryCls:OnTuJianQueryRequest(sonid,typeId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".TuJianQueryRequest(sonid,typeId))
end

function BiglibraryCls:OnTuJianDrawRequest(oid,typeId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".TuJianDrawRequest(oid,typeId))
end

function BiglibraryCls:OnCombiButtonClicked()

	   local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.CombiStyle.CombiStyle")

end

function BiglibraryCls:OnTuJianQueryResponse(msg)
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

function BiglibraryCls:OnTuJianDrawResponse(msg)

end

function BiglibraryCls:OnChengjiuQueryResponse(msg)
	-- 成就网络回调
	self:SetAchievementData(msg)
	self:SetAchievementDataCallBack()
end

function BiglibraryCls:OnChengjiuDrawResponse(msg)

	self:UpdateAchievementData(self.AchievementSonIndex,msg.Chengjiu)
	self:SetAchievementDataCallBack()
	self:ShowAwardItem(msg.Chengjiu.id)
end


function BiglibraryCls:RedDotStateQuery()
	local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
	if RedDotData ~= nil then
		local award = RedDotData:GetModuleRedState(S2CGuideRedResult.big_jiangli)
		self.awardRedDotImage:SetActive(award == 1)
		
		self.cardRed = RedDotData:GetCollectionCardInfo()
		for i=1,#self.cardRed do
			if self.cardRed[i].red == 1 then
				self.collectionRedDotImage:SetActive(true)
				break
			else
				self.collectionRedDotImage:SetActive(false)
			end
		end
		self.equipRed = RedDotData:GetCollectionEquipInfo()
		for i=1,#self.equipRed do
			if self.equipRed[i].red == 1 then
				self.achieveRedDotImage:SetActive(true)
				break
			else
				self.achieveRedDotImage:SetActive(false)
			end
		end
	end
end

--红点更新
function BiglibraryCls:RedDotStateUpdated(moduleId,moduleState)
	local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
	local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
	local cardRed = RedDotData:GetCollectionCardInfo()
	local equipRed = RedDotData:GetCollectionEquipInfo()
	local achieveState = {}
	local libraryDataCls = require "StaticData.BigLibrary.BigLibrary"
	-- self:GetDropDataDict(AchievementState)
	-- self:LoadAchievementContent()
	-- for i=1,#self.cardRed do
	-- 	-- debug_print(self.cardRed[i].sonid.."   红点更新状态   "..self.cardRed[i].red)
	-- end
	
	if cardRed ~= nil then
		self.cardRed = cardRed
	end
	if equipRed ~= nil then
		self.equipRed = equipRed
	end
	if self.currPanelState == CollectionState then
		local count = #self.node
		for j=1,#self.cardRed  do
			for i=1,count do
				if self.cardRed[j].sonid == self.node[i].id then
					self.node[i]:SetRedDot(self.cardRed[j].red)
					break
				end
			end
		end
	elseif self.currPanelState == EquipState then
		local count = #self.node
		for j=1,#self.equipRed  do
			for i=1,count do
				if self.equipRed[j].sonid == self.node[i].id then
					self.node[i]:SetRedDot(self.equipRed[j].red)
					break
				end
			end
		end
	end
	 if moduleId == S2CGuideRedResult.big_jiangli then
		self.awardRedDotImage:SetActive(moduleState == 1)
	 end
	 for i=1,#self.cardRed do
		if self.cardRed[i].red == 1 then
			self.collectionRedDotImage:SetActive(true)
			break
		else
			self.collectionRedDotImage:SetActive(false)
		end
	end
	for i=1,#self.equipRed do
		if self.equipRed[i].red == 1 then
			self.achieveRedDotImage:SetActive(true)
			break
		else
			self.achieveRedDotImage:SetActive(false)
		end
	end
end

----------------------------------------------------------------------
function BiglibraryCls:GetDropDataDict(state)
	-- 获取下拉菜单数据
	local dataDict = OrderedDictionary.New()

	-- 字典类静态数据
	local libraryDataCls = require "StaticData.BigLibrary.BigLibrary"

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

function BiglibraryCls:LoadAchievementContent()
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
	local libraryDataCls = require "StaticData.BigLibrary.BigLibrary"
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
end

function BiglibraryCls:SetAchievementRedDot(redDot)
	-- self.AchievementNodeCls:SetRedDot(redDot)
end

function BiglibraryCls:OnAchievementItemClicked(id,key)
	local numberId = tonumber(id)
	self:OnChengjiuDrawRequest(numberId,key)
end


function BiglibraryCls:ShowAchievementPanel()
	-- 成就激活
	self:AddChild(self.AchievementNodeCls)
	-- coroutine.start(DelayWaitShow,self,self.AchievementNodeCls)
	self:StartCoroutine(DelayWaitShow,self.AchievementNodeCls)
	self:AddChild(self.AchievementScrollNode)
end

function BiglibraryCls:FillAchievementPanelData(id,labelId)
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

function BiglibraryCls:SetAchievementData(msg)
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

function BiglibraryCls:SetAchievementDataCallBack()
	local UserDataType = require "Framework.UserDataType"
	local playerData = self:GetCachedData(UserDataType.PlayerAchievementData)
	
	local data = playerData:GetData(self.AchievementSonIndex)

	local count = data:Count()
	local dataDict = data:GetItemDict()
	self.AchievementScrollNode:UpdateScrollContent(count,dataDict)
	--self.AchievementScrollNode:ResetVerticalOffset(1)
end

function BiglibraryCls:UpdateAchievementData(typeId,data)
	local UserDataType = require "Framework.UserDataType"
	local playerData = self:GetCachedData(UserDataType.PlayerAchievementData)
	
	if playerData ~= nil then
		playerData:UpdateData(typeId,data)
	end
end

function BiglibraryCls:ClearAchievementData()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.PlayerAchievementData)

	if data ~= nil then
		data:Clear()
	end
end

function BiglibraryCls:HideAchievementPanel()
	-- 成就hide
	self.AchievementSonIndex = nil
	self:ClearAchievementData()
	self.AchievementNodeCls:Hide()
	self:RemoveChild(self.AchievementNodeCls,true)
	self:RemoveChild(self.AchievementScrollNode,true)
end

function BiglibraryCls:OnAchievementToggleValueChanged(index)
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

function BiglibraryCls:ShowAwardItem(awardId)
	-- 获得奖励
	local staticData = require "StaticData.BigLibrary.BigLibraryAchievement":GetData(awardId)
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


-----------------------------------------------------------------
---  图鉴卡牌、装备
-----------------------------------------------------------------
--设置红点信息
function BiglibraryCls:SetRedInfo(redState,id)
	local red = 2
	if redState ~= nil then
		local count = #redState
		for j=1,count do
			if redState[j].sonid == id then
				red = redState[j].red
				break
			else
				red = 2
			end
		end
	else
		red = 2
	end
	return red
end

function BiglibraryCls:LoadCollectionContent()
	--加载卡牌
	self:GetCollectionItem(CollectionState)
	self.CollectionScrollNode = require "GUI.Collection.CollectionScrollNode".New(self.AchievementScrollNodePoint,self)
end

--加载装备
function BiglibraryCls:LoadEquipContent()
	self:GetCollectionItem(EquipState)
	self.CollectionScrollNode = require "GUI.Collection.CollectionScrollNode".New(self.AchievementScrollNodePoint,self)
end

function BiglibraryCls:GetCollectionItem(state)
	local collectionData = require "StaticData.BigLibrary.BigLibraryCollection"
	local libraryDataCls = require "StaticData.BigLibrary.BigLibrary"

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

	local redState
	if state == EquipState then
		if self.equipRed ~= nil then
			redState = self.equipRed
		end
	elseif state == CollectionState then
		if self.cardRed ~= nil then
			redState = self.cardRed
		end
	end
	self.node = {}
	for i = 1,#parentTable do
		local red = self:SetRedInfo(redState,parentTable[i])
		CollectionStateNodeCls = require "GUI.Collection.CollectionButtonItem".New(self.collectionItemPoint,parentTable[i],i,red)
		self:AddChild(CollectionStateNodeCls)
		self.node[i] = CollectionStateNodeCls
		self.node[i]:SetCallback(self,self.OnCollectionStateToggleValueChanged)
	end	
	-- debug_print(parentTable[1])
	self.collectionIndex = parentTable[1] 
	self:OnTuJianQueryRequest(parentTable[1],parentTable[1])
end


function BiglibraryCls:IsInclude(value, tab)
    for k,v in pairs(tab) do
      if v == value then
          return true
      end
    end
    return false
end

function BiglibraryCls:OnCollectionStateToggleValueChanged(index,id)
	-- debug_print("index++++++++++++++++++++++",id)
	self:SetSelectState()
	self.node[index]:SelectButton(index)
	self.collectionIndex = id
	local scrollRect = self.AchievementScrollNodePoint:Find("ScrollContent"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	scrollRect.content.localPosition = Vector2.zero
	self:OnTuJianQueryRequest(id,id)
	-- local tables = self:GetCollectionNodeTables(index)
	-- self.CollectionPoolDict:Clear()
end

function BiglibraryCls:SetSelectState()
	for i=1,#self.node do
		self.node[i].clickeedObj.gameObject:SetActive(false)
	end
end

function BiglibraryCls:ShowCollectionStatePanel()
	-- 图鉴进入
	-- self:AddChild(self.CollectionStateNodeCls)
	-- coroutine.start(DelayWaitShow,self,self.CollectionStateNodeCls)
	-- self.node[1]:OnInfoButtonClicked()
	self.collectionItem.gameObject:SetActive(true)
	self:AddChild(self.CollectionScrollNode)
end

function BiglibraryCls:HideCollectionPanel()
	-- 图鉴退出
	self:RemoveChild(self.CollectionScrollNode,true)
	for i = 1,#self.node do 
		self:RemoveChild(self.node[i],true)
	end
	self.CollectionPoolDict:Clear()
end

function BiglibraryCls:GetCollectionNodeTables(index)
	-- 获得图鉴数据列表
	
	self.CollectionPoolDict:Clear()
	local tables = {}
	local DataCls = require "StaticData.BigLibrary.BigLibraryCollection"
	local keys = DataCls:GetKeys()
	
	local Length = keys.Length -1
	for i = 0, Length do
		local temp = keys[i]
		temp = math.floor(temp / 100)
		
		if temp == index then
			tables[#tables + 1] = keys[i]
		end
	end

	return tables
end

function BiglibraryCls:RefreshCollectionNode(tables)
	-- 刷新图鉴子物体
	self.currCollectionNodeTable = {}
	local idtables = self:GetCollectionNodeTables(self.collectionIndex)
	local data = require "StaticData.BigLibrary.BigLibraryCollection"
	local realTables = {}
	local node = {}
	-- local tables = msg.tujian
	-- print(#msg.tujian)
	local count = #idtables
	-- local nodeCls = require "GUI.Collection.CollectionItemNode"

	for i = 1,count do

		if not self.CollectionPoolDict:Contains(i) then
			-- node = tables[i]
			local collectiondata = data:GetData(idtables[i])
			if collectiondata:GetIsShow() == 1 then
				realTables[#realTables + 1] = idtables[i]
				
				-- self.CollectionPoolDict:Add(i,node)
			end
		end

	end
	if #realTables == #tables then
		for i=1,#tables do
			for j=1,#realTables do
				local param = data:GetData(realTables[j]):GetParam()
				if param == tables[i].id then
					node[i] = {}
					node[i].id = realTables[j]
					node[i].state = tables[i].state
					node[i].param = param
				end
			end
			
		end

	else
		error("server data error")
	end
	local color = {}
	local gametool = require "Utils.GameTools"
	for i=1,#node do
		local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(node[i].param)
		local itemColor = gametool.GetItemColorByType(itemType,data)
		node[i].color = itemColor
	end
	self:ColorSort(node)
	-- self:StateSort(node)
	for i=1,#node do
		self.CollectionPoolDict:Add(i,node[i])
	end
end

function BiglibraryCls:SetSortValue(data)
	if data == 1 then
		data = 2
	else
		data = 0
	end
	return data
end

function BiglibraryCls:StateSort(data)
	table.sort(data,function(a,b)
		return self:SetSortValue(a.state) > self:SetSortValue(b.state)	
		end)
end

function BiglibraryCls:ColorSort(data)
	
	table.sort(data,function(a,b)
		if self:SetSortValue(a.state) == self:SetSortValue(b.state) then
			return a.color < b.color
		else
			return self:SetSortValue(a.state) > self:SetSortValue(b.state)
		end
		end)
end

-- function BiglibraryCls:GetCollectionTables(id)
-- 	local tables = {}
-- 	local data = require "StaticData.BigLibrary.BigLibraryCollection"
-- 	local keys = DataCls:GetKeys()
	
-- 	local Length = keys.Length -1
-- 	for i = 0, Length do
-- 		tables[#tables+1] = keys[i]
-- 	end
-- 	for i=0,#id do
-- 		print(i)
-- 	end
-- end
-----------------------------------------------------------------
---  攻略
-----------------------------------------------------------------
function BiglibraryCls:LoadStrategyStateContent()
	-- 加载攻略下拉菜单
	local dataDict = self:GetDropDataDict(StrategyState)
	self.StrategyStateNodeCls = require "GUI.Dropdown.DropdownCtrl".New(self.Point,dataDict)
	self.StrategyStateNodeCls:SetCallback(self,self.OnStrategyStateToggleValueChanged)
end

function BiglibraryCls:OnStrategyStateToggleValueChanged(index)
	print("index",index)
	local tables = self:GetStrategyNodeTables(index)
	print(#tables,"长度")
	self:RefreshStrategyNode(tables)
	self.scrollViewRect.verticalNormalizedPosition = 1
end

function BiglibraryCls:ShowStrategyStatePanel()
	-- 攻略进入
	self.collectionItem.gameObject:SetActive(false)
	self:AddChild(self.StrategyStateNodeCls)
	-- coroutine.start(DelayWaitShow,self,self.StrategyStateNodeCls)
	self:StartCoroutine(DelayWaitShow,self.StrategyStateNodeCls)
end

function BiglibraryCls:HideStrategyPanel()
	-- 攻略退出
	for i = 1 , #self.currStrategyNodeTable do
		local node = self.currStrategyNodeTable[i]
		node:SetActive(false)
		self:RemoveChild(node)
	end

	self:RemoveChild(self.StrategyStateNodeCls,true)
	self.StrategyPoolDict:Clear()
end

function BiglibraryCls:GetStrategyNodeTables(index)
	-- 获得数据列表
	local tables = {}
	local DataCls = require "StaticData.BigLibrary.BigLibraryStrategy"
	local keys = DataCls:GetKeys()
	
	local Length = keys.Length -1
	for i = 0, Length do
		local temp = keys[i]
		temp = math.floor(temp / 100)
		
		if temp == index then
			tables[#tables + 1] = keys[i]
		end
	end

	return tables
end

function BiglibraryCls:RefreshStrategyNode(tables)
	-- 刷新攻略子物体
	self.currStrategyNodeTable = {}

	local count = #tables
	local nodeCls = require "GUI.Strategy.StrategyItemNode"

	for i = 1,count do
		
		local id = tables[i]
		local node
		if self.StrategyPoolDict:Contains(i) then
			node = self.StrategyPoolDict:GetEntryByKey(i)
			local active = node:GetActive()
			if not active then
				self:AddChild(node)
				node:SetActive(true)
			end
			node:RefreshItem(id)
		else
			node = nodeCls.New(self.scrollContent)
			self:AddChild(node)
			node:SetActive(true)
			node:RefreshItem(id)
			self.StrategyPoolDict:Add(i,node)
		end

		self.currStrategyNodeTable[#self.currStrategyNodeTable + 1] = node
	end

	local poolCount = self.StrategyPoolDict:Count()
	if poolCount > count then
		local Length = count + 1
		for j = poolCount , Length , -1 do
			local node = self.StrategyPoolDict:GetEntryByKey(j)
			self:RemoveChild(node)
			node:SetActive(false)
		end
	end
end

-----------------------------------------------------------------
---  奖励
-----------------------------------------------------------------
function BiglibraryCls:LoadAwardContent()
	--加载奖励
	-- local dataDict = self:GetDropDataDict(AwardState)
	self.AwardScrollNodeCls = require "GUI.Collection.CollectionAwardScrollNode".New(self.awardPoint,self)
end


function BiglibraryCls:ShowAwardPanel()
	-- 进入奖励
	self.AwardPoolDoct:Clear()
	self.currAwardNodeTable = {}
	self.awardPanel.gameObject:SetActive(true)
	self.awardCollection.gameObject:SetActive(true)
	--获取奖励数据
	self:AddChild(self.AwardScrollNodeCls)
	self:OnTuJianQueryRequest(0,0)
	-- self:SetPanel(0)
	-- coroutine.start(DelayWaitShow,self,self.AwardNodeCls)
	
end

function BiglibraryCls:HideAwardPanel()
	-- 奖励退出
	-- if #self.currAwardNodeTable ~= 0 then
	-- 	local tables = self:GetAwardNodeTables()
	-- 	for i = 1 , #self.currAwardNodeTable do
	-- 		local node = self.currAwardNodeTable[i]
	-- 		self:RemoveChild(node,true)
	-- 	end
	-- end
	self:RemoveChild(self.AwardScrollNodeCls,true)
	self.AwardPoolDoct:Clear()
end

function BiglibraryCls:GetAwardNodeTables()
	-- 获得奖励数据列表
	
	local tables = {}
	local DataCls = require "StaticData.BigLibrary.BigLibraryCollectionAward"
	local keys = DataCls:GetKeys()
	
	for i = 0, (keys.Length - 1) do
		tables[i+1] = keys[i]
	end

	return tables
end

function BiglibraryCls:RefreshAwardNode(tables,msg)
	-- 刷新奖励子物体
	-- local data = require "StaticData.BigLibrary.BiglibraryCollectionAward"
	-- self:HideAwardPanel()
	self.AwardPoolDoct:Clear()
	local count = #tables
	local nodeCls = require "GUI.Collection.CollectionAwardNode"
	local _,nextid = self:GetNextNeedPoint(msg.points)
	local tujian
	local node = {}
	if not self.CollectionPoolDict:Contains(i) then
		for i = 1,count do
			tuJianPoint = msg.tuJianPoint[i]
			local id = tables[i]
			node[i] = {}
			node[i].id = tables[i]
			node[i].tujian = tuJianPoint
			node[i].points = msg.points
			-- local node = nodeCls.New(self.awardPoint,tables[i],tuJianPoint)
			-- print(i)
			
			-- node:SetActive(true)
			self.currAwardNodeTable[#self.currAwardNodeTable + 1] = node
		end
	end
	for i=1,#node do
		if node[i].tujian.state == 0 then
			node[i].state = 1
		elseif node[i].tujian.state == 1 then
			node[i].state = 0
		elseif node[i].tujian.state == 2 then
			node[i].state = 2
		end
	end
		table.sort(node,function(a,b)
			if a.state == b.state then
				return a.id <b.id
			else
				return a.state < b.state
			end
		end)

	for i=1,#node do
		self.AwardPoolDoct:Add(i,node[i])
	end

end

--加载奖励界面
function BiglibraryCls:SetPanel(msg)
	local curPoint = msg.points
	local curCollectionNum = msg.tuJianNum
	local curAwardNum = msg.tuJianAwardNum
	local keys = require "StaticData.BigLibrary.BigLibraryCollection":GetKeys()
	local collectiondata = require "StaticData.BigLibrary.BigLibraryCollection":GetData(keys[0])
	local allPoint = collectiondata:GetAllCollection()
	self.collectionPointFill.fillAmount = curCollectionNum/allPoint
	self.collectionPoint.text = curCollectionNum.."/"..allPoint
	local nextPoint,_ = self:GetNextNeedPoint(msg.points)
	self.awardNextPoint.text = curPoint.."/"..nextPoint
	self.awardFill.fillAmount = curPoint/nextPoint
	self.awardInfo.text = self:GetTitle(msg.points)
	local awardAllPoint = require "StaticData.BigLibrary.BigLibraryCollectionAwardInfo":GetKeys()
	-- local awardcurPoint = msg.points
	self.awardPointText.text = curAwardNum.."/"..awardAllPoint.Length
	self.awardPointFill.fillAmount = curAwardNum/awardAllPoint.Length

	-- local achievementKeys = require "StaticData.Achievement.AchievementInfo":GetKeys()
	-- self.achievementPointText.text = msg.chengjiuPoints .."/"..achievementKeys.Length
	-- self.achievementPointFill.fillAmount = msg.chengjiuPoints/achievementKeys.Length
	--故事写了个假数据
	
	self.storyPointText.text = 0 .."/"..125
	self.storyPointFill.fillAmount = 0/125
end

--获得称号
function BiglibraryCls:GetTitle(point)
	local awardInfo = require "StaticData.BigLibrary.BigLibraryCollectionAwardInfo"
	local keys = awardInfo:GetKeys()
	local infotables = {}
	local nextPoint,id = self:GetNextNeedPoint(point)
	local name = nil
	for i = 0,(keys.Length - 1) do
		if keys[i] == id and i~=0 then
			local data = awardInfo:GetData(keys[i - 1])
			name = data:GetName()
			break
		end
	end
	if name == nil then
		local data = awardInfo:GetData(keys[0])
		name = data:GetName()
	end
	return name
end

function BiglibraryCls:GetAwardId()
	local awarddata = require "StaticData.BigLibrary.BigLibraryCollectionAward"
	local keys = awarddata:GetKeys()
	local tables = {}
	for i = 0,(keys.Length - 1) do
		local id = awarddata:GetData(keys[i]):GetID()
		tables[i + 1] = id
	end
	return tables
end

function BiglibraryCls:GetPoint()
	local awarddata = require "StaticData.BigLibrary.BigLibraryCollectionAward"
	local keys = awarddata:GetKeys()
	local tables = {}
	local idtables = {}
	for i = 0,(keys.Length - 1) do
		local point = awarddata:GetData(keys[i]):GetNeedPoint()
		tables[i + 1] = point
	end
	return tables
end

function BiglibraryCls:GetAllPoint()
	local tables = self:GetPoint()
	local allPoint = 0
	for i = 1, #tables do
		local data = tonumber(tables[i])
		allPoint = data + allPoint
	end
	return allPoint
end

--判断下一个可领取的奖励点
function BiglibraryCls:GetNextNeedPoint(curPoint)
	local tables = self:GetPoint()
	local nextPoint = nil
	local idtables = self:GetAwardId()
	local id = nil
	if #tables == #idtables then
		for i = 1,#tables do
			if tables[i] > curPoint then
				nextPoint,id = tables[i],idtables[i]
				break
			-- else
				-- return tables[#tables],idtables[#tables]
			end
		end
	end
	if nextPoint == nil then
		nextPoint,id = tables[#tables],idtables[#tables]
	end
	return nextPoint,id
end

function BiglibraryCls:HidePanel()
	self.awardPanel.gameObject:SetActive(false)
	self.awardCollection.gameObject:SetActive(false)
end
-----------------------------------------------------------------
function BiglibraryCls:StateChangeCtrl(state)
	-- 状态切换
	if self.currPanelState == state then		
		return 
	end

	if self.currPanelState ~= nil then
		self:OnPanelStateExit(self.currPanelState)
	end

	self:OnPanelStateEnter(state)

end


function BiglibraryCls:OnPanelStateEnter(state)
	-- 状态进入
	self:HidePanel()
	if state == CollectionState then
		-- print("图鉴进入")
		self:ChangeButtonTheme(self.CollectionButton)
		self:LoadCollectionContent()
		self:ShowCollectionStatePanel()
	-- elseif state == AchievementState then
		-- print("成就进入")
		-- self:ChangeButtonTheme(self.AchievementButton)
		-- self:ShowAchievementPanel()
	elseif state == StrategyState then
		-- print("攻略进入") 
		self:ChangeButtonTheme(self.StrategyButton)
		self:ShowStrategyStatePanel()
	elseif state == StotyState then
		-- print("故事进入")
		self:ChangeButtonTheme(self.StotyButton)
	elseif state == AwardState then
		-- print("奖励进入")
		self:ChangeButtonTheme(self.AwardButton)
		self:ShowAwardPanel()
	elseif state == EquipState then
		-- debug_print("装备进入")
		self:ChangeButtonTheme(self.AchievementButton)
		self:LoadEquipContent()
		self:ShowCollectionStatePanel()
	end

	self.currPanelState = state
end

function BiglibraryCls:OnPanelStateExit(state)
	-- 状态退出

	if state == CollectionState or state == EquipState then
		-- print("图鉴退出")
		self:HideCollectionPanel()
	elseif state == AchievementState then
		-- print("成就退出")
		self:HideAchievementPanel()
	elseif state == StrategyState then
		-- print("攻略退出")
		self:HideStrategyPanel()
	elseif state == StotyState then

		-- print("故事退出")
	elseif state == AwardState then
		-- print("奖励退出")
		self:HideAwardPanel()
	end

	self.currPanelState = nil

end
------------------------------------------------------------------

function BiglibraryCls:OnTitleButtonClicked()
	-- 标题按钮点击事件

	local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
end

function BiglibraryCls:OnCollectionButtonClicked()
	-- 图鉴 事件
	self:StateChangeCtrl(CollectionState)
end

function BiglibraryCls:OnAchievementButtonClicked()
	-- 成就 事件
	self:StateChangeCtrl(EquipState)
end

function BiglibraryCls:OnStrategyButtonClicked()
	-- 攻略 事件
	self:StateChangeCtrl(StrategyState)

end

function BiglibraryCls:OnStotyButtonClicked()
	-- 故事 事件
	self:StateChangeCtrl(StotyState)
end

function BiglibraryCls:OnAwardButtonClicked()
	-- 奖励 事件
	self:StateChangeCtrl(AwardState)
end



local function ChangePosition(object,offset)
	-- 改变组件位置
	local tempPosition = object.transform.localPosition
	tempPosition.x = tempPosition.x + offset
	object.transform.localPosition = tempPosition
end

local function SetLabelTheme(label,OnShow)
	--设置文字样式
	local outLine = label:GetComponent(typeof(UnityEngine.UI.Outline))
	if OnShow then
		label.fontSize = 55
		label.color = UnityEngine.Color(1,1,1,1)
		outLine.enabled = true
	else
		label.fontSize = 39
		label.color = UnityEngine.Color(0,0,0,1)
		outLine.enabled = false
	end
end 

function BiglibraryCls:ChangeButtonTheme(targetButton)
	-- 更改button按钮选中主题
	local gameTool = require "Utils.GameTools"
	
	local buttonImage = targetButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	buttonImage.color = ButtonSelectedImageColor
	ChangePosition(targetButton,-30)
	local textLabel = targetButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	SetLabelTheme(textLabel,true)

	if self.OnSelectButton ~= nil then
		local onSelectButtonImage = self.OnSelectButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
		onSelectButtonImage.color = ButtonNormalImageColor
		ChangePosition(self.OnSelectButton,30)
		local textLabel = self.OnSelectButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		SetLabelTheme(textLabel,false)
	end

	self.OnSelectButton = targetButton
end




return BiglibraryCls