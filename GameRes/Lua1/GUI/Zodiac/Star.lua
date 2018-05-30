local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "LUT.StringTable"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local StarCls = Class(BaseNodeClass)

function StarCls:Ctor(zodiac)
	self.zodiac = zodiac
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function StarCls:OnInit()
	-- 加载界面(只走一次)
	debug_print("*****************@@ ", self.zodiac:GetZodiacData():GetPortrait())
	utility.LoadNewGameObjectAsync(self.zodiac:GetZodiacData():GetPortrait(), function(go)
		self:BindComponent(go)
	end)
end

function StarCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function StarCls:OnResume()
	-- 界面显示时调用
	StarCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function StarCls:OnPause()
	-- 界面隐藏时调用
	StarCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function StarCls:OnEnter()
	-- Node Enter时调用
	StarCls.base.OnEnter(self)
end

function StarCls:OnExit()
	-- Node Exit时调用
	StarCls.base.OnExit(self)
end

local function ShowLastClick(self, i1, i2)
	if self.lastClickedSpot ~= nil then
		self.lastClickedSpot.selected.gameObject:SetActive(false)
	end
	self.lastClickedSpot = self.star[i1].spot[i2]
	self.lastClickedSpot.selected.gameObject:SetActive(true)
end

local function InitViews(self)
	for i = 1, 5 do
		for j = 0, 5 do
			self.star[i].spot[j].prepared.gameObject:SetActive(false)
			self.star[i].spot[j].notPrepared.gameObject:SetActive(false)
			self.star[i].spot[j].done.gameObject:SetActive(false)
			self.star[i].spot[j].selected.gameObject:SetActive(false)
		end
	end
	
	local activedSpots = self.zodiac:GetActivedSpots()
	local activedSpotsArray = {}
	if activedSpots ~= nil then
		for i, v in ipairs(activedSpots) do
			activedSpotsArray[v] = 0
		end
	end
	local zodiacStateMgr = require "StaticData.Zodiac.ZodiacState"
	local found = false
	for i = 1, 5 do
		local bigSpotIndex = (i - 1) * 6
		local bigSpotId = self.zodiac:GetZodiacData():GetZodiacPoints():get_Item(bigSpotIndex)
		local bigSpotState = zodiacStateMgr:GetData(bigSpotId)
		local bigSpotUnlock = false
		if (activedSpots ~= nil) and (activedSpotsArray[bigSpotId]) ~= nil then
			self.star[i].spot[0].done.gameObject:SetActive(true)
			bigSpotUnlock = true
		else
			if self.zodiac:GetLv() < bigSpotState:GetLimit() then
				self.star[i].spot[0].notPreparedTxt.text = string.format(ZodiacString[0], bigSpotState:GetLimit())
				self.star[i].spot[0].notPrepared.gameObject:SetActive(true)
			else
				self.star[i].spot[0].prepared.gameObject:SetActive(true)
			end
			
			if not found then
				found = true
				ShowLastClick(self, i, 0)
				self.zodiac:SelectSpot(bigSpotId, bigSpotState, self.zodiac:GetLv() >= bigSpotState:GetLimit())
			end
		end
		
		for j = 1, 5 do
			if bigSpotUnlock then
				local smallSpotIndex = bigSpotIndex + j
				local smallSpotId = self.zodiac:GetZodiacData():GetZodiacPoints():get_Item(smallSpotIndex)
				local smallSpotState = zodiacStateMgr:GetData(smallSpotId)
				if (activedSpots ~= nil) and (activedSpotsArray[smallSpotId]) ~= nil then
					self.star[i].spot[j].done.gameObject:SetActive(true)
				else
					self.star[i].spot[j].prepared.gameObject:SetActive(true)
					if not found then
						found = true
						ShowLastClick(self, i, j)
						self.zodiac:SelectSpot(smallSpotId, smallSpotState, true)
					end
				end
			else
				self.star[i].spot[j].notPrepared.gameObject:SetActive(true)
			end
		end
	end
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function StarCls:InitControls()
	local transform = self:GetUnityTransform()
	transform:SetParent(self.zodiac:GetZodiacPoint())
	
	self.star = {}
	for i = 1, 5 do
		self.star[i] = {}
		local name = "Point"..i
		self.star[i].base = transform:Find(name)
		self.star[i].spot = {}
		self.star[i].spot[0] = {}
		self.star[i].spot[0].base = transform:Find(name.."/Big")
		self.star[i].spot[0].prepared = transform:Find(name.."/Big/Prepared")
		self.star[i].spot[0].preparedBtn = transform:Find(name.."/Big/Prepared/Image"):GetComponent(typeof(UnityEngine.UI.Button))
		self.star[i].spot[0].notPrepared = transform:Find(name.."/Big/NotPrepared")
		self.star[i].spot[0].notPreparedTxt = transform:Find(name.."/Big/NotPrepared/LevelNum"):GetComponent(typeof(UnityEngine.UI.Text))
		self.star[i].spot[0].notPreparedBtn = transform:Find(name.."/Big/NotPrepared/Image"):GetComponent(typeof(UnityEngine.UI.Button))
		self.star[i].spot[0].done = transform:Find(name.."/Big/Done")
		self.star[i].spot[0].selected = transform:Find(name.."/Big/Select")
		for j = 1, 5 do
			local subName = "/Small"..j
			self.star[i].spot[j] = {}
			self.star[i].spot[j].base = transform:Find(name..subName)
			self.star[i].spot[j].prepared = transform:Find(name..subName.."/Prepared")
			self.star[i].spot[j].preparedBtn = transform:Find(name..subName.."/Prepared/Image"):GetComponent(typeof(UnityEngine.UI.Button))
			self.star[i].spot[j].notPrepared = transform:Find(name..subName.."/NotPrepared")
			self.star[i].spot[j].notPreparedBtn = transform:Find(name..subName.."/NotPrepared/Image"):GetComponent(typeof(UnityEngine.UI.Button))
			self.star[i].spot[j].done = transform:Find(name..subName.."/Done")
			self.star[i].spot[j].selected = transform:Find(name..subName.."/Select")
		end
	end
	
	InitViews(self)
	self.myGame = utility:GetGame()
