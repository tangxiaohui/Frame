local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ExploreItemCls = Class(BaseNodeClass)
require "System.LuaDelegate"
function ExploreItemCls:Ctor(parent,chapterData)
	self.chapterData=chapterData
	self.parent=parent

	self.didCallback = LuaDelegate.New()
end


function ExploreItemCls:SetDidCallback(table,func)
	--self.table=table
	 self.didCallback:Set(table,func)
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ExploreItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ChanllengeItem', function(go)
		self:BindComponent(go)
	end)
end

function ExploreItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function ExploreItemCls:OnResume()
	-- 界面显示时调用
	ExploreItemCls.base.OnResume(self)
	self:SetInfo()
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	
	
end

function ExploreItemCls:SetInfo()
	debug_print("self.chapterData.ChapterInfoID",self.chapterData.ChapterInfoID)
	--self:InitViews()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
 -- 	print(self.chapterData.data:GetChapterLv())
   -- self.controls.characterLevelLbl.text = userData:GetLevel()
   if  userData:GetLevel()>=self.chapterData.data:GetChapterLv() then
   		self.redDotImage.enabled=true	
		self.game:SendNetworkMessage(require "Network.ServerService".ExploreMapQueryRequest(self.chapterData.ChapterInfoID))

	 else
	 	self.redDotImage.enabled=false	
	 	self.LastTime.text=self.chapterData.data:GetChapterLv().."级开启"
	 	--self.ChallengdungeonStageImage.color=UnityEngine.Color(1,1,1,1)
	 	self.ChallengdungeonStageImage.material=utility.GetGrayMaterial(true)
	 	-- self.Title.color=UnityEngine.Color(1,1,1,1)
	 	-- self.Reward.color=UnityEngine.Color(1,1,1,1)
	 	-- self.TitleOutLine.effectColor=UnityEngine.Color(0,0,0,1)
	 	-- self.RewardOutLine.effectColor=UnityEngine.Color(0,0,0,1)
	-- 	print("需要达到"..self.chapterData.data:GetChapterLv().."开启")
	end
	-- body
end

function ExploreItemCls:OnPause()
	-- 界面隐藏时调用
	ExploreItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ExploreItemCls:OnEnter()
	-- Node Enter时调用
	ExploreItemCls.base.OnEnter(self)
end

