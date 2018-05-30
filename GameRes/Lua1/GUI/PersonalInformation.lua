local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local PlayerPromote = require "StaticData.PlayerPromote"
local InitialCard = require "StaticData.InitialCard"
local PlayerHead = require "StaticData.PlayerHead"
local messageGuids = require "Framework.Business.MessageGuids"

require "Const"

local PersonalInformationCls = Class(BaseNodeClass)
windowUtility.SetMutex(PersonalInformationCls, true)

function PersonalInformationCls:Ctor()
	 
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function PersonalInformationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NeoPersonalInformation', function(go)
		self:BindComponent(go)
	end)
end

function PersonalInformationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()

end


function PersonalInformationCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function PersonalInformationCls:ResumeHeadImage()
	-- 显示界面
	for i=1,#self.headCard do
		self:AddChild(self.headCard[i])
	end
		for i=1,#self.heroHeadCard do
		self:AddChild(self.heroHeadCard[i])
	end


end

function PersonalInformationCls:ChildDidClickFunCallBack(tables,id)
--local  function ChildDidClickFunCallBack(self,id)
--	if self.allHeroHeadCard then
--		print(true)
--		else
--			print(false)
--			end
hzj_print("ChildDidClickFunCallBack",tables,id)
	local item=nil
	table.foreach(tables.allHeroHeadCard, function(i, v) 
		if i==id then	
			item=tables.allHeroHeadCard[i]
			tables.allHeroHeadCard[i]:CancleCheck()
			end

		 end) ;	
    tables.currentCardID=id
	tables.Effect:SetActive(true)
	tables.Effect.transform:SetParent(item.PersonalInformationHeadIcon.transform)
	tables.Effect.transform.localPosition=Vector3(0, 0, -1);
		tables.Effect.transform.localScale=Vector3(80, 80, 1);

	tables.script[#tables.script]:Init(tables.maskImage,item.PersonalInformationHeadIcon)
	--print("ChildDidClickFunCallBack",id,tables.currentCardID)
	-- body
end


function PersonalInformationCls:OnResume()
	-- 界面显示时调用
	PersonalInformationCls.base.OnResume(self)
	self:GetUnityTransform():SetAsLastSibling()


	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
    self:GetGame():SendNetworkMessage( require "Network/ServerService".TiliCountDownRequest(3))

	self:InitView()
	--self:RefreshHeadCard()
	self.ConfirmEffect:SetActive(false)
	
	-- self.game:SendNetworkMessage(require "Network.ServerService".LoadPlayer())--cardID请求
	self:ScheduleUpdate(self.Update)
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
       -- 	print("*********************************")
        transform.localScale = Vector3(s, s, s)
    end)
  --  self.ScrollbarVertical.value = 1
end

function PersonalInformationCls:OnExitTransitionDidStart(immediately)
	PersonalInformationCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function PersonalInformationCls:OnPause()
	-- 界面隐藏时调用
	PersonalInformationCls.base.OnPause(self)
	-- self:UnscheduleUpdate(self.UpdateData)
	self:UnregisterNetworkEvents()
	self:UnregisterControlEvents()
end

function PersonalInformationCls:OnEnter()
	-- Node Enter时调用
	PersonalInformationCls.base.OnEnter(self)

end

function PersonalInformationCls:OnExit()
	-- Node Exit时调用
	PersonalInformationCls.base.OnExit(self)
end

----------------测试End---------------------
function PersonalInformationCls:InitView()
	--获取玩家信息--名字，玩家ID，当前等级，Exp,---- 装备等级上限，英雄等级上限，英雄进阶上限
	local UserDataType = require "Framework.UserDataType"
	local userData = self:GetCachedData(UserDataType.PlayerData)
	self.PersonalInformationNameLabel.text = userData:GetName()
	self.PersonalInformationPlayerIdLabel.text = userData:GetUid()
	self.PersonalInformationLvNumLabel.text = userData:GetLevel()
	self.NowLvNumLabel.text = userData:GetLevel()
	self.EquipmentLvNumLabel.text = userData:GetLevel()
	self.CardLvNumLabel.text = userData:GetLevel()

	
	self.PersonalInformationExpNumLabel.text = userData:GetExp().."/"..self:GetCurrenLevelIntervarExp()
	self.TheMainCharacterExpFill.fillAmount = userData:GetExp()/self:GetCurrenLevelIntervarExp()--最大经验值
	--根据ID查询头像
	self.currentCardID=userData:GetHeadCardID()
	print(self.currentCardID,"  根据ID查询头像 ",userData:GetName())
	self:LoadImageBycardID(self.currentCardID)

	if self.HeroPromptText.gameObject.activeInHierarchy == true then
		self.HeroPromptText.gameObject:SetActive(false)
	 	self.InformationMask.gameObject:SetActive(true)
	 	self.ConfirmChangeHeadButton.gameObject:SetActive(false)
	 	self.ChangeHeadButton.gameObject:SetActive(true)	
	 	--self.ScrollView.content=self.InformationMask 
	 end

	local PlayerPromoteData= PlayerPromote:GetData(userData:GetLevel())
	local  willOpenList = PlayerPromoteData:GetWillOpenSystem()

	local systemBasisData = require"StaticData.SystemConfig.SystemBasis"
	local systemBasisInfoData = require"StaticData.SystemConfig.SystemBasisInfo"
	
	for i=1,#willOpenList do
		debug_print(systemBasisData:GetData(willOpenList[i]):GetMinLevel(),"&&&&&&&&&&&&&&&&&&&&&&")
		self.willOpens[i].willLevelObj.gameObject:SetActive(true)
		local info = systemBasisData:GetData(willOpenList[i]):GetInfo()
		local name = systemBasisInfoData:GetData(info):GetName()
		debug_print(name)


		self.willOpens[i].willLevel.text ='开放等级'..systemBasisData:GetData(willOpenList[i]):GetMinLevel()
		debug_print(systemBasisData:GetData(willOpenList[i]):GetMinLevel())

		self.willOpens[i].willName.text =name
	end
	if userData:GetLevel()<systemBasisData:GetData(13):GetMinLevel()then
		self.CardAdvancedNumLabel.text = "未开放"
		elseif userData:GetLevel()>=systemBasisData:GetData(13):GetMinLevel()and userData:GetLevel()<systemBasisData:GetData(14):GetMinLevel() then
			self.CardAdvancedNumLabel.text = "+1"
		elseif userData:GetLevel()>=systemBasisData:GetData(14):GetMinLevel()and userData:GetLevel()<systemBasisData:GetData(15):GetMinLevel() then
		
			self.CardAdvancedNumLabel.text = "+2"
		elseif userData:GetLevel()>=systemBasisData:GetData(15):GetMinLevel()and userData:GetLevel()<systemBasisData:GetData(16):GetMinLevel() then
					self.CardAdvancedNumLabel.text = "+3"

		elseif userData:GetLevel()>=systemBasisData:GetData(16):GetMinLevel()and userData:GetLevel()<systemBasisData:GetData(17):GetMinLevel() then
			self.CardAdvancedNumLabel.text = "+4"	
		elseif userData:GetLevel()>=systemBasisData:GetData(17):GetMinLevel()and userData:GetLevel()<systemBasisData:GetData(18):GetMinLevel() then
			self.CardAdvancedNumLabel.text = "+5"
		elseif userData:GetLevel()>=systemBasisData:GetData(18):GetMinLevel() then
			self.CardAdvancedNumLabel.text = "+6"
		end

	
	--	self.userData = require "Data.UserData"
  -- local roles = self.userData:GetRoles()
  -- print(userData:GetIsShowOnline(),"((((((((((((((((((((")

