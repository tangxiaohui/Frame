
require "Game.Role"
require "Collection.OrderedDictionary"
require "Data.LineupData"
require "Const"

RedDotData = Class(LuaObject)

function RedDotData:Ctor()
    self.moduleRed = {}
    self.cardRed = {}
	self.chengjiu = {}
	self.tujianCard = {}
	self.tujianEquip = {}
	self.activeInfo = {}
    self.sevenDay = {}
end

function RedDotData:UpdateGroupModuleRed(modules, red)
    for i=1,#modules do
        local moduleID = modules[i]
        local redState = red[i]
        if self.moduleRed[moduleID] ~= redState then
            self.moduleRed[moduleID] = redState
        end
    end
end

function RedDotData:UpdateGroupCardRed(cards, red)
    for i=1,#cards do
        local cardUID = cards[i]
        local redState = red[i]
        if self.cardRed[cardUID]~= redState then
            self.cardRed[cardUID] = redState
        end
    end
end

function RedDotData:UpdateOneModuleRed(moduleID, red)
    if self.moduleRed[moduleID] ~= red then
        self.moduleRed[moduleID] = red
        return true
    end
    return false
end

function RedDotData:UpdateOneCardRed(cardUID, red)
    if self.cardRed[cardUID] ~= red then
        self.cardRed[cardUID] = red
        return true
    end
    return false
end

--更新成就
function RedDotData:SetChengjiuInfo(chengjiu)

    for i = 1,#chengjiu do 
        debug_print(chengjiu[i].sonid.."成就"..chengjiu[i].red)
    end


	if self.chengjiu ~= nil and chengjiu ~= nil then 
		self.chengjiu = self:SetServerData(self.chengjiu,chengjiu)
	end
    for i = 1,#self.chengjiu do 
        debug_print(self.chengjiu[i].sonid.."成就"..self.chengjiu[i].red)
    end
	-- self.chengjiu = chengjiu
end

--更新图鉴卡牌
function RedDotData:SetCollectionCardInfo(data)
	if self.tujianCard ~= nil and data ~= nil then 
		self.tujianCard = self:SetServerData(self.tujianCard,data)
	end
end

--更新图鉴装备
function RedDotData:SetCollectionEquipInfo(data)
	if self.tujianEquip ~= nil and data ~= nil then 
		self.tujianEquip = self:SetServerData(self.tujianEquip,data)
	end
end

--更新活动
function RedDotData:SetActiveInfo(data)
	if self.activeInfo ~= nil and data ~= nil then
        for i = 1,#data do 
         debug_print(data[i].activityID.."SetActiveInfo"..data[i].red,data[i].subID)
        end
		self.activeInfo = self:SetActivityServerData(self.activeInfo,data)
	end

    debug_print("***********************")
    for i = 1,#self.activeInfo do 
        debug_print(i,self.activeInfo[i].activityID.."SetActiveInfo"..self.activeInfo[i].red,self.activeInfo[i].subID)
    end

    -- for i = 1,#data do 
    --         debug_print(data[i].activityID.."红点："..data[i].red,data[i].subID)
    -- end
 
     debug_print("--------------------------")

end

--更新七日狂欢
function RedDotData:SetSevenDayInfo(data)
    debug_print("SetSevenDayInfo")
    if self.sevenDay ~= nil and data ~= nil then
    	-- for i = 1,#data do 
    	-- 	debug_print(data[i].activityID.."红点："..data[i].red,data[i].subID)
    	-- end
        self.sevenDay = self:SetSevenServerData(self.sevenDay,data)
    end
    -- debug_print("***********************")
    -- for i = 1,#self.sevenDay do 
    --     debug_print(i,self.sevenDay[i].activityID.."sevenDay"..self.sevenDay[i].red,self.sevenDay[i].subID)
    -- end

    -- -- for i = 1,#data do 
    -- --         debug_print(data[i].activityID.."红点："..data[i].red,data[i].subID)
    -- -- end
 
    --  debug_print("--------------------------")