function ExploreItemCls:OnExit()
	-- Node Exit时调用
	ExploreItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ExploreItemCls:InitControls()
	self.game=utility:GetGame()
	self.transform = self:GetUnityTransform()
	self.ChallengeButton = self.transform:GetComponent(typeof(UnityEngine.UI.Button))
	self.ChallengdungeonStageImage = self.transform:GetComponent(typeof(UnityEngine.UI.Image))
	self.redDotImage=self.transform:Find('RedDot'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LastTime = self.transform:Find('LastTime'):GetComponent(typeof(UnityEngine.UI.Text))
	self.TiliText = self.transform:Find('TiliText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.redDotImage.enabled=false
	--local gameTool = require "Utils.GameTools"
	-- print(self.chapterData.atlaseName)
	utility.LoadSpriteFromPath("UI/Atlases/ExplorerSea/"..self.chapterData.atlaseName,self.ChallengdungeonStageImage)
	--self.SelectChallengdungeonStageImage.color=self.chapterData.Color
	

	local UserDataType = require "Framework.UserDataType"
	local userData = self:GetCachedData(UserDataType.PlayerData)


	if self.remainCount ~=nil then
		if self.remainCount<=0 then
			self.redDotImage.enabled=false	
		else
			self.redDotImage.enabled=true
		end
	end
	local FirstLevelID = require"StaticData.Chapter":GetData(self.chapterData.ChapterID):GetFirstLevelID()
	local needTili = require"StaticData.ChapterLevel":GetData(FirstLevelID):GetVigorToConsume()
	self.TiliText.text=string.format(DungeonStringTable[0],needTili)

	--self:InitInfo()
end

-- function ExploreItemCls:InitInfo()
-- 	self.Title.text=self.chapterData.data:GetChapterInfo():GetName()
-- 	self.Reward.text=self.chapterData.infoData:GetDescShort()
-- end


function ExploreItemCls:RegisterControlEvents()
	-- 注册 SelectChallengdungeonStage 的事件
	self.__event_button_onSelectChallengdungeonStageClicked__ = UnityEngine.Events.UnityAction(self.OnSelectChallengdungeonStageClicked, self)
	self.ChallengeButton.onClick:AddListener(self.__event_button_onSelectChallengdungeonStageClicked__)
end

function ExploreItemCls:UnregisterControlEvents()
	-- 取消注册 SelectChallengdungeonStage 的事件
	if self.__event_button_onSelectChallengdungeonStageClicked__ then
		self.ChallengeButton.onClick:RemoveListener(self.__event_button_onSelectChallengdungeonStageClicked__)
		self.__event_button_onSelectChallengdungeonStageClicked__ = nil
	end
end

-- function  ExploreItemCls:InitViews()
-- 	-- body
-- 	 self.mTrans=self:GetUnityTransform()     
--      self.mRTrans=self.mTrans:GetComponent(typeof(UnityEngine.RectTransform))    
--      self.mRTrans.sizeDelta=Vector2(self.width,self.height)  
--      self.mRTrans.pivot = Vector2(0.5, 0.5);--//设置panel的中心在左上角
--      self.mRTrans.anchorMin =  Vector2(0, 1);
--      self.mRTrans.anchorMax =  Vector2(0, 1);  
-- end
-- local function DelayOnBind(self,width,height)
-- 	while (not self:IsReady()) do
-- 		coroutine.step(1)
-- 	end
-- 	self.transform.localPosition = Vector2(width,height)
-- 	---初始化好了进行回掉
-- 	self.callback:Invoke()
	
-- end
-- function ExploreItemCls:SetPosition(width,height)
-- 	coroutine.start(DelayOnBind,self,width,-height)

-- end


-- function ExploreItemCls:SetRotate(distance,itemWidth)

-- 	if -tempValue*10<-10 then
-- 		transform.localEulerAngles=Vector3(0,-10,0)
-- 	else
-- 		transform.localEulerAngles=Vector3(0,-tempValue*10,0)
-- 	end
-- 	local tempScale=1-math.abs(tempValue/10)
-- 	transform.localScale = Vector3(tempScale, tempScale, 1)

-- end

--
-- function ExploreItemCls:ResetPosition()
	
-- end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ExploreItemCls:OnSelectChallengdungeonStageClicked()
	--SelectChallengdungeonStage控件的点击事件处理
	if self.remainCount ~=nil then
		if self.remainCount<=0 then
		
		local windowManager = utility:GetGame():GetWindowManager()
	   	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, "今日探索次数已经用完")

		else
			
			local UserDataType = require "Framework.UserDataType"
		    local userData = self:GetCachedData(UserDataType.PlayerData)
		  	print(self.chapterData.data:GetChapterLv())
		   -- self.controls.characterLevelLbl.text = userData:GetLevel()
		   if  userData:GetLevel()>=self.chapterData.data:GetChapterLv() then
				self.didCallback:Invoke(self.chapterData)
			else
				self.game:SendNetworkMessage(require "Network.ServerService".ExploreMapQueryRequest(self.chapterData.ChapterInfoID))
			end
		end
	else
		
		local windowManager = utility:GetGame():GetWindowManager()
	   	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, "等级不够")
	end
	
end
-------------------------------------------------------------
------------------网络事件-----------------------------------
-------------------------------------------------------------

function ExploreItemCls:RegisterNetworkEvents()
		-- self.game:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	self.game:RegisterMsgHandler(net.S2CExploreMapQueryResult, self, self.ExploreMapQueryResult)
end

function ExploreItemCls:UnregisterNetworkEvents()
		--加载玩家信息
	
	  -- self.game:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	self.game:UnRegisterMsgHandler(net.S2CExploreMapQueryResult, self, self.ExploreMapQueryResult)
end
---探险结果返回
function ExploreItemCls:ExploreMapQueryResult(msg)
	if msg.systemID==self.chapterData.ChapterInfoID then
		self.LastTime.text="剩余次数: "..msg.remainCount
		self.remainCount=msg.remainCount
		debug_print(msg.remainCount,'剩余',self.chapterData.ChapterInfoID)
	end
	if self.remainCount ~=nil then
		if self.remainCount<=0 then
			self.redDotImage.enabled=false	
		else
			self.redDotImage.enabled=true
		end
	end
	
end

return ExploreItemCls

