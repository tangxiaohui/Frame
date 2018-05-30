local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local itemDictionary = require "Collection.OrderedDictionary"
 local net = require "Network.Net"
 local messageGuids = require "Framework.Business.MessageGuids"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeCls = Class(BaseNodeClass)
function ElvenTreeCls:Ctor()

end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTree', function(go)
		self:BindComponent(go)
	end)
end

function ElvenTreeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()

end

function ElvenTreeCls:OnResume()
	
	require "Utils.GameAnalysisUtils".EnterScene("精灵树界面")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_ElvenTreeView)
	-- 界面显示时调用
	ElvenTreeCls.base.OnResume(self)
	self:RegisterEvent(messageGuids.UpdatedOneCard, self.OnCardUpdateEvent)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	--刷新当前的战力
	-- self:RefeshFightingCapacity()
	-- self:RefeshBattleFormation()
	self.game:SendNetworkMessage(require "Network.ServerService".RobQueryRequest(100,-1))
	self:ScheduleUpdate(self.Update)
	hzj_print(self.ElvenTreeFormationButton,"  6666")
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[1].systemGuideID,self)
end

function ElvenTreeCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.UpdatedOneCard, self.OnCardUpdateEvent)
	


end
 --local messageGuids = require "Framework.Business.MessageGuids"

function ElvenTreeCls:OnCardUpdateEvent(cardData)
	self.cardData=cardData
--	print("**************************************************************************************")

end


function ElvenTreeCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeCls.base.OnEnter(self)
end

function ElvenTreeCls:OnExit()
	-- Node Exit时调用
	ElvenTreeCls.base.OnExit(self)
end
function ElvenTreeCls:Update()
	self:UpdateTime()
end
--刷新金币钻石体力信息显示s
function ElvenTreeCls:RefreshCurrency()
	  -- 设置货币刷新
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    self.TheMainTiLiLabel.text = string.format("%d/%d", userData:GetVigor(), userData:GetMaxVigor())
    self.TheMainMoneyLabel.text = userData:GetCoin()
    self.TheMainDiamondLabel.text = userData:GetDiamond()
end

--更新时间
function ElvenTreeCls:UpdateTime()
	local countFlag = false
	if os.time()-self.lastT>=1 then
		self.lastT=os.time()
		countFlag=true
	end

	if self.countTime ~=nil then
		if self.countTime<=0 then
			self.ElvenTreeSnatchTimesLabel.text=""
			
		else
		--	self.countTime=self.countTime-Time.deltaTime
			if countFlag then
			--	self.lastT=os.time()
				self.countTime=self.countTime-1
			end

			--sdebug_print(self.countTime)
			--print(self.countTime)
			self.ElvenTreeSnatchTimesLabel.text="冷却时间: "..utility.ConvertTime(self.countTime)
		end	
	end

	for i=1,#self.repairingBoxItems do
		--表示已经开启
		if self.repairingBoxItems[i].containItem then
			--表示没有包含物体
			if self.repairingBoxItems[i].countTime>0 then
				if countFlag then
					
					self.repairingBoxItems[i].countTime=self.repairingBoxItems[i].countTime-1
					self.repairingBoxItems[i].label.text=utility.ConvertTime(self.repairingBoxItems[i].countTime)
				--	print(self.repairingBoxItems[i].countTime)
					end
			else
				self.repairingBoxItems[i].label.text=""
				--请求刷新
				if not self.repairingBoxItems[i].refresh then
				--	print(self.repairingBoxItems[i].itemUID,"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",self.repairingBoxItems[i].countTime,self.repairingBoxItems[i].containItem)
					self.repairingBoxItems[i].refresh=true
					self.repairingBoxItems[i].flag=true
					--表示是否有了物体
					self.repairingBoxItems[i].containItem=false
					--当前修复物体的倒计时
					self.repairingBoxItems[i].countTime=nil
					--当前修复物体的Id
					self.repairingBoxItems[i].itemID=nil
					--当前修复物体的UID
					self.repairingBoxItems[i].itemUID=nil	
					self.repairingBoxItems[i].image.sprite=nil	
					self.repairingBoxItems[i].image.color=UnityEngine.Color(1, 1, 1, 0)			
					--self.repairingBoxItems[i].colorTrans.gameObject:SetActive(false)
					self.repairingBoxItems[i].timeTrans.gameObject:SetActive(false)
					self.repairingBoxItems[i].protect=nil
					self.repairingBoxItems[i].shieldImage.enabled=false
					self.game:SendNetworkMessage(require "Network.ServerService".RobQueryRequest(0,-1))
					end
				end
			
		end
    end


