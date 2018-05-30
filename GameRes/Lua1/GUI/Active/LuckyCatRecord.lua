local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"

local LuckyCatRecord = Class(BaseNodeClass)

local rowCount = 5
local hight = 40
local width = 291
function  LuckyCatRecord:Ctor(parent,name,number)
	self.parent = parent
	self.name = name
	self.number = number
end

function  LuckyCatRecord:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/LuckyCatRecord",function(go)
		self:BindComponent(go)
	end)
end

function LuckyCatRecord:OnComponentReady()
	self:InitControls()
	self:LinkComponent(self.parent)
end

function LuckyCatRecord:OnResume()
	LuckyCatRecord.base.OnResume(self)
	-- self:Show(self.name,self.number)
end

function LuckyCatRecord:OnPause()
	LuckyCatRecord.base.OnPause(self)
end

function LuckyCatRecord:OnEnter()
	LuckyCatRecord.base.OnEnter(self)
	self.transform.sizeDelta =Vector2(width,hight)
	self:Show(self.name,self.number)
end

function LuckyCatRecord:OnExit()
	LuckyCatRecord.base.OnExit(self)
end

function LuckyCatRecord:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform
	self.nameLabel = transform:Find("Name"):GetComponent(typeof(UnityEngine.UI.Text))
	self.image = transform:Find("Image")
	self.numberLabel = transform:Find("Number"):GetComponent(typeof(UnityEngine.UI.Text))
end

function LuckyCatRecord:Show(name,number)
	-- debug_print(string.format(ActivityStringTable[3],name))
	name = string.format(ActivityStringTable[3],name)
	self.nameLabel.text = name
	self.numberLabel.text = number
	local nameWidth = self:GetStringWordNum(name)*self.nameLabel.fontSize
	local numberWidth = self:GetStringWordNum(number)*self.numberLabel.fontSize
	local imageWidth = self.image.rect.width
	local allWidth = {}
	allWidth[1] = nameWidth + rowCount 
	allWidth[2] = allWidth[1] + rowCount + imageWidth
	allWidth[3] = allWidth[2] + numberWidth
	self.nameLabel.transform.sizeDelta =Vector2(nameWidth,hight)
	self.numberLabel.transform.sizeDelta =Vector2(numberWidth,hight)
	if allWidth[3] > width then
		debug_print(self.numberLabel.transform.localPosition.y - hight)
		self.numberLabel.transform.localPosition = Vector2(imageWidth+rowCount,self.numberLabel.transform.localPosition.y - hight)
		self.image.localPosition = Vector2(0,self.image.localPosition.y - hight)
		self.transform.sizeDelta =Vector2(width,hight*2)
	else
		self.numberLabel.transform.localPosition = Vector2(allWidth[2],self.numberLabel.transform.localPosition.y)
		self.image.localPosition = Vector2(allWidth[1],self.image.localPosition.y)
		self.transform.sizeDelta =Vector2(width,hight)
	end
end

--計算字符個數
function LuckyCatRecord:GetStringWordNum(str)
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        i = i + byteCount
        count = count + 1
    end
    return count
end

return LuckyCatRecord