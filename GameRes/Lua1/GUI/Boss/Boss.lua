local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
 local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local BossCls = Class(BaseNodeClass)

function BossCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BossCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Boss', function(go)
		self:BindComponent(go)
	end)
end

function BossCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end
local function CloseUIScene(self)

	local UserDataType = require "Framework.UserDataType"
    local worldBossData = self:GetCachedData(UserDataType.WorldBossData)
    debug_print(worldBossData:Count(),"  ===============")
    if worldBossData:Count()<=0 then
        self:OnBackButtonClicked()
    end

end
function BossCls:OnResume()
	-- 界面显示时调用
	BossCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)
	self.game:SendNetworkMessage(require "Network.ServerService".WorldBossQueryRequest())
	CloseUIScene(self)
end



function BossCls:OnPause()
	-- 界面隐藏时调用
	BossCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function BossCls:OnEnter()
	-- Node Enter时调用
	BossCls.base.OnEnter(self)
end

function BossCls:OnExit()
	-- Node Exit时调用
	BossCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BossCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility:GetGame()
--	self.Base = transform:Find('Base/Base'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.BaseFrameAbove = transform:Find('Base/BaseFrameAbove'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.BaseFrameBelow = transform:Find('Base/BaseFrameBelow'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.Backbg = transform:Find('Base/Title/Backbg'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackButton = transform:Find('Base/Title/BackButton'):GetComponent(typeof(UnityEngine.UI.Button))
--	self.BossLable = transform:Find('Base/Title/BossLable'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Mainbg = transform:Find('MainPanel/Mainbg'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image = transform:Find('MainPanel/LeftPanel/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	--Boss 立绘
	self.Bossimg = transform:Find('MainPanel/LeftPanel/Bossimg'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.Scrollbg = transform:Find('MainPanel/LeftPanel/Xuetiao/Scrollbg'):GetComponent(typeof(UnityEngine.UI.Image))
	--血条
	self.Fill = transform:Find('MainPanel/LeftPanel/Xuetiao/Scrollbg/Fill'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.Lvicon = transform:Find('MainPanel/LeftPanel/Xuetiao/Lvicon'):GetComponent(typeof(UnityEngine.UI.Image))
	--Boss 级别	
	self.LevelText = transform:Find('MainPanel/LeftPanel/Xuetiao/LevelText'):GetComponent(typeof(UnityEngine.UI.Text))
	--血量
	self.JinyanText = transform:Find('MainPanel/LeftPanel/Xuetiao/JinyanText'):GetComponent(typeof(UnityEngine.UI.Text))
--self.Namebg = transform:Find('MainPanel/LeftPanel/Namebg'):GetComponent(typeof(UnityEngine.UI.Image))
	--Boss 名字
	self.BossNameText = transform:Find('MainPanel/LeftPanel/Namebg/BossNameText'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 特性说明按钮
	self.TexinButton = transform:Find('MainPanel/LeftPanel/TexinButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
--	self.ShenyuText = transform:Find('MainPanel/LeftPanel/ShenyuText'):GetComponent(typeof(UnityEngine.UI.Text))
--	self.Graybg = transform:Find('MainPanel/LeftPanel/Graybg'):GetComponent(typeof(UnityEngine.UI.Image))
	--剩余时间
	self.TimeText = transform:Find('MainPanel/LeftPanel/Graybg/TimeText'):GetComponent(typeof(UnityEngine.UI.Text))

	self.layout = transform:Find('MainPanel/LeftPanel/Prize')

	self.BossTip = transform:Find('MainPanel/BossTip'):GetComponent(typeof(UnityEngine.UI.Text))

	self.BossTip.gameObject:SetActive(false)
	self.rightTran= transform:Find('MainPanel/RightPanel/HurtList')
	self.leftTran= transform:Find('MainPanel/LeftPanel')
	self.rightTran.gameObject:SetActive(true)
	self.bossRankTran= transform:Find('MainPanel/RightPanel/HurtList/Paihang')
	self.bossRankTip= transform:Find('MainPanel/RightPanel/HurtList/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks={}
	self.playerRanks[#self.playerRanks+1]={}
	self.playerRanks[#self.playerRanks].transform=transform:Find('MainPanel/RightPanel/HurtList/Paihang/Myself')
	self.playerRanks[#self.playerRanks].rank = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Myself/ListNumberText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].name = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Myself/PlayerNameText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].lv = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Myself/LevelText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].hurt = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Myself/HurtNumberText '):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].headIcon = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Myself/Headimg/Headicon'):GetComponent(typeof(UnityEngine.UI.Image))
	

	self.playerRanks[#self.playerRanks+1]={}
	self.playerRanks[#self.playerRanks].transform=transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other1')
	self.playerRanks[#self.playerRanks].rank = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other1/ListNumberText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].name = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other1/PlayerNameText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].lv = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other1/LevelText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].hurt = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other1/HurtNumberText '):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].headIcon = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other1/Headimg/Headicon'):GetComponent(typeof(UnityEngine.UI.Image))
	

	self.playerRanks[#self.playerRanks+1]={}

	self.playerRanks[#self.playerRanks].transform=transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other2')

	self.playerRanks[#self.playerRanks].rank = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other2/ListNumberText'):GetComponent(typeof(UnityEngine.UI.Text))

	self.playerRanks[#self.playerRanks].name = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other2/PlayerNameText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].lv = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other2/LevelText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].hurt = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other2/HurtNumberText '):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].headIcon = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other2/Headimg/Headicon'):GetComponent(typeof(UnityEngine.UI.Image))
	


	self.playerRanks[#self.playerRanks+1]={}
	self.playerRanks[#self.playerRanks].transform=transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other3')

	self.playerRanks[#self.playerRanks].rank = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other3/ListNumberText'):GetComponent(typeof(UnityEngine.UI.Text))

	self.playerRanks[#self.playerRanks].name = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other3/PlayerNameText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].lv = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other3/LevelText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].hurt = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other3/HurtNumberText '):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].headIcon = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other3/Headimg/Headicon'):GetComponent(typeof(UnityEngine.UI.Image))
	



	self.playerRanks[#self.playerRanks+1]={}
	self.playerRanks[#self.playerRanks].transform=transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other4')

	self.playerRanks[#self.playerRanks].rank = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other4/ListNumberText'):GetComponent(typeof(UnityEngine.UI.Text))

	self.playerRanks[#self.playerRanks].name = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other4/PlayerNameText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].lv = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other4/LevelText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].hurt = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other4/HurtNumberText '):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerRanks[#self.playerRanks].headIcon = transform:Find('MainPanel/RightPanel/HurtList/Paihang/Other4/Headimg/Headicon'):GetComponent(typeof(UnityEngine.UI.Image))
	

	self.keys={}
	self.keys[#self.keys+1]=transform:Find('MainPanel/RightPanel/Cishu/Yaoshiicon')
	self.keys[#self.keys+1]=transform:Find('MainPanel/RightPanel/Cishu/Yaoshiicon1')
	self.keys[#self.keys+1]=transform:Find('MainPanel/RightPanel/Cishu/Yaoshiicon2')
	self.keys[#self.keys+1]=transform:Find('MainPanel/RightPanel/Cishu/Yaoshiicon3')
	self.keys[#self.keys+1]=transform:Find('MainPanel/RightPanel/Cishu/Yaoshiicon4')
	self.keys[#self.keys+1]=transform:Find('MainPanel/RightPanel/Cishu/Yaoshiicon5')
	for i=1,#self.keys do
		print(self.keys[i].gameObject.name,"   --------------------------")
	end


	--恢复时间
	self.HuifuTimeText = transform:Find('MainPanel/RightPanel/Graybg/HuifuTimeText'):GetComponent(typeof(UnityEngine.UI.Text))
	--购买钥匙
	self.AddButton = transform:Find('MainPanel/RightPanel/AddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ListButton = transform:Find('MainPanel/ListButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ShareButton = transform:Find('MainPanel/ShareButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ShareButtonImage = transform:Find('MainPanel/ShareButton'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BattleButton = transform:Find('MainPanel/BattleButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BattleButtonImage = transform:Find('MainPanel/BattleButton'):GetComponent(typeof(UnityEngine.UI.Image))

	

end
function  BossCls:Update()
	if self.isShow then

		self.Image.transform.localEulerAngles=Vector3(0, 0, self.Image.transform.localEulerAngles.z-0.8)

	end

	if self.timeFlag then
		if os.time()-self.lastT>=1 then
			self.lastT=os.time()
			self.countTime=self.countTime-1
		end
		if self.countTime <= 0 then
			self.TimeText.text=""
			self.timeFlag=false

		else
			self.TimeText.text=utility.ConvertTime(self.countTime)

		end

	end

	if self.timeChallengeFlag then
		if os.time()-self.lastchallengeTime>=1 then
			self.lastchallengeTime=os.time()
			self.challengeTime=self.challengeTime-1
		end
		--debug_print(self.msg.challengeTimes,"")
		if self.challengeTime <= 0 and self.msg.challengeTimes<6 then
			self.timeChallengeFlag=false
			self.HuifuTimeText.text=""
			self.game:SendNetworkMessage(require "Network.ServerService".WorldBossQueryRequest())			
		else
			self.HuifuTimeText.text=utility.ConvertTime(self.challengeTime)

		end

	end

end

local function ShowKeys(self,count)
	for i=1,self.maxKey do
		if i<= count then
			self.keys[i].gameObject:SetActive(true)
		else
			self.keys[i].gameObject:SetActive(false)
		end
	end
end

function BossCls:InitViews()
	hzj_print("self.msg.aggressor.length",self.msg.worldBossData.sharerId,self.msg.worldBossData.bossLevel)
	if self.msg.worldBossData.sharerId~=0 then
		self.isShow=true
		self.leftTran.gameObject:SetActive(true)
		self.rightTran.gameObject:SetActive(true)
		self.BossTip.gameObject:SetActive(false)

		if #self.msg.aggressor<=0 then
			self.bossRankTran.gameObject:SetActive(false)
			--self.bossRankTip.gameObject:SetActive(true)
			self.bossRankTip.text="亲，您的Boss还没有人挑战！"
		else
			self.bossRankTran.gameObject:SetActive(true)
			self.bossRankTip.gameObject:SetActive(false)
			debug_print("#self.msg.aggressor",#self.msg.aggressor)
			for i=1,#self.playerRanks do
				if i>#self.msg.aggressor then
					self.playerRanks[i].transform.gameObject:SetActive(false)

				else
					self.playerRanks[i].transform.gameObject:SetActive(true)
					self.playerRanks[i].rank.text=self.msg.aggressor[i].rank
					self.playerRanks[i].name.text=self.msg.aggressor[i].name
					self.playerRanks[i].lv.text=self.msg.aggressor[i].level
					self.playerRanks[i].hurt.text=self.msg.aggressor[i].hit					
					utility.LoadRoleHeadIcon(self.msg.aggressor[i].picId, self.playerRanks[i].headIcon)
				end			
				
			end
		
		end

		
		debug_print(self.msg.worldBossData.bossLevel,"self.msg.worldBossData.bossLevel",self.msg.worldBossData.bossId)

		--boss数据
		local WorldBossLevelData = require "StaticData.Boss.WorldBossLevel":GetData(self.msg.worldBossData.bossId)
		self.bossID = WorldBossLevelData:GetBossID()
		self.bossInfo=WorldBossLevelData:GetInfo()
		local bossType = WorldBossLevelData:GetBossIndexByLevel(self.msg.worldBossData.bossLevel)
		local _,_,awardItem,awardItemNum,extraAwardItems,extraAwardItemNums,bossID,bossColor,bosslevel = WorldBossLevelData:GetBossDataByIndex(bossType)
		debug_print(bosslevel,"  ************",awardItem,awardItemNum,extraAwardItems,extraAwardItemNums,bossID,bossColor,bosslevel)
		self.bosslevel=bosslevel

		self.LevelText.text=self.msg.worldBossData.bossLevel
		self.JinyanText.text=self.msg.worldBossData.hp.."/"..self.msg.worldBossData.maxHp
		debug_print(self.msg.worldBossData.hp,self.msg.worldBossData.maxHp,"+++++++++")
		self.Fill.fillAmount=(self.msg.worldBossData.hp)/self.msg.worldBossData.maxHp

		if self.awardItem==nil or self.awardItem.itemID~=awardItem then
			self.awardItem = require 'GUI.Boss.BossAwardItem'.New(self.layout,awardItem,awardItemNum,nil)
		    self:AddChild(self.awardItem)
		end
		if self.extraAwardItem==nil or self.extraAwardItem.itemID~=extraAwardItems then
			self.extraAwardItem= require 'GUI.Boss.BossAwardItem'.New(self.layout,extraAwardItems,extraAwardItemNums,nil)
			self:AddChild(self.extraAwardItem)
		end
		--时间倒计时

		self.timeFlag=true
		self.lastT =0
		self.countTime=self.msg.worldBossData.validTime/1000
		debug_print(countTime,"countTime")

  		local roleMgr = require "StaticData.Role"
        local roleData = roleMgr:GetData(bossID)
        self.BossNameText.text=roleData:GetInfo()
		--Boss的立绘
		--utility.LoadRolePortraitImage(bossID,self.Bossimg)
		self:ShowBossPortrait(self.msg.worldBossData.bossId)
		self.BattleButtonImage.material = nil
		self.BattleButton.enabled=true

	else
		self.isShow=false
		self.leftTran.gameObject:SetActive(false)  
		self.rightTran.gameObject:SetActive(false)
		self.BossTip.gameObject:SetActive(true)
		self.BossTip.text="您还没有探索到自己的Boss！"
		self.BattleButtonImage.material = utility.GetGrayMaterial()
		self.BattleButton.enabled=false
		

	end
	debug_print("分享状态",self.msg.alSharer)
	--分享按钮
	if self.msg.alSharer then
		self.ShareButton.enabled=true
		self.ShareButtonImage.material = nil
	else

		self.ShareButtonImage.material = utility.GetGrayMaterial()
		self.ShareButton.enabled=false
		
	end
	debug_print("钥匙数目",self.msg.challengeTimes)
	local WorldBossData = require "StaticData.Boss.WorldBoss":GetData(1)
	print(WorldBossData:GetChallengetimes(),"  *****************-")
	self.maxKey=WorldBossData:GetChallengetimes()
	--钥匙恢复时间
	self.HuifuTimeText.text=self.msg.nextTime
	debug_print(self.msg.nextTime,"hsddsfhkdshkkldskldsklj")
	--钥匙数目
	if self.msg.challengeTimes>=self.maxKey then
		self.HuifuTimeText.text=""
		self.timeChallengeFlag=false

	else
		self.timeChallengeFlag=true
		self.lastchallengeTime = 0
		self.challengeTime = self.msg.nextTime/1000+2

	end

	ShowKeys(self,self.msg.challengeTimes)
	self.buyTimes=self.msg.buyTimes



end

function BossCls:ShowBossPortrait( Id )
	if self.objParent ~=nil then
		return 

	end
	self.objParent = UnityEngine.GameObject.Instantiate(utility.LoadResourceSync("UI/Prefabs/ShowWorldBoss", typeof(UnityEngine.GameObject)))
	local objParentTrans = self.objParent.transform:Find('Point')
	UnityEngine.Object.DontDestroyOnLoad(self.objParent)
	local GameObject= UnityEngine.GameObject

	local WorldBossLevelData = require "StaticData.Boss.WorldBossLevel":GetData(Id)
	local bossId = WorldBossLevelData:GetBossID()
	local resPathMgr = require "StaticData.ResPath"
	local prefabName = resPathMgr:GetData(bossId):GetPath()
	local obj = GameObject.Instantiate(utility.LoadResourceSync(prefabName, typeof(UnityEngine.GameObject)))
	local position =WorldBossLevelData:GetBossPosition()
	local rotation =WorldBossLevelData:GetBossRotation()
	local scale =WorldBossLevelData:GetBossScale()
	--debug_print(position.x, position.y, position.z,"angle",rotation.x, rotation.y, rotation.z,"Scale",scale.x, scale.y, scale.z)
	obj.transform:SetParent(objParentTrans)
	obj.transform.localPosition=Vector3(position.x, position.y, position.z)
	obj.transform.localEulerAngles=Vector3(rotation.x, rotation.y, rotation.z)
	obj.transform.localScale=Vector3(scale.x, scale.y, scale.z)

end



function BossCls:RegisterControlEvents()
	-- 注册 BackButton 的事件
	self.__event_button_onBackButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackButtonClicked, self)
	self.BackButton.onClick:AddListener(self.__event_button_onBackButtonClicked__)

	-- 注册 TexinButton 的事件
	self.__event_button_onTexinButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTexinButtonClicked, self)
	self.TexinButton.onClick:AddListener(self.__event_button_onTexinButtonClicked__)

	-- 注册 AddButton 的事件
	self.__event_button_onAddButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAddButtonClicked, self)
	self.AddButton.onClick:AddListener(self.__event_button_onAddButtonClicked__)

	-- 注册 ListButton 的事件
	self.__event_button_onListButtonClicked__ = UnityEngine.Events.UnityAction(self.OnListButtonClicked, self)
	self.ListButton.onClick:AddListener(self.__event_button_onListButtonClicked__)

	-- 注册 ShareButton 的事件
	self.__event_button_onShareButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShareButtonClicked, self)
	self.ShareButton.onClick:AddListener(self.__event_button_onShareButtonClicked__)

	-- 注册 BattleButton 的事件
	self.__event_button_onBattleButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBattleButtonClicked, self)
	self.BattleButton.onClick:AddListener(self.__event_button_onBattleButtonClicked__)
end

function BossCls:UnregisterControlEvents()
	-- 取消注册 BackButton 的事件
	if self.__event_button_onBackButtonClicked__ then
		self.BackButton.onClick:RemoveListener(self.__event_button_onBackButtonClicked__)
		self.__event_button_onBackButtonClicked__ = nil
	end

	-- 取消注册 TexinButton 的事件
	if self.__event_button_onTexinButtonClicked__ then
		self.TexinButton.onClick:RemoveListener(self.__event_button_onTexinButtonClicked__)
		self.__event_button_onTexinButtonClicked__ = nil
	end

	-- 取消注册 AddButton 的事件
	if self.__event_button_onAddButtonClicked__ then
		self.AddButton.onClick:RemoveListener(self.__event_button_onAddButtonClicked__)
		self.__event_button_onAddButtonClicked__ = nil
	end

	-- 取消注册 ListButton 的事件
	if self.__event_button_onListButtonClicked__ then
		self.ListButton.onClick:RemoveListener(self.__event_button_onListButtonClicked__)
		self.__event_button_onListButtonClicked__ = nil
	end

	-- 取消注册 ShareButton 的事件
	if self.__event_button_onShareButtonClicked__ then
		self.ShareButton.onClick:RemoveListener(self.__event_button_onShareButtonClicked__)
		self.__event_button_onShareButtonClicked__ = nil
	end

	-- 取消注册 BattleButton 的事件
	if self.__event_button_onBattleButtonClicked__ then
		self.BattleButton.onClick:RemoveListener(self.__event_button_onBattleButtonClicked__)
		self.__event_button_onBattleButtonClicked__ = nil
	end
end

function BossCls:RegisterNetworkEvents()

	    self.game:RegisterMsgHandler(net.S2CWorldBossQueryResult, self, self.WorldBossQueryResult)
	    self.game:RegisterMsgHandler(net.S2CWBossListResult, self, self.WBossListResult)
		self.game:RegisterMsgHandler(net.S2CWBossSharerResult, self, self.WBossSharerResult)
		self.game:RegisterMsgHandler(net.S2CBuyWBossKeyResult, self, self.BuyWBossKeyResult)



end

function BossCls:UnregisterNetworkEvents()
		self.game:UnRegisterMsgHandler(net.S2CWorldBossQueryResult, self, self.WorldBossQueryResult)
		self.game:UnRegisterMsgHandler(net.S2CWBossListResult, self, self.WBossListResult)
		self.game:UnRegisterMsgHandler(net.S2CWBossSharerResult, self, self.WBossSharerResult)
		self.game:UnRegisterMsgHandler(net.S2CBuyWBossKeyResult, self, self.BuyWBossKeyResult)


end
function BossCls:WBossListResult(msg)

	debug_print("WBossListResult")


end
function BossCls:WorldBossQueryResult(msg)

	debug_print("WorldBossQueryResult")
	self.msg=msg
	self:InitViews()


end

function BossCls:BuyWBossKeyResult(msg)

	if msg.status then
		self.game:SendNetworkMessage(require "Network.ServerService".WorldBossQueryRequest())
		debug_print("购买钥匙成功")
		self.buyTimes=self.buyTimes-1

	else
		debug_print("购买钥匙失败")

	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BossCls:OnBackButtonClicked()
	--BackButton控件的点击事件处理
	UnityEngine.Object.Destroy(self.objParent)
	local sceneManager = self.game:GetSceneManager()
    sceneManager:PopScene()
end

function BossCls:OnTexinButtonClicked()
	--TexinButton控件的点击事件处理
	local infoData = require "StaticData.ChapterAdventureInfo"

	local descriptionData = infoData:GetData(self.bossInfo)
	local str = descriptionData:GetDescLong()
	
	-- local hintStr = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
	str = string.gsub(str,"\\n","\n")
	
    local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.CommonDescriptionModule",str)

end


local function OnConfirmBuy(self)
    print("向服务器发协议购买钥匙",self.buyKeys)
	self.game:SendNetworkMessage(require "Network.ServerService".BuyWBossKeyRequest())

end

local function OnCancelBuy(self)
  	 print("取消购买钥匙")
end


-- 购买钥匙按钮
function BossCls:OnAddButtonClicked()
		if self.buyTimes>0 then
		--AddButton控件的点击事件处理
		local WorldBossData = require "StaticData.Boss.WorldBoss":GetData(1)
		local utility = require "Utils.Utility"
		self.buyKeys=WorldBossData:GetChargedya()
	   	utility.ShowBuyConfirmDialog("是否花费"..self.buyKeys.."钻石购买一次挑战机会？(今日剩余购买次数为"..self.buyTimes..')', self, OnConfirmBuy, OnCancelBuy)
	else
		local windowManager = self.game:GetWindowManager()
		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
		windowManager:Show(ConfirmDialogClass, "购买次数已用完")
	end	


	
end
function BossCls:CallBack(self,bossData,bossLevel)	

	debug_print("BossCls:CallBack	",self.bossList,bossData.sharerId )
	if self.bossList~=nil then
		self.bossList:Close()
		self:RefreshFormation(bossLevel ,bossData)
	end
	
end
function BossCls:OnListButtonClicked()
	--ListButton控件的点击事件处理
	local windowManager = self.game:GetWindowManager()
	self.bossList=windowManager:Show(require "GUI.Boss.BossList",self,self.CallBack)
end
--分享
function BossCls:OnShareButtonClicked()
	debug_print("分享发送")
	self.game:SendNetworkMessage(require"Network/ServerService".WBossSharerRequest())

end

function BossCls:WBossSharerResult(msg)

		debug_print("分享状态",msg.status)
	local windowManager = utility:GetGame():GetWindowManager()
   	local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"
	if msg.status then	
		self.ShareButtonImage.material =nil
		--self.ShareButtonImage.ma	
		windowManager:Show(ConfirmDialogClass, "分享成功！")
	else
		windowManager:Show(ConfirmDialogClass, "分享失败！")
	end

end

function BossCls:OnBattleButtonClicked()
	--BattleButton控件的点击事件处理

	-- local sceneManager = self:GetGame():GetSceneManager()
 --    local FormationCls = require "GUI.Formation.Formation"  
 --    sceneManager:PushScene(FormationCls.New(kLineup_JourneyToExplore4,self.RefreshFormation,self))
 	debug_print(self.level ,self.msg.worldBossData)
 	self:RefreshFormation(self.bosslevel ,self.msg.worldBossData)
end

function BossCls:RefreshFormation(bosslevel,worldBossData)

	 debug_print("开始挑战！！！*****************************")
    local BattleUtility = require "Utils.BattleUtility"
 	local LocalDataType = require "LocalData.LocalDataType"
    local ServerService = require "Network.ServerService"


    --debug_print(self.bossTeamID,"  HHHHHHHHHHHHHHHHHHHHHHH",self.bosslevel)
	local foeTeams = BattleUtility.CreateBattleTeamsByLevelID(bosslevel)

	local WorldBossData = require "StaticData.Boss.WorldBoss":GetData(1)

	local sceneID= WorldBossData:GetSceneId()
    local battleParams = require "LocalData.Battle.BattleParams".New()
	battleParams:SetSceneID(sceneID)
	battleParams:SetScriptID(nil)
	battleParams:SetBattleType(kLineup_JourneyToExplore4)	
	battleParams:SetBattleOverLocalDataName(LocalDataType.BossBattleResult)
	
	battleParams:SetBattleStartProtocol(ServerService.WBossFightEndRequest(1,worldBossData.sharerId))

	battleParams:SetBattleResultResponsePrototype(net.S2CWBossFightEndResult)

	battleParams:SetRightDamageRate(100)

	battleParams:SetBattleResultViewClassName("GUI.Boss.BossBattleResult")
	battleParams:SetMaxBattleRounds(10)
	battleParams:SetBattleResultWhenReachMaxRounds(false)
	battleParams:SetPVPMode(true)
	-- battleParams:DisableManuallyOperation()
	battleParams:SetSkillRestricted(false)
	battleParams:SetUnlimitedRage(false)

	--设置boss的血量
	BattleUtility.SetCustomHpParameterInTeam(foeTeams[1], 5, tonumber(worldBossData.hp), tonumber(worldBossData.maxHp))


	local formation =  utility.StartBattle(battleParams, foeTeams, nil,function( attackRate,isThreeType,hp,maxHp )
		
		debug_print(isThreeType,hp,maxHp," ----------------")
		battleParams:SetRightDamageRate(attackRate)
		battleParams:SetBattleStartProtocol(ServerService.WBossFightEndRequest(isThreeType,worldBossData.sharerId))

		BattleUtility.SetCustomHpParameterInTeam(foeTeams[1], 5, tonumber(hp), tonumber(maxHp))
	end)
	debug_print("开始挑战 参数设置成功",worldBossData.sharerId)
	formation:SetBossID(worldBossData.sharerId)
 	formation:SetBossKey(self.msg.challengeTimes)

end


return BossCls