end

local function HasOwn(self, id)
--	print(id)
    return self.heroHeadCard[id] == true
end


--初始化已经获得的头像
function  PersonalInformationCls:InitCurrentOwnCardInfo()
	
	local UserDataType = require "Framework.UserDataType"
	local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	local count = cardBagData:Count()
	for i=1,count do
		local currentCard = cardBagData:GetRoleByPos(i)
		if currentCard:GetColor()>= PlayerHead:GetData(currentCard:GetId()):GetunlockParame2() then
			debug_print(self.Head,path,true,currentCard:GetId())
			local path = PlayerHead:GetData(currentCard:GetId()):GetIcon()
			self.headCard[i]=require"GUI.PersonalInformationChangeHead".New(self.Head,path,true,currentCard:GetId())
			self.headCard[i]:SetCallback(self,currentCard:GetId(),self.ChildDidClickFunCallBack)
			self:AddChild(self.headCard[i])
			self.heroHeadCard[currentCard:GetId()] = true
			self.allHeroHeadCard[currentCard:GetId()]=self.headCard[i]
		--	print(self,currentCard:GetId())
	     	HasOwn(self,currentCard:GetId())
     	end
	end
end




--初始化未获得的头像
function  PersonalInformationCls:InitCurrentNotGetCardInfo()
    local roleMgr = Data.Role.Manager.Instance()
    local keys = roleMgr:GetKeys()
    local roleMgr = require "StaticData.Role"
	
	 require "Game.Role"
    for i = 0, keys.Length-1 do
    --	print(keys[i])
    	local flag=HasOwn(self, keys[i])
        if not flag then
            local currentRole = Role.New()
             currentRole:UpdateForStatic(keys[i], 1, 1)
          --  print(currentRole:GetId())
            local data = roleMgr:GetData(currentRole:GetId()) 
          --  print(data:IsShowInCollection())
            if data:IsShowInCollection() then
            	 self.heroHeadCard[i]=require"GUI.PersonalInformationChangeHead".New(self.HeroHead,currentRole:GetHeadIcon(),false,currentRole:GetId())
	            self.heroHeadCard[keys[i]] = false
	            self.allHeroHeadCard[keys[i]]=self.heroHeadCard[i]
	            self:AddChild(self.heroHeadCard[i])
            end

           
           
        end
    end
end


function PersonalInformationCls:LoadImageBycardID(id)

	-- local cardName
 --    local roleMgr = Data.Role.Manager.Instance()
 --    local keys = roleMgr:GetKeys()
 -- 	require "Game.Role"
 --    for i = 0, keys.Length-1 do
 --    	if keys[i]==id then
 --            local currentRole = Role.New()
 --            currentRole:UpdateForStatic(keys[i], 1, 1)
 --            cardName=currentRole:GetHeadIcon()
 --        --   break
 --        end
 --    end
	-- local name = string.format("UI/Atlases/CardHead/%s", cardName)
     utility.LoadRoleHeadIcon(id , self.PersonalInformationHeadIcon)
end

-- function PersonalInformationCls:UpdateData()
-- 	self:InitView()
-- end

