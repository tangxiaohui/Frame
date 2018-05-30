require "StaticData.Manager"

ZodiacDrawData = Class(LuaObject)

function ZodiacDrawData:Ctor(id)
	local zodiacDrawDataMgr = Data.ZodiacDraw.Manager.Instance()
	self.data = zodiacDrawDataMgr:GetObject(id)
	if self.data == nil then
		error(string.format("ZodiacDraw，ID：%s 不存在",id))
		return
	end
end

function ZodiacDrawData:GetNeedType()
	return self.data.needType
end

function ZodiacDrawData:GetNeedNum()
	return self.data.needNum
end

function ZodiacDrawData:GetFreetimes()
	return self.data.freetimes
end

function ZodiacDrawData:GetDrawBag()
	return self.data.drawBag
end

ZodiacDrawDataManager = Class(DataManager)

local zodiacDrawDataMgr = ZodiacDrawDataManager.New(ZodiacDrawData)
return zodiacDrawDataMgr