---------------------------卡牌和背包红点本地计算-------------------------
--0表示没有红点
--1表示有红点
--------------------------------------------------------------------------
local messageGuids = require "Framework.Business.MessageGuids"
require "Const"
local utility = require "Utils.Utility"
r_Main_Role = 0                     --主界面角色按钮红点
r_Choose_Head = 1                   --选择英雄界面英雄头像上的红点  

r_Detail_Upgrade= 2                 --英雄详细信息界面升级红点 
r_Detail_Advanced= 3                --英雄详细信息界面进阶红点 
r_Detail_Talent= 4                  --英雄详细信息界面天赋红点 
r_Detail_TeamTalent= 5              --英雄详细信息界面团队天赋红点 



r_Detail_EquipPos= {}                 --英雄详细信息界面团队装备栏

r_Detail_EquipPos[1] = {}
r_Detail_EquipPos[1][1] = 6          --英雄详细信息界面团队装备栏1 是否可以装装备
r_Detail_EquipPos[1][2] = 7          --英雄详细信息界面团队装备栏1 是否可以可以升级    
r_Detail_EquipPos[1][3] = 8          --英雄详细信息界面团队装备栏1 是否可以可以镶嵌宝石

r_Detail_EquipPos[2] = {}
r_Detail_EquipPos[2][1] = 9         --英雄详细信息界面团队装备栏2 是否可以装装备
r_Detail_EquipPos[2][2] = 10          --英雄详细信息界面团队装备栏2 是否可以可以升级    
r_Detail_EquipPos[2][3] = 11         --英雄详细信息界面团队装备栏2 是否可以可以镶嵌宝石

r_Detail_EquipPos[3] = {}
r_Detail_EquipPos[3][1] = 12          --英雄详细信息界面团队装备栏3 是否可以装装备
r_Detail_EquipPos[3][2] = 13          --英雄详细信息界面团队装备栏3 是否可以可以升级    
r_Detail_EquipPos[3][3] = 14          --英雄详细信息界面团队装备栏3 是否可以可以镶嵌宝石

r_Detail_EquipPos[4] = {}
r_Detail_EquipPos[4][1] = 15          --英雄详细信息界面团队装备栏4 是否可以装装备
r_Detail_EquipPos[4][2] = 16          --英雄详细信息界面团队装备栏4 是否可以可以升级    
r_Detail_EquipPos[4][3] = 17         --英雄详细信息界面团队装备栏4 是否可以可以镶嵌宝石

r_Detail_EquipPos[5] = {}
r_Detail_EquipPos[5][1] = 18          --英雄详细信息界面团队装备栏5 是否可以装装备
r_Detail_EquipPos[5][2] = 19          --英雄详细信息界面团队装备栏5 是否可以可以升级 或宠物强化   
r_Detail_EquipPos[5][3] = 20          --英雄详细信息界面团队装备栏5 是否可以可以镶嵌宝石 或宠物进阶

r_Detail_EquipPos[6] = {}
r_Detail_EquipPos[6][1] = 21          --英雄详细信息界面团队装备栏6 是否可以装装备
r_Detail_EquipPos[6][2] = 22          --英雄详细信息界面团队装备栏6 是否可以可以升级    
r_Detail_EquipPos[6][3] = 23          --英雄详细信息界面团队装备栏6 是否可以可以镶嵌宝石

r_Detail_EquipPos[7] = {}
r_Detail_EquipPos[7][1] = 24          --英雄详细信息界面团队装备栏7 是否可以装装备
r_Detail_EquipPos[7][2] = 25          --英雄详细信息界面团队装备栏7 是否可以可以升级    
r_Detail_EquipPos[7][3] = 26          --英雄详细信息界面团队装备栏7 是否可以可以镶嵌宝石

r_Detail_EquipPos[8] = {}
r_Detail_EquipPos[8][1] = 27          --英雄详细信息界面团队装备栏8 是否可以装装备
r_Detail_EquipPos[8][2] = 28          --英雄详细信息界面团队装备栏8 是否可以可以升级    
r_Detail_EquipPos[8][3] = 29          --英雄详细信息界面团队装备栏8 是否可以可以镶嵌宝石

r_Choose_HeroChip      =  30          --选择英雄界面英雄碎片可以合成




local CalculateRed = {}
--当前拥有卡牌的红点
local RoleRedData = {}


--当前拥有卡牌碎片的红点
local RoleDebrisRedData = {}

function CalculateRed.GetGame()
    return require "Game.Cos3DGame"
end

function CalculateRed.GetCachedManager()
    local game = CalculateRed.GetGame()
    return game:GetDataCacheManager()
