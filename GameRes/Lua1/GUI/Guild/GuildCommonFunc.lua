local utility = require "Utils.Utility"
local PropUtility = require "Utils.PropUtility"
local AtlasesLoader = require "Utils.AtlasesLoader"

local LegionIconData = require "StaticData.LegionIcon"
local LegionLvData = require "StaticData.LegionLv"

local GuildCommonFunc = {}

--function GuildCommonFunc.GetSelfGuildId()
--return self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
--end


function GuildCommonFunc.PrintGuldInfo(ghInfo)
	print("id = "..ghInfo.ghID)
	print("name = "..ghInfo.name)
	print("logoID = "..ghInfo.logoID)
	print("level = "..ghInfo.level)
	print("total = "..ghInfo.total)
	print("exp = "..ghInfo.exp)
	print("act = "..ghInfo.act)
	print("showmsg = "..ghInfo.showmsg)
end


function GuildCommonFunc.GetGuildIconInfo(iconId)
	local iconInfo = LegionIconData:GetData(iconId)

	local unlockLv = iconInfo:GetUnlockLv()

	local colorIndex = iconInfo:GetIconColor()
	local iconColor = PropUtility.GetRGBColorValue(colorIndex)

	local iconType = iconInfo:GetIconType()
	local iconName = iconInfo:GetIcon()
	-- local iconSet
	-- if iconType==1 then
	-- 	iconSet = "EquipWeaponIcon"
	-- elseif iconType==3 then
	-- 	iconSet = "EquipAccessoriesIcon"
	-- end
	-- local iconPath = string.format("UI/Atlases/Icon/%s/%s", iconSet, iconName)
	-- local iconSprite = AtlasesLoader:LoadAtlasSprite(iconPath)

	return iconName, iconColor, unlockLv
end

function GuildCommonFunc.ShowErrorTip(hintStr)
	-- debug_print(type(hintStr))
    local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
    local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(ErrorDialogClass, hintStr)
end

function GuildCommonFunc.TranslateTime(nTime)
	--转换毫秒时间
	local seconds = (nTime - nTime % 1000) / 1000
	local minutes = (seconds - seconds % 60) / 60
	local hours = (minutes - minutes % 60) / 60
	local days = (hours - hours % 24) / 24
	local timeString = ""
	if days>0 then
		timeString = timeString..days..'天'
	end
	if hours>0 then
		timeString = timeString..hours..'小时'
	end
	if minutes>0 then
		timeString = timeString..minutes..'分钟'
	end
	if timeString=="" then
		timeString = '1分钟'
	end
	return timeString
end

return GuildCommonFunc