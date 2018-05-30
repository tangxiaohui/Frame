--
-- User: HZJ
-- Date: 10/08/2017
-- Time: 12:26 AM
--

local NodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"
 
local BattleSkillBlackBoardNode = Class(NodeClass)

local function InitControls(self)
   -- local transform = self:GetUnityTransform()
    --self.label = transform:Find("Label"):GetComponent(typeof(UnityEngine.UI.Text))
end

function BattleSkillBlackBoardNode:Ctor(owner)
    self.owner=owner
    print(owner,"    ------------------------")
 --   self:BindComponent(transform.gameObject, false)
 self.Battlefield = self.owner:GetBattlefield()
 
    InitControls(self)

end

local function DelayChange(self,time,color,flag)
    local  time = time
    local currentTime = 0
    if flag==false then
        currentTime=time*0.3
    end
    self.skillSceneObject = self.Battlefield:GetSceneEnvironment()
    if self.skillSceneObject ~= nil then
        local tableRenders = self.skillSceneObject:GetComponentsInChildren(typeof(UnityEngine.MeshRenderer))
        while(currentTime<time)do
            currentTime=currentTime+Time.deltaTime
         
            for i=0,tableRenders.Length-1 do
                if flag then
                     tableRenders[i].material.color = UnityEngine.Color((1-(currentTime/time)*(1-color)), (1-(currentTime/time)*(1-color)),(1-(currentTime/time)*(1-color)), 1);
                else
                     tableRenders[i].material.color = UnityEngine.Color((currentTime/time)*color, (currentTime/time)*color,(currentTime/time)*color, 1);
                end

            end
            coroutine.step()


        end
        for i=0,tableRenders.Length-1 do
        tableRenders[i].material.color = UnityEngine.Color(color, color, color, 1);
    end

    end
end 

local function OnBattleSkillBlackBoardBlack(self,time,color)
    if self.coroutineTable~=nil then
        self:StopCoroutine(self.coroutineTable) 
    end
    --coroutine.start(DelayChange,self,time,color,true) 
   self.coroutineTable=self:StartCoroutine(DelayChange,time,color,true)  
end

local function OnBattleSkillBlackBoardWhite(self,time,color)
    
    if self.coroutineTable~=nil then
        self:StopCoroutine(self.coroutineTable) 
    end
  --  coroutine.start(DelayChange,self,time,color,false) 
    self.coroutineTable=self:StartCoroutine(DelayChange,time,color,false) 
    -- if self.skillSceneObject ~= nil then
    --     -- self.skillSceneObject:SetActive(true)
    --     local tableRenders = self.skillSceneObject:GetComponentsInChildren(typeof(UnityEngine.MeshRenderer))
    --         for i=0,tableRenders.Length-1 do
    --             tableRenders[i].material.color = UnityEngine.Color(1, 1, 1, 1);
    --         end
    --     self.skillSceneObject = nil
    --  end
end

function BattleSkillBlackBoardNode:OnEnter()
    BattleSkillBlackBoardNode.base.OnEnter(self)
   self:RegisterEvent(messageGuids.BattleSkillBlackBoardBlack, OnBattleSkillBlackBoardBlack,nil)
   self:RegisterEvent(messageGuids.BattleSkillBlackBoardWhite, OnBattleSkillBlackBoardWhite,nil)


end
function BattleSkillBlackBoardNode:OnExit()
    BattleSkillBlackBoardNode.base.OnExit(self)
   self:UnregisterEvent(messageGuids.BattleSkillBlackBoardBlack, OnBattleSkillBlackBoardBlack,nil)
   self:UnregisterEvent(messageGuids.BattleSkillBlackBoardWhite, OnBattleSkillBlackBoardWhite,nil)
end

-- local function DelayHideBubble(self)
--     coroutine.wait(0.5)
--     self:InactiveComponent()
-- end

-- local function GetCurrentCamera(unit)
--     local battlefield = unit:GetBattlefield()
--     local worldCameraObject = battlefield:GetCurrentCamera()
--     if worldCameraObject ~= nil then
--         return worldCameraObject:GetComponent(typeof(UnityEngine.Camera))
--     end
--     return nil
-- end

-- local function Reposition(self, unit)
--     local gameObject = unit:GetGameObject()
--     local worldCamera = GetCurrentCamera(unit)
--     local transform = gameObject.transform:Find("Dummy002")

--     if worldCamera == nil or transform == nil then
--         return false
--     end

--     local screenPoint = worldCamera:WorldToScreenPoint(transform.position)
--     local uiCamera = self:GetUIManager():GetMainUICanvas():GetCamera()

--     local bubbleTransform = self:GetUnityTransform()

--     local _, worldPosition = UnityEngine.RectTransformUtility.ScreenPointToWorldPointInRectangle(bubbleTransform, screenPoint, uiCamera, nil)

--     bubbleTransform.position = worldPosition
--     local pos = bubbleTransform.localPosition
--     pos.z = 0
--     bubbleTransform.localPosition = pos
--     return true
-- end

-- local function OnBattleShowSkillBubble(self, unit, text)
--     print("执行显示气泡")
--     if Reposition(self, unit) then
--         self.label.text = text
--         self:ActiveComponent()
--         self:StartCoroutine(DelayHideBubble)
--     end
-- end

function BattleSkillBlackBoardNode:OnResume()
    print("注册场景变黑 >>>> 1")
 --   self:RegisterEvent(messageGuids.BattleShowSkillBubble, OnBattleShowSkillBubble, nil)
end

function BattleSkillBlackBoardNode:OnPause()
    print("注册场景变亮 >>>> 2")
  --  self:UnregisterEvent(messageGuids.BattleShowSkillBubble, OnBattleShowSkillBubble, nil)
end

return BattleSkillBlackBoardNode
