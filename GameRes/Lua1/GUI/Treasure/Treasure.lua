local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local unityUtils = require "Utils.Unity"
-- local messageManager = require "Network.MessageManager"
local TreasureCls = Class(BaseNodeClass)
require "System.LuaDelegate"
function TreasureCls:Ctor(callback,tables)
		debug_print("^^^^^^^^^^^^^^^^^^^^^^^^^^",tables)
	self.tables=tables
	 if callback ~=nil then
        self.callback = LuaDelegate.New()
        self.callback:Set(tables, callback)
     end
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TreasureCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Treasure', function(go)
		self:BindComponent(go)
	end)
end

function TreasureCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function TreasureCls:OnResume()
	-- 界面显示时调用
	TreasureCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitViews()
end

function TreasureCls:OnPause()
	-- 界面隐藏时调用
	TreasureCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function TreasureCls:OnEnter()
	-- Node Enter时调用
	TreasureCls.base.OnEnter(self)
end

function TreasureCls:OnExit()
	-- Node Exit时调用
	TreasureCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function TreasureCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility:GetGame()
	-- self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Backbg = transform:Find('Back/Backbg'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackButton = transform:Find('Back/BackButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.BossLable = transform:Find('Back/BossLable'):GetComponent(typeof(UnityEngine.UI.Image))
	self.OpenButton = transform:Find('OpenButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.OpenNeed = transform:Find('OpenButton/DiamondCostText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OpenNeedIcon = transform:Find('OpenButton/DiamondIcon')
	self.OpenNeedIcon.gameObject:SetActive(false)
	self.treasureBoxAnim={}
	for i=1,10 do
		self.treasureBoxAnim[#self.treasureBoxAnim+1]=transform:Find('Box/'..i):GetComponent(typeof(UnityEngine.Animator))
	end
	
	self.Blackbg = transform:Find('LeftTopText/Blackbg'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.Notice = transform:Find('LeftTopText/Count/Notice'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.Image = transform:Find('LeftTopText/Count/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	--剩余次数
	self.CountLabel = transform:Find('LeftTopText/Count/CountLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.Notice1 = transform:Find('LeftTopText/Get/Notice'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.Image1 = transform:Find('LeftTopText/Get/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	--获得金币
	self.GetLabel = transform:Find('LeftTopText/Get/GetLabel'):GetComponent(typeof(UnityEngine.UI.Text))
--	self.objTrans = UnityEngine.GameObject.Instantiate(utility.LoadResourceSync("UI/Prefabs/D_Choukachangjing", typeof(UnityEngine.GameObject)))
	self.treasureAnimator=transform:Find("D_Choukachangjing/baoxiang"):GetComponent(typeof(UnityEngine.Animator))
	-- utility.LoadNewGameObjectAsync('UI/Models/D_Choukachangjing', function(go)
	-- 	--self:BindComponent(go)
	-- end)
	--普通开宝箱特效
	self.bao=transform:Find("D_Choukachangjing/bao")
	self.bao.gameObject:SetActive(false)
	--暴击开宝箱特效
	self.baoji = transform:Find("D_Choukachangjing/baoji")
	self.baoji.gameObject:SetActive(false)

	self.baojiLayout = transform:Find("Baoji")
	self.baojiImage = transform:Find("Baoji/Baoji"):GetComponent(typeof(UnityEngine.UI.Image))
	self.BoxBaojiText = transform:Find('Baoji'):GetComponent(typeof(UnityEngine.Animator))
end
function  TreasureCls:InitViews()
	
    local playerData = self:GetPlayerData()
    local remainCount = playerData:GetRemainBuyCoinCount()
    local alreadyCount = playerData:GetAlreadyBuyCoinCount()
    local staticDataCls = require "StaticData.Player.CoinBuy"
    local keys = staticDataCls:GetKeys()
    local maxCount = keys[keys.Length -1]
    local id = math.min(alreadyCount +1,maxCount)
    local staticData = staticDataCls:GetData(id)

    local cost = staticData:GetPrice()
    self.lastNum = staticData:GetNum()
    debug_print(CommonStringTable[7],cost,CommonStringTable[8],self.lastNum,CommonStringTable[9],alreadyCount,remainCount)
  --  str = string.format(CommonStringTable[7],cost,CommonStringTable[8],num,CommonStringTable[9],alreadyCount,remainCount)
   -- self:ButRequest(str,self.OnVipBuyCoinRequest)
   self.allCount=(alreadyCount+remainCount)
   self.CountLabel.text=remainCount.."/"..self.allCount
   self.GetLabel.text= self.lastNum
   self.remainCount= remainCount
  
   --self:PlayAnim(self.allCount-remainCount)
    if cost <= 0 then
    	self.OpenNeedIcon.gameObject:SetActive(false)
    	self.OpenNeed.text = "本次免费"

   	else
 		self.OpenNeed.text=cost
 		self.OpenNeedIcon.gameObject:SetActive(true)
   	end
   --	self.treasureBoxAnim[1]:CrossFade("default",0)
  -- local count = (self.allCount-remainCount)%10
--	debug_print(count,num,"==========")
    -- for i=1,#self.treasureBoxAnim do
    -- 	if count >=i then
    -- 		debug_print("BoxColse",i)
    -- 		self.treasureBoxAnim[i]:CrossFade("BoxColse",1)
    -- 	else
    -- 		debug_print("default",i)

    -- 		self.treasureBoxAnim[i]:CrossFade("default",1)
    -- 	end

    -- end
end

function TreasureCls:GetPlayerData()
    -- 获取玩家数据
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    return userData
end


function TreasureCls:RegisterControlEvents()
	-- 注册 BackButton 的事件
	self.__event_button_onBackButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackButtonClicked, self)
	self.BackButton.onClick:AddListener(self.__event_button_onBackButtonClicked__)

	-- 注册 OpenButton 的事件
	self.__event_button_onOpenButtonClicked__ = UnityEngine.Events.UnityAction(self.OnOpenButtonClicked, self)
	self.OpenButton.onClick:AddListener(self.__event_button_onOpenButtonClicked__)

end

function TreasureCls:UnregisterControlEvents()
	-- 取消注册 BackButton 的事件
	if self.__event_button_onBackButtonClicked__ then
		self.BackButton.onClick:RemoveListener(self.__event_button_onBackButtonClicked__)
		self.__event_button_onBackButtonClicked__ = nil
	end

	-- 取消注册 OpenButton 的事件
	if self.__event_button_onOpenButtonClicked__ then
		self.OpenButton.onClick:RemoveListener(self.__event_button_onOpenButtonClicked__)
		self.__event_button_onOpenButtonClicked__ = nil
	end

end

function TreasureCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CVipDiamondBuyCoinQueryResult, self, self.VipDiamondBuyCoinQueryResult)

end

function TreasureCls:UnregisterNetworkEvents()
		self.game:UnRegisterMsgHandler(net.S2CVipDiamondBuyCoinQueryResult, self, self.VipDiamondBuyCoinQueryResult)

end

local function CloseNode(self,timer,msg)
	coroutine.wait(timer/2)
	local baoJiNum = msg.curBuyGetCoinNums/self.lastNum
	if baoJiNum > 1 then
		self.baoji.gameObject:SetActive(false)
		self.baoji.gameObject:SetActive(true)
		--暴击数值显示
		utility.LoadSpriteFromPath("UI/Atlases/Baoji/"..baoJiNum, self.baojiImage)
		self.BoxBaojiText:CrossFade("Box_Baoji",0)
	else

		self.bao.gameObject:SetActive(false)
		self.bao.gameObject:SetActive(true)
	end

	coroutine.wait(timer/2)
	self.BoxBaojiText:CrossFade("default",0)

	self.OpenButton.enabled=true
	self.CountLabel.text=msg.surplusBuyDone.."/"..self.allCount
 	self.remainCount=msg.surplusBuyDone
    self.GetLabel.text=msg.curAtleastGetCoin
    self.OpenNeed.text=msg.curBuyNeedDiamonds

    hzj_print("暴击率",msg.curBuyGetCoinNums/self.lastNum)

	local windowManager = self:GetGame():GetWindowManager()
	local AwardCls = require "GUI.Task.GetAwardItem"	
	self.items={}
	self.items[1]={}
	self.items[1].id=10410002
	self.items[1].count=msg.curBuyGetCoinNums	
	self.items[1].color=nil
	windowManager:Show(AwardCls,self.items,self,self.CallBack)
	self:InitViews()
	
end
function TreasureCls:VipDiamondBuyCoinQueryResult(msg)
		
	debug_print(msg.surplusBuyDone,msg.curBuyNeedDiamonds,msg.curAtleastGetCoin)
	
    --self:PlayAnim(self.allCount-msg.surplusBuyDone)

    self.treasureAnimator:CrossFade("Take 001",0)
    self:StartCoroutine(CloseNode,1.6,msg)


end
function TreasureCls:CallBack()
	hzj_print("CallBack")
	self.treasureAnimator:CrossFade("default",0)
 	
end

function TreasureCls:DelayTime(timer,msg)
				
end
function TreasureCls:PlayAnim(num)

	--self.treasureBoxAnim[1]:CrossFade("boxAnim",0)
	-- local count = num%10
	-- if count ==0 then
	-- 	self.treasureBoxAnim[10]:CrossFade("boxAnim",1)

	-- else
	--     for i=1,#self.treasureBoxAnim do
	--     	if count >i then
	--     		self.treasureBoxAnim[i]:CrossFade("BoxColse",1)
	--     	elseif count == i then
	-- 			self.treasureBoxAnim[i]:CrossFade("boxAnim",1)
	--     	else
	--     		self.treasureBoxAnim[i]:CrossFade("default",1)
	--     	end

	--     end
 --    end
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function TreasureCls:OnBackButtonClicked()
	 if  self.callback ~=nil then
        self.callback:Invoke(self.tables)
    end 
	--BackButton控件的点击事件处理
	local sceneManager = self.game:GetSceneManager()
    sceneManager:PopScene()
end

function TreasureCls:OnOpenButtonClicked()
	debug_print("TreasureCls:OnOpenButtonClicked()")
	if self.remainCount > 0 then
	 	self.OpenButton.enabled=false
		
		--OpenButton控件的点击事件处理
		utility:GetGame():SendNetworkMessage( require"Network/ServerService".OnVipBuyTiliCoin(2))	
	 else
	 	local windowManager = self:GetGame():GetWindowManager()
		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
		windowManager:Show(ConfirmDialogClass, "购买次数已用完")

	 end
end

return TreasureCls
