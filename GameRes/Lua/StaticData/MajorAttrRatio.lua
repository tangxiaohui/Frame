require "StaticData.Manager"

MajorAttrRatio = Class(LuaObject)

function MajorAttrRatio:Ctor(id)
	local attrMgr = Data.MajorAttrRatio.Manager.Instance()
	self.data = attrMgr:GetObject(id)
	if self.data == nil then
		print(string.format("主属性系数初始化失败，ID: %s 不存在", id))
		return
	end
end

function MajorAttrRatio:ToString()
	return "MajorAttrRatio"
end

function MajorAttrRatio:GetHpRatio()
	return self.data.hp
end

function MajorAttrRatio:GetApRatio()
	return self.data.ap
end

function MajorAttrRatio:GetSpeedRatio()
	return self.data.speed
end

MajorAttrRatioManager = Class(DataManager)

local majorAttrRatioManager = MajorAttrRatioManager.New(MajorAttrRatio)
return majorAttrRatioManager