end
--获取玩家的金币
local function GetPlayerCoin()
    local UserDataType = require "Framework.UserDataType"
    local userData = CalculateRed.GetCachedManager():GetData(UserDataType.PlayerData)   
    return userData:GetCoin()
end

--获取玩家的钻石
local function GetPlayerDiamond()
    local UserDataType = require "Framework.UserDataType"
    local userData = CalculateRed.GetCachedManager():GetData(UserDataType.PlayerData)   
    return userData:GetDiamond()
end

--获取玩家等级
local function GetPlayerLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = CalculateRed.GetCachedManager():GetData(UserDataType.PlayerData)
    return userData:GetLevel()
end
--获取装备背包数据
local function GetEquipBagData()
    local UserDataType = require "Framework.UserDataType"
    return  CalculateRed.GetCachedManager():GetData(UserDataType.EquipBagData)
end

--获取Item背包数据
local function GetItemBagData()
    local UserDataType = require "Framework.UserDataType"
    return  CalculateRed.GetCachedManager():GetData(UserDataType.ItemBagData)
end
--获取卡牌数据
local function GetCardBagDataByID(roleID)
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = CalculateRed.GetCachedManager():GetData(UserDataType.CardBagData)
    return cardBagData:GetRoleById(roleID)
end


--获取该卡牌身上的红点数据
local function CreateRoleRedDataByID(roleID,uid)
    for k,v in pairs(RoleRedData) do
        if k == roleID then
            return v
        end 
    end
    RoleRedData[roleID] = {}
    RoleRedData[roleID].uid = uid
    return RoleRedData[roleID]
end

--判断是否存在该卡牌数据
local function HasRoleRedDataByID(roleID,data)
    if data == nil then
        data=CalculateRed.GetRoleRedDataByID(roleID)
    end
    if data == nil then
        return
    end

    return data
end

--根据ID获取卡牌红点数据
function CalculateRed.GetRoleRedDataByID(roleID)
    for k,v in pairs(RoleRedData) do
        if k == roleID then
            return v
        end 
    end  
end



--根据UID获取卡牌红点数据
function CalculateRed.GetRoleRedDataByUID(uid)
    for k,v in pairs(RoleRedData) do
        if v.uid == uid then
            return v
        end 
    end  
end

function CalculateRed.GetMainRoleRedData()
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = CalculateRed.GetCachedManager():GetData(UserDataType.CardBagData)
    local ownedCount = cardBagData:RoleCount()

    for j = 1, ownedCount do
        local userCardData = cardBagData:GetRoleByPos(j)
        local roleID = userCardData:GetId()    
        local flag = CalculateRed.GetChooseRoleRedData(roleID,nil)
        if flag then
           -- hzj_print("roleID",roleID,flag)
            return flag
        end
    end
    CalculateRed.CalculateAllRoleDebrisCompound()
    for k,v in pairs(RoleDebrisRedData) do
        for i,t in pairs(v) do
             --hzj_print(i,t,"********************",k)

            if t== 1 then
                return true
            end
        end 
    end

  
    return false
end
--获取玩家升级进阶天赋团队天赋数据
function CalculateRed.GetUpgradeRoleRedDataByID(roleID)
    local data = CalculateRed.GetRoleRedDataByID(roleID)
    if data == nil then
        return
    end


    return data[r_Detail_Upgrade]==1

end



--获取玩家进阶数据
function CalculateRed.GetRoleAdvancedRedDataByID(roleID)
    local data = CalculateRed.GetRoleRedDataByID(roleID)
    if data == nil then
        return
    end
    return data[r_Detail_Advanced]==1
    
end

--获取玩家团队天赋数据

function CalculateRed.GetRoleTalentRedDataByID(roleID)
    local data = CalculateRed.GetRoleRedDataByID(roleID)
    if data == nil then
        return
    end
    return data[r_Detail_Talent]==1
    
end
--获取团队天赋数据
function CalculateRed.GetRoleTeamTalentRedDataByID(roleID)
    local data = CalculateRed.GetRoleRedDataByID(roleID)
    if data == nil then
        return
    end
    return data[r_Detail_TeamTalent]==1
    
end
--获取玩家装备栏的的第一个红点数据
function CalculateRed.GetRoleEquipRedDataByIDAndPosAndIndex(roleUid,pos,index)
    hzj_print(roleUid,pos,index)
    local data = CalculateRed.GetRoleRedDataByUID(roleUid)
    if data == nil then
        return
    end
    if pos == 10 then
        pos=8
    end
    return data[r_Detail_EquipPos[pos][index+1]]==1 

end

