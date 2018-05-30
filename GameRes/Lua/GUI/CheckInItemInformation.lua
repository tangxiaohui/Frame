local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
--local net = require "Network.Net"
local CheckInItemInformationCls = Class(BaseNodeClass)


function CheckInItemInformationCls:Ctor()
	

end
function CheckInItemInformationCls:OnWillShow(info,itemNum,itemID,itemColor)
	self.Info=info
	self.ItemNum=itemNum
	self.ItemID=itemID
	self.ItemColor=itemColor
--	print("************************************")
	-- print("head",self.Info.head,"equipUID",self.Info.equip.equipUID,
	-- 	"equipID",self.Info.equip.equipID,"level",self.Info.equip.level,
	-- 	"pos",self.Info.equip.pos,"bindCardUID",self.Info.equip.bindCardUID,
	-- 	"onWhichCard",self.Info.equip.onWhichCard,"exp",self.Info.equip.exp,
	-- 	"color",self.Info.equip.color,"stoneID",self.Info.equip.stoneID,
	-- 	"stoneUID",self.Info.equip.stoneUID,"mod",self.Info.mod)
	-- print("555555555555555555555555")
end
--- 场景状态
-----------------------------------------------------------------------
function CheckInItemInformationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CheckInItemInformation', function(go)
		self:BindComponent(go)
	end)
end

function CheckInItemInformationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()	
end

function CheckInItemInformationCls:OnResume()
	-- 界面显示时调用
	CheckInItemInformationCls.base.OnResume(self)
	self:InitView()
	self:GetUnityTransform():SetAsLastSibling()
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
	
end

function CheckInItemInformationCls:OnPause()
	-- 界面隐藏时调用
	CheckInItemInformationCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function CheckInItemInformationCls:OnEnter()
	-- Node Enter时调用
	CheckInItemInformationCls.base.OnEnter(self)
end

function CheckInItemInformationCls:OnExit()
	-- Node Exit时调用
	CheckInItemInformationCls.base.OnExit(self)