function PersonalInformationCls:GetCurrenLevelIntervarExp()
	local UserDataType = require "Framework.UserDataType"
	local userData = self:GetCachedData(UserDataType.PlayerData)
	if userData:GetLevel() == 80 then
		return PlayerPromote:GetData(79):GetexpPerLevel()
	end
	return PlayerPromote:GetData(userData:GetLevel()):GetexpPerLevel()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function PersonalInformationCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	--任务信息面板
	self.TranslucentLayer=transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.Base = transform:Find('Head/Base'):GetComponent(typeof(UnityEngine.UI.Image))  -- 头像BG
	self.PersonalInformationHeadIcon = transform:Find('PersonInfoPanel/InformationMask/Head/Base/PersonalInformationHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))  --头像Image
	self.PersonalInformationNameLabel = transform:Find('PersonInfoPanel/InformationMask/Information/PersonalInformationNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))  --名字显示
	--返回按钮
	self.PersonalInformationRetrunButton = transform:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button)) -- 返回按钮
	--更换头像按钮
	self.ChangeHeadButton = transform:Find('PersonInfoPanel/InformationMask/ChangeHeadButton'):GetComponent(typeof(UnityEngine.UI.Button))   --ConfirmChangeHeadButton更换头像按钮
	--确定按钮
	self.ConfirmChangeHeadButton = transform:Find('PersonInfoPanel/ChangeHeadMask/ChangeHeadButton'):GetComponent(typeof(UnityEngine.UI.Button))   --ConfirmChangeHeadButton更换头像按钮
	
	--更换名字BUTTON
	self.PersonalInformationModifyButton = transform:Find('PersonInfoPanel/InformationMask/Information/PersonalInformationModifyButton'):GetComponent(typeof(UnityEngine.UI.Button))  -- 更换name——Button
	--級別
	self.PersonalInformationLvNumLabel = transform:Find('PersonInfoPanel/InformationMask/Information/PersonalInformationLvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))  --Level num
	--经验Image
	self.TheMainCharacterExpFill = transform:Find('PersonInfoPanel/InformationMask/Information/Exp/TheMainCharacterExpFill'):GetComponent(typeof(UnityEngine.UI.Image))   --经验条
	--经验数值
	self.PersonalInformationExpNumLabel = transform:Find('PersonInfoPanel/InformationMask/Information/Exp/PersonalInformationExpNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))  -- 经验数值
	--玩家的ID
	self.PersonalInformationPlayerIdLabel = transform:Find('PersonInfoPanel/InformationMask/Information/PlayerId/PersonalInformationPlayerIdLabel'):GetComponent(typeof(UnityEngine.UI.Text)) --PlayerID点击复制
	--体力回复时间曼
	self.recoverAllTime = transform:Find('PersonInfoPanel/InformationMask/Information/Base/all/StaminaFullTime'):GetComponent(typeof(UnityEngine.UI.Text)) --PlayerID点击复制
	self.recoverAllTrans= transform:Find('PersonInfoPanel/InformationMask/Information/Base/all')
        self.recoverAllTrans.gameObject:SetActive(false)

	--玩家等级信息
	self.NowLvNumLabel = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/LvInformation/NowLvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))  -- 当前等级显示
	self.EquipmentLvNumLabel = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/LvInformation/EquipmentLvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))  --装备等级上限
	self.CardLvNumLabel = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/LvInformation/CardLvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))  -- 英雄等级上限
	self.CardAdvancedNumLabel = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/LvInformation/CardAdvancedNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))  -- 英雄进阶上限
	

	self.HeroPromptText = transform:Find('PersonInfoPanel/ChangeHeadMask') --:GetComponent(typeof(UnityEngine.UI.GridLayoutGroup)) -- 头像选择页面
	self.InformationMask = transform:Find('PersonInfoPanel/InformationMask')--:GetComponent(typeof(UnityEngine.UI.GridLayoutGroup))
	
