local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local CheckInItemCls = Class(BaseNodeClass)
require "System.LuaDelegate"

function CheckInItemCls:Ctor(parent,info,stage,maskImage)
	self.Parent = parent
	self.Info = info
	--签到里程碑
	self.stage=stage
	self.maskImage=maskImage
	self.callback = LuaDelegate.New()
	print("物品状态",self.Info.day,self.Info.state)

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CheckInItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CheckInItem', function(go)
		self:BindComponent(go,false)
	end)
end

function CheckInItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.Parent)
--	self
end

function CheckInItemCls:OnResume()
	-- 界面显示时调用
	CheckInItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	if  self.Info.state==1 then
		--self.DrawButton.enabled=true
		self:RegisterNetworkEvents()

		
	else
		-- if self.Effect ~=nil then
		-- 	self.Effect:SetActive(false)
		-- end
	end
	self:InitView()
	
end

function CheckInItemCls:SetCallback(tables,func)
	--print(tables,func)
	self.tables=tables
    self.callback:Set(tables,func)
end

function CheckInItemCls:ChoseEffect(flag)
	self.Effect:SetActive(flag)
end




function CheckInItemCls:OnPause()
	-- 界面隐藏时调用
	CheckInItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	if  self.Info.state==1 then
		--self.DrawButton.enabled=true
		self:UnregisterNetworkEvents()
	end
end

function CheckInItemCls:OnEnter()
	-- Node Enter时调用
	CheckInItemCls.base.OnEnter(self)
end

function CheckInItemCls:OnExit()
	-- Node Exit时调用
	CheckInItemCls.base.OnExit(self)
end

function CheckInItemCls:IsOpen()
	-- if self.Info.

