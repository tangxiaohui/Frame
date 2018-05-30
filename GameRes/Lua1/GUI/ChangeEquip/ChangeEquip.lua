local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local UnityUtils = require "Utils.Unity"
local messageGuids = require "Framework.Business.MessageGuids"
-- local messageManager = require "Network.MessageManager"
local ChangeEquipCls = Class(BaseNodeClass)

function ChangeEquipCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ChangeEquipCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ChangeEquip', function(go)
		self:BindComponent(go)
	end)
end
--cardID,	卡牌ID
--equipType, 装备类型
--toPos,	穿戴位置
--flag，	是否显示详情
function ChangeEquipCls:OnWillShow(cardID,equipType,toPos,flag)
	
	self.cardID=cardID
	local UserDataType = require "Framework.UserDataType"
   
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
   
	self.cardUID=cardBagData:GetUidFromId(self.cardID)
	 print(self.cardID,self.cardUID)
	self.equipType=equipType
	self.toPos=toPos
	self.flag=flag 
	print("******************",self.flag,flag,self.toPos)


end
function ChangeEquipCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end
function ChangeEquipCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
function ChangeEquipCls:OnResume()
	-- 界面显示时调用
	ChangeEquipCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.currentClickButton=nil
	self:RegisterEvent(messageGuids.EquipChanged, self.EquipChangedEvent)


	
end

function ChangeEquipCls:OnPause()
	-- 界面隐藏时调用
	ChangeEquipCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.EquipChanged, self.EquipChangedEvent)
end

function ChangeEquipCls:OnEnter()
	-- Node Enter时调用
	ChangeEquipCls.base.OnEnter(self)
end

function ChangeEquipCls:OnExit()
	-- Node Exit时调用
	ChangeEquipCls.base.OnExit(self)
end


function  ChangeEquipCls:EquipChangedEvent(cardID,itemUID,toPos)
	-- body
	print(cardID,itemUID,toPos,'       8888888888888888888888888888')
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ChangeEquipCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	
	--关闭Button
	self.CrossButton = transform:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	--确定Button
	self.ConferButton = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ConferButtonImage = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Image))
	--确定Button
	self.DetailsButton = transform:Find('DetailsButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--确定DetailsButtonImage
	self.DetailsButtonImage = transform:Find('DetailsButton'):GetComponent(typeof(UnityEngine.UI.Image))
	--穿戴
	self.Title1 = transform:Find('Title'):GetComponent(typeof(UnityEngine.UI.Image))
	--更换装备
	self.Title2 = transform:Find('Title (2)'):GetComponent(typeof(UnityEngine.UI.Image))
	
	if self.flag==false then
		self.DetailsButton.gameObject:SetActive(false)
		local confirmRTran = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.RectTransform))
		confirmRTran.localPosition= Vector3(0, confirmRTran.localPosition.y, confirmRTran.localPosition.z)
	end
	--Item transfrom
	self.Layout= transform:Find('Layout')
	self.DetailsButton.enabled=false
	self.ConferButton.enabled=false
	self:InitViews()
	--当前被选择的物体
	--self.currentClickButton={}
	self.lastIndex=nil

end


