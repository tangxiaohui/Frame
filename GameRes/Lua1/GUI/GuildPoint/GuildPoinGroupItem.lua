local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"

local GuildPointGroupItemCls = Class(BaseNodeClass)

function GuildPointGroupItemCls:Ctor(parent,data,isGuild)
	self.parent = parent
	self.data = data
	self.isGuild = isGuild
end

function  GuildPointGroupItemCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/GuildPointFightRankItem",function(go)
		self:BindComponent(go)
	end)
end

function GuildPointGroupItemCls:OnComponentReady()
	self:LinkComponent(self.parent)
	self:InitControls()

end

function GuildPointGroupItemCls:OnResume()
	GuildPointGroupItemCls.base.OnResume(self)
	self:ShowItem()
end

function GuildPointGroupItemCls:OnPause()
	GuildPointGroupItemCls.base.OnPause(self)
end

function GuildPointGroupItemCls:OnEnter()
	GuildPointGroupItemCls.base.OnEnter(self)
	-- self:ShowPanel()
end

function GuildPointGroupItemCls:OnExit()
	GuildPointGroupItemCls.base.OnExit(self)
end

function GuildPointGroupItemCls:InitControls()
	local transform = self:GetUnityTransform()

	self.playerName = transform:Find("NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.LvLabel = transform:Find("Lv/LvLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerGuildName = transform:Find("GuildLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerPoint = transform:Find("PointLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.playerHeader = transform:Find("Head/Base/PersonalInformationHeadIcon"):GetComponent(typeof(UnityEngine.UI.Image))

	--排名
	self.rank = transform:Find("Rank")
	self.playerRankObj = self.rank:Find("MyRanktext")
	self.playerGuildRankObj = self.rank:Find("MyGuildRank")
	self.rankNum = {} --前三名
	for i=1,3 do
		self.rankNum[i] = self.rank:Find("Rank"..i)
	end
	self.rankOtherNum = self.rank:Find("RankLabel"):GetComponent(typeof(UnityEngine.UI.Text)) --除前三名的排名

end

function GuildPointGroupItemCls:ShowItem()
	local playerData = self.data
	self.playerName.text = playerData.name
	self.LvLabel.text = playerData.playerLv
	self.playerPoint.text = playerData.point
	if self.isGuild then
		self.playerGuildName.text = playerData.playerName
		self:SetPlayerHeader(playerData.guildHead,false)
		self.playerRankObj.gameObject:SetActive(false)
		self.playerGuildRankObj.gameObject:SetActive(true)
	else
		self.playerGuildName.text = playerData.guildName
		self:SetPlayerHeader(playerData.playerHead,true)
		self.playerRankObj.gameObject:SetActive(true)
		self.playerGuildRankObj.gameObject:SetActive(false)
	end
	self:SetRank(playerData.rank)
end

function GuildPointGroupItemCls:SetPlayerHeader(playerHead,isPlayer)
	-- 设置玩家头像
	if playerHead ~= 0 and playerHead ~= nil and playerHead ~= "" then
		if isPlayer then
			utility.LoadRoleHeadIcon(playerHead,self.playerHeader)
		else
			local GuildCommonFunc = require "GUI.Guild.GuildCommonFunc"
			local iconPath, _, _ = GuildCommonFunc.GetGuildIconInfo(playerHead)
			utility.LoadSpriteFromPath(iconPath,self.playerHeader)
		end
	end
end

function GuildPointGroupItemCls:SetRank(rank)
	self:HideAllRank()
	if rank ~= 0 and rank ~= nil then
		if rank <= #self.rankNum then
			self.rankNum[rank].gameObject:SetActive(true)
		else
			self.rankOtherNum.gameObject:SetActive(true)
			self.rankOtherNum.text = rank
		end
	end
end

function GuildPointGroupItemCls:HideAllRank()
	for i=1,3 do
		self.rankNum[i].gameObject:SetActive(false)
	end
	self.rankOtherNum.gameObject:SetActive(false)
end

return GuildPointGroupItemCls