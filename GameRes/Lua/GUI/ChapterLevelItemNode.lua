
local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local ChapterLevelUtils = require "Utils.ChapterLevelUtils"
require "Const"

local ChapterLevelItemNode = Class(BaseNodeClass)

function ChapterLevelItemNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    self:InitControls()
    self.levelData = nil
end

local function SetStarStatus(self, image, active)
    if active then
        image.sprite = self.starLightSprite
    else
        image.sprite = self.starGraySprite
    end
end

local function ClearStarStatus(self, image)
    image.sprite = nil
end

local function IsNew(self, canPlay)
	if not canPlay then
		return false
	end
	
	local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    local currentStar = playerChapterData:GetLevelStar(self.levelData:GetChapterId(), self.levelData:GetId())
	
	--print("@@@@@@@ 关卡 ", self.levelData:GetId(), currentStar)

	
	return currentStar <= 0
end

local function CanPlay(self)
    local UserDataType = require "Framework.UserDataType"
    local playerData = self:GetCachedData(UserDataType.PlayerData)
    return ChapterLevelUtils.CanPlayTheLevelSelf(self.levelData:GetId(), playerData:GetLevel())

    -- local UserDataType = require "Framework.UserDataType"
    -- local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    -- local currentStar = playerChapterData:GetLevelStar(self.levelData:GetChapterId(), self.levelData:GetId())
    -- if not self:HasStarControl() and currentStar > 0 then   
    --     self.Complete.gameObject:SetActive(true)

    --     return false, "这个关卡只能通关一次!"
    -- end
 

    -- local prevId = self.levelData:GetPreLevelId()
    -- if prevId == 0 then
    --     return true, nil
    -- end

    -- local star = playerChapterData:GetLevelStar(self.levelData:GetChapterId(), prevId)

    -- if star > 0 then
    --     return true, nil
    -- else
    --     local levelMgr = require "StaticData.ChapterLevel"
    --     local prevLevelData = levelMgr:GetData(prevId)

    --     return false, string.format("请先通关 %s", prevLevelData:GetLevelInfo():GetName())
    -- end
end

local function UpdateView(self)

    if self.levelData == nil then
        return
    end

    if self.Complete ~= nil then
        self.Complete.gameObject:SetActive(false)
    end

    -- 显示图片
    utility.LoadTextureSprite("Checkpoint", self.levelData:GetLevelImage(), self.Image)

    -- 不能玩这关!!!
    local canPlay = (CanPlay(self))
    if canPlay then
        self.Image.material = utility.GetCommonMaterial()
		self.levelTitle.material = nil
    else
        self.Image.material = self.GrayMaterial
		self.levelTitle.material = utility.GetGrayMaterial(true)
    end

	-- 刷新描述 --
	self.levelTitle.text = self.levelData:GetLevelInfo():GetChapterNum()
	
	-- new flag
	self.newAnimationObject:SetActive(IsNew(self, canPlay))

    -- 不能显示星级 隐藏:SetActive(false) --
    if (not canPlay) or (not self:HasStarControl()) then
        self.starLayoutObject:SetActive(false)
        ClearStarStatus(self, self.starObjectImages[1])
        ClearStarStatus(self, self.starObjectImages[2])
        ClearStarStatus(self, self.starObjectImages[3])
        return
    end

    -- 刷新星级控件
    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    local star = playerChapterData:GetLevelStar(self.levelData:GetChapterId(), self.levelData:GetId())

    SetStarStatus(self, self.starObjectImages[1], star >= 1)
    SetStarStatus(self, self.starObjectImages[2], star >= 2)
    SetStarStatus(self, self.starObjectImages[3], star >= 3)
    self.starLayoutObject:SetActive(true)
end

function ChapterLevelItemNode:SetData(data)
    self.levelData = data

    if self:IsReady() then
        UpdateView(self)
    end
end

function ChapterLevelItemNode:OnComponentReady()
end

function ChapterLevelItemNode:UpdateView()
    UpdateView(self)
end

function ChapterLevelItemNode:OnResume()
    ChapterLevelItemNode.base.OnResume(self)
    self:RegisterControlEvents()
end

function ChapterLevelItemNode:OnPause()
    ChapterLevelItemNode.base.OnPause(self)
    self:UnregisterControlEvents()
end


function ChapterLevelItemNode:InitControls()
    print("@@ ChapterLevelItemNode @@")

    local transform = self:GetUnityTransform()

    self.MainButton = transform:Find(''):GetComponent(typeof(UnityEngine.UI.Button))
    self.Image = transform:Find(''):GetComponent(typeof(UnityEngine.UI.Image))
    self.GrayMaterial = utility.GetGrayMaterial()
	
	self.newAnimationObject = transform:Find("New").gameObject
	self.newAnimationObject:SetActive(false)
    self.Complete=transform:Find('Complete'):GetComponent(typeof(UnityEngine.UI.Image))
    self.Complete.gameObject:SetActive(false)

	self.levelTitle = transform:Find("Title"):GetComponent(typeof(UnityEngine.UI.Text))
	self.levelTitle.text = nil

    -- 用于隐藏和操作用!
    self.starLayoutTrans = transform:Find('StarLayout')
    self.starLayoutObject = self.starLayoutTrans.gameObject

    if self.starLayoutTrans ~= nil then
        self.starObjectImages = {
            self.starLayoutTrans:Find('Star01'):GetComponent(typeof(UnityEngine.UI.Image)),
            self.starLayoutTrans:Find('Star02'):GetComponent(typeof(UnityEngine.UI.Image)),
            self.starLayoutTrans:Find('Star03'):GetComponent(typeof(UnityEngine.UI.Image))
        }

        self.starGraySprite = self.starObjectImages[1].sprite
        self.starLightSprite = self.starObjectImages[2].sprite
    end


end

-- 是否显示星级, 是否可以扫荡!
function ChapterLevelItemNode:HasStarControl()
    local levelType = self.levelData:GetFbType()
    return levelType ~= kLevelType_Normal and levelType ~= kLevelType_Hidden
end

function ChapterLevelItemNode:RegisterControlEvents()
    -- 注册按钮事件
    self.__event_button_ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMainButtonClicked, self)
    self.MainButton.onClick:AddListener(self.__event_button_ButtonClicked__)
end

function ChapterLevelItemNode:UnregisterControlEvents()
    -- 取消注册按钮事件
    if self.__event_button_ButtonClicked__ then
        self.MainButton.onClick:RemoveListener(self.__event_button_ButtonClicked__)
        self.__event_button_ButtonClicked__ = nil
    end
end

function ChapterLevelItemNode:OnMainButtonClicked()
    if self.levelData == nil then
        return
    end

    local res,errorMsg = CanPlay(self)
    if not res then
        utility.ShowErrorDialog(
            errorMsg
        )
        return
    end


    local CheckpointFightModuleClass = require "GUI.Modules.CheckpointFightModule"
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(CheckpointFightModuleClass, self.levelData)
end

return ChapterLevelItemNode