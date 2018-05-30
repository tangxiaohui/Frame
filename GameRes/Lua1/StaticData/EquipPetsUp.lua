require "StaticData.Manager"

EquipPetsUpData = Class(LuaObject)

function EquipPetsUpData:Ctor(id)
    local EquipPetsUpDataMgr = Data.EquipPetsUp.Manager.Instance()
    self.data = EquipPetsUpDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipPetsUpData:GetColor()
    return self.data.color
end

function EquipPetsUpData:GetDisplayId()
    return self.data.displayId
end

function EquipPetsUpData:GetCost()
    return self.data.cost
end

function EquipPetsUpData:GetItemId()
    return self.data.itemId
end

function EquipPetsUpData:GetNeedNum()
    return self.data.needNum
end

function EquipPetsUpData:GetLevelLimit()
    return self.data.levelLimit
end

function EquipPetsUpData:GetOutputType()
    return self.data.outputType
end




EquipPetsUpInfoManager = Class(DataManager)

local EquipPetsUpInfoMgr = EquipPetsUpInfoManager.New(EquipPetsUpData)
return EquipPetsUpInfoMgr




-- require "StaticData.Manager"

-- EquipCrapInfoData = Class(LuaObject)

-- function EquipCrapInfoData:Ctor(id)
--     local EquipCrapInfoMgr = Data.EquipCrapInfo.Manager.Instance()
--     self.data = EquipCrapInfoMgr:GetObject(id)
--     if self.data == nil then
--         error(string.format("道具信息不存在，ID: %s 不存在", id))
--         return
--     end
-- end

-- function EquipCrapInfoData:GetId()
--     return self.data.id
-- end

-- function EquipCrapInfoData:GetName()
--     return self.data.name
-- end


-- EquipCrapInfoManager = Class(DataManager)

-- local EquipCrapInfoDataMgr = EquipCrapInfoManager.New(EquipCrapInfoData)
-- return EquipCrapInfoDataMgr