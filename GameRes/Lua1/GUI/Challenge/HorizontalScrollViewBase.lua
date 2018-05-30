local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local HorizontalScrollViewBaseCls = Class(BaseNodeClass)
require "System.LuaDelegate"

function HorizontalScrollViewBaseCls:Ctor(parent,rowCount,width,height,itemNum,viewWidth,viewHeight,chapter)
	self.rowCount=rowCount
	self.width=width
	self.height=height
	self.itemNum=itemNum
	self.parent=parent
	self.viewWidth=viewWidth
	self.viewHeight=viewHeight
	self.Chapter=chapter
	self.itemsDic = OrderedDictionary.New()
	self.callback = LuaDelegate.New()
	self.childCallback = LuaDelegate.New()
	self.firstMove=true
	print(self.itemNum,self.Chapter,#self.Chapter)
end
-----------------------------------------------------------------------
function HorizontalScrollViewBaseCls:SetCallback(table,func)
	self.callback:Set(table,func)
end
function HorizontalScrollViewBaseCls:SetDidChildCallback(table,func)
	self.childCallback:Set(table,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function HorizontalScrollViewBaseCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/HorizontalScrollViewBase', function(go)
		self:BindComponent(go)
	end)
 end

function HorizontalScrollViewBaseCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	--self:LinkComponent(self.parent)

end

function HorizontalScrollViewBaseCls:OnResume()
	-- 界面显示时调用
	HorizontalScrollViewBaseCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:InitViews()
	self.contentChange=false
	--self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)
--	self.first=true
	self.firstMove=true
	self.num=0

end

function HorizontalScrollViewBaseCls:OnPause()
	-- 界面隐藏时调用
	HorizontalScrollViewBaseCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function HorizontalScrollViewBaseCls:OnEnter()
	-- Node Enter时调用
	HorizontalScrollViewBaseCls.base.OnEnter(self)
end

