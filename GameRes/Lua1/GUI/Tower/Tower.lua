local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
require "LUT.StringTable"
require "Const"
local speed = 40
local movePosY = -425
local TowerCls = Class(BaseNodeClass)

function TowerCls:Ctor()
	
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TowerCls:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/Tower",function(go)
		self:BindComponent(go)
	end)
end

function TowerCls:OnComponentReady()
	--界面加载完成
	self:InitControls()
end

function TowerCls:OnResume()
	--界面显示时调用
	TowerCls.base.OnResume(self)
	self:ScheduleUpdate(self.Update)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:TowerQueryRequest()
	self:AttributeQuery()
	-- self:LoadTower(1,103,100)
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[13].systemGuideID,self)

end

function TowerCls:OnPause()
	TowerCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function TowerCls:OnEnter()
	TowerCls.base.OnEnter(self)
end

function TowerCls:OnExit()
	TowerCls.base.OnExit(self)
end

function TowerCls:Update()
	self:MoveCloud()
	self:MoveTower()
end

-------------------------------------------------------------------
--- 控件相关
-------------------------------------------------------------------

-- 控件绑定
function TowerCls:InitControls()
	local transform = self:GetUnityTransform()
	

	self.returnButton = transform:Find("ReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))
	--属性值
	self.attrParent = transform:Find("Scene/NowPromote/Layout")
	self.attrObj = transform:Find("Scene/NowPromote")
	self.timeNumLabel = transform:Find("TimeNumLabel"):GetComponent(typeof(UnityEngine.UI.Text)) -- 剩余重置次数
	self.Information = transform:Find("Information")
	--星级
	self.historyStar = self.Information:Find("BestRank/numLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.currentStar = self.Information:Find("NowRank/numLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--奖励
	self.itemIcon = {}
	self.itemFrame = {}
	self.itemNum = {}
	for i=1,6 do
		self.itemIcon[i] = self.Information:Find("Item/MyGeneralItem"..i.."/ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
		self.itemFrame[i] = self.Information:Find("Item/MyGeneralItem"..i.."/Frame/Image"):GetComponent(typeof(UnityEngine.UI.Image))
		self.itemNum[i] = self.Information:Find("Item/MyGeneralItem"..i.."/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	end
	self.notice = self.Information:Find("Notice"):GetComponent(typeof(UnityEngine.UI.Text))
	--塔
	self.towerParent = transform:Find("Scene/Viewport/Content/Tower")
	-- 一键三星
	self.sweepButton = transform:Find("SweepButton"):GetComponent(typeof(UnityEngine.UI.Button))
	-- 重置
	self.resetButton = transform:Find("ResetButton"):GetComponent(typeof(UnityEngine.UI.Button))
	-- 战斗
	self.fightButton = transform:Find("FightButton"):GetComponent(typeof(UnityEngine.UI.Button))
	-- boss
	self.bossButton = transform:Find("BossButton"):GetComponent(typeof(UnityEngine.UI.Button))
	-- 商店
	self.shopButton = transform:Find("ShopButton"):GetComponent(typeof(UnityEngine.UI.Button))
	-- 排名
	self.rankButton = transform:Find("RankButton"):GetComponent(typeof(UnityEngine.UI.Button))

	-- 上方云
	self.BackCloud = transform:Find("Scene/BackCloud")
	--下方云
	self.Cloud = transform:Find("Scene/Cloud")
	-- self.3starItemIcon1 = self.Information:Find("3Star/MyGeneralItem1/ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.3starItemFrame1 = self.Information:Find("3Star/MyGeneralItem1/Frame/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.3starItemIcon2 = self.Information:Find("3Star/MyGeneralItem2/ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.3starItemFrame2 = self.Information:Find("3Star/MyGeneralItem2/Frame/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.6starItemIcon1 = self.Information:Find("6Star/MyGeneralItem1/ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.6starItemFrame1 = self.Information:Find("6Star/MyGeneralItem1/Frame/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.6starItemIcon2 = self.Information:Find("6Star/MyGeneralItem2/ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.6starItemFrame2 = self.Information:Find("6Star/MyGeneralItem2/Frame/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.9starItemIcon1 = self.Information:Find("9Star/MyGeneralItem1/ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.9starItemFrame1 = self.Information:Find("9Star/MyGeneralItem1/Frame/Image"):GetComponent(typeof(UnityEngine.UI.Image))

	self.BackCloudPosX = -900
	self.CloudPosX = 972
	self.towerMove = false
	self.position = self.towerParent.localPosition
end

function TowerCls:RegisterControlEvents()
	--注册退出事件
	self._event_button_onReturnButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onReturnButtonClicked_)
	--注册一键三星事件
	self._event_button_onSweepButtonClicked_ = UnityEngine.Events.UnityAction(self.OnSweepButtonClicked,self)
	self.sweepButton.onClick:AddListener(self._event_button_onSweepButtonClicked_)
	--注册重置事件
	self._event_button_onResetButtonClicked_ = UnityEngine.Events.UnityAction(self.OnResetButtonClicked,self)
	self.resetButton.onClick:AddListener(self._event_button_onResetButtonClicked_)
	--注册战斗事件
	self._event_button_onFightButtonClicked_ = UnityEngine.Events.UnityAction(self.OnFightButtonClicked,self)
	self.fightButton.onClick:AddListener(self._event_button_onFightButtonClicked_)
	--注册Boss事件
	self._event_button_onBossButtonClicked_ = UnityEngine.Events.UnityAction(self.OnBossButtonClicked,self)
	self.bossButton.onClick:AddListener(self._event_button_onBossButtonClicked_)
	--注册商店事件
	self._event_button_onShopButtonClicked_ = UnityEngine.Events.UnityAction(self.OnShopButtonClicked,self)
	self.shopButton.onClick:AddListener(self._event_button_onShopButtonClicked_)
	--注册排名事件
	self._event_button_onRankButtonClicked_ = UnityEngine.Events.UnityAction(self.OnRankButtonClicked,self)
	self.rankButton.onClick:AddListener(self._event_button_onRankButtonClicked_)
end

function TowerCls:UnregisterControlEvents()
	--取消注册退出事件
	if self._event_button_onReturnButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onReturnButtonClicked_)
		self._event_button_onReturnButtonClicked_ = nil
	end
	--取消注册一键三星事件
	if self._event_button_onSweepButtonClicked_ then
		self.sweepButton.onClick:RemoveListener(self._event_button_onSweepButtonClicked_)
		self._event_button_onSweepButtonClicked_ = nil
	end
	--取消注册重置事件
	if self._event_button_onResetButtonClicked_ then
		self.resetButton.onClick:RemoveListener(self._event_button_onResetButtonClicked_)
		self._event_button_onResetButtonClicked_ = nil
	end
	--取消注册战斗事件
	if self._event_button_onFightButtonClicked_ then
		self.fightButton.onClick:RemoveListener(self._event_button_onFightButtonClicked_)
		self._event_button_onFightButtonClicked_ = nil
	end
	--取消注册boss事件
	if self._event_button_onBossButtonClicked_ then
		self.bossButton.onClick:RemoveListener(self._event_button_onBossButtonClicked_)
		self._event_button_onBossButtonClicked_ = nil
	end
	--取消注册商店事件
	if self._event_button_onShopButtonClicked_ then
		self.shopButton.onClick:RemoveListener(self._event_button_onShopButtonClicked_)
		self._event_button_onShopButtonClicked_ = nil
	end
	--取消注册排名事件
	if self._event_button_onRankButtonClicked_ then
		self.rankButton.onClick:RemoveListener(self._event_button_onRankButtonClicked_)
		self._event_button_onRankButtonClicked_ = nil
	end
end

function TowerCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CTowerQueryResult,self,self.TowerQueryResult)
	utility:GetGame():RegisterMsgHandler(net.S2CAttributeQueryResult,self,self.AttributeQueryResult)
	utility:GetGame():RegisterMsgHandler(net.S2CBossQueryResult,self,self.BossQueryResult)
	utility:GetGame():RegisterMsgHandler(net.S2CTowerBigStageAwardResult,self,self.TowerBigStageAwardResult)
	utility:GetGame():RegisterMsgHandler(net.S2CTowerResetResult,self,self.TowerResetResult)
	utility:GetGame():RegisterMsgHandler(net.S2CTowerSweepResult,self,self.TowerSweepResult)
end

function TowerCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CTowerQueryResult,self,self.TowerQueryResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CAttributeQueryResult,self,self.AttributeQueryResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CBossQueryResult,self,self.BossQueryResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CTowerBigStageAwardResult,self,self.TowerBigStageAwardResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CTowerResetResult,self,self.TowerResetResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CTowerSweepResult,self,self.TowerSweepResult)
end

function TowerCls:ChangeArenaFightingPower()
	local UserDataType = require "Framework.UserDataType"
    self.cardBagData = self:GetCachedData(UserDataType.CardBagData)
	local data = self.cardBagData:GetRoleByUid(uid)
	self.power = data:GetPower()
end

function TowerCls:TowerQueryResult(msg)
	debug_print("層級："..msg.currentLayer)
	self.currentLayer = msg.currentLayer
	self:LoadTowerPanel(msg)
end

function TowerCls:AttributeQueryResult(msg)
	self:RemoveAll()
	self:LoadAttr(msg.attrArray)
end

function TowerCls:TowerResetResult(msg)
	self:TowerQueryRequest()
	self:AttributeQuery()
end

function TowerCls:TowerSweepResult(msg)
	debug_print(#msg.items)
	self:ShowSweepAward(msg.items)
	self:RemoveAll()
	self:LoadAttr(msg.attrArray)
	self:TowerQueryRequest()
	self:AttributeQuery()
end

function TowerCls:BossQueryResult(msg)
	debug_print("打开boss界面"..msg.maxCanChallengeID)
	self:LoadBossPanel(msg)
end

function TowerCls:TowerRankQueryResult(msg)
	
end

function TowerCls:TowerBigStageAwardResult(msg)
	self:ShowAwardPanel(msg.awards)
end

function TowerCls:BossQueryRequest()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".BossQueryRequest())
end

function TowerCls:TowerQueryRequest()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".TowerQueryRequest())
end

function TowerCls:AttributeQuery()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".AttributeQueryRequest())
end

function TowerCls:TowerRankQueryRequest()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".TowerRankQueryRequest())
end

function TowerCls:TowerSweepRequest()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".TowerSweepRequest())
end

function TowerCls:TowerResetRequest()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".TowerResetRequest())
end

function TowerCls:OnReturnButtonClicked()
	local sceneManager = utility:GetGame():GetSceneManager()
	sceneManager:PopScene()
end

--扫荡
function TowerCls:OnSweepButtonClicked()
	self:TowerSweepRequest()
	-- self:LoadTower(71,103,100)
end

--重置
function TowerCls:OnResetButtonClicked()
	local windowManager = utility:GetGame():GetWindowManager()
	if self.surplusFreeResetCount <= 0 then
		windowManager:Show(require "GUI.Dialogs.ErrorDialog", "重置次数不足")
	else
	    local str = string.format("剩余%d次重置机会，是否确定重置", self.surplusFreeResetCount)
	    local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	    windowManager:Show(ConfirmDialogClass, str, self, self.TowerResetRequest)
		--self:LoadTower(1,103,100)
	end
end

-- local index = 1
--战斗
function TowerCls:OnFightButtonClicked()
	-- index = index + 1
	-- self:LoadTower(index,103,100)
	self:LoadNormalPanel()
end

--Boss
function TowerCls:OnBossButtonClicked()
	self:BossQueryRequest()
	
end

--商店
function TowerCls:OnShopButtonClicked()
	local windowManager = utility.GetGame():GetWindowManager()
	windowManager:Show(require "GUI.Shop.Shop",KShopType_Tower)
end

--排名
function TowerCls:OnRankButtonClicked()
	local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Arena.ArenaRank",kTowerRank)
 	-- local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
  --   local windowManager = self:GetGame():GetWindowManager()
  --   windowManager:Show(ErrorDialogClass, "暂未开启！")
end

function TowerCls:LoadBossPanel(data)
	local windowManager = utility:GetGame():GetWindowManager()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local playerVip = userData:GetVip()
    local vipData = require "StaticData.Vip.Vip":GetData(playerVip)
	local count = vipData:GetBuyTowerBossResetLimit() - data.alreayBuyBossCount
	windowManager:Show(require "GUI.Tower.TowerBoss",data.maxCanChallengeID,data.maxKilledBossID,data.surplusCount,count)
end

function TowerCls:LoadNormalPanel()
	local windowManager = utility:GetGame():GetWindowManager()
	windowManager:Show(require "GUI.Tower.TowerLevel",self.currentLayer)
end

--加载界面
function TowerCls:LoadTowerPanel(data)

	self:RemoveTower()
	self.historyStar.text = data.historyStar
	self.currentStar.text = data.currentStar
	self.timeNumLabel.text = data.surplusFreeResetCount
	self.surplusFreeResetCount = data.surplusFreeResetCount
	local id = data.currentLayer * 100 + 1
	local levelData = require "StaticData.Tower.TowerLevels":GetData(id)
	local level = levelData:GetLevelid()
	self.level = level
	local power = self:GetPower()
	-- local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
 --    local UserDataType = require "Framework.UserDataType"
	-- local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)
	-- local aaa = self:GetCachedData(UserDataType.CardBagData):GetRoleByUid(playerData:GetUid())
	-- local power = aaa:GetPower()
	self:LoadTower(level,id,power)
	self:LoadAward(level)
	local windowManager = utility:GetGame():GetWindowManager()
	if data.isNeedAddAttribute  then
		--加成属性
		for i=1,#data.attributeIDArray do
			debug_print("屬性加成："..data.attributeIDArray[i])
		end
		windowManager:Show(require "GUI.Tower.TowerAttrAdd",data.attributeIDArray,data.currentStar)
	end
	if data.isShowSecretShop then
		--神秘商店
		self:LoadSecretShop(data.shopItemID)
	end
end

function TowerCls:GetPower()
	local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local defence = cardBagData:GetTroopByLineup(kLineup_TowerAttack)
    fightingCapacity = 0
    for i=1,#defence do
        local data = cardBagData:GetRoleByUid(defence[i])  
        if data ~= nil then
        	fightingCapacity = fightingCapacity+data:GetPower()
        end
    end
    return fightingCapacity
end

--加载属性
function TowerCls:LoadAttr(attrArray)
	self.node = {}
	if attrArray ~= nil then
		for i=1,#attrArray do
			local attrItemCls = require "GUI.Tower.TowerAttrItem".New(self.attrParent,1,attrArray[i].attributeKey,attrArray[i].attributeValue)
			self.node[i] = attrItemCls
			self:AddChild(self.node[i])
		end
	end
end


--加载神秘商店
function TowerCls:LoadSecretShop(id)
	local windowManager = utility:GetGame():GetWindowManager()
	windowManager:Show(require "GUI.Tower.TowerSecretShop",id)
end

--加载塔
function TowerCls:LoadTower(level,id,power)
	self.towerParent.localPosition = self.position
	self.towerItem = {}
	local keys = Data.TowerLevels.Manager.Instance():GetKeys()
	local towerData = require "StaticData.Tower.Tower":GetData(1)
	local bigLevel = towerData:GetBigLevel()
	local count = keys.Length/bigLevel
	
		-- for i=1,4 do
		-- 	local toweItemCls = require "GUI.Tower.TowerItem".New(self.towerParent,1)
		-- 	self.towerItem[i] = toweItemCls
		-- 	self:AddChild(self.towerItem[i])
		-- end
	if level < count - 1 then
		for i=1,6 do
			local toweItemCls = require "GUI.Tower.TowerItem".New(self.towerParent,1)
			self.towerItem[i] = toweItemCls
			if level == 1 then 
				self.towerItem[1]:SetPower(power,level,id)
			elseif level == 2 and i == 2 then
				-- self.towerMove = true
				self.towerItem[i]:SetPower(power,level,id)
			elseif level > 2 then
				if i == 3 then
					self.towerItem[i]:SetPower(power,level,id)
				end
				if i >= 3 then
					self.towerMove = true
				end
			end
			self:AddChild(self.towerItem[i])
		end
		
	elseif level == count then
		for i=1,2 do
			local toweItemCls = require "GUI.Tower.TowerItem".New(self.towerParent,1)
			self.towerItem[i] = toweItemCls
			self:AddChild(self.towerItem[i])
		end
		local toweItemCls = require "GUI.Tower.TowerItem".New(self.towerParent,2)
		self.towerItem[3] = toweItemCls
		self.towerItem[3]:SetPower(power,level,id)
		self:AddChild(self.towerItem[3])
	elseif level == count - 1 then
		for i=1,3 do
			local toweItemCls = require "GUI.Tower.TowerItem".New(self.towerParent,1)
			self.towerItem[i] = toweItemCls
			if i == 3 then
				self.towerMove = true
				self.towerItem[3]:SetPower(power,level,id)
			end
			self:AddChild(self.towerItem[i])
		end
		local toweItemCls = require "GUI.Tower.TowerItem".New(self.towerParent,2)
		self.towerItem[4] = toweItemCls
		self:AddChild(self.towerItem[4])
	end
end

function TowerCls:RemoveTower()
	if self.towerItem ~= nil then
		for i=1,#self.towerItem do
			self:RemoveChild(self.towerItem[i],true)
		end
	end
end

--加载通关奖励
function TowerCls:LoadAward(level)
	local id = self:GetLevelIdTable(level)
	local table = {}
	if id ~= nil then
		for i=1,#id do
			local data = require "StaticData.Tower.TowerBiglevelaward":GetData(id[i])
			local count = data:GetAwarditem().Count - 1
			for j=0,count do
				table[(2*i+j-1)] = {}
				table[(2*i+j-1)].itemID = data:GetAwarditem()[j]
				table[(2*i+j-1)].itemNum = data:GetAwardnum()[j]
			end
		end
	end
	local gametool = require "Utils.GameTools"
	for i=1,#table do
		local _,data,_,iconPath,itemType = gametool.GetItemDataById(table[i].itemID)
		utility.LoadSpriteFromPath(iconPath,self.itemIcon[i])
		local color = gametool.GetItemColorByType(itemType,data)
		local PropUtility = require "Utils.PropUtility"
 		PropUtility.AutoSetRGBColor(self.itemFrame[i],color)
 		self.itemNum[i].text = table[i].itemNum
	end
end

--获取大关卡ID
function TowerCls:GetLevelIdTable(level)
	local idTabel = {}
	local towerData = require "StaticData.Tower.Tower":GetData(1)
	local bigLevel = towerData:GetBigLevel()
	local towerLevel = require "StaticData.Tower.TowerBiglevelaward"
	local keys = towerLevel:GetKeys()
	local count,_ = math.modf((level - 1)/bigLevel)
	local number = (count+1) * bigLevel
	for i=0,(keys.Length - 1) do
		local data = towerLevel:GetData(keys[i])
		if data:GetLevel() == number then
			idTabel[#idTabel + 1] = data:GetID()
		end
	end
	local firstCount = number - 2
	self.notice.text = string.format(TowerString[0],firstCount,number)
	return idTabel
end

function TowerCls:RemoveAll()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
end

function TowerCls:ShowSweepAward(item)
	local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Tower.TowerSweepAward",item,1)
end

function TowerCls:ShowAwardPanel(item)
	local itemstables = {}
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	for i=1,#item do
		local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(item[i].itemID)
		itemstables[i] = {}
		itemstables[i].id = item[i].itemID
		itemstables[i].count = item[i].itemNum
		local color = gametool.GetItemColorByType(itemType,data)
		-- debug_print(color)
		itemstables[i].color = color
	end

	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
local moveSpeed = 40
local backCloudTime = 2
local cloudTime = 5
local backCloudBool = true
local cloudBool = true
local curBackCloudTime = 0
local curCloudTime = 0
--云动画
function TowerCls:MoveCloud()
	if backCloudBool then
		self.BackCloud:Translate(Vector3.left * Time.deltaTime * moveSpeed)
		if self.BackCloud.localPosition.x <= self.BackCloudPosX then
			backCloudBool = false
			-- self.BackCloud.localPosition = Vector2(-self.BackCloudPosX,self.BackCloud.localPosition.y)
		end
	else
		curBackCloudTime = curBackCloudTime + Time.deltaTime;
        if backCloudTime - curBackCloudTime <= 0 then
           self.BackCloud.localPosition = Vector2(-self.BackCloudPosX,self.BackCloud.localPosition.y)
           backCloudBool = true
           curBackCloudTime = 0
        end
	end
	if cloudBool then
		self.Cloud:Translate(Vector3.right * Time.deltaTime * moveSpeed)
		if self.Cloud.localPosition.x >= self.CloudPosX then
			cloudBool = false
			-- self.Cloud.localPosition = Vector2(-self.CloudPosX,self.Cloud.localPosition.y)
		end
	else
		curCloudTime = curCloudTime + Time.deltaTime;
        if cloudTime - curCloudTime <= 0 then
           self.Cloud.localPosition = Vector2(-self.CloudPosX,self.Cloud.localPosition.y)
           cloudBool = true
           curCloudTime = 0
        end
	end
	
end


--塔动画
function TowerCls:MoveTower()
	if self.towerMove then
		if self.towerParent.localPosition.y > movePosY then
			self.towerParent:Translate(Vector3.down * Time.deltaTime * speed)
		else
			self.towerMove = false
		end
	end
end

return TowerCls