function ChangeEquipCls:EquipItemClicked(id,table)
		
		print("table",table.index)

		self.DetailsButton.enabled=true
		self.DetailsButtonImage.material=utility.GetCommonMaterial()
		self.ConferButtonImage.material=utility.GetCommonMaterial()
		self.ConferButton.enabled=true
		if self.lastIndex==nil then
			self.currentClickButton={}
			self.currentClickButton.itemColor=table.itemColor
			self.currentClickButton.itemID=table.itemID
			self.currentClickButton.itemUID=table.itemUID
			self.currentClickButton.bind=table.data:GetBindCardUID()

			self.lastIndex=table.index
			self.ChangeEquipScrollNode:ClearSelectedState()
			self.ChangeEquipScrollNode:AddSelectedState(table.index,true)
			self.ChangeEquipScrollNode:SetItemSelecetdState()
			self.bindUID=table.BindCardUID

		-- 	self.currentClickButton:ShowFrame(true)	
		else
			if self.lastIndex==table.index then
				-- self.currentClickButton:ShowFrame(false)
				-- self.DetailsButton.enabled=false
				-- self.currentClickButton=nil
			else
				self.currentClickButton.itemColor=table.itemColor
				self.currentClickButton.itemID=table.itemID
				self.currentClickButton.itemUID=table.itemUID
				self.currentClickButton.bind=table.data:GetBindCardUID()

				self.lastIndex=table.index
				self.ChangeEquipScrollNode:ClearSelectedState()
				self.ChangeEquipScrollNode:AddSelectedState(table.index,true)
				self.ChangeEquipScrollNode:SetItemSelecetdState()
				self.bindUID=table.BindCardUID
			end
		end
		-- print("EquipItemClicked",id,table)
		-- self.DetailsButton.enabled=true
		-- self.DetailsButtonImage.material=nil
		-- self.ConferButtonImage.material=nil
		-- self.ConferButton.enabled=true


		-- if self.currentClickButton==nil then
		-- 	self.currentClickButton=table
		-- 	self.currentClickButton:ShowFrame(true)
		-- else
		-- 	if self.currentClickButton==table then
		-- 		-- self.currentClickButton:ShowFrame(false)
		-- 		-- self.DetailsButton.enabled=false
		-- 		-- self.currentClickButton=nil
		-- 	else
		-- 		self.currentClickButton:ShowFrame(false)
		-- 		self.currentClickButton=table
		-- 		self.currentClickButton:ShowFrame(true)
		-- 	end

			
		-- end
		

end

local function FindGameObject(self,path)
	while true do
		local obj =  UnityUtils:FindGameObject(path)
		if obj ~= nil then
			local guideMgr = utility.GetGame():GetGuideManager()

			guideMgr:AddGuideEvnt(kGuideEvnt_SelectFirstWeapon)
			guideMgr:AddGuideEvnt(kGuideEvnt_Confirm2EquipWeapon)
			
			guideMgr:SortGuideEvnt()
			guideMgr:ShowGuidance()
			break

		else
			coroutine.step(1)
		end
	end



end
function ChangeEquipCls:InitViews()

	self.ChangeEquipScrollNode = require "GUI.ChangeEquip.ChangeEquipScorllNodeCls".New(self.Layout,self,self.EquipItemClicked)
	self:AddChild(self.ChangeEquipScrollNode)
	self:FilterEquip()
	local path = "ChangeEquip/Layout/ScrollContent/Viewport/Content/EquipItem/EquipIcon"


	self:StartCoroutine(FindGameObject,path)
	

end


function ChangeEquipCls:FilterEquip()





-- 筛选装备
  --self.currKnapsackType = KKnapsackItemType_EquipNormal

  local UserDataType = require "Framework.UserDataType"
  local tempData = self:GetCachedData(UserDataType.EquipBagData)

  local ddd=tempData:GetOneCardEquipsByUid(self.cardUID)
  print(ddd:Count(),"&&&&&&&&&&&&&&&&&&&&&&&")
  for i=1,ddd:Count() do
  	print(ddd:GetEntryByIndex(i),"   ------------",self.cardUID)
  	print(tempData:GetItem(ddd:GetEntryByIndex(i)):GetEquipID())
  end

  --已经装备的数量
  local count = ddd:Count()

  --tempData:Sort()
  local data = tempData:RetrievalByResultFunc(function (item)
        local itemType = item:GetEquipType()

        if  itemType == self.equipType then
        for i=1,count do
        	local tempEquipId =tempData:GetItem(ddd:GetEntryByIndex(i)):GetEquipID()
        	if item:GetEquipID()==tempEquipId then
        		return nil
        	end
        end




        	--判断是都有羁绊英雄
    --     	if item:GetEquipStaticData():GetZhuanyou()==1 then
    --     		print(item:GetEquipStaticData():GetZhuanyou(),item:GetEquipID() )
				-- local equipID = item:GetEquipID()
    --     		local comradeStaticData = require "StaticData.EquipExclusive":GetData(equipID)
   	-- 			local jibanCardID = comradeStaticData:GetJibanCardID()
    --     		for i=0,jibanCardID.Count-1 do
    --     			print(jibanCardID[i])
    --     			if jibanCardID[i]==self.cardID then
    --     				return nil
    --     			end
    --     		end
    --     	end
        	--判断是否绑定过英雄
        	-- print(item:GetBindCardUID()," |||||||||||||",type(item:GetBindCardUID()))
        	-- if item:GetBindCardUID()==self.cardUID  then

        	-- elseif item:GetBindCardUID()=="" then

        	-- else 
        	-- 	return nil

        	-- end

        	print(item:GetOnWhichCard())
        	
			--p判断是否装备者英雄
        	-- if item:GetOnWhichCard()=="" then

        	-- else 
        	-- 	return nil

        	-- end
        	print(item:GetBindCardUID(),"*************************",item:GetEquipID())

        	
          local uid = item:GetEquipUID()
          return true,uid
        end
        return nil 
  end)
  local count = data:Count()    
	self.ChangeEquipScrollNode:UpdateScrollContent(count,data)
	self.ChangeEquipScrollNode:ResetVerticalOffset(1)

