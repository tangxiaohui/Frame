local BaseNodeClass=require"Framework.Base.UINode"
local untility=require"Utils.Utility"
local MytestCls=Class(BaseNodeClass)

--构造函数
function Ctor( parent,msg )
	self.parent=parent
	self.msg=msg
end

function MytestCls:OnInit()
	utility.LoadNewGameObjectAsync('UI/Prefabs/BigLibrary',function (go)   --加载界面
      self:BindComponent(go)  ---获取GameObject和transform 不设置Transform的信息
		
	end)
end

SceneManager:PushScene(MytestCls)

function MytestCls:OnComponentReady( )
	self.LinkComponent(self.parent)
	self.InitControls()
end

--界面显示
function MytestCls:OnResume( )
	MytestCls.Base.OnResume(self)
	self.ScheduleUpdate(self.Update)
end

--界面隐藏
function MytestCls:OnPause( )
	MytestCls.Base.OnPause(self)
end

function MytestCls:OnEnter( )
	MytestCls.Base.OnEnter(self)
end

function MytestCls:OnExit( )
	MytestCls.Base.OnExit(self)
end

function MytestCls:InitControls()
	local transform=self:GetUnityTransform()
	self.BigLibraryReturnButton=transform:Find('BigLibraryReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
end

function MytestCls:RegisterControlEvents()
	self._event_button_ReturnButton_OnClicked=UnityEngine.Events.UnityAction(self.ReturnButtonClicked,self)
	self.BigLibraryReturnButton.onClick:AddListener(self._event_button_ReturnButton_OnClicked)

end

function MytestCls:UnregisterControlEvents()
	if self._event_button_ReturnButton_OnClicked then
		self.BigLibraryReturnButton.onClick:RemoveListener(self._event_button_ReturnButton_OnClicked)
		self._event_button_ReturnButton_OnClicked=nil
end

function ReturnButtonClicked()
	MytestCls:OnPause()
end

return MytestCls;