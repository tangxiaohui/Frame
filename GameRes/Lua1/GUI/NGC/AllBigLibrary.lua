local BaseNodeClass=require"Framework.Base.WindowNode"
local utility=require"Utils.Utility"
local messageManager=require"Network.MessageManager"

local AllBigLibraryCls=Class(BaseNodeClass)


function AllBigLibraryCls:Ctor()	

end

--场景状态

--加载界面（只走一次）
function AllBigLibraryCls:OnInit()
	utility.LoadNewGameObjectAsync('UI/Prefabs/AllBigLibrary',function (go)
		self:BindComponent(go)
		
	end)
end

function AllBigLibraryCls:OnWillShow(index,flag)
	self.index=index
	self.flag=flag
end
--界面加载完成初始化函数只走一次
function AllBigLibraryCls:OnComponentReady()
    self:InitControls()
   
end

--界面显示时调用
function AllBigLibraryCls:OnResume()
	AllBigLibraryCls.base.OnResume(self)
	self:GetUnityTransform():SetAsLastSibling()
	self:RegisterControlEvents()
	--self.InitViews()

end

--界面隐藏时调用
function AllBigLibraryCls:OnPause()
	AllBigLibraryCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function AllBigLibraryCls:OnEnter()
	AllBigLibraryCls.base.OnEnter(self)
end

function AllBigLibraryCls:OnExit()
	
	AllBigLibraryCls.base.OnExit(self)
end

