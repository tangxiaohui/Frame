--
-- User: fbmly
-- Date: 4/20/17
-- Time: 11:34 AM
--

-- 静态表相关工具类
require "Const"

local utility = require "Utils.Utility"

local StaticTableUtility = {}

function StaticTableUtility.GetTypeFromID(id)
    if type(id) ~= "number" then
        error("id必须是有效的数字类型!")
    end
    return utility.ToInteger(id / 100000)
end

-- 主颜色
function StaticTableUtility.GetMainColor(id)
    error("未实现!")
end

-- 主显图标
function StaticTableUtility.GetMainIcon(id)
    error("未实现!")
end

return StaticTableUtility