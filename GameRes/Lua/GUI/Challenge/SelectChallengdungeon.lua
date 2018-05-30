local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SelectChallengdungeonCls = Class(BaseNodeClass)

function SelectChallengdungeonCls:Ctor(firstChapterIndex)
	self.firstChapterIndex=firstChapterIndex or 1
debug_print("firstChapterIndex",firstChapterIndex)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SelectChallengdungeonCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SelectChallengdungeon', function(go)
		self:BindComponent(go)
	end)
end

function SelectChallengdungeonCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function SelectChallengdungeonCls:OnResume()
	require "Utils.GameAnalysisUtils".EnterScene("探险之旅界面")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_JourneyView)
	-- 界面显示时调用
	SelectChallengdungeonCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)
	self.game:SendNetworkMessage(require "Network.ServerService".ExploreQueryRequest())
	--self.game:SendNetworkMessage(require "Network.ServerService".ExploreQueryRequest())
	--self.game:SendNetworkMessage(require "Network.ServerService".ExploreQueryRequest())
--	print("***********************************************************************")
end

function SelectChallengdungeonCls:OnPause()
	-- 界面隐藏时调用
	SelectChallengdungeonCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SelectChallengdungeonCls:OnEnter()
	-- Node Enter时调用
	SelectChallengdungeonCls.base.OnEnter(self)
end

function SelectChallengdungeonCls:OnExit()
	-- Node Exit时调用
	SelectChallengdungeonCls.base.OnExit(self)
end

