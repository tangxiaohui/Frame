local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local MileStoneItemCls = Class(BaseNodeClass)

function MileStoneItemCls:Ctor(parent)
    self.parent = parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function MileStoneItemCls:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/MileStoneItem', function(go)
        self:BindComponent(go,false)
    end)
end

function MileStoneItemCls:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    self:LinkComponent(self.parent)
    self:InitControls()
end

function MileStoneItemCls:OnResume()
    -- 界面显示时调用
    MileStoneItemCls.base.OnResume(self)
    self:RegisterControlEvents()
    self:RegisterNetworkEvents()
end

function MileStoneItemCls:OnPause()
    -- 界面隐藏时调用
    MileStoneItemCls.base.OnPause(self)
    self:UnregisterControlEvents()
    self:UnregisterNetworkEvents()
end

function MileStoneItemCls:OnEnter()
    -- Node Enter时调用
    MileStoneItemCls.base.OnEnter(self)
end

function MileStoneItemCls:OnExit()
    -- Node Exit时调用
    MileStoneItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function MileStoneItemCls:InitControls()
    local transform = self:GetUnityTransform()
    self.GetButton = transform:Find('GetButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.timeLabel = transform:Find('NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))

    self.point = transform:Find('ItemList')

    self.flag = transform:Find('Flag').gameObject

    self.ButtonImage = self.GetButton:GetComponent(typeof(UnityEngine.UI.Image))
    self.ButtonLabel = self.GetButton.transform:Find('Text'):GetComponent(typeof(UnityEngine.UI.Text))

    self.myGame = utility:GetGame()
end


function MileStoneItemCls:RegisterControlEvents()
    self.__event_button_onGetButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGetButtonClicked, self)
    self.GetButton.onClick:AddListener(self.__event_button_onGetButtonClicked__)

end

function MileStoneItemCls:UnregisterControlEvents()
    if self.__event_button_onGetButtonClicked__ then
        self.GetButton.onClick:RemoveListener(self.__event_button_onGetButtonClicked__)
        self.__event_button_onGetButtonClicked__ = nil
    end
end

function MileStoneItemCls:RegisterNetworkEvents()
    self.myGame:RegisterMsgHandler(net.S2CArenaMilestoneAwardResult, self, self.OnArenaMilestoneAwardResponse)
end

function MileStoneItemCls:UnregisterNetworkEvents()
    self.myGame:UnRegisterMsgHandler(net.S2CArenaMilestoneAwardResult, self, self.OnArenaMilestoneAwardResponse)
end


function MileStoneItemCls:OnArenaMilestoneQueryRequest(aid)
    self.myGame:SendNetworkMessage( require"Network/ServerService".OnArenaMilestoneAwardRequest(aid))
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function MileStoneItemCls:OnArenaMilestoneAwardResponse(msg)
    
    if msg.result and (msg.head.sid == self.id)  then
        self.flag.gameObject:SetActive(msg.result)
        self:SetGrayTheme()
        local windowManager = self.myGame:GetWindowManager()
        windowManager:Show(require "GUI.Task.GetAwardItem",self.items)
        self.status = 2
    end
   
end

function MileStoneItemCls:OnGetButtonClicked()
    if self.status == 0 then
        local windowManager = self.myGame:GetWindowManager()
        windowManager:Show(require "GUI.Dialogs.ErrorDialog","尚未达到领取该阶段奖励的次数")
    elseif self.status == 1 then
        self:OnArenaMilestoneQueryRequest(self.id)
    elseif self.status == 2 then
        local windowManager = self.myGame:GetWindowManager()
        windowManager:Show(require "GUI.Dialogs.ErrorDialog","已领取该阶段奖励")
    end
    
end

local function DelayRefreshItem(self,data,succeed)
    while (not self:IsReady()) do
        coroutine.step(1)
    end
    local StaticData = require "StaticData.Arena.ArenaMileStone":GetData(data.id)
    self.id = data.id
    self.status = data.status

    local wins = StaticData:GetWins()
    local itemIds = StaticData:GetItemID()
    local itemNums = StaticData:GetItemNum()

    self.timeLabel.text = string.format("成功挑战%s次",wins)
    self.flag.gameObject:SetActive(self.status == 2)

    local gametool = require "Utils.GameTools"
    local nodeCls = require "GUI.Item.GeneralItem"

    local items = {}

    for i = 0 ,itemIds.Count -1 do
        local id = itemIds[i]
        local num = itemNums[i]
        local _,data,_,_,itype = gametool.GetItemDataById(id)
        local color = gametool.GetItemColorByType(itype,data)
        local node = nodeCls.New(self.point,id,num,color)
        self:AddChild(node)

        items[i+1] = {}
        items[i+1].id = id
        items[i+1].count = count
        items[i+1].color = color
    end

    self.items = items

    if self.status == 0 or self.status == 2 then
      self:SetGrayTheme()
    end

end

function MileStoneItemCls:SetGrayTheme()
    local graymaterial = utility:GetGrayMaterial()
    self.ButtonImage.material = graymaterial
    self.ButtonLabel.material = graymaterial
    self.GetButton.interactable = false
end

function MileStoneItemCls:RefreshItem(data)
    -- coroutine.start(DelayRefreshItem,self,data)  
    self:StartCoroutine(DelayRefreshItem, data)
end

return MileStoneItemCls