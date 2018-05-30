local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "LUT.StringTable"

local CollectionAwardNodeCls = Class(BaseNodeClass)

function CollectionAwardNodeCls:Ctor(parent,itenWidth,itemHigh)
	self.parent = parent
	self.itemWidth = itenWidth
	self.itemHigh = itemHigh
	-- self.id = id
	-- self.tujian = tujian
end

function CollectionAwardNodeCls:SetCallback()

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CollectionAwardNodeCls:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/CollectionRewardItem", function(go)
		self:BindComponent(go,false)
	end)
end

function CollectionAwardNodeCls:OnComponentReady()
	--界面加载完成
	self:LinkComponent(self.parent)
	self:InitControls()
end

function CollectionAwardNodeCls:OnResume()
	CollectionAwardNodeCls.base.OnResume(self)
	-- self:AddAwardPoint()
	-- self:LoadPanel()
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function CollectionAwardNodeCls:OnPause()
	CollectionAwardNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CollectionAwardNodeCls:OnEnter()
	CollectionAwardNodeCls.base.OnEnter(self)
end

function CollectionAwardNodeCls:OnExit()
	CollectionAwardNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CollectionAwardNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	transform.localScale = Vector3.New(0.98, 0.98, 0.98)
	-- self.transform = transform
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	self.infoButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
	--奖励点
	self.awardNumLable = transform:Find("ProgressBar/BigLibrarySpeciesProgressBarNumLable"):GetComponent(typeof(UnityEngine.UI.Text))
	self.awardNumFill = transform:Find("ProgressBar/BigLibrarySpeciesProgressBarMask/Base"):GetComponent(typeof(UnityEngine.UI.Image))
	--名称
	self.collectionName = transform:Find("Title/BigLibrarySpeciesTextNameLable"):GetComponent(typeof(UnityEngine.UI.Text))
	self.descLabel = transform:Find("Title/BigLibrarySpeciesBriefingLable"):GetComponent(typeof(UnityEngine.UI.Text))
	self.itemName = transform:Find("AwardIcon/ItemNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--图标
	self.colorImage = transform:Find("AwardIcon/Frame"):GetComponent(typeof(UnityEngine.UI.Image))
	self.iconImage = transform:Find("AwardIcon/BigLibrarySpeciesIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	--图鉴数量
	self.itemNumLble = transform:Find("AwardIcon/ItemNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	-- 已领取状态
	self.awardState = transform:Find("BigLibrarySpeciesStatus").gameObject
	--不可领取状态
	self.Icon = transform:Find("Icon/BigLibrarySpeciesIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.awardImage = transform:Find("Title/Line"):GetComponent(typeof(UnityEngine.UI.Image))
	-- hsl材质球
	self.hslMaterial = self.colorImage.material
	self.GrayMaterial = utility.GetGrayMaterial()
	self.myGame = utility:GetGame()
end

function CollectionAwardNodeCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
end

function CollectionAwardNodeCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
end

function CollectionAwardNodeCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.TuJianDrawResultMessage,self, self.OnTuJianDrawResponse)
end

function CollectionAwardNodeCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.TuJianDrawResultMessage,self, self.OnTuJianDrawResponse)
end

function CollectionAwardNodeCls:OnTuJianDrawRequest(oid,typeId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".TuJianDrawRequest(oid,typeId))
end

function CollectionAwardNodeCls:OnTuJianQueryRequest(sonid,typeId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".TuJianQueryRequest(sonid,typeId))
end

function CollectionAwardNodeCls:OnTuJianDrawResponse(msg)
	if msg.result == 1 and msg.oid == self.id then
		self:OnTuJianQueryRequest(0,0)
		self:CanAward()
	else
		-- local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        -- local windowManager = utility.GetGame():GetWindowManager()

        -- local hintStr = string.format(CommonStringTable[0],levelLimit)
        -- windowManager:Show(ErrorDialogClass, hintStr)
	end
end

function CollectionAwardNodeCls:OnInfoButtonClicked()
	if self.tujian.state == 1 then
		--领取图鉴点奖励
		self:OnTuJianDrawRequest(self.id,2)
	end
end


function CollectionAwardNodeCls:CanAward()
	local items = {}
	local awardData = require "StaticData.BigLibrary.BigLibraryCollectionAward":GetData(self.id)
	local item = {}
	item.id = awardData:GetAwardId()
	item.count = awardData:GetAwardNum()
	local gametool = require "Utils.GameTools"
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(awardData:GetAwardId())
	local color = gametool.GetItemColorByType(itemType,data)
	item.color = color

	items[1] = item
	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,items)
end

function CollectionAwardNodeCls:LoadPanel()
	-- print(data.id)
	local awardData = require "StaticData.BigLibrary.BigLibraryCollectionAward":GetData(self.id)
	print("self.points",self.points)
	self.awardNumLable.text = self.points.."/".. awardData:GetNeedPoint()
	self.awardNumFill.fillAmount = self.points/awardData:GetNeedPoint()
	local gametool = require "Utils.GameTools"
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(awardData:GetAwardId())
	utility.LoadSpriteFromPath(iconPath,self.iconImage)
	local color = gametool.GetItemColorByType(itemType,data)
	local PropUtility = require "Utils.PropUtility"
 	PropUtility.AutoSetRGBColor(self.colorImage,color)
	self.itemName.text = itemName
	self.collectionName.text = string.format(LibraryStringTable[1],awardData:GetNeedPoint())
	self.descLabel.text = string.format(LibraryStringTable[0],awardData:GetNeedPoint())
	self.itemNumLble.text = awardData:GetAwardNum()
	self:HideAwardState()
	if self.tujian ~= nil then
		if self.tujian.state == 0 then
			self:ShowState(self.GrayMaterial)
			self.collectionName.material = utility.GetGrayMaterial("Text")
		end
		if self.tujian.state == 1 then
			self.collectionName.material = utility.GetCommonMaterial("Text")
			self:ShowState(utility.GetCommonMaterial())
			-- self.colorImage.material = self.hslMaterial
		end
		if self.tujian.state == 2 then
			self.collectionName.material = utility.GetCommonMaterial("Text")
			self:ShowState(utility.GetCommonMaterial())
			-- self.colorImage.material = self.hslMaterial
			self.awardState.gameObject:SetActive(true)
		end
	end
end

function CollectionAwardNodeCls:ShowState(isShow)
	self.awardImage.material = isShow
	self.iconImage.material = isShow
	self.colorImage.material = isShow
	self.Icon.material = isShow
	self.awardNumFill.material = isShow
	
end

function CollectionAwardNodeCls:HideAwardState()
	self.awardState.gameObject:SetActive(false)
end

function CollectionAwardNodeCls:AddAwardPoint()
	local awarddata = require "StaticData.BigLibrary.BigLibraryCollectionAward"
	local keys = awarddata:GetKeys()
	local tables = {}
	local allPoint = 0
	for i = 0,(keys.Length - 1) do
		local point = awarddata:GetData(keys[i]):GetNeedPoint()
		tables[i + 1] = point
	end
	for i = 1, #tables do
		local data = tonumber(tables[i])
		allPoint = data + allPoint
	end
end

function CollectionAwardNodeCls:SetActive(active)
	self.active = active
end


function CollectionAwardNodeCls:ResetItem(data)
	self:LoadPanel()
end

local function DelayOnBind(self,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.rectTransform.sizeDelta = Vector2(self.itemWidth,self.itemHigh)

	self:ResetItem(data)
end

function CollectionAwardNodeCls:OnBind(data,index,args)

	self.data = data
	self.index = index	
	--self.args = args
	self.id = data.id
	self.tujian = data.tujian
	self.points = data.points
	-- coroutine.start(DelayOnBind,self,data)
	self:StartCoroutine(DelayOnBind, data)

end

function CollectionAwardNodeCls:OnUnbind()
	
end

local function DelayResetPosition(self,position)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.rectTransform.anchoredPosition = position
end

function CollectionAwardNodeCls:ResetPosition(position)
	-- coroutine.start(DelayResetPosition,self,position)
	self:StartCoroutine(DelayResetPosition, position)
end

return CollectionAwardNodeCls