function SelectChallengdungeonCls:Update()
--	print("GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG")
	if self.isMove then
		self:MoveTransform()
	end
	if self.isChangeImage then 
		self:ChangePicture()
	end

	if self.isChangeColor then
		self:ChangeColor()
	end
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SelectChallengdungeonCls:InitControls()

	local transform = self:GetUnityTransform()

	self.game=utility:GetGame()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Decoration = transform:Find('Decoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TitleImag = transform:Find('TitleImag'):GetComponent(typeof(UnityEngine.UI.Image))
	self.SubtitleBase = transform:Find('SelectDifficultyBox/SubtitleBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.LightBar = transform:Find('SelectDifficultyBox/LightBar'):GetComponent(typeof(UnityEngine.UI.Image))
	self.StageImageBase = transform:Find('SelectDifficultyBox/StageImageBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InkDecoration1 = transform:Find('SelectDifficultyBox/InkDecoration1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InkDecoration2 = transform:Find('SelectDifficultyBox/InkDecoration2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LinghtlingDecoration1 = transform:Find('SelectDifficultyBox/LinghtlingDecoration1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LinghtlingDecoration2 = transform:Find('SelectDifficultyBox/LinghtlingDecoration2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LinghtlingDecoration3 = transform:Find('SelectDifficultyBox/LinghtlingDecoration3'):GetComponent(typeof(UnityEngine.UI.Image))
	self.AnimatedStageImage = transform:Find('SelectDifficultyBox/AnimatedStageImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InfoBox = transform:Find('SelectDifficultyBox/InfoBox'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InfoText = transform:Find('SelectDifficultyBox/InfoBox/InfoText'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InfoBoxDecoration = transform:Find('SelectDifficultyBox/InfoBox/InfoBoxDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InfoBoxTitle = transform:Find('SelectDifficultyBox/InfoBox/InfoBoxTitle'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.SelectDifficultyBoxBase = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--标题
	self.StageTitle = transform:Find('SelectDifficultyBox/StageTitle'):GetComponent(typeof(UnityEngine.UI.Text))
	--奖励wenzi 
	self.Reward2 = transform:Find('SelectDifficultyBox/Reward2'):GetComponent(typeof(UnityEngine.UI.Text))
	--文字提示

	self.InfoBoxText1 = transform:Find('SelectDifficultyBox/InfoBox/Scroll View/Viewport/Content/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.InfoBoxText2 = transform:Find('SelectDifficultyBox/InfoBox/Scroll View/Viewport/Content/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text))

	
	---难度的五图片
	self.difficults={}
	for i=1,5 do
		self.difficults[i]={}
	end

	 self.difficults[1].difficultButton = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon1'):GetComponent(typeof(UnityEngine.UI.Button))
	 self.difficults[1].difficultImage = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon1/Image/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[1].difficultTrans = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon1/SelectYourStage1')
	self.difficults[1].lock = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon1/Image/Lock'):GetComponent(typeof(UnityEngine.UI.Image))
	self.difficults[1].text = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon1/Image/Lock/Text'):GetComponent(typeof(UnityEngine.UI.Text))

	-- self.difficults[1].difficultTrans.gameObject:SetActive(false)
	 self.currentClickBut =self.difficults[1]
	 self.currentClickBut.index=1
	 self.difficults[1].difficultIconName="1Icon"

	self.grayMat=self.difficults[1].difficultImage.material
	 self.difficults[2].difficultButton = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon2'):GetComponent(typeof(UnityEngine.UI.Button))
	 self.difficults[2].difficultImage = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon2/Image/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[2].lock = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon2/Image/Lock'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[2].text = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon2/Image/Lock/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	 self.difficults[2].difficultTrans = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon2/SelectYourStage2')
	 self.difficults[2].difficultIconName="2Icon"
	 self.difficults[2].difficultTrans.gameObject:SetActive(false)


 	 self.difficults[3].difficultButton = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon3'):GetComponent(typeof(UnityEngine.UI.Button))
	 self.difficults[3].difficultImage = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon3/Image/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[3].lock = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon3/Image/Lock'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[3].text = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon3/Image/Lock/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	 self.difficults[3].difficultTrans = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon3/SelectYourStage3')
	 self.difficults[3].difficultIconName="3Icon"
	 self.difficults[3].difficultTrans.gameObject:SetActive(false)


 	 self.difficults[4].difficultButton = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon4'):GetComponent(typeof(UnityEngine.UI.Button))
	 self.difficults[4].difficultImage = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon4/Image/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[4].lock = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon4/Image/Lock'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[4].text = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon4/Image/Lock/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	 self.difficults[4].difficultTrans = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon4/SelectYourStage4')
	 self.difficults[4].difficultIconName="4Icon"
	 self.difficults[4].difficultTrans.gameObject:SetActive(false)


     self.difficults[5].difficultButton = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon5'):GetComponent(typeof(UnityEngine.UI.Button))
	 self.difficults[5].difficultImage = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon5/Image/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[5].lock = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon5/Image/Lock'):GetComponent(typeof(UnityEngine.UI.Image))
	 self.difficults[5].text = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon5/Image/Lock/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	 self.difficults[5].difficultTrans = transform:Find('SelectDifficultyBox/SelectDifficultyBoxBase/SelectDifficultyStageIcon5/SelectYourStage5')
	 self.difficults[5].difficultIconName="5Icon"
	 self.difficults[5].difficultTrans.gameObject:SetActive(false)
	--难度图片
	self.SelectChallengdungeonDifficultyIcon1 = transform:Find('SelectDifficultyBox/InfoBox/SelectChallengdungeonDifficultyIcon1'):GetComponent(typeof(UnityEngine.UI.Image))
	

	self.TexturesTran = transform:Find('Textures')
	self.StageClickImage=transform:Find('Textures/StageImage'):GetComponent(typeof(UnityEngine.UI.Image))

	self.SelectChallengdungeonReturnButton = transform:Find('SelectChallengdungeonReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SelectChallengdungeonFightButton = transform:Find('SelectChallengdungeonFightButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SelectStageBox = transform:Find('SelectStageBox'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Scroll_View = transform:Find('SelectStageBox/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	-- self.Scrollbar_Horizontal = transform:Find('SelectStageBox/Scroll View/Scrollbar Horizontal'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	-- self.Scrollbar_Vertical = transform:Find('SelectStageBox/Scroll View/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	-- self.Viewport = transform:Find('SelectStageBox/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.SubtitleBaseTran= transform:Find('SelectDifficultyBox')
	self.SubtitleBaseAnimator = transform:Find('SelectDifficultyBox'):GetComponent(typeof(UnityEngine.Animator))

	self.SelectStageBoxAnimator=transform:Find('SelectStageBox'):GetComponent(typeof(UnityEngine.Animator))


	--体力
	self.powerText=transform:Find('Currency/TiLi/TheMainTiLiLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.powerButton=transform:Find('Currency/TiLi/TiLiAddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--金钱
	self.moneyText=transform:Find('Currency/Money/TheMainMoneyLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.moneyButton=transform:Find('Currency/Money/MoneyAddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--钻石
	self.diamondText=transform:Find('Currency/Diamond/TheMainDiamondLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.diamondButton=transform:Find('Currency/Diamond/DiamondAddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--VIP
	self.VipText=transform:Find('TitleImag/VipButton (1)/TheMainCharacterVipLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.VipButton=transform:Find('TitleImag/VipButton (1)'):GetComponent(typeof(UnityEngine.UI.Button))

	self.SelectChallengdungeonReturnButton__1_ = transform:Find('SelectChallengdungeonReturnButton (1)'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SelectChallengdungeonRightButton = transform:Find('SelectStageBox/SelectChallengdungeonRightButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SelectChallengdungeonLeftButton = transform:Find('SelectStageBox/SelectChallengdungeonLeftButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.Scroll_ViewParent=transform:Find('SelectStageBox')
	
	self.Scroll_ViewRTran=self.Scroll_ViewParent:GetComponent(typeof(UnityEngine.RectTransform))
	self.Scroll_ViewParent.localPosition = Vector3(self.Scroll_ViewRTran.sizeDelta.x + 100, self.Scroll_ViewParent.localPosition.y, self.Scroll_ViewParent.localPosition.z)
	self.isAniamtion=false
	self.isChangeImage=false
	self.isChangeColor=false
	self:InitView()

end
--刷新金币钻石体力信息显示s
function SelectChallengdungeonCls:RefreshCurrency()
	  -- 设置货币刷新
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    self.powerText.text = string.format("%d/%d", userData:GetVigor(), userData:GetMaxVigor())
    self.moneyText.text = userData:GetCoin()
    self.diamondText.text = userData:GetDiamond()
    self.VipText.text=userData:GetVip()
end

--子物体初始化好了
function SelectChallengdungeonCls:InitChildCallBack()
	self.SelectChallengdungeonReturnButton__1_.transform:SetAsLastSibling()
	self.SelectChallengdungeonRightButton.transform:SetAsLastSibling()
	self.SelectChallengdungeonLeftButton.transform:SetAsLastSibling()
	self.childList=self.Scroll_ViewParent:GetComponentsInChildren(typeof(UnityEngine.Transform))
	self.skewList={}


	self.isMove=true
	self.totalMoveTime=0.5
	self.currentMoveTime=0
	self.isChangeImage=false
	self.totalChangeImageTime=0.8
	self.currentChangeImageTime=0
	
end




--修改图片的形状
function SelectChallengdungeonCls:ChangePicture()
 		local TweenUtility = require "Utils.TweenUtility"
       	local t = self.currentChangeImageTime/self.totalChangeImageTime
       	self.currentChangeImageTime=self.currentChangeImageTime+Time.deltaTime
    --   	print(t)
       	if t>1 then
       		 self.isChangeImage=false
       		-- print(self.currentChangeImageTime)
       		 self.Scroll:InitValue()
			--self:InitItems()
			self.Scroll:ResetChildPosition()
       	end
       	local s = TweenUtility.EaseInOutBack(0.5, 0,t)

  --       for i=1,#self.skewList do
		-- 	self.skewList[i].Horizontal=-s
		-- end
end

--修改图片的形状
function SelectChallengdungeonCls:MoveTransform()
       	local t = self.currentMoveTime/self.totalMoveTime
       	self.currentMoveTime=self.currentMoveTime+Time.deltaTime
       	if t>1 then
       		 self.isMove=false
       	end
       	if  self.isChangeImage  then
       		
       	else
				if t>0.2 then
       			self.isChangeImage=true
       		end

       	end
 		local transform = self.Scroll_ViewRTran
         local TweenUtility = require "Utils.TweenUtility"
         local s = TweenUtility.EaseInOutExpo(self.Scroll_ViewRTran.localPosition.x, 0,t)
         transform.localPosition = Vector3(s, transform.localPosition.y,  transform.localPosition.z)

end

function  SelectChallengdungeonCls:InitChapterInfos()
	local data = require "StaticData.Chapter"
	local infoData = require "StaticData.ChapterAdventureInfo"
	local chapterInfo = {}
	chapterInfo={}
	chapterInfo[1]={}
	--chapterInfo[1].ChapterID=12100000
	chapterInfo[1].ChapterInfoID=1001
	chapterInfo[1].kLineup=kLineup_JourneyToExplore1
	chapterInfo[1].atlaseName="DragonNail"
	chapterInfo[1].Color=UnityEngine.Color(160/255,60/255,20/255,1)

	chapterInfo[2]={}
	--chapterInfo[2].ChapterID=12100001
	chapterInfo[2].ChapterInfoID=1002
	chapterInfo[2].kLineup=kLineup_JourneyToExplore2
	chapterInfo[2].atlaseName="xu_2"
	chapterInfo[2].Color=UnityEngine.Color(20/128,60/255,162/255,1)

	chapterInfo[3]={}
--	chapterInfo[3].ChapterID=12100002
	chapterInfo[3].ChapterInfoID=1003
	chapterInfo[3].kLineup=kLineup_JourneyToExplore3
	chapterInfo[3].atlaseName="PowerFight"
	chapterInfo[3].Color=UnityEngine.Color(140/255,40/255,160/255,1)

	chapterInfo[4]={}
--	chapterInfo[4].ChapterID=12100003
	chapterInfo[4].ChapterInfoID=1004
	chapterInfo[4].kLineup=kLineup_JourneyToExplore5
	chapterInfo[4].atlaseName="Survival"
	chapterInfo[4].Color=UnityEngine.Color(0/255,160/255,130/255,1)

	local chapterAdventureData = require "StaticData.ChapterAdventure"
	for i=1,#chapterInfo do
		
		local data1= chapterAdventureData:GetData(chapterInfo[i].ChapterInfoID)
		chapterInfo[i].ChapterID=data1:GetMapID()
		chapterInfo[i].round=data1:GetRound()
		chapterInfo[i].BossPortrait={}
		chapterInfo[i].BossPortrait[1]=data1:GetBossPortrait1()
		chapterInfo[i].BossPortrait[2]=data1:GetBossPortrait2()
		chapterInfo[i].BossPortrait[3]=data1:GetBossPortrait3()
		chapterInfo[i].BossPortrait[4]=data1:GetBossPortrait4()
		chapterInfo[i].BossPortrait[5]=data1:GetBossPortrait5()
	
		for j=1,#chapterInfo[i].BossPortrait do
			for k=1,chapterInfo[i].BossPortrait[j].Count do
				print(chapterInfo[i].BossPortrait[j][k-1])
			end
			
		end
	end

	self.Chapter={}

	for i=1,#chapterInfo do
		self.Chapter[i]=chapterInfo[i]
		print("999999999999999  ",#self.Chapter[i].BossPortrait)
	end

	-- self.Chapter[5]={}
	-- self.Chapter[5].ChapterID=12100004
	-- self.Chapter[5].ChapterInfoID=1005
	-- self.Chapter[5].kLineup=kLineup_JourneyToExplore4
	

	for i=1,#self.Chapter do
		self.Chapter[i].data=data:GetData(self.Chapter[i].ChapterID)
		self.Chapter[i].infoData=infoData:GetData(self.Chapter[i].ChapterInfoID)
		print(self.Chapter[i].ChapterID,i)
	
	end



end



---初始化显示的Scrollview
function SelectChallengdungeonCls:InitView()
	self:InitChapterInfos()
	--self:RefreshCurrency()
	self.Scroll= require "GUI.Challenge.HorizontalScrollViewBase".New(self.Scroll_ViewParent,1,300,466,#self.Chapter,1237,466,self.Chapter)
	self:AddChild(self.Scroll)
	self.Scroll:SetDidChildCallback(self,self.ChildClickedCallBack)
	self.Scroll:SetCallback(self,self.InitChildCallBack)
--	self.childLenght=self.Scroll_ViewParent:GetComponentsInChildren(typeof(UnityEngine.Transform)
end
------------改变透明度
function SelectChallengdungeonCls:ChangeColor()
 		local TweenUtility = require "Utils.TweenUtility"
       	local t = self.currentChangeImageTime/self.totalChangeColorTime
       	self.currentChangeColorTime=self.currentChangeColorTime+Time.deltaTime
    --   	print(t)
       	if t>1 then
       		 self.isChangeColor=false
      	 	self.Scroll_ViewParent.gameObject:SetActive(false)
      	 	self.TexturesTran.gameObject:SetActive(false)
       	end
       	local s = TweenUtility.EaseInOutBack(1, 0,t)

	    for i=0,self.childList.Length-1 do
	    	local tempImage = self.childList[i].gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	    	if tempImage then
				tempImage.color=UnityEngine.Color(tempImage.color.r, tempImage.color.g, tempImage.color.b, s)
	    	end

	    	local tempText = self.childList[i].gameObject:GetComponent(typeof(UnityEngine.UI.Text))
	    	if tempText then
				tempText.color=UnityEngine.Color(tempText.color.r, tempText.color.g, tempText.color.b, s)
	    	end
	    end
end
--打开和显示物体
function SelectChallengdungeonCls:ShowAndResetComponent()
	for i=0,self.childList.Length-1 do
	    	local tempImage = self.childList[i].gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	    	if tempImage then
				tempImage.color=UnityEngine.Color(tempImage.color.r, tempImage.color.g, tempImage.color.b, 1)
	    	end

	    	local tempText = self.childList[i].gameObject:GetComponent(typeof(UnityEngine.UI.Text))
	    	if tempText then
				tempText.color=UnityEngine.Color(tempText.color.r, tempText.color.g, tempText.color.b, 1)
	    	end
	    end
	local childRect = self.Scroll_ViewParent:GetComponent(typeof(UnityEngine.RectTransform))  
	childRect.pivot = Vector2(0.5, 0.5);--//设置panel的中心在左上角
     childRect.anchorMin =  Vector2(0.5, 0.5);
     childRect.anchorMax =  Vector2(0.5, 0.5);  
     childRect.transform.localPosition=Vector3(0,-26,0)
     print(childRect.name)
 	self.Scroll:InitValue()
			--self:InitItems()
			self.Scroll:ResetChildPosition()

     -- local ScrollRect=self.Scroll:GetComponent(typeof(UnityEngine.RectTransform))  
     -- ScrollRect.transform.localPosition=Vector3(0,0,0)


end


--延时关闭与打开显示
local function DelayHide(self)



		local gameTool = require "Utils.GameTools"

	utility.LoadSpriteFromPath("UI/Atlases/Challenge/"..self.childData.atlaseName,self.AnimatedStageImage)

	self.TexturesTran.gameObject:SetActive(true)
	coroutine.wait(0.313)
	self.SelectStageBoxAnimator.runtimeAnimatorController=nil
	self.isChangeColor=true
	self.currentChangeColorTime=0
	self.totalChangeColorTime=0.3
	coroutine.wait(0.25)	
	--self.SelectStageBoxAnimator:CrossFade("SelectDifficultyBox", 0);

	--第二个界面
	self.SubtitleBaseTran.gameObject:SetActive(true)
	self.SubtitleBaseAnimator:CrossFade("SelectDifficultyBox", 0);
	self.SelectChallengdungeonReturnButton__1_.gameObject:SetActive(false)
	self.SelectChallengdungeonReturnButton.gameObject:SetActive(true)
	self.SelectChallengdungeonFightButton.gameObject:SetActive(true)





end



-----子物体按钮被点击事件返回

-- function  SelectChallengdungeonCls:ResetButton()
	
-- 		local BattleUtility = require "Utils.BattleUtility"
-- 	local chapterLevel = require "StaticData.ChapterLevel"
-- 	local role = require "StaticData.Role"
-- 	local id = self.currentClickBut.index+self.childData.data:GetFirstLevelID()-1
-- 	print(id,"   &&&&&&&&&&&&&&&&&&&&&&&&&&&")
-- end




 function SelectChallengdungeonCls:ChildClickedCallBack(table)
 	--print(type(info))
	print("SelectChallengdungeonCls")--,self.info.data:GetChapterInfo():GetName())
	print(type(table),table.ChapterID)
	self.childData=table
	self:ResetInfo()
	-- print(#table.BossPortrait,"OOOOOOOOOOOOOO")
	local gameTool = require "Utils.GameTools"	
	local num=1
	if self.childData.ChapterInfoID==1003 then
		num = gameTool.AutoWeedDay()
	end
	for i=1,#self.difficults do
		
	end
	for i=1,#self.childData.BossPortrait do
		utility.LoadRoleHeadIcon(self.childData.BossPortrait[i][num-1],self.difficults[i].difficultImage)
	--	print(self.childData.BossPortrait[i][num-1])
	end


	self.SelectStageBoxAnimator.runtimeAnimatorController=utility.GetRunTimeAnaimator("SelectStageBox")
		
	utility.LoadSpriteFromPath("UI/Atlases/Challenge/"..self.childData.atlaseName,self.StageClickImage)
	-- coroutine.start(DelayHide,self)
	self:StartCoroutine(DelayHide)

end 
--重置信息
function SelectChallengdungeonCls:ResetInfo()
	self.StageTitle.text=self.childData.infoData:GetName()
	--标题
	
	--奖励wenzi 
	self.Reward2.text =self.childData.infoData:GetDescShort()
	--文字提示
	local hintStr = self.childData.infoData:GetDescLong()
--	print(hintStr)
	local str = string.gsub(hintStr,"\\n","\n")
--	print(str)
	self.InfoBoxText1.text = str

	self.InfoBoxText2.text =""

	for i=1,#self.difficults do
		self.difficults[i].difficultImage.material=self.grayMat
		self.difficults[i].difficultButton.enabled=false
		self.difficults[i].difficultTrans.gameObject:SetActive(false)
		self.difficults[i].lock.gameObject:SetActive(true)
	end
	self.difficults[1].difficultTrans.gameObject:SetActive(true)

	self.currentClickBut=self.difficults[1]
	self.currentClickBut.index=1
	local atlaseName = "Challenge"
	utility.LoadAtlasesSprite(atlaseName,self.difficults[1].difficultIconName,self.SelectChallengdungeonDifficultyIcon1)

	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local level= userData:GetLevel() 


	local BattleUtility = require "Utils.BattleUtility"
	local chapterLevel = require "StaticData.ChapterLevel"
	
	local id = self.childData.data:GetFirstLevelID()
	local index = 1
	local chapterLevelData = chapterLevel:GetData(id)
	
	while chapterLevelData:GetNextLevelId()~=nil or chapterLevelData:GetNextLevelId()~=0  do

		
		--print(level,chapterLevelData:GetNextLevelId(),"---------------",chapterLevelData:GetLevelLimit())
		if level>=chapterLevelData:GetLevelLimit() then
		--print(level,chapterLevelData:GetNextLevelId(),"&&&&&&&&&&&&&&&&&",chapterLevelData:GetLevelLimit())

			self.difficults[index].lock.gameObject:SetActive(false)
			self.difficults[index].difficultImage.material=nil
			self.difficults[index].difficultButton.enabled=true
		else
			--print("ssssssssssssssssssssssssssssssssssssssss")
			self.difficults[index].text.text=chapterLevelData:GetLevelLimit().."级开启！"

		end
		index=index+1


		if chapterLevelData:GetNextLevelId() ~=0 then
			chapterLevelData = chapterLevel:GetData(chapterLevelData:GetNextLevelId())
		else
			break
		end
		-- if chapterLevelData:GetNextLevelId()==nil or chapterLevelData:GetNextLevelId()==0 then
		-- 	break
		-- end

	end

	print(id,"---------------",level)




end



function SelectChallengdungeonCls:RegisterControlEvents()
	-- 注册 SelectChallengdungeonReturnButton 的事件
	self.__event_button_onSelectChallengdungeonReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSelectChallengdungeonReturnButtonClicked, self)
	self.SelectChallengdungeonReturnButton.onClick:AddListener(self.__event_button_onSelectChallengdungeonReturnButtonClicked__)

	-- 注册 SelectChallengdungeonFightButton 的事件
	self.__event_button_onSelectChallengdungeonFightButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSelectChallengdungeonFightButtonClicked, self)
	self.SelectChallengdungeonFightButton.onClick:AddListener(self.__event_button_onSelectChallengdungeonFightButtonClicked__)

	
	-- 注册 SelectChallengdungeonReturnButton__1_ 的事件
	self.__event_button_onSelectChallengdungeonReturnButton__1_Clicked__ = UnityEngine.Events.UnityAction(self.OnSelectChallengdungeonReturnButton__1_Clicked, self)
	self.SelectChallengdungeonReturnButton__1_.onClick:AddListener(self.__event_button_onSelectChallengdungeonReturnButton__1_Clicked__)

	-- 注册 SelectChallengdungeonRightButton 的事件
	self.__event_button_onSelectChallengdungeonRightButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSelectChallengdungeonRightButtonClicked, self)
	self.SelectChallengdungeonRightButton.onClick:AddListener(self.__event_button_onSelectChallengdungeonRightButtonClicked__)

	-- 注册 SelectChallengdungeonLeftButton 的事件
	self.__event_button_onSelectChallengdungeonLeftButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSelectChallengdungeonLeftButtonClicked, self)
	self.SelectChallengdungeonLeftButton.onClick:AddListener(self.__event_button_onSelectChallengdungeonLeftButtonClicked__)

	-- 注册self.difficults[1].difficult1Button 的事件
	self.__event_button_onDifficult1ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDifficult1ButtonClicked, self)
	self.difficults[1].difficultButton.onClick:AddListener(self.__event_button_onDifficult1ButtonClicked__)

	self.__event_button_onDifficult2ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDifficult2ButtonClicked, self)
	self.difficults[2].difficultButton.onClick:AddListener(self.__event_button_onDifficult2ButtonClicked__)

	self.__event_button_onDifficult3ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDifficult3ButtonClicked, self)
	self.difficults[3].difficultButton.onClick:AddListener(self.__event_button_onDifficult3ButtonClicked__)

	self.__event_button_onDifficult4ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDifficult4ButtonClicked, self)
	self.difficults[4].difficultButton.onClick:AddListener(self.__event_button_onDifficult4ButtonClicked__)

	self.__event_button_onDifficult5ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDifficult5ButtonClicked, self)
	self.difficults[5].difficultButton.onClick:AddListener(self.__event_button_onDifficult5ButtonClicked__)



end

function SelectChallengdungeonCls:UnregisterControlEvents()
	-- 取消注册 SelectChallengdungeonReturnButton 的事件
	if self.__event_button_onSelectChallengdungeonReturnButtonClicked__ then
		self.SelectChallengdungeonReturnButton.onClick:RemoveListener(self.__event_button_onSelectChallengdungeonReturnButtonClicked__)
		self.__event_button_onSelectChallengdungeonReturnButtonClicked__ = nil
	end

	-- 取消注册 SelectChallengdungeonFightButton 的事件
	if self.__event_button_onSelectChallengdungeonFightButtonClicked__ then
		self.SelectChallengdungeonFightButton.onClick:RemoveListener(self.__event_button_onSelectChallengdungeonFightButtonClicked__)
		self.__event_button_onSelectChallengdungeonFightButtonClicked__ = nil
	end

	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

	-- 取消注册 Scrollbar_Horizontal 的事件
	if self.__event_scrollbar_onScrollbar_HorizontalValueChanged__ then
		self.Scrollbar_Horizontal.onValueChanged:RemoveListener(self.__event_scrollbar_onScrollbar_HorizontalValueChanged__)
		self.__event_scrollbar_onScrollbar_HorizontalValueChanged__ = nil
	end

	-- 取消注册 Scrollbar_Vertical 的事件
	if self.__event_scrollbar_onScrollbar_VerticalValueChanged__ then
		self.Scrollbar_Vertical.onValueChanged:RemoveListener(self.__event_scrollbar_onScrollbar_VerticalValueChanged__)
		self.__event_scrollbar_onScrollbar_VerticalValueChanged__ = nil
	end

	-- 取消注册 SelectChallengdungeonReturnButton__1_ 的事件
	if self.__event_button_onSelectChallengdungeonReturnButton__1_Clicked__ then
		self.SelectChallengdungeonReturnButton__1_.onClick:RemoveListener(self.__event_button_onSelectChallengdungeonReturnButton__1_Clicked__)
		self.__event_button_onSelectChallengdungeonReturnButton__1_Clicked__ = nil
	end

	-- 取消注册 SelectChallengdungeonRightButton 的事件
	if self.__event_button_onSelectChallengdungeonRightButtonClicked__ then
		self.SelectChallengdungeonRightButton.onClick:RemoveListener(self.__event_button_onSelectChallengdungeonRightButtonClicked__)
		self.__event_button_onSelectChallengdungeonRightButtonClicked__ = nil
	end

	-- 取消注册 SelectChallengdungeonLeftButton 的事件
	if self.__event_button_onSelectChallengdungeonLeftButtonClicked__ then
		self.SelectChallengdungeonLeftButton.onClick:RemoveListener(self.__event_button_onSelectChallengdungeonLeftButtonClicked__)
		self.__event_button_onSelectChallengdungeonLeftButtonClicked__ = nil
	end



	-- 取消注册 SelectChallengdungeonLeftButton 的事件
	if self.__event_button_onDifficult1ButtonClicked__ then
		self.difficults[1].difficultButton.onClick:RemoveListener(self.__event_button_onDifficult1ButtonClicked__)
		self.__event_button_onDifficult1ButtonClicked__ = nil
	end

	if self.__event_button_onDifficult2ButtonClicked__ then
		self.difficults[2].difficultButton.onClick:RemoveListener(self.__event_button_onDifficult2ButtonClicked__)
		self.__event_button_onDifficult2ButtonClicked__ = nil
	end

	if self.__event_button_onDifficult3ButtonClicked__ then
		self.difficults[3].difficultButton.onClick:RemoveListener(self.__event_button_onDifficult3ButtonClicked__)
		self.__event_button_onDifficult3ButtonClicked__ = nil
	end

	if self.__event_button_onDifficult4ButtonClicked__ then
		self.difficults[4].difficultButton.onClick:RemoveListener(self.__event_button_onDifficult4ButtonClicked__)
		self.__event_button_onDifficult4ButtonClicked__ = nil
	end

	if self.__event_button_onDifficult5ButtonClicked__ then
		self.difficults[5].difficultButton.onClick:RemoveListener(self.__event_button_onDifficult5ButtonClicked__)
		self.__event_button_onDifficult5ButtonClicked__ = nil
	end


end


function SelectChallengdungeonCls:HandleButtonClicked(index )

	-- local path = "UI/Atlases/Challenge/"..self.difficults[index].difficultIconName
 	-- local AtlasesLoader = require "Utils.AtlasesLoader"
 	-- print(path)
	local atlaseName = "Challenge"
    -- local sprite = AtlasesLoader:LoadAtlasSprite(path)
	utility.LoadAtlasesSprite(atlaseName,self.difficults[index].difficultIconName,self.SelectChallengdungeonDifficultyIcon1)
	-- self.SelectChallengdungeonDifficultyIcon1.sprite=sprite
	if self.currentClickBut then
		self.currentClickBut.difficultTrans.gameObject:SetActive(false)
		self.currentClickBut= self.difficults[index]
		self.currentClickBut.index=index
		self.currentClickBut.difficultTrans.gameObject:SetActive(true)
	
	else
		self.currentClickBut= self.difficults[index]
		self.currentClickBut.index=index
		self.currentClickBut.difficultTrans.gameObject:SetActive(true)

	end


	
end
-------------------------------------------------------------
------------------网络事件-----------------------------------
-------------------------------------------------------------
function SelectChallengdungeonCls:UnregisterNetworkEvents()
		--加载玩家信息
	
	--  self.game:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
	  self.game:UnRegisterMsgHandler(net.S2CExploreQueryResult, self, self.ExploreQueryResult)
	  self.game:UnRegisterMsgHandler(net.S2CExploreMapQueryResult, self, self.ExploreMapQueryResult)
end

function SelectChallengdungeonCls:RegisterNetworkEvents()
	--	self.game:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.UpdatePlayerData)
		self.game:RegisterMsgHandler(net.S2CExploreQueryResult, self, self.ExploreQueryResult)
		self.game:RegisterMsgHandler(net.S2CExploreMapQueryResult, self, self.ExploreMapQueryResult)
end

---------------------------------
-----------请求返回协议---------
--------------------------------

function SelectChallengdungeonCls:ExploreQueryResult(msg)
	
		-- for i=1,#msg.explores do
		-- 	print("mapID",msg.explores[i].mapID,"isExplore",msg.explores[i].isExplore,"id",msg.explores[i].id,"name",msg.explores[i].name)
		-- end
end

-----------------------------
----------加载玩家信息------
-----------------------------
function SelectChallengdungeonCls:UpdatePlayerData()
	-- 刷新玩家当前的金币 钻石 体力等显示
	--self:RefreshCurrency()
end




--延时关闭与打开显示
local function DelayShowAnimation(self)
	self.SubtitleBaseAnimator:CrossFade("SelectBack", 0);
	--self.game:SendNetworkMessage(require "Network.ServerService".ExploreQueryRequest())
	coroutine.wait(1.5)
	self.SelectChallengdungeonReturnButton__1_.gameObject:SetActive(true)
	self.SelectChallengdungeonReturnButton.gameObject:SetActive(false)
	self.SelectChallengdungeonFightButton.gameObject:SetActive(false)
	self.SubtitleBaseTran.gameObject:SetActive(false)
	self.Scroll_ViewParent.gameObject:SetActive(true)
	self:ShowAndResetComponent()
	

end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SelectChallengdungeonCls:OnSelectChallengdungeonReturnButtonClicked()
	print("OnSelectChallengdungeonReturnButtonClicked")
	self:StartCoroutine(DelayShowAnimation)
end

function SelectChallengdungeonCls:InitEnemysInfo()
	-- body
	local BattleUtility = require "Utils.BattleUtility"
	local chapterLevel = require "StaticData.ChapterLevel"
	local role = require "StaticData.Role"
	local id = self.currentClickBut.index+self.childData.data:GetFirstLevelID()-1
	print(id,"   &&&&&&&&&&&&&&&&&&&&&&&&&&&")
	local chapterLevelData =chapterLevel:GetData(id)

-----足够的体力
	local isEnough, errorRoutine = utility.IsVigorEnough(chapterLevelData:GetVigorToConsume())
    if not isEnough then
        errorRoutine()
        return
    end
	--print(chapterLevelData:GetTeams())
	local gameTool = require "Utils.GameTools"
	local enemyTeams = chapterLevelData:GetTeams()

	print(self.childData.ChapterInfoID)
	local index=1
	if self.childData.ChapterInfoID==1003 then
		index = gameTool.AutoWeedDay()
	end
	for i=1,#enemyTeams do
	 	print(enemyTeams[i]:GetId())
	end

	print(id,"   +++++++++++++++++")
	------------------暂定一波------------

	self.enemyInfo = {}

	local allTeams = BattleUtility.CreateBattleTeamsByLevelID(id)

	utility.ASSERT(
		#allTeams > 0, 
		string.format(
			"关卡 %d 配置的队伍数为0",
			id
		)
	)
	local power = 0
	local battleTeamParameter = allTeams[1]

	local unitCount = battleTeamParameter:Count()
	for i = 1, unitCount do
		local curUnit = battleTeamParameter:GetUnit(i)

		local role = curUnit:GetRole()
		local location = curUnit:GetLocation()
		power=role:GetPower()+power
		local t = {}
		t.cardID = role:GetId()
		t.cardColor = role:GetColor()
		t.cardLevel = role:GetLv()
		t.cardPos = location
		t.cardStage = role:GetStage()
		t.sparColor = role:GetStar()

		self.enemyInfo[#self.enemyInfo + 1] = t
	end
	local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.Formation.ArenaEnemyFormation",nil,self.enemyInfo,power,self.StartChallengFight,self)


	
end
-- local function CheckFormationCount(self)
-- 	local UserDataType = require "Framework.UserDataType"
-- 	local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	
-- 	local ArenaDefenceCount = cardBagData:GetTroopCount(kLineup_ArenaDefence)
-- 	if ArenaDefenceCount == 0 then
-- 		utility.ShowErrorDialog("防守阵容不能为空，请先设置防守阵容")
-- 		return false
-- 	end
-- 	return true
-- end
function SelectChallengdungeonCls:StartChallengFight()
	print('显示挑战阵容')
	-- if CheckFormationCount(self) ==false then
	-- 	return
	-- end

	



 	local LocalDataType = require "LocalData.LocalDataType" 
    local ServerService = require "Network.ServerService"

    local BattleUtility = require "Utils.BattleUtility"

    --local foeTeams = self:GetFoeTeam()
    local chapterLevel = require "StaticData.ChapterLevel"
    local id = self.currentClickBut.index+self.childData.data:GetFirstLevelID()-1
	local chapterLevelData =chapterLevel:GetData(id)
	print(id)
	print(chapterLevelData,"___________________________________")
	local foeTeams = BattleUtility.CreateBattleTeamsByLevelID(id)


	local battleParams = require "LocalData.Battle.BattleParams".New()
	battleParams:SetSceneID(2)
	battleParams:SetScriptID(nil)
	battleParams:SetBattleType(self.childData.kLineup)
	battleParams:SetBattleOverLocalDataName(LocalDataType.ExploreBattleResult)
	battleParams:SetBattleStartProtocol(ServerService.ExploreFightRequest(self.childData.ChapterInfoID,id))
	battleParams:SetBattleResultResponsePrototype(net.S2CExploreStartFightResult)
	battleParams:SetBattleResultViewClassName("GUI.Challenge.ChallengFightResult")
	battleParams:SetMaxBattleRounds(self.childData.round)
	if self.childData.ChapterInfoID==1004 then
		debug_print("CCCCCCCCCC@@@@@@@@@@@@@")
		battleParams:SetBattleResultWhenReachMaxRounds(true)
	else
		battleParams:SetBattleResultWhenReachMaxRounds(false)
	end

	if self.childData.ChapterInfoID==1003 then
		battleParams:SetUnlimitedRage(true)
	else
		battleParams:SetUnlimitedRage(false)
	end
	
	battleParams:SetPVPMode(true)
	-- battleParams:DisableManuallyOperation()
	battleParams:SetSkillRestricted(false)
	

	utility.StartBattle(battleParams, foeTeams, nil)


    -- local battleStartParams = require "LocalData.BattleStartParams".New()
    -- battleStartParams:SetBattleResultLocalDataName(LocalDataType.ExploreBattleResult)
    -- print(self.childData.ChapterID,id)
    -- battleStartParams:SetBattleRecordProtocol(ServerService.ExploreFightRequest(self.childData.ChapterInfoID,id))
    -- battleStartParams:SetBattleResultResponse(net.S2CExploreStartFightResult)
    -- battleStartParams:SetBattleResultViewHANDLEClassName("GUI.Challenge.ChallengFightResult")
    -- print(self.childData.kLineup)
  --  utility.StartBattle(self.childData.kLineup, battleStartParams, foeTeams)



end


function SelectChallengdungeonCls:ExploreMapQueryResult(msg)
	debug_print("******************************")
	if self.requestMapQuery == false then
		return
	end
	self.requestMapQuery = false
	local windowManager = utility:GetGame():GetWindowManager()
	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
	if self.childData==nil then
		return
	end
	if msg.systemID==self.childData.ChapterInfoID then
		local remainCount=msg.remainCount
		debug_print("self.currentClickBut.index+self.childData.ChapterID-1")
		if remainCount ~=nil then
			if remainCount<=0 then
				
				windowManager:Show(ConfirmDialogClass, "今日探索次数已经用完")
			else
				 self:InitEnemysInfo()
			end
		else
			windowManager:Show(ConfirmDialogClass, "服务器返回数据有问题")
		end
	end
	
end
function SelectChallengdungeonCls:OnSelectChallengdungeonFightButtonClicked()
	--SelectChallengdungeonFightButton控件的点击事件处理
	debug_print("点击战斗按钮",self.currentClickBut.index+self.childData.ChapterID-1)
	debug_print("self.childData",self.childData.ChapterInfoID)
	self.requestMapQuery = true
	self.game:SendNetworkMessage(require "Network.ServerService".ExploreMapQueryRequest(self.childData.ChapterInfoID))



	
	
end



function SelectChallengdungeonCls:OnDifficult1ButtonClicked()
	--Scroll_View控件的点击事件处理
	print("OnDifficult1ButtonClicked")
	print(type(table),self.childData.ChapterID)
	self:HandleButtonClicked(1)
	

end
function SelectChallengdungeonCls:OnDifficult2ButtonClicked()
	--Scroll_View控件的点击事件处理
	print("OnDifficult2ButtonClicked")
	self:HandleButtonClicked(2)
end

function SelectChallengdungeonCls:OnDifficult3ButtonClicked()
	--Scroll_View控件的点击事件处理
	print("OnDifficult3ButtonClicked")
	print(type(table),self.childData.ChapterID)
	self:HandleButtonClicked(3)
end

function SelectChallengdungeonCls:OnDifficult4ButtonClicked()
	--Scroll_View控件的点击事件处理
	print("OnDifficult4ButtonClicked")
	print(type(table),self.childData.ChapterID)
	self:HandleButtonClicked(4)
end

function SelectChallengdungeonCls:OnDifficult5ButtonClicked()
	--Scroll_View控件的点击事件处理
	print("OnDifficult5ButtonClicked")
	print(type(table),self.childData.ChapterID)
	self:HandleButtonClicked(5)
end

function SelectChallengdungeonCls:OnScrollbar_HorizontalValueChanged(value)
	--Scrollbar_Horizontal控件的点击事件处理
end

function SelectChallengdungeonCls:OnScrollbar_VerticalValueChanged(value)
	--Scrollbar_Vertical控件的点击事件处理
end




function SelectChallengdungeonCls:OnSelectChallengdungeonReturnButton__1_Clicked()
	--SelectChallengdungeonReturnButton__1_控件的点击事件处理
	
--local hintStr = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
	local sceneManager = self.game:GetSceneManager()
    sceneManager:PopScene()
end

function SelectChallengdungeonCls:OnSelectChallengdungeonRightButtonClicked()
	--SelectChallengdungeonRightButton控件的点击事件处理
end

function SelectChallengdungeonCls:OnSelectChallengdungeonLeftButtonClicked()
	--SelectChallengdungeonLeftButton控件的点击事件处理
end

return SelectChallengdungeonCls

