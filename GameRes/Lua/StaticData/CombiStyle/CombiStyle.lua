require "StaticData.Manager"

CombiStyleData = Class(LuaObject)

function CombiStyleData:Ctor(id)
    local CombiStyleMgr = Data.CombiStyle.Manager.Instance()
    self.data = CombiStyleMgr:GetObject(id)
    if self.data == nil then
        error(string.format("流派关联信息不存在，ID: %s 不存在", id))
        return
    end
end

function CombiStyleData:GetId()
    return self.data.id
end

function CombiStyleData:GetInfo()
    return self.data.info
end

function CombiStyleData:GetCardId()
     self.cardIds={}
    for i=0,self.data.cardId.Count-1 do
        self.cardIds[#self.cardIds+1]=self.data.cardId[i]
        debug_print(self.cardIds[#self.cardIds])
    end
    return  self.cardIds
   
end

function CombiStyleData:GetAddPowerId()
    return self.data.addPowerId
end
function CombiStyleData:GetAddPowerValue()
    return self.data.addPowerValue
end
function CombiStyleData:GetAwardRank()
    self.awardRanks={}
    for i=0,self.data.awardRank.Count-1 do
        self.awardRanks[#self.awardRanks+1]=self.data.awardRank[i]
        -- debug_print(self.cardIds[#self.cardIds])
    end
    -- return  self.cardIds
    return self.awardRanks
end

function CombiStyleData:GetAwardID()
    self.awardIDs={}
     for i=0,self.data.awardID.Count-1 do
        self.awardIDs[#self.awardIDs+1]=self.data.awardID[i]
    end
    return self.awardIDs
end
function CombiStyleData:GetAwrdNum()
    self.awrdNums={}
     for i=0,self.data.awrdNum.Count-1 do
        self.awrdNums[#self.awrdNums+1]=self.data.awrdNum[i]
    end
    return self.awrdNums
end

function CombiStyleData:GetCount()
    return #self.awardIDs
end 

function CombiStyleData:GetAwardDataByIndex(index)
  
    self:GetAwardID()
    self:GetAwrdNum()
    if index>self:GetCount() then
        debug_print("index 不存在")
         return nil
    else

        local id = self.awardIDs[index]
        local num = self.awrdNums[index]      
         return id,num

    end
   

end

function CombiStyleData:GetRankDataByStage(allStage)

    self:GetAwardRank()
    for i=1,#self.awardRanks do
        if allStage >= self.awardRanks[i] then
            debug_print("已达成",i)

        else
            debug_print("未达成",i)
            return i-1;
            
        end
    end

    return nil
end


CombiStyleManager = Class(DataManager)

local CombiStyleDataMgr = CombiStyleManager.New(CombiStyleData)
return CombiStyleDataMgr