local ElvenTreeSystemGuide = Class(LuaObject)

function ElvenTreeSystemGuide:Ctor(id,tables)
	self.id=id
	self.tables=tables
    	hzj_print("ElvenTreeSystemGuide:Ctor(id)",id)
   	self:InitSystemGuideStep()
   	self.currenStep=nil
end
function ElvenTreeSystemGuide:InitSystemGuideStep()
	--stepIndex 表示是引导的第几步骤
	--stepType 表示是引导按钮类型 1表示是 背景是按钮 2 表示是特定的button
	--stepInfo 表示是引导要显示的消息
	--stepPortraitPos 表示是引导立绘显示位置
	--stepInfoPos 表示是引导消息显示位置
	--nextStep 表示是引导要下一个步骤 nil 表示没有下一个步骤
	self.step={}
	self.step[1]={}
	self.step[1].stepIndex=1
	self.step[1].stepType=1
	self.step[1].stepButton=nil
	self.step[1].stepPortraitPos=1
	self.step[1].stepInfo="副本中获取的宠物蛋，可以在精灵树孵化。孵化好的蛋有概率开出宠物的呦"
	self.step[1].stepInfoPos=1
	self.step[1].nextStep=nil

	self.step[2]={}
	self.step[2].stepIndex=2
	self.step[2].stepType=2
	self.step[2].stepButton=self.tables.ElvenTreeFormationImageButton
	self.step[2].stepPortraitPos=2
	self.step[2].stepInfo="先上阵防守阵容"
	self.step[2].stepInfoPos=1
	self.step[2].nextStep=nil


	self.step[3]={}
	self.step[3].stepIndex=2
	self.step[3].stepType=2
	self.step[3].stepButton=self.tables.ElvenTreeSnatchButton
	self.step[3].stepPortraitPos=2
	self.step[3].stepInfo="点击掠夺"
	self.step[3].stepInfoPos=1
	self.step[3].nextStep=nil

	self.step[4]={}
	self.step[4].stepIndex=2
	self.step[4].stepType=2
	self.step[4].stepButton=self.tables.LevelUpButton
	self.step[4].stepPortraitPos=2
	self.step[4].stepInfo="点击培养按钮,培养精灵树"
	self.step[4].stepInfoPos=1
	self.step[4].nextStep=nil


	hzj_print(self.step[2].stepButton,"傻逼",self.tables.ElvenTreeFormationImageButton)

	for i=1,#self.step-1 do
		self.step[i].nextStep=self.step[i+1]
	end
	-- for i=1,#self.step do
	-- 	hzj_print(self.step[i].stepIndex,self.step[i].nextStep)
	-- end
end
function ElvenTreeSystemGuide:GetSystemGuideNextStep()
	if 	self.currenStep == nil then
		self.currenStep=self.step[1]
	else
		self.currenStep=self.currenStep.nextStep
	end
	

	return self.currenStep
end
return ElvenTreeSystemGuide