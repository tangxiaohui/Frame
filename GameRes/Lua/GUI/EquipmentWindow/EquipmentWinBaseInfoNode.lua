local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Const"
require "LUT.StringTable"
require "LUT.ArrayString"
require "Collection.OrderedDictionary"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local messageGuids = require "Framework.Business.MessageGuids"

--- @颜色连接
local colorStrRep = "<color=#%s> %s</color>"
local colorValueTable = {"9A9A9AFF","08E64BFF","2C93DEFF","BC4FEAFF","FFCA3EFF"}
-----------------------------------------------------------------------

local EquipmentWinBaseInfoNodeCls = Class(BaseNodeClass)

function EquipmentWinBaseInfoNodeCls:Ctor(parent,ctrlTakeoffWearingButton,ctrlChangewearingButton,ctrlReformButton)
	self.parent = parent
	-- 卸下
	self.ctrlTakeoffWearingButton = ctrlTakeoffWearingButton
	-- 换装
	self.ctrlChangewearingButton = ctrlChangewearingButton
	-- 重铸
	self.ctrlReformButton = ctrlReformButton
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipmentWinBaseInfoNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipmentBasicInfo', function(go)
		self:BindComponent(go,false)
	end)
end

function EquipmentWinBaseInfoNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent,true)
	self:InitControls()
	self:LoadSuitItem()
end

function EquipmentWinBaseInfoNodeCls:OnResume()
	-- 界面显示时调用
	EquipmentWinBaseInfoNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.ScrollRect.normalizedPosition = Vector2(1,1)
end

function EquipmentWinBaseInfoNodeCls:OnPause()
	-- 界面隐藏时调用
	EquipmentWinBaseInfoNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function EquipmentWinBaseInfoNodeCls:OnEnter()
	-- Node Enter时调用
	EquipmentWinBaseInfoNodeCls.base.OnEnter(self)
end

