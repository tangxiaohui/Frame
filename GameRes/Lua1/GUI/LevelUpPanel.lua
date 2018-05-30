local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
require "LUT.StringTable"

local LevelUpCls = Class(BaseNodeClass)
windowUtility.SetMutex(LevelUpCls, true)

function  LevelUpCls:Ctor()
	
end

function LevelUpCls:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end

function LevelUpCls:OnWillShow(data)
	self.data = data 
end

function  LevelUpCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/Levelup",function(go)
		self:BindComponent(go)
	end)
end

function LevelUpCls:OnComponentReady()
	self:InitControls()
end

function LevelUpCls:OnResume()
	LevelUpCls.base.OnResume(self)
	local guideMgr = utility.GetGame():GetGuideManager()
	
    guideMgr:AddGuideEvnt(kGuideEvnt_LevelUpJump1)
    guideMgr:AddGuideEvnt(kGuideEvnt_LevelUpJump2)
	guideMgr:SortGuideEvnt()
    guideMgr:ShowGuidance()
	self:RegisterControlEvents()
	self:ShowPanel()
end

function LevelUpCls:OnPause()
	LevelUpCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function LevelUpCls:OnEnter()
	LevelUpCls.base.OnEnter(self)
end

function LevelUpCls:OnExit()
	LevelUpCls.base.OnExit(self)
end


function  LevelUpCls:InitControls()
	local transform = self:GetUnityTransform()

	self.statusLayout = transform:Find("StatusLayout")
	self.oldLevel = self.statusLayout:Find("Level/OldLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.newLevel = self.statusLayout:Find("Level/NewLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.oldTili = self.statusLayout:Find("StaminaMax/OldLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.newTili = self.statusLayout:Find("StaminaMax/NewLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.oldHeroLevel = self.statusLayout:Find("HeroLevel/OldLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.newHeroLevel = self.statusLayout:Find("HeroLevel/NewLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.oldEquipLevel = self.statusLayout:Find("EquipLevel/OldLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.newEquipLevel = self.statusLayout:Find("EquipLevel/NewLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.oldFightHero = self.statusLayout:Find("FightHero/OldLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.newFightHero = self.statusLayout:Find("FightHero/NewLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.noticeLabel = transform:Find("NoticeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.noticeTxt = transform:Find("Notice")
	self.conferButton = transform:Find("ConferButton"):GetComponent(typeof(UnityEngine.UI.Button))
end

function LevelUpCls:RegisterControlEvents()
	self._event_button_onConferButtonClicked_ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked,self)
	self.conferButton.onClick:AddListener(self._event_button_onConferButtonClicked_)
end

function LevelUpCls:UnregisterControlEvents()
	if self._event_button_onConferButtonClicked_ then
		self.conferButton.onClick:RemoveListener(self._event_button_onConferButtonClicked_)
		self._event_button_onConferButtonClicked_ = nil
	end
end

function LevelUpCls:OnConferButtonClicked()
	self:SetNewModule()
	self:Close(true)
end

function LevelUpCls:SetNewModule()
	for i=1,#self.id do
		local data = require "StaticData.SystemConfig.SystemBasis":GetData(self.id[i])
		if data:GetRefType() == 1 then
			local windowManager = self:GetGame():GetWindowManager()
    		local windowCls = require "GUI.NewModuleCls"
    		windowManager:Show(windowCls,self.id[i])
		end
	end
end

function LevelUpCls:ShowPanel()
	data = self.data
	self.oldLevel.text = data.oldLevel
	self.newLevel.text = data.nowLevel
	self.oldTili.text = data.oldTili
	self.newTili.text = data.nowTili
	self.oldHeroLevel.text = data.oldLevel
	self.newHeroLevel.text = data.nowLevel
	self.oldEquipLevel.text = data.oldLevel
	self.newEquipLevel.text = data.nowLevel
	local configData = require "StaticData.SystemConfig.FormationConfig"
	local oldMaxCard
	local newMaxCard
	for i=4,1,-1 do
		
		local levelTemp = configData:GetData(i):GetLevel()
		local levelMaxOn = configData:GetData(i):GetMaxCardOn()
		
		if data.oldLevel >= levelTemp then
			oldMaxCard = levelMaxOn		
			break
		end		
	end
	for i=4,1,-1 do
		
		local levelTemp = configData:GetData(i):GetLevel()
		local levelMaxOn = configData:GetData(i):GetMaxCardOn()
		
		if data.nowLevel >= levelTemp then
			newMaxCard = levelMaxOn		
			break
		end		
	end

	self.oldFightHero.text = oldMaxCard
	self.newFightHero.text = newMaxCard
	self:SetNotice()
end

function LevelUpCls:SetNotice()
	local configData = require "StaticData.SystemConfig.SystemBasis"
	local configInfoData = require "StaticData.SystemConfig.SystemBasisInfo"
	local keys = configData:GetKeys()
	self.id = {}
	for i=0,(keys.Length - 1) do
		local data = configData:GetData(keys[i])
		local levelTemp = data:GetMinLevel()
		if levelTemp > self.data.oldLevel and levelTemp <= self.data.nowLevel then
			self.id[#self.id + 1] = data:GetInfo()
		end
	end
	local str = ""
	for i=1,#self.id do
		local info = configInfoData:GetData(self.id[i]):GetName()
		str = str.." "..info
	end
	if str ~= nil and str ~= "" then
		self.noticeLabel.text = str
	else
		self.noticeLabel.text = str
		self.noticeTxt.gameObject:SetActive(false)
	end
end

return LevelUpCls