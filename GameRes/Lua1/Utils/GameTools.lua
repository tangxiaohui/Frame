utility = require "Utils.Utility"
require "Const"
require "LUT.StringTable"

local CustomIconPath = {PlayerIcon = "UI/Atlases/CardHead/",ItemIcon = "UI/Atlases/Icon/ItemIcon/" ,PublicIcon = "UI/Atlases/Icon/",FactoryIcon = "UI/Atlases/Icon/FactoryIcon/"}
local EquipCustomPath = "UI/Atlases/Icon/"
local EquipIconPath = {"EquipWeaponIcon/" , "EquipArmorIcon/" , "EquipAccessoriesIcon/" ,"EquipShoesrIcon/",
						"EquipWingIcon/","EquipSparIcon/","EquipFashionIcon/",
						"PublicIcon/","EquipPetIcon/","EquipGemIcon/" }

-- 装备标签路径Ga
local FixedEquipTagImagePath = "UI/Atlases/CardInfo/"
local EquipTagImagePath = {
		"Icon_dj_wuqi","Icon_dj_fangqu","Icon_dj_shiping","Icon_dj_xuezhi","Icon_dj_chibang","Icon_dj_jingshi","Icon_dj_shizhuang",
		"Icon_dj_xunzhang","Icon_dj_chongwu","Icon_dj_baoshi","TagIcon_Items"}
-- 皮肤头像路径
local skinHeadIconPath = "UI/Atlases/SkinHead/"

local GameTools = {}

---------------------------------------------------------------
------------------获取装备物品数据-------------------------------
---------------------------------------------------------------
local  function GetRoleInfoById(id)
	local tempId = require"StaticData.Role":GetData(id):GetInfoId()
	local RoleInfoData = require"StaticData.RoleInfo":GetData(tonumber(tempId))
	local RoleData = require"StaticData.Role":GetData(id)
	return RoleInfoData,RoleData
end

local  function GetEquipInfoById(id)
	local tempEquipId = require"StaticData.Equip":GetData(id):GetInfo()
	local EquipInfoData = require"StaticData.EquipInfo":GetData(tempEquipId)
	local EquipData = require"StaticData.Equip":GetData(id)
	return EquipInfoData,EquipData
end

local  function GetItemInfoById(id)
	local tempItemId = require"StaticData.Item":GetData(id):GetInfo()
	local ItemInfoData = require"StaticData.ItemInfo":GetData(tempItemId)
	local ItemData = require"StaticData.Item":GetData(id)
	return ItemInfoData,ItemData
end

local  function GetRoleInfoByRoleCrap(id)
	local tempRoleCrapId = require"StaticData.RoleCrap":GetData(id):GetRoleId()
	local RoleInfoData,RoleData = GetRoleInfoById(tempRoleCrapId)
	return RoleInfoData,RoleData
end

local  function GetEquipCrapByEquipCrap(id)
	local tempEquipCrapId = require"StaticData.EquipCrap":GetData(id):GetEquipid()
	local EquipInfoData,EquipData = GetEquipInfoById(tempEquipCrapId)
	return EquipInfoData,EquipData
end

local  function GetFactoryItemInfoById(id)
	local FactoryItemData = require"StaticData.FactoryItem":GetData(id)
	local tempItemInfoId = FactoryItemData:GetInfo()
	local FactoryItemInfoData = require"StaticData.FactoryItemInfo":GetData(tempItemInfoId)
	return FactoryItemInfoData,FactoryItemData
end

local function GetCardSkinInfoById(id)
	local skinData = require"StaticData.CardSkin.Skin":GetData(id)
	local infoData = skinData:GetInfoData()
	return infoData,skinData
end

local function GetRoleIconPath(iconName)
	return iconName
	-- local path = CustomIconPath.PlayerIcon..iconName
	-- return path
end

local function GetItemIconPath(iconName)
	local path = CustomIconPath.ItemIcon..iconName
	return path
end

local function GetFactoryIconIconPath(iconName)
	local path = CustomIconPath.FactoryIcon..iconName
	return path
end


local function GetEquipIconPath(iconName,iconType)
	local tempType 
	if iconType == 10 then
		tempType = 9
	elseif iconType == 20 then
		tempType = 10
	else 
		tempType = iconType
	end

	local path = string.format("%s%s%s",EquipCustomPath,EquipIconPath[tempType],iconName)

	return path