--	self.TheMainCharacterExpSlider = transform:Find('TweenObj/Scroll View/Viewport/Content/InformationMask/Information/Exp/Slider'):GetComponent(typeof(UnityEngine.UI.Slider))   --经验条Slider
	--self.ScrollbarVertical = transform:Find('TweenObj/Scroll View/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.tweenObjectTrans = transform

	self.Head = transform:Find('PersonInfoPanel/ChangeHeadMask/Scroll View/Viewport/Content/InitialHeadLayout') -- 基礎頭像
	self.HeroHead = transform:Find('PersonInfoPanel/ChangeHeadMask/Scroll View/Viewport/Content/CardHeadLayout')--英雄頭像	
	self.maskImage=transform:Find('PersonInfoPanel/ChangeHeadMask/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BlackListButton = transform:Find('PersonInfoPanel/InformationMask/BlackListButton'):GetComponent(typeof(UnityEngine.UI.Button))  -- 更换name——Button
	self.ChangeCountButton = transform:Find('PersonInfoPanel/InformationMask/ChangeCountButton'):GetComponent(typeof(UnityEngine.UI.Button))  -- 更换name——Button
	self.HeadCrossButtonButton = transform:Find('PersonInfoPanel/ChangeHeadMask/CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))  -- 更换name——Button
		--背景按钮
	self.BackgroundButton = transform:Find('PersonInfoPanel/ChangeHeadMask/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	local sdkManager = self.game:GetSDKManager()
	if self:GetSDKManager():IsFuckingSDK() then
		self.ChangeCountButton.gameObject:SetActive(true)
	else
		self.ChangeCountButton.gameObject:SetActive(false)
	end

	self.ConfirmChangeHeadButton.gameObject:SetActive(false)
	self.headCard = {}
	self.heroHeadCard={}
	self.allHeroHeadCard={}

	---特效
	local Object = UnityEngine.Object
    local Resources = UnityEngine.Resources
	local resPathMgr = require "StaticData.ResPath"
	local data = resPathMgr:GetData(1016)
	self.path=data:GetPath()	
	self.Effect = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	print(type(self.Effect),self.Effect.name,self.Effect.transform)
	local effectTrans = self.Effect.transform
	local effectMeshRender = effectTrans:Find('UI_touxiangkuang/UI_touxiang_kuang1'):GetComponent(typeof(UnityEngine.MeshRenderer))
	effectMeshRender.sortingOrder = 151
	--effectMeshRender.gameObject.SetActive(false)

--	effectMeshRender.sortingOrder=150
	self.Effect:SetActive(false)
	
	data = resPathMgr:GetData(1017)
	self.path=data:GetPath()	
	self.ConfirmEffect = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	self.ConfirmEffect.transform:SetParent(self.PersonalInformationHeadIcon.transform)
	self.ConfirmEffect.transform.localPosition=Vector3(0, 0, -1);
	self.ConfirmEffect.transform.localScale=Vector3(75, 75, 1);
	self.ConfirmEffect:SetActive(false)
	self.script={}

	self.script[#self.script+1]=self.Effect:AddComponent(typeof(ChangeMaterialValue))
	---------------------
	


	self.PersonInfoPanel=transform:Find('PersonInfoPanel')
	self.PersonInfoPanel.gameObject:SetActive(true)
	--人物信息按钮
	self.InformationButton = transform:Find('InformationButton'):GetComponent(typeof(UnityEngine.UI.Button))  
	
	--人物信息图片
	self.InformationButtonImage = transform:Find('InformationButton'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InformationButtonText = transform:Find('InformationButton/TexGerenxinxi'):GetComponent(typeof(UnityEngine.UI.Text))
	self.InformationButtonOutline = transform:Find('InformationButton/TexGerenxinxi'):GetComponent(typeof(UnityEngine.UI.Outline))
	self.InformationButtonText.color= UnityEngine.Color(1,1,1,1)
	self.InformationButton.enabled=false
	self.InformationButtonImage.color= UnityEngine.Color(1,1,1,1)


	self.CodePanel=transform:Find('CodePanel')
	self.CodePanel.gameObject:SetActive(false)
	--兑换礼包按钮
	self.GiftButton = transform:Find('GiftButton'):GetComponent(typeof(UnityEngine.UI.Button))  
	self.GiftButtonText = transform:Find('GiftButton/TexDuihuan'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GiftButtonOutline = transform:Find('GiftButton/TexDuihuan'):GetComponent(typeof(UnityEngine.UI.Outline))
	self.GiftButtonText.color= UnityEngine.Color(0,0,0,1) 
	self.GiftButtonOutline.enabled=false
	self.GiftButton.enabled=true
	--兑换礼包图片
	self.GiftButtonImage = transform:Find('GiftButton'):GetComponent(typeof(UnityEngine.UI.Image))  
	self.GiftButtonImage.color=UnityEngine.Color(0.5,0.5,0.5,1)

	self.SettingPanel=transform:Find('SettingPanel')
	--设置按钮
	self.ConfigButton = transform:Find('ConfigButton'):GetComponent(typeof(UnityEngine.UI.Button)) 
	self.ConfigButtonText = transform:Find('ConfigButton/TexShezhi'):GetComponent(typeof(UnityEngine.UI.Text))  
	self.ConfigButtonOutline = transform:Find('ConfigButton/TexShezhi'):GetComponent(typeof(UnityEngine.UI.Outline))
	self.ConfigButtonOutline.enabled=false
	self.ConfigButtonText.color= UnityEngine.Color(0,0,0,1) 
	self.ConfigButton.enabled=true
	--设置图片
	self.ConfigButtonImage = transform:Find('ConfigButton'):GetComponent(typeof(UnityEngine.UI.Image)) 
	self.ConfigButtonImage.color=UnityEngine.Color(0.5,0.5,0.5,1)

	self.SettingPanel.gameObject:SetActive(false)

	----即将开放功能
	self.willOpens={}
	self.willOpens[1]={}
	self.willOpens[1].willLevelObj=transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen')
	self.willOpens[1].willName = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen/Text'):GetComponent(typeof(UnityEngine.UI.Text)) 
	self.willOpens[1].willLevel = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text)) 



	self.willOpens[2]={}
	self.willOpens[2].willLevelObj=transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (1)')
	self.willOpens[2].willName = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (1)/Text'):GetComponent(typeof(UnityEngine.UI.Text)) 
	self.willOpens[2].willLevel = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (1)/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text)) 


	self.willOpens[3]={}
	self.willOpens[3].willLevelObj=transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (2)')
	self.willOpens[3].willName = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (2)/Text'):GetComponent(typeof(UnityEngine.UI.Text)) 
	self.willOpens[3].willLevel = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (2)/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text)) 

	self.willOpens[4]={}
	self.willOpens[4].willLevelObj=transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (3)')
	self.willOpens[4].willName = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (3)/Text'):GetComponent(typeof(UnityEngine.UI.Text)) 
	self.willOpens[4].willLevel = transform:Find('PersonInfoPanel/InformationMask/Information/Scroll View/Viewport/Content/OpenInformationLayout/WillOpen (3)/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text)) 

	for i=1,#self.willOpens do
		self.willOpens[i].willLevelObj.gameObject:SetActive(false)
		self.willOpens[i].willName.text=""
		self.willOpens[i].willLevel.text=""

	end




---------兑换码--------------
	self.GetGiftButton= transform:Find('CodePanel/CodeGift/GetGiftButton'):GetComponent(typeof(UnityEngine.UI.Button))  
	self.InputField= transform:Find('CodePanel/CodeGift/InputField'):GetComponent(typeof(UnityEngine.UI.InputField)) 
	self.errorText = transform:Find('CodePanel/CodeGift/Noticeerror'):GetComponent(typeof(UnityEngine.UI.Text))
	self.errorText.enabled=false 
--------兑换码End---------------
	
---------Setting--------------

	---音乐设置
	self.MusicSwitchButton= transform:Find('SettingPanel/Config/MusicSwitchButton'):GetComponent(typeof(UnityEngine.UI.Button))  
	self.MusicSwitchButtonImage= transform:Find('SettingPanel/Config/MusicSwitchButton'):GetComponent(typeof(UnityEngine.UI.Image)) 
	--图标
	self.MusicSwitchButtonOnImage= transform:Find('SettingPanel/Config/MusicSwitchButton/On/Icon'):GetComponent(typeof(UnityEngine.UI.Image)) 
	self.MusicSwitchButtonOffImage= transform:Find('SettingPanel/Config/MusicSwitchButton/Off/Icon'):GetComponent(typeof(UnityEngine.UI.Image)) 


	--音效设置
	self.SESwitchButton= transform:Find('SettingPanel/Config/SESwitchButton'):GetComponent(typeof(UnityEngine.UI.Button))  
	self.SESwitchButtonImage= transform:Find('SettingPanel/Config/SESwitchButton'):GetComponent(typeof(UnityEngine.UI.Image))  

	self.SESwitchButtonOnImage= transform:Find('SettingPanel/Config/SESwitchButton/On/Icon'):GetComponent(typeof(UnityEngine.UI.Image)) 
	self.SESwitchButtonOffImage= transform:Find('SettingPanel/Config/SESwitchButton/Off/Icon'):GetComponent(typeof(UnityEngine.UI.Image)) 
	

    --特效设置
	self.EffectSwitchButton= transform:Find('SettingPanel/Config/EffectSwitchButton'):GetComponent(typeof(UnityEngine.UI.Button))  
	self.EffectSwitchButtonImage= transform:Find('SettingPanel/Config/EffectSwitchButton'):GetComponent(typeof(UnityEngine.UI.Image))  

	self.EffectSwitchButtonOnImage= transform:Find('SettingPanel/Config/EffectSwitchButton/On/Icon'):GetComponent(typeof(UnityEngine.UI.Image)) 
	self.EffectSwitchButtonOffImage= transform:Find('SettingPanel/Config/EffectSwitchButton/Off/Icon'):GetComponent(typeof(UnityEngine.UI.Image)) 
--------Setting  End---------------

	self:InitCurrentOwnCardInfo()
	self:InitCurrentNotGetCardInfo()
	--人物信息面板End
	self:InitSettingPanel()

	

end

---1表示开，0表示关闭
function PersonalInformationCls:InitSettingPanel()
	
	print(KBackgroundMusicSetting,type(KBackgroundMusicSetting))
	print(UnityEngine.PlayerPrefs.GetInt(KBackgroundMusicSetting,1),UnityEngine.PlayerPrefs.GetInt(KEffectSoundSetting,1))
	self.musicSetting =  UnityEngine.PlayerPrefs.GetInt(KBackgroundMusicSetting,1)
	if self.musicSetting ==1 then
		self.MusicSwitchButtonImage.material=utility.GetCommonMaterial()
		self.MusicSwitchButtonOnImage.enabled=false
		self.MusicSwitchButtonOffImage.enabled=true
	else
		self.MusicSwitchButtonImage.material=utility.GetGrayMaterial()
		self.MusicSwitchButtonOnImage.enabled=true
		self.MusicSwitchButtonOffImage.enabled=false
	end
	--音效
	self.effectSoundSetting =  UnityEngine.PlayerPrefs.GetInt(KEffectSoundSetting,1)
	
	if self.effectSoundSetting ==1 then
		self.SESwitchButtonImage.material=utility.GetCommonMaterial()
		self.SESwitchButtonOnImage.enabled=false
		self.SESwitchButtonOffImage.enabled=true

	else
		
		self.SESwitchButtonImage.material=utility.GetGrayMaterial()
		self.SESwitchButtonOnImage.enabled=true
		self.SESwitchButtonOffImage.enabled=false
	end

		--特效
	self.effectSetting =  UnityEngine.PlayerPrefs.GetInt(KEffectSetting,1)
	
	if self.effectSetting ==1 then
		self.EffectSwitchButtonImage.material=utility.GetCommonMaterial()
		self.EffectSwitchButtonOnImage.enabled=false
		self.EffectSwitchButtonOffImage.enabled=true

	else
		
		self.EffectSwitchButtonImage.material=utility.GetGrayMaterial()
		self.EffectSwitchButtonOnImage.enabled=true
		self.EffectSwitchButtonOffImage.enabled=false
	end
end


function PersonalInformationCls:RegisterControlEvents()
	-- 注册 PersonalInformationRetrunButton 的事件
	self.__event_button_onPersonalInformationRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPersonalInformationRetrunButtonClicked, self)
	self.PersonalInformationRetrunButton.onClick:AddListener(self.__event_button_onPersonalInformationRetrunButtonClicked__)


	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnHeadCrossButtonButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 ChangeHeadButton 的事件
	self.__event_button_onChangeHeadButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChangeHeadButtonClicked, self)
	self.ChangeHeadButton.onClick:AddListener(self.__event_button_onChangeHeadButtonClicked__)

	-- 注册 ConfirmChangeHeadButton 的事件
	self.__event_button_onConfirmChangeHeadButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfirmChangeHeadButtonClicked, self)
	self.ConfirmChangeHeadButton.onClick:AddListener(self.__event_button_onConfirmChangeHeadButtonClicked__)

	-- 注册 PersonalInformationModifyButton 的事件
	self.__event_button_onPersonalInformationModifyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPersonalInformationModifyButtonClicked, self)
	self.PersonalInformationModifyButton.onClick:AddListener(self.__event_button_onPersonalInformationModifyButtonClicked__)

	-- 注册 InformationButton 的事件
	self.__event_button_onInformationButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInformationButtonClicked, self)
	self.InformationButton.onClick:AddListener(self.__event_button_onInformationButtonClicked__)

     -- 注册 GiftButton 的事件
	self.__event_button_onGiftButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGiftButtonClicked, self)
	self.GiftButton.onClick:AddListener(self.__event_button_onGiftButtonClicked__)

     -- 注册 ConfigButton 的事件
	self.__event_button_onConfigButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfigButtonClicked, self)
	self.ConfigButton.onClick:AddListener(self.__event_button_onConfigButtonClicked__)

	     -- 注册 GetGiftButton 的事件
	self.__event_button_onGetGiftButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGetGiftButtonClicked, self)
	self.GetGiftButton.onClick:AddListener(self.__event_button_onGetGiftButtonClicked__)




	-- 注册 MusicSwitchButton 的事件
	self.__event_button_onEffectSwitchButtonClicked__ = UnityEngine.Events.UnityAction(self.OnEffectSwitchButtonClicked, self)
	self.EffectSwitchButton.onClick:AddListener(self.__event_button_onEffectSwitchButtonClicked__)

   -- 注册 MusicSwitchButton 的事件
	self.__event_button_onMusicSwitchButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMusicSwitchButtonClicked, self)
	self.MusicSwitchButton.onClick:AddListener(self.__event_button_onMusicSwitchButtonClicked__)

	     -- 注册 SESwitchButton 的事件
	self.__event_button_onSESwitchButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSESwitchButtonClicked, self)
	self.SESwitchButton.onClick:AddListener(self.__event_button_onSESwitchButtonClicked__)

	     -- 注册 BlackListButton 的事件
	self.__event_button_onBlackListButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBlackListButtonClicked, self)
	self.BlackListButton.onClick:AddListener(self.__event_button_onBlackListButtonClicked__)

	self.__event_button_onChangeCountButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChangeCountButtonClicked, self)
	self.ChangeCountButton.onClick:AddListener(self.__event_button_onChangeCountButtonClicked__)