end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CheckInItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	
	--领取按钮
	self.DrawButton = transform:Find('CheckInItemIcon'):GetComponent(typeof(UnityEngine.UI.Button))--
	--领取数量Text
	self.CheckInNumText = transform:Find('CheckInNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--是否领取对号
	self.CheckInIsDrawImage = transform:Find('CheckInItemHook'):GetComponent(typeof(UnityEngine.UI.Image))
	--显示领取的物体
	self.CheckInItemImage = transform:Find('CheckInItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--VIP双分
	self.CheckInDoubleVipItemImage = transform:Find('CheckInItemVip')
	self.CheckInDoubleVipRankItemText = transform:Find('CheckInItemVip/CheckInItemVipLable'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DebrisIcon= transform:Find('DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DebrisIconBack=transform:Find('DebrisIcon (1)')
	--卡的颜色
	--self.colorArr={}
	self.color=transform:Find('Frame')
	-- self.colorArr[0] = transform:Find('Frame/Color00')
	-- self.colorArr[1] = transform:Find('Frame/Color01')
	-- self.colorArr[2] = transform:Find('Frame/Color02')
	-- self.colorArr[3] = transform:Find('Frame/Color03')
	-- self.colorArr[4] = transform:Find('Frame/Color04')
	-- self.colorArr[5] = transform:Find('Frame/Color05')
	-- self.colorArr[6] = transform:Find('Frame/Color06')
--	self.DrawButton.enabled=false
	self.CheckInIsDrawImage.enabled=false

	
end

--初始化控件显示
function CheckInItemCls:InitView()
	--如果可以签到 button 可以点击
	if  self.Info.state==1 then
		self.DrawButton.enabled=true	

		local resPathMgr = require "StaticData.ResPath"
		local data = resPathMgr:GetData(1014)
		self.path=data:GetPath()
		local Object = UnityEngine.Object
		self.Effect = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject)))
		self.Effect.transform:SetParent(self.CheckInItemImage.transform)
		self.effectScript=self.Effect:AddComponent(typeof(ChangeMaterialValue))
		self.effectScript:Init(self.tables.maskImage,self.CheckInItemImage)
		self.Effect.transform.localScale=Vector3(90, 90, 1);
		self.Effect.transform.localPosition=Vector3(0, 0, -1);
		self.Effect:SetActive(true)


	--如果已经签到过了显示对号
    elseif  self.Info.state==2 then
		self.CheckInIsDrawImage.enabled=true
		self.DrawButton.enabled=false
		self.CheckInItemImage.color= UnityEngine.Color(0.58, 0.58, 0.58, 1)
		end
	if self.Info.itemNum>1 then
		self.CheckInNumText.text=self.Info.itemNum
	else self.CheckInNumText.text=nil
		end

	self.double=false
--判断是否是VIP双份
	if self.Info.doubleVip>0 then
		self.double=true
		--处理显示 
		if self.Info.doubleVip<10 then
			self.CheckInDoubleVipRankItemText.text="V"..self.Info.doubleVip.." 双倍"
		else
			self.CheckInDoubleVipRankItemText.text="V"..self.Info.doubleVip.."双倍"
		end
	else
		self.CheckInDoubleVipItemImage.gameObject:SetActive(false)

	end


	local infData 
	local data
	local itemName
	local iconPath
	local itemTypeStr
	local gameTool = require "Utils.GameTools"
	infData,data,itemName,iconPath,itemTypeStr = gameTool.GetItemDataById(self.Info.itemID)
	utility.LoadSpriteFromPath(iconPath,self.CheckInItemImage)

	if itemTypeStr == "RoleChip"  or itemTypeStr == "EquipChip" then
	
		self.DebrisIcon.gameObject:SetActive(true)
		self.DebrisIconBack.gameObject:SetActive(true)
	end


	--判断颜色
	--print(self.Info.itemColor,"*************************************",type(GetItemColor(itemTypeStr,data)),self.Info.itemID)
	  -- 设置颜色

	
	--print(self.Info.itemColor,"&&&&&&&&&&&&&&&&&&&&&&&&&&")
    local PropUtility = require "Utils.PropUtility"
    --    print("颜色 颜色 颜色 颜色", self.itemColor,self.ColorFrameGroupTrans)
   

	if self.Info.itemColor>0 then
		 
	elseif self.Info.itemColor==-1 then
		 self.Info.itemColor=gameTool.GetItemColorByType(itemTypeStr,data)
		-- self.colorArr[0].gameObject:SetActive(false)
		-- self.colorArr[self.Info.itemColor].gameObject:SetActive(true)
	end
	PropUtility.AutoSetRGBColor(self.color, self.Info.itemColor)
end

--注册控制事件
function CheckInItemCls:RegisterControlEvents()

	-- 注册 PersonalInformationRetrunButton 的事件
	self.__event_button_onDrawButtonClicked__ = UnityEngine.Events.UnityAction(self.ClickDrawButton, self)
	self.DrawButton.onClick:AddListener(self.__event_button_onDrawButtonClicked__)
end
--取消注册事件
function CheckInItemCls:UnregisterControlEvents()

	if self.__event_button_onDrawButtonClicked__ then
		self.DrawButton.onClick:RemoveListener(self.__event_button_onDrawButtonClicked__)
		self.__event_button_onDrawButtonClicked__ = nil
	end
end
--监听网络事件
function CheckInItemCls:RegisterNetworkEvents()
	 
    self.game:RegisterMsgHandler(net.S2CDailySignInDrawResult, self, self.DailySignInDraw)
    self.game:RegisterMsgHandler(net.S2CEquipBagFlush, self, self.EquipBagFlushResult)

end
--取消监听网络事件
function CheckInItemCls:UnregisterNetworkEvents()
    self.game:UnRegisterMsgHandler(net.S2CDailySignInDrawResult, self, self.DailySignInDraw)
    self.game:UnRegisterMsgHandler(net.S2CEquipBagFlush, self, self.EquipBagFlushResult)

end

--点击领取按钮事件
function CheckInItemCls:ClickDrawButton()
	print("点击领取按钮",self.Info.day,self.Info.state)
		--如果可以签到 button 可以点击
	if self.Info.state==1 then
		if self.stage then
			self.game:SendNetworkMessage(require"Network/ServerService".DailySignInDrawRequest(self.Info.day,100))
		else
			self.game:SendNetworkMessage(require"Network/ServerService".DailySignInDrawRequest(self.Info.day,-1))
		end
	else
		self:ShowItemInfo()
	--	print("签到不可领取物品被点击信息显示窗口入口",self.Info.state)
	end


end

function CheckInItemCls:ShowItemInfo()

	
	
	

	local modV = math.floor(self.Info.itemID/100000)
	if modV==100 then
		-- local sceneManager = self:GetGame():GetSceneManager()
        -- local senceCls = require "GUI.Collection.CollectionCardInfo"
        -- sceneManager:PushScene(senceCls.New(self.Info.itemID))
		local windowManager = utility:GetGame():GetWindowManager()
		windowManager:Show(require "GUI.Collection.CollectionCardInfo",self.Info.itemID)

	else
		local gameTool = require "Utils.GameTools"
		gameTool.ShowItemWin(self.Info.itemID)

	end

	
	-- body
	
   -- end
end
--点击领取按钮事件
function CheckInItemCls:DailySignInDraw(msg)
	hzj_print("领取事件返回",self.Info.day,msg.day)
	if msg.day== self.Info.day then

	self.Effect:SetActive(false)
	self.CheckInIsDrawImage.enabled=true
	self.CheckInItemImage.color= UnityEngine.Color(0.58, 0.58, 0.58, 1)
--	print(self.Info.day)
	self.DrawButton.enabled=false	
	self.callback:Invoke(self.tables,self.Info.day,self.Info.day)
	self.Info.state=2

	local modV = math.floor(self.Info.itemID/100000)
	if modV==100 then

		local UserDataType = require "Framework.UserDataType"
		local cardBagData = self:GetCachedData(UserDataType.CardBagData)
		local card= cardBagData:GetRoleById(self.Info.itemID)

		self.addCardDict = OrderedDictionary.New()
		if card ==nil then
			self.addCardDict:Add(self.Info.itemID,self.Info.itemID)
		end
		local windowManager = self.game:GetWindowManager()
   		windowManager:Show(require "GUI.GeneralCard.GetCardWin",self.Info.itemID,addCardDict)

   	elseif modV==101 then

			local gameTool = require "Utils.GameTools"
			gameTool.GetItemWin(self.Info.itemID)

   	else

   		local windowManager = self:GetGame():GetWindowManager()
  		local AwardCls = require "GUI.Task.GetAwardItem"
  		self.items={}
  		self.items[1]={}
  		self.items[1].id=self.Info.itemID
  		if self.double == true then
  			self.items[1].count=self.Info.itemNum*2
  		else 
			self.items[1].count=self.Info.itemNum
  		end
  		self.items[1].count=self.Info.itemNum
  		self.items[1].color=self.Info.itemColor
   		windowManager:Show(AwardCls,self.items)

	end

end






end

function CheckInItemCls:EquipBagFlushResult(msg)

	
	-- local windowManager = self.game:GetWindowManager()
 --    windowManager:Show(require"GUI.CheckInItemInformation",nil,nil,self.Info.itemID,self.Info.itemColor)

end

return CheckInItemCls