end

local function GetCardSkinIconPath(iconName)
	return string.format("%s%s",skinHeadIconPath,iconName)
end

------------------------------------------------------------------------------
--------------对外调用-------------------------------------------------
------------------------------------------------------------------------------
function GameTools.GetItemDataById(id)
	local modV = math.floor(id/100000)
	local infData
	local data
	local itemType
	local itemName
	local iconName
	local iconPath
	local iconType

	if modV == 100 then
		infData,data = GetRoleInfoById(id)
		itemType = "Role"
		itemName = infData:GetName()
		iconName = data:GetHeadIcon()
		iconPath = GetRoleIconPath(iconName)
		return infData,data,itemName,iconPath,itemType
	elseif modV == 101 then
		infData,data = GetEquipInfoById(id)
		itemType = "Equip"
		itemName = infData:GetName()
		iconName = data:GetIcon()
		iconType = data:GetType()
		iconPath = GetEquipIconPath(iconName,iconType) 
		return infData,data,itemName,iconPath,itemType
	elseif modV == 103 then
		infData,data = GetItemInfoById(id)
		itemType = "Item"
		itemName = infData:GetName()
		iconName = data:GetResourceID()
		iconPath = GetItemIconPath(iconName)
		return infData,data,itemName,iconPath,itemType
	elseif modV == 104 then
		infData,data = GetItemInfoById(id)
		itemType = "Item"
		itemName = infData:GetName()
		iconName = data:GetResourceID()
		iconPath = GetItemIconPath(iconName)
		return infData,data,itemName,iconPath,itemType
	elseif modV == 105 then
		infData,data = GetRoleInfoByRoleCrap(id)
		itemType = "RoleChip"
		itemName = infData:GetName()
		iconName = data:GetHeadIcon()
		iconPath = GetRoleIconPath(iconName)
		return infData,data,itemName,iconPath,itemType
	elseif modV == 106 then
		infData,data = GetEquipCrapByEquipCrap(id)
		itemType = "EquipChip"
		itemName = infData:GetName()
		iconName = data:GetIcon()
		iconType = data:GetType()
		iconPath = GetEquipIconPath(iconName,iconType) 
		return infData,data,itemName,iconPath,itemType
	elseif modV == 108 then
		print("物品类型108")
	elseif modV == 109 then
		infData,data = GetCardSkinInfoById(id)
		itemName = data:GetName()
		iconName = data:GetSkinicon()
		iconPath = iconName
		itemType = "CardSkin"
		return infData,data,itemName,iconPath,itemType
	elseif modV == 111 then
		infData,data = GetFactoryItemInfoById(id)
		itemType = "FactoryItem"
		itemName = infData:GetName()
		iconName = data:GetIconInRepair()
		iconPath = GetFactoryIconIconPath(iconName)
		return infData,data,itemName,iconPath,itemType
	end

	error("----物品类型错误----")
	return nil
end


-----------------------------------------------------------
-- *对外调用 加载图片 arg1: 图片Image  arg1: 图片路径 
-- function GameTools.OnLoadSprite(image,imagePath)
	-- local platform = utility.GetPlatform()
	-- local IconSprite = nil
	-- local iconAtlas = "PublicIcon"
	-- if platform == "Android" then
		-- local imageRGBPath = utility.GetRGBPath(imagePath)
		-- local imageAlphaPath = utility.GetAlphaPath(imagePath)
		-- local iconRGBAtlas = utility.GetRGBName(iconAtlas)
		-- local iconAlphaAtlas = utility.GetAlphaName(iconAtlas)
		-- IconSprite = GameTools.GetSprite(imageRGBPath,iconRGBAtlas)
		-- if imageAlphaPath ~= nil and iconAlphaAtlas ~= nil then
			-- image.secondSprite = GameTools.GetSprite(imageAlphaPath,iconAlphaAtlas)
		-- end
	-- else
		-- IconSprite = GameTools.GetSprite(imagePath,iconAtlas)
	-- end
	 -- image.sprite = IconSprite
-- end

