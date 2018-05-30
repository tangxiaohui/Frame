
require "Class"

SpineController = Class()

function SpineController:Ctor()
	print("SpineController:Ctor()")
end

local function DelayTimeToPlay(self,timer)

	local currentTime = 0
	while(currentTime<timer) do
		currentTime=currentTime+Time.deltaTime
		 coroutine.step()
	end
	self:RamdomData(self)
	print("延時結束")

end

local  function AniamationDelayEnd(self)
	local delayTime =math.random(self.smallTalkData:GetNexttalkTime()[0],self.smallTalkData:GetNexttalkTime()[1])
	self.delayTimeCoroutine=coroutine.start(DelayTimeToPlay,self,delayTime) 
end

local function DelayPlayAniamation(self,timer,func)
	local currentTime = 0
	while(currentTime<timer) do
		currentTime=currentTime+Time.deltaTime
		 coroutine.step()
	end
	if self.spine~=nil then
		self.spine.timeScale = 0
	end
	self.showText.transform.parent.gameObject:SetActive(false)
	print("播放结束")

	if self.delayTimeCoroutine ~=nil then
		--coroutine.stop(co)
		coroutine.stop(self.delayTimeCoroutine)
	end

	func(self)
	

end 


------------------随机说话-------------------
function SpineController:RamdomData(self)
	--随机那一句话
	local num=math.random(self.smallTalkData:GetRandrange()[0],self.smallTalkData:GetRandrange()[1])
	self.smallTalkInfoData = self.smallTalkInfoStaticData:GetData(num)
	self.showText.transform.parent.gameObject:SetActive(true)
	self.showText.text=self.smallTalkInfoData :GetContent()
	--播放
	if self.spine~=nil then
		self.spine.timeScale = 1
	end
	--延时关闭
	if self.animCoroutine ~=nil then
		--coroutine.stop(co)
		coroutine.stop(self.animCoroutine)
	end
	self.animCoroutine=coroutine.start(DelayPlayAniamation,self,self.time,AniamationDelayEnd) 


end 


local function InitData(self)
	
	local smallTalkStaticData=require "StaticData.SmallTalk.SmallTalk"
	self.smallTalkData = smallTalkStaticData:GetData(self.id)


	self.smallTalkInfoStaticData=require "StaticData.SmallTalk.SmallTalkInfo"
	--说话的时长
	self.time = self.smallTalkData:GetTalkTime()
		
	self:RamdomData(self)


	-- print(data:GetTalkTime(),data:GetNexttalkTime()[0])
	
	-- --print(math.random(data:GetRandrange()[0],data:GetRandrange()[1]))

	-- local num=math.random(data:GetRandrange()[0],data:GetRandrange()[1])
	
	-- self.smallTalkInfoData = self.smallTalkInfoStaticData:GetData(num)
	-- print(dataInfo:GetContent())
	-- self.showText.text=dataInfo:GetContent()

	-- coroutine.start(DelayPlayAniamation,self,time) 
	-- self.spine.timeScale = 1

end







function SpineController:SetData(spine,showText,id)
	self.spine = spine
	self.showText = showText
	self.id=id
	InitData(self)
end


function SpineController:Clear()
	self.spine = nil
	self.showText = nil
end

function SpineController:ToString()
	return "SpineController"
end


function SpineController:Stop()

	self.spine = nil
	self.showText = nil
	if self.delayTimeCoroutine ~=nil then
		--coroutine.stop(co)
		coroutine.stop(self.delayTimeCoroutine)
	end

	if self.animCoroutine ~=nil then
		--coroutine.stop(co)
		coroutine.stop(self.animCoroutine)
	end
end
