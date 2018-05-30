local PrincessSystemGuide = Class(LuaObject)

function PrincessSystemGuide:Ctor(id,tables)
	self.id=id
	self.tables=tables
    	hzj_print("PrincessSystemGuide:Ctor(id)",id)
   	self:InitSystemGuideStep()
   	self.currenStep=nil
end
function PrincessSystemGuide:InitSystemGuideStep()
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
	self.step[1].stepInfo="守护雅典娜是获取金币和高级装备的好地方，守护的层数越高，奖励也越丰厚"
	self.step[1].stepInfoPos=1
	self.step[1].nextStep=nil

	self.step[2]={}
	self.step[2].stepIndex=2
	self.step[2].stepType=1
	self.step[2].stepButton=nil
	self.step[2].stepPortraitPos=1
	self.step[2].stepInfo="在守护雅典娜中可以雇佣军团的佣兵进行战斗，不过可是要花钱的呦"
	self.step[2].stepInfoPos=1
	self.step[2].nextStep=nil


	for i=1,#self.step-1 do
		self.step[i].nextStep=self.step[i+1]
	end
	-- for i=1,#self.step do
	-- 	hzj_print(self.step[i].stepIndex,self.step[i].nextStep)
	-- end
end
function PrincessSystemGuide:GetSystemGuideNextStep()
	if 	self.currenStep == nil then
		self.currenStep=self.step[1]
	else
		self.currenStep=self.currenStep.nextStep
	end
	

	return self.currenStep
end
return PrincessSystemGuide