--获取玩家装备栏的红点数据根据位置
function CalculateRed.GetRoleEquipRedDataByIDAndPos(roleID,pos)
    local data = CalculateRed.GetRoleRedDataByID(roleID)
    if data == nil then
        return
    end
    if pos == 10 then
        pos=8
    end
    return data[r_Detail_EquipPos[pos][1]]==1 or data[r_Detail_EquipPos[pos][2]]==1 or data[r_Detail_EquipPos[pos][3]]==1

end
    
function CalculateRed.GetChooseRoleRedData(roleID,data)
    if data == nil then
        data = CalculateRed.GetRoleRedDataByID(roleID)
 
    end
    if data == nil then
       -- hzj_print(roleID)
        return false
    end
    for i,v in pairs(data) do
        if data[i] == 1 then
            return true
          --  hzj_print(roleID,data[i],i)
        end
    end
    return false
end

--计算所有卡牌的红点
function CalculateRed.CalculateAllRoleRed()
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = CalculateRed.GetCachedManager():GetData(UserDataType.CardBagData)
    local ownedCount = cardBagData:RoleCount()
    for i = 1, ownedCount do
        local userCardData = cardBagData:GetRoleByPos(i)
        local roleID = userCardData:GetId()   
      --  hzj_print(roleID,"CalculateAllRoleRed")
        local data = CreateRoleRedDataByID(roleID,userCardData:GetUid())  
        CalculateRed.CalculateRoleRedByID(roleID,data)   
    end
    -- for k,v in pairs(RoleRedData) do
    --    hzj_print(k,"data[r_Detail_Upgrade]",v[r_Detail_Upgrade],"data[r_Detail_Advanced]",v[r_Detail_Advanced])
    -- end
end
--根据ID计算卡牌的红点
function CalculateRed.CalculateRoleRedByID(roleID,data)
    CalculateRed.CalculateRoleUpgrade(roleID,data)
    CalculateRed.CalculateRoleAdvanced(roleID,data)
    CalculateRed.CalculateRoleTalent(roleID,data)                --计算卡牌的天赋
    CalculateRed.CalculateRoleTeamTalent(roleID,data)            --计算卡牌的团队天赋
    CalculateRed.CalculateRoleEquip(roleID,data)                 --计算卡牌的装备
    --hzj_print("CalculateRoleRedByID",roleID,data[r_Detail_Upgrade],data[r_Detail_Advanced],data[r_Detail_Talent],data[r_Detail_TeamTalent])
    -- for i,v in pairs(data) do
    --     hzj_print(roleID,data[i],i)
    -- end
end

function CalculateRed.CalculateRoleEquip(roleID,data)
    data = HasRoleRedDataByID(roleID,data)
    if data == nil then
        hzj_print("不存在该玩家的数据")
        return       
    end


   
    local EquipBagData = GetEquipBagData() 
    --卡牌位置信息
    local oneCardEquipDic = EquipBagData:GetOneCardEquipsByUid(data.uid)

    --槽位类型信息

    -- CalculateRed.CalculateRoleAddEquip(roleID,data)
    
    local userCardData = GetCardBagDataByID(roleID)
    local slotCount = userCardData:GetEquipmentSlotCount()
    for i=1,slotCount do
        local slotType = userCardData:GetEquipmentTypeByPos(i)
      --  hzj_print(slotType,"slotType",roleID)
        data[r_Detail_EquipPos[i][1]] = 0
        data[r_Detail_EquipPos[i][2]] = 0
        data[r_Detail_EquipPos[i][3]] = 0

        local contains = false
        if i==8 and oneCardEquipDic:Contains(10) then
            contains=true

        end

        --已经装备装备
        if oneCardEquipDic:Contains(i) or contains then
            local equipUid = oneCardEquipDic:GetEntryByKey(i)
            if contains then
                equipUid=oneCardEquipDic:GetEntryByKey(10)
            end
            local equipData = EquipBagData:GetItem(equipUid)
            local pos = equipData:GetPos()
           -- hzj_print("pos",roleID,i,pos)

            local equipType = equipData:GetEquipType()
            local func,func1= CalculateRed.CalculateRoleEquipType(equipType)
            
            if func ~= nil then
                local flag = func(roleID,data,equipData)
                if flag then
                    data[r_Detail_EquipPos[i][2]] = 1
                else
                    data[r_Detail_EquipPos[i][2]] = 0
                end 
            else
                data[r_Detail_EquipPos[i][2]] = 0
            end
                           
            if func1 ~= nil then

               local flag = func1(roleID,equipType,equipData)  
               if flag then
                    data[r_Detail_EquipPos[i][3]] = 1
                else
                    data[r_Detail_EquipPos[i][3]] = 0
                end 
            else
                data[r_Detail_EquipPos[i][3]] = 0 
            end
            
             --hzj_print(equipUid,"equipUid",equipType)

        --没有装装备的时候           
        else

            local flag = CalculateRed.CalculateRoleAddEquip(roleID,data,slotType,i)
            if flag then
                data[r_Detail_EquipPos[i][1]] = 1
            else
                data[r_Detail_EquipPos[i][1]] = 0
            end
            data[r_Detail_EquipPos[i][2]] = 0
            data[r_Detail_EquipPos[i][3]] = 0
            -- hzj_print(roleID,i,data[r_Detail_EquipPos[i][1]],r_Detail_EquipPos[i][1])
            
        end
        
    end


