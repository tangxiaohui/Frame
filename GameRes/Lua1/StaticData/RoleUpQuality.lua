require "StaticData.Manager"

RoleUpQualityData = Class(LuaObject)

function RoleUpQualityData:Ctor(id)
    local RoleUpQualityMgr = Data.RoleUpQuality.Manager.Instance()
    self.data = RoleUpQualityMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌升品Quality不存在，ID: %s 不存在", id))
        return
    end
end

function RoleUpQualityData:GetId()
    return self.data.id
end

function RoleUpQualityData:GetCardID()
    return self.data.cardID
end

function RoleUpQualityData:GetBeforeCardColorID()
    return self.data.beforeCardColorID
end

function RoleUpQualityData:GetAfterCardColorID()
    return self.data.afterCardColorID
end

function RoleUpQualityData:GetIdAndCount(index)
    -- 获取Id与count
    if index == 1 then
        return self.data.needEquipID1,self.data.needEquipNum2
    elseif index == 2 then 
        return self.data.needEquipID2,self.data.needEquipNum2
    elseif index == 3 then
         return self.data.needEquipID3,self.data.needEquipNum3
    elseif index == 4 then
        return self.data.needEquipID4,self.data.needEquipNum4
    end
end


function RoleUpQualityData:GetNeedEquipID1()
    return self.data.needEquipID1
end

function RoleUpQualityData:GetNeedEquipNum1()
    return self.data.needEquipNum1
end

function RoleUpQualityData:GetNeedEquipID2()
    return self.data.needEquipID2
end

function RoleUpQualityData:GetNeedEquipNum2()
    return self.data.needEquipNum2
end

function RoleUpQualityData:GetNeedEquipID3()
    return self.data.needEquipID3
end

function RoleUpQualityData:GetNeedEquipNum3()
    return self.data.needEquipNum3
end

function RoleUpQualityData:GetNeedEquipID4()
    return self.data.needEquipID4
end

function RoleUpQualityData:GetNeedEquipNum4()
    return self.data.needEquipNum4
end

function RoleUpQualityData:GetCoin()
    return self.data.coin
end



RoleUpQualityManager = Class(DataManager)

local RoleUpQualityDataMgr = RoleUpQualityManager.New(RoleUpQualityData)
return RoleUpQualityDataMgr