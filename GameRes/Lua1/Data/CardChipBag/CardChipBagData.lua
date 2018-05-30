require "Collection.OrderedDictionary"
local CardChiipDataClass = require "Data.CardChipBag.CardChipData"

CardChipBagData = Class(LuaObject)

function CardChipBagData:Ctor()
    self.cardChipDict = OrderedDictionary.New()
end


function CardChipBagData:SetAllData(cardChips)
    self.cardChipDict:Clear()

    local currentChapter

    -- 设置所有
    for i = 1, #cardChips do
        currentChapter = CardChiipDataClass.New()
        currentChapter:SetAllData(cardChips[i])
        self.cardChipDict:Add(currentChapter:GetId(), currentChapter)
    end

    self.cardChipDict:Sort(function(a, b)
        return a:GetNumber() > b:GetNumber()
    end)
end

function CardChipBagData:UpdateData(cardChipData)
    local uid = cardChipData.cardSuipianID
    local currentCardChip = self.cardChipDict:GetEntryByKey(uid)
    if currentCardChip ~= nil then
        currentCardChip:UpdateData(cardChipData)
    else
        currentCardChip = CardChiipDataClass.New()
        currentCardChip:UpdateData(cardChipData)
        self.cardChipDict:Add(uid, currentCardChip)
    end

    self.cardChipDict:Sort(function(a, b)
        return a:GetNumber() > b:GetNumber()
    end)

    return currentCardChip
end

function CardChipBagData:Remove(id)
    local chipData = self.cardChipDict:GetEntryByKey(id)
    if chipData ~= nil then
        self.cardChipDict:Remove(id)
        return chipData
    end
    return nil
end

function CardChipBagData:GetCount()
    return self.cardChipDict:Count()
end

function CardChipBagData:GetCardChipCount(id)
    local data = self.cardChipDict:GetEntryByKey(id)
    local count = 0
    if data ~= nil then
        count = data:GetNumber()
    end
 
    return count
end

function CardChipBagData:GetDataByIndex(index)
    local data = self.cardChipDict:GetEntryByIndex(index)
    return data
end

function CardChipBagData:GetItem(id)
    return self.cardChipDict:GetEntryByKey(id)
end

function CardChipBagData:GetItemCountById(id)
    -- 根据ID查询数量 
    local count = 0

    local item = self:GetItem(id)
    print(item,type(item),"**********")
    if item == nil then
        count = 0
    else
        count = item:GetNumber()
    end
    return count

end


local function SortFunc(a,b)
    return a:GetNumber() < b:GetNumber()
end

function CardChipBagData:Test()
    ----------------Test------------------
    local count = self.cardChipDict:Count() 

    self.cardChipDict:Sort(function(a, b)
        return a:GetNumber() > b:GetNumber()
    end)

    print("-----Sort is done------")
    for i=1,count do
        print(self.cardChipDict:GetEntryByIndex(i):GetNumber())
    end
end
--[[
function CardChipBagData:Sort()
    -- 根据数量排序
    local x = 1

    local count = self:GetCount()
    for i=1, count-1 do
        print(self.cardChipDict:GetEntryByIndex(i).number,"------number----")
    end
end
--]]

return CardChipBagData