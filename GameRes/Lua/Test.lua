
local BaseNodeClass = require "Framework.Base.Node"


local GeneralItem = Class(BaseNodeClass)

function GeneralItem:Ctor(parentTransform, itemID, itemNum, itemColor, itemLevel, gemId1, gemId2)
    hzj_print("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP")
end


function GeneralItem:OnInit()
    -- 加载界面(只走一次)
    print("OnInit")
    utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
        self:BindComponent(go, false)
    end)
end



function GeneralItem:OnComponentReady()
    self:InitControls()
end


function GeneralItem:OnResume()
    GeneralItem.base.OnResume(self)
    self:LinkComponent(self.parentTransform, true)
    SetControls(self)
    self:RegisterControlEvents()
end

function GeneralItem:OnPause()
    GeneralItem.base.OnPause(self)
    ResetControls(self)
    self:UnregisterControlEvents()
end

return GeneralItem

