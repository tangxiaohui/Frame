require "StaticData.Manager"
require "Collection.OrderedDictionary"

WorldBossLevelData = Class(LuaObject)
function WorldBossLevelData:Ctor(id)
    local WorldBossLevelMgr = Data.WorldBossLevel.Manager.Instance()
    self.data = WorldBossLevelMgr:GetObject(id)
    if self.data == nil then
        error(string.format("Boss信息不存在，ID: %s 不存在", id))
        return
    end
end
function WorldBossLevelData:GetID()
    return self.data.id
end


function WorldBossLevelData:GetLevelrange()
    return self.data.levelrange
end

function WorldBossLevelData:GetInfo()
    return self.data.info
end

function WorldBossLevelData:GetLevelgaps()
    self.levelgaps={}
    for i=0,self.data.levelgap.Count-1 do
        self.levelgaps[#self.levelgaps+1]=self.data.levelgap[i]
    end
    return  self.levelgaps
end

function WorldBossLevelData:GetTeamid()
  
    self.teamids={}
    for i=0,self.data.teamId.Count-1 do
        self.teamids[#self.teamids+1]=self.data.teamId[i]
    end
    return  self.teamids


end

function WorldBossLevelData:GetStayTime()
    return self.data.staytime
end



function WorldBossLevelData:GetNormalAwardItem()
    self.normalawarditems={}
    for i=0,self.data.normalawarditem.Count-1 do
        self.normalawarditems[#self.normalawarditems+1]=self.data.normalawarditem[i]
        debug_print( self.normalawarditems[#self.normalawarditems])
    end
    return  self.normalawarditems
end

function WorldBossLevelData:GetNormalAwardItemNum()

    self.normalawarditemnums={}
    for i=0,self.data.normalawarditemnum.Count-1 do
        self.normalawarditemnums[#self.normalawarditemnums+1]=self.data.normalawarditemnum[i]
        debug_print( self.normalawarditemnums[#self.normalawarditemnums])
    end
    return  self.normalawarditemnums

end

function WorldBossLevelData:GetExtraAwardItem()

    self.extraawarditems={}
    for i=0,self.data.extraawarditem.Count-1 do
        self.extraawarditems[#self.extraawarditems+1]=self.data.extraawarditem[i]
        debug_print( self.extraawarditems[#self.extraawarditems])
        
    end
    return  self.extraawarditems
end
function WorldBossLevelData:GetExtraAwardItemNum()
    self.extraawarditemnums={}
    for i=0,self.data.extraawarditem.Count-1 do
        self.extraawarditemnums[#self.extraawarditemnums+1]=self.data.extraawarditemnum[i]
    end
    return  self.extraawarditemnums
end


function WorldBossLevelData:GetBossID()
    return  self.data.bossid
end

function WorldBossLevelData:GetBossColor()
     self.bosscolors={}
    for i=0,self.data.bosscolor.Count-1 do
        self.bosscolors[#self.bosscolors+1]=self.data.bosscolor[i]
    end
    return  self.bosscolors

end

function WorldBossLevelData:GetLevelId()
     self.levelIds={}
    for i=0,self.data.levelId.Count-1 do     
        self.levelIds[#self.levelIds+1]=self.data.levelId[i]
    end
    return  self.levelIds

end

function WorldBossLevelData:GetBossPosition()
     self.bossPosition={}
     self.bossPosition.x=self.data.bossPosition[0]
     self.bossPosition.y=self.data.bossPosition[1]
     self.bossPosition.z=self.data.bossPosition[2]
  
    return  self.bossPosition

end


function WorldBossLevelData:GetBossRotation()
     self.bossRotation={}
     self.bossRotation.x=self.data.bossRotation[0]
     self.bossRotation.y=self.data.bossRotation[1]
     self.bossRotation.z=self.data.bossRotation[2]
  
    return  self.bossRotation

end


function WorldBossLevelData:GetBossScale()
     self.bossScale={}
     self.bossScale.x=self.data.bossScale[0]
     self.bossScale.y=self.data.bossScale[1]
     self.bossScale.z=self.data.bossScale[2]
  
    return  self.bossScale

end

function WorldBossLevelData:GetBossAnimation()
    return  self.data.bossAnimation

end

function WorldBossLevelData:GetBossDataByIndex(index)
 
    self:GetLevelgaps()
    self:GetTeamid()
    self:GetNormalAwardItem()
    self:GetNormalAwardItemNum()
    self:GetExtraAwardItem()
    self:GetExtraAwardItemNum()
    self:GetBossColor()
    self:GetLevelId()
      
    return self.levelgaps[index],self.teamids[index],self.normalawarditems[index],
           self.normalawarditemnums[index],self.extraawarditems[index],self.extraawarditemnums[index],
           self.data.bossid,self.bosscolors[index],self.levelIds[index]
end


function WorldBossLevelData:GetBossIndexByLevel(level)
    self:GetLevelgaps()
    self.num=0
    for i=1,#self.levelgaps do
       if self.levelgaps[i]>=level then
         num=i+1
         break
        end

        if i==(#self.levelgaps-1) then

            num=i+1

        end
      
    end
    if self.num==0 then
        self.num=self.num+1

    end
    return  self.num



end



local WorldBossLevelManager = Class(DataManager)

local WorldBossLevelMgr = WorldBossLevelManager.New(WorldBossLevelData)
return WorldBossLevelMgr