end
--更新服务器数据
function RedDotData:SetActivityServerData(tables,data)
    local activityID = {}
    local isInclude = false
    for j = 1,#tables do
        activityID[j] = tables[j].activityID
    end

    for j = 1,#activityID do
        debug_print("SetActiveInfo",activityID[j])
    end
    for i = 1,#data do
        isInclude = self:Is_include(data[i].activityID,activityID)
        if isInclude then
          debug_print("SetActiveInfoxiugai状态",data[i].activityID,activityID)
            for j = 1,#tables do
                if tables[j].activityID == data[i].activityID then
                    tables[j] = data[i]
                    break
                end
            end
        else
            debug_print("SetActiveInfo添加状态",data[i].activityID,activityID[i])
            tables[#tables + 1] = data[i]
            activityID[#activityID+1]=data[i].activityID
        end
    end
    return tables
end



--更新服务器数据
function RedDotData:SetSevenServerData(tables,data)
    local subID = {}
    local isInclude = false
    for j = 1,#tables do
        subID[j] = tables[j].subID
    end
    for i = 1,#data do
        isInclude = self:Is_include(data[i].subID,subID)
        if isInclude then
        --  debug_print("xiugai状态",data[i].subID,subID)
            for j = 1,#tables do
                if tables[j].subID == data[i].subID then
                    tables[j] = data[i]
                    break
                end
            end
        else
           -- debug_print("添加状态",data[i].subID,subID)
            tables[#tables + 1] = data[i]
        end
    end
    return tables
end

--更新服务器数据
function RedDotData:SetServerData(tables,data)
	local sonID = {}
	local isInclude = false
	for j = 1,#tables do
		sonID[j] = tables[j].sonid
	end
	for i = 1,#data do
		isInclude = self:Is_include(data[i].sonid,sonID)
		if isInclude then
			for j = 1,#tables do
				if tables[j].sonid == data[i].sonid then
					tables[j] = data[i]
					break
				end
			end
		else
			tables[#tables + 1] = data[i]
		end
	end
	return tables
end

function RedDotData:Is_include(value, tab)
    for k,v in pairs(tab) do
      if v == value then
          return true
      end
    end
    return false
end

function RedDotData:GetChengjiu()
	return self.chengjiu
end

function RedDotData:GetCollectionCardInfo()
	return self.tujianCard
end

function RedDotData:GetCollectionEquipInfo()
	return self.tujianEquip
end

function RedDotData:GetActiveInfo()
	return self.activeInfo
end

function RedDotData:GetServerDayInfo()
    return self.sevenDay
end
function RedDotData:GetMainUIChengJiuState()
    debug_print("GetMainUIChengJiuState",#self.chengjiu,self.chengjiu)
    if self.chengjiu ~= nil  then
        for i = 1,#self.chengjiu  do 
            if self.chengjiu[i].red == 1 then
                 debug_print(self.chengjiu[i].sonid.."  chengjiu  "..self.chengjiu[i].red)
                 return true
            else
                return false
            end
        end
    else
        return false
    end
end
function RedDotData:GetMainUISevenDayState()
    debug_print("SetSevenDayInfo",#self.sevenDay)
    if self.sevenDay ~= nil  then
        for i = 1,#self.sevenDay  do 
            if self.sevenDay[i].red == 1 then
                 debug_print(self.sevenDay[i].activityID.."  红点"..self.sevenDay[i].red,self.sevenDay[i].subID)
                 return true
            else
                return false
            end
        end
    else
        return false
    end
end

function RedDotData:GetModuleRedState(moduleID)
    if self.moduleRed[moduleID] then
        return self.moduleRed[moduleID]
    end
    return 0
end

function RedDotData:GetCardRedData(cardUID)
    if self.cardRed[cardUID] then
        return self.cardRed[cardUID]
    end
    return 0
end
