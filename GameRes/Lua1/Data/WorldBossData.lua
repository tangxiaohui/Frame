
require "Game.Role"
require "Collection.OrderedDictionary"
require "Data.LineupData"
require "Const"

WorldBossData = Class(LuaObject)

function WorldBossData:Ctor()
    self.allShareID={}
    self.bossCount=0

end

function WorldBossData:SetAllData(shareIDs)
  --  debug_print("存储世界BOss============",#shareIDs)
    self.allShareID={}
    self.bossCount=0
    for i=1,#shareIDs do
       -- debug_print(shareIDs[i],"++++++++++++++++新来的世界Boss")
       self.allShareID[i]=shareIDs[i]
       self.bossCount=self.bossCount+1
    end
    self:Count()
end

function WorldBossData:AddData(shareID)
    for i,v in ipairs(self.allShareID) do
        if v== shareID then
            debug_print("shareID",shareID.."已经存在！")       
            return    
        end       
    end

   -- debug_print("shareID",shareID.."新增世界BOss！")       
    self.allShareID[#self.allShareID+1]=shareID
    self.bossCount=self.bossCount+1


end

function WorldBossData:RemoveData(shareID)
    --debug_print("RemoveData",shareID)
    for i,v in ipairs(self.allShareID) do
        if v== shareID then
            self.allShareID[i]=nil
            self.bossCount=self.bossCount-1
           -- debug_print("shareID",shareID.."消失！")
        end       
    end
end
function WorldBossData:Count()
    -- for i,v in ipairs(self.allShareID) do
    --     debug_print("现在存在的世界boss",v)
    -- end
   -- debug_print("Count",self.bossCount)
    return self.bossCount
end

function WorldBossData:CheckCount()
    if self.bossCount <=0 then
        
    end
end