end
function ChangeEquipCls:RegisterControlEvents()

	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)


	-- 注册 ConferButton 的事件
	self.__event_button_onConferButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked, self)
	self.ConferButton.onClick:AddListener(self.__event_button_onConferButtonClicked__)

	-- 注册 DetailsButton 的事件
	self.__event_button_onDetailsButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDetailsButtonClicked, self)
	self.DetailsButton.onClick:AddListener(self.__event_button_onDetailsButtonClicked__)

	
end

function ChangeEquipCls:UnregisterControlEvents()


	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end

	-- 取消注册 ConferButton 的事件
	if self.__event_button_onConferButtonClicked__ then
		self.ConferButton.onClick:RemoveListener(self.__event_button_onConferButtonClicked__)
		self.__event_button_onConferButtonClicked__ = nil
	end
		-- 取消注册 DetailsButton 的事件
	if self.__event_button_onDetailsButtonClicked__ then
		self.DetailsButton.onClick:RemoveListener(self.__event_button_onDetailsButtonClicked__)
		self.__event_button_onDetailsButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function ChangeEquipCls:RegisterNetworkEvents()
	 self.game:RegisterMsgHandler(net.S2CEquipPutOnResult, self, self.EquipPutOnResult)
	 self.game:RegisterMsgHandler(net.S2CEquipPutOffResult, self, self.EquipPutOffResult)
	 self.game:RegisterMsgHandler(net.S2CEquipDismissBindResult, self, self.OnEquipDismissBindResponse)
end

function ChangeEquipCls:UnregisterNetworkEvents()
	 self.game:UnRegisterMsgHandler(net.S2CEquipPutOnResult, self, self.EquipPutOnResult)
	 self.game:UnRegisterMsgHandler(net.S2CEquipPutOffResult, self, self.EquipPutOffResult)
	 self.game:UnRegisterMsgHandler(net.S2CEquipDismissBindResult, self, self.OnEquipDismissBindResponse)

end


function ChangeEquipCls:EquipPutOnResult(msg)
	
	--CrossButton控件的点击事件处理
	local eventMgr = self.game:GetEventManager()
    eventMgr:PostNotification(messageGuids.EquipChanged,nil, self.cardID,self.currentClickButton.itemUID,self.toPos)
    print("&&&&&&&&&&&&&&&&&&&&&&&&&")
--	self:PostNotification(messageGuids.EquipChanged, self.currentClickButton.itemUID,self.toPos)
	self:DispatchEvent(messageGuids.CloseEquipWindow)
	self:Close()

