local ZodiacSecondSystemGuide = Class(LuaObject)

function ZodiacSecondSystemGuide:Ctor(id,tables)
	self.id=id
	self.tables=tables
    	hzj_print("ZodiacSecondSystemGuide",self.tables.itemStar.star[1].spot[0].preparedBtn )
   	self:InitSystemGuideStep()
   	self.currenStep=nil
end
function ZodiacSecondSystemGuide:InitSystemGuideStep()
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
	self.step[1].stepInfo="星宫模块开启了，快来体验一下吧"
	self.step[1].stepInfoPos=1
	self.step[1].nextStep=nil

	self.step[2]={}
	self.step[2].stepIndex=2
	self.step[2].stepType=2
	self.step[2].stepButton=self.tables.itemStar.star[1].spot[0].preparedBtn 
	self.step[2].stepPortraitPos=2
	self.step[2].stepInfo="点击第一个模块"
	self.step[2].stepInfoPos=1
	self.step[2].nextStep=nil

	self.step[3]={}
	self.step[3].stepIndex=3
	self.step[3].stepType=2
	self.step[3].stepButton=self.tables.ActiveButton 
	self.step[3].stepPortraitPos=2
	self.step[3].stepInfo="点击点亮按钮，给人物添加属性"
	self.step[3].stepInfoPos=1
	self.step[3].nextStep=nil

	

	hzj_print(self.step[2].stepButton,"傻逼",self.tables.ElvenTreeFormationImageButton)

	for i=1,#self.step-1 do
		self.step[i].nextStep=self.step[i+1]
	end
	-- for i=1,#self.step do
	-- 	hzj_print(self.step[i].stepIndex,self.step[i].nextStep)
	-- end
end

-- function ZodiacSystemGuide:UpdateTableData(tables)
-- 	self.tables=tables
-- 	self:InitSystemGuideStep()
-- end
function ZodiacSecondSystemGuide:GetSystemGuideNextStep()
	if 	self.currenStep == nil then
		self.currenStep=self.step[1]
	else
		self.currenStep=self.currenStep.nextStep
	end
	

	return self.currenStep
end
return ZodiacSecondSystemGuide