end

-----------------------------start 计算有装备的情况  start-----------------------------


function CalculateRed.CalculateRoleEquipType(equipType)
    --武器
    if equipType == KEquipType_EquipWeapon then
        return CalculateRed.CalculateRoleEquipWeapon,CalculateRed.CalculateRoleEquipMountedGem
    --防具
    elseif equipType == KEquipType_EquipArmor then
        return CalculateRed.CalculateRoleEquipArmor,CalculateRed.CalculateRoleEquipMountedGem
    --翅膀
    elseif equipType == KEquipType_EquipWing then
        return CalculateRed.CalculateRoleEquipWingPowerUp,CalculateRed.CalculateRoleEquipWingUpGrade
    --宠物
    elseif equipType == KEquipType_EquipPet then
        return CalculateRed.CalculateRoleEquipPetPowerUp,CalculateRed.CalculateRoleEquipPetUpGrade
    --饰品
    elseif equipType == KEquipType_EquipAccessories then
        return CalculateRed.CalculateRoleEquipAccessories,CalculateRed.CalculateRoleEquipMountedGem
    --鞋子
    elseif equipType == KEquipType_EquipShoesr then
        return CalculateRed.CalculateRoleEquipShoesr,CalculateRed.CalculateRoleEquipMountedGem
    else
        return nil
    end
end
--计算翅膀强化的红点
function CalculateRed.CalculateRoleEquipWingPowerUp(roleID,data,equipData)
    local userCardData = GetCardBagDataByID(roleID)
    local EquipBagData = GetEquipBagData()
    local equipDic =EquipBagData:GetItemDict()
    local count = equipDic:Count()
    local staticdata = require  "StaticData.EquipWingExp":GetData(1)
    for i=1,count do
        local equipTemData = equipDic:GetEntryByIndex(i)
        local equipColor = equipTemData:GetColor()
        local equipType = equipTemData:GetEquipType()
        if equipColor >=KCardColorType_Green and equipColor <= KCardColorType_Blue then
            if equipTemData:GetEquipUID() ~= equipData:GetEquipUID() and ( equipType == KEquipType_EquipWeapon or equipType == KEquipType_EquipArmor or equipType == KEquipType_EquipAccessories or equipType == KEquipType_EquipShoesr) then
               local needCoin=0
                if equipColor== KCardColorType_Green then
                    needCoin=staticdata:GetGreenProvideExp()*staticdata:GetCoinXishu()*staticdata:GetExpXishu()
                elseif equipColor== KCardColorType_Green then
                    needCoin=staticdata:GetBlueProvideExp()*staticdata:GetCoinXishu()*staticdata:GetExpXishu()


                end 
                   -- hzj_print(roleID,equipColor,equipType,"CalculateRoleEquipWingPowerUp",equipTemData:GetStoneCount(),equipTemData:GetName(),equipTemData:GetStoneUID())

                if equipTemData:GetStoneCount()==0 and GetPlayerCoin()>=needCoin then
                    local userCardData = GetCardBagDataByID(roleID) 
                    local color = equipData:GetColor()
                    local level = equipData:GetLevel()
                    local temp = math.min(color,3)  
                    local wingID = userCardData:GetRace()*10+temp 
                    local staticData = require "StaticData.EquipWingUp":GetData(wingID)
                    local  needLevel = staticData:GetLevelLimit()
                    if GetPlayerLevel() >level and level < needLevel then
                        return true
                    end
                    
                end
            end

        end
    end
    return false
 
end

--计算翅膀进阶的红点
function CalculateRed.CalculateRoleEquipWingUpGrade(roleID,data,equipData)
    local userCardData = GetCardBagDataByID(roleID)
    local level = equipData:GetLevel()
  --  local wingID = equipData:GetEquipID()
    local color = equipData:GetColor()
    local temp = math.min(color,3)
    local wingID = userCardData:GetRace()*10+temp



    local staticData = require "StaticData.EquipWingUp":GetData(wingID)
    local needNum = staticData:GetNeedNum()
    local needCoin = staticData:GetNeedCoin()
    local needID = staticData:GetNeedSuipianID()

    local ItemBagData = GetItemBagData()
    --拥有的个数
    local ownNum = ItemBagData:GetItemCountById(needID)
    hzj_print("GetPlayerLevel",GetPlayerLevel() , level ,GetPlayerCoin(),needCoin , ownNum , needNum)
    if GetPlayerLevel() >= level and GetPlayerCoin()>= needCoin and ownNum >= needNum then
        return true
    end
    return false

 
