local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local skinInfoCls = require "GUI.SkinSystem.SkinInfoCls"
require "LUT.StringTable"
local SkinCardItem = Class(BaseNodeClass)

require "System.LuaDelegate"
function SkinCardItem:Ctor(parent,id,data)
	-- self.parentTran=parentTran
	-- self.width=width
	-- self.height=height
	self.id = id
	self.data = data
	self.parent=parent
	-- self.callback = LuaDelegate.New()
	-- self.didCallback = LuaDelegate.New()
	--print(#self.chapterData.BossPortrait)

end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SkinCardItem:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NewCardSkin', function(go)
		self:BindComponent(go,false)
	end)
end

function SkinCardItem:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function SkinCardItem:OnResume()
	-- 界面显示时调用
	SkinCardItem.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitViews()
	self:SetItem(self.id)
end

function SkinCardItem:OnPause()
	-- 界面隐藏时调用
	SkinCardItem.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SkinCardItem:OnEnter()
	-- Node Enter时调用
	SkinCardItem.base.OnEnter(self)
end

function SkinCardItem:OnExit()
	-- Node Exit时调用
	SkinCardItem.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SkinCardItem:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = self:GetUnityTransform()
	transform.localScale = Vector3(0.65, 0.65, 1)
	local base = transform:Find("Base/Info")
	self.base = base
	self.baseImage = transform:Find("Base/SkinIllust"):GetComponent(typeof(UnityEngine.UI.Image))
	self.nameLabel = base:Find("name/NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.racial = base:Find("Icon/Racial"):GetComponent(typeof(UnityEngine.UI.Image))
	--立绘
	self.icon = base:Find("Icon/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.lvLabel = base:Find("LV/LvLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--羁绊等级
	self.kizunaLabel = base:Find("Kizuna/KizunaLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.infoLabel = base:Find("Notice/NoticeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.rarity = base:Find("Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
end

function SkinCardItem:SetItem(id)
	if id ~= nil then
		self.base.gameObject:SetActive(true)
		self.baseImage.color = UnityEngine.Color(1, 1, 1, 1)
		if id ~= 0 then
			local data = require "StaticData.CardSkin.Skin":GetData(id)
			local roleInfoData = require "StaticData.RoleInfo":GetData(data:GetRoleid())
			self.nameLabel.text = roleInfoData:GetCardName()
			local roleData = require "StaticData.Role":GetData(data:GetRoleid())
			utility.LoadRaceIcon(roleData:GetRace(),self.racial)
			local iconPath = data:GetSkinIllust()
			utility.LoadAtlasesSpriteByFullName(iconPath,self.icon)
			self.infoLabel.text = data:GetDescription()
			utility.LoadSpriteFromPath(data:GetRarity(data:GetColor()),self.rarity)
			self:ResetInfo(id,self.data)
		end
	else
		self.base.gameObject:SetActive(false)
		self.baseImage.color = UnityEngine.Color(1, 1, 1, 0)
	end
end
function SkinCardItem:ResetData(id,data)
	self.id = id
	self.data = data
	self:SetItem(id)
end
function SkinCardItem:ResetInfo(id,data)
	local cardSkinData
	if #data ~= 0 then
		for i=1,#data do
			if id == data[i].cardSkinId then
				cardSkinData = data[i]
				break
			end
		end
	else
		cardSkinData = data
	end
	if cardSkinData == nil then
		self.icon.material = utility.GetGrayMaterial()
		cardSkinData = {}
		cardSkinData.cardSkinLevel = 0
		cardSkinData.currActPro = 0
	else
		self.icon.material = utility.GetCommonMaterial()
	end
	local index,_ = skinInfoCls:GetIndex(cardSkinData.currActPro)
	self.kizunaLabel.text = index
	self.lvLabel.text = cardSkinData.cardSkinLevel
end

function SkinCardItem:GetSkinId()
	return self.id
end

function SkinCardItem:SetCallback(table,func)
	--self.table=table
	 self.callback:Set(table,func)
end

function SkinCardItem:SetDidCallback(table,func)
	--self.table=table
	 self.didCallback:Set(table,func)
end


function SkinCardItem:RegisterControlEvents()
	-- 注册 SelectChallengdungeonStage 的事件
	-- self.__event_button_onSelectChallengdungeonStageClicked__ = UnityEngine.Events.UnityAction(self.OnSelectChallengdungeonStageClicked, self)
	-- self.SelectChallengdungeonStage.onClick:AddListener(self.__event_button_onSelectChallengdungeonStageClicked__)
end

function SkinCardItem:UnregisterControlEvents()
	-- -- 取消注册 SelectChallengdungeonStage 的事件
	-- if self.__event_button_onSelectChallengdungeonStageClicked__ then
	-- 	self.SelectChallengdungeonStage.onClick:RemoveListener(self.__event_button_onSelectChallengdungeonStageClicked__)
	-- 	self.__event_button_onSelectChallengdungeonStageClicked__ = nil
	-- end
end

function  SkinCardItem:InitViews()
	-- body
	 self.mTrans=self:GetUnityTransform()     
     self.mRTrans=self.mTrans:GetComponent(typeof(UnityEngine.RectTransform))    
     self.mRTrans.sizeDelta=Vector2(self.width,self.height)  
     self.mRTrans.pivot = Vector2(0.5, 0.5);--//设置panel的中心在左上角
     self.mRTrans.anchorMin =  Vector2(0, 1);
     self.mRTrans.anchorMax =  Vector2(0, 1);  
end

local function DelayOnBind(self,width,height)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.transform.localPosition = Vector2(width,height)
	---初始化好了进行回掉
	self.callback:Invoke()
	
end
function SkinCardItem:SetPosition(width,height)
	--coroutine.start(DelayOnBind,self,width,-height)
	self:StartCoroutine(DelayOnBind, width,-height)
end

function SkinCardItem:ResetMessage(num)
	-- print_debug("SkinCardItem",self:GetUnityTransform().name)
	skinInfoCls:SetSkinId(self.id)
end
--
function SkinCardItem:ResetPosition()
	
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SkinCardItem:OnSelectChallengdungeonStageClicked()
	--SelectChallengdungeonStage控件的点击事件处理
	-- if self.remainCount ~=nil then
	-- 	if self.remainCount<=0 then

	-- 	local windowManager = utility:GetGame():GetWindowManager()
	--    	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
	-- 	windowManager:Show(ConfirmDialogClass, "今日探索次数已经用完")

	-- 	else
	-- 		local UserDataType = require "Framework.UserDataType"
	-- 	    local userData = self:GetCachedData(UserDataType.PlayerData)
	-- 	  	print(self.chapterData.data:GetChapterLv())
	-- 	   -- self.controls.characterLevelLbl.text = userData:GetLevel()
	-- 	   if  userData:GetLevel()>=self.chapterData.data:GetChapterLv() then
	-- 			self.didCallback:Invoke(self.chapterData)
	-- 		else
	-- 			self.game:SendNetworkMessage(require "Network.ServerService".ExploreMapQueryRequest(self.chapterData.ChapterInfoID))
	-- 		end
	-- 	end
	-- else

	-- 	local windowManager = utility:GetGame():GetWindowManager()
	--    	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
	-- 	windowManager:Show(ConfirmDialogClass, "等级不够")
	-- end
	
end
-------------------------------------------------------------
------------------网络事件-----------------------------------
-------------------------------------------------------------

function SkinCardItem:RegisterNetworkEvents()
		-- self.game:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	-- self.game:RegisterMsgHandler(net.S2CExploreMapQueryResult, self, self.ExploreMapQueryResult)
end

function SkinCardItem:UnregisterNetworkEvents()
		--加载玩家信息
	
	  -- self.game:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	-- self.game:UnRegisterMsgHandler(net.S2CExploreMapQueryResult, self, self.ExploreMapQueryResult)
end

local content = 510
local x = 378/2
function SkinCardItem:SetItemSize(posX,width)
	local localPos = self.transform.localPosition.x - width*posX
	if content >= localPos - x and content <= localPos + x then
		self.transform.localScale = Vector3(0.8, 0.8, 1)
		skinInfoCls:SetSkinId(self.id)
	else
		self.transform.localScale = Vector3(0.65, 0.65, 1)
	end
	-- print_debug(self.transform.localPosition.x)
end

return SkinCardItem

