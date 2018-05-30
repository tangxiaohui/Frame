require "Collection.OrderedDictionary"
local CardSkinDataClass = require "Data.CardSkinBag.CardSkinData"

local CardSkinBagData = Class(LuaObject)

function CardSkinBagData:Ctor()
    self.CardSkinDict = OrderedDictionary.New()
end

function CardSkinBagData:SetAllData(CardSkins)
    self.CardSkinDict:Clear()
    local currentChapter

    for i = 1,#CardSkins do
        local CardSkinData = CardSkins[i]
        self:UpdateData(CardSkinData)
    end
end

function CardSkinBagData:UpdateData(CardSkinData)
    local id = CardSkinData.cardId
    local currentCardSkin = self.CardSkinDict:GetEntryByKey(id)
    local skinData
    if currentCardSkin ~= nil then
        skinData = currentCardSkin:UpdateData(CardSkinData,id)
    else
        currentCardSkin = CardSkinDataClass.New()
        skinData = currentCardSkin:UpdateData(CardSkinData,id)
        self.CardSkinDict:Add(id, currentCardSkin)
    end

    return currentCardSkin,skinData
end

-- function CardSkinBagData:UpdateOneSkinData(CardSkinData)
--     local id = CardSkinData.cardId
--     local currentCardSkin = self.CardSkinDict:GetEntryByKey(id)
--     if currentCardSkin ~= nil then
--         currentCardSkin:UpdateOneSkinData(CardSkinData.cardSkin,id)
--     else
--         currentCardSkin = CardSkinDataClass.New()
--         currentCardSkin:UpdateOneSkinData(CardSkinData.cardSkin,id)
--         self.CardSkinDict:Add(id, currentCardSkin)
--     end
--     return currentCardSkin
-- end

function CardSkinBagData:GetCount()
    return self.CardSkinDict:Count()
end

function CardSkinBagData:GetCardSkins(id)
    return self.CardSkinDict:GetEntryByKey(id)
end

function CardSkinBagData:GetOneSkinData(cardId,skinId)
    local cardData = self.CardSkinDict:GetEntryByKey(cardId)
    if cardData == nil then
        return nil,nil
    else
        return cardData:GetSkinDataById(skinId),cardData
    end
end

return CardSkinBagData