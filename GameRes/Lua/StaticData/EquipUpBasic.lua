require "StaticData.Manager"

EquipData = Class(LuaObject)

function EquipData:Ctor(id)
    local EquipChainMgr = Data.EquipUpBasic.Manager.Instance()
    self.data = EquipChainMgr:GetObject(id)
    if self.data == nil then
        -- error(string.format("装备进阶颜色，ID: %s 不存在", id))
        return
    end
end

function EquipData:GetID()
	local id
	if self.data ~= nil then
		id = self.data.id
	end
    return id
end

function EquipData:GetColor()
    return self.data.color
end

function EquipData:GetIndexId()
	return self.data.indexId
end

function EquipData:GetEquipUpId(color)
	local colorsData = self.data.color
	local index = self.data.indexId
	local id = nil
	for i=0,colorsData.Count - 1  do
		if colorsData[i] == color then
			id = index[i]
			break
		end
	end
	return id
end

EquipChainManager = Class(DataManager)

local EquipChainDataMgr = EquipChainManager.New(EquipData)
return EquipChainDataMgr