--控件绑定
function AllBigLibraryCls:InitControls()
	local transform=self:GetUnityTransform()
	self.game=utility.GetGame()
	--英雄按钮
	self.BigLibraryHeroButton=transform:Find('Content/Sort/NewEntry/GenusSortLayout/BigLibraryHeroButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BigLibraryHeroButtonImage=transform:Find('Content/Sort/NewEntry/GenusSortLayout/BigLibraryHeroButton/GenusSortStatus')
	--战斗按钮
	self.BigLibraryFightButton=transform:Find('Content/Sort/NewEntry/GenusSortLayout/BigLibraryFightButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BigLibraryFightButtonImage=transform:Find('Content/Sort/NewEntry/GenusSortLayout/BigLibraryFightButton/GenusSortStatus')
	--等级攻略按钮
	self.BigLibraryLevelStrategyButton=transform:Find('Content/Sort/NewEntry/GenusSortLayout/BigLibraryLevelStrategyButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BigLibraryLevelStrategyButtonImage=transform:Find('Content/Sort/NewEntry/GenusSortLayout/BigLibraryLevelStrategyButton/GenusSortStatus')
	--玩法介绍按钮
	self.BigLibraryHowToPlayButton=transform:Find('Content/Sort/NewEntry/GenusSortLayout/BigLibraryHowToPlayButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BigLibraryHowToPlayButtonImage=transform:Find('Content/Sort/NewEntry/GenusSortLayout/BigLibraryHowToPlayButton/GenusSortStatus')
	--英雄搭配按钮
	self.BigLibraryHeroWaerButton=transform:Find('Content/Sort/GrowthPath/GenusSortLayout/BigLibraryHeroWaerButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BigLibraryHeroWaerButtonImage=transform:Find('Content/Sort/GrowthPath/GenusSortLayout/BigLibraryHeroWaerButton/GenusSortStatus')
	----滚动试图
	self.ScrollPanel=transform:Find('rightContent/ScrollPanel'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
    
    local  itemParent = transform:Find('rightContent/ScrollPanel/Layout')
     self.NGCEnum={All="All",Hero="Hero",Fight="Fight",LevelStrategy="LevelStrategy",HowToPlay="HowToPlay",HeroWaer="HeroWaer"}
     
    --local windowManager=self:GetGame():GetWindowManager()
	self.AllImages={self.BigLibraryHeroButtonImage,self.BigLibraryFightButtonImage,self.BigLibraryLevelStrategyButtonImage,self.BigLibraryHowToPlayButtonImage,self.BigLibraryHeroWaerButtonImage}

     self.Alllist={}
     self.Alllist[1]={}   ---英雄
     self.Alllist[2]={}   ---战斗
     self.Alllist[3]={}   --等级攻略
     self.Alllist[4]={}   ---玩法介绍
     self.Alllist[5]={}   ---英雄搭配
     ---英雄
    
    
     -- local BigLibraryStrategyInfoMgr = Data.BigLibraryStrategyInfo.Manager.Instance()
     -- self.keys= BigLibraryStrategyInfoMgr:GetKeys()
      local BigLibraryMgr = Data.BigLibrary.Manager.Instance()
      local BigLibraryStrategyMgr = Data.BigLibraryStrategy.Manager.Instance()


     local fakeId = 3

     local startId = fakeId * 100 + 1

     local allLibraries = {} --存放的是以3为父项的子项

     local currentLibrary = BigLibraryMgr:GetObject(startId)

     while(currentLibrary ~= nil)
     	do
     		allLibraries[#allLibraries + 1] = currentLibrary
     		startId = startId + 1
     		currentLibrary = BigLibraryMgr:GetObject(startId)
     end

     ---按钮的个数    #allLibraryies

     self.sortNumber= {}  --------------攻略一级分组分组ID
     -- local i=allLibraries[1]*100+1
     -- local currentSort = BigLibraryStrategyMgr:GetObject(i)
     
     -- while(currentSort~=nil)
     -- 	do
     --    self.heroNumber[#self.heroNumber+1]=currentSort
     --    i=i+1
     --    currentSort=BigLibraryStrategrMgr:GetObject(i)
     -- end
  ---------self.sortNumber[i] 攻略二级分组id

  
    local x=allLibraries[1]*100+1
    for i=0,#allLibraries do
      while(currentSort~=nil) do
       self.sortNumber[i][#self.sortNumber[i]=currentSort
       x=x+1
       currentSort=BigLibraryStrategrMgr:GetObject(x)
       end

    end
    

    







   
     for i=0,self.keys.Length-1 do 
     	if tonumber(self.keys[i])<3010200 then
     		if tonumber(self.keys[i])>3010100 then 
     			local item = require"GUI.NGC.heroStar".New(itemParent,self.keys[i])
                self:AddChild(item)
                self.Alllist[1][tostring(i)]=item 
     		end
     	end

     end
   

     for i=0,self.keys.Length-1 do
     		if tonumber(self.keys[i])<3010300 then
     			if tonumber(self.keys[i])>3010200 then
                  local item = require"GUI.NGC.heroStar".New(itemParent,self.keys[i])
                  self:AddChild(item)
                  self.Alllist[2][tostring(i)]=item
     			end 	
     		end	
     end

 
     for i=0,self.keys.Length-1 do
     	
     		if tonumber(self.keys[i])<3010400 then
     			if tonumber(self.keys[i])>3010300 then
                  local item = require"GUI.NGC.heroStar".New(itemParent,self.keys[i])
                  self:AddChild(item)
                  self.Alllist[3][tostring(i)]=item

     			end 
     		end
     	
     end

     
  
     for i=0,self.keys.Length-1 do
    
     		if tonumber(self.keys[i])<3010500 then
     			if tonumber(self.keys[i])>3010400 then
                  local item = require"GUI.NGC.heroStar".New(itemParent,self.keys[i])
                  self:AddChild(item)
                  self.Alllist[4][tostring(i)]=item
     			end 
     		end
     end
     
        
     for i=0,self.keys.Length-1 do
     	if tonumber(self.keys[i])>3020100 then
                  local item = require"GUI.NGC.heroStar".New(itemParent,self.keys[i])
                  self:AddChild(item)
                  self.Alllist[5][tostring(i)]=item    
     	end
     end


     self.CurrentState=self.NGCEnum.All
   
end

function AllBigLibraryCls:RegisterControlEvents()
	---注册BigLibraryHeroButton
	self._event_OnBigLibraryHeroButtonClicked_=UnityEngine.Events.UnityAction(self.BigLibraryHeroButtonClicked,self)
	self.BigLibraryHeroButton.onClick:AddListener(self._event_OnBigLibraryHeroButtonClicked_)
   --注册BigLibraryFightButton
   self._event_OnBigLibraryFightButtonClicked_=UnityEngine.Events.UnityAction(self.BigLibraryFightButtonClicked,self)
   self.BigLibraryFightButton.onClick:AddListener(self._event_OnBigLibraryFightButtonClicked_)
   --注册BigLibraryLevelStrategyButton
   self._event_OnBigLibraryLevelStrategyButtonClicked_=UnityEngine.Events.UnityAction(self.BigLibraryLevelStrategyButtonClicked,self)
   self.BigLibraryLevelStrategyButton.onClick:AddListener(self._event_OnBigLibraryLevelStrategyButtonClicked_)
   --注册BigLibraryHowToPlayButton
   self._event_OnBigLibraryHowToPlayButtonClicked_=UnityEngine.Events.UnityAction(self.BigLibraryHowToPlayButtonClicked,self)
   self.BigLibraryHowToPlayButton.onClick:AddListener(self._event_OnBigLibraryHowToPlayButtonClicked_)
   --注册BigLibraryHeroWaerButton
   self._event_OnBigLibraryHeroWaerButtonClicked_=UnityEngine.Events.UnityAction(self.BigLibraryHeroWaerButtonClicked,self)
   self.BigLibraryHeroWaerButton.onClick:AddListener(self._event_OnBigLibraryHeroWaerButtonClicked_)

	
end

-----显示和隐藏某个类型的信息
function OnShowlist(list,active)
     
	for k,v in pairs(list) do
		v:GetUnityTransform().gameObject:SetActive(active)
		
	end
end
function AllBigLibraryCls:UnregisterControlEvents()
	---取消注册BigLibraryHeroButton
	if self._event_OnBigLibraryHeroButtonClicked_ then 
		self.BigLibraryHeroButton.onClick:RemoveListener(self._event_OnBigLibraryHeroButtonClicked_)
		self._event_OnBigLibraryHeroButtonClicked_=nil
	end
    --取消注册BigLibraryFightButton
	if self._event_OnBigLibraryFightButtonClicked_ then
		self.BigLibraryFightButton.onClick:RemoveListener(self._event_OnBigLibraryFightButtonClicked_)
		self._event_OnBigLibraryFightButtonClicked_=nil
	end
    --取消注册BigLibraryLevelStrategyButton
	if self._event_OnBigLibraryLevelStrategyButtonClicked_ then
		self.BigLibraryLevelStrategyButton.onClick:RemoveListener(self._event_OnBigLibraryLevelStrategyButtonClicked_)
		self._event_OnBigLibraryLevelStrategyButtonClicked_=nil
	end
    --取消注册BigLibraryHowToPlayButton
	if self._event_OnBigLibraryHowToPlayButtonClicked_ then
		self.BigLibraryHowToPlayButton.onClick:RemoveListener(self._event_OnBigLibraryHowToPlayButtonClicked_)
		self._event_OnBigLibraryHowToPlayButtonClicked_=nil
	end
    --取消注册BigLibraryHeroWaerButton
	if self._event_OnBigLibraryHeroWaerButtonClicked_ then
		self.BigLibraryHeroWaerButton.onClick:RemoveListener(self._event_OnBigLibraryHeroWaerButtonClicked_)
		self._event_OnBigLibraryHeroWaerButtonClicked_=nil
	end
end

function AllBigLibraryCls:ChangeButtonColor(buttonimage,isClicked)
	for i=1,#self.AllImages do
		self.AllImages[i].gameObject:SetActive(false)
	end
	buttonimage.gameObject:SetActive(isClicked)
end
--第一条攻略显示的内容
function AllBigLibraryCls:BigLibraryHeroButtonClicked()
   if self.CurrentState==self.NGCEnum.Hero then
   	return 
   end
  
   OnShowlist(self.Alllist[1],true)
   OnShowlist(self.Alllist[2],false)
   OnShowlist(self.Alllist[3],false)
   OnShowlist(self.Alllist[4],false)
   OnShowlist(self.Alllist[5],false)
   self:ChangeButtonColor(self.BigLibraryHeroButtonImage,true)

   self.CurrentState=self.NGCEnum.Hero
end

function AllBigLibraryCls:BigLibraryFightButtonClicked()
   if self.CurrentState==self.NGCEnum.Fight then
   	return 
   end

   OnShowlist(self.Alllist[2],true)
   OnShowlist(self.Alllist[1],false)
   OnShowlist(self.Alllist[3],false)
   OnShowlist(self.Alllist[4],false)
   OnShowlist(self.Alllist[5],false)
   self:ChangeButtonColor(self.BigLibraryFightButtonImage,true)
   self.CurrentState=self.NGCEnum.Fight
end

function AllBigLibraryCls:BigLibraryLevelStrategyButtonClicked()
	print("LevelStrategy")
   if self.CurrentState==self.NGCEnum.LevelStrategy then
   	return 
   end
   OnShowlist(self.Alllist[3],true)
   OnShowlist(self.Alllist[2],false)
   OnShowlist(self.Alllist[1],false)
   OnShowlist(self.Alllist[4],false)
   OnShowlist(self.Alllist[5],false)
   self:ChangeButtonColor(self.BigLibraryLevelStrategyButtonImage,true)
   self.CurrentState=self.NGCEnum.LevelStrategy
end

function AllBigLibraryCls:BigLibraryHowToPlayButtonClicked()
   if self.CurrentState==self.NGCEnum.HowToPlay then
   	return 
   end
   OnShowlist(self.Alllist[4],true)
    OnShowlist(self.Alllist[2],false)
   OnShowlist(self.Alllist[3],false)
   OnShowlist(self.Alllist[1],false)
   OnShowlist(self.Alllist[5],false)
   self:ChangeButtonColor(self.BigLibraryHowToPlayButtonImage,true)
   self.CurrentState=self.NGCEnum.HowToPlay
end

function AllBigLibraryCls:BigLibraryHeroWaerButtonClicked()
   if self.CurrentState==self.NGCEnum.HeroWaer then
   	return 
   end
   OnShowlist(self.Alllist[5],true)
   OnShowlist(self.Alllist[2],false)
   OnShowlist(self.Alllist[3],false)
   OnShowlist(self.Alllist[4],false)
   OnShowlist(self.Alllist[1],false)
   self:ChangeButtonColor(self.BigLibraryHeroWaerButtonImage,true)
   self.CurrentState=self.NGCEnum.HeroWaer
end


return AllBigLibraryCls