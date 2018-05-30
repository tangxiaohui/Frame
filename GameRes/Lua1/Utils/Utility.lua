require "LUT.ArrayString"

require "Const"
local Utility = {}

local math = _G.math
local debug = _G.debug
local table = _G.table
local os = _G.os
local unpack = _G.unpack
local tonumber = _G.tonumber
local string = _G.string

function Utility.GetGame()
    return require "Game.Cos3DGame"
end

function Utility.GetUIManager()
    local game = Utility.GetGame()
    return game:GetUIManager()
end

function Utility.UnPack(t)
    return unpack(t, 1, table.maxn(t))
end

function Utility.GetPlatform()
	local game = Utility.GetGame()
	local platform = game.gameServer.sdkSessions.platform
	return platform
end	

---------------------------------------------------------------
-- 数学
---------------------------------------------------------------
-- 判断符号
function Utility.Sign(number)
    if number >= 0 then
        return 1
    else
        return -1
    end
end

function Utility.NormalizedDirection(number)
    if number > 0 then
        return 1
    elseif number < 0 then
        return -1
    else
        return 0
    end
end

-- 转换到boolean
function Utility.ToBoolean(v)
    if v then
        return true
    end
    return false
end

-- 舍弃小数 取整
function Utility.ToInteger(number)
    if number >= 0 then
        return math.floor(number)
    else
        return math.ceil(number)
    end
end

-- 四舍五入 --
local __roundFmtTable__ = {[1] = "%", [2] = 0, [3] = ".", [4] = 0, [5] = "f"}
function Utility.ToRoundNumber(number, reservedDecimalNum, totalBits)
    __roundFmtTable__[2] = totalBits or 0
    __roundFmtTable__[4] = reservedDecimalNum or 0
    local fmt = table.concat(__roundFmtTable__)
    return tonumber(string.format(fmt, number))
end

-- 四舍五入(整数)
function Utility.ToRoundInteger(number)
    return Utility.ToRoundNumber(number, 0)
end

-- 范围值限定
function Utility.Clamp(value, min, max)
    local s = math.min(min, max)
    local e = math.max(min, max)
    return math.min(e, math.max(s, value))
end

-- 范围值 限定到 [0, 1]
function Utility.Clamp01(value)
    return Utility.Clamp(value, 0, 1)
end

-- 获取当前的值在 范围的百分比  不会限定 [0,1], 因为有的时候超过范围 有其它用处
function Utility.NormValue(value, start, end_)
    local d = end_ - start
    if d == 0 then
        error("start和end差不能为0")
    end
    return (value - start) / d
end

-- 将value 从范围 [start1, end1] 映射到 [start2, end2]
function Utility.MapValue(value, start1, end1, start2, end2)
    local t = Utility.NormValue(value, start1, end1)
    return start2 + (end2 - start2) * t
end

---------------------------------------------------------------
-- 调试用
---------------------------------------------------------------
--- 获取调用栈 --
function Utility.TraceBack()
    return debug.traceback("<<<<<<< 栈信息 >>>>>>>", 2)
end

function Utility.CollectionGarbage()
    return collectgarbage()
end

function Utility.GetTotalMemoryInUseByLua()
    return collectgarbage("count")
end

function Utility.PrintTotalMemoryInUse()
    --local kb = Utility.GetTotalMemoryInUseByLua()
    --local bytes = kb * 1024
    --print("************** 当前已用内存字节", bytes, "**************")
end

---------------------------------------------------------------
-- 通用函数
---------------------------------------------------------------
function Utility.ASSERT(condition, message)
    if not condition then
        error(message, 2)
    end
end

function Utility.ClearArrayTableContent(table_)
    local count = table.maxn(table_)
    if count > 0 then
        for i = count, 1, -1 do
            table_[i] = nil
        end
    end
end

-- 获取一个通用的灰色材质 (Material)
local __grayMaterial__
function Utility.GetGrayMaterial(isImage)
    if isImage == nil then
        __grayMaterial__= Utility.LoadResourceSync("UI/Materials/GrayMateriaImage", typeof(UnityEngine.Material))
    else 
		__grayMaterial__= Utility.LoadResourceSync("UI/Materials/GrayMaterial", typeof(UnityEngine.Material))
	end
    return __grayMaterial__
end

function Utility.GetCommonMaterial(isImage)
	local material = nil
	if isImage == nil then
	local materialPath = "UI/Materials/Common"
	material = Utility.LoadResourceSync(materialPath,typeof(UnityEngine.Material))
	end
	return material
end

function Utility.GetRunTimeAnaimator(name)
    local __runtimeAnimatorController__ = nil
    if __runtimeAnimatorController__ == nil then
        __runtimeAnimatorController__= Utility.LoadResourceSync("UI/Animation/SelectStageBox", typeof(UnityEngine.RuntimeAnimatorController))
    end
    if __runtimeAnimatorController__ == nil then
        print('加载动画状态机失败')
    end

    return __runtimeAnimatorController__
end

---------------------------------------------------------------
-- 资源加载函数
---------------------------------------------------------------
local FileNameExtensions = {[1] = nil, [2] = nil}
local function GetAssetExtension(assetType)
    if assetType == typeof(UnityEngine.GameObject) then
        return ".prefab"
    elseif assetType == typeof(UnityEngine.Texture2D) then
        return ".png"
    elseif assetType == typeof(UnityEngine.Sprite) then
        return ".png"
    elseif assetType == typeof(UnityEngine.AudioClip) then
        return ".mp3"
    elseif assetType == typeof(UnityEngine.Material) then
        return ".mat"
    elseif assetType == typeof(UnityEngine.RuntimeAnimatorController) then
        return ".controller"
    end
    return ""
end

local function GetFullAssetName(name, assetType)
    return name .. GetAssetExtension(assetType)
end

function Utility.LoadResourceSync(name, assetType)
    -- note: 直接把 空字符串 传给 Resources 会导致卡住几秒
    if type(name) ~= "string" or string.len(name) == 0 then
        return nil
    end

    -- debug_print("@ 资源加载", GetFullAssetName(name, assetType))
    return _G.AssetManager.LoadAsset(GetFullAssetName(name, assetType))
end

function Utility.UnloadResource(name, assetType)
    _G.AssetManager.UnloadAsset(GetFullAssetName(name, assetType))
end

