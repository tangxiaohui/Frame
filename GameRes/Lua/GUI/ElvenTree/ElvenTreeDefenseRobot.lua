local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeDefenseRobotCls = Class(BaseNodeClass)

function ElvenTreeDefenseRobotCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeDefenseRobotCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTreeDefenseRobot', function(go)
		self:BindComponent(go)
	end)
end

function ElvenTreeDefenseRobotCls:OnWillShow(info)
	self.info=info
	end

function ElvenTreeDefenseRobotCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ElvenTreeDefenseRobotCls:OnResume()
	-- 界面显示时调用
	ElvenTreeDefenseRobotCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function ElvenTreeDefenseRobotCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeDefenseRobotCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function ElvenTreeDefenseRobotCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeDefenseRobotCls.base.OnEnter(self)
end

function ElvenTreeDefenseRobotCls:OnExit()
	-- Node Exit时调用
	ElvenTreeDefenseRobotCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeDefenseRobotCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()


	--self.Title = transform:Find('SmallWindowBase/Title'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemIconTrans = transform:Find('CharacterBox/base')
	
	self.ItemIcon = transform:Find('CharacterBox/CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.ElvenTreeDescriptionLvLabel = transform:Find('MyGeneralItem/Base/Lv1/CardBasisHeroListLvLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ElvenTreeDescriptionLabel = transform:Find('CharacterBox/CharacterNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ElvenTreeDescriptionButton__1_ = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.RarityImage = transform:Find("CharacterBox/Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
	self.star={}
	self.star[1]=transform:Find('CharacterBox/CharacterRank/RankStarIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.star[2]=transform:Find('CharacterBox/CharacterRank/RankStarIcon (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.star[3]=transform:Find('CharacterBox/CharacterRank/RankStarIcon (2)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.star[4]=transform:Find('CharacterBox/CharacterRank/RankStarIcon (3)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.star[5]=transform:Find('CharacterBox/CharacterRank/RankStarIcon (4)'):GetComponent(typeof(UnityEngine.UI.Image))
	for i=1,#self.star do
		self.star[i].enabled=false
	end
	local AtlasesLoader = require "Utils.AtlasesLoader"

    local GameTools = require "Utils.GameTools"
    local _,_,itemName,iconPath = GameTools.GetItemDataById(self.info.cardID)
        -- 设置图标
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

    -- 设置颜色
    local PropUtility = require "Utils.PropUtility"
    print(self.info.cardColor,self.info.cardPos,self.info.cardID)

    PropUtility.AutoSetRGBColor(self.ItemIconTrans, self.info.cardColor)

    local roleData = require "StaticData.Role":GetData(self.info.cardID)
	local rarity = roleData:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
 	-- local star = roleData:GetStar()
 	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
 	-- for i=1,star do
		-- self.star[i].enabled=true	
 	-- end


   -- self.ElvenTreeDescriptionLvLabel.text=self.info.cardLevel
	self.ElvenTreeDescriptionLabel.text=itemName
	

end


function ElvenTreeDefenseRobotCls:RegisterControlEvents()
	-- 注册 ElvenTreeDescriptionButton__1_ 的事件
	self.__event_button_onElvenTreeDescriptionButton__1_Clicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButton__1_Clicked, self)
	self.ElvenTreeDescriptionButton__1_.onClick:AddListener(self.__event_button_onElvenTreeDescriptionButton__1_Clicked__)

		-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButton__1_Clicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function ElvenTreeDefenseRobotCls:UnregisterControlEvents()
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
function ElvenTreeDefenseRobotCls:OnElvenTreeDescriptionButton__1_Clicked()
	--ElvenTreeDescriptionButton__1_控件的点击事件处理
	--self.game:SendNetworkMessage( require"Network/ServerService".PutCardOnLineup(self.info.cardID,kLineup_ElvenTree,5,-10))
	self:Hide()
end


return  ElvenTreeDefenseRobotCls
