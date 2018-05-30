require "StaticData.Manager"

CardskinData = Class(LuaObject)

function CardskinData:Ctor(id)
    local CardskinMgr = Data.Cardskin.Manager.Instance()
    
    self.data = CardskinMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌皮肤关联信息不存在，ID: %s 不存在", id))
        return
    end
end

function CardskinData:GetId()
    return self.data.id
end

function CardskinData:GetSkinid()
	self.Skinids={}
	for i=0,self.data.Skinid.Count-1 do
		debug_print("self.data.Skinid.Count",self.data.Skinid[i])
		self.Skinids[#self.Skinids+1]=self.data.Skinid[i]
	end


    return self.Skinids
end


CardskinManager = Class(DataManager)

local CardskinDataMgr = CardskinManager.New(CardskinData)
return CardskinDataMgr