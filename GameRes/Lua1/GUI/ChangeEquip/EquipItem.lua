local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
require "System.LuaDelegate"
local EquipItemCls = Class(BaseNodeClass)

function EquipItemCls:Ctor(parent,itemWidth,itemHigh)
	self.parent = parent
	self.callback = LuaDelegate.New()
end

function EquipItemCls:SetCallback(ctable,func)
	self.ctable=ctable
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipItem', function(go)
		self:BindComponent(go,false)
	end)
end

function EquipItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function EquipItemCls:OnResume()
	-- 界面显示时调用
	EquipItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function EquipItemCls:OnPause()
	-- 界面隐藏时调用
	EquipItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function EquipItemCls:OnEnter()
	-- Node Enter时调用
	EquipItemCls.base.OnEnter(self)
end

function EquipItemCls:OnExit()
	-- Node Exit时调用
	EquipItemCls.base.OnExit(self)
end

function EquipItemCls:SetSelectedState(active)
	self.ConerParent.gameObject:SetActive(active)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.rectTransform=transform:GetComponent(typeof(UnityEngine.RectTransform))

	
	--颜色
	self.Frame = transform:Find('Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	--图标
	self.EquipIcon = transform:Find('EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--按钮
	self.EquipButton = transform:Find('EquipIcon'):GetComponent(typeof(UnityEngine.UI.Button))

	--绑定标识
	self.Bind = transform:Find('Bind'):GetComponent(typeof(UnityEngine.UI.Image))
	--套装
	self.Flag = transform:Find('Flag')
	
	self.Text = transform:Find('Flag/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	--名字
	self.ItemNameLabel = transform:Find('ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--状态
	self.ItemStatusLabel = transform:Find('ItemStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--级别
	self.ItemLevelNuLabel = transform:Find('ItemLevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--选中框
	self.ConerParent = transform:Find('SelectBox')
	--
	self.Flag.gameObject:SetActive(false)
	self.RaceIconImage = transform:Find('RaceIconImage'):GetComponent(typeof(UnityEngine.UI.Image))

	self.Bind.enabled=false
	
end


function EquipItemCls:RegisterControlEvents()
	self.__event_button_onEquipButtonClicked__ = UnityEngine.Events.UnityAction(self.OnEquipButtonClicked, self)
	self.EquipButton.onClick:AddListener(self.__event_button_onEquipButtonClicked__)


end

function EquipItemCls:UnregisterControlEvents()

	if self.__event_button_onEquipButtonClicked__ then
		self.EquipButton.onClick:RemoveListener(self.__event_button_onEquipButtonClicked__)
		self.__event_button_onEquipButtonClicked__ = nil
	end
end

function EquipItemCls:RegisterNetworkEvents()
end

function EquipItemCls:UnregisterNetworkEvents()
end
function EquipItemCls:OnEquipButtonClicked()
	print("OnEquipButtonClicked")
--	self.ConerParent.gameObject:SetActive(true)
	self.callback:Invoke(self.itemUID,self)
end
--显示框
function EquipItemCls:ShowFrame(flag)
	self.ConerParent.gameObject:SetActive(flag)
	print("Test",self.itemUID,flag)
	if flag then
		self.beClicked=self.itemUID
	else
		self.beClicked=nil
	end
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

local function DelayOnBind(self,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.rectTransform.sizeDelta = Vector2(self.itemWidth,self.itemHigh)

	self:ResetItem(data)
end

function EquipItemCls:OnBind(data,index,args)

	self.data = data
	self.index = index	
	-- coroutine.start(DelayOnBind,self,data)
	self:StartCoroutine(DelayOnBind, data)
end
function EquipItemCls:OnUnbind()
	
end

local function DelayResetPosition(self,position)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.rectTransform.anchoredPosition = position
end

function EquipItemCls:ResetPosition(position)
	-- coroutine.start(DelayResetPosition,self,position)
	self:StartCoroutine(DelayResetPosition, position)
end

function EquipItemCls:ResetItem(data)

	--self:ShowFrame(flag)
	self.Bind.enabled=false
	self.data=data
	--名字及级别
	self.ItemNameLabel.text=data:GetName()
	self.ItemLevelNuLabel.text='LV'..data:GetLevel()

	--KEquipType_EquipAccessories = 3 ---  3.饰品
	--KEquipType_EquipShoesr = 4 	  ---  4.鞋子
	local KEquipType = data:GetEquipType()
	if KEquipType == KEquipType_EquipAccessories or KEquipType == KEquipType_EquipShoesr then
		self.ItemLevelNuLabel.text=''
	end

	self.itemUID=data:GetEquipUID()
	self.itemID=data:GetEquipID()
	--套装设置
	local staticData =require "StaticData.Equip"
	local equipData = staticData:GetData(data:GetEquipID())
	local suit = equipData:GetTaozhuangID() 
	if suit>0 then
		self.Flag.gameObject:SetActive(true)
	else
		self.Flag.gameObject:SetActive(false)
	end
	--设置颜色
	self.itemColor=data:GetColor()
	--解绑
	self.unbundling=equipData:GetNeedJiebangNum()
	local PropUtility = require "Utils.PropUtility"
	PropUtility.AutoSetRGBColor(self.Frame,self.itemColor)


	-- 设置图标
	local AtlasesLoader = require "Utils.AtlasesLoader"
    local GameTools = require "Utils.GameTools"
    local _,_,_,iconPath,itemType = GameTools.GetItemDataById(data:GetEquipID())    
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon)

    --增加的属性

  	local equipType =equipData:GetMainPropID()
  	local _,basis=data:GetBasisValue(equipType)
  	local addition = equipData:GetPromoteValue()
  	
  	self.ItemStatusLabel.text=EquipStringTable[equipType].."<color=#00DC6E>+"..GameTools.UpdatePropValue(equipType,data:CalculateAddValue(basis,addition,data:GetLevel())).." </color>"

 -- 	print(self.ctable.cardUID,"&&&&&&&&&&&&&&&&&&&&&",data:GetBindCardUID(),"&&&&&&&&&&&&&&&&&&&&&",self.itemID,"&&&&&&&&&&&&&&&&&&&&&",self.itemUID)
  	self.BindCardUID=data:GetBindCardUID()
  	if data:GetBindCardUID()~="" then
  		self.Bind.enabled=true
  	end
  --	print(self.BindCardUID,"   *************")
	--   print(self.itemUID,self.beClicked,"点击")
	-- if self.beClicked ~=nil and self.itemUID==self.beClicked then
	-- 	self.ConerParent.gameObject:SetActive(true)
	-- else
	-- 	self.ConerParent.gameObject:SetActive(false)
	-- end
	--如果是宠物显示种族绑定
	local itemEquipType = equipData:GetType()
	if itemEquipType == 10 then
  --	debug_print(raceAddType,111111111111111111111111)
  		self.RaceIconImage.gameObject:SetActive(true)
		local raceAddType = equipData:GetRaceAdd()
		utility.LoadRaceIcon(raceAddType,self.RaceIconImage)
	else
 	--	debug_print(itemType,2222222222222222222)
		self.RaceIconImage.gameObject:SetActive(false)

	end


--	print(equipData:GetTaozhuangID(),"HHHHHHHHHHHHHHHHHHHHHHH",data:GetName(),data:GetEquipID(),data:GetColor())
end

return EquipItemCls
