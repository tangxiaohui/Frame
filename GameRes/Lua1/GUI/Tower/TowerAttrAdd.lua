local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
require "LUT.StringTable"

local TowerAttrAdd = Class(BaseNodeClass)
windowUtility.SetMutex(TowerAttrAdd, true)

function  TowerAttrAdd:Ctor()
	
end

function TowerAttrAdd:OnWillShow(attributeIDArray,curStar)
	self.attrId = attributeIDArray
	self.star = curStar
end

function  TowerAttrAdd:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/TowerAttrAdd",function(go)
		self:BindComponent(go)
	end)
end

function TowerAttrAdd:OnComponentReady()
	self:InitControls()
end

function TowerAttrAdd:OnResume()
	TowerAttrAdd.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.transform

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:AttributeQuery()
end

function TowerAttrAdd:OnPause()
	TowerAttrAdd.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function TowerAttrAdd:OnEnter()
	TowerAttrAdd.base.OnEnter(self)
	self:LoadPanel()
end

function TowerAttrAdd:OnExit()
	TowerAttrAdd.base.OnExit(self)
end

function TowerAttrAdd:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  TowerAttrAdd:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform:Find("Base")

	self.itemIcon = {}
	self.itemSelect = {}
	self.attrLabel = {}
	self.attrNum = {}
	self.selectButton = {}
	for i=1,3 do
		self.itemIcon[i] = transform:Find("Base/Attr/Attr"..i.."/AttrIcon/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
		self.itemSelect[i] = transform:Find("Base/Attr/Attr"..i.."/Select").gameObject
		self.attrLabel[i] = transform:Find("Base/Attr/Attr"..i.."/Status/AttrLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.attrNum[i] = transform:Find("Base/Attr/Attr"..i.."/Status/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.selectButton[i] = transform:Find("Base/Attr/Attr"..i.."/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	end
	self.starNum = transform:Find("Base/Price/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.confirmButton = transform:Find("Base/ConfirmButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.attrParent = transform:Find("Base/Status")

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function TowerAttrAdd:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function TowerAttrAdd:OnExitTransitionDidStart(immediately)
    TowerAttrAdd.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.transform

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

----------------------------------------------------------------------------
--事件处理--
----------------------------------------------------------------------------
function TowerAttrAdd:RegisterControlEvents()
	--注册确定事件
	self._event_button_onConfirmButtonClicked_ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked,self)
	self.confirmButton.onClick:AddListener(self._event_button_onConfirmButtonClicked_)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	--注册选择事件
	self._event_button_onSelectButtonClicked_ = {}
	self.SelectButtonClicked = {}
	self.SelectButtonClicked[1] = self.Select3StarCliecked
	self.SelectButtonClicked[2] = self.Select6StarCliecked
	self.SelectButtonClicked[3] = self.Select9StarCliecked
	for i=1,#self.selectButton do
		self._event_button_onSelectButtonClicked_[i] = UnityEngine.Events.UnityAction(self.SelectButtonClicked[i],self)
		self.selectButton[i].onClick:AddListener(self._event_button_onSelectButtonClicked_[i])
	end

end

function TowerAttrAdd:UnregisterControlEvents()
	--取消注册确定事件
	if self._event_button_onConfirmButtonClicked_ then
		self.confirmButton.onClick:RemoveListener(self._event_button_onConfirmButtonClicked_)
		self._event_button_onConfirmButtonClicked_ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
	--取消注册选择事件
	for i=1,#self.selectButton do
		if self._event_button_onSelectButtonClicked_[i] then
			self.selectButton[i].onClick:RemoveListener(self._event_button_onSelectButtonClicked_[i])
			self._event_button_onSelectButtonClicked_[i] = nil
		end
	end

end

function TowerAttrAdd:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CAddAttributeResult,self,self.OnAddAttributeResult)
	utility:GetGame():RegisterMsgHandler(net.S2CAttributeQueryResult,self,self.AttributeQueryResult)
end

function TowerAttrAdd:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CAddAttributeResult,self,self.OnAddAttributeResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CAttributeQueryResult,self,self.AttributeQueryResult)
end

function TowerAttrAdd:OnAddAttributeResult(msg)
	self:AttributeQuery()
	self:TowerQueryRequest()
	self:Close(true)
end

function TowerAttrAdd:AttributeQueryResult(msg)
	self:RemoveAll()
	self:LoadCurAttr(msg.attrArray)
end

function TowerAttrAdd:TowerQueryRequest()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".TowerQueryRequest())
end

function TowerAttrAdd:AddAttributeRequest(needStar,attributeID)
	utility:GetGame():SendNetworkMessage(require "Network.ServerService".AddAttributeRequest(needStar,attributeID))
end

function TowerAttrAdd:AttributeQuery()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".AttributeQueryRequest())
end

function TowerAttrAdd:OnConfirmButtonClicked()
	self:AddAttributeRequest((self.index * 3),self.attrId[self.index])
end

function TowerAttrAdd:OnReturnButtonClicked()
	self:Close()
end

function TowerAttrAdd:Select3StarCliecked()
	self:ShowSelect(1)
end

function TowerAttrAdd:Select6StarCliecked()
	self:ShowSelect(2)
end

function TowerAttrAdd:Select9StarCliecked()
	self:ShowSelect(3)
end

function TowerAttrAdd:ShowSelect(index)
	self.index = index
	self:HideSelect()
	self.itemSelect[index]:SetActive(true)
end

function TowerAttrAdd:HideSelect()
	for i=1,#self.itemSelect do
		self.itemSelect[i]:SetActive(false)
	end
end

--加载界面
function TowerAttrAdd:LoadPanel()
	if self.attrId ~= nil then
		self:ShowSelect(1)
		local randomAdd = require "StaticData.Tower.RandomAdd"
		local towerData = require "StaticData.Tower.Tower":GetData(1):GetAddPrice()
		for i=1,#self.attrId do
			local data = randomAdd:GetData(self.attrId[i])
			local icon = data:GetIcon()
			utility.LoadSpriteFromPath(string.format("UI/Atlases/Icon/TalentIcon/%s",icon),self.itemIcon[i])
			self.attrLabel[i].text = EquipStringTable[data:GetTypeid()]
			local price = towerData[i - 1] * data:GetPriceRate()
			self.attrNum[i].text = "+"..string.format("%.1f",price).."%"
		end
		self.starNum.text = self.star
	end
end

function TowerAttrAdd:LoadCurAttr(curAttrArray)
	self.node = {}
	if curAttrArray ~= nil then
		for i=1,#curAttrArray do
			local attrItemCls = require "GUI.Tower.TowerAttrItem".New(self.attrParent,2,curAttrArray[i].attributeKey,curAttrArray[i].attributeValue)
			self.node[i] = attrItemCls
			self:AddChild(self.node[i])
		end
	end
end

function TowerAttrAdd:RemoveAll()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
end

return TowerAttrAdd