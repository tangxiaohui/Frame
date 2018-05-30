require "StaticData.Manager"

ZodiacData = Class(LuaObject)

function ZodiacData:Ctor(id)
	local zodiacDataMgr = Data.Zodiac.Manager.Instance()
	self.data = zodiacDataMgr:GetObject(id)
	if self.data == nil then
		error(string.format("Zodiac，ID：%s 不存在",id))
		return
	end
end

function ZodiacData:GetInfo()
	return self.data.info
end

function ZodiacData:GetIcon()
	return self.data.icon
end

function ZodiacData:GetPortrait()
	return self.data.portrait
end

function ZodiacData:GetZodiacPoints()
	return self.data.zodiacPoints
end

ZodiacDataManager = Class(DataManager)

local zodiacDataMgr = ZodiacDataManager.New(ZodiacData)
return zodiacDataMgr