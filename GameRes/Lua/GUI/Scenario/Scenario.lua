local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local scriptStepData = require "StaticData.Scenario.ScriptStep"
local dataInfoData =  require "StaticData.Scenario.ScriptStepInfo"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ScenarioCls = Class(BaseNodeClass)
require "System.LuaDelegate"

function ScenarioCls:Ctor()
end
---table 调用的类
---listTable 类型table  内容ScriptStep中的ID 
---func 说完剧情之后的回调函数
function ScenarioCls:OnWillShow(table,listTable,func)
	self.listTable=listTable
	self.callBack = LuaDelegate.New()
	self:SetCallback(table,func)

end

function ScenarioCls:SetCallback(table,func)	
	 self.callBack:Set(table,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ScenarioCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Scenario', function(go)
		self:BindComponent(go)
	end)
end

function ScenarioCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ScenarioCls:OnResume()
	-- 界面显示时调用
	ScenarioCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)
	self:InitViews()
end

function ScenarioCls:OnPause()
	-- 界面隐藏时调用
	ScenarioCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ScenarioCls:OnEnter()
	-- Node Enter时调用
	ScenarioCls.base.OnEnter(self)
end

function ScenarioCls:OnExit()
	-- Node Exit时调用
	ScenarioCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ScenarioCls:InitControls()
	local transform = self:GetUnityTransform()
	self.BaseNextButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	self.parentTarn = transform:Find('TranslucentLayer')
	self.Left = transform:Find('Left')
	self.CharacterPicture = transform:Find('Left/CharacterPicture'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ScenarioLabel = transform:Find('Left/Base/ScenarioLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.NextButton = transform:Find('Left/Base/NextButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.NameBase = transform:Find('Left/NameBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text = transform:Find('Left/NameBase/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	


	self.Right = transform:Find('Right')
	self.CharacterPicture1 = transform:Find('Right/CharacterPicture'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ScenarioLabel1 = transform:Find('Right/Base/ScenarioLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.NextButton1 = transform:Find('Right/Base/NextButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.NameBase1 = transform:Find('Right/NameBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text1 = transform:Find('Right/NameBase/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.AudioSource=transform.gameObject:AddComponent(typeof(UnityEngine.AudioSource))

	-- self.aduio=self:GetAudioManager()
end



function ScenarioCls:InitViews()
	self.Left.gameObject:SetActive(false)
	self.Right.gameObject:SetActive(false)
	-- local scriptStepData = require "StaticData.Scenario.ScriptStep"
	-- local dataInfoData =  require "StaticData.Scenario.ScriptStepInfo"
	self.playCount=1
	for i=1,#self.listTable do
		local data = scriptStepData:GetData(self.listTable[i])
		print(self.listTable[i],data:GetNextStep(),data:GetSpeaker())
		local dataInfo = dataInfoData:GetData(self.listTable[i])
		print(dataInfo:GetContent())
	end
	self:ResetShow()
end

local function StopGameSound(self)
	self:GetAudioManager():StopME()
end

local function PlayGameSound(self, id)
	_G.PlayGameME(id)
end

function ScenarioCls:ResetShow()
	-- body
	self.clickNum=0
	if self.skeletonGraphic ~=nil then
 		UnityEngine.Object.DestroyImmediate(self.skeletonGraphic.gameObject.transform.parent.gameObject)
 		self.skeletonGraphic =nil
	end

	if self.playCount<=#self.listTable then
		self.BaseNextButton.enabled=true
		self.NextButton.enabled=true
		self.NextButton1.enabled=true
		self.state=1
		local data = scriptStepData:GetData(self.listTable[self.playCount])
		local dataInfo = dataInfoData:GetData(self.listTable[self.playCount])
		self.time=data:GetDuration()
		self.currentTime=0
		self.textInfo=dataInfo:GetContent()
		-- if string.len(self.textInfo)==0 then
		-- 	self.textInfo="    "
		-- else

		-- self.lastTime=string.len(self.textInfo)/20
		-- end

		print(self.time,self.textInfo,data:GetVoice())
		
		local voice = data:GetVoice()
		print( os.time(),voice,"****************")
		if voice ~= "" then
			vioce = tonumber(voice)
			PlayGameSound(self, vioce)
		end

		if data:GetIsSipne()==1 then
			print(data:GetIsSipne())
				self.CharacterPicture.gameObject:SetActive(false)
				self.Text.transform.parent.gameObject:SetActive(true)
				self.CharacterPicture1.gameObject:SetActive(false)
				self.Text1.transform.parent.gameObject:SetActive(true)

			local pos = data:GetPos()
			if pos==1 then

				self.Left.gameObject:SetActive(true)
				self.Right.gameObject:SetActive(false)
				self:SetPersonSpine(self.Text,self.CharacterPicture,data:GetSpeaker(),pos)
				self.showText=self.ScenarioLabel
			else
				self.Left.gameObject:SetActive(false)
				self.Right.gameObject:SetActive(true)
				self:SetPersonSpine(self.Text1,self.CharacterPicture1,data:GetSpeaker(),pos)
				self.showText=self.ScenarioLabel1
			end




		else
			if data:GetPortraitShow()==1 then

				self.CharacterPicture.gameObject:SetActive(true)
				self.Text.transform.parent.gameObject:SetActive(true)
				self.CharacterPicture1.gameObject:SetActive(true)
				self.Text1.transform.parent.gameObject:SetActive(true)
			else
				self.CharacterPicture.gameObject:SetActive(false)
				--self.Text.transform.parent.gameObject:SetActive(false)
				self.CharacterPicture1.gameObject:SetActive(false)
				--self.Text1.transform.parent.gameObject:SetActive(false)

			end

			if data:GetPos()==1 then

				self.Left.gameObject:SetActive(true)
				self.Right.gameObject:SetActive(false)
				self:SetPersonInfo(self.Text,self.CharacterPicture,data:GetSpeaker())
				self.showText=self.ScenarioLabel
			else
				self.Left.gameObject:SetActive(false)
				self.Right.gameObject:SetActive(true)
				self:SetPersonInfo(self.Text1,self.CharacterPicture1,data:GetSpeaker())
				self.showText=self.ScenarioLabel1
			end


		end
		
	else
		self.state=0
		self.callBack:Invoke()
		self:Close()

	end
end
function  ScenarioCls:SetPersonInfo(name,CharacterPicture,roleId)
	local roleInfo = require "StaticData.RoleInfo"
	local roleInfoData = roleInfo:GetData(roleId)
	name.text=roleInfoData:GetName()

	utility.LoadRolePortraitImage(roleId, CharacterPicture)
end

function  ScenarioCls:SetPersonSpine(name,CharacterPicture,roleId,pos)
	print("显示Spine")
	local roleInfo = require "StaticData.RoleInfo"
	local roleInfoData = roleInfo:GetData(roleId)
	name.text=roleInfoData:GetName()
	local GameObject= UnityEngine.GameObject
	
	local roleSpineInfo = require "StaticData.RoleSpine"
		local roleSpineInfoData = roleSpineInfo:GetData(roleId)
		local path = "Spine/Prefabs/"..roleSpineInfoData:GetSpinePath()
		print(roleSpineInfoData:GetSpinePath(),roleId,path)
		
		
		local obj = GameObject.Instantiate(utility.LoadResourceSync(path, typeof(UnityEngine.GameObject)))
		self.skeletonGraphic=obj:GetComponentInChildren(typeof( Spine.Unity.SkeletonGraphic))
		local t = obj.transform
		t:SetParent(self.parentTarn)
		
		local rectTran = t:GetComponent(typeof(UnityEngine.RectTransform))

        print(rectTran.localPosition);
        if pos==1 then
	        t.localScale =Vector3(-1, 1, 1);
	        rectTran.anchoredPosition =Vector3(rectTran.rect.width / 2 , rectTran.rect.height / 2)
		    rectTran.localPosition =Vector3(rectTran.localPosition.x, rectTran.localPosition.y,0)
	        rectTran.anchorMax = Vector2.zero;
	        rectTran.anchorMin = Vector2.zero;
	        rectTran.pivot = Vector2.one * 0.5;
        else
        	t.localScale =Vector3(1, 1, 1);
 			rectTran.anchoredPosition = Vector3(rectTran.rect.width / 2 * (-1), rectTran.rect.height / 2);
 			rectTran.localPosition =Vector3(rectTran.localPosition.x, rectTran.localPosition.y,0)
 			rectTran.anchorMax = Vector2(1, 0);
            rectTran.anchorMin = Vector2(1, 0);
            rectTran.pivot = Vector2.one * 0.5;
        end


end




function ScenarioCls:Update()
	if self.state==1 then
		self:ChangeShowText()
	end
	
end


--修改图片的形状
function ScenarioCls:ChangeShowText()
 		-- local TweenUtility = require "Utils.TweenUtility"
       	local t = self.currentTime/(self.time)
       	self.currentTime=self.currentTime+UnityEngine.Time.deltaTime
       	print(self.currentTime,self.time,os.time())
       	if self.currentTime<self.time then
		    self.showText.text=self.textInfo--string.sub(self.textInfo,0,string.len(self.textInfo))     

		  	if t<=1 then
	   			if t<=0.9 then
	   				--self.showText.text=string.sub(self.textInfo,0,t*string.len(self.textInfo))      
	   			else
	   				--self.showText.text=string.sub(self.textInfo,0,string.len(self.textInfo))     
	   			end
	      	 	 return	
	       				
		    end
			return

       	end
    --   	print(t)
     

       	self.state=0
       	self.playCount=self.playCount+1  
       	print( os.time(),voice,"Next****************") 
       	self:ResetShow() 

  --      	local s = TweenUtility.Linear(t*string.len(self.textInfo), string.len(self.textInfo),t)

  --       for i=1,#self.skewList do
		-- 	self.skewList[i].Horizontal=-s
		-- end
		-- self.showText.text=TweenUtility.Linear(0.5, string.len(self.textInfo),t)
		-- for i=1,string.len(self.textInfo) do
		-- 	print(string.sub(self.textInfo,0,i))
		-- end

end

function ScenarioCls:RegisterControlEvents()
	--self.BaseNextButton
	self.__event_button_onBaseNextButtonClicked__ = UnityEngine.Events.UnityAction(self.OnNextButtonClicked, self)
	self.BaseNextButton.onClick:AddListener(self.__event_button_onBaseNextButtonClicked__)

	-- 注册 NextButton 的事件
	self.__event_button_onNextButtonClicked__ = UnityEngine.Events.UnityAction(self.OnNextButtonClicked, self)
	self.NextButton.onClick:AddListener(self.__event_button_onNextButtonClicked__)

	-- 注册 NextButton1 的事件
	self.__event_button_onNextButton1Clicked__ = UnityEngine.Events.UnityAction(self.OnNextButtonClicked, self)
	self.NextButton1.onClick:AddListener(self.__event_button_onNextButton1Clicked__)

end

function ScenarioCls:UnregisterControlEvents()

		-- 取消注册 NextButton 的事件
	if self.__event_button_onBaseNextButtonClicked__ then
		self.BaseNextButton.onClick:RemoveListener(self.__event_button_onBaseNextButtonClicked__)
		self.__event_button_onBaseNextButtonClicked__ = nil
	end


	-- 取消注册 NextButton 的事件
	if self.__event_button_onNextButtonClicked__ then
		self.NextButton.onClick:RemoveListener(self.__event_button_onNextButtonClicked__)
		self.__event_button_onNextButtonClicked__ = nil
	end

	-- 取消注册 NextButton1 的事件
	if self.__event_button_onNextButton1Clicked__ then
		self.NextButton1.onClick:RemoveListener(self.__event_button_onNextButton1Clicked__)
		self.__event_button_onNextButton1Clicked__ = nil
	end

end

function ScenarioCls:RegisterNetworkEvents()
end

function ScenarioCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ScenarioCls:OnNextButtonClicked()
	--NextButton控件的点击事件处理
	if self.clickNum==0 then
		self.currentTime=self.time-0.5		
		self.clickNum=1
		StopGameSound(self)
	elseif self.clickNum==1 then
		self.BaseNextButton.enabled=false
		self.NextButton.enabled=false
		self.NextButton1.enabled=false
		self.currentTime=self.time
	end



end

function ScenarioCls:OnNextButton1Clicked()
	--NextButton1控件的点击事件处理
	self.currentTime=self.time-0.5
	self.BaseNextButton.enabled=false
	self.NextButton.enabled=false
	self.NextButton1.enabled=false
	StopGameSound(self)

end

return ScenarioCls
