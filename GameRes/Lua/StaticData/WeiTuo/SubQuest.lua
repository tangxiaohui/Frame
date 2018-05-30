require "StaticData.Manager"

SubQuestData = Class(LuaObject)

function SubQuestData:Ctor(id)
	local zodiacDataMgr = Data.SubQuest.Manager.Instance()
	self.data = zodiacDataMgr:GetObject(id)
	if self.data == nil then
		error(string.format("Zodiac，ID：%s 不存在",id))
		return
	end
end

function SubQuestData:GetId()
	return self.data.id
end
function SubQuestData:GetInfo()
	return self.data.questInfo
end
function SubQuestData:GetOpenLevel()
	return self.data.openLevel
end

function SubQuestData:GetMinCardNum()
	return self.data.minCardNum
end

function SubQuestData:GetTimeRank()
	return self.data.timeRank
end

function SubQuestData:GetTimeRate()
	return self.data.timeRate
end

function SubQuestData:GetVipRank()
	return self.data.vipRank
end

function SubQuestData:GetVipRate()
	return self.data.vipRate
end

function SubQuestData:GetVipExtraRate()
	return self.data.vipExtraRate
end

function SubQuestData:GetVipCost()
	return self.data.vipCost
end

function SubQuestData:GetNormalItem()
	return self.data.normalItem
end

function SubQuestData:GetNormalitemNum()
	return self.data.NormalitemNum
end

function SubQuestData:GetExtraItem()
	return self.data.extraItem
end

function SubQuestData:GetExtraItemNum()
	return self.data.extraItemNum
end
function SubQuestData:GetExtraItemRate()
	return self.data.extraItemRate
end

function SubQuestData:GetMaxExtraNum()
	return self.data.maxExtraNum
end




SubQuestDataManager = Class(DataManager)

local SubQuestDataMgr = SubQuestDataManager.New(SubQuestData)
--获取一共有多少条目
function SubQuestDataMgr:GetKeys()
    return Data.SubQuest.Manager.Instance():GetKeys()
end
return SubQuestDataMgr