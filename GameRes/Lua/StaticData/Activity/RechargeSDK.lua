require "StaticData.Manager"
require "Collection.OrderedDictionary"

RechargeSDKData = Class(LuaObject)
function RechargeSDKData:Ctor(id)
    local RechargeSDKMgr = Data.RechargeSDK.Manager.Instance()
    self.data = RechargeSDKMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function RechargeSDKData:GetId()
    return self.data.id
end
function RechargeSDKData:GetName()
    return self.data.name
end

function RechargeSDKData:GetDes()
    return self.data.des
end

function RechargeSDKData:GetPrice()
    return self.data.price
end

function RechargeSDKData:GetDiamond()
    return self.data.diamond
end

function RechargeSDKData:GetFirstDiamond()
    return self.data.firstDiamond
end

function RechargeSDKData:GetIcon()
    return self.data.Icon
end

function RechargeSDKData:GetRechargeType()
    return self.data.Rechargetype
end

function RechargeSDKData:GetKeys()
    return Data.RechargeSDK.Manager.Instance():GetKeys()
end



RechargeSDKManager = Class(DataManager)

local RechargeSDKDataMgr = RechargeSDKManager.New(RechargeSDKData)






return RechargeSDKDataMgr