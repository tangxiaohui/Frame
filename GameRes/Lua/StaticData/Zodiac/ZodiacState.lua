require "StaticData.Manager"

ZodiacStateData = Class(LuaObject)

function ZodiacStateData:Ctor(id)
	local zodiacStateDataMgr = Data.ZodiacStates.Manager.Instance()
	self.data = zodiacStateDataMgr:GetObject(id)
	if self.data == nil then
		error(string.format("ZodiacState，ID：%s 不存在",id))
		return
	end
end

function ZodiacStateData:GetPointType()
	return self.data.pointType
end

function ZodiacStateData:GetLimit()
	return self.data.limit
end

function ZodiacStateData:GetPoweType()
	return self.data.poweType
end

function ZodiacStateData:GetPowerNum()
	return self.data.powerNum
end

function ZodiacStateData:GetSoulType()
	return self.data.soulType
end

function ZodiacStateData:GetSoulNum()
	return self.data.soulNum
end

function ZodiacStateData:GetStoneType()
	return self.data.stoneType
end

function ZodiacStateData:GetStoneNum()
	return self.data.stoneNum
end

function ZodiacStateData:GetAllProperties(propertySet)
	propertySet = propertySet or require "Game.Property.PropertySet".New()
	local powerTypes = self:GetPoweType()
	local powerValues = self:GetPowerNum()
	local count = powerTypes.Count - 1
	for i = 0, count do
		local propertyId = powerTypes[i]
		if propertyId > 0 then
			propertySet:AddValue(propertyId, powerValues[i])
		end
	end
	return propertySet
end

ZodiacStateDataManager = Class(DataManager)

local zodiacStateDataMgr = ZodiacStateDataManager.New(ZodiacStateData)
return zodiacStateDataMgr