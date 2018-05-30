require "StaticData.Manager"

SkinKizunaData = Class(LuaObject)

function SkinKizunaData:Ctor(id)
    local SkinKizunaMgr = Data.SkinKizuna.Manager.Instance()
    
    self.data = SkinKizunaMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌皮肤羁绊信息不存在，ID: %s 不存在", id))
        return
    end
end

function SkinKizunaData:GetId()
    return self.data.id
end

function SkinKizunaData:GetSkinid()
    return self.data.skinid
end

function SkinKizunaData:GetCardid()
    return self.data.cardid
end

function SkinKizunaData:GetKizuna()
    return self.data.kizuna
end

function SkinKizunaData:GetKizunalevel1()
    return self.data.kizunalevel1
end

function SkinKizunaData:GetKizunalevel2()
    return self.data.kizunalevel2
end

function SkinKizunaData:GetKizunalevel3()
    return self.data.kizunalevel3
end

function SkinKizunaData:GetStatusid()
    return self.data.statusid
end

function SkinKizunaData:GetStatusrate()
    return self.data.statusrate
end

function SkinKizunaData:GetIndex()
    return self.data.index
end

SkinKizunaManager = Class(DataManager)

local SkinKizunaDataMgr = SkinKizunaManager.New(SkinKizunaData)
return SkinKizunaDataMgr