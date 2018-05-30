local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
require "LUT.StringTable"

local SkinInfoCls = Class(BaseNodeClass)

local isChange = true
function SkinInfoCls:Ctor()
end

function SkinInfoCls:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/NewSkinInfo",function(go)
		self:BindComponent(go)
	end)
end

function SkinInfoCls:OnWillShow(id)
	self.id = id
	local data = require "StaticData.CardSkin.Cardskin":GetData(id)
	self.skinIdArray = data:GetSkinid()
	self.index = 0
end

function SkinInfoCls:OnComponentReady()
	self:InitControls()
	self:ScheduleUpdate(self.Update)
end

function SkinInfoCls:OnResume()
	SkinInfoCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:CardCorrCardSkinInfoQueryRequest(self.id)
	-- self:LoadBlongInfo(2001)
	-- self:LoadSkinItem()
end

function SkinInfoCls:OnPause()
	SkinInfoCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SkinInfoCls:OnEnter()
	SkinInfoCls.base.OnEnter(self)
end

function SkinInfoCls:OnExit()
	SkinInfoCls.base.OnExit(self)
end

function SkinInfoCls:Update()
	if not isChange then
		isChange = true
		self:LoadPanel(self.skinId)
	end
end

function SkinInfoCls:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end

--绑定控件
function SkinInfoCls:InitControls()
	local transform = self:GetUnityTransform()

	self.returnButton = transform:Find("ReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))
	--皮肤属性
	self.NormalInfo = transform:Find("NormalInfo")
	self.lifeStatusLabel = self.NormalInfo:Find("Status/Life/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.atkStatusLabel = self.NormalInfo:Find("Status/Atk/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.lvLabel = self.NormalInfo:Find("LvLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.lvFill = self.NormalInfo:Find("Bar/Frame/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	self.expLabel = self.NormalInfo:Find("Bar/EXPLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.levelButton = self.NormalInfo:Find("LevelButton"):GetComponent(typeof(UnityEngine.UI.Button))
	--羁绊加成
	self.KizunaInfo = transform:Find("KizunaInfo")
	self.headPoint = self.KizunaInfo:Find("Layout")
	--现有羁绊加成
	self.nowStatus = {}
	self.nowStatusIcon = {}
	self.nowStatusName = {}
	self.nowStatusNum = {}
	for i=1,2 do
		self.nowStatus[i] = transform:Find("KizunaInfo/Kizuna/NowKizuna/Status"..i)
		self.nowStatusIcon[i] = self.nowStatus[i]:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Image))
		self.nowStatusName[i] = self.nowStatus[i]:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
		self.nowStatusNum[i] = self.nowStatus[i]:Find("StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	end
	self.nowKizunaLevel = transform:Find("KizunaInfo/Kizuna/NowKizuna/KizunaLevel"):GetComponent(typeof(UnityEngine.UI.Text))
	--下次羁绊加成
	self.nextStatus = {}
	self.nextStatusName = {}
	self.nextStatusNum = {}
	for i=1,2 do
		self.nextStatus[i] = transform:Find("KizunaInfo/Kizuna/NextKizuna/Status"..i)
		self.nextStatusName[i] = self.nextStatus[i]:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
		self.nextStatusNum[i] = self.nextStatus[i]:Find("StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	end
	self.nextKizunaLevel = transform:Find("KizunaInfo/Kizuna/NextKizuna/KizunaLevel"):GetComponent(typeof(UnityEngine.UI.Text))
	--激活
	self.priceIcon = transform:Find("KizunaInfo/Price/CoinIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.priceNum = transform:Find("KizunaInfo/Price/PriceLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.priceButton = transform:Find("KizunaInfo/Price/ActiveButton"):GetComponent(typeof(UnityEngine.UI.Button))
	--皮肤父物体
	self.skinPoint = transform:Find("SlideArea/Scroll View/Viewport/Content")
	self.scrollView = transform:Find("SlideArea/Scroll View"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.setList = self.skinPoint:GetComponent(typeof(UnityEngine.UI.SetListData))
	--穿戴
	self.wearButton = transform:Find("WearButton"):GetComponent(typeof(UnityEngine.UI.Button))

	self.rightButton = transform:Find("SlideArea/RightButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.leftButton = transform:Find("SlideArea/LeftButton"):GetComponent(typeof(UnityEngine.UI.Button))

	--升级
	local LeftUpNodeClass = require "GUI.SkinSystem.SkinLevelUp"
	self.levelUpPanel = LeftUpNodeClass.New(transform:Find("LevelUpPanel"))
    self:AddChild(self.levelUpPanel)
end

function SkinInfoCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)

	self._event_button_onRightButtonClicked_ = UnityEngine.Events.UnityAction(self.OnRightButtonClicked,self)
	self.rightButton.onClick:AddListener(self._event_button_onRightButtonClicked_)
	
	self._event_button_onLeftButtonClicked_ = UnityEngine.Events.UnityAction(self.OnLeftButtonClicked,self)
	self.leftButton.onClick:AddListener(self._event_button_onLeftButtonClicked_)

	self._event_button_onPriceButtonClicked_ = UnityEngine.Events.UnityAction(self.OnPriceButtonClicked,self)
	self.priceButton.onClick:AddListener(self._event_button_onPriceButtonClicked_)

	self._event_button_onLevelButtonClicked_ = UnityEngine.Events.UnityAction(self.OnLevelButtonClicked,self)
	self.levelButton.onClick:AddListener(self._event_button_onLevelButtonClicked_)

	self._event_button_onWearButtonClicked_ = UnityEngine.Events.UnityAction(self.OnWearButtonClicked,self)
	self.wearButton.onClick:AddListener(self._event_button_onWearButtonClicked_)

	-- 注册 ScrollView 的事件
    self.__event_scrollrect_onScrollViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScrollViewValueChanged, self)
    self.scrollView.onValueChanged:AddListener(self.__event_scrollrect_onScrollViewValueChanged__)
end

function SkinInfoCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end

	if self._event_button_onRightButtonClicked_ then
		self.rightButton.onClick:RemoveListener(self._event_button_onRightButtonClicked_)
		self._event_button_onRightButtonClicked_ = nil
	end

	if self._event_button_onLeftButtonClicked_ then
		self.leftButton.onClick:RemoveListener(self._event_button_onLeftButtonClicked_)
		self._event_button_onLeftButtonClicked_ = nil
	end

	if self._event_button_onPriceButtonClicked_ then
		self.priceButton.onClick:RemoveListener(self._event_button_onPriceButtonClicked_)
		self._event_button_onPriceButtonClicked_ = nil
	end

	if self._event_button_onWearButtonClicked_ then
		self.wearButton.onClick:RemoveListener(self._event_button_onWearButtonClicked_)
		self._event_button_onWearButtonClicked_ = nil
	end
	
	 -- 取消注册 ScrollView 的事件
    if self.__event_scrollrect_onScrollViewValueChanged__ then
        self.scrollView.onValueChanged:RemoveListener(self.__event_scrollrect_onScrollViewValueChanged__)
        self.__event_scrollrect_onScrollViewValueChanged__ = nil
    end
end

function SkinInfoCls:RegisterNetworkEvents()
    self:GetGame():RegisterMsgHandler(net.S2CCardCorrCardSkinInfoQueryResult,self,self.CardCorrCardSkinInfoQueryResult)
    self:GetGame():RegisterMsgHandler(net.S2CCardCorrCardSkinInfoRefreshPushResult,self,self.CardCorrCardSkinInfoRefreshPushResult)
end

function SkinInfoCls:UnregisterNetworkEvents() 
    self:GetGame():UnRegisterMsgHandler(net.S2CCardCorrCardSkinInfoQueryResult, self, self.CardCorrCardSkinInfoQueryResult)
    self:GetGame():UnRegisterMsgHandler(net.S2CCardCorrCardSkinInfoRefreshPushResult,self,self.CardCorrCardSkinInfoRefreshPushResult)
end

function SkinInfoCls:CardCorrCardSkinInfoRefreshPushResult(msg)
	self.cardSkin = msg.cardSkin
	self:LoadPanel(msg.cardSkin.cardSkinId)
	for i=1,#self.skinCardItem do
		if self.skinCardItem[i]:GetSkinId() == msg.cardSkin.cardSkinId then
			self.skinCardItem[i]:ResetInfo(msg.cardSkin.cardSkinId,msg.cardSkin)
			break
		end
	end
	
end

function SkinInfoCls:CardCorrCardSkinInfoQueryResult(msg)
	for i=1,#msg.cardSkin do
		debug_print(#msg.cardSkin,i,"CardCorrCardSkinInfoQueryResult",msg.cardSkin[i].cardSkinId,msg.cardSkin[i].cardSkinLevel,msg.cardSkin[i].cardSkinExp,msg.cardSkin[i].cardSkinUID,msg.cardSkin[i].currSkinId,msg.cardSkin[i].currActPro)
	end
	self.cardSkin = msg.cardSkin
	local id
	self.wearId = msg.currSkinId
	if msg.currSkinId ~= 0 then
		id = msg.currSkinId
	for i=1,#self.skinIdArray do
		if msg.currSkinId == self.skinIdArray[i] then
			self.index = i
			break
		end
	end
	else
		self.index = 0
		id = self.skinIdArray[0]
	end
	self:Load(id)
end

function SkinInfoCls:CardCorrCardSkinInfoQueryRequest(id)
	debug_print("CardCorrCardSkinInfoQueryRequest",id)
	self:GetGame():SendNetworkMessage(require "Network/ServerService".CardCorrCardSkinInfoQueryRequest(id))
end

function SkinInfoCls:CardSkinPutOnRequest(uid,cardId)
	self:GetGame():SendNetworkMessage(require "Network/ServerService".CardSkinPutOnRequest(tostring(cardId),uid))
end

--羁绊id
function SkinInfoCls:CardSkinActivationRequest(id)
	self:GetGame():SendNetworkMessage(require "Network/ServerService".CardSkinActivationRequest(id))
end

function SkinInfoCls:OnReturnButtonClicked()
	self:Close(true)
end

function SkinInfoCls:OnRightButtonClicked()
	self.index = self.index + 1
	if self.index >= #self.skinIdArray then
		self.index = 0
	end
	self:LoadPanel(self.skinIdArray[self.index])
end


function SkinInfoCls:OnLeftButtonClicked()
	self.index = self.index - 1
	if self.index < 0 then
		self.index = #self.skinIdArray
	end
	self:LoadPanel(self.skinIdArray[self.index])
end

function SkinInfoCls:OnPriceButtonClicked()
	self:CardSkinActivationRequest(self.kizumaId)
end

function SkinInfoCls:OnLevelButtonClicked()
	self.levelUpPanel:SetLevelUpPanel()
end


function SkinInfoCls:OnWearButtonClicked()
	local data = self:GetData(self.skinInfoId)
	self:CardSkinPutOnRequest(data.cardSkinUID,self.id)
end



function SkinInfoCls:LoadSkinItem(curId)
	debug_print("LoadSkinItem",curId)
	local index = 0
	local count = #self.skinIdArray

	local data = {}


	for i=1,count do
		if self.skinIdArray[i] == curId then
			index = i
		end
	end

	data[#data+1]=self.skinIdArray[index]
	-- laocal itemData =self.skinIdArray[index]
	
	for i=1,count do
		if index == i then
			
		else
			data[#data+1]=self.skinIdArray[i]
		end
	end



	-- -- local data = self.setList:SetFirstList(self.skinIdArray,index)
	-- -- data=SortByIndex(self.skinIdArray,index)
	-- debug_print("*******************",index)



	if self.skinCardItem~=nil then
		self.skinCardItem[1]:ResetData(nil,nil)
		for i=1,#data do			
			self.skinCardItem[i+1]:ResetData(data[i],self.cardSkin)
		end
		self.skinCardItem[#self.skinCardItem]:ResetData(nil,nil)
		return
	end

	self.skinCardItem={}
	local childCls = require "GUI.SkinSystem.SkinCardItem".New(self.skinPoint,nil,nil)
	self:AddChild(childCls)
	self.skinCardItem[#self.skinCardItem + 1] = childCls

	for i=1,#data do
		debug_print("self.cardSkin",self.cardSkin)
		local childCls = require "GUI.SkinSystem.SkinCardItem".New(self.skinPoint,data[i],self.cardSkin)
		self:AddChild(childCls)
		self.skinCardItem[#self.skinCardItem + 1] = childCls
	end

	local childCls = require "GUI.SkinSystem.SkinCardItem".New(self.skinPoint,nil,nil)
	self:AddChild(childCls)
	self.skinCardItem[#self.skinCardItem + 1] = childCls

end

function SkinInfoCls:ChildClickedCallBack()
	
end

function SkinInfoCls:InitChildCallBack()
	
end

function SkinInfoCls:GetData(id)
	for i=1,#self.cardSkin do
		if id == self.cardSkin[i].cardSkinId then
			local data = self.cardSkin[i]
			return data
		end
	end
	return nil
end

function SkinInfoCls:Load(id)
	debug_print("Lod")
	self:LoadSkinItem(id)
	self:LoadPanel(id)
end


function SkinInfoCls:LoadPanel(id)
	if id ~= 0 then
		-- print_debug(id)
		if self.wearId == id then
			self.wearButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
			self.wearButton.enabled = false
		else
			self.wearButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetCommonMaterial()
			self.wearButton.enabled = true
		end
	local skinData = require "StaticData.CardSkin.Skin":GetData(id)
	self.lifeStatusLabel.text = skinData:GetHpLimitindex()
	self.atkStatusLabel.text = skinData:GetGongjiliindex()
	local data
	if #self.cardSkin ~= 0 then
		for i=1,#self.cardSkin do
			if id == self.cardSkin[i].cardSkinId then
				data = self.cardSkin[i]
				break
			end
		end
	else
		data = self.cardSkin
	end
	if data == nil then
		data = {}
		data.cardSkinLevel = 0
		data.cardSkinExp = 0
		data.currActPro = 0
		self.levelButton.enabled = false
		self.priceButton.enabled = false
		self.wearButton.enabled = false
	else
		self.levelButton.enabled = true
		self.priceButton.enabled = true
		self.wearButton.enabled = true
	end
	self.lvLabel.text = "Lv."..data.cardSkinLevel 
	local keys =  require "StaticData.CardSkin.SkinLevel":GetKeys()
	local levelData
	if data.cardSkinLevel < keys.Length then
		levelData = require "StaticData.CardSkin.SkinLevel":GetData(data.cardSkinLevel + 1)
	else
		levelData = require "StaticData.CardSkin.SkinLevel":GetData(keys[keys.Length - 1])
	end

	self.expLabel.text = data.cardSkinExp.."/"..levelData:GetExp()
	self.lvFill.fillAmount = data.cardSkinExp/levelData:GetExp()
	self.kizumaId = skinData:GetKizuna()
	self:LoadBlongInfo(self.kizumaId,data)
	self.levelUpPanel:GetSkinInfo(data)
	self.skinInfoId = id
	end
end

function SkinInfoCls:SetSkinId(id)
	isChange = false
	self.skinId = id
	self.skinInfoId = id
end

--羁绊
function SkinInfoCls:LoadBlongInfo(id,data)
	self:RemoveHeadItem()
	local skinData = require "StaticData.CardSkin.SkinKizuna":GetData(id)
	local idTable = skinData:GetKizuna()
	self.node = {}
	for i=0,idTable.Count - 1 do
		local item = require "GUI.SkinSystem.SkinIconItem".New(self.headPoint,idTable[i])
		self:AddChild(item)
		self.node[i + 1] = item
	end
	local statusId = skinData:GetStatusid()
	local statusValue = skinData:GetStatusrate()
	local index,nextIndex = self:GetIndex(data.currActPro)
	for i=0,statusId.Count - 1 do
		self.nowStatusName[i + 1].text = EquipStringTable[statusId[i]]
		self.nowStatusNum[i + 1].text = index*statusValue[i].."%"
		self.nextStatusName[i + 1].text = EquipStringTable[statusId[i]]
		self.nextStatusNum[i + 1].text = nextIndex*statusValue[i].."%"
	end
	self.nowKizunaLevel.text = index
	self.nextKizunaLevel.text = nextIndex
	self:SetPrice(index,idTable)
end

--激活
function SkinInfoCls:SetPrice(index,idTable)
	if index == 0 then
		self.priceButton.enabled = false
		index = 1
	end
	local infoList = {}
	for i=0,idTable.Count - 1 do
		infoList[i] = {}
		infoList[i] = self:GetData(idTable[i])
	end
	
	local levelData = require "StaticData.CardSkin.SkinKizunaLevelup":GetData(index)
	local gametool = require "Utils.GameTools"
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(levelData:GetNeedItem())
	utility.LoadSpriteFromPath(iconPath,self.priceIcon)
	self.priceNum.text = levelData:GetNeedNum()
	local levelList = levelData:GetLevelRank()
	if #infoList ~= 0 then
	for i=0,#infoList do
		if infoList[i].cardSkinLevel >= levelList[i] then
			self.priceButton.enabled = true
		else
			self.priceButton.enabled = false
		end
	end
	else
		self.priceButton.enabled = false
	end
end

function SkinInfoCls:GetIndex(id)
	local index,nextIndex
	if id == 0 then
		index = 0
		nextIndex = 1
	elseif id >= 3 then
		index = 3
		nextIndex = 3
	else
		index = id
		nextIndex = id + 1
	end
	return index,nextIndex
end

function SkinInfoCls:RemoveHeadItem()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
end

function SkinInfoCls:OnScrollViewValueChanged(posXY)
	local t = utility.Clamp01(posXY.x)
	local width = self.skinPoint.sizeDelta.x
	-- self.skinPoint.localPosition = Vector3(-500 +width*t ,0,0)
	-- print_debug(-500 +width*t)
	for i=1,#self.skinCardItem do
		self.skinCardItem[i]:SetItemSize(t,width)
	end
end

return SkinInfoCls