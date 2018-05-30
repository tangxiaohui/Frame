require "Collection.OrderedDictionary"
require "Object.LuaObject"

local SkinItemData = Class(LuaObject)
function SkinItemData:UpdateData(data)
    self.data = data
    self.cardSkinId = data.cardSkinId
    self.cardSkinLevel = data.cardSkinLevel
    self.cardSkinExp = data.cardSkinExp
    self.cardSkinUID = data.cardSkinUID
end

function SkinItemData:GetCardSkinId()
    return self.cardSkinId
end

function SkinItemData:GetCardSkinLevel()
    return self.cardSkinLevel
end

function SkinItemData:GetCardSkinExp()
    return self.cardSkinExp
end

function SkinItemData:GetCardSkinUID()
    return self.cardSkinUID
end

function SkinItemData:GetData()
    return self.data
end

function SkinItemData:GetSkinStaticData()
    return require"StaticData.CardSkin.Skin":GetData(self.cardSkinId)
end

function SkinItemData:GetSkinKizunaStaticData()
    local kiZunaId = self:GetSkinStaticData():GetKizuna()
    return require"StaticData.CardSkin.SkinKizuna":GetData(kiZunaId)
end


---------------------------------------------
local CardData = Class(LuaObject)

function CardData:Ctor()
    self.SkinsDict = OrderedDictionary.New()
end

function CardData:GetCardId()
    return self.cardId
end

function CardData:GetcurrSkinId()
    return self.currSkinId
end

function CardData:GetCardSkins()
    return self.SkinsDict
end

function CardData:GetSkinDataById(skinId)
    return self.SkinsDict:GetEntryByKey(skinId)
end

function CardData:GetCardskinStaticData()
   return require"StaticData.CardSkin.Cardskin":GetData(self.cardId) 
end

function CardData:UpdateData(data,cardId)
    self.data = data
    self.currSkinId = data.currSkinId
    self.cardSkin = data.cardSkin
    self.cardId = cardId
    -- debug_print("@@@cardId",cardId," ",data.currSkinId)
    local lastSkinData
    for i = 1 ,#self.cardSkin do
        lastSkinData = self:UpdateOneSkinData(self.cardSkin[i],cardId)
    end
    return lastSkinData
end

function CardData:UpdateOneSkinData(skin)
    local cardSkinId = skin.cardSkinId
    local currSkinData = self.SkinsDict:GetEntryByKey(cardSkinId)
    if currSkinData ~= nil then
        currSkinData:UpdateData(skin)
    else
        currSkinData = SkinItemData.New()
        currSkinData:UpdateData(skin)
        self.SkinsDict:Add(cardSkinId,currSkinData)
    end
    return currSkinData
end

return CardData