end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility:GetGame()
	
	--返回按钮
	self.ArenaReturnButton = transform:Find('ArenaReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	--self.AnnouncementBase = transform:Find('Announcement/AnnouncementBase'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.TheMainAnnouncementLabel = transform:Find('Announcement/TheMainAnnouncementLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--体力添加Button
	self.TiLiAddButton = transform:Find('Currency/TiLi/TiLiAddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--体力显示Text
	self.TheMainTiLiLabel = transform:Find('Currency/TiLi/TheMainTiLiLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--金币添加Button
	self.MoneyAddButton = transform:Find('Currency/Money/MoneyAddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--金币显示Text
	self.TheMainMoneyLabel = transform:Find('Currency/Money/TheMainMoneyLabel'):GetComponent(typeof(UnityEngine.UI.Text))	
	--钻石添加Button
	self.DiamondAddButton = transform:Find('Currency/Diamond/DiamondAddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--钻石显示Text
	self.TheMainDiamondLabel = transform:Find('Currency/Diamond/TheMainDiamondLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- self.BaseFormation = transform:Find('Formation/BaseFormation'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BlackShading = transform:Find('Formation/BlackShading'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.TitleFormation = transform:Find('Formation/TitleFormation'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.ElvenTreeRightButton = transform:Find('Formation/ElvenTreeRightButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.ElvenTreeLeftButton = transform:Find('Formation/ElvenTreeLeftButton'):GetComponent(typeof(UnityEngine.UI.Button))


	--self.BaseWarehouse = transform:Find('Warehouse/BaseWarehouse'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.BlackShadingWarehouse = transform:Find('Warehouse/BlackShadingWarehouse'):GetComponent(typeof(UnityEngine.UI.Image))
	--Title 显示文字
	self.TitleWarehouse = transform:Find('Warehouse/TitleWarehouse'):GetComponent(typeof(UnityEngine.UI.Text))
	--可修复与可开启切换Button
	self.ElvenTreeWarehouseSwitchButton = transform:Find('Warehouse/ElvenTreeWarehouseSwitchButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--可修复Image
	self.ElvenTreeWarehouseSwitchRepairImage = transform:Find('Warehouse/ElvenTreeWarehouseSwitchButton/ElvenTreeWarehouseSwitchButtonTextImage'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.ElvenTreeWarehouseSwitchRepairImage.gameObject:SetActive(true)
	--可开启Image
	self.ElvenTreeWarehouseSwitchOpenImage = transform:Find('Warehouse/ElvenTreeWarehouseSwitchButton/ElvenTreeWarehouseSwitchOpenButtonTextImage'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.ElvenTreeWarehouseSwitchOpenImage.gameObject:SetActive(false)
	--可开启列表父物体
	self.ElvenTreeOpenItemLayoutScrollView = transform:Find('Warehouse/Scroll View')
	self.ElvenTreeOpenItemLayoutTrans = transform:Find('Warehouse/Scroll View/Viewport/Content')
	self.ElvenTreeOpenItemLayoutScrollView.gameObject:SetActive(true)

	--可开启列表滑动条
	--self.ElvenTreeOpenItemLayoutScrollbar = transform:Find('Warehouse/Scroll View/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))

	--待修复列表父物体
	self.ElvenTreeRepairItemLayoutScrollView = transform:Find('Warehouse/Scroll View (1)')
	self.ElvenTreeRepairItemLayoutTrans = transform:Find('Warehouse/Scroll View (1)/Viewport/Content')
	self.ElvenTreeRepairItemLayoutScrollView.gameObject:SetActive(false)
	--待修复列表滑动条
	--self.ElvenTreeRepairItemLayoutScrollbar = transform:Find('Warehouse/Scroll View (1)/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))

	--战力Text
	self.ElvenTreeStrengthNumLabel = transform:Find('Strength/ElvenTreeStrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--描述信息Button
	self.ElvenTreeFormationButton = transform:Find('ButtonList/ElvenTreeFormationButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--抢夺Button
	self.ElvenTreeSnatchButton = transform:Find('ButtonList/ElvenTreeSnatchButton'):GetComponent(typeof(UnityEngine.UI.Button))

	--阵容信息Button
	self.ElvenTreeFormationImageButton = transform:Find('Formation/FormationButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	--阵容信息Button
	self.ElvenTreeDescriptionButton = transform:Find('ButtonList/ElvenTreeDescriptionButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--战报Button
	self.ElvenTreeReportButton = transform:Find('ButtonList/ElvenTreeReportButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BaseQueue = transform:Find('Queue/BaseQueue'):GetComponent(typeof(UnityEngine.UI.Image))
	--抢夺次数Text
	self.ElvenTreeSnatchNumLabel = transform:Find('Queue/ElvenTreeSnatchTimesLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--抢夺红点
	self.ElvenTreeSnatchButtonRedDot = transform:Find('ButtonList/ElvenTreeSnatchButton/RedDot'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ElvenTreeSnatchButtonRedDot.enabled=false
	--	--抢夺时间Text
	self.ElvenTreeSnatchTimesLabel = transform:Find('Queue/ElvenTreeSnatchTimesLabel (1)'):GetComponent(typeof(UnityEngine.UI.Text))

---------------------精灵树升级---------------------------------------------
	self.treeStatusText={}
	self.treeStatusText[#self.treeStatusText+1]=transform:Find('Status/Layout/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.treeStatusText[#self.treeStatusText+1]=transform:Find('Status/Layout/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.treeStatusText[#self.treeStatusText+1]=transform:Find('Status/Layout/Text (2)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.treeStatusText[#self.treeStatusText+1]=transform:Find('Status/Layout/Text (3)'):GetComponent(typeof(UnityEngine.UI.Text))
	--精灵树加成
	self.treeStatusTitleText=transform:Find('Status/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	--精灵树等级
	self.treeStatusLvText=transform:Find('TreeLevel/LevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--培养Button
	self.LevelUpButton=transform:Find('Status/LevelUpButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.LevelUpRodDot = transform:Find('Status/LevelUpButton/RedDot')

	self.BackGround = transform:Find('BackGround'):GetComponent(typeof(UnityEngine.UI.Image))
----------------------------------------------------------------------------


	--精灵树中修复中的蛋物体
	self.repairingBoxItems={}
	--五个修复的箱子创建五个表
	for i=1,5 do
		self.repairingBoxItems[i]={}
	
		--表示是否有了物体
		self.repairingBoxItems[i].containItem=false
		--当前修复物体的倒计时
		self.repairingBoxItems[i].countTime=nil
		--当前修复物体的Id
		self.repairingBoxItems[i].itemID=nil
		--当前修复物体的UID
		self.repairingBoxItems[i].itemUID=nil
		--当前修复物体时间到了 请求刷新
		self.repairingBoxItems[i].refresh=false
		--是否保护
		self.repairingBoxItems[i].protect=nil
		

	end
	--修复器的显示IMage button以及Text
	--时间的trans
	self.repairingBoxItems[1].timeTrans = transform:Find('Queue/Queue01/Time01')
	self.repairingBoxItems[1].image = transform:Find('Queue/Queue01/ElvenTreeQueue01Item01'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[1].button = transform:Find('Queue/Queue01/ElvenTreeQueue01Item01'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[1].label = transform:Find('Queue/Queue01/Time01/ElvenTreeQueue01TimeLabel01'):GetComponent(typeof(UnityEngine.UI.Text))
	self.repairingBoxItems[1].shieldImage = transform:Find('Queue/Queue01/ShieldImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[1].SpeedUpButton = transform:Find('Queue/Queue01/SpeedUpButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[1].SpeedUpButton.gameObject:SetActive(false)
	self.repairingBoxItems[1].shieldImage.enabled=false
	self.repairingBoxItems[1].image.color=UnityEngine.Color(1, 1, 1, 0)
	
	--self.repairingBoxItems[1].colorTrans = transform:Find('Queue/Queue01/ElvenTreeQueue01Item01/Frame01')
	self.repairingBoxItems[1].flag=true
	self.repairingBoxItems[1].label.text =""
	--self.repairingBoxItems[1].colorTrans.gameObject:SetActive(false)
	self.repairingBoxItems[1].button.enabled=false
	self.repairingBoxItems[1].timeTrans.gameObject:SetActive(false)

--时间的trans
	self.repairingBoxItems[2].timeTrans = transform:Find('Queue/Queue02/Time02')
	self.repairingBoxItems[2].image = transform:Find('Queue/Queue02/ElvenTreeQueue02Item02'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[2].shieldImage = transform:Find('Queue/Queue02/ShieldImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[2].shieldImage.enabled=false
	self.repairingBoxItems[2].SpeedUpButton = transform:Find('Queue/Queue02/SpeedUpButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[2].SpeedUpButton.gameObject:SetActive(false)

	self.repairingBoxItems[2].button = transform:Find('Queue/Queue02/ElvenTreeQueue02Item02'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[2].label = transform:Find('Queue/Queue02/Time02/ElvenTreeQueue02TimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.repairingBoxItems[2].colorTrans = transform:Find('Queue/Queue02/ElvenTreeQueue02Item02/Frame02')
	self.repairingBoxItems[2].label.text =""
	self.repairingBoxItems[2].flag=true
	--self.repairingBoxItems[2].colorTrans.gameObject:SetActive(false)
	self.repairingBoxItems[2].button.enabled=false
	self.repairingBoxItems[2].image.color=UnityEngine.Color(1, 1, 1, 0)
	--self.repairingBoxItems[2].timeTrans.gameObject:SetActive(false)
	
	--时间的trans
	self.repairingBoxItems[3].timeTrans = transform:Find('Queue/Queue03/Time03')
	self.repairingBoxItems[3].image = transform:Find('Queue/Queue03/ElvenTreeQueue03Item'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[3].shieldImage = transform:Find('Queue/Queue03/ShieldImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[3].shieldImage.enabled=false
	self.repairingBoxItems[3].SpeedUpButton = transform:Find('Queue/Queue03/SpeedUpButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[3].SpeedUpButton.gameObject:SetActive(false)
	
	self.repairingBoxItems[3].button = transform:Find('Queue/Queue03/ElvenTreeQueue03Item'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[3].label = transform:Find('Queue/Queue03/Time03/ElvenTreeQueue03TimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.repairingBoxItems[3].colorTrans = transform:Find('Queue/Queue03/ElvenTreeQueue03Item/Frame03')
	self.repairingBoxItems[3].flag=true
	self.repairingBoxItems[3].label.text=""
	--self.repairingBoxItems[3].colorTrans.gameObject:SetActive(false)
	self.repairingBoxItems[3].timeTrans.gameObject:SetActive(false)
	self.repairingBoxItems[3].button.enabled=false
	self.repairingBoxItems[3].image.color=UnityEngine.Color(1, 1, 1, 0)
	
	--时间的trans
	self.repairingBoxItems[4].timeTrans = transform:Find('Queue/Queue04/Time04')
	--锁的trans
	self.repairingBoxItems[4].lockTrans = transform:Find('Queue/Queue04/Lock04')
	self.repairingBoxItems[4].redDot = transform:Find('Queue/Queue04/Lock04/RedDot')
	--修复蛋的图片
	self.repairingBoxItems[4].image = transform:Find('Queue/Queue04/ElvenTreeQueue04Item'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[4].shieldImage = transform:Find('Queue/Queue04/ShieldImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[4].shieldImage.enabled = false
	self.repairingBoxItems[4].image.color=UnityEngine.Color(1, 1, 1, 0)
	self.repairingBoxItems[4].SpeedUpButton = transform:Find('Queue/Queue04/SpeedUpButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[4].SpeedUpButton.gameObject:SetActive(false)

	--修复蛋的button
	self.repairingBoxItems[4].button = transform:Find('Queue/Queue04/ElvenTreeQueue04Item'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[4].button.enabled = false
	--时间显示
	self.repairingBoxItems[4].label = transform:Find('Queue/Queue04/Time04/ElvenTreeQueue04TimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--锁的按钮
	self.repairingBoxItems[4].lockButton = transform:Find('Queue/Queue04/Lock04/LockImage04'):GetComponent(typeof(UnityEngine.UI.Button))
	--Vip label
	self.repairingBoxItems[4].vipLabel = transform:Find('Queue/Queue04/Lock04/ElvenTreeQueue04VipOpenLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--钻石label
	self.repairingBoxItems[4].diamondLabel = transform:Find('Queue/Queue04/Lock04/Currency04/ElvenTreeQueue04CurrencyNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.repairingBoxItems[4].colorTrans = transform:Find('Queue/Queue04/ElvenTreeQueue04Item/Frame04')
	self.repairingBoxItems[4].label.text=""
--	self.repairingBoxItems[4].colorTrans.gameObject:SetActive(false)




	--时间的trans
	self.repairingBoxItems[5].timeTrans = transform:Find('Queue/Queue05/Time05')
	--锁的trans
	self.repairingBoxItems[5].lockTrans = transform:Find('Queue/Queue05/Lock05')
	self.repairingBoxItems[5].redDot = transform:Find('Queue/Queue05/Lock05/RedDot')
	--修复蛋的图片
	self.repairingBoxItems[5].image = transform:Find('Queue/Queue05/ElvenTreeQueue05Item'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[5].shieldImage = transform:Find('Queue/Queue05/ShieldImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[5].shieldImage.enabled=false
	--修复蛋的button
	self.repairingBoxItems[5].button = transform:Find('Queue/Queue05/ElvenTreeQueue05Item'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[5].SpeedUpButton = transform:Find('Queue/Queue05/SpeedUpButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.repairingBoxItems[5].SpeedUpButton.gameObject:SetActive(false)
	self.repairingBoxItems[5].button.enabled=false
	--时间显示
	self.repairingBoxItems[5].label = transform:Find('Queue/Queue05/Time05/ElvenTreeQueue05TimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--锁的按钮
	self.repairingBoxItems[5].lockButton=transform:Find('Queue/Queue05/Lock05/LockImage05'):GetComponent(typeof(UnityEngine.UI.Button))
	
	self.repairingBoxItems[5].vipLabel = transform:Find('Queue/Queue05/Lock05/ElvenTreeQueue05VipOpenLabel'):GetComponent(typeof(UnityEngine.UI.Text))
--	self.CurrencyImage05 = transform:Find('Queue/Queue05/Lock05/Currency05/CurrencyImage05'):GetComponent(typeof(UnityEngine.UI.Image))
	self.repairingBoxItems[5].diamondLabel = transform:Find('Queue/Queue05/Lock05/Currency05/ElvenTreeQueue05CurrencyNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.repairingBoxItems[5].image.color=UnityEngine.Color(1, 1, 1, 0)
	--self.repairingBoxItems[5].colorTrans = transform:Find('Queue/Queue05/ElvenTreeQueue05Item/Frame05')
	self.repairingBoxItems[5].label.text=""
	--self.repairingBoxItems[5].colorTrans.gameObject:SetActive(false)

	self.LayoutBack=transform:Find('Formation/LayoutBack')
	self.LayoutFront=transform:Find('Formation/LayoutFront')

	--购买抢夺次数按钮
	self.BuyRobTimeButton = transform:Find('Queue/BuyTime'):GetComponent(typeof(UnityEngine.UI.Button))

	
	--可开起队列
	self.openItem={}
	--可开起队列
	self.repairItem={}
	--所有的Item队列
	self.allItem={}
	--当前战力
	self.fightingCapacity=0

	--上次时间
	self.lastT =0
	
	--精灵树中修复中的蛋
	self.repairingBox={}
	--精灵树中的敌人
	self.enemy={}
	--防御阵型
	self.formations={}
		--刷新当前的金币钻石等数据
	self:RefreshCurrency()
	-- --刷新当前的战力	
--	self:RefeshFightingCapacity()
	-- --刷新当前的战力	
--	self:RefeshBattleFormation()
	--
	self.msg={}

end
--刷新战力
function ElvenTreeCls:RefeshFightingCapacity()
	self.fightingCapacity=0
	-- 刷新防守上阵阵容
	local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local elvenTreeDefence = cardBagData:GetTroopByLineup(kLineup_ElvenTree)
	local data=nil
    for i=1,#elvenTreeDefence do
    	if elvenTreeDefence[i] ~= 0 then
    --	print(elvenTreeDefence[i],self.cardData:GetUid(),self.cardData)
	    	--if not self.cardData ==nil then
	    		--print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN")
		        if self.cardData:GetUid()== elvenTreeDefence[i] then
				    data=self.cardData
				    self.fightingCapacity=self.fightingCapacity+self.msg.robotCard.zhanli
				else
		    	    data = cardBagData:GetRoleByUid(elvenTreeDefence[i])	
		    	    self.fightingCapacity=self.fightingCapacity+data:GetPower()
		    	end
		  --   else
				-- print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN")
		  --   	 data = cardBagData:GetRoleByUid(elvenTreeDefence[i])	
		  --   	 self.fightingCapacity=self.fightingCapacity+data:GetPower()
		  --  end
		
    	end
    	--print(self.fightingCapacity,"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",elvenTreeDefence[i])
    end
    self.ElvenTreeStrengthNumLabel.text = self.fightingCapacity
	
end

--第一次创建

--刷新当前的阵容
function ElvenTreeCls:RefeshBattleFormation()
	self.formations={}
	local roleNodeCls = require "GUI.Arena.FormationItem"
	local emptyNodeCls = require "GUI.Arena.EmptyFormationNode"
	local node
	local layout

	local UserDataType = require "Framework.UserDataType"
   
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local elvenTreeDefence = cardBagData:GetTroopByLineup(kLineup_ElvenTree)

    -- 上阵阵容
  --	local arenaDefenceFormation = {}

  	local power = 0
    local count = 0
    for i=1,#elvenTreeDefence do
    	
    	if i < 4 then
    		layout = self.LayoutFront
    	else
    		layout = self.LayoutBack
    	end

    	if elvenTreeDefence[i] ~= 0 then
    		local uid = elvenTreeDefence[i]
    	--	local data = cardBagData:GetRoleByUid(uid)
    		if self.cardData:GetUid()== elvenTreeDefence[i] then
				data=self.cardData
			else
	    		data = cardBagData:GetRoleByUid(uid)	
	    	end
    		power = power + data:GetPower()
    		count = count + 1
    		node = roleNodeCls.New(layout,i,true)
    		node:ResetView(data)
    	else
    		node = emptyNodeCls.New(layout)
    	end
    	self:AddChild(node)
    	self.formations[#self.formations + 1] = node

    end
    self.ElvenTreeStrengthNumLabel.text = power

	
end




function ElvenTreeCls:RegisterControlEvents()
	-- 注册 ArenaReturnButton 的事件
	self.__event_button_onArenaReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaReturnButtonClicked, self)
	self.ArenaReturnButton.onClick:AddListener(self.__event_button_onArenaReturnButtonClicked__)

	-- 注册 TiLiAddButton 的事件
	self.__event_button_onTiLiAddButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTiLiAddButtonClicked, self)
	self.TiLiAddButton.onClick:AddListener(self.__event_button_onTiLiAddButtonClicked__)

	-- 注册 MoneyAddButton 的事件
	self.__event_button_onMoneyAddButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMoneyAddButtonClicked, self)
	self.MoneyAddButton.onClick:AddListener(self.__event_button_onMoneyAddButtonClicked__)

	-- 注册 DiamondAddButton 的事件
	self.__event_button_onDiamondAddButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDiamondAddButtonClicked, self)
	self.DiamondAddButton.onClick:AddListener(self.__event_button_onDiamondAddButtonClicked__)

	-- 注册 ElvenTreeWarehouseSwitchButton 的事件
	self.__event_button_onElvenTreeWarehouseSwitchButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeWarehouseSwitchButtonClicked, self)
	self.ElvenTreeWarehouseSwitchButton.onClick:AddListener(self.__event_button_onElvenTreeWarehouseSwitchButtonClicked__)

	-- 注册 ElvenTreeFormationButton 的事件
	self.__event_button_onElvenTreeFormationButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeFormationButtonClicked, self)
	self.ElvenTreeFormationButton.onClick:AddListener(self.__event_button_onElvenTreeFormationButtonClicked__)

	-- 注册 ElvenTreeFormationButton 的事件
	self.__event_button_onElvenTreeFormationImageButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeFormationButtonClicked, self)
	self.ElvenTreeFormationImageButton.onClick:AddListener(self.__event_button_onElvenTreeFormationImageButtonClicked__)



	-- 注册 ElvenTreeSnatchButton 的事件
	self.__event_button_onElvenTreeSnatchButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeSnatchButtonClicked, self)
	self.ElvenTreeSnatchButton.onClick:AddListener(self.__event_button_onElvenTreeSnatchButtonClicked__)

    -- 注册 BuyRobTimeButton 的事件
	self.__event_button_onBuyRobTimeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBuyRobTimeButtonClicked, self)
	self.BuyRobTimeButton.onClick:AddListener(self.__event_button_onBuyRobTimeButtonClicked__)

	-- 注册 ElvenTreeDescriptionButton 的事件
	self.__event_button_onElvenTreeDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButtonClicked, self)
	self.ElvenTreeDescriptionButton.onClick:AddListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)
	
	-- 注册 ElvenTreeReportButton 的事件
	self.__event_button_onElvenTreeReportButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeReportButtonClicked, self)
	self.ElvenTreeReportButton.onClick:AddListener(self.__event_button_onElvenTreeReportButtonClicked__)

		-- 注册 repairingBoxItems[4].lockButton 的事件
	self.__event_button_onRepairingBoxItems4lockButtonClicked__ = UnityEngine.Events.UnityAction(self.RepairingBoxItems4LockButtonClicked, self)
	self.repairingBoxItems[4].lockButton.onClick:AddListener(self.__event_button_onRepairingBoxItems4lockButtonClicked__)
			-- 注册 repairingBoxItems[5].lockButto 的事件
	self.__event_button_onRepairingBoxItems5lockButtonClicked__ = UnityEngine.Events.UnityAction(self.RepairingBoxItems5LockButtonClicked, self)
	self.repairingBoxItems[5].lockButton.onClick:AddListener(self.__event_button_onRepairingBoxItems5lockButtonClicked__)
			-- 注册 repairingBoxItems[4].button 的事件
	self.__event_button_onRepairingBoxItems4ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnrepairingBoxItems4ButtonClicked, self)
	self.repairingBoxItems[4].button.onClick:AddListener(self.__event_button_onRepairingBoxItems4ButtonClicked__)
			-- 注册 repairingBoxItems[5].button 的事件

	--	print(self.repairingBoxItems[5].button,"OIIIIIIIIII")
	self.__event_button_onRepairingBoxItems5ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnrepairingBoxItems5ButtonClicked, self)
	self.repairingBoxItems[5].button.onClick:AddListener(self.__event_button_onRepairingBoxItems5ButtonClicked__)

	self.__event_button_onRepairingBoxItems3ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnrepairingBoxItems3ButtonClicked, self)
	self.repairingBoxItems[3].button.onClick:AddListener(self.__event_button_onRepairingBoxItems3ButtonClicked__)
			-- 注册 repairingBoxItems[5].button 的事件
	self.__event_button_onRepairingBoxItems2ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnrepairingBoxItems2ButtonClicked, self)
	self.repairingBoxItems[2].button.onClick:AddListener(self.__event_button_onRepairingBoxItems2ButtonClicked__)

	self.__event_button_onRepairingBoxItems1ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnrepairingBoxItems1ButtonClicked, self)
	self.repairingBoxItems[1].button.onClick:AddListener(self.__event_button_onRepairingBoxItems1ButtonClicked__)


	--精灵树培养Button
	self.__event_button_onLevelUpButtonClicked__ = UnityEngine.Events.UnityAction(self.OnLevelUpButtonClicked, self)
	self.LevelUpButton.onClick:AddListener(self.__event_button_onLevelUpButtonClicked__)

	self.__event_button_onSpeedUpButton1ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSpeedUpButton1ButtonClicked, self)
	self.repairingBoxItems[1].SpeedUpButton.onClick:AddListener(self.__event_button_onSpeedUpButton1ButtonClicked__)
	
	self.__event_button_onSpeedUpButton2ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSpeedUpButton2ButtonClicked, self)
	self.repairingBoxItems[2].SpeedUpButton.onClick:AddListener(self.__event_button_onSpeedUpButton2ButtonClicked__)
	
	self.__event_button_onSpeedUpButton3ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSpeedUpButton3ButtonClicked, self)
	self.repairingBoxItems[3].SpeedUpButton.onClick:AddListener(self.__event_button_onSpeedUpButton3ButtonClicked__)
	
	self.__event_button_onSpeedUpButton4ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSpeedUpButton4ButtonClicked, self)
	self.repairingBoxItems[4].SpeedUpButton.onClick:AddListener(self.__event_button_onSpeedUpButton4ButtonClicked__)
	
	self.__event_button_onSpeedUpButton5ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSpeedUpButton5ButtonClicked, self)
	self.repairingBoxItems[5].SpeedUpButton.onClick:AddListener(self.__event_button_onSpeedUpButton5ButtonClicked__)

end

function ElvenTreeCls:UnregisterControlEvents()

	
	if self.__event_button_onSpeedUpButton1ButtonClicked__ then
		self.repairingBoxItems[1].SpeedUpButton.onClick:RemoveListener(self.__event_button_onSpeedUpButton1ButtonClicked__)
		self.__event_button_onSpeedUpButton1ButtonClicked__ = nil
	end

	if self.__event_button_onSpeedUpButton2ButtonClicked__ then
		self.repairingBoxItems[2].SpeedUpButton.onClick:RemoveListener(self.__event_button_onSpeedUpButton2ButtonClicked__)
		self.__event_button_onSpeedUpButton2ButtonClicked__ = nil
	end

	if self.__event_button_onSpeedUpButton3ButtonClicked__ then
		self.repairingBoxItems[3].SpeedUpButton.onClick:RemoveListener(self.__event_button_onSpeedUpButton3ButtonClicked__)
		self.__event_button_onSpeedUpButton3ButtonClicked__ = nil
	end

	if self.__event_button_onSpeedUpButton4ButtonClicked__ then
		self.repairingBoxItems[4].SpeedUpButton.onClick:RemoveListener(self.__event_button_onSpeedUpButton4ButtonClicked__)
		self.__event_button_onSpeedUpButton4ButtonClicked__ = nil
	end

	if self.__event_button_onSpeedUpButton5ButtonClicked__ then
		self.repairingBoxItems[5].SpeedUpButton.onClick:RemoveListener(self.__event_button_onSpeedUpButton5ButtonClicked__)
		self.__event_button_onSpeedUpButton5ButtonClicked__ = nil
	end


	-- 取消注册 LevelUpButton 的事件
	if self.__event_button_onLevelUpButtonClicked__ then
		self.LevelUpButton.onClick:RemoveListener(self.__event_button_onLevelUpButtonClicked__)
		self.__event_button_onLevelUpButtonClicked__ = nil
	end
		-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onRepairingBoxItems4lockButtonClicked__ then
		self.repairingBoxItems[4].lockButton.onClick:RemoveListener(self.__event_button_onRepairingBoxItems4lockButtonClicked__)
		self.__event_button_onRepairingBoxItems4lockButtonClicked__ = nil
	end
			-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onRepairingBoxItems5lockButtonClicked__ then
		self.repairingBoxItems[5].lockButton.onClick:RemoveListener(self.__event_button_onRepairingBoxItems5lockButtonClicked__)
		self.__event_button_onRepairingBoxItems5lockButtonClicked__ = nil
	end
			-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onRepairingBoxItems4ButtonClicked__ then
		self.repairingBoxItems[4].button.onClick:RemoveListener(self.__event_button_onRepairingBoxItems4ButtonClicked__)
		self.__event_button_onRepairingBoxItems4ButtonClicked__ = nil
	end
			-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onRepairingBoxItems5ButtonClicked__ then
		self.repairingBoxItems[5].button.onClick:RemoveListener(self.__event_button_onRepairingBoxItems5ButtonClicked__)
		self.__event_button_onRepairingBoxItems5ButtonClicked__ = nil
	end	
		-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onRepairingBoxItems3ButtonClicked__ then
		self.repairingBoxItems[3].button.onClick:RemoveListener(self.__event_button_onRepairingBoxItems3ButtonClicked__)
		self.__event_button_onRepairingBoxItems3ButtonClicked__ = nil
	end
			-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onRepairingBoxItems2ButtonClicked__ then
		self.repairingBoxItems[2].button.onClick:RemoveListener(self.__event_button_onRepairingBoxItems2ButtonClicked__)
		self.__event_button_onRepairingBoxItems2ButtonClicked__ = nil
	end		-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onRepairingBoxItems1ButtonClicked__ then
		self.repairingBoxItems[1].button.onClick:RemoveListener(self.__event_button_onRepairingBoxItems1ButtonClicked__)
		self.__event_button_onRepairingBoxItems1ButtonClicked__ = nil
	end




	-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onArenaReturnButtonClicked__ then
		self.ArenaReturnButton.onClick:RemoveListener(self.__event_button_onArenaReturnButtonClicked__)
		self.__event_button_onArenaReturnButtonClicked__ = nil
	end

	-- 取消注册 TiLiAddButton 的事件
	if self.__event_button_onTiLiAddButtonClicked__ then
		self.TiLiAddButton.onClick:RemoveListener(self.__event_button_onTiLiAddButtonClicked__)
		self.__event_button_onTiLiAddButtonClicked__ = nil
	end

	-- 取消注册 MoneyAddButton 的事件
	if self.__event_button_onMoneyAddButtonClicked__ then
		self.MoneyAddButton.onClick:RemoveListener(self.__event_button_onMoneyAddButtonClicked__)
		self.__event_button_onMoneyAddButtonClicked__ = nil
	end

	-- 取消注册 DiamondAddButton 的事件
	if self.__event_button_onDiamondAddButtonClicked__ then
		self.DiamondAddButton.onClick:RemoveListener(self.__event_button_onDiamondAddButtonClicked__)
		self.__event_button_onDiamondAddButtonClicked__ = nil
	end

	-- 取消注册 ElvenTreeWarehouseSwitchButton 的事件
	if self.__event_button_onElvenTreeWarehouseSwitchButtonClicked__ then
		self.ElvenTreeWarehouseSwitchButton.onClick:RemoveListener(self.__event_button_onElvenTreeWarehouseSwitchButtonClicked__)
		self.__event_button_onElvenTreeWarehouseSwitchButtonClicked__ = nil
	end

	-- 取消注册 ElvenTreeFormationButton 的事件
	if self.__event_button_onElvenTreeFormationImageButtonClicked__ then
		self.ElvenTreeFormationImageButton.onClick:RemoveListener(self.__event_button_onElvenTreeFormationImageButtonClicked__)
		self.__event_button_onElvenTreeFormationImageButtonClicked__ = nil
	end

	-- 取消注册 ElvenTreeFormationButton 的事件
	if self.__event_button_onElvenTreeFormationButtonClicked__ then
		self.ElvenTreeFormationButton.onClick:RemoveListener(self.__event_button_onElvenTreeFormationButtonClicked__)
		self.__event_button_onElvenTreeFormationButtonClicked__ = nil
	end

	-- 取消注册 ElvenTreeSnatchButton 的事件
	if self.__event_button_onElvenTreeSnatchButtonClicked__ then
		self.ElvenTreeSnatchButton.onClick:RemoveListener(self.__event_button_onElvenTreeSnatchButtonClicked__)
		self.__event_button_onElvenTreeSnatchButtonClicked__ = nil
	end

	-- 取消注册 BuyRobTimeButton 的事件
	if self.__event_button_onBuyRobTimeButtonClicked__ then
		self.BuyRobTimeButton.onClick:RemoveListener(self.__event_button_onBuyRobTimeButtonClicked__)
		self.__event_button_onBuyRobTimeButtonClicked__ = nil
	end

	-- 取消注册 ElvenTreeDescriptionButton 的事件
	if self.__event_button_onElvenTreeDescriptionButtonClicked__ then
		self.ElvenTreeDescriptionButton.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)
		self.__event_button_onElvenTreeDescriptionButtonClicked__ = nil
	end
	
	-- 取消注册 ElvenTreeReportButton 的事件
	if self.__event_button_onElvenTreeReportButtonClicked__ then
		self.ElvenTreeReportButton.onClick:RemoveListener(self.__event_button_onElvenTreeReportButtonClicked__)
		self.__event_button_onElvenTreeReportButtonClicked__ = nil
	end

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

function ElvenTreeCls:RepairingBoxItems4LockButtonClicked()


	local windowManager = self.game:GetWindowManager()	
	--表示是第四个
    windowManager:Show(require"GUI.ElvenTree.ElvenTreeOpenRepairBox",4,true)

end
function ElvenTreeCls:RepairingBoxItems5LockButtonClicked()
	
	local flag = false
	if self.msg.boxPos4==0 then
		flag=false
	else
		flag = true
		end
	local windowManager = self.game:GetWindowManager()	
	--表示是第四个
    windowManager:Show(require"GUI.ElvenTree.ElvenTreeOpenRepairBox",5,flag)
end
function ElvenTreeCls:OnrepairingBoxItems1ButtonClicked()

	self:DidClickButton(self.repairingBoxItems[1])

end
function ElvenTreeCls:OnrepairingBoxItems2ButtonClicked()
	self:DidClickButton(self.repairingBoxItems[2])
end
function ElvenTreeCls:OnrepairingBoxItems3ButtonClicked()

self:DidClickButton(self.repairingBoxItems[3])
end
function ElvenTreeCls:OnrepairingBoxItems4ButtonClicked()

self:DidClickButton(self.repairingBoxItems[4])
end
function ElvenTreeCls:OnrepairingBoxItems5ButtonClicked()

self:DidClickButton(self.repairingBoxItems[5])
end

function ElvenTreeCls:OnArenaReturnButtonClicked()
	--ArenaReturnButton控件的点击事件处理 隐藏窗口的显示
	print("OnArenaReturnButtonClickedOnArenaReturnButtonClickedOnArenaReturnButtonClickedOnArenaReturnButtonClicked")
	self:RefreshFormation()
	local sceneManager = self.game:GetSceneManager()
    sceneManager:PopScene()
end

function ElvenTreeCls:OnTiLiAddButtonClicked()
	--TiLiAddButton控件的点击事件处理
end

function ElvenTreeCls:OnMoneyAddButtonClicked()
	--MoneyAddButton控件的点击事件处理
end

function ElvenTreeCls:OnDiamondAddButtonClicked()
	--DiamondAddButton控件的点击事件处理
end

-- function ElvenTreeCls:OnElvenTreeRightButtonClicked()
-- 	--ElvenTreeRightButton控件的点击事件处理
-- --	print("点击右侧按钮")
-- 	self.ElvenTreeScrollbar.value=1
		
-- end

-- function ElvenTreeCls:OnElvenTreeLeftButtonClicked()
-- 	--ElvenTreeLeftButton控件的点击事件处理

-- --	print("点击左侧按钮")
-- 	self.ElvenTreeScrollbar.value=0

-- end

function ElvenTreeCls:OnElvenTreeWarehouseScrollbarValueChanged(value)
	--ElvenTreeWarehouseScrollbar控件的点击事件处理

end
local function  TakeInProtectBox(info,itemUID)

--	print(itemUID,info)
	for i=1,#info.repairingBoxItems do
	--	print(type(info),info.repairingBoxItems[i].itemID,info.repairingBoxItems[i].itemUID,info.itemColor,info.protect)
		if info.repairingBoxItems[i].itemUID==itemUID then
			info.repairingBoxItems[i].shieldImage.enabled=true
			info.repairingBoxItems[i].protect=1
		end
	end
	info.game:SendNetworkMessage(require "Network.ServerService".RobQueryRequest(100,-1))
	
end 
-----------------------------------------
----------------点击加锁按钮
-----------------------------------------
function ElvenTreeCls:DidClickButton(info)

--	print(type(info),info.itemID,info.itemUID,info.itemColor,info.protect)
	local windowManager = self.game:GetWindowManager()	
    windowManager:Show(require"GUI.ElvenTree.ElvenTreeProtectBoxDescription",self,info,self.msg.todayProtectCount,TakeInProtectBox)
   
	
end
function ElvenTreeCls:OnElvenTreeWarehouseSwitchButtonClicked()
	
	if self.ElvenTreeRepairItemLayoutScrollView.gameObject.activeInHierarchy == false then


		self.ElvenTreeWarehouseSwitchRepairImage.gameObject:SetActive(false)
		self.ElvenTreeRepairItemLayoutScrollView.gameObject:SetActive(true)

	 	self.ElvenTreeWarehouseSwitchOpenImage.gameObject:SetActive(true)
	 	self.ElvenTreeOpenItemLayoutScrollView.gameObject:SetActive(false)
	 	self.TitleWarehouse.text="待修复"

	else
		self.ElvenTreeWarehouseSwitchRepairImage.gameObject:SetActive(true)
		self.ElvenTreeRepairItemLayoutScrollView.gameObject:SetActive(false)

	 	self.ElvenTreeWarehouseSwitchOpenImage.gameObject:SetActive(false)	 	
	 	self.ElvenTreeOpenItemLayoutScrollView.gameObject:SetActive(true)
	 	self.TitleWarehouse.text="可开启（点击图标开启）"

		end

end
---------------------------------
---------刷新阵型信息--------- touxiang
------------------------------
function ElvenTreeCls:RefreshFormation(msg)
	--刷新当前的战力	
--	print("--刷新当前的战力	")
	--self:RefeshFightingCapacity()
--	print("箱子4箱子5的状态")
	--self:RefeshBattleFormation()
end


-- function ElvenTreeCls:SelectCardInArenaFight()
-- 	-- 挑战选择阵容
-- 	print("挑战选择阵容！！%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
-- 	local sceneManager = self:GetGame():GetSceneManager()

--     local FormationCls = require "GUI.Formation.Formation"
--     sceneManager:PushScene(FormationCls.New(kLineup_ArenaAttack,self.StartArenaFight,self))
-- end


function ElvenTreeCls:OnElvenTreeFormationButtonClicked()
for i=1,6 do
	self:RemoveChild(self.formations[i],true)

end
	
	--ElvenTreeFormationButton控件的点击事件处理
    local sceneManager = self:GetGame():GetSceneManager()
    local FormationCls = require "GUI.Formation.Formation"  
    sceneManager:PushScene(FormationCls.New(kLineup_ElvenTree,self.RefreshFormation,self))

 --   FormationCls:
end

local function CheckFormationCount(self)
	local UserDataType = require "Framework.UserDataType"
	local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	
	local ArenaDefenceCount = cardBagData:GetTroopCount(kLineup_ElvenTree)
	if ArenaDefenceCount <=1 then
		utility.ShowErrorDialog("防守阵容不能为空，请先设置防守阵容")
		return false
	end
	return true
end
-------------点击抢夺按钮事件----------------------
function ElvenTreeCls:OnElvenTreeSnatchButtonClicked()
	--ElvenTreeSnatchButton控件的点击事件处理

	-- if not CheckFormationCount(self) then
	-- 	return
	-- end
	if self.msg.todayRemainRob<=0 then

		local windowManager = utility:GetGame():GetWindowManager()
	   	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, "抢夺剩余次数不足！")
	else
		local windowManager = self.game:GetWindowManager()
	    windowManager:Show(require "GUI.ElvenTree.ElvenTreeSnatch",self.enemy,self.msg.todayRemainRob)
    end
end
--点击描述信息按钮
function ElvenTreeCls:OnElvenTreeDescriptionButtonClicked()
	  -- local windowManager = self.game:GetWindowManager()
   --  windowManager:Show(require "GUI.ElvenTree.ElvenTreeDescription")

	local id = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_ElvenTreeID):GetDescriptionInfo()[0]
	local hintStr = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
	local str = string.gsub(hintStr,"\\n","\n")
	
    local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.CommonDescriptionModule",str)



end

--战报
function ElvenTreeCls:OnElvenTreeReportButtonClicked()
	self:RobZhanbaoRequest()
end

--购买抢夺次数协议返回
function ElvenTreeCls:BuyRobTimeResult(msg)

	if msg.status then

	else
		debug_print("购买钥匙失败")
	end
end
-------------点击购买抢夺次数按钮事件----------------------
function ElvenTreeCls:OnBuyRobTimeButtonClicked()

	local UserDataType = require "Framework.UserDataType"
	local userData = self:GetCachedData(UserDataType.PlayerData)

    local VipData = require "StaticData.Vip.Vip"
	--当前vip等级的购买次数
	local vipAddCount = VipData:GetData(userData:GetVip()):GetPlunderTimes()

    -- 购买次数
	local windowManager = utility:GetGame():GetWindowManager()

	if self.robTimeRemain >= self.robTimeTotal then

		windowManager:Show(require "GUI.Dialogs.ErrorDialog","当前抢夺次数已为最大！")

	elseif self.alreadyBuy < vipAddCount then

		local data = require "StaticData.Factory.TreeBuyTimes":GetData(self.alreadyBuy + 1)
		local cost = data:GetCost()
		local str = "是否花费"..cost.."钻石购买一次抢夺机会？(今日剩余购买次数为"..(vipAddCount - self.alreadyBuy)..')'
		local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
		windowManager:Show(ConfirmDialogClass, str,self, self.OnElvenTreeBuyRobTimeRequest)
		
	else
		windowManager:Show(require "GUI.Dialogs.ErrorDialog","当前购买次数已为最大！")
	end
end

--网络事件

function ElvenTreeCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.RobBoxFlushMessage, self, self.RobBoxFlushMessage)
	--加载玩家信息
	self.game:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	--注册精灵树请求结果
	self.game:RegisterMsgHandler(net.S2CRobQueryResult, self, self.RobQueryResult)
	--领取宝箱之后返回消息
    self.game:RegisterMsgHandler(net.S2CRobOpenBoxResult, self, self.RobOpenBoxResult)
    --请求机器人上阵
    self.game:RegisterMsgHandler(net.S2CPutOnZhenrongResult, self, self.OnPutOnZhenrongResponse)
	--战报
	self.game:RegisterMsgHandler(net.S2CRobZhanbaoResult, self, self.OnRobZhanbaoResult)

	self.game:RegisterMsgHandler(net.S2CTakeBoxSecondKillResult, self, self.TakeBoxSecondKillResult)

	--精灵树购买抢夺次数返回消息
	self.game:RegisterMsgHandler(net.S2CRobBuyTimesResult, self, self.OnElvenTreeBuyRobTimeResult)

end

function ElvenTreeCls:UnregisterNetworkEvents()


	self.game:UnRegisterMsgHandler(net.RobBoxFlushMessage, self, self.RobBoxFlushMessage)

    self.game:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
    --取消注册精灵树请求结果
	self.game:UnRegisterMsgHandler(net.S2CRobQueryResult, self, self.RobQueryResult)
	--取消注册领取宝箱之后返回消息
    self.game:UnRegisterMsgHandler(net.S2CRobOpenBoxResult, self, self.RobOpenBoxResult)
     --请求机器人上阵
    self.game:UnRegisterMsgHandler(net.S2CPutOnZhenrongResult, self, self.OnPutOnZhenrongResponse)
	--战报
	self.game:UnRegisterMsgHandler(net.S2CRobZhanbaoResult, self, self.OnRobZhanbaoResult)
	self.game:UnRegisterMsgHandler(net.S2CTakeBoxSecondKillResult, self, self.TakeBoxSecondKillResult)

	--取消注册精灵树购买抢夺次数返回消息
	self.game:UnRegisterMsgHandler(net.S2CRobBuyTimesResult, self, self.OnElvenTreeBuyRobTimeResult)
end

function ElvenTreeCls:RobBoxFlushMessage(msg)
	print("%%%%%%%%%%%%%%%%%%%   RobBoxFlushMessage   %%%%%%%%%%%%%%%%%%%%%%")
	print(msg.RobBoxUID)
	local count = #self.msg.repairBoxItems
	for i=1,count do
		if self.msg.repairBoxItems[i].repairBoxUID==msg.RobBoxUID then
			--self.msg.repairBoxItems[i]=nil
			table.remove(self.msg.repairBoxItems,i)
			break
		end
	end
	InitViews(self.msg)
end


--战报请求
function ElvenTreeCls:RobZhanbaoRequest()
	self.game:SendNetworkMessage( require "Network/ServerService".RobZhanbaoRequest())
end

function ElvenTreeCls:OnElvenTreeBuyRobTimeRequest()
	-- 购买抢夺次数 请求
	self:GetGame():SendNetworkMessage( require"Network/ServerService".ElvenTreeBuyRobTimeRequest())
end

-----------------------------
----------上阵信息返回------
-----------------------------
function ElvenTreeCls:OnPutOnZhenrongResponse()
	-- 刷新玩家当前的金币 钻石 体力等显示
	self:RefreshCurrency()
end

--战报
function ElvenTreeCls:OnRobZhanbaoResult(msg)
	local windowManager = utility.GetGame():GetWindowManager()
	windowManager:Show(require "GUI.GuildPoint.ReportInfo",kReportElventTree,msg.zhanbao)
end

--购买抢夺次数 信息返回
function ElvenTreeCls:OnElvenTreeBuyRobTimeResult(robResult)	
	self:ShowBuyRobTimePanel(robResult)
end

-----------------------------
----------加载玩家信息------
-----------------------------
function ElvenTreeCls:UpdatePlayerData()
	-- 刷新玩家当前的金币 钻石 体力等显示
	self:RefreshCurrency()
end

local function RepairBoxItemsInfo (msg)
	-- body
	-- body optional int32 repairBoxID = 1;//可以根据id读取配置得到其颜色
	print("repairBoxID",msg.repairBoxID,"repairBoxUID",msg.repairBoxUID,"type",msg.type,"protecttype",msg.protecttype)
end


local function RobotCardInfo (msg)

	hzj_print("cardID",msg.cardID,"cardLevel",msg.cardLevel,"cardColor",msg.cardColor,"cardPos",msg.cardPos,"anger",msg.anger,"hp",msg.hp,"hpLimit",msg.hpLimit,"stage",msg.stage,"zhanli",msg.zhanli,"sparColor",msg.sparColor)
end
local function RepairBoxStatesInfo (msg)
	-- body optional int32 repairBoxID = 1;//可以根据id读取配置得到其颜色
	debug_print("repairBoxID",msg.repairBoxID,"repairBoxUID",msg.repairBoxUID,"remainTime",msg.remainTime,"protecttype",msg.protecttype)
  
end
local function PrintEnemyInfo (msg)
	-- body

	print("repairBoxID",msg.repairBoxID,"playerLevel",msg.playerLevel,"playerName",msg.playerName,"playerUID",msg.playerUID,"totalZhanli",msg.playerName,"totalZhanli",msg.playerName,"canRob",msg.canRob,"headID",msg.headID,"headColor",msg.headColor,"gonghuiName",msg.gonghuiName)
	--	print("敌人卡牌信息")
	--for i=1,#msg.robotCard do
--	print("cardID",msg.cards.cardID,"cardLevel",msg.cards.cardLevel,"cardColor",msg.cards.cardColor,"cardPos",msg.cards.cardPos,"anger",msg.cards.anger,"hp",msg.cards.hp,"hpLimit",msg.cards.hpLimit,"stage",msg.cards.stage,"zhanli",msg.cards.zhanli,"sparColor",msg.cards.sparColor)
	for i=1,#msg.cards do
     RobotCardInfo(msg.cards[i])
	end
end
function ElvenTreeCls:ShowTreeLevelUp(msg)
	for i=1,#self.treeStatusText do
		self.treeStatusText[i].gameObject:SetActive(false)
	end
	--debug_print("msg.level",msg.level)


	--msg.level=20
	self.treeStatusLvText.text=msg.level
	local TreeLevelUpData = require"StaticData/Factory/TreeLevelUp":GetData(msg.level)
	local types = TreeLevelUpData:GetPowerType()
	local nums = TreeLevelUpData:GetPowerNum()
	if msg.level==0 then
		self.treeStatusText[1].gameObject:SetActive(true)
		self.treeStatusText[1].text="暂未加成"
	else
		for i=1,#types do
			self.treeStatusText[i].gameObject:SetActive(true)
			self.treeStatusText[i].text=EquipStringTable[types[i]].."+"..nums[i]
		end
		self.treeStatusText[#types+1].gameObject:SetActive(true)
		local str = string.gsub(CommonStringTable[12],"\\n","\n")
		self.treeStatusText[#types+1].text=string.format(CommonStringTable[12], TreeLevelUpData:GetReduceTime())
		
	end
	-- if msg.level>0 then
		
	-- else
	-- 	self.treeStatusText[1].text="无"
	-- 	for i=2,#self.treeStatusText do
	-- 		self.treeStatusText[i].gameObject:SetActive(false)
	-- 	end
	-- end

end
--------------------------------------
----------请求查询精灵树返回结果------
--------------------------------------
function ElvenTreeCls:RobQueryResult(msg)

	--debug_print("OnBuyRobTimeButtonClicked   ", msg.buyTimes)


	self:ShowTreeLevelUp(msg)

	self.BackGround.raycastTarget = false
	
	for i=1,6 do
		if self.formations[i] ~=nil then
			self:RemoveChild(self.formations[i],true)
		end
	end
--print(self.cardData:GetUid(),msg.robotCard.cardID)
	if self.cardData:GetUid()==msg.robotCard.cardID then
		--print(self.cardData:GetUid())
	else
	--	self.cardData=nil
	end
	--print("robotCard",msg.robotCard,"todayRemainRob",msg.todayRemainRob,"todayTotalRob",msg.todayTotalRob,"resumeCountRemainTime",msg.resumeCountRemainTime,"todayProtectCount",msg.todayProtectCount)
--	print("器人卡牌 固定在位置5")
	--print("cardID",msg.robotCard.cardID,"cardLevel",msg.robotCard.cardLevel,"cardColor",msg.robotCard.cardColor,"cardPos",msg.robotCard.cardPos,"anger",msg.robotCard.anger,"hp",msg.robotCard.hp,"hpLimit",msg.robotCard.hpLimit,"stage",msg.robotCard.stage,"zhanli",msg.robotCard.zhanli,"sparColor",msg.robotCard.sparColor)

	-- print("主面板上3个带维修的箱子的状态")
	for i=1,#msg.repairBoxStates do
		RepairBoxStatesInfo(msg.repairBoxStates[i])
	end
	-- print("仓库里面的箱子开始")
	for i=1,#msg.repairBoxItems do
		RepairBoxItemsInfo(msg.repairBoxItems[i])
	end
	-- print("仓库里面的箱子结束")
	-- print("敌人的list")
	 
	for i=1,#msg.enemy do
		--hzj_print()
		hzj_print(msg.enemy[i].repairBoxID,msg.enemy[i].playerLevel,msg.enemy[i].playerName)
	end
--	print("箱子4箱子5的状态",msg.boxPos4,msg.boxPos5)
	--刷新两个特殊的箱子
	self:RefeshSpecialRepairBox(self.repairingBoxItems[4],msg.boxPos4,4)
	self:RefeshSpecialRepairBox(self.repairingBoxItems[5],msg.boxPos5,5)
	self.enemy=msg.enemy
	--保护次数
	--self.todayProtectCount=msg.todayProtectCount

	self.msg=msg
	self:InitViews(msg)


		-- --刷新当前的战力	
	self:RefeshFightingCapacity()
	--刷新当前的战力	
	self:RefeshBattleFormation()
	--
end 


----------------------------------------
-------------初始化界面显示-------------
----------------------------------------
function ElvenTreeCls:InitViews(msg)
	if(msg.showRobotNotice) then
	--	print("显示机器人")
		self:ShowRobotPanel(msg.robotCard)
	else
	--	print("不现实机器人")
	end
	
	--在刷新 抢夺次数
	self.ElvenTreeSnatchNumLabel.text="抢夺次数:"..msg.todayRemainRob.."/"..msg.todayTotalRob
	if msg.todayRemainRob<=0 then
		self.ElvenTreeSnatchButtonRedDot.enabled=false
	else

		self.ElvenTreeSnatchButtonRedDot.enabled=true
	end

	--刷新显示需要维修和可开启的箱子
	self:RefeshRepairBox(msg.repairBoxItems)
	--刷新显示维修中的蛋
	self:RefeshRepairingBoxState(msg.repairBoxStates)

	--当前剩余可抢夺倒计时
	self.countTime = msg.resumeCountRemainTime

	local TreeLevelUpData = require"StaticData/Factory/TreeLevelUp":GetData(self.msg.level)
	local needNum = TreeLevelUpData:GetNeedNum()
	if needNum > 0 then
		local UserDataType = require "Framework.UserDataType"
		local itemCardData = self:GetCachedData(UserDataType.ItemBagData)
		local count = itemCardData:GetItemCountById(10300148)
		self.LevelUpRodDot.transform.gameObject:SetActive(count >= needNum)
	else
		self.LevelUpRodDot.transform.gameObject:SetActive(false)
	end

	self.alreadyBuy = msg.buyTimes
	self.robTimeRemain = msg.todayRemainRob
	self.robTimeTotal = msg.todayTotalRob
end

--显示机器人面板
function  ElvenTreeCls:ShowRobotPanel(msg)
	local windowManager = self.game:GetWindowManager()	
    windowManager:Show(require"GUI.ElvenTree.ElvenTreeDefenseRobot",msg)
end

--刷新抢夺次数的 界面显示
function ElvenTreeCls:ShowBuyRobTimePanel(msg)

	debug_print("OnBuyRobTimeButtonClicked  ", msg.surplusTimes, msg.totalTimes, msg.buyTimes, msg.resumeCountRemainTime)

    -- 设置剩余次数
	self.robTimeRemain = msg.surplusTimes
	self.robTimeTotal = msg.totalTimes


	self.alreadyBuy = msg.buyTimes

	self.countTime = tonumber(msg.resumeCountRemainTime)


	debug_print("mmmmmmmm...",msg.resumeCountRemainTime, self.countTime)


	self.msg.todayRemainRob = self.robTimeRemain
	self.msg.todayTotalRob = self.robTimeTotal

	self.ElvenTreeSnatchNumLabel.text = "抢夺次数:"..self.robTimeRemain.."/"..self.robTimeTotal
    
    if self.robTimeRemain <= 0 then
		self.ElvenTreeSnatchButtonRedDot.enabled = false
	else
		self.ElvenTreeSnatchButtonRedDot.enabled = true
	end
end


--刷新精灵树中修复的蛋的显示 
local function RepairingBoxHasOwn(self,id)
--	print(id)
	for i=1,#self.repairingBoxItems do
		if self.repairingBoxItems[i].itemUID==id then
			return true
			end
		end
    return false
end

local function FindCanRepairBox(self)
	for i=1,#self.repairingBoxItems do
		--表示已经开启
		if self.repairingBoxItems[i].flag then
			--表示没有包含物体
			if not self.repairingBoxItems[i].containItem then
				return i
				end
			end
		end
    return nil
end
function  ElvenTreeCls:ResetRepairingBox()
	for i=1,5 do
		self.repairingBoxItems[i].refresh=true
		self.repairingBoxItems[i].flag=true
		--表示是否有了物体
		self.repairingBoxItems[i].containItem=false
		--当前修复物体的倒计时
		self.repairingBoxItems[i].countTime=nil
		--当前修复物体的Id
		self.repairingBoxItems[i].itemID=nil
		--当前修复物体的UID
		self.repairingBoxItems[i].itemUID=nil	
		self.repairingBoxItems[i].image.sprite=nil	
		self.repairingBoxItems[i].image.color=UnityEngine.Color(1, 1, 1, 0)			
		--self.repairingBoxItems[i].colorTrans.gameObject:SetActive(false)
    		self.repairingBoxItems[i].SpeedUpButton.gameObject:SetActive(false)

		self.repairingBoxItems[i].timeTrans.gameObject:SetActive(false)
		self.repairingBoxItems[i].protect=nil
		self.repairingBoxItems[i].shieldImage.enabled=false
	end


end
--刷新精灵树中修复的蛋的显示 
function  ElvenTreeCls:RefeshRepairingBoxState(msg)
self:ResetRepairingBox()
	for i=1,#msg do	
	-- end
	if not RepairingBoxHasOwn(self,msg[i].repairBoxUID) then
		--不存在 查找位置
		local pos=FindCanRepairBox(self)
		--如果查找到了位置
		if  pos then
			-- local AtlasesLoader = require "Utils.AtlasesLoader"
			local GameTools = require "Utils.GameTools"
	   		local _,data,_,iconPath,itemType = GameTools.GetItemDataById(msg[i].repairBoxID)
	   		local itemColor=GameTools.GetItemColorByType(itemType,data)
	   		iconPath="UI/Atlases/Icon/FactoryIcon/"..data:GetIconInRepair()
			utility.LoadSpriteFromPath(iconPath,self.repairingBoxItems[pos].image)
	   		-- local sprite = AtlasesLoader:LoadAtlasSprite(iconPath)
    		-- self.repairingBoxItems[pos].image.sprite = sprite
    		self.repairingBoxItems[pos].image.color=UnityEngine.Color(1, 1, 1, 1)
    		self.repairingBoxItems[pos].itemID=msg[i].repairBoxID
    		self.repairingBoxItems[pos].itemUID=msg[i].repairBoxUID
    		self.repairingBoxItems[pos].countTime=msg[i].remainTime+2
    	--	print(self.repairingBoxItems[pos].countTime,pos)
    		self.repairingBoxItems[pos].containItem=true
    		self.repairingBoxItems[pos].refresh=false
    		self.repairingBoxItems[pos].button.enabled=true
    		self.repairingBoxItems[pos].protect=msg[i].protecttype    		
    		self.repairingBoxItems[pos].timeTrans.gameObject:SetActive(true)
    		self.repairingBoxItems[pos].SpeedUpButton.gameObject:SetActive(true)
    		if msg[i].protecttype==1 then
				self.repairingBoxItems[pos].shieldImage.enabled=true			
    		end
    		self.repairingBoxItems[pos].protect=msg[i].protecttype
    	--	self.repairingBoxItems[pos].colorTrans.gameObject:SetActive(true)
    		-- local PropUtility = require "Utils.PropUtility"
    	 --    PropUtility.AutoSetColor(self.repairingBoxItems[pos].colorTrans, itemColor + 1)

		end

	else
		--print("修复中的物体已经存在，更新信息",msg[i].repairBoxUID)

		end
  
	end

end
--显示维修中的蛋box 4 box5
function  ElvenTreeCls:RefeshSpecialRepairBox(boxTable,boxPos,index)

	local UserDataType = require "Framework.UserDataType"
	local userData = self:GetCachedData(UserDataType.PlayerData)
	local vip = userData:GetVip()

	--已经打开
	if boxPos==0 then
		boxTable.flag=false
		--print(boxTable.timeTrans)
		--repairingBoxItems[4].timeTrans:SetActive(false)
		boxTable.timeTrans.gameObject:SetActive(false)
		boxTable.lockTrans.gameObject:SetActive(true)
		local FactoryConfigData = require"StaticData/Factory/FactoryConfig"
	  --   print(FactoryConfigData:GetData(1):Slot4Vip(),"**********",FactoryConfigData:GetData(1):Slot4Diamond())
	    if index == 4 then
	    	local Slot4Vip = FactoryConfigData:GetData(1):Slot4Vip()
			boxTable.vipLabel.text="VIP"..Slot4Vip.."\n免费解锁"
			 
			boxTable.diamondLabel.text = FactoryConfigData:GetData(1):Slot4Diamond()
			boxTable.redDot.transform.gameObject:SetActive(vip>=Slot4Vip)

		elseif index == 5 then
			local Slot5Vip = FactoryConfigData:GetData(1):Slot5Vip()
			boxTable.vipLabel.text="VIP"..Slot5Vip.."\n免费解锁"
			boxTable.diamondLabel.text=FactoryConfigData:GetData(1):Slot5Diamond()

			boxTable.redDot.transform.gameObject:SetActive(vip>=Slot5Vip)

		end
	
	else 
	--还未解锁
		boxTable.flag=true
	--	boxTable.timeTrans.gameObject:SetActive(false)
		boxTable.lockTrans.gameObject:SetActive(false)
	end
	
end

local function ClearAllItemHasOwnItem(self,msg)
--	print("清楚仓库中多余的蛋的显示")
	local flag = false
	for i=1,#self.allItem do
		flag=false
		for j=1,#msg do		
			if msg[j].repairBoxUID==self.allItem[i] then
				flag=true
				break
			end
		end
		if not flag then
		--	print(self.allItem[i])
			if self.allItem[i] then
			--	print(self.allItem[i],'清除')
				--i=i-1

				self:RemoveSelfChild(self.allItem[i])
			else
				--print(self.allItem[i],"已经清楚过了")
				end
		else
			--print(self.allItem[i],"为清楚")
		end
	end	
end 
function  ElvenTreeCls:RemoveSelfChild(uid)

	local i = 1
	 while self.allItem[i] do 
            if self.allItem[i]==uid then 
            	--print(self.allItem[i],"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",uid)
                table.remove(self.allItem,i) 
                break
            else 
                i = i+1 
            end 
     end 
    -- print("44444444444444444444444444444444444444444444")
    i = 1
	while self.openItem[i] do 
            if self.openItem[i].itemUID==uid then                
                self:RemoveChild(self.openItem[i])	
            --     print(self.openItem[i].itemUID,"&&&&&&&&&&&&&&&&&&&&&",uid)
                 table.remove(self.openItem,i) 
                 break
            else 
                i = i+1 
            end 
     end 
    i = 1
	while self.repairItem[i] do 
            if self.repairItem[i].itemUID==uid then                
                self:RemoveChild(self.repairItem[i])	
                 table.remove(self.repairItem,i) 
                 break
            else 
                i = i+1 
            end 
    end 


	
	 
end
--判断是否创建了该ID的物体
local function HasOwn(self, id)
--	print(id)
	for i=1,#self.allItem do
		if self.allItem[i]==id then
			return true
			end
		end
    return false
end
--刷新显示仓库中的蛋
function  ElvenTreeCls:RefeshRepairBox(msg)
	-- print("清处之前")
	-- for i=1,#self.allItem do	
	-- 	print("self.allItem",self.allItem[i])
	-- 	end
	--清楚仓库中多余的蛋的显示
	ClearAllItemHasOwnItem(self,msg)
	-- print("清处之后未添加")
	-- for i=1,#self.allItem do	
	-- 	print("self.allItem",self.allItem[i])
	-- 	end
	--循环仓库中的蛋 判断是否都显示了
	for i=1,#msg do	
   		--防止重复显示 如果没就添加进去
   		if not HasOwn(self,msg[i].repairBoxUID) then
   			--获取要显物体的信息
   			local GameTools = require "Utils.GameTools"
   			local _,data,_,_,itemType = GameTools.GetItemDataById(msg[i].repairBoxID)
   			local itemColor=GameTools.GetItemColorByType(itemType,data)
	   		if msg[i].type==0 then
				self.openItem[#self.openItem+1]=require"GUI.ElvenTree.ElvenGeneralItem".New(self.ElvenTreeOpenItemLayoutTrans,msg[i].repairBoxID,nil,itemColor,msg[i].type,msg[i].repairBoxUID,msg[i].protecttype)	
	   			self.allItem[#self.allItem+1]=msg[i].repairBoxUID
	   		--	print(self.openItem[#self.openItem].itemUID,'新添加的的物体openItem')

	   			self:AddChild(self.openItem[#self.openItem])	
	   		else
				self.repairItem[#self.repairItem+1]=require"GUI.ElvenTree.ElvenGeneralItem".New(self.ElvenTreeRepairItemLayoutTrans,msg[i].repairBoxID,nil,itemColor,msg[i].type,msg[i].repairBoxUID,msg[i].protecttype)	
				self.allItem[#self.allItem+1]=msg[i].repairBoxUID
	   			self:AddChild(self.repairItem[#self.repairItem])
	   		--	print(self.openItem[table.maxn(self.openItem)],'新添加的的物体repairItem')	
	   		end	

	   	else
	   	--	print(msg[i].repairBoxUID,"已经添加过了")
	   	end

	end

	-- print("清楚之后新添加")
	-- for i=1,#self.allItem do	
	-- 	print("self.allItem",self.allItem[i])
	-- 	end
end

--判断当前的服务器返回的RepairBox是是否包含该Id的物体
local function RepairBoxHasOwn(self,msg, id)
--	print(id)
	for i=1,#msg do
	--	print(msg[i].repairBoxUID,id)
		if msg[i].repairBoxUID==id then
			return true
			end
		end
--	print("return false",id)
    return false
end
------------------打开宝箱返回事件---------------
function ElvenTreeCls:RobOpenBoxResult(msg)
 
	local gameTool = require "Utils.GameTools"
	

    local modV = math.floor(msg.award.itemID/100000)
	if modV==101 then			
		gameTool.GetItemWin(msg.award.itemID)

   	else
   		local items = {}
   		items[1]={}
  		items[1].id=msg.award.itemID
  		items[1].count=msg.award.itemNum
  		items[1].color=msg.award.itemColor
		local windowManager = self:GetGame():GetWindowManager()
	  	local AwardCls = require "GUI.Task.GetAwardItem"
	  	windowManager:Show(AwardCls,items)
	end
	self:RefeshRepairBox(msg.repairBoxItems)
end

local function CallBack(self)
	debug_print("up  CallBack")
	self.game:SendNetworkMessage(require "Network.ServerService".RobQueryRequest(100,-1))
end


function ElvenTreeCls:OnLevelUpButtonClicked()
	local windowManager = self.game:GetWindowManager()

	windowManager:Show(require "GUI.ElvenTree.TreeLevelUp",self.msg.level,self.msg.exp,CallBack,self)

end

function ElvenTreeCls:TakeBoxSecondKillResult(msg)
	debug_print("TakeBoxSecondKillResult",#msg.award)
	debug_print(msg.award.itemID,msg.award.itemColor,msg.award.itemNum)
	
	-- local gameTool = require "Utils.GameTools"
	

 --    local modV = math.floor(msg.award.itemID/100000)
	-- if modV==101 then			
	-- 	gameTool.GetItemWin(msg.award.itemID)

 --   	else
 --   		gameTool.ShowItemWin(msg.award.itemID)
	-- end


	 
	local gameTool = require "Utils.GameTools"
	

    local modV = math.floor(msg.award.itemID/100000)
	if modV==101 then			
		gameTool.GetItemWin(msg.award.itemID)

   	else
   		local items = {}
   		items[1]={}
  		items[1].id=msg.award.itemID
  		items[1].count=msg.award.itemNum
  		items[1].color=msg.award.itemColor
		local windowManager = self:GetGame():GetWindowManager()
	  	local AwardCls = require "GUI.Task.GetAwardItem"
	  	windowManager:Show(AwardCls,items)
	end


end

function ElvenTreeCls:OnSpeedUpButton1ButtonClicked()
	local windowManager = self.game:GetWindowManager()
	windowManager:Show(require "GUI.ElvenTree.ElvenTreeEggDoneNow",self.repairingBoxItems[1].itemUID,self.repairingBoxItems[1].itemID,CallBack,self)
end
function ElvenTreeCls:OnSpeedUpButton2ButtonClicked()
		local windowManager = self.game:GetWindowManager()
	windowManager:Show(require "GUI.ElvenTree.ElvenTreeEggDoneNow",self.repairingBoxItems[2].itemUID,self.repairingBoxItems[2].itemID,CallBack,self)
end
function ElvenTreeCls:OnSpeedUpButton3ButtonClicked()
		local windowManager = self.game:GetWindowManager()
	windowManager:Show(require "GUI.ElvenTree.ElvenTreeEggDoneNow",self.repairingBoxItems[3].itemUID,self.repairingBoxItems[3].itemID,CallBack,self)
end
function ElvenTreeCls:OnSpeedUpButton4ButtonClicked()
		local windowManager = self.game:GetWindowManager()
	windowManager:Show(require "GUI.ElvenTree.ElvenTreeEggDoneNow",self.repairingBoxItems[4].itemUID,self.repairingBoxItems[4].itemID,CallBack,self)
end
function ElvenTreeCls:OnSpeedUpButton5ButtonClicked()
		local windowManager = self.game:GetWindowManager()
	windowManager:Show(require "GUI.ElvenTree.ElvenTreeEggDoneNow",self.repairingBoxItems[5].itemUID,self.repairingBoxItems[5].itemID,CallBack,self)
end

return ElvenTreeCls

