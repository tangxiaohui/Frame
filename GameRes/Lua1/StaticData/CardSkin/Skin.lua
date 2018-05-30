require "StaticData.Manager"

SkinData = Class(LuaObject)

function SkinData:Ctor(id)
	local SkinMgr = Data.Skin.Manager.Instance()
    self.data = SkinMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌皮肤信息不存在，ID: %s 不存在", id))
        return
    end

    local SkininfoMgr = Data.Skininfo.Manager.Instance()
    local infoId = self.data.info
    self.Infodata = SkininfoMgr:GetObject(infoId)
    if self.Infodata == nil then
        error(string.format("卡牌皮肤描述信息不存在，ID: %s 不存在", id))
        return
    end
end    
    


function SkinData:GetId()
    return self.data.id
end

function SkinData:GetIndex()
    return self.data.index
end

function SkinData:GetRoleid()
    return self.data.roleid
end

function SkinData:GetInfo()
    return self.data.info
end

function SkinData:GetColor()
    return self.data.color
end

function SkinData:GetSkinicon()
    return self.data.skinicon
end

function SkinData:GetSkinIllust()
    return self.data.skinIllust
end

function SkinData:GetGongjiliindex()
    return self.data.gongjiliindex
end

function SkinData:GetHpLimitindex()
    return self.data.hpLimitindex
end

function SkinData:GetExp()
    return self.data.exp
end

function SkinData:GetCoin()
    return self.data.coin
end

function SkinData:GetFragment()
    return self.data.fragment
end

function SkinData:GetFragmentnum()
    return self.data.fragmentnum
end

function SkinData:GetKizuna()
    return self.data.kizuna
end

function SkinData:GetName()
	return self.Infodata.info
end

function SkinData:GetDescription()
	return self.Infodata.description
end

function SkinData:GetInfoData()
	return self.Infodata
end

function SkinData:GetRarity(color)
	local rarityData = require "StaticData.StartoSSR":GetData(color + 2)
	return rarityData:GetSSR()
end

SkinManager = Class(DataManager)

local SkinDataMgr = SkinManager.New(SkinData)
return SkinDataMgr