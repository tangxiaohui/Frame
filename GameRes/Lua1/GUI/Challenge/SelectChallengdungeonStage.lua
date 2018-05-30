local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SelectChallengdungeonStageCls = Class(BaseNodeClass)
require "System.LuaDelegate"
function SelectChallengdungeonStageCls:Ctor(parent,parentTran,width,height,chapterData)
	self.parentTran=parentTran
	self.width=width
	self.height=height
	self.chapterData=chapterData
	self.parent=parent
	self.callback = LuaDelegate.New()
	self.didCallback = LuaDelegate.New()
	print(#self.chapterData.BossPortrait)

end
function SelectChallengdungeonStageCls:SetCallback(table,func)
	--self.table=table
	 self.callback:Set(table,func)
end

function SelectChallengdungeonStageCls:SetDidCallback(table,func)
	--self.table=table
	 self.didCallback:Set(table,func)
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SelectChallengdungeonStageCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SelectChallengdungeonStage', function(go)
		self:BindComponent(go)
	end)
end

function SelectChallengdungeonStageCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parentTran)
end

function SelectChallengdungeonStageCls:OnResume()
	-- 界面显示时调用
	SelectChallengdungeonStageCls.base.OnResume(self)
	

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitViews()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
 -- 	print(self.chapterData.data:GetChapterLv())
   -- self.controls.characterLevelLbl.text = userData:GetLevel()
   if  userData:GetLevel()>=self.chapterData.data:GetChapterLv() then
		self.game:SendNetworkMessage(require "Network.ServerService".ExploreMapQueryRequest(self.chapterData.ChapterInfoID))

	 else
	 	self.LastTime.text=self.chapterData.data:GetChapterLv().."级开启"
	 	self.SelectChallengdungeonStageImage.color=UnityEngine.Color(1,1,1,1)
	 	self.StageImage.material=utility.GetGrayMaterial(true)
	 	self.Title.color=UnityEngine.Color(1,1,1,1)
	 	self.Reward.color=UnityEngine.Color(1,1,1,1)
	 	self.TitleOutLine.effectColor=UnityEngine.Color(0,0,0,1)
	 	self.RewardOutLine.effectColor=UnityEngine.Color(0,0,0,1)
	-- 	print("需要达到"..self.chapterData.data:GetChapterLv().."开启")
	end
	
end

function SelectChallengdungeonStageCls:OnPause()
	-- 界面隐藏时调用
	SelectChallengdungeonStageCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SelectChallengdungeonStageCls:OnEnter()
	-- Node Enter时调用
	SelectChallengdungeonStageCls.base.OnEnter(self)
end

function SelectChallengdungeonStageCls:OnExit()
	-- Node Exit时调用
	SelectChallengdungeonStageCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SelectChallengdungeonStageCls:InitControls()
	self.game=utility:GetGame()
	self.transform = self:GetUnityTransform()
	self.SelectChallengdungeonStage = self.transform:GetComponent(typeof(UnityEngine.UI.Button))
	self.SelectChallengdungeonStageImage = self.transform:GetComponent(typeof(UnityEngine.UI.Image))
	--self.SelectChallengdungeonStage.enabled=false
	self.StageImage = self.transform:Find('StageImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Title = self.transform:Find('Title'):GetComponent(typeof(UnityEngine.UI.Text))
	self.TitleOutLine= self.transform:Find('Title'):GetComponent(typeof(UnityEngine.UI.Outline))
	self.Reward = self.transform:Find('Reward'):GetComponent(typeof(UnityEngine.UI.Text))
	self.RewardOutLine= self.transform:Find('Reward'):GetComponent(typeof(UnityEngine.UI.Outline))
	self.LastTime = self.transform:Find('LastTime'):GetComponent(typeof(UnityEngine.UI.Text))
	--print(self.chapterData.data:GetChapterLv())

	local gameTool = require "Utils.GameTools"
	print(self.chapterData.atlaseName)
	utility.LoadSpriteFromPath("UI/Atlases/Challenge/"..self.chapterData.atlaseName,self.StageImage)
	self.SelectChallengdungeonStageImage.color=self.chapterData.Color



	self:InitInfo()
end

function SelectChallengdungeonStageCls:InitInfo()
	self.Title.text=self.chapterData.data:GetChapterInfo():GetName()
	self.Reward.text=self.chapterData.infoData:GetDescShort()


end


function SelectChallengdungeonStageCls:RegisterControlEvents()
	-- 注册 SelectChallengdungeonStage 的事件
	self.__event_button_onSelectChallengdungeonStageClicked__ = UnityEngine.Events.UnityAction(self.OnSelectChallengdungeonStageClicked, self)
	self.SelectChallengdungeonStage.onClick:AddListener(self.__event_button_onSelectChallengdungeonStageClicked__)
end

function SelectChallengdungeonStageCls:UnregisterControlEvents()
	-- 取消注册 SelectChallengdungeonStage 的事件
	if self.__event_button_onSelectChallengdungeonStageClicked__ then
		self.SelectChallengdungeonStage.onClick:RemoveListener(self.__event_button_onSelectChallengdungeonStageClicked__)
		self.__event_button_onSelectChallengdungeonStageClicked__ = nil
	end
end

function  SelectChallengdungeonStageCls:InitViews()
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
function SelectChallengdungeonStageCls:SetPosition(width,height)
	--coroutine.start(DelayOnBind,self,width,-height)
	self:StartCoroutine(DelayOnBind,width,-height)
end


function SelectChallengdungeonStageCls:SetRotate(distance,itemWidth)

	if -tempValue*10<-10 then
		transform.localEulerAngles=Vector3(0,-10,0)
	else
		transform.localEulerAngles=Vector3(0,-tempValue*10,0)
	end
	local tempScale=1-math.abs(tempValue/10)
	transform.localScale = Vector3(tempScale, tempScale, 1)

end

--
function SelectChallengdungeonStageCls:ResetPosition()
	
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SelectChallengdungeonStageCls:OnSelectChallengdungeonStageClicked()
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

function SelectChallengdungeonStageCls:RegisterNetworkEvents()
		-- self.game:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	self.game:RegisterMsgHandler(net.S2CExploreMapQueryResult, self, self.ExploreMapQueryResult)
end

function SelectChallengdungeonStageCls:UnregisterNetworkEvents()
		--加载玩家信息
	
	  -- self.game:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	self.game:UnRegisterMsgHandler(net.S2CExploreMapQueryResult, self, self.ExploreMapQueryResult)
end
---探险结果返回
function SelectChallengdungeonStageCls:ExploreMapQueryResult(msg)
	if msg.systemID==self.chapterData.ChapterInfoID then
		self.LastTime.text="剩余次数 "..msg.remainCount
		self.remainCount=msg.remainCount
	--	print(msg.cdtime)
	end
	
end

return SelectChallengdungeonStageCls

