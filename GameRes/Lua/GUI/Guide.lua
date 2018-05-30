local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local UnityUtils = require "Utils.Unity"
local net = require "Network.Net"
local GuideCls = Class(BaseNodeClass)

-- ### 表示这个窗口只能同时弹出1个
windowUtility.SetMutex(GuideCls, true)

local kDynamicBtn = 2
local kFullMask = 0

function GuideCls:Ctor()
	self.stepBtn = nil
	self.btnType = -1
	self.typeParam = nil
	self.typePos = nil
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuideCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NewPlayerGuide', function(go)
		self:BindComponent(go)
	end)
end

function GuideCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:InitView()
end

function GuideCls:OnResume()
	-- 界面显示时调用
	GuideCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuideCls:OnPause()
	-- 界面隐藏时调用
	GuideCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuideCls:OnEnter()
	-- Node Enter时调用
	GuideCls.base.OnEnter(self)
end

function GuideCls:OnExit()
	-- Node Exit时调用
	GuideCls.base.OnExit(self)
end

function GuideCls:OnWillShow(content, btnType, typeParam, typePos, highlight, highlightPos, 
							portrait, portraitPos, framePosition,voice,locateDelay,ModulePath)
	self.content = content
	self.btnType = btnType
	self.typeParam = typeParam
	self.typePos = typePos
	self.highlight = highlight
	self.highlightPos = highlightPos
	self.portrait = portrait
	self.portraitPos = portraitPos
	self.framePosition = framePosition
	self.voice=voice
	self.locateDelay=locateDelay
	self.ModulePath=ModulePath
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuideCls:InitControls()
	local transform = self:GetUnityTransform()
	self.ScreenMaxButton = transform:Find('Tips/ButtonParent/ScreenMaxButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ScreenSelectButton = transform:Find('Tips/ButtonParent/ScreenSelectButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Finger = transform:Find('Finger')
	self.Tips = transform:Find('Tips')
	
	self.TranslucentLayerGroup = {}
	for i = 1, 5 do
		self.TranslucentLayerGroup[i] = transform:Find('TranslucentLayerGroup/TranslucentLayer'..i)
	end

	self.PortraitGroup = {}
	self.Portrait = {}
	self.TextLabel = {}
	for i=1,3 do
		self.PortraitGroup[i] = transform:Find('Tips/Position'..i)
		self.Portrait[i] = transform:Find('Tips/Position'..i..'/Guide/SkeletonGraphic (ytsn)')--:GetComponent(typeof(UnityEngine.UI.Image))
		if i==1 then
			self.TextGroup = {}
			self.TextLabel[i] = {}
			for j=1,4 do
				self.TextGroup[j] = transform:Find('Tips/Position'..i..'/TextPosition/Position'..j)
				self.TextLabel[i][j] = transform:Find('Tips/Position'..i..'/TextPosition/Position'..j..'/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
			end
		else
			self.TextLabel[i] = transform:Find('Tips/Position'..i..'/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		end
	end


end


local function StopGameSound(self)
	local audioManager = self:GetAudioManager()
	audioManager:StopME()
end

local function PlayGameSound(self)
	local voiceId = tonumber(self.voice)
	if type(voiceId) == "number" and voiceId > 0 then
		local audioManager = self:GetAudioManager()
		audioManager:PlayME(voiceId)
	end
end

local function OnGuideContinue(self)
	if self.btnType == kDynamicBtn then
		self.Finger.gameObject:SetActive(true)
		-- self.ScreenSelectButton.gameObject:SetActive(true)
		-- self.ScreenMaxButton.gameObject:SetActive(false)
	else
		self.Finger.gameObject:SetActive(false)
		-- self.ScreenSelectButton.gameObject:SetActive(false)
		-- self.ScreenMaxButton.gameObject:SetActive(true)
	end

	print("目标button >>",self.stepBtn ~= nil)

	if ((self.btnType == kDynamicBtn) and (self.stepBtn ~= nil)) then
		local btnPosition = self.stepBtn.transform.position
		print("目标button btnPosition >>",tostring(btnPosition))
		self.Finger.transform.position = Vector3(btnPosition.x + 4, btnPosition.y - 6, btnPosition.z)
		self.ScreenSelectButton.transform.position = btnPosition
		if self.typePos ~= nil then
			self.ScreenSelectButton.transform:SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, self.typePos[0])
			self.ScreenSelectButton.transform:SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, self.typePos[1])
		end
	end
	
	if self.highlight == kFullMask then
		for i = 1, 4 do
			self.TranslucentLayerGroup[i].gameObject:SetActive(false)
		end
		self.TranslucentLayerGroup[5].gameObject:SetActive(true)
	else
		local idx = 0
		for i = 1, 4 do
			self.TranslucentLayerGroup[i].gameObject:SetActive(true)
			self.TranslucentLayerGroup[i].transform:SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, self.highlightPos[idx])
			self.TranslucentLayerGroup[i].transform:SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, self.highlightPos[idx+1])
			idx = idx + 2
		end
		self.TranslucentLayerGroup[5].gameObject:SetActive(false)
	end

	--停止播放音效
	StopGameSound(self)

	if self.voice~=nil and self.voice~="" then
		PlayGameSound(self)
	end

	