-- 注册 ConfirmChangeHeadButton 的事件
	self.__event_button_onHeadCrossButtonButtonClicked__ = UnityEngine.Events.UnityAction(self.OnHeadCrossButtonButtonClicked, self)
	self.HeadCrossButtonButton.onClick:AddListener(self.__event_button_onHeadCrossButtonButtonClicked__)

		-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnHeadCrossButtonButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)


	-- 	-- 取消注册 self.HeadCrossButtonButton 的事件
	-- if self.__event_button_onHeadCrossButtonButtonClicked__ then
	-- 	self.HeadCrossButtonButton.onClick:RemoveListener(self.__event_button_onHeadCrossButtonButtonClicked__)
	-- 	self.__event_button_onHeadCrossButtonButtonClicked__ = nil
	-- end

end

function PersonalInformationCls:UnregisterControlEvents()
	-- 取消注册 PersonalInformationRetrunButton 的事件
	if self.__event_button_onPersonalInformationRetrunButtonClicked__ then
		self.PersonalInformationRetrunButton.onClick:RemoveListener(self.__event_button_onPersonalInformationRetrunButtonClicked__)
		self.__event_button_onPersonalInformationRetrunButtonClicked__ = nil
	end

	-- 取消注册 ChangeHeadButton 的事件
	if self.__event_button_onConfirmChangeHeadButtonClicked__ then
		self.ConfirmChangeHeadButton.onClick:RemoveListener(self.__event_button_onConfirmChangeHeadButtonClicked__)
		self.__event_button_onConfirmChangeHeadButtonClicked__ = nil
	end
		-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end


	-- 取消注册 ChangeHeadButton 的事件
	if self.__event_button_onChangeHeadButtonClicked__ then
		self.ChangeHeadButton.onClick:RemoveListener(self.__event_button_onChangeHeadButtonClicked__)
		self.__event_button_onChangeHeadButtonClicked__ = nil
	end

	-- 取消注册 self.HeadCrossButtonButton 的事件
	if self.__event_button_onHeadCrossButtonButtonClicked__ then
		self.HeadCrossButtonButton.onClick:RemoveListener(self.__event_button_onHeadCrossButtonButtonClicked__)
		self.__event_button_onHeadCrossButtonButtonClicked__ = nil
	end

	-- 取消注册 PersonalInformationModifyButton 的事件
	if self.__event_button_onPersonalInformationModifyButtonClicked__ then
		self.PersonalInformationModifyButton.onClick:RemoveListener(self.__event_button_onPersonalInformationModifyButtonClicked__)
		self.__event_button_onPersonalInformationModifyButtonClicked__ = nil
	end


		-- 取消注册 InformationButton 的事件
	if self.__event_button_onInformationButtonClicked__ then
		self.InformationButton.onClick:RemoveListener(self.__event_button_onInformationButtonClicked__)
		self.__event_button_onInformationButtonClicked__ = nil
	end
		-- 取消注册 GiftButton 的事件
	if self.__event_button_onGiftButtonClicked__ then
		self.GiftButton.onClick:RemoveListener(self.__event_button_onGiftButtonClicked__)
		self.__event_button_onGiftButtonClicked__ = nil
	end
		-- 取消注册 PersonalInformationModifyButton 的事件
	if self.__event_button_onConfigButtonClicked__ then
		self.ConfigButton.onClick:RemoveListener(self.__event_button_onConfigButtonClicked__)
		self.__event_button_onConfigButtonClicked__ = nil
	end

		-- 取消注册 GetGiftButton 的事件
	if self.__event_button_onGetGiftButtonClicked__ then
		self.GetGiftButton.onClick:RemoveListener(self.__event_button_onGetGiftButtonClicked__)
		self.__event_button_onGetGiftButtonClicked__ = nil
	end



		-- 取消注册 MusicSwitchButton 的事件
	if self.__event_button_onMusicSwitchButtonClicked__ then
		self.MusicSwitchButton.onClick:RemoveListener(self.__event_button_onMusicSwitchButtonClicked__)
		self.__event_button_onMusicSwitchButtonClicked__ = nil
	end

		-- 取消注册 SESwitchButton 的事件
	if self.__event_button_onSESwitchButtonClicked__ then
		self.SESwitchButton.onClick:RemoveListener(self.__event_button_onSESwitchButtonClicked__)
		self.__event_button_onSESwitchButtonClicked__ = nil
	end
		-- 取消注册 BlackListButton 的事件
	if self.__event_button_onBlackListButtonClicked__ then
		self.BlackListButton.onClick:RemoveListener(self.__event_button_onBlackListButtonClicked__)
		self.__event_button_onBlackListButtonClicked__ = nil
	end

	if self.__event_button_onChangeCountButtonClicked__ then
		self.ChangeCountButton.onClick:RemoveListener(self.__event_button_onChangeCountButtonClicked__)
		self.__event_button_onChangeCountButtonClicked__ = nil
	end


		-- 取消注册 EffectSwitchButton 的事件
	if self.__event_button_onEffectSwitchButtonClicked__ then
		self.EffectSwitchButton.onClick:RemoveListener(self.__event_button_onEffectSwitchButtonClicked__)
		self.__event_button_onEffectSwitchButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end


