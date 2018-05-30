--
-- User: fbmly
-- Date: 3/30/17
-- Time: 10:27 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local ChapterLevelUtils = require "Utils.ChapterLevelUtils"
require "System.LuaDelegate"
require "Const"

local ChapterItemNode = Class(BaseNodeClass)

function ChapterItemNode:Ctor(data, parent)
    self.callback = LuaDelegate.New()
    self.lastToggleState = false
    self.chapterData = data
    self.parent = parent
    self.isOpen = nil
end

function ChapterItemNode:GetChapterData()
    return self.chapterData
end

function ChapterItemNode:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/CheckpointChapterButtonElement', function(go)
        self:BindComponent(go, false)
    end)
end

function ChapterItemNode:OnComponentReady()
    self:LinkComponent(self.parent)
    self:InitControls()
end

-- 更新红点状态(客户端计算部分)
function ChapterItemNode:UpdateRedDotStatus(active)
    if self.redDotImage == nil then
        return
    end

    if self.chapterData == nil then
        return
    end

    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)

    local userData = self:GetCachedData(UserDataType.PlayerData)
    local playerLevel = userData:GetLevel()
    
    local status1 = playerLevel >= self.chapterData:GetChapterLv()
    local status2 = playerChapterData:GetChapterCompleteStatus(self.chapterData:GetId(), 1) == kChapterBoxStatus_NotReceiveYet
    local status3 = playerChapterData:GetChapterCompleteStatus(self.chapterData:GetId(), 2) == kChapterBoxStatus_NotReceiveYet
    local status4 = playerChapterData:GetChapterCompleteStatus(self.chapterData:GetId(), 3) == kChapterBoxStatus_NotReceiveYet
    

    self.redDotImage.enabled = status1 and (status2 or status3 or status4)
end

local function SetSelected(self, isSelect)
    self.ChapterFrameObject:SetActive(isSelect)
end

function ChapterItemNode:SetSelected(isSelect)
    if isSelect and not self:IsReady() then
        self.selectedOnStart = true
        return
    end

    SetSelected(self, isSelect)
end

function ChapterItemNode:SetCallback(table, func)
    self.callback:Set(table, func)
end

local function IsOpen(self)
    local UserDataType = require "Framework.UserDataType"
    local playerData = self:GetCachedData(UserDataType.PlayerData)
    local playerLevel = playerData:GetLevel()
    return ChapterLevelUtils.CanPlayTheChapter(self.chapterData:GetId(), playerLevel)
end

local function DoesCanEnter(self)
    -- -- 找到当前章节的前置章节ID
    -- local preChapterID = self.chapterData:GetPreChapterID()
    -- if preChapterID <= 0 then
    --     -- 为0说明无条件开启!
    --     return true, nil
    -- end

    -- local chapterMgr = require "StaticData.Chapter"
    -- local prevChapterData = chapterMgr:GetData(preChapterID)

    -- local levelID = prevChapterData:GetFirstLevelID()
    -- local chapterID = prevChapterData:GetId()
    -- local currentLevelData

    -- local levelMgr = require "StaticData.ChapterLevel"


    -- while(levelID > 0)
    -- do
    --     currentLevelData = levelMgr:GetData(levelID)

    --     -- 遍历结束了?
    --     if currentLevelData:GetChapterId() ~= chapterID then
    --         break
    --     end

    --     -- 获取动态数据
    --     local UserDataType = require "Framework.UserDataType"
    --     local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    --     local star = playerChapterData:GetLevelStar(chapterID, currentLevelData:GetId())
    --     if star <= 0 then
    --         -- 没有打过去??
    --         return false, string.format("您需要先通关 %s", prevChapterData:GetChapterInfo():GetName())
    --     end

    --     levelID = currentLevelData:GetNextLevelId()
    -- end

    -- return true, nil
end

function ChapterItemNode:UpdateView()
    if not self:IsReady() then
        return false
    end

    local open = (IsOpen(self))

    if open ~= self.isOpen then
        self.isOpen = open
        if open then
            self.ChapterImage.material = utility.GetCommonMaterial()
            self.ChapterLabel.color = UnityEngine.Color.New(1, 0.796078431372549, 0.172549019607843, 1)
        else
            self.ChapterImage.material = self.GrayMaterial
            self.ChapterLabel.color = UnityEngine.Color.New(0.631372549019608, 0.631372549019608, 0.631372549019608, 1)
        end
    end

    return open
end

function ChapterItemNode:InitControls()
    local transform = self:GetUnityTransform()

    self.ChapterButton = transform:Find("ChapterButton"):GetComponent(typeof(UnityEngine.UI.Button))

    self.ChapterImage = transform:Find("ChapterButton"):GetComponent(typeof(UnityEngine.UI.Image))

    --self.GrayMaterial = self.ChapterImage.material
    self.GrayMaterial = utility.GetGrayMaterial()


    self.ChapterLabel = transform:Find("ChapterButton/ChapterButtonLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.ChapterLabel.text = string.format("%s\n%s", self.chapterData:GetChapterInfo():GetNumText(),
                                                self.chapterData:GetChapterInfo():GetName())

    self.ChapterFrameObject = transform:Find("ChapterButton/ChapterButtonFarme").gameObject

    self.redDotImage = transform:Find("ChapterButton/RedDot"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 初始选择 --
    if self.selectedOnStart then
        self.ChapterFrameObject:SetActive(true)
        self.selectedOnStart = nil
        self.callback:Invoke(self)
    end

    self:UpdateView()
end

function ChapterItemNode:OnResume()
    ChapterItemNode.base.OnResume(self)
    self:RegisterControlEvents()
	
    self:UpdateRedDotStatus()

    utility.LoadTextureSprite("Checkpoint", self.chapterData:GetHeadImage(), self.ChapterImage)
end

function ChapterItemNode:OnPause()
    ChapterItemNode.base.OnPause(self)
    self:UnregisterControlEvents()
end

-- 注册事件
function ChapterItemNode:RegisterControlEvents()
    -- 注册 ChapterButton 的事件
    self.__event_button_onChapterButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChapterButtonClicked, self)
    self.ChapterButton.onClick:AddListener(self.__event_button_onChapterButtonClicked__)
end

function ChapterItemNode:UnregisterControlEvents()
    -- 取消注册 ChapterButton 的事件
    if self.__event_button_onChapterButtonClicked__ then
        self.ChapterButton.onClick:RemoveListener(self.__event_button_onChapterButtonClicked__)
        self.__event_button_onChapterButtonClicked__ = nil
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ChapterItemNode:OnChapterButtonClicked()
    -- # 如果不能打开 就弹出错误消息!
    local res, reason = IsOpen(self)
    if not res then
        utility.ShowErrorDialog(reason)
        return
    end

    -- # 回调
    self.callback:Invoke(self)
end

return ChapterItemNode