end

local function GetSpotState(self, index)
	local zodiacStateMgr = require "StaticData.Zodiac.ZodiacState"
	local spotId = self.zodiac:GetZodiacData():GetZodiacPoints():get_Item(index)
	local spotState = zodiacStateMgr:GetData(spotId)
	return spotId, spotState
end

function StarCls:OnSpot_10_PreparedClicked()
	ShowLastClick(self, 1, 0)
	local id, state = GetSpotState(self, 0)
	self.zodiac:SelectSpot(id, state, true)
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[6].systemGuideID,self)

end

function StarCls:OnSpot_10_NotPreparedClicked()
	ShowLastClick(self, 1, 0)
	local id, state = GetSpotState(self, 0)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_11_PreparedClicked()
	ShowLastClick(self, 1, 1)
	local id, state = GetSpotState(self, 1)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_11_NotPreparedClicked()
	ShowLastClick(self, 1, 1)
	local id, state = GetSpotState(self, 1)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_12_PreparedClicked()
	ShowLastClick(self, 1, 2)
	local id, state = GetSpotState(self, 2)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_12_NotPreparedClicked()
	ShowLastClick(self, 1, 2)
	local id, state = GetSpotState(self, 2)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_13_PreparedClicked()
	ShowLastClick(self, 1, 3)
	local id, state = GetSpotState(self, 3)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_13_NotPreparedClicked()
	ShowLastClick(self, 1, 3)
	local id, state = GetSpotState(self, 3)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_14_PreparedClicked()
	ShowLastClick(self, 1, 4)
	local id, state = GetSpotState(self, 4)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_14_NotPreparedClicked()
	ShowLastClick(self, 1, 4)
	local id, state = GetSpotState(self, 4)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_15_PreparedClicked()
	ShowLastClick(self, 1, 5)
	local id, state = GetSpotState(self, 5)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_15_NotPreparedClicked()
	ShowLastClick(self, 1, 5)
	local id, state = GetSpotState(self, 5)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_20_PreparedClicked()
	ShowLastClick(self, 2, 0)
	local id, state = GetSpotState(self, 6)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_20_NotPreparedClicked()
	ShowLastClick(self, 2, 0)
	local id, state = GetSpotState(self, 6)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_21_PreparedClicked()
	ShowLastClick(self, 2, 1)
	local id, state = GetSpotState(self, 7)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_21_NotPreparedClicked()
	ShowLastClick(self, 2, 1)
	local id, state = GetSpotState(self, 7)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_22_PreparedClicked()
	ShowLastClick(self, 2, 2)
	local id, state = GetSpotState(self, 8)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_22_NotPreparedClicked()
	ShowLastClick(self, 2, 2)
	local id, state = GetSpotState(self, 8)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_23_PreparedClicked()
	ShowLastClick(self, 2, 3)
	local id, state = GetSpotState(self, 9)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_23_NotPreparedClicked()
	ShowLastClick(self, 2, 3)
	local id, state = GetSpotState(self, 9)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_24_PreparedClicked()
	ShowLastClick(self, 2, 4)
	local id, state = GetSpotState(self, 10)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_24_NotPreparedClicked()
	ShowLastClick(self, 2, 4)
	local id, state = GetSpotState(self, 10)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_25_PreparedClicked()
	ShowLastClick(self, 2, 5)
	local id, state = GetSpotState(self, 11)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_25_NotPreparedClicked()
	ShowLastClick(self, 2, 5)
	local id, state = GetSpotState(self, 11)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_30_PreparedClicked()
	ShowLastClick(self, 3, 0)
	local id, state = GetSpotState(self, 12)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_30_NotPreparedClicked()
	ShowLastClick(self, 3, 0)
	local id, state = GetSpotState(self, 12)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_31_PreparedClicked()
	ShowLastClick(self, 3, 1)
	local id, state = GetSpotState(self, 13)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_31_NotPreparedClicked()
	ShowLastClick(self, 3, 1)
	local id, state = GetSpotState(self, 13)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_32_PreparedClicked()
	ShowLastClick(self, 3, 2)
	local id, state = GetSpotState(self, 14)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_32_NotPreparedClicked()
	ShowLastClick(self, 3, 2)
	local id, state = GetSpotState(self, 14)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_33_PreparedClicked()
	ShowLastClick(self, 3, 3)
	local id, state = GetSpotState(self, 15)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_33_NotPreparedClicked()
	ShowLastClick(self, 3, 3)
	local id, state = GetSpotState(self, 15)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_34_PreparedClicked()
	ShowLastClick(self, 3, 4)
	local id, state = GetSpotState(self, 16)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_34_NotPreparedClicked()
	ShowLastClick(self, 3, 4)
	local id, state = GetSpotState(self, 16)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_35_PreparedClicked()
	ShowLastClick(self, 3, 5)
	local id, state = GetSpotState(self, 17)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_35_NotPreparedClicked()
	ShowLastClick(self, 3, 5)
	local id, state = GetSpotState(self, 17)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_40_PreparedClicked()
	ShowLastClick(self, 4, 0)
	local id, state = GetSpotState(self, 18)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_40_NotPreparedClicked()
	ShowLastClick(self, 4, 0)
	local id, state = GetSpotState(self, 18)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_41_PreparedClicked()
	ShowLastClick(self, 4, 1)
	local id, state = GetSpotState(self, 19)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_41_NotPreparedClicked()
	ShowLastClick(self, 4, 1)
	local id, state = GetSpotState(self, 19)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_42_PreparedClicked()
	ShowLastClick(self, 4, 2)
	local id, state = GetSpotState(self, 20)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_42_NotPreparedClicked()
	ShowLastClick(self, 4, 2)
	local id, state = GetSpotState(self, 20)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_43_PreparedClicked()
	ShowLastClick(self, 4, 3)
	local id, state = GetSpotState(self, 21)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_43_NotPreparedClicked()
	ShowLastClick(self, 4, 3)
	local id, state = GetSpotState(self, 21)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_44_PreparedClicked()
	ShowLastClick(self, 4, 4)
	local id, state = GetSpotState(self, 22)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_44_NotPreparedClicked()
	ShowLastClick(self, 4, 4)
	local id, state = GetSpotState(self, 22)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_45_PreparedClicked()
	ShowLastClick(self, 4, 5)
	local id, state = GetSpotState(self, 23)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_45_NotPreparedClicked()
	ShowLastClick(self, 4, 5)
	local id, state = GetSpotState(self, 23)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_50_PreparedClicked()
	ShowLastClick(self, 5, 0)
	local id, state = GetSpotState(self, 24)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_50_NotPreparedClicked()
	ShowLastClick(self, 5, 0)
	local id, state = GetSpotState(self, 24)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_51_PreparedClicked()
	ShowLastClick(self, 5, 1)
	local id, state = GetSpotState(self, 25)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_51_NotPreparedClicked()
	ShowLastClick(self, 5, 1)
	local id, state = GetSpotState(self, 25)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_52_PreparedClicked()
	ShowLastClick(self, 5, 2)
	local id, state = GetSpotState(self, 26)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_52_NotPreparedClicked()
	ShowLastClick(self, 5, 2)
	local id, state = GetSpotState(self, 26)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_53_PreparedClicked()
	ShowLastClick(self, 5, 3)
	local id, state = GetSpotState(self, 27)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_53_NotPreparedClicked()
	ShowLastClick(self, 5, 3)
	local id, state = GetSpotState(self, 27)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_54_PreparedClicked()
	ShowLastClick(self, 5, 4)
	local id, state = GetSpotState(self, 28)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_54_NotPreparedClicked()
	ShowLastClick(self, 5, 4)
	local id, state = GetSpotState(self, 28)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:OnSpot_55_PreparedClicked()
	ShowLastClick(self, 5, 5)
	local id, state = GetSpotState(self, 29)
	self.zodiac:SelectSpot(id, state, true)