end

function PersonalInformationCls:Update()
	self:CountTimedown()

end
function PersonalInformationCls:CountTimedown()
    if self.timeDownFlag then
        if self.countTimeDown<0 then
            self.timeDownFlag=false
            self.recoverAllTrans.gameObject:SetActive(false)
        else
            if os.time() - self.lastTimeDown >= 1 then
                self.lastTimeDown=os.time()
                self.countTimeDown=self.countTimeDown-1
            else

            end
            self.recoverAllTime.text=utility.ConvertTime(self.countTimeDown)
        end
    end
end


function PersonalInformationCls:TiliCountDownResult(msg)

    debug_print(msg.fullTime,"回复man体力需要时间",TiliCountDown)
    local timer = tonumber(msg.fullTime)
    debug_print(timer)
    if timer>0 then

        self.timeDownFlag=true
        self.lastTimeDown=0
        self.countTimeDown=timer
        self.recoverAllTrans.gameObject:SetActive(true)

    else
         self.timeDownFlag=false
        self.recoverAllTrans.gameObject:SetActive(false)

    end

end

function PersonalInformationCls:RegisterNetworkEvents()
	 self.game:RegisterMsgHandler(net.S2CTiliCountDownResult,self,self.TiliCountDownResult)
	self.game:RegisterMsgHandler(net.S2CChangePlayerNameResult, self, self.ChangePlayerNameResult)
	self.game:RegisterMsgHandler(net.S2CChooseHeadImageResult, self, self.PlayerHeadImage)
	self.game:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
		self.game:RegisterMsgHandler(net.S2CExchangeCodeResult, self, self.ExchangeCodeResult)
end