end
function ChangeEquipCls:EquipPutOffResult(msg)

	if msg.state==0 then

	

		print(msg.state, msg.cardUID,msg.equipUID,"$$$$$$$$$$$$$$$$$$$$$$$$$$$$",self.lastEquipUid,self.cardUID)
		if msg.cardUID==self.cardUID and msg.equipUID==self.lastEquipUid then
			print("))))))))))))))))))))))))))")
			if self.DetailsButton.enabled==true then
				print("((((((((((((((((((((((((((((((")
				self.game:SendNetworkMessage(require "Network.ServerService".EquipPutOnRequest(self.cardUID,self.currentClickButton.itemUID,self.toPos))
			end

   		 end
	end
	print(msg.state, msg.cardUID,msg.equipUID)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

function ChangeEquipCls:OnCrossButtonClicked()
	--CrossButton控件的点击事件处理
	self:Close()
end
--绑定装备返回函数
function ChangeEquipCls:BindCallBack( ... )
	
	print("BindCallBack")
		--DetailsButton控件的点击事件处理
	--分发事件
	local UserDataType = require "Framework.UserDataType"
  	local equipBagData = self:GetCachedData(UserDataType.EquipBagData)
  	local dataDic = equipBagData:GetOneCardEquipsByUid(self.cardUID)

	if dataDic:Contains(self.toPos) then
		print("^^^^^^^^^^^^^^^^^^^^^")
		self.game:SendNetworkMessage(require "Network.ServerService".EquipPutOffRequest(self.cardUID,dataDic:GetEntryByKey(self.toPos)))
		self.lastEquipUid=dataDic:GetEntryByKey(self.toPos)
	else
			print("OOOOOOOOOOOOOOOOOO")
		if self.DetailsButton.enabled==true then
			print(self.cardUID,self.currentClickButton.itemUID,self.toPos)
			self.game:SendNetworkMessage(require "Network.ServerService".EquipPutOnRequest(self.cardUID,self.currentClickButton.itemUID,self.toPos))
		end
	end


end


function ChangeEquipCls:OnRoleBingdingButtonClicked()
	
	local windowManager = self:GetGame():GetWindowManager()
	local str = EquipStringTable[36].."\n"..EquipStringTable[33]
	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	windowManager:Show(ConfirmDialogClass,str,self,self.OnOnEquipDismissBindRequestEvent)
end

function ChangeEquipCls:OnOnEquipDismissBindRequestEvent()
	self:OnEquipDismissBindRequest(self.currentClickButton.itemUID)
end

function ChangeEquipCls:OnEquipDismissBindRequest(equipUID)
	self.game:SendNetworkMessage( require"Network/ServerService".OnEquipDismissBindRequest(equipUID))
end

function ChangeEquipCls:OnEquipDismissBindResponse(msg)
	---假数据随便写
	self.currentClickButton.bind="OKyixiexia"
	
	self:ChangeEquipItem()

end

function ChangeEquipCls:ChangeEquipItem()

	print(self.currentClickButton.itemColor,self.equipType,self.currentClickButton.itemColor,"   ...................",self.currentClickButton.bind)
	if (((self.currentClickButton.itemColor>=3 and self.equipType ~=5)or(self.equipType ==6))and self.currentClickButton.bind=="") then
	print(self.currentClickButton.itemColor,self.equipType,self.currentClickButton.itemColor)
		local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
		local windowManager = utility:GetGame():GetWindowManager()
	   	windowManager:Show(ConfirmDialogClass, EquipStringTable[33],self, self.BindCallBack)
	else
		self:BindCallBack()

	end

end


function ChangeEquipCls:OnConferButtonClicked()
	if self.bindUID~=nil and self.bindUID ~="" and self.bindUID~=self.cardUID then
		self:OnRoleBingdingButtonClicked()
	else
		self:ChangeEquipItem()
	end
end


function ChangeEquipCls:OnDetailsButtonClicked()
		--CrossButton控件的点击事件处理
	local windowManager = utility:GetGame():GetWindowManager()
	windowManager:Show(require "GUI.EquipmentWindow.EquipmentWindow",self.currentClickButton.itemUID,self.currentClickButton.itemID,KEquipWinShowType_BaseInfo,nil,nil,false)



end


return ChangeEquipCls