end

local function StopGuideTimeout(self)
	self:StopCoroutine(self.coTimeout)
end

local function OnGuideTimeout(self)
	coroutine.wait(10)
	error("找不到指定的GameObject ===> " .. self.typeParam)
	self.coTimeout = nil
end

local function DelayInitView(self)
	print(self.voice,self.typeParam,"     ++++++++++++++++",self.locateDelay)

	if self.typeParam == '' then
		self.stepBtn = nil
	else
		coroutine.wait(self.locateDelay/100)
		print("目标button",self.typeParam)
		local go
		repeat
			go = UnityUtils:FindGameObject(self.typeParam)
			coroutine.step(1)
		until(go ~= nil)

		self.stepBtn = go:GetComponent(typeof(UnityEngine.UI.Button))
	end
	StopGuideTimeout(self)
	OnGuideContinue(self)
end

local function InitGuideVisible(self)
	if self.btnType == kDynamicBtn then
		--self.Finger.gameObject:SetActive(true)
		self.ScreenSelectButton.gameObject:SetActive(true)
		self.ScreenMaxButton.gameObject:SetActive(false)
	else
		self.Finger.gameObject:SetActive(false)
		self.ScreenSelectButton.gameObject:SetActive(false)
		self.ScreenMaxButton.gameObject:SetActive(true)
	end

	--- ####

	local portraitName = self.portrait
	local groupIndex = self.portraitPos
	local subIndex = self.framePosition
	--self.Tips.gameObject:SetActive(portraitName~='')
	if portraitName~='' then
		for i=1,3 do
			self.PortraitGroup[i].gameObject:SetActive(i==groupIndex)
			if i==groupIndex then
			--	utility.LoadTextureSprite("CardPortrait",portraitName, self.Portrait[i])
			end
		end
		
		if groupIndex==1 then
			for j=1,4 do
				self.TextGroup[j].gameObject:SetActive(j==subIndex)
			end
			self.TextLabel[groupIndex][subIndex].text = self.content
		elseif groupIndex==2 or groupIndex==3 then
			self.TextLabel[groupIndex].text = self.content
		end
	else
		for i=1,3 do
			self.PortraitGroup[i].gameObject:SetActive(false)
		end
		for j=1,4 do
				self.TextGroup[j].gameObject:SetActive(false)
		end
		if groupIndex==1 then
			
			--self.TextLabel[groupIndex][subIndex].text = self.content
		elseif groupIndex==2 or groupIndex==3 then
			--self.TextLabel[groupIndex].text = self.content
		end
	end
end

function GuideCls:InitView()
	StopGuideTimeout(self)
	InitGuideVisible(self)
	self:StartCoroutine(DelayInitView)
	self.coTimeout = self:StartCoroutine(OnGuideTimeout)
end

function GuideCls:RegisterControlEvents()
	-- 注册 ScreenMaxButton 的事件
	self.__event_button_onScreenMaxButtonClicked__ = UnityEngine.Events.UnityAction(self.OnScreenMaxButtonClicked, self)
	self.ScreenMaxButton.onClick:AddListener(self.__event_button_onScreenMaxButtonClicked__)

	-- 注册 ScreenSelectButton 的事件
	self.__event_button_onScreenSelectButtonClicked__ = UnityEngine.Events.UnityAction(self.OnScreenSelectButtonClicked, self)
	self.ScreenSelectButton.onClick:AddListener(self.__event_button_onScreenSelectButtonClicked__)
end

function GuideCls:UnregisterControlEvents()
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

function GuideCls:RegisterNetworkEvents()
end

function GuideCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuideCls:OnScreenMaxButtonClicked()
	print(" $$$$$$$ GuideCls:OnScreenMaxButtonClicked",self.typeParam)
	
	if self.btnType == kDynamicBtn then
		utility.ASSERT(false, "新手引导按钮异常")
		return
	end
	
	print("@@@@ 关闭窗口 >> 1", self,self.btnType)
	self:Close(true)
	
	local guideManager = utility.GetGame():GetGuideManager()
	guideManager:FinishGuideStep()
end

function GuideCls:OnScreenSelectButtonClicked()
	print(" $$$$$$$ GuideCls:OnScreenSelectButtonClicked")
	
	if self.btnType ~= kDynamicBtn then
		utility.ASSERT(false, "新手引导按钮异常")
		return
	end

	print("@@@@ 关闭窗口 >> 2", self)
	self:Close(true)
	
	local guideManager = utility.GetGame():GetGuideManager()
	guideManager:FinishGuideStep()
	
	if self.stepBtn ~= nil then
		self.stepBtn.onClick:Invoke()
	end
	
end

return GuideCls