function PersonalInformationCls:UnregisterNetworkEvents()
	self.game:UnRegisterMsgHandler(net.S2CChangePlayerNameResult, self, self.ChangePlayerNameResult)
	self.game:UnRegisterMsgHandler(net.S2CChooseHeadImageResult, self, self.PlayerHeadImage)
	 self.game:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	 self.game:UnRegisterMsgHandler(net.S2CExchangeCodeResult, self, self.ExchangeCodeResult)
	 self.game:UnRegisterMsgHandler(net.S2CTiliCountDownResult,self,self.TiliCountDownResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function PersonalInformationCls:OnPersonalInformationRetrunButtonClicked()
	--self:UnregisterControlEvents()
	self:Close()
end
local function DelayHide(self)

	
	coroutine.wait(1)
	 self.ConfirmEffect:SetActive(false)
end
function PersonalInformationCls:OnConfirmChangeHeadButtonClicked()

	hzj_print("OnConfirmChangeHeadButtonClicked")
	if self.HeroPromptText.gameObject.activeInHierarchy == true then
		self.HeroPromptText.gameObject:SetActive(false)
	 	self.InformationMask.gameObject:SetActive(true)
	 	self.ConfirmChangeHeadButton.gameObject:SetActive(false)
	 	self.ChangeHeadButton.gameObject:SetActive(true)
	 	hzj_print(self.currentCardID)
		 self.ConfirmEffect:SetActive(true)
		 self.Effect.gameObject:SetActive(false)
		 -- coroutine.start(DelayHide,self)
		 self:StartCoroutine(DelayHide)
	 --	self.ScrollView.content=self.InformationMask
	 	if self.currentCardID then
	 		self.game:SendNetworkMessage(require "Network.ServerService".PlayerHeadRequest(0,self.currentCardID))
	 	end
	 end
end

function PersonalInformationCls:OnHeadCrossButtonButtonClicked()

	print("OnConfirmChangeHeadButtonClicked")
	if self.HeroPromptText.gameObject.activeInHierarchy == true then
		self.HeroPromptText.gameObject:SetActive(false)
	 	self.InformationMask.gameObject:SetActive(true)
	 	self.ConfirmChangeHeadButton.gameObject:SetActive(false)
	 	self.ChangeHeadButton.gameObject:SetActive(true)
	 	print(self.currentCardID)
		--  self.ConfirmEffect:SetActive(true)
		--  self.Effect.gameObject:SetActive(false)
		--  coroutine.start(DelayHide,self)
	 -- --	self.ScrollView.content=self.InformationMask
	 -- 	if self.currentCardID then
	 -- 		self.game:SendNetworkMessage(require "Network.ServerService".PlayerHeadRequest(0,self.currentCardID))
	 -- 	end
	 end
end


function PersonalInformationCls:OnChangeHeadButtonClicked()
	-- -- 更换头像Button控件的点击事件处理
	 if self.HeroPromptText.gameObject.activeInHierarchy == false then
	 	self.HeroPromptText.gameObject:SetActive(true)
	 	self.InformationMask.gameObject:SetActive(false)
	 	self.ConfirmChangeHeadButton.gameObject:SetActive(true)
	 	self.ChangeHeadButton.gameObject:SetActive(false)
	-- 	self.ScrollView.content=self.HeroPromptText
	
	 end
	
--	print("把系统设置入口临时坐在这以后改")
--	local windowManager = self.game:GetWindowManager()
--  windowManager:Show(require "GUI.SystemSettings")
end

--刷新当前的头像 
function PersonalInformationCls:RefreshHeadCard()
	
	local UserDataType = require "Framework.UserDataType"
	local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	local count = cardBagData:Count()
	print(count)
	for i=1,count do
		local currentTempCard = cardBagData:GetRoleByPos(i)
		--print(cardBagData:GetRoleByPos(i))
		--判断上次调用的时候是否拥有
		local id = currentTempCard:GetId()
	--	print(id,self.heroHeadCard[id] )
		if not self.heroHeadCard[id] then
			print("RefreshHeadCard")
			self.heroHeadCard[id] = true
			self.allHeroHeadCard[id]:RefreshHeadCard(self.Head)
			end	
	end


end






function PersonalInformationCls:OnPersonalInformationModifyButtonClicked()
	--更换名字Button控件的点击事件处理
    local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.ModifyName")
end


function PersonalInformationCls:OnInformationButtonClicked()

	self.InformationButton.enabled=false
	self.InformationButtonImage.color=UnityEngine.Color(1,1,1,1)
	self.InformationButton.gameObject.transform.localScale=Vector3(1.1,1.1,1.1)


	self.ConfigButton.enabled=true
	self.ConfigButtonImage.color=UnityEngine.Color(0.5,0.5,0.5,1)
	self.ConfigButton.gameObject.transform.localScale=Vector3(1,1,1)

	self.GiftButton.enabled=true
	self.GiftButton.gameObject.transform.localScale=Vector3(1,1,1)
	self.GiftButtonImage.color=UnityEngine.Color(0.5,0.5,0.5,1)

	self.PersonInfoPanel.gameObject:SetActive(true)
	self.CodePanel.gameObject:SetActive(false)
	self.SettingPanel.gameObject:SetActive(false)


	self.InformationButtonOutline.enabled=true
	self.InformationButtonText.color= UnityEngine.Color(1,1,1,1) 
	self.GiftButtonOutline.enabled=false
	self.GiftButtonText.color= UnityEngine.Color(0,0,0,1) 
	self.ConfigButtonOutline.enabled=false
	self.ConfigButtonText.color= UnityEngine.Color(0,0,0,1) 

	
	self.ConfigButton.transform:SetAsFirstSibling()
	self.GiftButton.transform:SetAsFirstSibling()
	self.InformationButton.transform:SetAsLastSibling()
	self.TranslucentLayer.transform:SetAsFirstSibling()

end


function PersonalInformationCls:OnConfigButtonClicked()
	
	self.InformationButton.enabled=true
	self.InformationButton.gameObject.transform.localScale=Vector3(1,1,1)
	self.InformationButtonImage.color=UnityEngine.Color(0.5,0.5,0.5,1)

	self.ConfigButton.enabled=false
	self.ConfigButton.gameObject.transform.localScale=Vector3(1.1,1.1,1.1)			
	self.ConfigButtonImage.color=UnityEngine.Color(1,1,1,1)

	self.GiftButton.enabled=true
	self.GiftButton.gameObject.transform.localScale=Vector3(1,1,1)
	self.GiftButtonImage.color=UnityEngine.Color(0.5,0.5,0.5,1)

	self.PersonInfoPanel.gameObject:SetActive(false)
	self.CodePanel.gameObject:SetActive(false)
	self.SettingPanel.gameObject:SetActive(true)


	self.InformationButtonOutline.enabled=false
	self.InformationButtonText.color= UnityEngine.Color(0,0,0,1) 
	self.GiftButtonOutline.enabled=false
	self.GiftButtonText.color= UnityEngine.Color(0,0,0,1) 
	self.ConfigButtonOutline.enabled=true
	self.ConfigButtonText.color= UnityEngine.Color(1,1,1,1)
	self.InformationButton.transform:SetAsFirstSibling()
	self.ConfigButton.transform:SetAsLastSibling()
	self.GiftButton.transform:SetAsLastSibling()

	
	self.InformationButton.transform:SetAsFirstSibling()
	self.ConfigButton.transform:SetAsLastSibling()
	self.GiftButton.transform:SetAsFirstSibling()
	self.TranslucentLayer.transform:SetAsFirstSibling()

end


function PersonalInformationCls:OnGiftButtonClicked()

	self.InformationButton.enabled=true
	self.InformationButton.gameObject.transform.localScale=Vector3(1,1,1)
	self.InformationButtonImage.color=UnityEngine.Color(0.5,0.5,0.5,1)

	self.ConfigButton.enabled=true
	self.ConfigButton.gameObject.transform.localScale=Vector3(1,1,1)
	self.ConfigButtonImage.color=UnityEngine.Color(0.5,0.5,0.5,1)

	self.GiftButton.enabled=false
	self.GiftButton.gameObject.transform.localScale=Vector3(1.1,1.1,1.1)
	self.GiftButtonImage.color=UnityEngine.Color(1,1,1,1)

	self.PersonInfoPanel.gameObject:SetActive(false)
	self.CodePanel.gameObject:SetActive(true)
	self.SettingPanel.gameObject:SetActive(false)

	self.InformationButtonOutline.enabled=false
	self.InformationButtonText.color= UnityEngine.Color(0,0,0,1) 
	self.GiftButtonOutline.enabled=true
	self.GiftButtonText.color= UnityEngine.Color(1,1,1,1) 
	self.ConfigButtonOutline.enabled=false
	self.ConfigButtonText.color= UnityEngine.Color(0,0,0,1) 

	
	self.InformationButton.transform:SetAsFirstSibling()
	self.ConfigButton.transform:SetAsFirstSibling()
	self.GiftButton.transform:SetAsLastSibling()
	self.TranslucentLayer.transform:SetAsFirstSibling()

	
end
--兑换按钮
function PersonalInformationCls:OnGetGiftButtonClicked()
	print("点击兑换按钮")
	self.game:SendNetworkMessage(require "Network.ServerService".Code(self.InputField.text))
end


function PersonalInformationCls:ExchangeCodeResult(msg)
	print("兑换事件返回")
	if msg.ret==0 then
		local windowManager = utility:GetGame():GetWindowManager()
	 --   	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		-- windowManager:Show(ConfirmDialogClass, "礼包已放入背包！")
		-- for i=1,#msg.items do
		-- 	print(msg.items[i].itemID,msg.items[i].itemNum,msg.items[i].itemNum)
		-- end


	local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Tower.TowerSweepAward",msg.items,4)
		--print(#msg.items)
	else
		self.errorText.enabled=true
	end
end
--开关音乐
function PersonalInformationCls:OnMusicSwitchButtonClicked()
	if self.musicSetting ==1 then
		self.musicSetting=0
		self.MusicSwitchButtonImage.material=utility.GetGrayMaterial()
		self.MusicSwitchButtonOnImage.enabled=true
		self.MusicSwitchButtonOffImage.enabled=false
	else
		self.musicSetting=1
		self.MusicSwitchButtonImage.material=nil
		self.MusicSwitchButtonOnImage.enabled=false
		self.MusicSwitchButtonOffImage.enabled=true
	end

	utility.SetMusicEnabled(self.musicSetting == 1 and true or false)
end

--开关特效
function PersonalInformationCls:OnEffectSwitchButtonClicked()
	self.effectSetting = UnityEngine.PlayerPrefs.GetInt(KEffectSetting,1)

	if self.effectSetting ==1 then
		self.effectSetting=0
		self.EffectSwitchButtonImage.material=utility.GetGrayMaterial()
		self.EffectSwitchButtonOnImage.enabled=true
		self.EffectSwitchButtonOffImage.enabled=false
	else
		self.effectSetting=1
		self.EffectSwitchButtonImage.material=nil
		self.EffectSwitchButtonOnImage.enabled=false
		self.EffectSwitchButtonOffImage.enabled=true
	end

	utility.SetCameraPathEffectEnabled(self.effectSetting == 1 and true or false)
end

--开关音效
function PersonalInformationCls:OnSESwitchButtonClicked()
	--音效
	if self.effectSoundSetting ==1 then
		self.effectSoundSetting=0		
		self.SESwitchButtonImage.material=utility.GetGrayMaterial()
		self.SESwitchButtonOnImage.enabled=true
		self.SESwitchButtonOffImage.enabled=false
	else
		self.effectSoundSetting=1
		self.SESwitchButtonImage.material=utility.GetCommonMaterial()
		self.SESwitchButtonOnImage.enabled=false
		self.SESwitchButtonOffImage.enabled=true
	end
	
	utility.SetSoundEnabled(self.effectSoundSetting == 1 and true or false)
end

function PersonalInformationCls:ChangePlayerNameResult(msg)
	self.game:SendNetworkMessage(require "Network.ServerService".LoadPlayer())
end

function PersonalInformationCls:UpdatePlayerData(msg)
	self:InitView()
end

function PersonalInformationCls:OnChangeCountButtonClicked()
	self.ChangeCountButton.enabled=false
	self.game.gameServer:Logout()
end

function PersonalInformationCls:OnBlackListButtonClicked(msg)
	
	local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_ChatID):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end


local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.SystemSettingsBlacklist")

end

function PersonalInformationCls:PlayerHeadImage(msg)
end
return PersonalInformationCls