end

function StarCls:OnSpot_55_NotPreparedClicked()
	ShowLastClick(self, 5, 5)
	local id, state = GetSpotState(self, 29)
	self.zodiac:SelectSpot(id, state, false)
end

function StarCls:RegisterControlEvents()
	self.btnEvnt_Spot_10_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_10_PreparedClicked, self)
	self.star[1].spot[0].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_10_Prepared)
	
	self.btnEvnt_Spot_10_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_10_NotPreparedClicked, self)
	self.star[1].spot[0].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_10_NotPrepared)
	
	self.btnEvnt_Spot_11_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_11_PreparedClicked, self)
	self.star[1].spot[1].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_11_Prepared)
	
	self.btnEvnt_Spot_11_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_11_NotPreparedClicked, self)
	self.star[1].spot[1].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_11_NotPrepared)
	
	self.btnEvnt_Spot_12_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_12_PreparedClicked, self)
	self.star[1].spot[2].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_12_Prepared)
	
	self.btnEvnt_Spot_12_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_12_NotPreparedClicked, self)
	self.star[1].spot[2].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_12_NotPrepared)
	
	self.btnEvnt_Spot_13_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_13_PreparedClicked, self)
	self.star[1].spot[3].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_13_Prepared)
	
	self.btnEvnt_Spot_13_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_13_NotPreparedClicked, self)
	self.star[1].spot[3].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_13_NotPrepared)
	
	self.btnEvnt_Spot_14_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_14_PreparedClicked, self)
	self.star[1].spot[4].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_14_Prepared)
	
	self.btnEvnt_Spot_14_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_14_NotPreparedClicked, self)
	self.star[1].spot[4].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_14_NotPrepared)
	
	self.btnEvnt_Spot_15_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_15_PreparedClicked, self)
	self.star[1].spot[5].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_15_Prepared)
	
	self.btnEvnt_Spot_15_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_15_NotPreparedClicked, self)
	self.star[1].spot[5].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_15_NotPrepared)
	
	self.btnEvnt_Spot_20_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_20_PreparedClicked, self)
	self.star[2].spot[0].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_20_Prepared)
	
	self.btnEvnt_Spot_20_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_20_NotPreparedClicked, self)
	self.star[2].spot[0].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_20_NotPrepared)
	
	self.btnEvnt_Spot_21_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_21_PreparedClicked, self)
	self.star[2].spot[1].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_21_Prepared)
	
	self.btnEvnt_Spot_21_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_21_NotPreparedClicked, self)
	self.star[2].spot[1].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_21_NotPrepared)
	
	self.btnEvnt_Spot_22_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_22_PreparedClicked, self)
	self.star[2].spot[2].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_22_Prepared)
	
	self.btnEvnt_Spot_22_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_22_NotPreparedClicked, self)
	self.star[2].spot[2].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_22_NotPrepared)
	
	self.btnEvnt_Spot_23_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_23_PreparedClicked, self)
	self.star[2].spot[3].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_23_Prepared)
	
	self.btnEvnt_Spot_23_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_23_NotPreparedClicked, self)
	self.star[2].spot[3].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_23_NotPrepared)
	
	self.btnEvnt_Spot_24_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_24_PreparedClicked, self)
	self.star[2].spot[4].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_24_Prepared)
	
	self.btnEvnt_Spot_24_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_24_NotPreparedClicked, self)
	self.star[2].spot[4].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_24_NotPrepared)
	
	self.btnEvnt_Spot_25_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_25_PreparedClicked, self)
	self.star[2].spot[5].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_25_Prepared)
	
	self.btnEvnt_Spot_25_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_25_NotPreparedClicked, self)
	self.star[2].spot[5].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_25_NotPrepared)
	
	self.btnEvnt_Spot_30_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_30_PreparedClicked, self)
	self.star[3].spot[0].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_30_Prepared)
	
	self.btnEvnt_Spot_30_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_30_NotPreparedClicked, self)
	self.star[3].spot[0].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_30_NotPrepared)
	
	self.btnEvnt_Spot_31_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_31_PreparedClicked, self)
	self.star[3].spot[1].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_31_Prepared)
	
	self.btnEvnt_Spot_31_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_31_NotPreparedClicked, self)
	self.star[3].spot[1].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_31_NotPrepared)
	
	self.btnEvnt_Spot_32_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_32_PreparedClicked, self)
	self.star[3].spot[2].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_32_Prepared)
	
	self.btnEvnt_Spot_32_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_32_NotPreparedClicked, self)
	self.star[3].spot[2].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_32_NotPrepared)
	
	self.btnEvnt_Spot_33_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_33_PreparedClicked, self)
	self.star[3].spot[3].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_33_Prepared)
	
	self.btnEvnt_Spot_33_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_33_NotPreparedClicked, self)
	self.star[3].spot[3].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_33_NotPrepared)
	
	self.btnEvnt_Spot_34_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_34_PreparedClicked, self)
	self.star[3].spot[4].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_34_Prepared)
	
	self.btnEvnt_Spot_34_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_34_NotPreparedClicked, self)
	self.star[3].spot[4].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_34_NotPrepared)
	
	self.btnEvnt_Spot_35_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_35_PreparedClicked, self)
	self.star[3].spot[5].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_35_Prepared)
	
	self.btnEvnt_Spot_35_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_35_NotPreparedClicked, self)
	self.star[3].spot[5].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_35_NotPrepared)
	
	self.btnEvnt_Spot_40_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_40_PreparedClicked, self)
	self.star[4].spot[0].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_40_Prepared)
	
	self.btnEvnt_Spot_40_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_40_NotPreparedClicked, self)
	self.star[4].spot[0].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_40_NotPrepared)
	
	self.btnEvnt_Spot_41_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_41_PreparedClicked, self)
	self.star[4].spot[1].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_41_Prepared)
	
	self.btnEvnt_Spot_41_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_41_NotPreparedClicked, self)
	self.star[4].spot[1].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_41_NotPrepared)
	
	self.btnEvnt_Spot_42_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_42_PreparedClicked, self)
	self.star[4].spot[2].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_42_Prepared)
	
	self.btnEvnt_Spot_42_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_42_NotPreparedClicked, self)
	self.star[4].spot[2].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_42_NotPrepared)
	
	self.btnEvnt_Spot_43_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_43_PreparedClicked, self)
	self.star[4].spot[3].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_43_Prepared)
	
	self.btnEvnt_Spot_43_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_43_NotPreparedClicked, self)
	self.star[4].spot[3].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_43_NotPrepared)
	
	self.btnEvnt_Spot_44_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_44_PreparedClicked, self)
	self.star[4].spot[4].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_44_Prepared)
	
	self.btnEvnt_Spot_44_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_44_NotPreparedClicked, self)
	self.star[4].spot[4].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_44_NotPrepared)
	
	self.btnEvnt_Spot_45_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_45_PreparedClicked, self)
	self.star[4].spot[5].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_45_Prepared)
	
	self.btnEvnt_Spot_45_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_45_NotPreparedClicked, self)
	self.star[4].spot[5].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_45_NotPrepared)
	
	self.btnEvnt_Spot_50_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_50_PreparedClicked, self)
	self.star[5].spot[0].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_50_Prepared)
	
	self.btnEvnt_Spot_50_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_50_NotPreparedClicked, self)
	self.star[5].spot[0].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_50_NotPrepared)
	
	self.btnEvnt_Spot_51_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_51_PreparedClicked, self)
	self.star[5].spot[1].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_51_Prepared)
	
	self.btnEvnt_Spot_51_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_51_NotPreparedClicked, self)
	self.star[5].spot[1].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_51_NotPrepared)
	
	self.btnEvnt_Spot_52_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_52_PreparedClicked, self)
	self.star[5].spot[2].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_52_Prepared)
	
	self.btnEvnt_Spot_52_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_52_NotPreparedClicked, self)
	self.star[5].spot[2].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_52_NotPrepared)
	
	self.btnEvnt_Spot_53_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_53_PreparedClicked, self)
	self.star[5].spot[3].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_53_Prepared)
	
	self.btnEvnt_Spot_53_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_53_NotPreparedClicked, self)
	self.star[5].spot[3].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_53_NotPrepared)
	
	self.btnEvnt_Spot_54_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_54_PreparedClicked, self)
	self.star[5].spot[4].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_54_Prepared)
	
	self.btnEvnt_Spot_54_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_54_NotPreparedClicked, self)
	self.star[5].spot[4].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_54_NotPrepared)
	
	self.btnEvnt_Spot_55_Prepared = UnityEngine.Events.UnityAction(self.OnSpot_55_PreparedClicked, self)
	self.star[5].spot[5].preparedBtn.onClick:AddListener(self.btnEvnt_Spot_55_Prepared)
	
	self.btnEvnt_Spot_55_NotPrepared = UnityEngine.Events.UnityAction(self.OnSpot_55_NotPreparedClicked, self)
	self.star[5].spot[5].notPreparedBtn.onClick:AddListener(self.btnEvnt_Spot_55_NotPrepared)
