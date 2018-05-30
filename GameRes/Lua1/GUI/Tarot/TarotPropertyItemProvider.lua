require "Class"

local TarotPropertyItemProvider = Class()

local function CreatePropertyItemPool(self)
    self.propertyItemPool = {}
    local TarotPropertyItemClass = require "GUI.Tarot.TarotPropertyItem"
    for i = 1, self.count do
        self.propertyItemPool[#self.propertyItemPool + 1] = TarotPropertyItemClass.New(self.transform)
    end
end

function TarotPropertyItemProvider:Ctor(transform, count)
    self.transform = transform
    self.count = count
    CreatePropertyItemPool(self, count)
end

-----------------------------------------------------------------------
--- 外部接口
-----------------------------------------------------------------------
function TarotPropertyItemProvider:SpawnItem(parentTransform)
    if #self.propertyItemPool == 0 then
        error("没有额外的PropertyItem控件!")
    end

    local item = self.propertyItemPool[#self.propertyItemPool]
    self.propertyItemPool[#self.propertyItemPool] = nil
    item:SetParentTransform(parentTransform)
    return item
end

function TarotPropertyItemProvider:DespawnItem(item)
    self.propertyItemPool[#self.propertyItemPool + 1] = item
    item:SetParentTransform(self.transform)
end


return TarotPropertyItemProvider