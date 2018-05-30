local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local NewPlayerGuideCls = Class(BaseNodeClass)

function NewPlayerGuideCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function NewPlayerGuideCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NewPlayerGuide', function(go)
		self:BindComponent(go)
	end)
end
function NewPlayerGuideCls:OnWillShow(SystemGuide,func,tables)
	self.SystemGuide=SystemGuide
	self.tables=tables
	 if func ~=nil then
        self.callback=LuaDelegate.New()
        self.callback:Set(tables, func)
     end

end
function NewPlayerGuideCls:GetWindowManager()
	return self:GetGame():GetPersistentWindowManager()
end



function NewPlayerGuideCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function NewPlayerGuideCls:OnResume()
	-- 界面显示时调用
	NewPlayerGuideCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()	
	--self:StartGuide()
	self:InitViews()
end

function NewPlayerGuideCls:OnPause()
	-- 界面隐藏时调用
	NewPlayerGuideCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function NewPlayerGuideCls:OnEnter()
	-- Node Enter时调用
	NewPlayerGuideCls.base.OnEnter(self)
end

function NewPlayerGuideCls:OnExit()
	-- Node Exit时调用
	NewPlayerGuideCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function NewPlayerGuideCls:InitControls()
	local transform = self:GetUnityTransform()
	--新手引導的手指
	self.shouzhi = transform:Find('Finger')

	self.stepInfo={}
	self.stepInfo[1]={}
	self.stepInfo[1].object=transform:Find('Tips/Position1')
	self.stepInfo[1].textInfo={}
	self.stepInfo[1].textInfo[1] = transform:Find('Tips/Position1/TextPosition/Position1/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.stepInfo[1].textInfo[2] = transform:Find('Tips/Position1/TextPosition/Position2/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.stepInfo[1].textInfo[3] = transform:Find('Tips/Position1/TextPosition/Position3/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.stepInfo[1].textInfo[4] = transform:Find('Tips/Position1/TextPosition/Position4/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.stepInfo[2]={}	
	self.stepInfo[2].object=transform:Find('Tips/Position2')
	self.stepInfo[2].textInfo={}
	self.stepInfo[2].textInfo[1] = transform:Find('Tips/Position2/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.stepInfo[3]={}	
	self.stepInfo[3].object=transform:Find('Tips/Position3')
	self.stepInfo[3].textInfo={}		
	self.stepInfo[3].textInfo[1] =transform:Find('Tips/Position3/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.ScreenMaxButton = transform:Find('Tips/ButtonParent/ScreenMaxButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ScreenSelectButton = transform:Find('Tips/ButtonParent/ScreenSelectButton'):GetComponent(typeof(UnityEngine.UI.Button))
	

end

-- 会删除
function NewPlayerGuideCls:Close(immediately)
    self:GetWindowManager():Close(self, immediately)
end


local function DelayChangePos(self,guideData)
	local dis = 10
	local pos = Vector3(0,0,0)

	
	while (dis>1) do
		
		dis=Vector3.Distance(pos,guideData.stepButton.transform.position)
		pos=guideData.stepButton.transform.position
	--	hzj_print("=====",dis)
		coroutine.step(1)
	end

		local btnPosition = guideData.stepButton.transform.position
		--self.shouzhi.position=guideData.stepButton.transform.position
		self.shouzhi.transform.position = Vector3(btnPosition.x + 4, btnPosition.y - 6, btnPosition.z)
		self.ScreenSelectButton.transform.position = btnPosition


end



function NewPlayerGuideCls:InitViews()

	self:ResetView()
	if self.guideData~=nil then
		if self.guideData.nextStep == nil then
	--	hzj_print("sdfffffffffffffffffffffffffff")

			self.callback:Invoke(self.tables)
			self:Close()
			--self.func(self.tables)
			return
		end
	end

	hzj_print(self.SystemGuide,"SystemGuide")


	self.guideData= self.SystemGuide:GetSystemGuideNextStep()
	
	if self.guideData.stepButton~=nil then
		self.ScreenMaxButton.enabled=false
		self.ScreenSelectButton.enabled=true
	else
		self.ScreenMaxButton.enabled=true
		self.ScreenSelectButton.enabled=false
	end
	hzj_print(self.guideData.stepIndex,self.guideData.stepType,self.guideData.stepPortraitPos,self.guideData.stepInfoPos)
	if self.guideData ==nil then	
		self:Close()
	else
		--表示按钮是背景
		if self.guideData.stepType == 1 then
		--	hzj_print("**************",self.stepInfo[guideData.stepPortraitPos].textInfo[guideData.stepInfoPos])
			self.stepInfo[self.guideData.stepPortraitPos].object.gameObject:SetActive(true)
			self.stepInfo[self.guideData.stepPortraitPos].textInfo[self.guideData.stepInfoPos].transform.parent.gameObject:SetActive(true)
			self.stepInfo[self.guideData.stepPortraitPos].textInfo[self.guideData.stepInfoPos].text = self.guideData.stepInfo
			self.ScreenSelectButton.enabled=false
			self.ScreenMaxButton.enabled=true

		--	self:ShowPortrait(guideData.stepPortraitPos)

		--表示是按钮
		else
			self.ScreenSelectButton.enabled=true
			self.ScreenMaxButton.enabled=false
			self.stepInfo[self.guideData.stepPortraitPos].object.gameObject:SetActive(true)
			self.stepInfo[self.guideData.stepPortraitPos].textInfo[self.guideData.stepInfoPos].transform.parent.gameObject:SetActive(true)
			self.stepInfo[self.guideData.stepPortraitPos].textInfo[self.guideData.stepInfoPos].text = self.guideData.stepInfo

			self.shouzhi.gameObject:SetActive(true)
			if self.guideData.delayType==1 then
				self:StartCoroutine(DelayChangePos, self.guideData)

			else
				local btnPosition = self.guideData.stepButton.transform.position
				--self.shouzhi.position=guideData.stepButton.transform.position
				self.shouzhi.transform.position = Vector3(btnPosition.x + 4, btnPosition.y - 6, btnPosition.z)
	  		    self.ScreenSelectButton.transform.position = btnPosition

			end
		
		end

	end


end
-- function NewPlayerGuideCls:ShowPortrait(index)
-- --	self.stepInfo[index].object.gameObject:SetActive(false)

-- end
-- --开始引导
-- function NewPlayerGuideCls:StartGuide()
-- 	--local guideData= self.SystemGuide:GetSystemGuideNextStep()
-- end


local function DelayStartSystemGuide(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self:GetUnityTransform().gameObject:SetActive(true)
	self:InitViews()

end

--开始引导
function NewPlayerGuideCls:DoNextStepGuide()
	--hzj_print( self:GetUnityTransform().gameObject.activeSelf)

	--hzj_print("NewPlayerGuideCls:DoNextStepGuide()",debug.traceback())
	-- self:StartCoroutine(DelayStartSystemGuide,self)
	self:GetUnityTransform().gameObject:SetActive(true)
	self:InitViews()

	-- if self.guideData~=nil then
	-- 	if self.guideData.guideEnd == nil then
	-- 	hzj_print("sdfffffffffffffffffffffffffff")

	-- 		self.callback:Invoke(self.tables)
	-- 		self:Close()
	-- 		--self.func(self.tables)
	-- 		return
	-- 	end
	-- end


	--hzj_print( self:GetUnityTransform().gameObject.activeSelf)

end

--开始引导
function NewPlayerGuideCls:ResetView()
	for i=1,#self.stepInfo do
		for j=1,#self.stepInfo[i].textInfo do
			self.stepInfo[i].object.gameObject:SetActive(false)
			self.stepInfo[i].textInfo[j].transform.parent.gameObject:SetActive(false)
		end		
	end
	self.shouzhi.gameObject:SetActive(false)
end


function NewPlayerGuideCls:RegisterControlEvents()
	hzj_print("RegisterControlEvents")
	-- 注册 ScreenMaxButton 的事件
	self.__event_button_onScreenMaxButtonClicked__ = UnityEngine.Events.UnityAction(self.OnScreenMaxButtonClicked, self)
	self.ScreenMaxButton.onClick:AddListener(self.__event_button_onScreenMaxButtonClicked__)

	-- 注册 ScreenSelectButton 的事件
	self.__event_button_onScreenSelectButtonClicked__ = UnityEngine.Events.UnityAction(self.OnScreenSelectButtonClicked, self)
	self.ScreenSelectButton.onClick:AddListener(self.__event_button_onScreenSelectButtonClicked__)
end

function NewPlayerGuideCls:UnregisterControlEvents()
	hzj_print("UnregisterControlEvents",debug.traceback())
	-- 取消注册 ScreenMaxButton 的事件
	if self.__event_button_onScreenMaxButtonClicked__ then
		self.ScreenMaxButton.onClick:RemoveListener(self.__event_button_onScreenMaxButtonClicked__)
		self.__event_button_onScreenMaxButtonClicked__ = nil
	end

	-- 取消注册 ScreenSelectButton 的事件
	if self.__event_button_onScreenSelectButtonClicked__ then
		self.ScreenSelectButton.onClick:RemoveListener(self.__event_button_onScreenSelectButtonClicked__)
		self.__event_button_onScreenSelectButtonClicked__ = nil
	end
end

function NewPlayerGuideCls:RegisterNetworkEvents()
end

function NewPlayerGuideCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function NewPlayerGuideCls:OnScreenMaxButtonClicked()
	--ScreenMaxButton控件的点击事件处理
	self:InitViews()
end

function NewPlayerGuideCls:OnScreenSelectButtonClicked()
	--ScreenSelectButton控件的点击事件处理
--	self:InitViews()
	self:GetUnityTransform().gameObject:SetActive(false)

	hzj_print("OnScreenSelectButtonClicked")
	self.guideData.stepButton.onClick:Invoke()
	
	
end

return NewPlayerGuideCls
