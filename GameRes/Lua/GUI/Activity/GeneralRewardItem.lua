local GeneralItemClass = require "GUI.Item.GeneralItem"
local BaseNodeClass = require "GUI.ChooseItemContainer.BaseItemNode"
local utility = require "Utils.Utility"


local GeneralRewardItemCls = Class(BaseNodeClass)

function GeneralRewardItemCls:Ctor(parent,itemWidth,itemHigh)

end

function GeneralRewardItemCls:OnInit()
	GeneralRewardItemCls.base.OnInit(self)
	self:InitControls()
end

function GeneralRewardItemCls:InitControls()
	GeneralRewardItemCls.base.InitControls(self)
	
end

function GeneralRewardItemCls:OnResume()
	GeneralRewardItemCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function GeneralRewardItemCls:OnPause()
	-- 界面隐藏时调用
	GeneralRewardItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function GeneralRewardItemCls:RegisterControlEvents()

end

function GeneralRewardItemCls:UnregisterControlEvents()
	
end



return GeneralRewardItemCls