function GameTools.GetSprite(imagePath,PublicIcon)
	local spriteLoader = require "Utils.AtlasesLoader"
	IconSprite = spriteLoader:LoadAtlasSprite(imagePath)
	 	
	if IconSprite == nil then
	 	
		local temp = utility.Split(imagePath, '/')
		local path = string.format("UI/Atlases/Icon/"..PublicIcon.."/%s",temp[#temp])
		IconSprite = spriteLoader:LoadAtlasSprite(path)
	end
	return IconSprite
end

-- function GameTools.OnLoadChanllgeSprite(image,imagePath)
	-- local platform = utility.GetPlatform()
	-- local IconSprite = nil
	-- local iconAtlas = "Challenge"
	-- if platform == "Android" then
		-- local imageRGBPath = utility.GetRGBPath(imagePath)
		-- local imageAlphaPath = utility.GetAlphaPath(imagePath)
		-- local iconRGBAtlas = utility.GetRGBName(iconAtlas)
		-- local iconAlphaAtlas = utility.GetAlphaName(iconAtlas)
		-- IconSprite = GameTools.GetSprite(imageRGBPath,iconRGBAtlas)
		-- if imageAlphaPath ~= nil and iconAlphaAtlas ~= nil then
			-- image.secondSprite = GameTools.GetSprite(imageAlphaPath,iconAlphaAtlas)
		-- end
	-- else
		-- IconSprite = GameTools.GetSprite(imagePath,iconAtlas)
	-- end
	 
	 -- image.sprite = IconSprite
-- end


function GameTools.GetItemColorByType(itemType,data)
	local color
	if itemType == "Role" or  itemType == "Equip" or itemType == "RoleChip" or  itemType == "EquipChip" then
		color = data:GetColorID()
		return color
	elseif itemType == "Item" or itemType == "FactoryItem" or itemType == "CardSkin" then
		color = data:GetColor()
		return color
	end
end

local starPath3 = "UI/Atlases/CardInfo/3Star"
local starPath4 = "UI/Atlases/CardInfo/4Star"
local starPath5 = "UI/Atlases/CardInfo/5Star"
local starTable = {starPath3,starPath3,starPath3,starPath4,starPath5}

function GameTools.AutoSetRoleStar(parentTransform,star)
	local count = parentTransform.childCount
	local spriteLoader = require "Utils.AtlasesLoader"
	local IconSprite
	local path
	if star > 0 then
		path = starTable[star]
	end
	
    for i = 0, count - 1 do
        local isShow =  (i <= (star-1) )
        local child = parentTransform:GetChild(i)
        child.gameObject:SetActive(isShow)
        if isShow then
			local image = child:GetComponent(typeof(UnityEngine.UI.Image))
			utility.LoadSpriteFromPath(path,image)
        end
    end
end

function GameTools.AutoSetStar(parentTransform,star)
    local count = parentTransform.childCount
    for i = 0, count - 1 do
        local isShow =  (i <= (star-1) )
        parentTransform:GetChild(i).gameObject:SetActive(isShow)
    end	
end
----获取一周的第几天-----------
function GameTools.AutoWeedDay()
   local day= os.date("%w") 
   return  tonumber(day)
	
end

--- 获取装备的标签路径
function GameTools.GetEquipTagImagePath(ItemType)
	local tempType 
	if ItemType == KEquipType_EquipPet then
		tempType = 9
	elseif ItemType == KEquipType_EquipGem then
		tempType = 10
	else 
		tempType = ItemType
	end
 
	local path = string.format("%s%s",FixedEquipTagImagePath,EquipTagImagePath[tempType])
	return path
end

function GameTools.UpdatePropValue(key,value)
	-- 判断是否为百分比
  	local temp
  	if value < 1 and value ~= 0 then
  		value = string.format("%.1f",value)
  	end

	if key == kPropertyID_HpLimitRate or key == kPropertyID_DpRate or key == kPropertyID_ApRate or 
    	key == kPropertyID_CritRate or key == kPropertyID_DecritRate or key == kPropertyID_HitRate or 
    	key == kPropertyID_AvoidRate or key == kPropertyID_CritDamageRate then    
    	temp = value.."%" 
 	else
    	temp = value
  	end

  	return temp
end

function GameTools.GetEquipInfoStr(dict,mainId)
	-- 获得装备的属性
		
	local leftStr = ""
	local rightStr = ""
	-- 主属性
	local mainStr

	-- 下一个字符串位置
	local leftcount = 0
	local rightcount = 0
	

	-- 固定Str
	local fixedStr
 	local fixedAddStr = EquipStringTable[0]
  	local fixedSubStr = EquipStringTable[16]
	local keys = dict:GetKeys()
	
	for i = 1 ,#keys do

		local key = keys[i]
		local additionValue = dict:GetEntryByKey(key)

		local tempStr = EquipStringTable[key]
    	if additionValue >= 0 then
      		fixedStr = fixedAddStr
   		else
      		fixedStr = fixedSubStr
    	end
    	additionValue = GameTools.UpdatePropValue(key,additionValue)
		local tempHintStr = string.format(fixedStr,tempStr,additionValue)
		
		if key == mainId then
			mainStr = tempHintStr
			leftStr = string.format("%s%s",tempHintStr,leftStr)
			leftcount = leftcount + 1
		else
			if  leftcount <= rightcount then
				leftStr = string.format("%s%s",leftStr,tempHintStr)
				leftcount = leftcount + 1
			else
				rightStr = string.format("%s%s",rightStr,tempHintStr)
				rightcount = rightcount + 1
			end
		end
	end

	return leftStr,rightStr,mainStr
end

function GameTools.GetEquipPrivateInfoStr(id)
	-- 获取装备专属加成
	
	local str = ""
	local staticData = require "StaticData.Equip":GetData(id)
 	-- 是否有种族加成
  	local raceAdd = staticData:GetRaceAdd()
  	if raceAdd ~= 0 then
    	local raceStaticData = require "StaticData.EquipRace":GetData(id)
    	local raceID = raceStaticData:GetRaceID()
    	local raceName = Race[raceID]
    	local addPropID = raceStaticData:GetAddPropID()
    	local propName = EquipStringTable[addPropID]
    	local value = raceStaticData:GetAddPropValue()
    	local propValue = GameTools.UpdatePropValue(addPropID,value)
    	local tempStr = string.format(EquipStringTable[27],raceName,propName,propValue)
   		str = string.format("%s%s",str,tempStr)
  	end

	-- 是否有羁绊英雄
  	local comrade = staticData:GetZhuanyou()
  	if comrade ~= 0 then
    	local comradeStaticData = require "StaticData.EquipExclusive":GetData(id)
    	local jibanCardID = comradeStaticData:GetJibanCardID()

    	local nameStr = ""
    	local roleInfoStaticDataCls = require "StaticData.RoleInfo"

    	for i = 0 ,jibanCardID.Count -1 do
    		print("是否有羁绊英雄",jibanCardID[i])
      		local name = roleInfoStaticDataCls:GetData(jibanCardID[i]):GetName()
      		nameStr = string.format("%s%s",nameStr,name)
      
      		if i < jibanCardID.Count -1 then
        		nameStr = string.format("%s%s",nameStr,",")
      		end
    	end

    	local addPropID = comradeStaticData:GetJibanAddPropID()
    	local addPropStr = EquipStringTable[addPropID]
    	local addValue = comradeStaticData:GetAddPropValue()
    	local tempStr = string.format(EquipStringTable[27],nameStr,addPropStr,addValue)
	    str = string.format("%s%s",str,tempStr)
  	end

  	-- 是否禁止怒气释放
 	local stopJigong = staticData:GetStopJigong()
  	if stopJigong ~= 0 then
    	local tempStr = EquipStringTable[30]
    	str = string.format("%s%s",str,tempStr)
  	end

  	return str
end

function GameTools.GetMajorAttrColor(attr)
	-- 力&敏&智 --
	if attr == 0 then
		-- 255, 74, 0, 255
		return UnityEngine.Color(1, 0.29020, 0, 1)
	elseif attr == 1 then
		-- 50, 212, 0, 255
		return UnityEngine.Color(0.19608, 0.83137, 0, 1)
	elseif attr == 2 then
		-- 0, 180, 255, 255
		return UnityEngine.Color(0, 0.70588, 1, 1)
	else
		-- default
		return UnityEngine.Color(0, 0, 0, 1)
	end
end

local star4ColorTop = UnityEngine.Color(1,0.941176,0.862745,1)
local star4ColorDown = UnityEngine.Color(0.2745098,0.627450,0.901960,1)
local star5ColorTop = UnityEngine.Color(1,0.941176,0.509803,1)
local star5ColorDown = UnityEngine.Color(0.941176,0.823529,0,1)
function GameTools.SetGradientColor(target,star)
	if star ~= nil then
		local gradient = target.transform:GetComponent(typeof(UnityEngine.UI.GradientVertical))
		if star >= 4 then
			gradient.enabled = true
			local top
			local down
			if star == 5 then
				top = star5ColorTop
				down = star5ColorDown
			else
				top = star4ColorTop
				down = star4ColorDown
			end		
			gradient.topColor = top
			gradient.bottomColor = down
		else
			gradient.enabled = false
		end
	end
end

function GameTools.SetRoleCardName(portraitName,CHNNameImage,JPNameImage,star)
	local utility = require "Utils.Utility"

	if JPNameImage ~= nil then
		utility.LoadAtlasesSprite(
			"BattleCardName",
			portraitName,
			JPNameImage
		)
		JPNameImage:SetNativeSize()
	end

	if CHNNameImage ~= nil then
		utility.LoadAtlasesSprite(
			"CardChName",
			portraitName,
			CHNNameImage
		)
		CHNNameImage:SetNativeSize()
	end
end

function GameTools.ShowItemWin(id,canUse)
	local windowManager = utility:GetGame():GetWindowManager()
	local _,_,_,_,itype = GameTools.GetItemDataById(id)

	if itype == "Equip" then
    	windowManager:Show(require "GUI.GeneralEquip.EquipOnlyDisWin",id)
	elseif itype == "Role" then
		windowManager:Show(require "GUI.Collection.CollectionCardInfo",id)
	else
		windowManager:Show(require "GUI.CommonItemWin",id,canUse)
	end
end

function GameTools.GetItemWin(id)
	local windowManager = utility:GetGame():GetWindowManager()
	local _,_,_,_,itype = GameTools.GetItemDataById(id)

	if itype == "Equip" then
    	windowManager:Show(require "GUI.GeneralEquip.EquipOnlyDisWin",id,true)
	elseif itype == "Role" then
		windowManager:Show(require "GUI.GeneralCard.GetCardWin",id)
	else
		windowManager:Show(require "GUI.CommonItemWin",id)
	end
end

function GameTools.ShowGotEquipOrCardWindow(id)
	local windowManager = utility:GetGame():GetWindowManager()
	local _,_,_,_,itype = GameTools.GetItemDataById(id)

	if itype == "Equip" then
    	windowManager:Show(require "GUI.GeneralEquip.EquipOnlyDisWin",id,true)
		return true
	elseif itype == "Role" then
		windowManager:Show(require "GUI.GeneralCard.GetCardWin",id)
		return true
	end

	return false
end

local typePath = {"UI/Atlases/CardInfo/STR","UI/Atlases/CardInfo/AGI","UI/Atlases/CardInfo/INT"}
function GameTools.GetMajorAttrImagePath(major)
	return typePath[major+1]
end

local itemEffectPath = {"Effect/Effects/UI/UI_zhuangbei_lv","Effect/Effects/UI/UI_zhuangbei_lan","Effect/Effects/UI/UI_zhuangbei_zi","Effect/Effects/UI/UI_zhuangbei_cheng"}
function GameTools.GetItemEffectPath(color)
	return itemEffectPath[color]
end

local defautColor = UnityEngine.Color(0.501960,0.501960,0.501960,1)
local greenColor = UnityEngine.Color(0.176470,0.960784,0.529411,1)
local blueColor = UnityEngine.Color(0,0.12156,1,1)
local purpleColor = UnityEngine.Color(0.725490,0.078431,0.921568,1)
local orangeColor = UnityEngine.Color(1, 0.49411, 0, 1)
local colorTable = {defautColor,greenColor,blueColor,purpleColor,orangeColor}
function GameTools.GetBackLightColor(color)
	return colorTable[color + 1]
end

function GameTools.GetGrayColor()
	return UnityEngine.Color(0.494117,0.494117,0.494117,1)
end

function GameTools.AddItemEffect(color,parent,func)
	local PropUtility = require "Utils.PropUtility"
	local c = PropUtility.GetColorValue(color)
	local path = "UI/Prefabs/ItemEffect"
	utility.LoadNewGameObjectAsync(path, function(go)
			go.transform:SetParent(parent.transform)
			local img = go.transform:GetComponent(typeof(UnityEngine.UI.Image))
			img.color = c
			go.transform.localPosition = Vector3(0,0,0)
			go.transform.localScale = Vector3(1,1,1)
			if func ~= nil then
				func(go)
			end
		end)
end

return GameTools