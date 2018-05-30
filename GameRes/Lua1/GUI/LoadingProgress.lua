local SceneCls = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
require "System.LuaDelegate"

local LoadingProgressCls = Class(SceneCls)
windowUtility.SetMutex(LoadingProgressCls, true)

function LoadingProgressCls:Ctor()
	self.callbackOnFinished = LuaDelegate.New()
end

function LoadingProgressCls:OnInit()
end

function LoadingProgressCls:OnWillShow(names,assetTypes,isCached4ever)
	self.names = names
	self.assetTypes = assetTypes
	self.totalCount = #names
	self.isCached4ever = isCached4ever
	self.loadCtrl = _G.LoadingScene.LoadingSceneCtrl.GetInstance()
	self.loadCtrl:InitLoadCanvas (2,self.totalCount)
	self.loadCtrl:ChangeLoadStr ("正在加载资源")
	
	--self:AyncLoadFile()
end

function LoadingProgressCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function LoadingProgressCls:OnResume()
	-- 界面显示时调用
	LoadingProgressCls.base.OnResume(self)
end

function LoadingProgressCls:SetCallbackOnFinished(table, func)
	self.callbackOnFinished:Set(table, func)
end

function LoadingProgressCls:OnEnter()
    LoadingProgressCls.base.OnEnter(self)
end

function LoadingProgressCls:InitControls()

end

function LoadingProgressCls:AyncLoadFile()
--    _G.AssetLoad.AssetLoadManager.Instance():LoadAssetsList(self.names,self.assetTypes,function (progress,_)
--    		self.loadCtrl:RefreshLoadingValue(progress)
-- 		-- debug_print("@@@ 完成度 ",progress, "总共 ", self.totalCount)
--    		if progress >= self.totalCount then
--    			self.loadCtrl:LoadingFinished()
-- 			self.callbackOnFinished:Invoke()
-- 			self:Close()
--    		end
--    end,self.isCached4ever == true)
end

return LoadingProgressCls