function EquipmentWinBaseInfoNodeCls:OnExit()
	-- Node Exit时调用
	EquipmentWinBaseInfoNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipmentWinBaseInfoNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	self.BaseScrollRect = transform:Find('Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	---  @装备信息

	local Element = transform:Find('Scroll View/Viewport/Content/Element')
	-- 装备头像
	self.itemIconImage = Element:Find('BasicInfo/ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 装备颜色
	self.itemColorFrame = Element:Find('BasicInfo/ItemBox/ColorFrame')
	-- 装备星级
	self.itemStarFrame = Element:Find('BasicInfo/ItemBox/EquipStarLayout')
	-- 装备名称
	self.itemNameLabel = Element:Find('BasicInfo/ItemNameBase/InfoItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 装备小图标
	self.itemTypeIconImage = Element:Find('BasicInfo/ItemNameBase/InfoItemTypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 套装标签
	self.suitFlag = Element:Find('BasicInfo/ItemBox/Flag').gameObject
	-- 描述信息
	self.itemInfoLabel = Element:Find('BasicInfo/EquipINfoTextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 绑定obj
	self.RoleBindingObj = Element:Find('BasicInfo/ItemBindingObj').gameObject
	-- 绑定按钮
	self.RoleBingdingButton = Element:Find('BasicInfo/ItemBindingObj/BindingButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 绑定角色
	self.RoleBindingLabel =  Element:Find('BasicInfo/ItemBindingObj/NameBase/CardNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 装备等级
	self.itemLvLabel = Element:Find('BasicInfo/ItemBox/BackpackEquipLevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 等级LV 字
	self.itemLvFont =  Element:Find('BasicInfo/ItemBox/Lv'):GetComponent(typeof(UnityEngine.UI.Image))

	--- @套装
	self.suitPointTrans = Element:Find('BasicInfo/SuitBase/Layout')
	self.suitObj = Element:Find('BasicInfo/SuitBase/SuitInfo').gameObject
	self.suitNoticeLabel = Element:Find('BasicInfo/SuitBase/Notice'):GetComponent(typeof(UnityEngine.UI.Text))
	self.suitNameLabel = Element:Find('BasicInfo/SuitBase/SuitInfo/SuitNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.suitInfoLabel = Element:Find('BasicInfo/SuitBase/SuitInfo/NumOfSuitInfor'):GetComponent(typeof(UnityEngine.UI.Text))

	--- @ 滑动条
	self.ScrollRect = transform:Find('Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	--self.ScrollBar = transform:Find('Scrollbar').gameObject
	
	--- @信息
	self.leftInfoLabel = Element:Find('BasicInfo/InfoBase/Viewport/Content/StatusBox/EquipStatusLabelLeft'):GetComponent(typeof(UnityEngine.UI.Text))
	self.rightInfoLabel = Element:Find('BasicInfo/InfoBase/Viewport/Content/StatusBox/EquipStatusLabelRight'):GetComponent(typeof(UnityEngine.UI.Text))
	self.infoBoxElement = Element:Find('BasicInfo/InfoBase/Viewport/Content/StatusBox'):GetComponent(typeof(UnityEngine.UI.LayoutElement))

	--- @宝石信息
	self.GemInfoBoxObj = Element:Find('BasicInfo/InfoBase/Viewport/Content/GemBox').gameObject
	-- 宝石镶嵌Button 1
	self.GemInlayOneButton = Element:Find('BasicInfo/ItemBox/ButtonBox/GemFirstPlusButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.GemButtonOneImage = self.GemInlayOneButton.transform:Find('PlusIamge'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 宝石镶嵌Button 2
	self.GemInlayTwoButton = Element:Find('BasicInfo/ItemBox/ButtonBox/GemSecondPlusButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.GemButtonTwoImage = self.GemInlayTwoButton.transform:Find('PlusIamge'):GetComponent(typeof(UnityEngine.UI.Image))

	self.GemButtonTable = {self.GemInlayOneButton.gameObject,self.GemInlayTwoButton.gameObject}
	self.ButtonIconTable = {self.GemButtonOneImage,self.GemButtonTwoImage}
	-- 默认镶嵌图标
	self.defautButtonIcon = self.GemButtonOneImage.sprite

	--- @ 宝石属性
	self.GemBoxObj = Element:Find('BasicInfo/InfoBase/Viewport/Content/GemBox').gameObject
	self.GemStatusLabel = Element:Find('BasicInfo/InfoBase/Viewport/Content/GemBox/GemStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	--ssr
	self.RarityImage = Element:Find('BasicInfo/ItemBox/Rarity'):GetComponent(typeof(UnityEngine.UI.Image))

	self.BaseScrollRect.enabled = false
	self.ScrollRect.enabled = false

	-- 宝石字典
	self.gemLocationDict = OrderedDictionary.New()

	self.myGame = utility:GetGame()
end


function EquipmentWinBaseInfoNodeCls:RegisterControlEvents()
	--	镶嵌Button 1
	self.__event_button_onGemInlayOneButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnGemInlayOneButtonClicked, self)
	self.GemInlayOneButton.onClick:AddListener(self.__event_button_onGemInlayOneButton_OneClicked__)
	
	--	镶嵌Button 2
	self.__event_button_onGemInlayTwoButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnGemInlayTwoButtonClicked, self)
	self.GemInlayTwoButton.onClick:AddListener(self.__event_button_onGemInlayTwoButton_OneClicked__)

	--	卸下
	self.__event_button_onctrlTakeoffWearingButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnctrlTakeoffWearingButtonClicked, self)
	self.ctrlTakeoffWearingButton.onClick:AddListener(self.__event_button_onctrlTakeoffWearingButton_OneClicked__)

	--	换装
	self.__event_button_onctrlChangewearingButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnctrlChangewearingButtonClicked, self)
	self.ctrlChangewearingButton.onClick:AddListener(self.__event_button_onctrlChangewearingButton_OneClicked__)

	--	重铸
	self.__event_button_onctrlReformButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnctrlReformButtonClicked, self)
	self.ctrlReformButton.onClick:AddListener(self.__event_button_onctrlReformButton_OneClicked__)

	--	绑定
	self.__event_button_onRoleBingdingButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnRoleBingdingButtonClicked, self)
	self.RoleBingdingButton.onClick:AddListener(self.__event_button_onRoleBingdingButton_OneClicked__)

end



function EquipmentWinBaseInfoNodeCls:UnregisterControlEvents()
	-- --取消注册 镶嵌Button1 的事件
	if self.__event_button_onGemInlayOneButton_OneClicked__ then
		self.GemInlayOneButton.onClick:RemoveListener(self.__event_button_onGemInlayOneButton_OneClicked__)
		self.__event_button_onGemInlayOneButton_OneClicked__ = nil
	end

	-- --取消注册 镶嵌Button2 的事件
	if self.__event_button_onGemInlayTwoButton_OneClicked__ then
		self.GemInlayTwoButton.onClick:RemoveListener(self.__event_button_onGemInlayTwoButton_OneClicked__)
		self.__event_button_onGemInlayTwoButton_OneClicked__ = nil
	end

	-- --取消注册 卸下 的事件
	if self.__event_button_onctrlTakeoffWearingButton_OneClicked__ then
		self.ctrlTakeoffWearingButton.onClick:RemoveListener(self.__event_button_onctrlTakeoffWearingButton_OneClicked__)
		self.__event_button_onctrlTakeoffWearingButton_OneClicked__ = nil
	end

	-- --取消注册 换装 的事件
	if self.__event_button_onctrlChangewearingButton_OneClicked__ then
		self.ctrlChangewearingButton.onClick:RemoveListener(self.__event_button_onctrlChangewearingButton_OneClicked__)
		self.__event_button_onctrlChangewearingButton_OneClicked__ = nil
	end

	-- --取消注册 重铸 的事件
	if self.__event_button_onctrlReformButton_OneClicked__ then
		self.ctrlReformButton.onClick:RemoveListener(self.__event_button_onctrlReformButton_OneClicked__)
		self.__event_button_onctrlReformButton_OneClicked__ = nil
	end

	-- --取消注册 绑定 的事件
	if self.__event_button_onRoleBingdingButton_OneClicked__ then
		self.RoleBingdingButton.onClick:RemoveListener(self.__event_button_onRoleBingdingButton_OneClicked__)
		self.__event_button_onRoleBingdingButton_OneClicked__ = nil
	end

end

function EquipmentWinBaseInfoNodeCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CStoneToEquipResult, self, self.OnStoneToEquipResponse)
	self.myGame:RegisterMsgHandler(net.S2CStoneRemoveResult, self, self.OnStoneRemoveResponse)
	self.myGame:RegisterMsgHandler(net.S2CEquipDismissBindResult, self, self.OnEquipDismissBindResponse)
	self.myGame:RegisterMsgHandler(net.S2CEquipPutOffResult, self, self.EquipPutOffResult)
end

function EquipmentWinBaseInfoNodeCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CStoneToEquipResult, self, self.OnStoneToEquipResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CStoneRemoveResult, self, self.OnStoneRemoveResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CEquipDismissBindResult, self, self.OnEquipDismissBindResponse)
	self.myGame:RegisterMsgHandler(net.S2CEquipPutOffResult, self, self.EquipPutOffResult)
end

function EquipmentWinBaseInfoNodeCls:OnStoneToEquipRequest(stoneUID,equipUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".StoneToEquipRequest(stoneUID,equipUID))
end

function EquipmentWinBaseInfoNodeCls:OnStoneRemoveRequest(stoneUID,equipUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".StoneRemoveRequest(stoneUID,equipUID))
end

function EquipmentWinBaseInfoNodeCls:OnStoneToEquipResponse(msg)
	-- 镶嵌装备response
	self:RefreshGemButtonTheme(self.equipUID)
end

function EquipmentWinBaseInfoNodeCls:OnStoneRemoveResponse(msg)
	self:RefreshGemButtonTheme(self.equipUID)
end

function EquipmentWinBaseInfoNodeCls:EquipPutOffResult(msg)
	if msg.state==0 then
		if msg.cardUID==self.roleUid and msg.equipUID==self.equipUID then
			local UserDataType = require "Framework.UserDataType"
		   
		    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
		  
			local roleID=cardBagData:GetIdFromUid(self.roleUid)
			
			local eventMgr = self.myGame:GetEventManager()
			print(self.toPos)
		    eventMgr:PostNotification(messageGuids.EquipChanged,nil, roleID,nil,self.toPos)
   -- self.toPos=-1
    --self:Close()
		end
	end
end



function EquipmentWinBaseInfoNodeCls:OnEquipDismissBindRequest(equipUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnEquipDismissBindRequest(equipUID))
end

function EquipmentWinBaseInfoNodeCls:OnEquipDismissBindResponse(msg)
	-- 解除绑定
	self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,1,true)
	-- coroutine.start(DelayRefreshItemInfo,self,msg.equipUID)
	self:StartCoroutine(DelayRefreshItemInfo, msg.equipUID)
end

function EquipmentWinBaseInfoNodeCls:ResetScrollRect(active)
	self.BaseScrollRect.enabled = active
	self.ScrollRect.enabled = active
end

-----------------------------------------------------------------------
-----------------------------------------------------------------------
function DelayRefreshItemInfo(self,uid,canDid)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local UserDataType = require "Framework.UserDataType"
	local cachedData = self:GetCachedData(UserDataType.EquipBagData)
	local equipdata = cachedData:GetItem(uid)
	local id = equipdata:GetEquipID()

	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local infodata,data,name,iconPath,itype = gametool.GetItemDataById(id)
	-- 名字
	self.itemNameLabel.text = name
	-- 图标
	utility.LoadSpriteFromPath(iconPath,self.itemIconImage)
	-- 颜色
	local color = equipdata:GetColor()
	PropUtility.AutoSetColor(self.itemColorFrame,color)
	-- 星级
	-- local starCount = data:GetStarID()
	-- gametool.AutoSetStar(self.itemStarFrame,starCount)
	local rarity = data:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
	

	-- 描述
	self.itemInfoLabel.text = infodata:GetDesc()

	-- 绑定
	self.bindCardUID = equipdata:GetBindCardUID()
	local isBind = self.bindCardUID ~= ""
	self.RoleBindingObj:SetActive(isBind)
	if isBind then
		local RoleCachedData = self:GetCachedData(UserDataType.CardBagData)
		local bindRoleId = RoleCachedData:GetIdFromUid(self.bindCardUID)
		local roleStaticData = require "StaticData.RoleInfo":GetData(bindRoleId)
		local roleName = roleStaticData:GetName()
		self.RoleBindingLabel.text = roleName
	end

	-- 类型标签
	local etype = data:GetType()
	local tagImagePath = gametool.GetEquipTagImagePath(etype)
	utility.LoadSpriteFromPath(tagImagePath,self.itemTypeIconImage)
	self:RefreshCtrlButtons(etype)
	self.equipType=etype
	self.toPos=self:GetPosWithUid()

	-- 等级
	local level = equipdata:GetLevel()

	local leveLimit = self:GetEquipLevelLimit(etype)
	debug_print(leveLimit,etype)
	if etype==KEquipType_EquipPet then
		leveLimit=utility.GetPetMaxLevel()
	end

	self.itemLvLabel.text = string.format("%s%s%s",level,"/",leveLimit)
	if leveLimit == 1 then
		self.itemLvLabel.text = ''
		self.itemLvFont.gameObject:SetActive(false)
	end

	-- 刷新套装信息
	local suitId = data:GetTaozhuangID()
	if suitId == 0 then
		self.suitObj:SetActive(false)
		self.suitNoticeLabel.gameObject:SetActive(true)
		self.ScrollRect.enabled = false
		--self.ScrollBar:SetActive(false)
		self.suitFlag:SetActive(false)
	else
		self.suitNoticeLabel.gameObject:SetActive(false)
		self:RefreshSuitInfo(suitId,gametool)
		self.ScrollRect.enabled = true
		--self.ScrollBar:SetActive(true)
		self.suitFlag:SetActive(true)
		self.suitObj:SetActive(true)
	end

	-- 属性信息
	local AttributeDict,mainID = equipdata:GetEquipAttribute()
	local leftStr,rightStr = gametool.GetEquipInfoStr(AttributeDict,mainID)
	self.rightInfoLabel.text = rightStr
	
	-- 专属装备
	local equipPrivateStr = gametool.GetEquipPrivateInfoStr(id)
	leftStr = string.format("%s%s",leftStr,equipPrivateStr)
	self.leftInfoLabel.text = leftStr
	self.infoBoxElement.preferredHeight = self.leftInfoLabel.preferredHeight
	debug_print(" can",canDid)
	if canDid==false then

		self.RoleBingdingButton.enabled=false
	else
		self.RoleBingdingButton.enabled=true

	end
	-- 镶嵌按钮
	self:InitButton(data)
	self:RefreshGemButtonTheme(uid)
end

function EquipmentWinBaseInfoNodeCls:RefreshItemInfo(uid,roleUid,canDid)
	-- 刷新信息
	self.equipUID = uid
	self.roleUid = roleUid
	-- coroutine.start(DelayRefreshItemInfo,self,uid,canDid)
	self:StartCoroutine(DelayRefreshItemInfo, uid,canDid)
end

function EquipmentWinBaseInfoNodeCls:LoadSuitItem()
  -- 加载套装node

  self.suitItemList = {}
  
  for i = 1 , KMaxEquipSuitNodeCount do
    local node = require "GUI.Knapsack.SuitItemNode".New(self.suitPointTrans)
    self.suitItemList[#self.suitItemList + 1] = node
    node:SetCallback(self,self.OnItemClicked)
  end

end

function EquipmentWinBaseInfoNodeCls:OnItemClicked()
	-- 套装点击回调
end

function EquipmentWinBaseInfoNodeCls:RefreshSuitInfo(id,gametool)
	-- 刷新套装显示
	local setData = require "StaticData.EquipSet":GetData(id)
	local setDataInfo = setData:GetInfo()
	local list = setData:GetTaozhuangList()
	local suitId = setData:GetInfo()
	local setPropertyCls = require "StaticData.EquipSetProperty"
 
	local Length = list.Count
  
	for i = 1,#self.suitItemList do
    	local node = self.suitItemList[i]
    	local active = node:GetNodeActive()
    
    	if i <= Length then
      		if not active  then
        	-- 显示操作
        	node:SetNodeActive(true)
        	self:AddChild(node)
      	end
      	local id = list[i-1]
    	node:OnBind(id,KKnapsackItemType_EquipNormal)
    	else
    		-- 隐藏操作
      		if active then
        		node:SetNodeActive(false)
        		self:RemoveChild(node)
      		end
    	end
  	end

  	-- 处理套装显示的字符串

	local maxProperty = setData:GetMaxProperty() - 1
	local str = ""
	local tempStr 
	local fixed = EquipStringTable[17]
	local fixeHeadStr = EquipStringTable[24]
	local hasCount
  	local propertyId

  	for  i = 0 , maxProperty do
    	local temp = string.format("%s%s%s",suitId,0,i)
    	propertyId = tonumber(temp)
   
  		local setPropertyData = setPropertyCls:GetData(propertyId)
    	local addProp = setPropertyData:GetAddPropID()
    	local addValue = setPropertyData:GetAddValue()
    	local hasNum = setPropertyData:GetHasNum()
    	
    	-- 是否换行    
    	if hasCount ~= hasNum then      
     		hasCount = hasNum
      		local temp = string.format(fixeHeadStr,hasCount)
      		str = string.format("%s%s",str,temp)
    	end

	    addValue = gametool.UpdatePropValue(addProp,addValue)

    	local tempHintStr = EquipStringTable[addProp]
    	tempStr = string.format(fixed,tempHintStr,addValue)

    	str = string.format("%s%s",str,tempStr) --str..tempStr

    	local maxId = string.format("%s%s%s",suitId,0,maxProperty)
    	local nextId = math.min(maxId,propertyId+1)
    	local nextHasNum = setPropertyCls:GetData(nextId):GetHasNum()

    	if hasCount ~= nextHasNum then
      		str = str.format("%s%s",str,"\n")
    	end
  	end

  	--- @ 套装名字 属性
  	local suitName = setData:GetSuitName()
  	self.suitNameLabel.text = suitName
  	self.suitInfoLabel.text = str
end

local function ReplaceDict(dict,key,value)
	-- 更新字典
	if dict:Contains(key) then
		dict:Remove(key)
	end
	dict:Add(key,value)
end

function EquipmentWinBaseInfoNodeCls:InitButton(data)
	-- 初始化按钮数量
	local count = data:GetGemNum()
	for i = 1 ,#self.GemButtonTable do
		self.GemButtonTable[i]:SetActive(i <= count )
	end
end

function EquipmentWinBaseInfoNodeCls:RefreshGemButtonTheme(uid)
	-- 刷新宝石按钮信息

	local UserDataType = require "Framework.UserDataType"
	local cachedData = self:GetCachedData(UserDataType.EquipBagData)
	local equipData = cachedData:GetItem(uid)

	-- ID列表
 	self.StoneIdTable = {}
 	-- UID列表
	self.StoneUIdTable = {}

	local stoneIDs = equipData:GetStoneID()
	
	for i = 1 ,#stoneIDs do
		self.StoneIdTable[#self.StoneIdTable + 1] = stoneIDs[i]
	end

	for i = 1 ,#self.ButtonIconTable do

		local id = self.StoneIdTable[i]
		
		if id ~= 0 then
			self:ResetButtonIcon(self.ButtonIconTable[i],id)
			ReplaceDict(self.gemLocationDict,i,true)
		else			
			self.ButtonIconTable[i].sprite = self.defautButtonIcon
			ReplaceDict(self.gemLocationDict,i,false)
		end
	end

	local uids = equipData:GetStoneUID()

	if string.find(uids,",",1) == 1 then
		uids = string.format("%s%s"," ",uids)
	end
	
	self.StoneUIdTable = utility.Split(uids,",")

	--- @ 更新文本
	if uids == " ," then
		self.GemStatusLabel.text = "未镶嵌宝石"
		self.GemBoxObj:SetActive(false)
	else
		self.GemBoxObj:SetActive(true)
		local attributeStr,chainColor,chainId = self:RefreshGemAttributeLabel(self.StoneIdTable)
		local chainStr = self:RefreshGemChainAttributeLabel(chainColor,chainId)
		self.GemStatusLabel.text = attributeStr..chainStr
	end

end

function EquipmentWinBaseInfoNodeCls:ResetButtonIcon(image,id)
	-- 根据Id重置button 图片
	local gametool = require "Utils.GameTools"
	local _,_,_,iconPath = gametool.GetItemDataById(id)
	utility.LoadSpriteFromPath(iconPath,image)
end

function EquipmentWinBaseInfoNodeCls:GetGemDataDict()
	-- 获取宝石dict
	local UserDataType = require "Framework.UserDataType"
	local cachedData = self:GetCachedData(UserDataType.EquipBagData)

    local data = cachedData:RetrievalByResultFunc(function(item)
        local itemType = item:GetEquipType()
       	local filltype = item:GetFillInType()
        if itemType == KEquipType_EquipGem and filltype == self.equipType then
        	local uid = item:GetEquipUID()
        	return true,uid
        end
       	return nil 
    end)

	return data
end

function EquipmentWinBaseInfoNodeCls:RefreshGemAttributeLabel(idTable)
	-- 重置属性列表
	local str = ""
	local chainColor = 0
	local chainId = 0

	for i = 1 ,#idTable do
		local id = idTable[i]
		local temp,color = self:GetAttributeStr(id)
		str = string.format("%s%s",str,temp)

		if color ~= nil and color > chainColor then
			chainColor = color
		end

		if id > chainId then
			chainId = id
		end
	end
	return str,chainColor,chainId
end

function EquipmentWinBaseInfoNodeCls:GetAttributeStr(id)
	-- 获得属性字符串
	if id == 0 then
		return ""
	end

	local gametool = require "Utils.GameTools"
	local infoData,itemData,name,iconPath = gametool.GetItemDataById(id)

	local attributeDict,mainId = itemData:GetEquipAttribute()
	local _,_,mainAttribute = gametool.GetEquipInfoStr(attributeDict,mainId)

	local name = infoData:GetName()
	local color = itemData:GetColorID()
	name = string.format("%s%s%s%s",name,"(",Color[color],")")
	name = string.format(colorStrRep,colorValueTable[color +1],name)
	
	local str = string.format("%s%s%s",name," : ",mainAttribute)
	return str,color
end

function EquipmentWinBaseInfoNodeCls:RefreshGemChainAttributeLabel(chainColor,chainId)
	-- 获取宝石连锁字符串
	local gametool = require "Utils.GameTools"
	local staticData = require "StaticData.EquipChain":GetData(chainColor)

	local addId = staticData:GetAddPropID()
	local addStr = EquipStringTable[addId]
	local addValue = staticData:GetAddPropValue()
	addValue = gametool.UpdatePropValue(addId,addValue)

	local chainStr = string.format(EquipStringTable[34],Color[chainColor])
	chainStr = string.format(colorStrRep,colorValueTable[chainColor +1],chainStr)

	local attributeStr
	local ischain = self:GetGemChainWithEquip(chainId)
	print("是否宝石连锁:",ischain)
	if ischain then
		attributeStr = string.format(EquipStringTable[0],addStr,addValue)
	else
		local temp = string.format("%s%s%s",addStr,": +",addValue)
		attributeStr = string.format(colorStrRep,colorValueTable[1],temp)
	end

	local str = string.format("%s%s%s",chainStr," :",attributeStr)
	return str
	
end

function EquipmentWinBaseInfoNodeCls:GetGemChainWithEquip(id)
	-- 获取是否激活宝石连锁
	if self.roleUid == nil then
		print("装备未穿戴")
		return false
	end

	-- 匹配id
	local matchID = math.floor(id / 10) 

	local UserDataType = require "Framework.UserDataType"
	local cacheData = self:GetCachedData(UserDataType.EquipBagData)
	local equipDict = cacheData:GetOneCardEquipsByUid(self.roleUid)
	--local keys = equipDict:GetKeys()
	
	for i = 1,4 do
		-- 宝石镶嵌前4个位置
		local equipUid = equipDict:GetEntryByIndex(i)
		if equipUid ~= nil then
			local data = cacheData:GetItem(equipUid)
			local staticData = data:GetEquipStaticData()
			local num = staticData:GetGemNum()
			local stoneIDs = data:GetStoneID()
			for i =1,num do
				local currID = math.floor(stoneIDs[i] / 10) 
				if currID ~= matchID then
					print("当前ID",stoneIDs[i],"匹配ID",id,"currID",currID,"matchID",matchID)
					print("宝石不一致")
					return false
				end
			end
		else
			print("缺少装备")
			return false
		end
	end

	return true
end

function EquipmentWinBaseInfoNodeCls:RefreshCtrlButtons(etype)
	-- 设置按钮
	if etype == KEquipType_EquipSpar then
		self.ctrlReformButton.gameObject:SetActive(true)
	end

	self.ctrlTakeoffWearingButton.gameObject:SetActive(self.roleUid ~= nil and etype ~= KEquipType_EquipWing)
	self.ctrlChangewearingButton.gameObject:SetActive(self.roleUid ~= nil and etype ~= KEquipType_EquipWing)

end

function EquipmentWinBaseInfoNodeCls:GetEquipLevelLimit(etype)
	-- 获取玩家当前等级
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local level = userData:GetLevel()
    local level = math.min(kMaxPlayerLevelNum,level)

    local limit = 1
    if etype == KEquipType_EquipWeapon or etype == KEquipType_EquipArmor or etype == KEquipType_EquipFashion or 
    	etype == KEquipType_EquipPet or etype == KEquipType_EquipWing then
    	limit = level
    end
    return limit
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function EquipmentWinBaseInfoNodeCls:OnGemInlayOneButtonClicked()
	-- 镶嵌1
	self:DisposeInlayEvent(1)
end

function EquipmentWinBaseInfoNodeCls:OnGemInlayTwoButtonClicked()
	-- 镶嵌2
	self:DisposeInlayEvent(2)
end

function EquipmentWinBaseInfoNodeCls:GemItemCallBack(uid,active)
	-- 宝石点击回调
	if  active then
		self.selectedStoneUid = uid
	else
		self.selectedStoneUid = nil
	end
end

function EquipmentWinBaseInfoNodeCls:ConfirmFunc()
	-- 确定按钮
	if self.selectedStoneUid == nil then
		return
	end

	local str = EquipStringTable[31]
	local windowManager = utility:GetGame():GetWindowManager()
	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	windowManager:Show(ConfirmDialogClass, str,self,self.OnInlayGemToEquip)
end

function EquipmentWinBaseInfoNodeCls:OnInlayGemToEquip()
	-- 镶嵌
	self:OnStoneToEquipRequest(self.selectedStoneUid,self.equipUID)
end

function EquipmentWinBaseInfoNodeCls:OnRomoveGemFromEquip()
	-- 摘除
	self:OnStoneRemoveRequest(self.selectedRomoveUid,self.equipUID)
end

function EquipmentWinBaseInfoNodeCls:DisposeInlayEvent(index)
	-- local isOpen = utility.IsCanOpenModule(KSystemBasis_GemCombine)
 --    if not isOpen then
 --        return
 --    end
	-- 镶嵌按钮事件处理
	local hasGem = self.gemLocationDict:GetEntryByKey(index)

	if hasGem then
		self.selectedRomoveUid = self.StoneUIdTable[index]
		local windowManager = utility:GetGame():GetWindowManager()
		local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
		local str = EquipStringTable[32]
		str = string.format(str,50)
		windowManager:Show(ConfirmDialogClass,str ,self, self.OnRomoveGemFromEquip)
	else 
		local itemCls = require "GUI.ChooseItemContainer.ChooseItemNode"
		local data = self:GetGemDataDict()
		local windowManager = self:GetGame():GetWindowManager()
		windowManager:Show(require "GUI.ChooseItemContainer.ChooseItemContainer",self,self.GemItemCallBack,itemCls,data,self.ConfirmFunc,1)
	end
end

------------------------------------------------------------------
function EquipmentWinBaseInfoNodeCls:GetPosWithUid()
	-- 获取穿在卡牌身上的位置
	local UserDataType = require "Framework.UserDataType"
	local cacheData = self:GetCachedData(UserDataType.EquipBagData)
	local equipDict = cacheData:GetOneCardEquipsByUid(self.roleUid)

	local keys = equipDict:GetKeys()
	for i = 1 ,#keys do
		local pos = keys[i]
		local uid = equipDict:GetEntryByKey(pos)
		if uid == self.equipUID then
			return pos
		end
	end
	return nil
end

function  EquipmentWinBaseInfoNodeCls:OnctrlTakeoffWearingButtonClicked()
	-- 卸下
	print("卸下")
	
	self.myGame:SendNetworkMessage(require "Network.ServerService".EquipPutOffRequest(self.roleUid,self.equipUID))
	self:DispatchEvent(messageGuids.CloseEquipWindow)

	print(str)
end

function  EquipmentWinBaseInfoNodeCls:OnctrlChangewearingButtonClicked()
	-- 换装
	local UserDataType = require "Framework.UserDataType"
   
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
  
	local roleID=cardBagData:GetIdFromUid(self.roleUid)

	local windowManager = self:GetGame():GetWindowManager()
    --ID  装备类型 装备位置
    windowManager:Show(require "GUI.ChangeEquip.ChangeEquip",roleID,self.equipType,self.toPos,false)

	print("换装")
	local messageGuids = require "Framework.Business.MessageGuids"
	
end

function  EquipmentWinBaseInfoNodeCls:OnctrlReformButtonClicked()
	-- 重铸
	print("重铸")
end

function EquipmentWinBaseInfoNodeCls:OnRoleBingdingButtonClicked()
	if self.roleUid ~= nil then
		return
	end

	local windowManager = self:GetGame():GetWindowManager()
	local str = EquipStringTable[36]
	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	windowManager:Show(ConfirmDialogClass,str,self,self.OnOnEquipDismissBindRequestEvent)
end

function EquipmentWinBaseInfoNodeCls:OnOnEquipDismissBindRequestEvent()
	self:OnEquipDismissBindRequest(self.equipUID)
end


return EquipmentWinBaseInfoNodeCls