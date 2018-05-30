require "Class"
require "LUT.ArrayString"
local utility = require "Utils.Utility"

PlayerPrefsUtils = Class()

local function setGuideEvent(evntId, value)
	UnityEngine.PlayerPrefs.SetString(GuideEvent[evntId], value)
end

function PlayerPrefsUtils:ClearGuideEvnt(evntId)
	setGuideEvent(evntId, 0)
end

function PlayerPrefsUtils:SetGuideEvntDone(evntId)
	-- print("@@@@@ PlayerPrefsUtils:SetGuideEvntDone "..evntId)
	setGuideEvent(evntId, GuideEvent[evntId])
end

function PlayerPrefsUtils:IsGuideEvntDone(evntId)
	-- print("@@@@@ PlayerPrefsUtils:IsGuideEvntDone "..GuideEvent[evntId].."   :   "..UnityEngine.PlayerPrefs.GetString(GuideEvent[evntId]))
	return UnityEngine.PlayerPrefs.GetString(GuideEvent[evntId]) == GuideEvent[evntId]
end

local ppu = PlayerPrefsUtils.New()
return ppu