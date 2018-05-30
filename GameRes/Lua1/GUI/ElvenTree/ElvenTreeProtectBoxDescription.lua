local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
require "System.LuaDelegate"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeProtectBoxDescriptionCls = Class(BaseNodeClass)


function ElvenTreeProtectBoxDescriptionCls:Ctor()
	self.callback = LuaDelegate.New()

end
function ElvenTreeProtectBoxDescriptionCls:SetCallback(tables,func)
	self.tables=tables
    self.callback:Set(tables,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeProtectBoxDescriptionCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTreeProtectBoxDescription', function(go)
		self:BindComponent(go)
	end)
end

function ElvenTreeProtectBoxDescriptionCls:OnWillShow(table,info,todayProtectCount,func)

	self.info=info
	self.todayProtectCount=todayProtectCount
	self.callback:Set(table,func)
	print(type(info))
end


function ElvenTreeProtectBoxDescriptionCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ElvenTreeProtectBoxDescriptionCls:OnResume()
	-- 界面显示时调用
	ElvenTreeProtectBoxDescriptionCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
    self:InitViews()
end

function ElvenTreeProtectBoxDescriptionCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeProtectBoxDescriptionCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ElvenTreeProtectBoxDescriptionCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeProtectBoxDescriptionCls.base.OnEnter(self)
end

function ElvenTreeProtectBoxDescriptionCls:OnExit()
	-- Node Exit时调用
	ElvenTreeProtectBoxDescriptionCls.base.OnExit(self)
end


function  ElvenTreeProtectBoxDescriptionCls:InitViews( )

