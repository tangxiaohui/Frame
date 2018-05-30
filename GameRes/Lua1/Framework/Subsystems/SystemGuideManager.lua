require "Framework.GameSubSystem"
local game = require "Game.Cos3DGame"
local utility = require "Utils.Utility"
local playerPrefsUtils = require "Utils.PlayerPrefsUtils"


local SystemGuideManager = Class(GameSubSystem)

function SystemGuideManager:Ctor()

	
end

---------------------------------------------------------------------------
------- 实现 GameSubSystem 的接口
---------------------------------------------------------------------------
function SystemGuideManager:GetGuid()
    return require "Framework.SubsystemGUID".SystemGuideManager
end

function SystemGuideManager:Startup()
	--第一次进入（因为是若引导 所以第一次进入如果退出就表示做完）
	self.firstStep=false
	-- UnityEngine.PlayerPrefs.DeleteAll()


end

function SystemGuideManager:Shutdown()

end

function SystemGuideManager:Restart()
end

function SystemGuideManager:Update()

end

function SystemGuideManager:SetNeetSystemGuideID(id,tables)
	if utility.GetGame():GetGuideManager():IsAllDone() == false then
		hzj_print("服务器新手引导没有做完")
		return

	end
	--hzj_print(id,tables,"id,tables",debug.traceback())
	if kSystem_Guide[id].modleId~=nil then
		local isOpen = utility.IsCanOpenModule(kSystem_Guide[id].modleId,true)
		hzj_print("isOpen",isOpen,id)
	    if not isOpen then
	        return
	    end
    end
    hzj_print(id,tables,"id,tables",debug.traceback())


	--表示第一进入 判断是否做完了
	if self.currentId==nil then
		if self:SystemGuideIsDone(id) then
			hzj_print("第一次进入引导 做完了")
			return
		else
			hzj_print("第一次进入引导 没有做完了")

		end
	--非第一次进入
	else
		--表示是当前的引导
		if self.currentId == id then
			hzj_print("继续当前引导")
			if self.currentGuideWindow ~=nil then
				self.currentGuideWindow:DoNextStepGuide()
			end
			return

		else
			hzj_print('不是当前引导')

		end
		return
	end

	if kSystem_Guide[1].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.ElvenTreeSystemGuide".New(id,tables)
	elseif kSystem_Guide[2].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.ExploreSystemGuide".New(id,tables)	
	elseif kSystem_Guide[3].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.CheckpointSystemGuide".New(id,tables)
	elseif kSystem_Guide[4].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.DragonChallengeSystemGuide".New(id,tables)
	elseif kSystem_Guide[5].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.ZodiacFirstSystemGuide".New(id,tables)
	elseif kSystem_Guide[6].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.ZodiacSecondSystemGuide".New(id,tables)
	elseif kSystem_Guide[7].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.SeaChallengeSystemGuide".New(id,tables)
	elseif kSystem_Guide[8].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.MagicChallengeSystemGuide".New(id,tables)
	elseif kSystem_Guide[9].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.LiveChallengeSystemGuide".New(id,tables)
	elseif kSystem_Guide[10].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.TaskSystemGuide".New(id,tables)
	elseif kSystem_Guide[11].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.GuildSystemGuide".New(id,tables)
	elseif kSystem_Guide[12].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.PrincessSystemGuide".New(id,tables)
	elseif kSystem_Guide[13].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.TowerSystemGuide".New(id,tables)
	elseif kSystem_Guide[14].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.TarotFirstSystemGuide".New(id,tables)
	elseif kSystem_Guide[15].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.TarotSecondSystemGuide".New(id,tables)
	elseif kSystem_Guide[16].systemGuideID == id then
		self.currentSystemGuide=require "GUI.SystemGuide.TarotThirdSystemGuide".New(id,tables)
	end
	if self.currentSystemGuide ~=nil then
		self:DoSystemGuide()
		self.currentId=id 
	else
		hzj_print("要做的系统引导不存在不存在")
	end
	
end




function SystemGuideManager:UpdateCurrentSystemGuideTable(tables)
	self.currentSystemGuide:UpdateTableData()

end
function SystemGuideManager:DoneSystemGuideCallBack(self)

	hzj_print("DoneSystemGuideCallBack",self.currentId)
	 self.currentId=nil
	 self.currentGuideWindow=nil
end
function SystemGuideManager:DoSystemGuide()
	local windowManager = utility.GetGame():GetPersistentWindowManager()
	self.currentGuideWindow=windowManager:Show(require "GUI.SystemGuide.NewPlayerGuide",self.currentSystemGuide,self.DoneSystemGuideCallBack,self)


end

function SystemGuideManager:SystemGuideIsDone(id)
	local UserDataType = require "Framework.UserDataType"
	local userData = utility.GetGame():GetDataCacheManager():GetData(UserDataType.PlayerData)
	local str = userData:GetUid()..kSystem_Guide[id].systemGuideStr
	-- self.PersonalInformationNameLabel.text = userData:GetName()
	-- self.PersonalInformationPlayerIdLabel.text = userData:GetUid()
  
	local state = UnityEngine.PlayerPrefs.GetInt(str,0)
	hzj_print("SystemGuideIsDone",id,state)

	if state == 0 then
		 UnityEngine.PlayerPrefs.SetInt(str,1)
		 return false
	else
		return true
	end

end


return SystemGuideManager