end

--计算是不是可以镶嵌宝石
function CalculateRed.CalculateRoleEquipMountedGem(roleID,equipType,equipData)
    local EquipBagData = GetEquipBagData()
    --背包中相同类型的宝石个数
    local gemNum = EquipBagData:GetMountedGemCountByType(equipType)
    --装备上镶嵌宝石的个数
    local mountedNum = equipData:GetStoneCount()
    --装备上可以镶嵌的个数
    local canMountedNum = equipData:GetGemNum()
    --hzj_print(equipType,gemNum,"gemNum",roleID)
   -- hzj_print("已经镶嵌了",equipData:GetStoneCount())
    if canMountedNum > mountedNum and gemNum > 0 then
       -- hzj_print(equipData:GetName(),"镶嵌可以有红点")
        return true
    end
   -- hzj_print(equipData:GetName(),"镶嵌没有红点")
    return false

end
--计算武器的红点
function CalculateRed.CalculateRoleEquipWeapon(roleID,data,equipData)
    local userCardData = GetCardBagDataByID(roleID)    
    -- local EquipBagData = GetEquipBagData() 
    local level = equipData:GetLevel()
   -- hzj_print(level,GetPlayerLevel(),"GetPlayerLevel")
    if level<GetPlayerLevel() then
        local cost = require "StaticData.EquipStrengthen":GetData(level):GetAttackNeedCoin()
        if GetPlayerCoin() >= cost then
           --  hzj_print(equipData:GetName(),"可以有红点")
             return true
        end
       -- hzj_print(equipData:GetName(),"可以升级")
    end
 --   hzj_print(equipData:GetName(),"没有红点") 
    return false
end
--计算防具的红点
function CalculateRed.CalculateRoleEquipArmor(roleID,data,equipData)
    local userCardData = GetCardBagDataByID(roleID)
    local level = equipData:GetLevel()
   -- hzj_print(level,GetPlayerLevel(),"GetPlayerLevel")
    if level<GetPlayerLevel() then
        local cost = require "StaticData.EquipStrengthen":GetData(level):GetADefeneNeedCoin()
        if GetPlayerCoin() >= cost then
           --  hzj_print(equipData:GetName(),"可以有红点")
             return true
        end
      --  hzj_print(equipData:GetName(),"可以升级")
    end
   -- hzj_print(equipData:GetName(),"没有红点") 
    return false
   
end

--计算宠物的是否可以强化
function CalculateRed.CalculateRoleEquipPetPowerUp(roleID,data1,equipData)
    local userCardData = GetCardBagDataByID(roleID)
    --宠物等级
    local level = equipData:GetLevel()
    --宠物已满级
    if (utility.GetPetMaxLevel()- level)<=0 then
        return false
     --宠物未满级
    else
       local EquipBagData = GetEquipBagData()
       local equipDic =EquipBagData:GetItemDict()
       local count = equipDic:Count()
       local petColor = equipData:GetColor() 
       local EquipPetsExpData = require"StaticData.EquipPetsExp":GetData(petColor)
       for i=1,count do
          local data = equipDic:GetEntryByIndex(i)
          local dataType = data:GetEquipType()

          local needCoin = petColor*EquipPetsExpData:GetCoinXishu()*EquipPetsExpData:GetPetExp()
          if dataType == KEquipType_EquipPet and data:GetColor()==equipData:GetColor() and data:GetEquipUID()~=equipData:GetEquipUID() and needCoin<= GetPlayerCoin() then

               -- hzj_print(petColor,EquipPetsExpData:GetCoinXishu(),EquipPetsExpData:GetPetExp(),"EquipPetsExp", dataType , KEquipType_EquipPet , data:GetColor(),equipData:GetColor() , data:GetEquipUID(),equipData:GetEquipUID() , needCoin, GetPlayerCoin())
                return true
          end
       end
    end
    return false

  
