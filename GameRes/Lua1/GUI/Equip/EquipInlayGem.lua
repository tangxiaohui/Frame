local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Collection.OrderedDictionary"
require "LUT.StringTable"

local colorTable = {"(绿)","(蓝)","(橙)"}
local cost = 50
-- 宝石连锁
local colorValueTable = {"05A60DFF","065EA7FF","7D05A7FF"}
local colorStrRep = "<color=#%s> %s</color>"

local EquipInlayGemCls = Class(BaseNodeClass)


----------------------------------------------------------------------
function EquipInlayGemCls:Ctor()
end

function EquipInlayGemCls:OnWillShow(equipID)
	self.equipID = equipID
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipInlayGemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GemAddup', function(go)
		self:BindComponent(go)
	end)
end

function EquipInlayGemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function EquipInlayGemCls:OnResume()
	-- 界面显示时调用
	EquipInlayGemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:ResetEquipPanel(self.equipID)
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end


function EquipInlayGemCls:OnPause()
	-- 界面隐藏时调用
	EquipInlayGemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function EquipInlayGemCls:OnEnter()
	-- Node Enter时调用
	EquipInlayGemCls.base.OnEnter(self)
end

function EquipInlayGemCls:OnExit()
	-- Node Exit时调用
	EquipInlayGemCls.base.OnExit(self)
end


function EquipInlayGemCls:IsTransition()
    return false
end