end
-- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CheckInItemInformationCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	--页面返回按钮
	self. CheckInItemInformationRetrunButton = transform:Find('CheckInItemInformationRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))--
	--页面确定按钮
	self. CheckInItemInformationConfirmButton = transform:Find('CheckInItemInformationQueDingButton'):GetComponent(typeof(UnityEngine.UI.Button))--
	--领取信息Image
	self. CheckInItemInformationImage = transform:Find('CheckInItemInformationIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--领取数量的信息
	self. CheckInItemInformationDrawText=transform:Find('CheckInItemInformationNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--物品的描述信息
	self. CheckInItemInformationDescriptionText=transform:Find('Scroll View/Viewport/Content/CheckInItemInformationDescriptionLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--领取数量的信息
	self. CheckInItemInformationNameText=transform:Find('CheckInItemInformationNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--卡的颜色
	
	self.colorTrans = transform:Find('Frame')
	-- self.colorArr[1] = transform:Find('Frame/Color01')
	-- self.colorArr[2] = transform:Find('Frame/Color02')
	-- self.colorArr[3] = transform:Find('Frame/Color03')
	-- self.colorArr[4] = transform:Find('Frame/Color04')
	-- self.colorArr[5] = transform:Find('Frame/Color05')
	-- self.colorArr[6] = transform:Find('Frame/Color06')

end
local function GetItemDescription(itemType,infoData)	
	if itemType == "Role" then		
		return infoData:GetDesc()
	elseif itemType == "Equip" then		
		return infoData:GetDesc()
	elseif itemType == "Item" then		
		return infoData:GetDesc()
	elseif itemType =="RoleChip" then	
		return infoData:GetDesc()
	elseif itemType == "EquipCrap"then		
		return infoData:GetInfo()	
	elseif itemType =="FactoryItem" then		
		return infoData:GetDesc()
	elseif itemType ==nil then
		print("物品类型108 无此描述")
	end
	error("----物品类型错误----")
	return nil
end

function CheckInItemInformationCls:InitView()
	--显示ICON
	local infoData 
	local data
	local itemName
	local iconPath

	if self.Info  then
	--	print(55555,self.Info.equip.equipID)
		self.equipID=self.Info.equip.equipID
		self.equipColor=self.Info.equip.color
	
	else
	--	print(666666,self.ItemID,self.ItemColor)
		self.equipID=self.ItemID
		self.equipColor=self.ItemColor

	end
	local  infoData,data,itemName,iconPath,itemTypeStr
	local gameTool = require "Utils.GameTools"
	infoData,data,itemName,iconPath,itemTypeStr = gameTool.GetItemDataById(self.equipID)
		utility.LoadSpriteFromPath(iconPath,self.CheckInItemInformationImage)
		--显示领取的数量
		self. CheckInItemInformationDrawText.text=nil--"X"..self.ItemNum
		--显示名字
		self. CheckInItemInformationNameText.text=itemName
		--显示信息
		self. CheckInItemInformationDescriptionText.text=GetItemDescription(itemTypeStr,infoData)


		local PropUtility = require "Utils.PropUtility"
    --    print("颜色 颜色 颜色 颜色", self.itemColor,self.ColorFrameGroupTrans)
   	    PropUtility.AutoSetColor(self.colorTrans, self.equipColor)

		-- --判断颜色
		-- if self.equipColor>0 then
		-- 	self.colorArr[0].gameObject:SetActive(false)
		-- 	self.colorArr[self.equipColor].gameObject:SetActive(true)	

		-- end
end



function CheckInItemInformationCls:RegisterControlEvents()
	 -- 注册 CheckInItemInformationConfirmButton 的事件
	 self.__event_button_onCheckInItemInformationRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInItemInformationButtonClicked, self)
	 self.CheckInItemInformationRetrunButton.onClick:AddListener(self.__event_button_onCheckInItemInformationRetrunButtonClicked__)
	-- 注册 CheckInItemInformationConfirmButton 的事件
	 self.__event_button_onCheckInItemInformationConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInItemInformationButtonClicked, self)
	 self.CheckInItemInformationConfirmButton.onClick:AddListener(self.__event_button_onCheckInItemInformationConfirmButtonClicked__)

end

function CheckInItemInformationCls:UnregisterControlEvents()
	-- 取消注册 CheckInItemInformationRetrunButton 的事件
	 if self.__event_button_onCheckInItemInformationRetrunButtonClicked__ then
	    self.CheckInItemInformationRetrunButton.onClick:RemoveListener(self.__event_button_onCheckInItemInformationRetrunButtonClicked__)
	    self.__event_button_onCheckInItemInformationRetrunButtonClicked__ = nil
	 end
	 -- 取消注册 CheckInRetrunButton 的事件
	 if self.__event_button_onCheckInItemInformationConfirmButtonClicked__ then
	    self.CheckInItemInformationConfirmButton.onClick:RemoveListener(self.__event_button_onCheckInItemInformationConfirmButtonClicked__)
	    self.__event_button_onCheckInItemInformationConfirmButtonClicked__ = nil
	 end


end

function CheckInItemInformationCls:RegisterNetworkEvents()
	
   -- self.game:RegisterMsgHandler(net.S2CDailySignInQueryResult, self, self.DailySignInQueryResult)

end

function CheckInItemInformationCls:UnregisterNetworkEvents()
   -- self.game:UnRegisterMsgHandler(net.S2CDailySignInQueryResult, self, self.DailySignInQueryResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CheckInItemInformationCls:OnCheckInItemInformationButtonClicked()
	--返回控件的点击事件处理
	-- self.colorArr[0].gameObject:SetActive(true)
	-- for i=2,#self.colorArr do
	-- 	self.colorArr[i].gameObject:SetActive(false)
	-- end
	
    self:Hide()
end

function CheckInItemInformationCls:OnCheckInDescriptionButtonClicked()

end

function CheckInItemInformationCls:DailySignInQueryResult(msg)
	
end

return CheckInItemInformationCls