-- FIXME: 需要支持异步.
local function WaitForResourceLoaded(request, func)
    while(not request.isDone)
    do
        coroutine.step(1)
    end
    func(request.asset)
end

function Utility.LoadResourceAsync(name, assetType, func)
    -- note: 直接把 空字符串 传给 Resources 会导致卡住几秒
    -- if type(name) ~= "string" or string.len(name) == 0 then
    --     func(nil)
    -- end
    func(Utility.LoadResourceSync(name, assetType))
end

-- FIXME: 重写!
function Utility.LoadFileList(names, types, onFinished, isCatche4ever)
	local loadMgr = AssetLoad.AssetLoadManager.Instance()
	loadMgr:LoadAssetsList(names, types, onFinished, isCatche4ever)
end

function Utility.LoadNewGameObjectAsync(name, func)
    Utility.LoadResourceAsync(name, typeof(UnityEngine.GameObject), function(prefab)
        local Object = UnityEngine.Object
        local gameObject = Object.Instantiate(prefab)
        gameObject.name = prefab.name

        local canvasGroup = gameObject:GetComponent(typeof(UnityEngine.CanvasGroup))
        if canvasGroup == nil then
            gameObject:AddComponent(typeof(UnityEngine.CanvasGroup))
        end

        func(gameObject)
    end)
end

-- FIXME : 这块起名有问题!
function Utility.LoadNewPureGameObjectAsync(name, func)
    Utility.LoadResourceAsync(name, typeof(UnityEngine.GameObject), function(prefab)
		if prefab == nil then
			func(nil)
			return
		end
		
        local Object = UnityEngine.Object
        local gameObject = Object.Instantiate(prefab)
        gameObject.name = prefab.name
        func(gameObject)
    end)
end

function Utility.DestroyChildrenInTransform(transform)
    local childCount = transform.childCount
    for i = 1, childCount do
        local trans = transform:GetChild(i - 1)
        if trans ~= nil then
            UnityEngine.Object.Destroy(trans.gameObject)
        end
    end
end

---------------------------------------------------------------
-- 特效相关
---------------------------------------------------------------
function Utility.PlayParticleSystem(go, stop, clear)
    local allParticleSystems = go:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem))
    local count = allParticleSystems.Length
    local ps
    for i = 1, count do
        ps = allParticleSystems[i - 1]
        if ps ~= nil then
            if stop then
                ps:Stop(false)
                if clear then ps:Clear(false) end
            end
            ps:Play(false)
        end
    end
end

function Utility.StopParticleSystem(go, isClear)
    local allParticleSystems = go:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem))
    local count = allParticleSystems.Length
    local ps
    for i = 1, count do
        ps = allParticleSystems[i - 1]
        if ps ~= nil then
            ps:Stop(false)
            if isClear then ps:Clear(false) end
        end
    end
end
---------------------------------------------------------------
-- 场景相关
---------------------------------------------------------------
function Utility.LoadNormalScene()
    UnityEngine.SceneManagement.SceneManager.LoadScene("Normal")
end

function Utility.LoadBattleSceneAsync(sceneName)
    return _G.AssetManager.LoadSceneAsync(sceneName .. ".unity", false)
end

---------------------------------------------------------------
-- 二分查找(未测试)
---------------------------------------------------------------
function Utility.BinarySearch(array, func)
    local startPos = 1
    local endPos = #array

    local currentPos = startPos

    local res

    while(startPos <= endPos)
    do
        currentPos = Utility.ToInteger((startPos + endPos) / 2)

        res = func(array[currentPos]) == 0

        if res == 0 then
            return true, currentPos
        end

        if res > 0 then
            startPos = currentPos + 1
        else
            endPos = currentPos - 1
        end
    end

    return res, currentPos
end

