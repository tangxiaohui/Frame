local BaseNodeClass=require"Framework.Base.UINode"
local utility=require"Utils.Utility"
local messageManager=require"Network.MessageManager"


herostarCls=Class(BaseNodeClass)
 function herostarCls:Ctor(parentTransform,id)
 	
 	self.parentTransform=parentTransform
 	self.megId=id
 end

--加载界面（只走一次）
function herostarCls:OnInit()
	utility.LoadNewGameObjectAsync('UI/Prefabs/heroStar',function (go)
		self:BindComponent(go,false)
	end)
end



function herostarCls:GetItemId()
	return self.itemdata:GetId()
end



function herostarCls:SetCallback(table)
       self.callback:Set(table)
end
--界面加载完成初始化函数只走一次
function herostarCls:OnComponentReady()	
	self:LinkComponent(self.parentTransform)	
    self:InitControls()
    
end

--界面显示时调用
function herostarCls:OnResume()
	herostarCls.base.OnResume(self)
	--self:GetUnityTransform():SetAsLastSibling()

end

--界面隐藏时调用
function herostarCls:OnPause()
	herostarCls.base.OnPause(self)
	
end

function herostarCls:OnEnter()
	herostarCls.base.OnEnter(self)
end

function herostarCls:OnExit()
	
	herostarCls.base.OnExit(self)
end

function herostarCls:InitControls()
	local transform =self:GetUnityTransform()
	self.canvasGroup=transform:GetComponent(typeof(UnityEngine.CanvasGroup))
	self.game=utility:GetGame()
	self.Background=transform:GetComponent(typeof(UnityEngine.UI.Image))
	self.Background.gameObject:SetActive(true)
	self.TextTitle=transform:Find('Title/BigLibrarySpeciesTextNameLable'):GetComponent(typeof(UnityEngine.UI.Text))
	self.TextContent=transform:Find('Title/BigLibrarySpeciesTextBriefingLable'):GetComponent(typeof(UnityEngine.UI.Text))
	self:ChangeText()
	transform:GetComponent(typeof(UnityEngine.UI.LayoutElement)).preferredHeight=CalculateImageHight(self.TextContent)
end

function herostarCls:ChangeText()
	local BigLibraryStrategyInfoData = require"StaticData/BigLibrary/BigLibraryStrategyInfo"
	self.TextTitle.text=string.gsub(BigLibraryStrategyInfoData:GetData(self.megId):GetName(),"\\n","\n")
    self.TextContent.text=string.gsub(BigLibraryStrategyInfoData:GetData(self.megId):GetDescription(),"\\n","\n")
end
function CalculateImageHight(ContentStr)
    local height=ContentStr.preferredHeight
    return (height+69)
end

return herostarCls