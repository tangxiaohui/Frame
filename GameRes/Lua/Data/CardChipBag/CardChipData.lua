--require "Collection.OrderedDictionary"

require "Object.LuaObject"
CardChipData = Class(LuaObject)

function CardChipData:SetAllData(cardChipData)
    self.cardSuipianID = cardChipData.cardSuipianID

    self.number = cardChipData.number

    -- self.data.cardSuipianID = cardChipData.cardSuipianID
    -- self.data.number = cardChipData.number
    --self.cardChipDict:Clear()
end

function CardChipData:GetId()
    return self.cardSuipianID
end

function CardChipData:GetNumber()
    return self.number
end

function CardChipData:UpdateData(data)
    --self = data
    self.cardSuipianID = data.cardSuipianID
    self.number = data.number
end

return CardChipData