---------------------------------------------------------------
-- 字符串分割
---------------------------------------------------------------
function Utility.Split(str, sep)
    local sep, fields = sep or ",", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function (c) fields[#fields + 1] = c end)
    return fields
end

-- input: 1001:351  output {1001, 351}
function Utility.SplitNew(str, sep, removeEmptyEntries)
	local sep = sep or ","
	local entries = {}
	
	local length = str:len()
    local stringBuilder = {}
    
    local isSep = false
	
	for i = 1, length do
		local c = str:sub(i, i)
        if c == sep then
            if #stringBuilder > 0 or not removeEmptyEntries then
                entries[#entries + 1] = table.concat(stringBuilder)
                Utility.ClearArrayTableContent(stringBuilder)
            end
            isSep = true
		else
            stringBuilder[#stringBuilder + 1] = c
            isSep = false
		end
	end
    
    if #stringBuilder > 0 or (isSep and not removeEmptyEntries) then
        entries[#entries + 1] = table.concat(stringBuilder)
    end
	
	return entries
end

---------------------------------------------------------------
-- 通用对话框
---------------------------------------------------------------
function Utility.ShowErrorDialog(msgText)
    local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
    local windowManager = Utility.GetGame():GetWindowManager()
    windowManager:Show(ErrorDialogClass, msgText)
end

function Utility.ShowConfirmDialog(msgText, table, confirmFunc, cancelFunc)
    local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
    local windowManager = Utility.GetGame():GetWindowManager()
    windowManager:Show(ConfirmDialogClass, msgText, table, confirmFunc, cancelFunc)
end


function Utility.ShowBuyConfirmDialog(msgText, table, confirmFunc, cancelFunc)
    local ConfirmBuyDialogClass = require "GUI.Dialogs.ConfirmBuyDialog"
    local windowManager = Utility.GetGame():GetWindowManager()
    windowManager:Show(ConfirmBuyDialogClass, msgText, table, confirmFunc, cancelFunc)
end

---------------------------------------------------------------
-- 排序函数
---------------------------------------------------------------
local function CompareRoleByLevel(roleData1, roleData2)
    return roleData1:GetLv() - roleData2:GetLv()
end

local function CompareRoleByColor(roleData1, roleData2)
    return roleData1:GetColor() - roleData2:GetColor()
end

local function CompareRoleByStage(roleData1, roleData2)
    if roleData1.GetStage ~= nil and roleData2.GetStage ~= nil then
        return roleData1:GetStage() - roleData2:GetStage()
    end
    return 0
end

local function CompareRoleByStar(roleData1, roleData2)
    return roleData1:GetStar() - roleData2:GetStar()
end

local function CompareRoleById(roleData1, roleData2)
    return roleData1:GetId() - roleData2:GetId()
end



local function CompareItemById(itemData1, itemData2)
    return itemData1:GetId() - itemData2:GetId()
end
local function CompareItemByColor(itemData1, itemData2)
    return itemData1:GetColor() - itemData2:GetColor()
end
local function CompareItemByOrderId(itemData1, itemData2)
  --  debug_print(itemData1:GetItemID(),itemData2:GetItemID() )
    return itemData1:GetOrderId() - itemData2:GetOrderId()
end
--设置优先级
local function SortShopItemType(type)
    if type==kStaticTableId_Card then
        return 1
    elseif type==kStaticTableId_Equipment then
        return 2
    elseif type==kStaticTableId_CardCrap then
        return 3
    elseif type==kStaticTableId_EquipmentCrap then
        return 4
    elseif type==kStaticTableId_GeneralItem then
        return 5
    elseif type==kStaticTableId_FactoryBoxToFix then
        return 6
    end
    
end 

local function SortShopItemColor(itemId)
     local gameTools = require"Utils.GameTools" 
    local infData,data,itemName,iconPath,itemType = gameTools.GetItemDataById(itemId)
    return gameTools.GetItemColorByType(itemType,data)
    
end 

--根据物品类型判断
local function CompareShopItemByItemType(itemData1, itemData2)
    local StaticTableUtility = require "Utils.StaticTableUtility"
    local item1ModV = SortShopItemType(StaticTableUtility.GetTypeFromID(itemData1:GetItemID()))
    local item2ModV = SortShopItemType(StaticTableUtility.GetTypeFromID(itemData2:GetItemID()))
    return item2ModV - item1ModV
end

--根据物品颜色判断
local function CompareShopItemByItemColor(itemData1, itemData2)
    local color1 = SortShopItemColor(itemData1:GetItemID())
    local color2 = SortShopItemColor(itemData2:GetItemID())
    debug_print(itemData1:GetItemID(),color1,itemData2:GetItemID(),color2)
    return color1 - color2
end
--根据物品ID 判断
local function CompareShopItemByItemId(itemData1, itemData2)
    local id1 = itemData1:GetItemID()
    local id2 = itemData2:GetItemID()
    return id1 - id2
end

local function SortShopBySpecialType(itemId)
    local gameTools = require"Utils.GameTools" 
    local _,data,_,_,itemType = gameTools.GetItemDataById(itemId)
    return data,itemType
    
end 
local function CompareShopItemBySpecialType( itemData1, itemData2 )

    local tempItemData1,itemType1 = SortShopBySpecialType(itemData1:GetItemID())
    local tempItemData2,itemType2 = SortShopBySpecialType(itemData2:GetItemID())

    if itemType1=="Item" and itemType2=="Item" then
        debug_print(tempItemData1:GetOrderId(),tempItemData2:GetOrderId()," orde ")
        local flag= Utility.CompareItemByItemData(tempItemData1,tempItemData2)
        if flag then
            return 1
        else
            return -1
        end
    else
        return 0
    end
end 

-- 商店排序 整件卡牌>整件装备>卡牌碎片>装备碎片>宝箱道具>材料道具>品质>ID
function Utility.CompareItemByShopItemData(allItemsIndex,shopType)

    local shopData = Utility.GetShopData(shopType)
    debug_print(shopData:GetData(1):GetItemID(),shopType,"shopType")
    local allItemsData = {}
    for i=1,#allItemsIndex do
        debug_print(allItemsIndex[i])
        allItemsData[#allItemsData+1]=shopData:GetData(allItemsIndex[i].id)
        allItemsData[#allItemsData].state=allItemsIndex[i].state
    end
    for i=1,#allItemsData do
        debug_print(allItemsData[i]:GetItemID(),"Begin")
    end
    table.sort(allItemsData, function(itemData1, itemData2)       
        local res
        -- @1. 根据物品类型排序
        res = CompareShopItemByItemType(itemData1, itemData2)
        if  res~=0 then
            if res<0 then
                return false
            else
                return true
            end
        end

      --   --103特殊类型
      --   res = CompareShopItemBySpecialType(itemData1, itemData2)
      -- -- debug_print("103特殊类型",itemData1:GetItemID(),itemData2:GetItemID(),res)

      --   if  res~=0 then
      --       if res<0 then
      --           return false
      --       else
      --           return true
      --       end
      --   end

        --根据颜色排序

        res = CompareShopItemByItemColor(itemData1, itemData2)
        if  res~=0 then
            if res<0 then
                return false
            else
                return true
            end
        end
        --根据ID排序
        res = CompareShopItemByItemId(itemData1, itemData2)
        if  res~=0 then
            if res>0 then
                return false
            else
                return true
            end
        end


        return false
      
        end)





    for i=1,#allItemsData do
        debug_print(allItemsData[i]:GetItemID(),"End")
    end
    local shopItemsIndex = {}
    for i=1,#allItemsData do
        shopItemsIndex[#shopItemsIndex+1]={}
        shopItemsIndex[#shopItemsIndex].id=allItemsData[i]:GetId()
        shopItemsIndex[#shopItemsIndex].state=allItemsData[i].state
    end
    return shopItemsIndex
  
end

function Utility.GetShopData(shopType)
    -- body
        if shopType == KShopType_Normal then      
        -- 普通商店
        
        return require "StaticData.Shop.ShopData"
    elseif shopType == KShopType_ProtectPrincess then
        -- 保护公主商店

        return require "StaticData.Shop.DefendThePrincessShop"
    elseif shopType == KShopType_Arena then
        -- 竞技场商店
        
        return require "StaticData.Shop.ArenaShopData"
    elseif shopType == KShopType_BlackMarket then
        -- 黑市商店
        
        return require "StaticData.Shop.BlackMarketData"
        -- error("黑市商店 shopData is null")
    elseif shopType == KShopType_ArmyGroup then
        --军团商店
        return require "StaticData.Shop.LegionShop"
    elseif shopType == KShopType_Gem then
        -- 宝石商店
        return require "StaticData.Shop.GemShop"
    elseif shopType == KShopType_GuildPoint then
        --公会积分战
        return require "StaticData.Shop.PointFightShop"
    elseif shopType == KShopType_Tower then
        --爬塔
        return require "StaticData.Shop.TowerShopMgr"
    elseif shopType == KShopType_IntegralShop then
        --积分抽卡商店
        return require "StaticData.Shop.DrawPointShop"
    
    elseif shopType == KShopType_LotteryShop then
        --积分抽卡商店
      --  debug_print("GetData(id)",id)
        return require "StaticData.Shop.AroundShop"
    
    end
end
-- Item排序
function Utility.CompareItemByItemData(itemData1, itemData2)
    local res
      -- @1. OrderId
    res = CompareItemByOrderId(itemData1, itemData2)
    if res ~= 0 then
        if res > 0 then
            return true
        else
            return false
        end
    end

    -- @2. 按颜色排
    res = CompareItemByColor(itemData1, itemData2)
    if res ~= 0 then
        if res > 0 then
            return true
        else
            return false
        end
    end

    -- @3. 按ID 排
    res = CompareItemById(itemData1, itemData2)
    if res ~= 0 then
        if res > 0 then
            return true
        else
            return false
        end
    end
    return false

end
-- 卡牌统一排序
function Utility.CompareCardByRoleData(roleData1, roleData2)
    local res

    -- @1. 排序等级
    res = CompareRoleByLevel(roleData1, roleData2)
    if res ~= 0 then
        if res > 0 then
            return true
        else
            return false
        end
    end

    -- @2. 按颜色排
    res = CompareRoleByColor(roleData1, roleData2)
    if res ~= 0 then
        if res > 0 then
            return true
        else
            return false
        end
    end

    -- @3. 按星级排
    res = CompareRoleByStar(roleData1, roleData2)
    if res ~= 0 then
        if res > 0 then
            return true
        else
            return false
        end
    end

    -- @4. 按阶排
    res = CompareRoleByStage(roleData1, roleData2)
    if res ~= 0 then
        if res > 0 then
            return true
        else
            return false
        end
    end

    -- @5. 按id排
    res = CompareRoleById(roleData1, roleData2)
    if res ~= 0 then
        if res > 0 then
            return true
        else
            return false
        end
    end

    return false
end
---------------------------------------------------------------
-- 异步用
---------------------------------------------------------------
function Utility.IsAllComponentsReady(nodes, ignoreParent)
    for i = 1, #nodes do
        if not nodes[i]:IsReady(ignoreParent) then
            return false
        end
    end
    return true
end

function Utility.IsNodeReady(node, ignoreParent)
    return node:IsReady(ignoreParent)
end


function Utility.SortNodeView(nodes, sortFunction, ignoreParent)
    if not Utility.IsAllComponentsReady(nodes, ignoreParent) then
        error("排序错误, 并没有全部布局好, 不能排序")
        return
    end

    table.sort(nodes, sortFunction)
    for i = 1, #nodes do
        local transform = nodes[i]:GetUnityTransform()
        transform:SetSiblingIndex(i - 1)
    end
end

---------------------------------------------------------------
-- * 滚动条 *
---------------------------------------------------------------
function Utility.HScrollingNeeded(scrollRect)
    return scrollRect.content.sizeDelta.x > (scrollRect.viewport.sizeDelta.x + 0.01)
end

function Utility.VScrollingNeeded(scrollRect)
    return scrollRect.content.sizeDelta.y > (scrollRect.viewport.sizeDelta.y + 0.01)
end

---------------------------------------------------------------
-- * 毫秒时间转换 *
---------------------------------------------------------------
function Utility.ConvertTime(time)
    local ConvertTime = {}
    ConvertTime.hour = time / 3600
    ConvertTime.minute = (time % 3600) / 60
    ConvertTime.second = (time % 3600) % 60

    if ConvertTime.hour < 10 then
         ConvertTime.houStr = 0 .. tostring(math.floor(ConvertTime.hour))
    else
         ConvertTime.houStr = tostring(math.floor(ConvertTime.hour))
    end

    if ConvertTime.minute < 10 then
         ConvertTime.minuteStr = 0 .. tostring(math.floor(ConvertTime.minute))
    else
         ConvertTime.minuteStr = tostring(math.floor(ConvertTime.minute))
    end

    if ConvertTime.second < 10 then
         ConvertTime.secondStr = 0 .. tostring(math.floor(ConvertTime.second))
    else
         ConvertTime.secondStr = tostring(math.floor(ConvertTime.second))
    end

    return ConvertTime.houStr .. ":" .. ConvertTime.minuteStr .. ":" .. ConvertTime.secondStr
end
-- # 时间转时间戳格式化
local TimeTable = {}
function Utility.GetTimeStampFromLocalTime(year, month, day, hour, min, sec)
    TimeTable.year = year
    TimeTable.month = month
    TimeTable.day = day
    TimeTable.hour = hour
    TimeTable.min = min
    TimeTable.sec = sec
    return os.time(TimeTable) * 1000
end

-- # 时间戳转时间
function Utility.GetLocalTimeFromTimeStamp(format, timestamp)
    return os.date(format, timestamp / 1000)
end

function Utility.GetLocalTimeTableFromTimeStamp(timestamp)
    return os.date("*t",timestamp)
end

function Utility.GetNameRandomly()
	local pro = require "Utils.Probability"
	local fnIdx = pro:RandomRange(0, #Firstname)
	local lnIdx = pro:RandomRange(0, #Lastname)
	return Lastname[lnIdx]..Firstname[fnIdx]
end

---------------------------------------------------------------
-- 使用货币相关 (可以用于弹出 当不够的时候 可以弹出购买对话框选项)
---------------------------------------------------------------
function Utility.IsVigorEnough(vigor)
    local dataCacheMgr = Utility.GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)

    -- 当前体力足够
    if playerData:GetVigor() >= vigor then
        return true, nil
    end

    -- 当前体力不足
    return false, function()
        Utility.ShowErrorDialog("当前体力不足!")
    end
end

function Utility.IsCoinEnough(coin)
    local dataCacheMgr = Utility.GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)

    -- 金币足够
    if tonumber(playerData:GetCoin()) >= coin then
        return true, nil, tonumber(playerData:GetCoin())
    end

    -- 当金币不足时
    return false, function()
        Utility.OnCoinBuyWithDiamond()
    end, tonumber(playerData:GetCoin())
end

function Utility.IsDiamondEnough(diamond)
    local dataCacheMgr = Utility.GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)

    if tonumber(playerData:GetDiamond()) >= diamond then
        return true, nil, tonumber(playerData:GetDiamond())
    end

    return false, function()
        -- TODO:购买钻石
    end, tonumber(playerData:GetDiamond())
end

-- 通用判断道具是否足够, 在之后会实现完整.
function Utility.IsItemEnough(itemId, itemNum)
    local PropUtility = require "Utils.PropUtility"
    return PropUtility.IsItemEnough(itemId, itemNum)
end

function Utility.OnCoinBuyWithDiamond()
    -- local messageGuids = require "Framework.Business.MessageGuids"
    -- Utility.GetGame():GetEventManager():PostNotification(messageGuids.OnCoinBuyWithDiamond)
end

---------------------------------------------------------------
-- 加载图片用 --
---------------------------------------------------------------

-- # 四个工具函数
function Utility.GetRGBName(name)
	return name.."_RGB"
end

function Utility.GetAlphaName(name)
	return name.."_Alpha"
end

function Utility.IsETCSupport()
    -- return Utility.GetPlatform() == "Android"
    -- return Utility.GetPlatform() == "aaa"
    return false
end

-- # 这两个即将废弃!
function Utility.GetRGBPath(path)
	local paths = Utility.Split(path,'/')
	local rgbName = Utility.GetRGBName(paths[#paths-1])
	path = string.gsub(path,paths[#paths-1],function(s) return rgbName end)
	return path
end

function Utility.GetAlphaPath(path)
	local paths = Utility.Split(path,'/')
	local alphaName = Utility.GetAlphaName(paths[#paths-1])
	path = string.gsub(path,paths[#paths-1],function(s) return alphaName end)
	return path
end

-- # 通过平台获取图集名字
local function GetAtlasNames(atlasName)
    if Utility.IsETCSupport() then
        return Utility.GetRGBName(atlasName), Utility.GetAlphaName(atlasName)
    else
        return atlasName, nil
    end
end

-- # 获得图片全路径
local function GetFullIconName(relativePath, atlasName, icon, isTexture)
    if relativePath == nil or atlasName == nil or icon == nil then
        return nil
    end

    if isTexture then
        return string.format("%s/%s/%s/%s", relativePath, atlasName, icon, icon)
    else
        return string.format("%s/%s/%s", relativePath, atlasName, icon)
    end
end

-- # 根据服务器状态获精灵名
function Utility.GetServerStateSprite(state)
    state = state or 0
    local spriteName

    if state == kServerState_Maintain then
        spriteName = "SmallGray"
    elseif state == kServerState_Justle then
        spriteName = "SmallRed"
    elseif state == kServerState_Prevail then
        spriteName = "SmallOrange"
    elseif state == kServerState_Fluency then
        spriteName = "SmallGreen"
    else
        spriteName = "SmallGreen"
    end
    
    return string.format("UI/Atlases/LoginIcon/%s", spriteName)
end

-- ### 加载精灵 ### --
function Utility.LoadSprite(relativePath, atlasName, icon, isTexture, image)
    local AtlasesLoader = require "Utils.AtlasesLoader"
    local atlasRGBName, atlasAlphaName = GetAtlasNames(atlasName)

    local fullIconName = GetFullIconName(relativePath, atlasRGBName, icon, isTexture)
    local fullIconAlphaName = GetFullIconName(relativePath, atlasAlphaName, icon, isTexture)

    if fullIconName ~= nil then
        image.sprite = AtlasesLoader:LoadAtlasSprite(fullIconName)
    end

    if fullIconAlphaName ~= nil then
        image.secondSprite = AtlasesLoader:LoadAtlasSprite(fullIconAlphaName)
    end
end
function Utility.LoadAtlasesSpriteByFullName(fullName,image)
    -- debug_print(fullName,image)
    local names = Utility.Split(fullName, '/')

    local len = #names
    if len <= 1 then
        error("路径不对, 应该是 全路径/图集名/精灵名")
    end
    local atlasName =fullName.."/"..names[len]

    local AtlasesLoader = require "Utils.AtlasesLoader"
    image.sprite = AtlasesLoader:LoadAtlasSprite(atlasName)
    -- debug_print(image.sprite,"image.sprite",atlasName)
end
function Utility.LoadAtlasesSprite(atlasName, icon, image)
    Utility.LoadSprite("UI/Atlases", atlasName, icon, false, image)
end

function Utility.LoadTextureSprite(atlasName, icon, image)
    Utility.LoadSprite("UI/Textures", atlasName, icon, true, image)
end

--根据路径获取图片(Image)
function Utility.LoadSpriteFromPath(path, image)
	local AtlasesLoader = require "Utils.AtlasesLoader"
	local sprite = nil
	if Utility.IsETCSupport() then
		local RGBPath = Utility.GetRGBPath(path)
		local AlphaPath = Utility.GetAlphaPath(path)
		alphaSprite = AtlasesLoader:LoadAtlasSprite(AlphaPath)
		sprite = AtlasesLoader:LoadAtlasSprite(RGBPath)
		image.secondSprite = alphaSprite
	else
		sprite = AtlasesLoader:LoadAtlasSprite(path)
	end
	image.sprite = sprite
end

-- # 加载卡牌头像
function Utility.LoadRoleHeadIcon(roleID, image)
    local roleMgr = require "StaticData.Role"
    local roleData = roleMgr:GetData(roleID)
    local icon = roleData:GetHeadIcon()
    Utility.LoadSpriteFromPath(icon,image)
end

-- # 战斗名字图标
function Utility.LoadRoleNameIcon(roleID, image)
	local roleMgr = require "StaticData.Role"
	local roleData = roleMgr:GetData(roleID)
	local portraitImage = roleData:GetPortraitImage()
    Utility.LoadAtlasesSprite(
        "BattleCardName",
        portraitImage,
        image
    )
end

-- # 卡牌战斗立绘
function Utility.LoadBattlePortraitImage(roleID, image)
	local roleMgr = require "StaticData.Role"
	local roleData = roleMgr:GetData(roleID)
	local portraitImage = roleData:GetPortraitImage()
	Utility.LoadTextureSprite(
        "BattlePortrait", 
        portraitImage, 
        image
    )
end

-- # 卡牌普通立绘
function Utility.LoadRolePortraitImage(roleID, image)
    local roleMgr = require "StaticData.Role"
    local roleData = roleMgr:GetData(roleID)
    local portraitImage = roleData:GetPortraitImage()
    Utility.LoadTextureSprite(
        "CardPortrait", 
        portraitImage, 
        image
    )
end

-- # 卡牌抽卡立绘
function Utility.LoadIllustRolePortraitImage(roleID, image)
    local roleMgr = require "StaticData.Role"
    local roleData = roleMgr:GetData(roleID)
    local portraitImage = roleData:GetPortraitImage()
	Utility.LoadTextureSprite(
        "CardIllust", 
        portraitImage, 
        image
    )
end

-- #玩家头像 --
function Utility.LoadPlayerHeadIcon(headID, image)
    local playerHeadMgr = require "StaticData.PlayerHead"
    local playerHeadData = playerHeadMgr:GetData(headID)
	Utility.LoadAtlasesSprite(
        "CardHead", 
        playerHeadData:GetIcon(), 
        image
    )
end

-- #力敏智 --
function Utility.LoadMajorIcon(majorID, image)
    local majorName
    if majorID == 0 then
        majorName = "STR"
    elseif majorID == 1 then
        majorName = "AGI"
    elseif majorID == 2 then
        majorName = "INT"
    else
        return nil
    end
    local atlasName = "NeoCardInfo"
    Utility.LoadAtlasesSprite(atlasName,majorName,image)
end

-- # 加载头像种族 # --
function Utility.LoadRaceIcon(raceID,image)
    local iconName
    if raceID == 1 then
        iconName = "renzhu1"
    elseif raceID == 2 then
        iconName = "maozhu1"
    elseif raceID == 3 then
        iconName = "jixiezhu1"
    elseif raceID == 4 then
        iconName = "guzhu1"
    elseif raceID == 5 then
        iconName = "longzhu1"
    elseif raceID == 6 then
        iconName = "shouhuzhe1"
    else
        return nil
    end
	local icon = string.format("Icon_zz_%s",iconName)
	local atlasName = "Common2"
	Utility.LoadAtlasesSprite(atlasName,icon,image)
end

---- # 加载装备槽类型图标 # --
function Utility.LoadEquipmentSlotTypeIcon(type,image)
    local iconName

    if type == KEquipType_EquipWeapon then
        iconName = "ZBC_1"
    elseif type == KEquipType_EquipArmor then
        iconName = "ZBC_2"
    elseif type == KEquipType_EquipAccessories then
        iconName = "ZBC_3"
    elseif type == KEquipType_EquipShoesr then
        iconName = "ZBC_4"
    elseif type == KEquipType_EquipPet then
        iconName = "ZBC_10"
    elseif type == KEquipType_EquipSpar then
        iconName = "ZBC_6"
    elseif type == KEquipType_EquipFashion then
        iconName = "ZBC_7"
    elseif type == KEquipType_Public then
        iconName = "ZBC_8"
    elseif type == KEquipType_EquipInvalid then
         -- 目前暂时把这个ID当坐骑, 反正不会开启!
        iconName = "ZBC_9"
    elseif type == KEquipType_EquipWing then
        iconName = "ZBC_5"
    end

	local atlasName = "EquipBase"
	Utility.LoadAtlasesSprite(atlasName,iconName,image)
end

function Utility.LoadCardSkinBaseIcon(color,image)
   local iconName
    if color == 1 then
        iconName = "SkinGreen"
    elseif color == 2 then
        iconName = "SkinBlue"
    elseif color == 3 then
        iconName = "SkinPurple"
    elseif color == 4 then
        iconName = "SkinOrange"
    else
        return nil
    end
    local atlasName = "Skin"
    Utility.LoadAtlasesSprite(atlasName,iconName,image)
end

-- # 皮肤立绘
function Utility.LoadIllustCardSkinPortraitImage(skinID, image)
    local skinMgr = require "StaticData.CardSkin.Skin"
    local skinData = skinMgr:GetData(skinID)
    local portraitImage = skinData:GetSkinicon()
    Utility.LoadTextureSprite(
        "Skinillust", 
        portraitImage, 
        image
    )
end

-- #皮肤头像 --
function Utility.LoadCardSkinHeadIcon(skinID, image)
     local skinMgr = require "StaticData.CardSkin.Skin"
    local skinData = skinMgr:GetData(skinID)
    local icon = skinData:GetSkinicon()
    Utility.LoadAtlasesSprite(
        "Skinhead", 
        icon, 
        image
    )
end

function Utility.GetRoleSkinDataFromBagById(roleId)
    local dataCacheMgr = Utility.GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local cardBagrData = dataCacheMgr:GetData(UserDataType.CardSkinsData)
    return cardBagrData:GetCardSkins(roleId)
end

---------------------------------------------------------------
-- 全局获取数据
---------------------------------------------------------------
function Utility.GetCurrenLevelIntervarExp()
    local PlayerPromote = require "StaticData.PlayerPromote"
    local UserDataType = require "Framework.UserDataType"
    local dataCacheMgr = Utility.GetGame():GetDataCacheManager()
    local userData = dataCacheMgr:GetData(UserDataType.PlayerData)
    if userData:GetLevel() == 80 then
        return PlayerPromote:GetData(79):GetexpPerLevel()
    end
    return PlayerPromote:GetData(userData:GetLevel()):GetexpPerLevel()
end

function Utility.GetLevelIntervalExp(level)
    local PlayerPromote = require "StaticData.PlayerPromote"
    if level == 80 then
        return PlayerPromote:GetData(79):GetexpPerLevel()
    end
    return PlayerPromote:GetData(level):GetexpPerLevel()
end

---------------------------------------------------------------
-- 角色uid
---------------------------------------------------------------
function Utility.IsValidUid(uid)
    return uid and uid ~= 0
end

---------------------------------------------------------------
-- 加载用户信息(登录/注册页面用)
---------------------------------------------------------------
function Utility.LoadAllUserData(table, func)
    local ServerService = require "Network.ServerService"
    local NetworkBatchProcessing = require "Network.NetworkBatchProcessing"
    local net = require "Network.Net"
    local networkBatcher = NetworkBatchProcessing.New()
    networkBatcher:SetCallback(table, func)
    networkBatcher:Add(net.S2CLoadPlayerResult, ServerService.LoadPlayer())
    networkBatcher:Add(net.S2CItemBagQueryResult, ServerService.ItemBagQueryRequest())
    networkBatcher:Add(net.S2CEquipBagQueryResult, ServerService.EquipBagQueryRequest())
    networkBatcher:Add(net.S2CEquipSuipianBagQueryResult, ServerService.EquipSuipianBagQueryRequest())
    networkBatcher:Add(net.S2CCardBagQueryResult, ServerService.CardBagQuery())
    networkBatcher:Add(net.S2CFBQueryAllMapResult, ServerService.QueryAllMaps())
    -- TODO 要加其他数据 放在下边
    networkBatcher:Add(net.S2CCardSuipianBagQueryResult, ServerService.CardSuipianBagQueryRequest())
    networkBatcher:Add(net.S2CGuideRedResult, ServerService.GuideRedRequest())
	networkBatcher:Add(net.S2CGuideStateResult, ServerService.GuideStateRequest())
    networkBatcher:Add(net.S2CWorldBossTotalResult, ServerService.WorldBossTotalRequest())
    networkBatcher:Add(net.S2CCardSkinBagQueryResult, ServerService.CardSkinBagQueryRequest())
    networkBatcher:Add(net.S2CTarotQueryResult, ServerService.TarotQueryRequest())
    
    return networkBatcher
end

---------------------------------------------------------------
-- 打开战斗页面
---------------------------------------------------------------
function Utility.StartBattle(battleParams, leftTeams, rightTeam, handler)
    -- >> 验证 << --
    battleParams:Verify()

    -- >> 从阵容进入战斗 << --
    local FormationClass = require "GUI.Formation.Formation"
    local sceneManager = Utility.GetGame():GetSceneManager()

    local formation = FormationClass.New(battleParams:GetBattleType(), function(_, ...)
        local BattleSceneClass = require "Scenes.BattleScene"
        if type(handler) == "function" then
            handler(...)
        end
        sceneManager:PushScene(BattleSceneClass.New(battleParams, leftTeams, rightTeam))
    end, nil)

    sceneManager:PushScene(formation)

    return formation
end

-- fightRecordMessage 传FightRecordMessage类型的协议数据
-- responseMsg 传结算数据
-- replacementBattleParams 优化时用, 通常传nil即可.
function Utility.StartReplay(fightRecordMessage, responseMsg, className, replacementBattleParams)
    -- >> 初始化 BattleParams << --
    local battleParams = replacementBattleParams or require "LocalData.Battle.BattleParams".New()
    battleParams:SetScriptID(nil)
    battleParams:SetBattleOverLocalDataName(nil)
    battleParams:SetBattleStartProtocol(nil)
    battleParams:SetBattleResultResponsePrototype(nil)
    battleParams:SetBattleResultViewClassName(className)
    battleParams:InitByProtobuf(fightRecordMessage.fightingData.startParams)
    battleParams:DisableManuallyOperation()
    battleParams:SetReplayDataResultResponseMsg(responseMsg)
    battleParams:SetReplayDataMessage(fightRecordMessage)

    -- >> 构造双方队伍 << --
    local BattleUtility = require "Utils.BattleUtility"

    -- 获得己方队伍 --
    local rightTeam = BattleUtility.GetBattleTeamByProtobufTeam(fightRecordMessage.fightingData.rightCards)

    -- 获得敌方队伍列表 --
    local leftTeams = BattleUtility.GetBattleTeamsByProtobufTeams(fightRecordMessage.fightingData.leftWaves)

    -- 进入场景 --
    local game = Utility.GetGame()
    local GamePhase = require "Game.GamePhase"
    local BattleSceneClass = require "Scenes.BattleScene"
    local sceneManager = Utility.GetGame():GetSceneManager()
    if game:GetCurrentPhase() == GamePhase.Battle then
        sceneManager:ReplaceScene(BattleSceneClass.New(battleParams, leftTeams, rightTeam))
    else
        sceneManager:PushScene(BattleSceneClass.New(battleParams, leftTeams, rightTeam))
    end
end

function Utility.StartFirstBattle()
    local firstFightConfig = require "Battle.FirstFight.FirstFightConfig".New()

    local battleParams = require "LocalData.Battle.BattleParams".New()
    battleParams:SetSceneID(firstFightConfig:GetSceneID())
    battleParams:SetScriptID(firstFightConfig:GetScriptID())
    battleParams:SetBattleType(0)
    battleParams:SetBattleOverLocalDataName(nil)
    battleParams:SetBattleStartProtocol(nil)
    battleParams:SetBattleResultResponsePrototype(nil)
    battleParams:SetBattleResultViewClassName(nil)
    battleParams:SetMaxBattleRounds(30)
    battleParams:SetBattleResultWhenReachMaxRounds(false)
    battleParams:SetPVPMode(false)
    battleParams:SetSkillRestricted(false)
    battleParams:SetUnlimitedRage(false)

    local BattleSceneClass = require "Scenes.BattleScene"
    local sceneManager = Utility.GetGame():GetSceneManager()
    sceneManager:ReplaceScene(BattleSceneClass.New(battleParams, firstFightConfig:GetLeftTeams(), firstFightConfig:GetRightTeam(), firstFightConfig))
end

-- 跳转场景 --
local function OnPopToMainScene(func)
    local sceneManager = Utility.GetGame():GetSceneManager()
    sceneManager:PopToRootScene()
    
    if type(func) == "function" then
        func()
    end
end

function Utility.PopToRootScene(func)
    local activeScene = UnityEngine.SceneManagement.SceneManager.GetActiveScene()
    if activeScene ~= nil and activeScene.name ~= "Normal" then
        -- loading 加载场景
        local windowManager = Utility.GetGame():GetWindowManager()
        local LoadingSceneCls = require "Scenes.LoadingScene"
        local windowInstance = windowManager:Show(LoadingSceneCls, "Normal")
        windowInstance:SetCallbackOnFinished(nil, function()
            OnPopToMainScene(func)
        end)
        return
    end
    OnPopToMainScene(func)
end

local function IsNormalSceneLoaded()
    local activeScene = UnityEngine.SceneManagement.SceneManager.GetActiveScene()
    return activeScene ~= nil and activeScene.name == "Normal" and not Utility.GetGame():GetSceneManager():IsLocked()
end

local function OnJumpSceneDelayWait(func)
    -- 等待场景是Normal场景 --
    repeat
        coroutine.step()
    until(IsNormalSceneLoaded(self))
    Utility.PopToRootScene(func)
end

-- 自定义跳转场景 --
function Utility.JumpScene(func)
    local messageGuids = require "Framework.Business.MessageGuids"
    Utility.GetGame():DispatchEvent(messageGuids.JumpToNormalScene, nil)
    coroutine.start(OnJumpSceneDelayWait, func)
end

local function OnPopToPreviousScene()
    local sceneManager = Utility.GetGame():GetSceneManager()
    sceneManager:PopScene()
end

function Utility.PopToPreviousScene()
    local activeScene = UnityEngine.SceneManagement.SceneManager.GetActiveScene()
    if activeScene ~= nil and activeScene.name ~= "Normal" then
        -- loading 加载场景
        local windowManager = Utility.GetGame():GetWindowManager()
        local LoginSceneCls = require "Scenes.LoadingScene"
        local windowInstance = windowManager:Show(LoginSceneCls, "Normal")
        windowInstance:SetCallbackOnFinished(nil, OnPopToPreviousScene)
        return
    end
    OnPopToPreviousScene()
end

function Utility.DropLocalData(name)
    local game = Utility.GetGame()
    local LocalDataMgr = game:GetLocalDataManager()
    return LocalDataMgr:Drop(name)
end

--获取本地化的音乐，音效
--返回值 第一个 音乐开关，第二个 音效开关
function Utility.GetMusicSound()
    local musicSetting =  UnityEngine.PlayerPrefs.GetInt(KBackgroundMusicSetting,1)
    local musicFlag = true 
    if musicSetting==0 then
        musicFlag=false
    end

    local effectSetting =  UnityEngine.PlayerPrefs.GetInt(KEffectSoundSetting,1)
    local scoundFlag = true  
    if effectSetting==0 then
        scoundFlag=false
    end
    return musicFlag,scoundFlag
end

-- 设置音乐
function Utility.SetMusicEnabled(enabled)
    UnityEngine.PlayerPrefs.SetInt(KBackgroundMusicSetting, enabled and 1 or 0)
    UnityEngine.PlayerPrefs.Save()
    local messageGuids = require "Framework.Business.MessageGuids"
    Utility.GetGame():GetEventManager():PostNotification(messageGuids.BgMusicChanged, nil, enabled)
end

-- 设置音效
function Utility.SetSoundEnabled(enabled)
    UnityEngine.PlayerPrefs.SetInt(KEffectSoundSetting, enabled and 1 or 0)
    UnityEngine.PlayerPrefs.Save()
    local messageGuids = require "Framework.Business.MessageGuids"
    Utility.GetGame():GetEventManager():PostNotification(messageGuids.EffectSoundChanged, nil, enabled)
end

-- 获得本地化是否开启了 技能特写 选项
function Utility.IsCameraPathEnable()
    return UnityEngine.PlayerPrefs.GetInt(KEffectSetting, 1) ~= 0
end

function Utility.SetCameraPathEffectEnabled(enabled)
    UnityEngine.PlayerPrefs.SetInt(KEffectSetting, enabled and 1 or 0)
    UnityEngine.PlayerPrefs.Save()
    local messageGuids = require "Framework.Business.MessageGuids"
    Utility.GetGame():GetEventManager():PostNotification(messageGuids.EffectChanged, nil, enabled)
end

function Utility.GetCurrentPlayerLevel()
    local dataCacheMgr = Utility.GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    return dataCacheMgr:GetData(UserDataType.PlayerData):GetLevel()
end

function Utility.IsCanOpenModule(modleId, checkOnly)
    -- 查看是否可以开启改功能
    local levelLimit = require"StaticData.SystemConfig.SystemBasis":GetData(modleId):GetMinLevel()

    local dataCacheMgr = Utility.GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)
    if playerData:GetLevel() < levelLimit then
        if not checkOnly then
            local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
            local windowManager = Utility.GetGame():GetWindowManager()
            local hintStr = string.format(CommonStringTable[0],levelLimit)
            windowManager:Show(ErrorDialogClass, hintStr)
        end
        return false
    end
    return true
end

local function GetCurrencyUnit(array)
    -- 获取单位
    local length = #array
    local convertLength = length - 4
    local unit = ""
    local integerLength = 0
    local decimalsLength = 0

    if  convertLength >= 2 and convertLength <= 4 then
        unit = "万"
    elseif convertLength > 4 then
        unit = "亿"
    end

    integerLength =  length % 4
    if integerLength == 0 then
        integerLength = 4
    end
    decimalsLength = 4 - integerLength

    local integerEnd = integerLength
    local decimalStart = integerEnd + 1
   
    local integerStr = ""
    for i = 1 ,integerEnd do
        integerStr = string.format("%s%s",integerStr,array[i])
    end
 
    local decimalStr = ""
    for j = decimalStart ,4 do
       decimalStr = string.format("%s%s",decimalStr,array[j])
    end

    local result 
    if integerLength == 4 then
        result = string.format("%s%s%s",integerStr,decimalStr,unit)
    else
        result = string.format("%s%s%s%s",integerStr,".",decimalStr,unit)
    end
    
    return result
end

function Utility.ConvertCurrencyUnit(value)
    -- 货币转换
    local stringUtility = require "Utils.StringUtility"
    local strArray =  stringUtility.CreateArray(value)
    
    local result = tostring(value)
    if #strArray > 5 then
        result = GetCurrencyUnit(strArray)
    end

    return result
end

function Utility.SetRectDefaut(rect)
    -- 设置recttransform默认
    rect.anchorMax = Vector2(1,1)
    rect.anchorMin = Vector2(0,0)
    rect.offsetMax = Vector2(0,0)
    rect.offsetMin = Vector2(0,0)
end

function Utility.ShowSourceWin(id)
    local SourceWinClass = require "GUI.ItemSource.SourceWin"
    local windowManager = Utility.GetGame():GetWindowManager()
    windowManager:Show(SourceWinClass, id)
end

function Utility.GetDescriptionStr(index)
    local id = require"StaticData.SystemConfig.SystemBasis":GetData(index):GetDescriptionInfo()[0]
    local hintStr = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
    return string.gsub(hintStr,"\\n","\n")
end

function Utility.GetTreeUpAddProperty(level,propertySet)
  
    local treeLevelUpData = require"StaticData.Factory.TreeLevelUp":GetData(level)
    return treeLevelUpData:GetAllProperiesByLevel(propertySet)
end

function Utility.GetUserUID()
    local dataCacheMgr = Utility.GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)
    return playerData:GetUid()
end
function Utility.GetPetMaxLevel()
   -- hzj_print(require "StaticData.EquipPetsLevel":GetKeys().Length)
    return require "StaticData.EquipPetsLevel":GetKeys().Length
   -- return playerData:GetUid()
end


return Utility