function HorizontalScrollViewBaseCls:OnExit()
	-- Node Exit时调用
	HorizontalScrollViewBaseCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function HorizontalScrollViewBaseCls:InitControls()
	local transform = self:GetUnityTransform()
	self.ScrollRect = transform:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Content = transform:Find('Viewport/Content')
	--print(self.ScrollRect,self.Content)
	-- self.SelectChallengdungeonReturnButton__1_ = transform:Find('SelectStageBox/Scroll View/SelectChallengdungeonReturnButton (1)'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.SelectChallengdungeonRightButton = transform:Find('SelectStageBox/Scroll View/SelectChallengdungeonRightButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.SelectChallengdungeonLeftButton = transform:Find('SelectStageBox/Scroll View/SelectChallengdungeonLeftButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self:InitChapterInfos()
	self.currentButton=nil
	
end


function  HorizontalScrollViewBaseCls:InitChapterInfos()
	
	self:InitValue()
	self:InitItems()
end


	

function HorizontalScrollViewBaseCls:InitViews()

	
	self:ResetChildPosition()
	--



end
--初始化数值
function HorizontalScrollViewBaseCls:InitValue()

 	if self.rowCount <= 0 then
            self.rowCount = 1
    end
     self.mTrans=self:GetUnityTransform()
     self.mRTrans=self.mTrans:GetComponent(typeof(UnityEngine.RectTransform))    
     self.mTrans:SetParent(self.parent)
	 self.mTrans.localPosition = Vector3(0,0,0)
	 self.mRTrans.sizeDelta=Vector2(self.viewWidth,self.viewHeight)     
     
     --ScrollView 显示区域大小
     self.contentSize=self.mRTrans.sizeDelta
     self.conners={}
     self.conners[1] = Vector3(-self.contentSize.x / 2, self.contentSize.y / 2, 0);
     self.conners[2] = Vector3(self.contentSize / 2, self.contentSize.y / 2, 0);
     self.conners[3] = Vector3(-self.contentSize.x / 2, -self.contentSize.y / 2, 0);
     self.conners[4] = Vector3(self.contentSize.x / 2, -self.contentSize.y / 2, 0);
    -- print( #self.conners)
     for i=1,#self.conners do     
     	--print(self.conners[i].x,self.conners[i].y,self.conners[i].z)
     	local temp = self.mTrans:TransformPoint(Vector3(self.conners[i].x,self.conners[i].y,self.conners[i].z));
        self.conners[i].x = temp.x;
        self.conners[i].y = temp.y;
     end

     self.mRTrans.pivot = Vector2(0.5, 0.5);--//设置panel的中心在左上角
     self.mRTrans.anchorMin =  Vector2(0.5, 0.5);
     self.mRTrans.anchorMax =  Vector2(0.5, 0.5);  

     self.mContentTrans=self.Content    
     self.mContentRTrans=self.mContentTrans:GetComponent(typeof(UnityEngine.RectTransform))  
     self.mContentRTrans.pivot = Vector2(0, 1);--//设置panel的中心在左上角
     self.mContentRTrans.anchorMin =  Vector2(0, 1);
     self.mContentRTrans.anchorMax =  Vector2(0, 1);  
     self.lastValue= 100000;
   
end


 function HorizontalScrollViewBaseCls:ChildInitOKCallBack()
	
	self.itemOkNum=self.itemOkNum+1
	--print(self.itemOkNum)
	if self.itemNum ==self.itemOkNum then
	--	print("初始化完成")
	--	self:Move()
		self.callback:Invoke()
	end
end 


 function HorizontalScrollViewBaseCls:ChildClickedCallBack(table)
 	--print(type(info))
	print("ChildClickedCallBack")--,self.info.data:GetChapterInfo():GetName())
	print(type(table),table.ChapterID)
	self.childCallback:Invoke(table)
end 

function HorizontalScrollViewBaseCls:InitItems()
	self.itemOkNum=0
	
	for i=1,self.itemNum do

		local item = require "GUI.Challenge.SelectChallengdungeonStage".New(self,self.Content,self.width,self.height,self.Chapter[i])
			self:AddChild(item)
			item:SetCallback(self,self.ChildInitOKCallBack)
			item:SetDidCallback(self,self.ChildClickedCallBack)
			self.itemsDic:Add(i,item)
	--	print(#self.Chapter,(i)-math.floor((i)/#self.Chapter)*#self.Chapter)
		-- if ((i)-math.floor((i)/#self.Chapter)*#self.Chapter) ~=0  then
		-- 	local item = require "GUI.Challenge.SelectChallengdungeonStage".New(self,self.Content,self.width,self.height,self.Chapter[(i)-math.floor((i)/#self.Chapter)*#self.Chapter])
		-- 	self:AddChild(item)
		-- 	item:SetCallback(self,self.ChildInitOKCallBack)
		-- 	item:SetDidCallback(self,self.ChildClickedCallBack)
		-- 	self.itemsDic:Add(i,item)

		-- else
		-- 	local item = require "GUI.Challenge.SelectChallengdungeonStage".New(self,self.Content,self.width,self.height,self.Chapter[#self.Chapter])
		-- 	self:AddChild(item)
		-- 	item:SetCallback(self,self.ChildInitOKCallBack)	
		-- 	item:SetDidCallback(self,self.ChildClickedCallBack)	
		-- 	self.itemsDic:Add(i,item)

		-- end
	end
end




--重置子类的位置
function  HorizontalScrollViewBaseCls:ResetChildPosition()
	--起始位置
	local startAxis={}
	startAxis.x=self.width/2
    startAxis.y=self.height/2
	--item数量
	local childCount = self.itemsDic:Count()
	local rows = self.rowCount
	--计算列数
	local cols =( math.floor(childCount/rows))	
	--范围
	self.extents=(cols * self.width) * 0.5
	--print(childCount)
	for i=1,childCount do
	--	print(i)
		local tempItem = self.itemsDic:GetEntryByKey(i)
	--	print(tempItem)
		if  tempItem ~=nil then
			--行号  和列号
			local x = (i-1)-math.floor((i-1)/rows)*rows
			local y = math.floor((i-1)/rows)	
			print(startAxis.x + y * self.width+(y+1)*20)		
 			tempItem:SetPosition (startAxis.x + y * self.width+(y+1)*20, startAxis.y - x * self.height)
 			--tempItem.gameObject.SetActive(true);
 			self:UpdateRectsize(startAxis.x + y * self.width+(y+1)*20, startAxis.y - x * self.height)
		else
			print("child 为空")
		end 
	end


end
--更新content尺寸
function HorizontalScrollViewBaseCls:UpdateRectsize( width,height)

	-- body
	self.mContentRTrans.sizeDelta=Vector2(width+self.width/2,self.rowCount*self.height)
	print(self.mContentRTrans.sizeDelta.x,self.mContentRTrans.sizeDelta.y)
end
--更新Item
function HorizontalScrollViewBaseCls:UpdateItem()
	
end

function HorizontalScrollViewBaseCls:RegisterControlEvents()

	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.ScrollRect.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

end

function HorizontalScrollViewBaseCls:UnregisterControlEvents()


	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.ScrollRect.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end


end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

-- function HorizontalScrollViewBaseCls:Change( ... )
-- 	-- body
-- end

function HorizontalScrollViewBaseCls:OnScroll_ViewValueChanged(posXY)

		
		--	self:Move()
	-- if self.contentChange then
	-- 	--print(false)
	-- else
	--  --	print(self.lastValue,self.mContentTrans.localPosition.x)
	--    if math.abs(self.lastValue - self.mContentTrans.localPosition.x)<0.2 then
	  
	--    		self.ScrollRect:StopMovement()
	--    		self.lastValue=0
	--    		self:MoveEnd()
	--    		self.contentChange=true
	--    else
	--    		self:Move()
	--    		self.lastValue = self.mContentTrans.localPosition.x;
	   
	--    	end
	--  end
	
	
end

function HorizontalScrollViewBaseCls:Update()
	if self.contentChange then
		self:ChangeContentPositon()
	end
	
end
function HorizontalScrollViewBaseCls:MoveEnd()
	
	--self.contentChange=true
	self.currentChangeTime=0
	self.totalChangeTime=0.5
	local conner_local = {}
	local TweenUtility = require "Utils.TweenUtility"
	for i=1,4 do		
		conner_local[i]=self.mContentTrans:InverseTransformPoint(Vector3(self.conners[i].x,self.conners[i].y,self.conners[i].z))
	end

	local  contentLenth = self.mContentTrans.localPosition.x;

	if  (contentLenth)-math.floor((contentLenth)/self.width)*self.width >self.width/2 then
 		self.contentEndPos=(math.floor(contentLenth / self.width)+1)*self.width

	elseif (contentLenth)-math.floor((contentLenth)/self.width)*self.width <-self.width/2 then
		self.contentEndPos=(math.floor(contentLenth / self.width)-1)*self.width
	else
		self.contentEndPos=(math.floor(contentLenth / self.width))*self.width
	end
end


--修改图片的形状
function HorizontalScrollViewBaseCls:ChangeContentPositon()
 	
 		local TweenUtility = require "Utils.TweenUtility"
       	local t = self.currentChangeTime/self.totalChangeTime
       	self.currentChangeTime=self.currentChangeTime+Time.deltaTime
       
       	if t>=1 then
       		
       		self.num=self.num+1
       		if self.num>=2 then
       		self.firstMove =false   
       		end
       		 self.contentChange=false   
       		else  
       	
	 	end
       	local s = TweenUtility.Linear(self.mContentTrans.localPosition.x, self.contentEndPos,t)
		self.mContentTrans.localPosition=Vector3(s,self.mContentTrans.localPosition.y,self.mContentTrans.localPosition.z)
     	
       if self.firstMove ==false then
	    local conner_local = {}
		for i=1,4 do
			conner_local[#conner_local+1]=self.mContentTrans:InverseTransformPoint(Vector3(self.conners[i].x,self.conners[i].y,self.conners[i].z))
		end

		local center =(conner_local[4] + conner_local[1])/2
		for i=1,self.itemsDic:Count() do
			local tempItem = self.itemsDic:GetEntryByKey(i)
			if  tempItem ~=nil then
				local distance = tempItem.transform.localPosition.x - center.x;
				self:SetRotate(distance,tempItem)
			end
		end
	end
    
end


function HorizontalScrollViewBaseCls:Move()
	-- body
	local conner_local = {}
	for i=1,4 do
		conner_local[#conner_local+1]=self.mContentTrans:InverseTransformPoint(Vector3(self.conners[i].x,self.conners[i].y,self.conners[i].z))
	end

	local center =(conner_local[4] + conner_local[1])/2
	
	local min = conner_local[1].x-self.width
	local max = conner_local[4].x+self.width
	for i=1,self.itemsDic:Count() do
		local tempItem = self.itemsDic:GetEntryByKey(i)
		if  tempItem ~=nil then
			local distance = tempItem.transform.localPosition.x - center.x;
			local pos =  tempItem.transform.localPosition
			self:SetRotate(distance,tempItem)
			 if distance < -self.extents then			 		
			 		 pos.x = pos.x+self.extents * 2
			 		 self:UpdateRectsize(pos.x,pos.y)
					 tempItem.transform.localPosition = pos
			 		
			 elseif distance >self.extents then
					pos.x = pos.x-self.extents * 2
					tempItem.transform.localPosition = pos
			 end
		end
	end

end

function HorizontalScrollViewBaseCls:SetRotate(distance,item)
	local tempValue = (distance+self.width/2)/self.width
	local value = math.abs(tempValue)
	if self.currentButton then
		
		if value<0.5 then
			self.currentButton.SelectChallengdungeonStage.enabled=false
			self.currentButton=item
			self.currentButton.SelectChallengdungeonStage.enabled=true
		end
	else
		if value<0.5 then
			self.currentButton=item
			self.currentButton.SelectChallengdungeonStage.enabled=true
		end
	end
	--print(tempValue,item.Title.text)
	if -tempValue*10<-10 then
		item.transform.localEulerAngles=Vector3(0,-10,0)
	else
		item.transform.localEulerAngles=Vector3(0,-tempValue*10,0)
	end
	local tempScale=1-math.abs(tempValue/10)
	item.transform.localScale = Vector3(tempScale, tempScale, 1)

end
return HorizontalScrollViewBaseCls