end
--计算宠物是否可以进阶
function CalculateRed.CalculateRoleEquipPetUpGrade(roleID,data,equipData)
    local level = equipData:GetLevel()
    --宠物不满级
    if (utility.GetPetMaxLevel()- level)>0 then
        return false
    end
    local UserDataType = require "Framework.UserDataType"
    local itemUserData =  CalculateRed.GetCachedManager():GetData(UserDataType.ItemBagData)
    local petColor = equipData:GetColor()
    local staticData = require "StaticData.EquipPetsUp":GetData(petColor+1)
    --进阶需要的个数
    local needItemId = staticData:GetItemId()
    --拥有的个数
    local ownNum = itemUserData:GetItemCountById(needItemId)
    --需要的个数
    local needNum = staticData:GetNeedNum()
    --需要消耗的金钱
    local coinCost = staticData:GetCost()
    if coinCost <= GetPlayerCoin() and ownNum>=needNum then
       -- hzj_print("宠物可以进阶",roleID)
        return true
    end
    return false

       

end

--计算鞋子的红点
function CalculateRed.CalculateRoleEquipShoesr(roleID,data,equipData)
    return false
  
end

--计算饰品的红点
function CalculateRed.CalculateRoleEquipAccessories(roleID,data,equipData)
    return false
  
end

-----------------------------end 计算有装备的情况 end-----------------------------
-----------------------------计算没有添加装备的情况-----------------------------

local function GetAvailableEquipmentCount(equipType, roleUid)
    local UserDataType = require "Framework.UserDataType"
    local equipBagData = CalculateRed.GetCachedManager():GetData(UserDataType.EquipBagData)

    debug_print(">>>>>>")
    local dict = equipBagData:RetrievalByResultFunc(function(item)
        
      --  hzj_print("@@@@ 装备ID", item:GetEquipID(), "装备类型", item:GetEquipType(), "装备槽类型", self.equipType, "装备槽位置", self.pos, "绑定UID", item:GetBindCardUID(), "穿戴在", item:GetOnWhichCard(), "当前卡牌", roleUid)
        
        -- @ 非当前装备类型
        if item:GetEquipType() ~= equipType then
            return false
        end
        
        -- @ 有绑定 and 绑定的不是自己
        local bindCardUID = item:GetBindCardUID()
        if type(bindCardUID) == "string" and bindCardUID ~= "" and bindCardUID ~= roleUid then
            return false
        end

        -- @ 有装备到身上的!
        local whichCardUID = item:GetOnWhichCard()
        if type(whichCardUID) == "string" and whichCardUID ~= "" then
            return false
        end

        -- @ 当前装备ID已经存在了!
        if equipBagData:ExistsOnCardEquipDict(item:GetEquipID(), roleUid) then
            return false
        end
        
        return true, item:GetEquipUID()
        
    end)
    --debug_print("<<<<<<", dict:Count())
    return dict:Count()
end


--计算是否可以穿戴装备
function CalculateRed.CalculateRoleAddEquip(roleID,data,equipType,pos)
    local isOpen = false
    local count = 0
     if equipType == KEquipType_EquipWing then
        count = 1
        ----服务器和客户端 槽位位置不统一         
        local EquipBagData = GetEquipBagData()
        local cardEquipDic = EquipBagData:GetOneCardEquipsByUid(data.uid)
        local count  = cardEquipDic:Count()
        local keys = cardEquipDic:GetKeys()
        for i=1,count do
            local equipUid =cardEquipDic:GetEntryByIndex(i)
            equipData = EquipBagData:GetItem(equipUid)
            local eType = equipData:GetEquipType()
            if eType == equipType then
                return false
            end 

        end
     
        local userCardData = GetCardBagDataByID(roleID)





        local staticWingData = require "StaticData.EquiWing":GetData(userCardData:GetbeishiID())
        local needCount = staticWingData:GetNeedBuildNum()

        local UserDataType = require "Framework.UserDataType"
        local itemUserData =  CalculateRed.GetCachedManager():GetData(UserDataType.ItemBagData)
        if itemUserData ~= nil then
            local hasBuildNum = itemUserData:GetItemCountById(staticWingData:GetNeedSuipianID())
            local coinNeeded = staticWingData:GetNeedCoin()
            local ownedCoin =  CalculateRed.GetCachedManager():GetData(UserDataType.PlayerData):GetCoin()
         --   hzj_print(ownedCoin, coinNeeded, type(ownedCoin), type(coinNeeded))
            isOpen = ownedCoin >= coinNeeded and hasBuildNum >= needCount
        end
    else
        count = GetAvailableEquipmentCount(equipType, data.uid)
        isOpen = utility.IsCanOpenModule(KSystemBasis_HeroEquipment, true)
    end
   -- hzj_print(roleID,count,isOpen,"count,isOpen")
    --可以装备的数量 isOpen是否可以开启
    if count == 0 or isOpen == false then
        return false
    end
    return true
end
-------------------------------------------------------------------------------------------------



