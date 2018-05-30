local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local EquipmentWinCombineNodeCls = Class(BaseNodeClass)
require "LUT.StringTable"
local messageGuids = require "Framework.Business.MessageGuids"

function EquipmentWinCombineNodeCls:Ctor(parent,ctrlCombineButton)
	self.parent = parent
	self.ctrlCombineButton = ctrlCombineButton
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipmentWinCombineNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipmentCombine', function(go)
		self:BindComponent(go,false)
	end)
end

function EquipmentWinCombineNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function EquipmentWinCombineNodeCls:OnResume()
	-- 界面显示时调用
	EquipmentWinCombineNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.IsPlayingEffect = false
end

function EquipmentWinCombineNodeCls:OnPause()
	-- 界面隐藏时调用
	EquipmentWinCombineNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function EquipmentWinCombineNodeCls:OnEnter()
	-- Node Enter时调用
	EquipmentWinCombineNodeCls.base.OnEnter(self)
end

function EquipmentWinCombineNodeCls:OnExit()
	-- Node Exit时调用
	EquipmentWinCombineNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipmentWinCombineNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	---@ 合成的物品
	-- 装备头像
	self.itemIconImage = transform:Find('ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 装备颜色
	self.itemColorFrame = transform:Find('ItemBox/ColorFrame')
	-- 装备星级
	self.itemStarFrame = transform:Find('ItemBox/EquipStarLayout')
	-- 装备名称
	self.itemNameLabel = transform:Find('ItemNameBase/InfoItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 装备小图标
	self.itemTypeIconImage = transform:Find('ItemNameBase/InfoItemTypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 套装标签
	self.suitFlag = transform:Find('ItemBox/Flag').gameObject
	--SSR
	self.Rarity = transform:Find('ItemBox/Rarity')
	-- 描述信息
	self.itemInfoLabel = transform:Find('ItemBox/EquipINfoTextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 等级
	self.itemLevelLabel = transform:Find('ItemBox/LevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.itemLevelLabel.text = 1
	-- 属性
	self.leftAttLabel = transform:Find('InfoBase/leftAttLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.rightAttLabel = transform:Find('InfoBase/rightAttLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	---@ 需要的物品
	self.needIconImage = transform:Find('NeedBase/ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.needColorFrame = transform:Find('NeedBase/ItemBox/ColorFrame')

	-- 进度显示
	self.needNumLabel = transform:Find('NeedBase/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.needNumBar = transform:Find('NeedBase/Bar/Fill'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 合成提示文字
	self.noticeLabel = transform:Find('NeedBase/Notice'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 碎片图标
	self.debrisImage = transform:Find('NeedBase/Debris').gameObject
	-- 合成费用
	self.coinYouNeed = transform:Find('NeedBase/CoinYouNeed').gameObject
	-- 合成费用文字
	self.coinYouNeedLabel = transform:Find('NeedBase/CoinYouNeed/NeoCardEquipPowerupCoinYouNeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 特效
	local effectCanvas = transform:Find('EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform))
	utility.SetRectDefaut(effectCanvas)
	self.effectPatical = transform:Find('EffectCanvas/UI_hecheng/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem))
end


function EquipmentWinCombineNodeCls:RegisterControlEvents()
	--	合成
	self.__event_button_onctrlCombineButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnctrlCombineButtonClicked, self)
	self.ctrlCombineButton.onClick:AddListener(self.__event_button_onctrlCombineButton_OneClicked__)
end

function EquipmentWinCombineNodeCls:UnregisterControlEvents()
	-- --取消注册 合成 的事件
	if self.__event_button_onctrlCombineButton_OneClicked__ then
		self.ctrlCombineButton.onClick:RemoveListener(self.__event_button_onctrlCombineButton_OneClicked__)
		self.__event_button_onctrlCombineButton_OneClicked__ = nil
	end
end

function EquipmentWinCombineNodeCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CEquipSuipianComposeResult, self, self.OnEquipSuipianComposeResponse)
	utility:GetGame():RegisterMsgHandler(net.S2CEquipChibangBuildResult, self, self.OnEquipChibangBuildResponse)
end

function EquipmentWinCombineNodeCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CEquipSuipianComposeResult, self, self.OnEquipSuipianComposeResponse)
	utility:GetGame():UnRegisterMsgHandler(net.S2CEquipChibangBuildResult, self, self.OnEquipChibangBuildResponse)
end

function EquipmentWinCombineNodeCls:OnEquipSuipianComposeRequest(id)
  	utility:GetGame():SendNetworkMessage( require"Network/ServerService".EquipSuipianComposeRequest(id))
end

function EquipmentWinCombineNodeCls:OnEquipChibangBuildRequest(chibangID,cardUID)
  	utility:GetGame():SendNetworkMessage( require"Network/ServerService".OnEquipChibangBuildRequest(chibangID,cardUID))
end

local function PlayEffect(self,ctable)
	self.effectPatical:Play()
	coroutine.wait(1)
	self.IsPlayingEffect = false
	self.returnFunc(ctable)
end

function EquipmentWinCombineNodeCls:OnEquipSuipianComposeResponse()
  -- 装备碎片合成结果
	
	self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,3)
	self.IsPlayingEffect = true
	-- coroutine.start(PlayEffect,self,self.ctable)
	self:StartCoroutine(PlayEffect, self.ctable)
end

local function PlayWingEffect(self,ctable,chibangID,uid,cardUID)
	self.effectPatical:Play()
	coroutine.wait(1)
	self.IsPlayingEffect = false
	--self.returnFunc(self.ctable,msg.chibangID,uid,msg.cardUID)
	self.returnFunc(ctable,chibangID,uid,cardUID)
end

function EquipmentWinCombineNodeCls:OnEquipChibangBuildResponse(msg)
	
	local UserDataType = require "Framework.UserDataType"
  	local cachedData = self:GetCachedData(UserDataType.EquipBagData)
  	local exist,equipData =  cachedData:ExistsOnCardEquipDict(msg.chibangID,msg.cardUID)
  	
  	local uid
  	if exist then
  		uid = equipData:GetEquipUID()
  	else
  		debug_print("@@@翅膀数据错误")
  		return 
  	end

  	self.IsPlayingEffect = true
	-- coroutine.start(PlayWingEffect,self,self.ctable,msg.chibangID,uid,msg.cardUID)
	self:StartCoroutine(PlayWingEffect, self.ctable,msg.chibangID,uid,msg.cardUID)
end
----------------------------------------------------------------------
local function DelayRefreshItem(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local infoData,data,name,iconPath,itype = gametool.GetItemDataById(self.combineId)
	local color = gametool.GetItemColorByType(itype,data)
	
	PropUtility.AutoSetColor(self.itemColorFrame,color)
	utility.LoadSpriteFromPath(iconPath,self.itemIconImage)
	self.itemNameLabel.text = name

	local desc = infoData:GetName()
	desc = string.format("%s%s",ShopStringTable[5],name)
	self.itemInfoLabel.text  = desc

	local suitId = data:GetTaozhuangID()
	self.suitFlag:SetActive(suitId ~= 0)

	-- 处理属性
	local attribute,mainId = data:GetEquipAttribute()
	local leftStr,rightStr = gametool.GetEquipInfoStr(attribute,mainId)
	self.rightAttLabel.text = rightStr

	local privateStr = gametool.GetEquipPrivateInfoStr(self.combineId)
	leftStr = string.format("%s%s",leftStr,privateStr)
	self.leftAttLabel.text = leftStr

	self.Rarity.gameObject:SetActive(false)

	--- 处理碎片消耗
	if self.RoleUid == nil then
		PropUtility.AutoSetColor(self.needColorFrame,color)
		utility.LoadSpriteFromPath(iconPath,self.needIconImage)
		self.debrisImage:SetActive(true)
		self.noticeLabel.text = "所需准备碎片"
		self.coinYouNeed:SetActive(false)
	else
		-- 翅膀图腾
		local _,itemData,name,iconPath,itype = gametool.GetItemDataById(self.needId)
		local icolor = gametool.GetItemColorByType(itype,itemData)
		PropUtility.AutoSetColor(self.needColorFrame,icolor)
		utility.LoadSpriteFromPath(iconPath,self.needIconImage)
		self.debrisImage:SetActive(false)
		self.noticeLabel.text = string.format("%s%s","所需",name)
		self.coinYouNeed:SetActive(true)
		self.coinYouNeedLabel.text = self.coinNeed
	end

	self.needNumLabel.text = string.format("%s%s%s",self.hasBuildNum,"/",self.needBuildNum)
	self.needNumBar.fillAmount = self.hasBuildNum / self.needBuildNum
end

function EquipmentWinCombineNodeCls:RefreshItem(id,RoleUid,ctable,returnFunc)
	local needId
	local combineId

	-- 需要多少
	local needBuildNum
	-- 拥有多少
	local hasBuildNum

	if RoleUid ~= nil then
		-- 翅膀合成
		combineId = id
		local staticData = require "StaticData.EquiWing":GetData(id)
		needId = staticData:GetNeedSuipianID()
		needBuildNum = staticData:GetNeedBuildNum()
		
		local UserDataType = require "Framework.UserDataType"
  		hasBuildNum = self:GetCachedData(UserDataType.ItemBagData):GetItemCountById(needId)
  		self.coinNeed = staticData:GetNeedCoin()
	else
		-- 装备碎片合成
		needId = id
		local staticData = require "StaticData.EquipCrap":GetData(id)
		combineId = staticData:GetEquipid()
		needBuildNum = staticData:GetNeedBuildNum()
		local UserDataType = require "Framework.UserDataType"
  		local CachedData = self:GetCachedData(UserDataType.EquipDebrisBag):GetItem(needId)
  		hasBuildNum = CachedData:GetNumber()
	end
	self.ctrlCombineButton.gameObject:SetActive(hasBuildNum >= needBuildNum)

	-- 卡牌uid
	self.RoleUid = RoleUid

	self.needId = needId
	self.combineId = combineId
	self.needBuildNum = needBuildNum
	self.hasBuildNum = hasBuildNum

	self.ctable = ctable
	self.returnFunc = returnFunc
	-- coroutine.start(DelayRefreshItem,self)
	self:StartCoroutine(DelayRefreshItem)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function EquipmentWinCombineNodeCls:OnctrlCombineButtonClicked()
	-- 合成
	if self.IsPlayingEffect == true then
		return
	end
	local windowManager = self:GetGame():GetWindowManager()
	local str = EquipStringTable[35]
	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	windowManager:Show(ConfirmDialogClass,str,self,self.OnCombineRequest)
	
end

function EquipmentWinCombineNodeCls:OnCombineRequest()
	if self.RoleUid == nil then
		self:OnEquipSuipianComposeRequest(self.needId)
	else
		print("合成 >>> ",self.combineId,self.RoleUid)
		self:OnEquipChibangBuildRequest(self.combineId,self.RoleUid)
	end
end

return EquipmentWinCombineNodeCls
