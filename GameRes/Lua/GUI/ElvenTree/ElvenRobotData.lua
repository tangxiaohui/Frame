require "Const"

ElvenRobotCard = Class(LuaObject)

function ElvenRobotCard:Ctor()
    
end

-----------------------------------------------------------------------

function ElvenRobotCard:SetRobotData(data)
    self.robotData=data
    self.robotData:GetUid()
end


function ElvenRobotCard:GetRobotData()
    if self.robotData==nil then
        print("Error :robotData is nil")
        return nil
    else
        self.robotData:GetUid()
        return self.robotData
    end
end