--计算卡牌的团队天赋
function CalculateRed.CalculateRoleTeamTalent(roleID,data)
   data = HasRoleRedDataByID(roleID,data)
    if data == nil then
        hzj_print("不存在该玩家的数据")
        return       
    end

    --卡牌数据
    local userCardData = GetCardBagDataByID(roleID)
    local roleLevel = userCardData:GetLv()
    local stage = 0
    --团队天赋红点
    for i=1,3 do
        local teamTalentStage = userCardData:GetTeamTalentByStage(i)
       -- hzj_print(teamTalentStage,"teamTalentStage")
        if teamTalentStage == nil then
            stage = i 
            break
        end
    end
    --hzj_print(stage,"stage",userCardData:GetStar())
    if stage ~= 0 then
        --获取当前卡的类型
        local teamTalentBasisData=require "StaticData.Talent.TeamTalentBasis":GetData(userCardData:GetStar())
        local rank,level,needType,needNum = teamTalentBasisData:GetInfoByRank(stage-1)
        local UserDataType = require "Framework.UserDataType"
        local itemBagData = CalculateRed.GetCachedManager():GetData(UserDataType.ItemBagData)
        local count
       -- hzj_print(roleID,stage,needNum,GetPlayerLevel(), level,"count >= needNum and GetPlayerLevel()>= level")
        if needType == 10410001 then
            count = GetPlayerDiamond()
        elseif needType == 10410002 then
            count = GetPlayerCoin()
        else
           count =itemBagData:GetItemCountById(needType)
        end

        if count >= needNum and GetPlayerLevel()>= level then
            data[r_Detail_TeamTalent]=1
            return
        end
    end
    data[r_Detail_TeamTalent]=0
end

--计算卡牌的天赋
function CalculateRed.CalculateRoleTalent(roleID,data)
    data = HasRoleRedDataByID(roleID,data)
    if data == nil then
        hzj_print("不存在该玩家的数据")
        return       
    end
    --卡牌数据
    local userCardData = GetCardBagDataByID(roleID)
    local count = userCardData:GetTalentCount()
    local color = userCardData:GetColor()
    local advanceStage = userCardData:GetStage()
    local stage = 0
    --取出来下一个需要开启的天赋
    for i=1,5 do
        local talentStage = userCardData:GetTalentByStage(i)
        if talentStage == nil then
            stage = i 
            break
        end
    end
    --个人天赋没有全部开启
    if stage ~= 0 then
        --蓝色开启
        if stage == 1 then
            if color >= KCardColorType_Blue then
                data[r_Detail_Talent] = 1
                return
            end
        --紫色开启
        elseif stage == 2 then
            if color > KCardColorType_Blue then
                data[r_Detail_Talent] = 1
                return
            end
        --紫色加2开启
        elseif stage == 3 then
            if color > KCardColorType_Blue then
                if advanceStage>=2 then
                    data[r_Detail_Talent] = 1
                    return
                end          
            end
        --紫色加4开启
        elseif stage == 4 then
            if color > KCardColorType_Blue then
                if advanceStage>=4 then
                    data[r_Detail_Talent] = 1
                    return
                end
            end
        --紫色加6开启
        elseif stage == 5 then
            if color > KCardColorType_Blue then
                if advanceStage>=6 then
                    data[r_Detail_Talent] = 1
                    return
                end 
            end 
        end
    else
        data[r_Detail_Talent] = 0
    end
    data[r_Detail_Talent] = 0
end