end

function StarCls:UnregisterControlEvents()
	if self.btnEvnt_Spot_10_Prepared then
		self.star[1].spot[0].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_10_Prepared)
		self.btnEvnt_Spot_10_Prepared = nil
	end
	
	if self.btnEvnt_Spot_10_NotPrepared then
		self.star[1].spot[0].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_10_NotPrepared)
		self.btnEvnt_Spot_10_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_11_Prepared then
		self.star[1].spot[1].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_11_Prepared)
		self.btnEvnt_Spot_11_Prepared = nil
	end
	
	if self.btnEvnt_Spot_11_NotPrepared then
		self.star[1].spot[1].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_11_NotPrepared)
		self.btnEvnt_Spot_11_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_12_Prepared then
		self.star[1].spot[2].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_12_Prepared)
		self.btnEvnt_Spot_12_Prepared = nil
	end
	
	if self.btnEvnt_Spot_12_NotPrepared then
		self.star[1].spot[2].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_12_NotPrepared)
		self.btnEvnt_Spot_12_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_13_Prepared then
		self.star[1].spot[3].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_13_Prepared)
		self.btnEvnt_Spot_13_Prepared = nil
	end
	
	if self.btnEvnt_Spot_13_NotPrepared then
		self.star[1].spot[3].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_13_NotPrepared)
		self.btnEvnt_Spot_13_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_14_Prepared then
		self.star[1].spot[4].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_14_Prepared)
		self.btnEvnt_Spot_14_Prepared = nil
	end
	
	if self.btnEvnt_Spot_14_NotPrepared then
		self.star[1].spot[4].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_14_NotPrepared)
		self.btnEvnt_Spot_14_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_15_Prepared then
		self.star[1].spot[5].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_15_Prepared)
		self.btnEvnt_Spot_15_Prepared = nil
	end
	
	if self.btnEvnt_Spot_15_NotPrepared then
		self.star[1].spot[5].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_15_NotPrepared)
		self.btnEvnt_Spot_15_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_20_Prepared then
		self.star[2].spot[0].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_20_Prepared)
		self.btnEvnt_Spot_20_Prepared = nil
	end
	
	if self.btnEvnt_Spot_20_NotPrepared then
		self.star[2].spot[0].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_20_NotPrepared)
		self.btnEvnt_Spot_20_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_21_Prepared then
		self.star[2].spot[1].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_21_Prepared)
		self.btnEvnt_Spot_21_Prepared = nil
	end
	
	if self.btnEvnt_Spot_21_NotPrepared then
		self.star[2].spot[1].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_21_NotPrepared)
		self.btnEvnt_Spot_21_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_22_Prepared then
		self.star[2].spot[2].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_22_Prepared)
		self.btnEvnt_Spot_22_Prepared = nil
	end
	
	if self.btnEvnt_Spot_22_NotPrepared then
		self.star[2].spot[2].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_22_NotPrepared)
		self.btnEvnt_Spot_22_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_23_Prepared then
		self.star[2].spot[3].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_23_Prepared)
		self.btnEvnt_Spot_23_Prepared = nil
	end
	
	if self.btnEvnt_Spot_23_NotPrepared then
		self.star[2].spot[3].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_23_NotPrepared)
		self.btnEvnt_Spot_23_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_24_Prepared then
		self.star[2].spot[4].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_24_Prepared)
		self.btnEvnt_Spot_24_Prepared = nil
	end
	
	if self.btnEvnt_Spot_24_NotPrepared then
		self.star[2].spot[4].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_24_NotPrepared)
		self.btnEvnt_Spot_24_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_25_Prepared then
		self.star[2].spot[5].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_25_Prepared)
		self.btnEvnt_Spot_25_Prepared = nil
	end
	
	if self.btnEvnt_Spot_25_NotPrepared then
		self.star[2].spot[5].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_25_NotPrepared)
		self.btnEvnt_Spot_25_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_30_Prepared then
		self.star[3].spot[0].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_30_Prepared)
		self.btnEvnt_Spot_30_Prepared = nil
	end
	
	if self.btnEvnt_Spot_30_NotPrepared then
		self.star[3].spot[0].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_30_NotPrepared)
		self.btnEvnt_Spot_30_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_31_Prepared then
		self.star[3].spot[1].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_31_Prepared)
		self.btnEvnt_Spot_31_Prepared = nil
	end
	
	if self.btnEvnt_Spot_31_NotPrepared then
		self.star[3].spot[1].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_31_NotPrepared)
		self.btnEvnt_Spot_31_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_32_Prepared then
		self.star[3].spot[2].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_32_Prepared)
		self.btnEvnt_Spot_32_Prepared = nil
	end
	
	if self.btnEvnt_Spot_32_NotPrepared then
		self.star[3].spot[2].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_32_NotPrepared)
		self.btnEvnt_Spot_32_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_33_Prepared then
		self.star[3].spot[3].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_33_Prepared)
		self.btnEvnt_Spot_33_Prepared = nil
	end
	
	if self.btnEvnt_Spot_33_NotPrepared then
		self.star[3].spot[3].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_33_NotPrepared)
		self.btnEvnt_Spot_33_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_34_Prepared then
		self.star[3].spot[4].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_34_Prepared)
		self.btnEvnt_Spot_34_Prepared = nil
	end
	
	if self.btnEvnt_Spot_34_NotPrepared then
		self.star[3].spot[4].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_34_NotPrepared)
		self.btnEvnt_Spot_34_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_35_Prepared then
		self.star[3].spot[5].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_35_Prepared)
		self.btnEvnt_Spot_35_Prepared = nil
	end
	
	if self.btnEvnt_Spot_35_NotPrepared then
		self.star[3].spot[5].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_35_NotPrepared)
		self.btnEvnt_Spot_35_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_40_Prepared then
		self.star[4].spot[0].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_40_Prepared)
		self.btnEvnt_Spot_40_Prepared = nil
	end
	
	if self.btnEvnt_Spot_40_NotPrepared then
		self.star[4].spot[0].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_40_NotPrepared)
		self.btnEvnt_Spot_40_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_41_Prepared then
		self.star[4].spot[1].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_41_Prepared)
		self.btnEvnt_Spot_41_Prepared = nil
	end
	
	if self.btnEvnt_Spot_41_NotPrepared then
		self.star[4].spot[1].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_41_NotPrepared)
		self.btnEvnt_Spot_41_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_42_Prepared then
		self.star[4].spot[2].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_42_Prepared)
		self.btnEvnt_Spot_42_Prepared = nil
	end
	
	if self.btnEvnt_Spot_42_NotPrepared then
		self.star[4].spot[2].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_42_NotPrepared)
		self.btnEvnt_Spot_42_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_43_Prepared then
		self.star[4].spot[3].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_43_Prepared)
		self.btnEvnt_Spot_43_Prepared = nil
	end
	
	if self.btnEvnt_Spot_43_NotPrepared then
		self.star[4].spot[3].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_43_NotPrepared)
		self.btnEvnt_Spot_43_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_44_Prepared then
		self.star[4].spot[4].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_44_Prepared)
		self.btnEvnt_Spot_44_Prepared = nil
	end
	
	if self.btnEvnt_Spot_44_NotPrepared then
		self.star[4].spot[4].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_44_NotPrepared)
		self.btnEvnt_Spot_44_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_45_Prepared then
		self.star[4].spot[5].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_45_Prepared)
		self.btnEvnt_Spot_45_Prepared = nil
	end
	
	if self.btnEvnt_Spot_45_NotPrepared then
		self.star[4].spot[5].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_45_NotPrepared)
		self.btnEvnt_Spot_45_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_50_Prepared then
		self.star[5].spot[0].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_50_Prepared)
		self.btnEvnt_Spot_50_Prepared = nil
	end
	
	if self.btnEvnt_Spot_50_NotPrepared then
		self.star[5].spot[0].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_50_NotPrepared)
		self.btnEvnt_Spot_50_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_51_Prepared then
		self.star[5].spot[1].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_51_Prepared)
		self.btnEvnt_Spot_51_Prepared = nil
	end
	
	if self.btnEvnt_Spot_51_NotPrepared then
		self.star[5].spot[1].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_51_NotPrepared)
		self.btnEvnt_Spot_51_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_52_Prepared then
		self.star[5].spot[2].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_52_Prepared)
		self.btnEvnt_Spot_52_Prepared = nil
	end
	
	if self.btnEvnt_Spot_52_NotPrepared then
		self.star[5].spot[2].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_52_NotPrepared)
		self.btnEvnt_Spot_52_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_53_Prepared then
		self.star[5].spot[3].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_53_Prepared)
		self.btnEvnt_Spot_53_Prepared = nil
	end
	
	if self.btnEvnt_Spot_53_NotPrepared then
		self.star[5].spot[3].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_53_NotPrepared)
		self.btnEvnt_Spot_53_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_54_Prepared then
		self.star[5].spot[4].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_54_Prepared)
		self.btnEvnt_Spot_54_Prepared = nil
	end
	
	if self.btnEvnt_Spot_54_NotPrepared then
		self.star[5].spot[4].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_54_NotPrepared)
		self.btnEvnt_Spot_54_NotPrepared = nil
	end
	
	if self.btnEvnt_Spot_55_Prepared then
		self.star[5].spot[5].preparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_55_Prepared)
		self.btnEvnt_Spot_55_Prepared = nil
	end
	
	if self.btnEvnt_Spot_55_NotPrepared then
		self.star[5].spot[5].notPreparedBtn.onClick:RemoveListener(self.btnEvnt_Spot_55_NotPrepared)
		self.btnEvnt_Spot_55_NotPrepared = nil
	end
end

function StarCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CCardTheSmallUniverseResult, self, self.OnUnlockSpot)
end

function StarCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CCardTheSmallUniverseResult, self, self.OnUnlockSpot)
end

function StarCls:OnUnlockSpot(msg)
	self.zodiac:UpdateActivedSpots()
	InitViews(self)
end

return StarCls