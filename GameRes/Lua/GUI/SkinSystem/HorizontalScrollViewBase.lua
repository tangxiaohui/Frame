-- local BaseNodeClass = require "Framework.Base.UINode"
-- local utility = require "Utils.Utility"
-- require "Collection.OrderedDictionary"
-- -- local net = require "Network.Net"
-- -- local messageManager = require "Network.MessageManager"
-- local HorizontalScrollViewBaseCls = Class(BaseNodeClass)
-- require "System.LuaDelegate"

-- function HorizontalScrollViewBaseCls:Ctor(parent,width,height,itemNum,skinId,chapter)
-- 	self.rowCount=1
-- 	self.width=width
-- 	self.height=height
-- 	self.itemNum=itemNum
-- 	self.parent=parent
-- 	self.skinId = skinId
-- 	local tempWidth=width*itemNum
-- 	if tempWidth>1000 then
-- 		self.viewWidth=1000
-- 	else
-- 		self.viewWidth=tempWidth
-- 	end
-- 	self.viewHeight=height
-- 	self.Chapter=chapter
-- 	self.itemsDic = OrderedDictionary.New()
-- 	self.callback = LuaDelegate.New()
-- 	self.childCallback = LuaDelegate.New()
-- 	self.firstMove=true
-- 	-- print(self.itemNum,self.Chapter,#self.Chapter)
-- end
-- -----------------------------------------------------------------------
-- function HorizontalScrollViewBaseCls:SetCallback(table,func)
-- 	self.callback:Set(table,func)
-- end
-- function HorizontalScrollViewBaseCls:SetDidChildCallback(table,func)
-- 	self.childCallback:Set(table,func)
-- end
-- -----------------------------------------------------------------------
-- --- 场景状态
-- -----------------------------------------------------------------------
-- function HorizontalScrollViewBaseCls:OnInit()
-- 	-- 加载界面(只走一次)
-- 	utility.LoadNewGameObjectAsync('UI/Prefabs/HorizontalScrollViewBase', function(go)
-- 		self:BindComponent(go)
-- 	end)
--  end

-- function HorizontalScrollViewBaseCls:OnComponentReady()
-- 	-- 界面加载完毕 初始化函数(只走一次)
-- 	self:InitControls()
-- 	--self:LinkComponent(self.parent)

-- end

-- function HorizontalScrollViewBaseCls:OnResume()
-- 	-- 界面显示时调用
-- 	HorizontalScrollViewBaseCls.base.OnResume(self)
-- 	self:RegisterControlEvents()
-- 	self:InitViews()
-- 	self.contentChange=false
-- 	--self:RegisterNetworkEvents()
-- 	self:ScheduleUpdate(self.Update)
-- 	self.first=false
-- 	self.firstMove=false
-- 	self.num=1
	

-- end
-- local  function NeedShowItem(self,i)
	
-- 	local tempItem = self.itemsDic:GetEntryByKey(i)
	

-- end
-- function HorizontalScrollViewBaseCls:OnPause()
-- 	-- 界面隐藏时调用
-- 	HorizontalScrollViewBaseCls.base.OnPause(self)
-- 	self:UnregisterControlEvents()
-- --	self:UnregisterNetworkEvents()
-- end

-- function HorizontalScrollViewBaseCls:OnEnter()
-- 	-- Node Enter时调用
-- 	HorizontalScrollViewBaseCls.base.OnEnter(self)
-- end

-- function HorizontalScrollViewBaseCls:OnExit()
-- 	-- Node Exit时调用
-- 	HorizontalScrollViewBaseCls.base.OnExit(self)
-- end

-- -----------------------------------------------------------------------
-- --- 控件相关
-- -----------------------------------------------------------------------
-- -- # 控件绑定
-- function HorizontalScrollViewBaseCls:InitControls()
-- 	local transform = self:GetUnityTransform()
-- 	self.ScrollRect = transform:GetComponent(typeof(UnityEngine.UI.ScrollRect))
-- 	self.Content = transform:Find('Viewport/Content')
-- 	self:InitNoteInfos()
-- 	self.currentButton=nil	
-- end


-- function  HorizontalScrollViewBaseCls:InitNoteInfos()	
-- 	--初始化ScrollRect的相关信息
-- 	self:InitValue()
-- 	self:InitItems()

-- end


	

-- function HorizontalScrollViewBaseCls:InitViews()	
-- 	self:ResetChildPosition()
-- end
-- --初始化数值
-- function HorizontalScrollViewBaseCls:InitValue()

--  	if self.rowCount <= 0 then
--             self.rowCount = 1
--     end
-- 	self.mTrans=self:GetUnityTransform()
--     self.mRTrans=self.mTrans:GetComponent(typeof(UnityEngine.RectTransform))    
-- 	self.mTrans:SetParent(self.parent)
-- 	self.mTrans.localPosition = Vector3(0,0,0)
-- 	self.mRTrans.sizeDelta=Vector2(self.viewWidth,self.viewHeight)     
	
-- 	 --ScrollView 显示区域大小
-- 	self.contentSize=self.mRTrans.sizeDelta
-- 	self.conners={}
-- 	self.conners[1] = Vector3(-self.contentSize.x / 2, self.contentSize.y / 2, 0);
-- 	self.conners[2] = Vector3(self.contentSize / 2, self.contentSize.y / 2, 0);
-- 	self.conners[3] = Vector3(-self.contentSize.x / 2, -self.contentSize.y / 2, 0);
-- 	self.conners[4] = Vector3(self.contentSize.x / 2, -self.contentSize.y / 2, 0);
-- 	-- print( #self.conners)
-- 	for i=1,#self.conners do     
-- 	 	--print(self.conners[i].x,self.conners[i].y,self.conners[i].z)
-- 	 	local temp = self.mTrans:TransformPoint(Vector3(self.conners[i].x,self.conners[i].y,self.conners[i].z));
-- 	    self.conners[i].x = temp.x;
-- 	    self.conners[i].y = temp.y;
-- 	 end
-- 	--//设置panel的中心在左上角
-- 	self.mRTrans.pivot = Vector2(0.5, 0.5);
-- 	self.mRTrans.anchorMin =  Vector2(0.5, 0.5);
-- 	self.mRTrans.anchorMax =  Vector2(0.5, 0.5);  
--     self.mContentTrans=self.Content
-- 	self.mContentRTrans=self.mContentTrans:GetComponent(typeof(UnityEngine.RectTransform)) 
-- 	--//设置panel的中心在左上角 
-- 	self.mContentRTrans.pivot = Vector2(0, 1);
-- 	self.mContentRTrans.anchorMin =  Vector2(0, 1);
-- 	self.mContentRTrans.anchorMax =  Vector2(0, 1);  
-- 	self.lastValue= 100000;
   
-- end


--  function HorizontalScrollViewBaseCls:ChildInitOKCallBack()
	
-- 	self.itemOkNum=self.itemOkNum+1
-- 	--print(self.itemOkNum)
-- 	if self.itemNum ==self.itemOkNum then
-- 	--	print("初始化完成")
-- 		self:Move()
-- 		self.callback:Invoke()
-- 		NeedShowItem(self,2)
-- 	end
-- 	debug_print(self.itemNum,"self.itemNum")
-- 	if self.itemNum<=1 then
-- 		self.ScrollRect.enabled=false
-- 	end	
-- end 


--  function HorizontalScrollViewBaseCls:ChildClickedCallBack(table)
--  	--print(type(info))
-- 	print("ChildClickedCallBack")--,self.info.data:GetChapterInfo():GetName())
-- 	print(type(table),table.ChapterID)
-- 	self.childCallback:Invoke(table)
-- end 

-- function HorizontalScrollViewBaseCls:InitItems()
-- 	self.itemOkNum=0
	
-- 	for i=1,self.itemNum do
-- 		local item = require "GUI.SkinSystem.SkinCardItem".New(self,self.Content,self.width,self.height,self.skinId[i - 1],self.Chapter)
-- 			self:AddChild(item)
-- 			item:SetCallback(self,self.ChildInitOKCallBack)
-- 			item:SetDidCallback(self,self.ChildClickedCallBack)
-- 			self.itemsDic:Add(i,item)
-- 	end
-- end

-- --重置子类的位置
-- function  HorizontalScrollViewBaseCls:ResetChildPosition()
-- 	--起始位置
-- 	local startAxis={}
-- 	startAxis.x=self.width/2
--     startAxis.y=self.height/2
-- 	--item数量
-- 	local childCount = self.itemsDic:Count()
-- 	local rows = self.rowCount
-- 	--计算列数
-- 	local cols =( math.floor(childCount/rows))	
-- 	--范围
-- 	self.extents=(cols * self.width) * 0.5
-- 	--print(childCount)
-- 	for i=1,childCount do
-- 	--	print(i)
-- 		local tempItem = self.itemsDic:GetEntryByKey(i)
-- 	--	print(tempItem)
-- 		if  tempItem ~=nil then
-- 			--行号  和列号
-- 			local x = (i-1)-math.floor((i-1)/rows)*rows
-- 			local y = math.floor((i-1)/rows)	
-- 			debug_print(startAxis.x + y * self.width+(y+1)*20," dddddddddd")		
--  			tempItem:SetPosition (startAxis.x + y * self.width, startAxis.y - x * self.height)
--  			--tempItem.gameObject.SetActive(true);
--  			self:UpdateRectsize(startAxis.x + y * self.width, startAxis.y - x * self.height)
-- 		else
-- 			print("child 为空")
-- 		end 
-- 	end
	


-- end

-- --更新content尺寸
-- function HorizontalScrollViewBaseCls:UpdateRectsize( width,height)

-- 	-- body
-- 	self.mContentRTrans.sizeDelta=Vector2(width+self.width/2,self.rowCount*self.height)
-- 	print(self.mContentRTrans.sizeDelta.x,self.mContentRTrans.sizeDelta.y)
-- end
-- --更新Item
-- function HorizontalScrollViewBaseCls:UpdateItem()
-- 	self.contentChange=true
-- end

-- function HorizontalScrollViewBaseCls:RegisterControlEvents()

-- 	-- 注册 Scroll_View 的事件
-- 	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
-- 	self.ScrollRect.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

-- end

-- function HorizontalScrollViewBaseCls:UnregisterControlEvents()


-- 	-- 取消注册 Scroll_View 的事件
-- 	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
-- 		self.ScrollRect.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
-- 		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
-- 	end


-- end

-- -----------------------------------------------------------------------
-- --- 事件处理
-- -----------------------------------------------------------------------

-- -- function HorizontalScrollViewBaseCls:Change( ... )
-- -- 	-- body
-- -- end

-- function HorizontalScrollViewBaseCls:OnScroll_ViewValueChanged(posXY)

	
-- 	self:Move()
-- 	if self.contentChange then
-- 		--print(false)
-- 	else
-- 	--	if math.abs(self.lastValue - self.mContentTrans.localPosition.x)<0.00001 then
-- 		if self.lastValue - self.mContentTrans.localPosition.x >0.1 and self.lastValue~=0  then
-- 			--print_debug("**********************************")
-- 			self.ScrollRect:StopMovement()
-- 			self:UnregisterControlEvents()

-- 	   		self.lastValue=0
-- 			self.moveDirLeft=true   --表示向右
-- 			self:MoveEnd()
-- 			self.contentChange=true
-- 		elseif self.lastValue - self.mContentTrans.localPosition.x <-0.1 and self.lastValue~=0 then
-- 		--	print_debug("*****++++++++++++++++++++++++++*******")

-- 			self.moveDirRight=true
-- 			self.ScrollRect:StopMovement()
-- 	   		self.lastValue=0
-- 			self:MoveEnd()
-- 			self:UnregisterControlEvents()
-- 			self.contentChange=true
-- 		--end
		
-- 	 --	print(self.lastValue,self.mContentTrans.localPosition.x)
-- 	   -- if math.abs(self.lastValue - self.mContentTrans.localPosition.x)<0.01 then
	  
-- 	   -- 		self.ScrollRect:StopMovement()
-- 	   -- 		self.lastValue=0
-- 	   -- 		self:MoveEnd()
-- 	   -- 		self.contentChange=true
-- 	   else
-- 	   		--self:Move()
-- 	   		self.lastValue = self.mContentTrans.localPosition.x;
	   
-- 	   	end
-- 	 end
	
	
-- end

-- function HorizontalScrollViewBaseCls:Update()
-- 	if self.contentChange then
-- 		self:ChangeContentPositon()
-- 	end
	
-- end
-- function HorizontalScrollViewBaseCls:MoveEnd()
	
-- 	--self.contentChange=true
-- 	self.currentChangeTime=0
-- 	self.totalChangeTime=0.5
-- 	local conner_local = {}
-- 	local TweenUtility = require "Utils.TweenUtility"
-- 	for i=1,4 do		
-- 		conner_local[i]=self.mContentTrans:InverseTransformPoint(Vector3(self.conners[i].x,self.conners[i].y,self.conners[i].z))
-- 	end

-- 	local  contentLenth = self.mContentTrans.localPosition.x;

-- 	if  (contentLenth)-math.floor((contentLenth)/self.width)*self.width >self.width/2 then
--  		self.contentEndPos=(math.floor(contentLenth / self.width)+1)*self.width

-- 	elseif (contentLenth)-math.floor((contentLenth)/self.width)*self.width <-self.width/2 then
-- 		self.contentEndPos=(math.floor(contentLenth / self.width)-1)*self.width
-- 	else
-- 		self.contentEndPos=(math.floor(contentLenth / self.width))*self.width
-- 	end

-- 	if self.itemNum%2==0 then
-- 		self.contentEndPos = self.contentEndPos+self.width/2
-- 	end









-- 	-- print_debug(self.moveDirLeft,self.moveDirRight,self.contentEndPos)
-- 	if self.moveDirLeft ~= nil and self.moveDirLeft == true then
-- 		self.contentEndPos = self.contentEndPos-self.width
-- 	end

-- 	if self.moveDirRight ~=nil and self.moveDirRight ==true then
-- 		self.contentEndPos = self.contentEndPos+self.width
-- 		if self.itemNum%2==0 then
-- 			self.contentEndPos = self.contentEndPos-self.width
-- 		end
-- 	end
-- end


-- --修改图片的形状
-- function HorizontalScrollViewBaseCls:ChangeContentPositon()
 	
--  		local TweenUtility = require "Utils.TweenUtility"
--        	local t = self.currentChangeTime/self.totalChangeTime
--        	self.currentChangeTime=self.currentChangeTime+Time.deltaTime
       
--        	if t>=1 then
       		
--        		self.num=self.num+1
--        		if self.num>=2 then
--        		self.firstMove =false   
--        		end
--        		 self.moveDirLeft =false
--        		 self.contentChange=false   
--        		 self.moveDirRight=false
--        		 self:RegisterControlEvents()
--        		else  
       	
-- 	 	end
--        	local s = TweenUtility.Linear(self.mContentTrans.localPosition.x, self.contentEndPos,t)
-- 		self.mContentTrans.localPosition=Vector3(s,self.mContentTrans.localPosition.y,self.mContentTrans.localPosition.z)
     	
--        if self.firstMove ==false then
-- 	    local conner_local = {}
-- 		for i=1,4 do
-- 			conner_local[#conner_local+1]=self.mContentTrans:InverseTransformPoint(Vector3(self.conners[i].x,self.conners[i].y,self.conners[i].z))
-- 		end

-- 		local center =(conner_local[4] + conner_local[1])/2
-- 		for i=1,self.itemsDic:Count() do
-- 			local tempItem = self.itemsDic:GetEntryByKey(i)
-- 			if  tempItem ~=nil then
-- 				local distance = tempItem.transform.localPosition.x - center.x;
-- 				-- if self.itemNum%2==0 then
-- 				-- 	distance = tempItem.transform.localPosition.x - center.x+self.width;
-- 				-- end
-- 				self:SetRotate(distance,tempItem)
-- 			end
-- 		end
-- 	end
    
-- end

-- local num = 0
-- function HorizontalScrollViewBaseCls:Move()
-- 	-- body
-- 	local conner_local = {}
-- 	for i=1,4 do
-- 		conner_local[#conner_local+1]=self.mContentTrans:InverseTransformPoint(Vector3(self.conners[i].x,self.conners[i].y,self.conners[i].z))
-- 	end

-- 	local center =(conner_local[4] + conner_local[1])/2
-- 	debug_print(center,"conner_",center.x,center.y)
-- 	local min = conner_local[1].x-self.width
-- 	local max = conner_local[4].x+self.width
-- 	for i=1,self.itemsDic:Count() do
-- 		local tempItem = self.itemsDic:GetEntryByKey(i)
-- 		if  tempItem ~=nil then
-- 			local distance = tempItem.transform.localPosition.x - center.x;
-- 			local pos =  tempItem.transform.localPosition
-- 			self:SetRotate(distance,tempItem)
-- 			-- print_debug("aaaaaaaaaa",distance,self.extents)
-- 			 if distance < -self.extents then	
-- 			 		num=num+1		 		
-- 			 		 pos.x = pos.x+self.extents * 2
-- 			 		 self:UpdateRectsize(pos.x,pos.y)
-- 					 tempItem.transform.localPosition = pos
-- 					 -- print_debug("******************************************************")
-- 					 tempItem:ResetMessage(num)
			 		
-- 			 elseif distance >self.extents then
-- 			 	num=num-1
-- 					 -- print_debug("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")

-- 					pos.x = pos.x-self.extents * 2
-- 					self:UpdateRectsize(pos.x,pos.y)
-- 					tempItem.transform.localPosition = pos
-- 					tempItem:ResetMessage(num)
-- 			 end
-- 		end
-- 	end

-- end

-- function HorizontalScrollViewBaseCls:SetRotate(distance,item)
-- 	local tempValue
-- 	tempValue = (distance)/self.width
-- 	-- if self.itemNum%2==1 then
-- 	-- 	tempValue = (distance)/self.width
-- 	-- else
-- 	-- 	tempValue = (distance-self.width/2)/self.width
-- 	-- end
-- 	local value = math.abs(tempValue)
-- 	if self.currentButton then
		
-- 		if value<0.5 then
-- 		--	self.currentButton.SelectChallengdungeonStage.enabled=false
-- 			self.currentButton=item
-- 		--	self.currentButton.SelectChallengdungeonStage.enabled=true
-- 		end
-- 	else
-- 		if value<0.5 then
-- 			self.currentButton=item
-- 		--	self.currentButton.SelectChallengdungeonStage.enabled=true
-- 		end
-- 	end
-- 	--print(tempValue,item.Title.text)
-- 	-- if -tempValue*10<-10 then
-- 	-- 	item.transform.localEulerAngles=Vector3(0,-10,0)
-- 	-- else
-- 	-- 	item.transform.localEulerAngles=Vector3(0,-tempValue*10,0)
-- 	-- end
-- 	local tempScale=1-math.abs(tempValue/3)
-- 	item.transform.localScale = Vector3(tempScale, tempScale, 1)

-- end
-- return HorizontalScrollViewBaseCls