--计算可以不可以进阶
function CalculateRed.CalculateRoleAdvanced(roleID,data)
    data = HasRoleRedDataByID(roleID,data)
    if data == nil then
        hzj_print("不存在该卡牌的数据")
        return       
    end
   
    --hzj_print(cardBagData,roleID,"roleID")
    local userCardData = GetCardBagDataByID(roleID)
    local  roleColor = userCardData:GetColor()
    --玩家当前拥有的金币
    local currentCoin = GetPlayerCoin()
    if roleColor == KCardColorType_Green or roleColor == KCardColorType_Blue then
        local itemId = tonumber(string.format("%d%d",roleID,roleColor))
        --获取玩家升品所需要的材料
        local RoleUpQualityData = require "StaticData.RoleUpQuality":GetData(itemId)
        --获取金币消耗
        local coinCost = RoleUpQualityData:GetCoin()
        if currentCoin < coinCost then            
            data[r_Detail_Advanced] = 0
            return
        end

        local UserDataType = require "Framework.UserDataType"
        local EquipBagData = CalculateRed.GetCachedManager():GetData(UserDataType.EquipBagData)
        

        for i=1,4 do
            local needId,needCount = RoleUpQualityData:GetIdAndCount(i)
           
            local count= EquipBagData:GetItemCountById(needId)
              hzj_print(itemId,needId,needCount,"itemId,needId,needCount",count)
            if needCount > count then
                data[r_Detail_Advanced] = 0
                return
            end

        end

        


    elseif roleColor == KCardColorType_Purple then
        
        local stage = userCardData:GetStage()
        -- 达到顶阶
        if stage > KCardStageMax then
            data[r_Detail_Advanced] = 0  
            return      
        else
            local roleImproveData = require "StaticData.RoleImprove":GetData(stage) 
            local count = roleImproveData:GetNeedCardSuipianNum()        
            local coinCost = roleImproveData:GetCoin()
            --判断钱够不够
            if currentCoin < coinCost then            
                data[r_Detail_Advanced] = 0
                return
            end
            local UserDataType = require "Framework.UserDataType"
            local CardChipBagData = CalculateRed.GetCachedManager():GetData(UserDataType.CardChipBagData)
            local currentFragments = CardChipBagData:GetCardChipCount(userCardData:GetScrapId())
            if currentFragments < count then            
                data[r_Detail_Advanced] = 0
                return
            end


        end
    end
    data[r_Detail_Advanced] = 1
    --hzj_print(currentCoin,"currentCoin")



end

--计算可以不可以升级
function CalculateRed.CalculateRoleUpgrade(roleID,data)
    data = HasRoleRedDataByID(roleID,data)
    if data == nil then
        return       
    end
    if require "Utils.RoleUtility".CanLevelUp(data.uid) then
        data[r_Detail_Upgrade]=1
    else
        data[r_Detail_Upgrade]=0
    end

end

--获取该卡牌身上的红点数据
local function CreateRoleDebrisRedDataByID(roleID,roleDebrisID)
    for k,v in pairs(RoleDebrisRedData) do
        if k == roleID then
            return v
        end 
    end
    RoleDebrisRedData[roleID] = {}
    RoleDebrisRedData[roleID].roleDebrisID = roleDebrisID
    return RoleDebrisRedData[roleID]
end




 --计算所有的碎片是不是可以合成
function CalculateRed.CalculateAllRoleDebrisCompound()
    local UserDataType = require "Framework.UserDataType"
    local CardChipBagData = CalculateRed.GetCachedManager():GetData(UserDataType.CardChipBagData)
    local count =  CardChipBagData:GetCount()
    for i=1,count do
        local CardDebrisData = CardChipBagData:GetDataByIndex(i)       
        local roleCrapData = require "StaticData.RoleCrap":GetData(CardDebrisData:GetId())
        local staticData = require "StaticData.Role":GetData(roleCrapData:GetRoleId()) 
        local roleID = roleCrapData:GetRoleId() 
        local roleData = HasRoleRedDataByID(roleID,nil)
        local data = CreateRoleDebrisRedDataByID(roleID,CardDebrisData:GetId())

        if roleData == nil then                

            local currentFragments = CardDebrisData:GetNumber()      
            local needNum = staticData:GetComposeNum()
            if needNum<= currentFragments then
                data[r_Choose_HeroChip]=1
            else
                data[r_Choose_HeroChip]=0  
            end
            hzj_print("roleID,CardDebrisData:GetId()",data,roleID,CardDebrisData:GetId(),needNum,currentFragments)
        else
            data[r_Choose_HeroChip]=0 
        end
    end  
end

 --计算背包的红点
function CalculateRed.CalculateBagRedData()
   return CalculateRed.CalculateEquipDebrisCompound() or CalculateRed.CalculateItemCanOpen()
end
 --计算是否有装备碎片可以合成
function CalculateRed.CalculateEquipDebrisCompound()
    local UserDataType = require "Framework.UserDataType"
    local EquipDebrisBag = CalculateRed.GetCachedManager():GetData(UserDataType.EquipDebrisBag)
    local count =  EquipDebrisBag:Count()
    for i=1,count do
        local EquipDebrisData = EquipDebrisBag:GetDataByIndex(i)
        local ownedCount = EquipDebrisData:GetNumber()
        local needCount = EquipDebrisData:GetNeedBuildNum()
        if needCount<= ownedCount then
            return true
        end
    end
    return false   
end

 --计算是否有道具可以打开
function CalculateRed.CalculateItemCanOpen()
    local ItemBagData = GetItemBagData()    
    local count =  ItemBagData:Count()
    for i=1,count do
        local itemData = ItemBagData:GetDataByIndex(i)
        local useType = itemData:GetCanUse()
        if useType == 5 or useType == 6 then
            return true
        end
    end
    return false   
end







return CalculateRed