function EquipInlayGemCls:OnExitTransitionDidStart(immediately)
	EquipInlayGemCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function EquipInlayGemCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipInlayGemCls:InitControls()
	self.myGame = utility:GetGame()
	local transform = self:GetUnityTransform()
	self.tweenObjectTrans = transform:Find("Base")

	-- 返回按钮
	self.ReturnButton = transform:Find('Base/GemAddupbase/GemAddupReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.iconImage = transform:Find('Base/GemAddupbase/BigItemIcon/GeneralItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.nameLabel = transform:Find('Base/GemAddupbase/GemAddupItemInfoNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.InlayButton_One = transform:Find('Base/GemAddupbase/BigItemIcon/BackpackGemFirstPlusButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.InlayButton_Two = transform:Find('Base/GemAddupbase/BigItemIcon/BackpackGemFirstPlusButton (1)'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 镶嵌按钮
	self.InlayButton_OneIcon = self.InlayButton_One.transform:Find('PlusIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InlayButton_TwoIcon = self.InlayButton_Two.transform:Find('PlusIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	self.ButtonIconTable = {self.InlayButton_OneIcon,self.InlayButton_TwoIcon}
	-- 默认图标
	self.defautButtonIcon = self.InlayButton_OneIcon.sprite

	-- 宝石属性
	self.propertyLabel = transform:Find('Base/GemAddupbase/ItemStatus/EquipStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))	

	-- button位置是否有宝石
	self.gemLocationDict = OrderedDictionary.New()
end


function EquipInlayGemCls:RegisterControlEvents()	
	-- -- 注册 返回 的事件
	 self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	 self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

	 self.__event_button_onInlayButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnInlayButton_OneClicked, self)
	 self.InlayButton_One.onClick:AddListener(self.__event_button_onInlayButton_OneClicked__)

	 self.__event_button_onInlayButton_TwoClicked__ = UnityEngine.Events.UnityAction(self.OnInlayButton_TwoClicked, self)
	 self.InlayButton_Two.onClick:AddListener(self.__event_button_onInlayButton_TwoClicked__)

end

function EquipInlayGemCls:UnregisterControlEvents()

	-- --取消注册 返回 的事件
	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end

	if self.__event_button_onInlayButton_OneClicked__ then
		self.InlayButton_One.onClick:RemoveListener(self.__event_button_onInlayButton_OneClicked__)
		self.__event_button_onInlayButton_OneClicked__ = nil
	end

	if self.__event_button_onInlayButton_TwoClicked__ then
		self.InlayButton_Two.onClick:RemoveListener(self.__event_button_onInlayButton_TwoClicked__)
		self.__event_button_onInlayButton_TwoClicked__ = nil
	end

end

function EquipInlayGemCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CStoneToEquipResult, self, self.OnStoneToEquipResponse)
	self.myGame:RegisterMsgHandler(net.S2CStoneRemoveResult, self, self.OnStoneRemoveResponse)
end

function EquipInlayGemCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CStoneToEquipResult, self, self.OnStoneToEquipResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CStoneRemoveResult, self, self.OnStoneRemoveResponse)
end
-----------------------------------------------------------------------
function EquipInlayGemCls:OnStoneToEquipRequest(stoneUID,equipUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".StoneToEquipRequest(stoneUID,equipUID))
end

function EquipInlayGemCls:OnStoneRemoveRequest(stoneUID,equipUID)
	self.myGame:SendNetworkMessage( require"Network/ServerService".StoneRemoveRequest(stoneUID,equipUID))
end

function EquipInlayGemCls:OnStoneToEquipResponse(msg)
	-- 镶嵌装备response
	print("镶嵌装备response")
	self:ResetInlayButtonTheme(self.equipUID)
end

function EquipInlayGemCls:OnStoneRemoveResponse(msg)
	print("摘除宝石")
	self:ResetInlayButtonTheme(self.equipUID)
end

-----------------------------------------------------------------------
function EquipInlayGemCls:ResetEquipPanel(id)
	-- 刷新装备	
	local gametool = require "Utils.GameTools"

	local infoData,data,name,iconPath = gametool.GetItemDataById(id)

	utility.LoadSpriteFromPath(iconPath,self.iconImage)
	self.nameLabel.text = name

	local buttonTwoActive = data:GetGemNum() == 2

	self.InlayButton_Two.gameObject:SetActive(buttonTwoActive)

	-- 装备UID
	local UserDataType = require "Framework.UserDataType"
 	local bagData = self:GetCachedData(UserDataType.EquipBagData)
 	local equipData,equipUID = bagData:RetrievalContainsById(id)
 	self.equipUID = equipUID

 	self:ResetInlayButtonTheme(equipUID)
end

local function ReplaceDict(dict,key,value)
	-- 更新字典
	if dict:Contains(key) then
		dict:Remove(key)
	end

	dict:Add(key,value)

end


function EquipInlayGemCls:ResetInlayButtonTheme(uid)
	-- 刷新镶嵌 button 显示

	-- ID列表
 	self.StoneIdTable = {}
 	-- UID列表
	self.StoneUIdTable = {}


	local UserDataType = require "Framework.UserDataType"
 	local bagData = self:GetCachedData(UserDataType.EquipBagData)
	local equipData = bagData:GetItem(uid)

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
	self.StoneUIdTable = utility.Split(uids,",")

	self:ResetPropertyLabel(self.StoneIdTable)

end

function EquipInlayGemCls:ResetButtonIcon(image,id)
	-- 根据Id重置button 图片
	local gametool = require "Utils.GameTools"
	local _,_,_,iconPath = gametool.GetItemDataById(id)
	utility.LoadSpriteFromPath(iconPath,image)
end

function EquipInlayGemCls:ResetPropertyLabel(idTable)
	-- 重置属性列表
	
	local str = ""
	
	for i = 1 ,#idTable do

		local isEnd = i == #idTable
		local id = idTable[i]
		local temp = self:GetPropString(id,isEnd)
		str = string.format("%s%s",str,temp)
	end
	self.propertyLabel.text = str
end

local function UpdatePropValue(key,value)
  -- 判断是否为百分比
  local temp 
  value = string.format("%.0f",value)
  
  if key == kPropertyID_HpLimitRate or key == kPropertyID_DpRate or key == kPropertyID_ApRate or 
  	key == kPropertyID_CritRate or key == kPropertyID_DecritRate or key == kPropertyID_HitRate or 
  	key == kPropertyID_AvoidRate or key == kPropertyID_CritDamageRate then    
    temp = value.."%" 
  else
    temp = value
  end

  return temp
end

function EquipInlayGemCls:GetPropString(id,isEnd)
	-- 获取属性Str
	if id == 0 then
		return ""
	end

	-- 显示Str
	local str = ""
	local colorStr
	-- 固定Str
	local fixedStr
  	local fixedAddStr = EquipStringTable[0]
  	local fixedSubStr = EquipStringTable[16]	

	local equipdata = require "StaticData.Equip":GetData(id)
	local dict = equipdata:GetEquipAttribute()

	local infoId = equipdata:GetInfo()
	local name = require "StaticData.EquipInfo":GetData(infoId):GetName()

	-- 宝石连锁
	local chainId = equipdata:GetColorID()
	colorStr = colorTable[chainId]

	local chainIData = require "StaticData.EquipChain":GetData(chainId)
	local chaimAddId = chainIData:GetAddPropID()
	local addStr = EquipStringTable[chaimAddId]
	local chainIdAddValue = chainIData:GetAddPropValue()
	chainIdAddValue = UpdatePropValue(chaimAddId,chainIdAddValue)
	local tempChainStr =  string.format(fixedAddStr,addStr,chainIdAddValue)
	tempChainStr = string.gsub(tempChainStr,":","")

	local tempColorValue = colorValueTable[chainId]
	local temoLineStr = string.format("%s%s","宝石连锁",colorStr)
	local lineStr = string.format(colorStrRep,tempColorValue,temoLineStr)
	tempChainStr = string.format("%s%s%s",lineStr," : ",tempChainStr)

	local tempNameStr = string.format("%s%s",name,colorStr)
	local lineNameStr = string.format(colorStrRep,tempColorValue,tempNameStr)

	if isEnd then
		tempChainStr = string.gsub(tempChainStr,"\n","")	
	end

	local keys = dict:GetKeys()
	
	for i = 1 ,#keys do

		local key = keys[i]
		local additionValue = dict:GetEntryByKey(key)

		local tempStr = EquipStringTable[key]
   
   		if additionValue >= 0 then
      		fixedStr = fixedAddStr
    	else
      		fixedStr = fixedSubStr
    	end        	

    	additionValue = UpdatePropValue(key,additionValue)
		
    	local tempHintStr = string.format(fixedStr,tempStr,additionValue)

    	tempHintStr = string.gsub(tempHintStr,":","")
		str = string.format("%s%s%s%s",lineNameStr," : ",str,tempHintStr)
	end

	str = string.format("%s%s",str,tempChainStr)
	return str

end



function EquipInlayGemCls:ItemClickedCallBack(uid)
	-- item 点击回调
	self.selectedStoneUid = uid
	local str = EquipStringTable[31]
	local windowManager = utility:GetGame():GetWindowManager()
	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	windowManager:Show(ConfirmDialogClass, str,self, self.OnInlayGemToEquip)

	
end

function EquipInlayGemCls:OnInlayGemToEquip()
	self:OnStoneToEquipRequest(self.selectedStoneUid,self.equipUID)
end

function EquipInlayGemCls:OnRomoveGemFromEquip()
	self:OnStoneRemoveRequest(self.selectedRomoveUid,self.equipUID)
end
-----------------------------------------------------------------------
function EquipInlayGemCls:OnReturnButtonClicked()
	-- 返回事件
	self:Hide()

end

function EquipInlayGemCls:OnInlayButton_OneClicked()
	-- 合成按钮 1 事件
	self:DisposeInlayEvent(1)
	
end

function EquipInlayGemCls:OnInlayButton_TwoClicked()
	-- 合成按钮 2 事件
	self:DisposeInlayEvent(2)
end

function EquipInlayGemCls:DisposeInlayEvent(index)
	local hasGem = self.gemLocationDict:GetEntryByKey(index)

	if hasGem then
		self.selectedRomoveUid = self.StoneUIdTable[index]
		local windowManager = utility:GetGame():GetWindowManager()
		local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
		local str = EquipStringTable[32]
		str = string.format(str,50)
		windowManager:Show(ConfirmDialogClass,str ,self, self.OnRomoveGemFromEquip)
	else 
		local windowManager = self:GetGame():GetWindowManager()
    	local InlayGemBagScrollNodeCls = require "GUI.Equip.InlayGemBag"
    	windowManager:Show(InlayGemBagScrollNodeCls,equipUid,self,self.ItemClickedCallBack)
	end
end





return EquipInlayGemCls