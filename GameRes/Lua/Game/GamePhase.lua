
-- 游戏阶段 是按大类分, 登录前的登录页面/注册, 登录后的大厅页面(战斗外), 战斗内

local GamePhase = {
    None        = 0,
    Login       = 1,
    Register    = 2,
    Lobby       = 3,
    Battle      = 4
}

return GamePhase