local GameTools = require "Utils.GameTools"
			local _,staticData,itemName,iconPath,itemType = GameTools.GetItemDataById(self.info.itemID)
		local PropUtility = require "Utils.PropUtility"
			local defaultColor = GameTools.GetItemColorByType(itemType, staticData)
			print(self.info.itemColor)
			utility.LoadSpriteFromPath(iconPath,self.ItemIcon)
   			
    --    print("颜色 颜色 颜色 颜色", self.itemColor,self.ColorFrameGroupTrans)
    		PropUtility.AutoSetRGBColor(self.ColorFrameGroupTrans, self.itemColor or defaultColor)
	if self.info.protect ~=nil then
		if self.info.protect==1 then
			self.Notice2.enabled=true
			self.Notice4.enabled=false
			self.ElvenTreeDescriptionLabel.enabled=false
			self.DyaIconImage.enabled=false
			self.ShieldImage.enabled=false
			self.ElvenTreeDescriptionButton__1_.gameObject.transform.localPosition=Vector3(self.comfirmPosition.x-100,self.comfirmPosition.y,0)
			self.ElvenTreeDescriptionButton.gameObject:SetActive(false)
			print("已经保护了")
			self.Notice2.text="已经保护了"
		
		else

			self.Notice2.enabled=true
			self.Notice4.enabled=true
			self.Notice2.text="是否进行保护"
			self.ElvenTreeDescriptionLabel.enabled=true
			self.ElvenTreeDescriptionButton__1_.gameObject.transform.localPosition=self.comfirmPosition
			self.ElvenTreeDescriptionButton.gameObject:SetActive(true)
			
			--local _,_,itemName,iconPath = GameTools.GetItemDataById(self.info.itemID)
			
			
			
   			local UserDataType = require "Framework.UserDataType"
    		local itemCardData = self:GetCachedData(UserDataType.ItemBagData)
    		local count=itemCardData:GetItemCountById(10300020)

    		debug_print(count)
    		if count ~=0 then
    			self.type=1
    			self.DyaIconImage.enabled=false
				self.ShieldImage.enabled=true
			 	self.ElvenTreeDescriptionLabel.text=1--"保护修理装备"..itemName.."不被抢走,需要守护盾1枚,是否进行？(当前拥有:)"..count.."个"

			 else
			 	self.type=2
			 	self.DyaIconImage.enabled=true
				self.ShieldImage.enabled=false
			 	local FactoryProtectionFeesData = require"StaticData/Factory/FactoryProtectionFees"
			 	debug_print(self.todayProtectCount.."保护费是：",FactoryProtectionFeesData:GetData(self.todayProtectCount):GetProtectPrice())
			 	
				self.ElvenTreeDescriptionLabel.text=FactoryProtectionFeesData:GetData(self.todayProtectCount):GetProtectPrice()--"保护修理装备"..itemName.."不被抢走,需要钻石"..FactoryProtectionFeesData:GetData(self.todayProtectCount):GetProtectPrice()..",是否进行？"
			 	end
		end
	end
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeProtectBoxDescriptionCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility:GetGame()
	
	-- self.TranslucentLayer = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BigFarme = transform:Find('SmallWindowBase/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.UpperBorder = transform:Find('SmallWindowBase/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GrayFarme = transform:Find('SmallWindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BlackTitleBase = transform:Find('SmallWindowBase/BlackTitleBase'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Title = transform:Find('SmallWindowBase/Title'):GetComponent(typeof(UnityEngine.UI.Text))
	 self.ElvenTreeDescriptionButton = transform:Find('CancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	 self.ElvenTreeDescriptionCrossButton = transform:Find('SmallWindowBase/CheckInDescriptionRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
		--背景按钮
	self.BackgroundButton = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.ElvenTreeDescriptionLabel = transform:Find('NeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Notice2 = transform:Find('Notice (2)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Notice4 = transform:Find('Notice (4)'):GetComponent(typeof(UnityEngine.UI.Text))

	self.ElvenTreeDescriptionButton__1_ = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.comfirmPosition=self.ElvenTreeDescriptionButton__1_.gameObject.transform.localPosition
	self.ItemIcon= transform:Find('ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
		self.ColorFrameGroupTrans=transform:Find('ItemBox/Frame')

	self.DyaIconImage = transform:Find('DyaIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ShieldImage = transform:Find('DyaIcon (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DyaIconImage.enabled=false
	self.ShieldImage.enabled=false
	self.Notice2.enabled=false
	self.Notice4.enabled=false
	self.ElvenTreeDescriptionLabel.enabled=false
end


function ElvenTreeProtectBoxDescriptionCls:RegisterControlEvents()
	-- 注册 ElvenTreeDescriptionButton 的事件
	self.__event_button_onElvenTreeDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButtonClicked, self)
	self.ElvenTreeDescriptionButton.onClick:AddListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)

	-- 注册 ElvenTreeDescriptionButton 的事件
	self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButtonClicked, self)
	self.ElvenTreeDescriptionCrossButton.onClick:AddListener(self.__event_button_onElvenTreeDescriptionCrossButtonClicked__)

	-- 注册 ElvenTreeDescriptionButton__1_ 的事件
	self.__event_button_onElvenTreeDescriptionButton__1_Clicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButton__1_Clicked, self)
	self.ElvenTreeDescriptionButton__1_.onClick:AddListener(self.__event_button_onElvenTreeDescriptionButton__1_Clicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function ElvenTreeProtectBoxDescriptionCls:UnregisterControlEvents()
	-- 取消注册 ElvenTreeDescriptionButton 的事件
	if self.__event_button_onElvenTreeDescriptionButtonClicked__ then
		self.ElvenTreeDescriptionButton.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)
		self.__event_button_onElvenTreeDescriptionButtonClicked__ = nil
	end

	if self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ then
		self.ElvenTreeDescriptionCrossButton.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionCrossButtonClicked__)
		self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ = nil
	end

	-- 取消注册 ElvenTreeDescriptionButton__1_ 的事件
	if self.__event_button_onElvenTreeDescriptionButton__1_Clicked__ then
		self.ElvenTreeDescriptionButton__1_.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionButton__1_Clicked__)
		self.__event_button_onElvenTreeDescriptionButton__1_Clicked__ = nil
	end
		-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ElvenTreeProtectBoxDescriptionCls:OnElvenTreeDescriptionButtonClicked()
	--ElvenTreeDescriptionButton控件的点击事件处理
	self:Hide()
end

function ElvenTreeProtectBoxDescriptionCls:OnElvenTreeDescriptionButton__1_Clicked()
	--请求保护物品
	--ElvenTreeDescriptionButton__1_控件的点击事件处理

	if self.info.protect ~=nil then
		if self.info.protect==1 then
				self:Hide()
		else
		self.game:SendNetworkMessage(require "Network.ServerService".TakeBoxInProtectedRequest(self.info.itemUID,self.type))

		end
	end
end



function ElvenTreeProtectBoxDescriptionCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CTakeBoxInProtectedResult, self, self.TakeBoxInProtectedResult)
end


function ElvenTreeProtectBoxDescriptionCls:UnregisterNetworkEvents()
self.game:RegisterMsgHandler(net.S2CTakeBoxInProtectedResult, self, self.TakeBoxInProtectedResult)
end

--TakeBoxInProtectedRequest 保护返回事件

function ElvenTreeProtectBoxDescriptionCls:TakeBoxInProtectedResult()

	self.callback:Invoke(self.info.itemUID)
	self:Hide()
	-- self.callback:Invoke(self.tables,self.Info.itemUID)
	-- self:Hide()
end
return ElvenTreeProtectBoxDescriptionCls
