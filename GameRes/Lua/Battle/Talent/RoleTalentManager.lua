--
-- User: fenghao
-- Date: 15/07/2017
-- Time: 1:00 PM
--

require "Object.LuaObject"
require "Collection.OrderedDictionary"

local RoleTalentManager = Class(LuaObject)

function RoleTalentManager:Ctor(owner)
    self.owner = owner
end

function RoleTalentManager:Set(talents)

end

return RoleTalentManager
