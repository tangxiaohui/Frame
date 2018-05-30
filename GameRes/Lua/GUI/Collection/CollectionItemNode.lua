local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local collectiondata = require "StaticData.BigLibrary.BigLibraryCollection"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"

local CollectionItemNodeCls = Class(BaseNodeClass)

function CollectionItemNodeCls:Ctor(parent,itenWidth,itemHigh)
	self.parent = parent
	self.itemWidth = itenWidth
	self.itemHigh = itemHigh
end

function CollectionItemNodeCls:SetCallback()

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CollectionItemNodeCls:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/CollectionItem", function(go)
		self:BindComponent(go,false)
	end)
end

function CollectionItemNodeCls:OnComponentReady()
	--界面加载完成
	self:LinkComponent(self.parent)
	self:InitControls()
end

function CollectionItemNodeCls:OnResume()
	CollectionItemNodeCls.base.OnResume(self)
	self:RegisterControEvents()
	self:RegisterNetworkEvents()
end

function CollectionItemNodeCls:OnPause()
	CollectionItemNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CollectionItemNodeCls:OnEnter()
	CollectionItemNodeCls.base.OnEnter(self)
end

function CollectionItemNodeCls:OnExit()
	CollectionItemNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CollectionItemNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	
	-- -- 信息按钮
	self.infoButton = transform:Find('CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	--  图标
	self.iconImage = transform:Find('CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.colorImage = transform:Find('Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 名称
	self.titleNameLabel = transform:Find('Cardname/CardNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--card图标
	self.carItem = transform:Find('TypeBase').gameObject
	self.cardItemIcon = transform:Find('TypeBase/Type'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--图鉴点
	self.collectionPoint = transform:Find("Image")
	-- hsl材质球
	self.hslMaterial = self.colorImage.material
	self.GrayMaterial = utility.GetGrayMaterial()
	self.myGame = utility:GetGame()
end

function CollectionItemNodeCls:RegisterControEvents()
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function CollectionItemNodeCls:UnregisterControlEvents()
	
	if self.__event_button_onInfoButtonClicked__ then
		self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end

function CollectionItemNodeCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.TuJianDrawResultMessage,self, self.OnTuJianDrawResponse)
end

function CollectionItemNodeCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.TuJianDrawResultMessage,self, self.OnTuJianDrawResponse)
end

function CollectionItemNodeCls:OnTuJianDrawRequest(oid,typeId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".TuJianDrawRequest(oid,typeId))
end

function CollectionItemNodeCls:OnTuJianQueryRequest(sonid,typeId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".TuJianQueryRequest(sonid,typeId))
end

function CollectionItemNodeCls:OnTuJianDrawResponse(msg)
	if msg.result == 1 then
		if self.param == msg.oid then
			self:ShowPanel(msg.type)
			self:OnTuJianQueryRequest(self.sonid,self.sonid)
		end
	end
end

function CollectionItemNodeCls:ShowPanel(typeId)
	if typeId == 1 then
		local items = {}
		local awardData = require "StaticData.BigLibrary.BigLibraryCollectionPoints":GetData(self.param)
		local item = {}
		item.id = 10410011
		item.count = awardData:GetAwardNum()
		local gametool = require "Utils.GameTools"
		local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(item.id)
		local color = gametool.GetItemColorByType(itemType,data)
		item.color = color

		items[1] = item
		local windowManager = self:GetGame():GetWindowManager()
		local AwardCls = require "GUI.Task.GetAwardItem"
		windowManager:Show(AwardCls,items)
	end
end

function CollectionItemNodeCls:OnInfoButtonClicked()
	print(self.state,"aaaaaaaaaaa")
	if self.state == 1 then
		self:OnTuJianDrawRequest(self.param,1)
	else
		if self.type == 1 then
			-- local sceneManager = self:GetGame():GetSceneManager()
			-- local senceCls = require "GUI.Collection.CollectionCardInfo"
			-- sceneManager:PushScene(senceCls.New(self.param))
			--卡牌
			local windowManager = utility:GetGame():GetWindowManager()
			windowManager:Show(require "GUI.Collection.CollectionCardInfo",self.param)
		end
		if self.type == 2 then
			--道具
			local gameTool = require "Utils.GameTools"
			gameTool.ShowItemWin(self.param)
			-- local windowManager = utility:GetGame():GetWindowManager()
			-- windowManager:Show(require "GUI.CommonItemWin",self.param)
		end
	end
end

--初始化预设
function CollectionItemNodeCls:LoadItem()
	if self.type == 1 then
		local RoleStaticData = require "StaticData.Role":GetData(self.param)
		self.carItem:SetActive(true)
		local roleData = require "StaticData.Role":GetData(self.param)
		utility.LoadRaceIcon(roleData:GetRace(),self.cardItemIcon)
		local count = RoleStaticData:GetDecomposeNum()
		-- self:SetCardIcon()
	end
	if self.type == 2 then
		self.carItem:SetActive(false)
	end
	self:SetIcon()
	self:SetPoint()
	self:LoadItemState()
end

function CollectionItemNodeCls:LoadItemState()
	if self.state == 0 then
		self:ShowState(self.GrayMaterial)
		self.collectionPoint.gameObject:SetActive(false)
	end
	if self.state == 1 then
		self:ShowState(utility.GetCommonMaterial())
		-- self.colorImage.material = self.hslMaterial
		self.collectionPoint.gameObject:SetActive(true)
	end
	if self.state == 2 then
		self:ShowState(utility.GetCommonMaterial())
		-- self.colorImage.material = self.hslMaterial
		self.collectionPoint.gameObject:SetActive(false)
	end
end

function CollectionItemNodeCls:ShowState(isShow)
	self.iconImage.material = isShow
	self.colorImage.material = isShow
end

--设置卡片图标
-- function CollectionItemNodeCls:SetCardIcon()
-- local gametool = require "Utils.GameTools"
	-- local infoData,data,itemName,iconPath,itemType = gametool.GetItemDataById(self.param)
	-- gametool.OnLoadSprite(self.cardItemIcon,iconPath)
-- end

--设置icon
function CollectionItemNodeCls:SetIcon()
	local gametool = require "Utils.GameTools"
	local infoData,data,itemName,iconPath,itemType = gametool.GetItemDataById(self.param)
	utility.LoadSpriteFromPath(iconPath,self.iconImage)
	local color = gametool.GetItemColorByType(itemType,data)
	local PropUtility = require "Utils.PropUtility"
 	PropUtility.AutoSetRGBColor(self.colorImage,color)
	self.titleNameLabel.text = itemName
end

function CollectionItemNodeCls:SetPoint()
	local pointdata = require "StaticData.BigLibrary.BigLibraryCollectionPoints"
	local data = pointdata:GetData(self.param)
	-- self.collectionPoint.text = data:GetAwardNum()
end

function CollectionItemNodeCls:RefreshItem(id)
	-- coroutine.start(DelayRefreshItem,self,id)
end

local function DelayRefreshItem(self,id)

end

function CollectionItemNodeCls:SetActive(active)
	self.active = active
end

local function DelayOnBind(self,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.rectTransform.sizeDelta = Vector2(self.itemWidth,self.itemHigh)
	self:ResetItem(data)
end

function CollectionItemNodeCls:OnBind(data,index,args)

	self.data = data
	self.index = index	
	--self.args = args
	
	-- coroutine.start(DelayOnBind,self,data)
	self:StartCoroutine(DelayOnBind, data)


end

function CollectionItemNodeCls:ResetItem(data)
	self.id = data.id
	-- print("id",data.id)
	local collection = collectiondata:GetData(data.id)
	self.sonid = collection:GetSon()
	self.type = collection:GetType()
	self.param = collection:GetParam()
	self.state = data.state
	self:LoadItem()
end

function CollectionItemNodeCls:OnUnbind()
	
end

local function DelayResetPosition(self,position)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.rectTransform.anchoredPosition = position
end

function CollectionItemNodeCls:ResetPosition(position)
	-- coroutine.start(DelayResetPosition,self,position)
	self:StartCoroutine(DelayResetPosition, position)
end

return CollectionItemNodeCls