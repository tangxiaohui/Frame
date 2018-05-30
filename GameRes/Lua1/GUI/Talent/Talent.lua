local calculateRed = require"Utils.CalculateRed"
local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
-- local messageManager = require "Network.MessageManager"
local TalentCls = Class(BaseNodeClass)
require "Object.LuaGameObject"
function TalentCls:Ctor()
end

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function GetRoleTalentData(id)
	return require "StaticData.Talent.RoleTalent":GetData(id)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TalentCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Talent 1', function(go)
		self:BindComponent(go)
	end)
end

function TalentCls:OnWillShow(cardID)
	self.cardID=cardID
	-- body
end

function TalentCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self.path="Effect/Effects/UI/UI_huxi_shizi"
	self:InitControls()
end

function TalentCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function TalentCls:OnResume()
	-- 界面显示时调用
	TalentCls.base.OnResume(self)
	-- 记录行为
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_CardTalentView)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)
	self:RegisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.ModuleRedDotChanged)
	self.clickNum=0
	self:LocalRedDotChanged()
end

function TalentCls:OnPause()
	-- 界面隐藏时调用
	TalentCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.ModuleRedDotChanged)
end


function TalentCls:LocalRedDotChanged()
	if self.clickNum%2==0 then
		self.redDot.enabled =calculateRed.GetRoleTeamTalentRedDataByID(self.cardID)
		
	else
		self.redDot.enabled =calculateRed.GetRoleTalentRedDataByID(self.cardID)
	end

end

function TalentCls:ModuleRedDotChanged(cardUIDs, cardRedState)
	-- print("ModuleRedDotChanged",cardUIDs,cardRedState)
end


function TalentCls:OnEnter()
	-- Node Enter时调用
	TalentCls.base.OnEnter(self)
end

function TalentCls:OnExit()
	-- Node Exit时调用
	TalentCls.base.OnExit(self)
end

function TalentCls:Update()
end

-- local function InItConst(self)
-- 	self.openConditions={}
-- 	self.openConditions[1].Color=2
-- 	self.openConditions[1].stage=nil

-- 	self.openConditions[2].Color=3
-- 	self.openConditions[2].stage=nil

-- 	self.openConditions[3].Color=3
-- 	self.openConditions[3].stage=2

-- 	self.openConditions[4].Color=3
-- 	self.openConditions[4].stage=4

-- 	self.openConditions[5].Color=3
-- 	self.openConditions[5].stage=6
-- end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function TalentCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()

	self.WindowBase1 = transform:Find('WindowBase1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperDecoration = transform:Find('UpperDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DownerDecoration = transform:Find('DownerDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Talent_Title = transform:Find('Talent_Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TalentReturnButton = transform:Find('TalentReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Stature = transform:Find('CardInfo/Stature'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardNameShadowSpace = transform:Find('CardInfo/CardNameShadowSpace'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardNameLabel = transform:Find('CardInfo/CardNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.WindowBase = transform:Find('WindowBase'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.ShadowBase = transform:Find('WindowBase/ShadowBase'):GetComponent(typeof(UnityEngine.UI.Image))

	self.UnlockNoticeLabel = transform:Find('PersonTalent/UnlockNotice/UnlockNoticeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ResetButton = transform:Find('ResetButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.Scrollbar = transform:Find('Scroll View/Scrollbar'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.MaskImage = transform:Find('PersonTalent/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Image))

	local Object = UnityEngine.Object
	self.effectScript={}
	---人物信息
	self.Rank1RankImage=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank1Talent/FlagBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank1TalentButton=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank1Talent/Rank1TalentSelectBox/Rank1TalentTalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Rank1TalentNameLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank1Talent/Rank1TalentSelectBox/Rank1TalentTalentSkill/TalentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank1TalentStatusLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank1Talent/Rank1TalentSelectBox/Rank1TalentTalentSkill/TalentStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank1UnlockMask=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank1Talent/Rank1TalentSelectBox/Rank1TalentTalentSkill/UnlockMask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank1SkillIcon=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank1Talent/Rank1TalentSelectBox/Rank1TalentTalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	self.Rank1Effect = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	self.Rank1Effect.transform:SetParent(self.Rank1SkillIcon.transform)
	--self.effectScript[1]=self.Rank1Effect:AddComponent(typeof(ChangeMaterialValue))
	--self.effectScript[1]:Init(self.MaskImage,self.Rank1SkillIcon)
	self.Rank1Effect.transform.localScale=Vector3(0.65, 0.65, 1);
	self.Rank1Effect.transform.localPosition=Vector3(0, 0, 0);
	self.Rank1Effect:SetActive(false)
		--  effectTrans = self.Rank1Effect.transform
		--  effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu'):GetComponent(typeof(UnityEngine.MeshRenderer))
		-- effectMeshRender.sortingOrder = 151
 	-- 	effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu2'):GetComponent(typeof(UnityEngine.MeshRenderer))
		-- effectMeshRender.sortingOrder = 151


	self.Rank2RankImage=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank2Talent/FlagBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank2TalentButton=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank2Talent/SelectBox/TalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Rank2TalentNameLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank2Talent/SelectBox/TalentSkill/TalentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank2TalentStatusLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank2Talent/SelectBox/TalentSkill/TalentStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank2UnlockMask=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank2Talent/SelectBox/TalentSkill/UnlockMask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank2SkillIcon=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank2Talent/SelectBox/TalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank2Effect = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	-- self.effectScript[2]=self.Rank2Effect:AddComponent(typeof(ChangeMaterialValue))
	-- self.effectScript[2]:Init(self.MaskImage,self.Rank2SkillIcon)
	self.Rank2Effect.transform:SetParent(self.Rank2SkillIcon.transform)
	self.Rank2Effect.transform.localScale=Vector3(0.65, 0.65, 1);
	self.Rank2Effect.transform.localPosition=Vector3(0, 0, 0);
	self.Rank2Effect:SetActive(false)
	-- effectTrans = self.Rank2Effect.transform
		--  effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu'):GetComponent(typeof(UnityEngine.MeshRenderer))
		-- effectMeshRender.sortingOrder = 151
 	-- 	effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu2'):GetComponent(typeof(UnityEngine.MeshRenderer))
		-- effectMeshRender.sortingOrder = 151




	self.Rank3RankImage=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank3Talent/FlagBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank3TalentButton=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank3Talent/SelectBox/TalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Rank3TalentNameLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank3Talent/SelectBox/TalentSkill/TalentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank3TalentStatusLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank3Talent/SelectBox/TalentSkill/TalentStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank3UnlockMask=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank3Talent/SelectBox/TalentSkill/UnlockMask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank3SkillIcon=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank3Talent/SelectBox/TalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank3Effect = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	-- self.effectScript[3]=self.Rank3Effect:AddComponent(typeof(ChangeMaterialValue))
	-- self.effectScript[3]:Init(self.MaskImage,self.Rank3SkillIcon)
	self.Rank3Effect.transform:SetParent(self.Rank3SkillIcon.transform)
	self.Rank3Effect.transform.localScale=Vector3(0.65, 0.65, 1);
	self.Rank3Effect.transform.localPosition=Vector3(0, 0, 0);
	self.Rank3Effect:SetActive(false)

		--  effectTrans = self.Rank3Effect.transform
		--  effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu'):GetComponent(typeof(UnityEngine.MeshRenderer))
		-- effectMeshRender.sortingOrder = 151
 	-- 	effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu2'):GetComponent(typeof(UnityEngine.MeshRenderer))
		-- effectMeshRender.sortingOrder = 151



	self.Rank4RankImage=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/FlagBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank4Talent1Button=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Rank4Talent1NameLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill/TalentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank4Talent1StatusLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill/TalentStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank4Unlock1Mask=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill/UnlockMask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank4Skill1Icon=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	self.Rank4Effect1 = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	self.Rank4Effect1.transform:SetParent(self.Rank4Skill1Icon.transform)
	self.Rank4Effect1.transform.localScale=Vector3(0.65, 0.65, 1);
	self.Rank4Effect1.transform.localPosition=Vector3(0, 0, -0);
	self.Rank4Effect1:SetActive(false)
	-- self.effectScript[4]=self.Rank4Effect1:AddComponent(typeof(ChangeMaterialValue))
	-- self.effectScript[4]:Init(self.MaskImage,self.Rank4Skill1Icon)

		--  effectTrans = self.Rank4Effect1.transform
		--  effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu'):GetComponent(typeof(UnityEngine.MeshRenderer))
		-- effectMeshRender.sortingOrder = 151
 	-- 	effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu2'):GetComponent(typeof(UnityEngine.MeshRenderer))
		-- effectMeshRender.sortingOrder = 151






	self.Rank4Talent2Button=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (1)/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Rank4Talent2NameLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (1)/TalentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank4Talent2StatusLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (1)/TalentStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank4Unlock2Mask=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (1)/UnlockMask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank4Skill2Icon=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (1)/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank4Effect2 = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	self.Rank4Effect2.transform:SetParent(self.Rank4Skill2Icon.transform)
	self.Rank4Effect2.transform.localScale=Vector3(0.65, 0.65, 1);
	self.Rank4Effect2.transform.localPosition=Vector3(0, 0, 0);
	self.Rank4Effect2:SetActive(false)

	-- self.effectScript[5]=self.Rank4Effect2:AddComponent(typeof(ChangeMaterialValue))
	-- self.effectScript[5]:Init(self.MaskImage,self.Rank4Skill2Icon)

	--  effectTrans = self.Rank4Effect2.transform
	-- 	 effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu'):GetComponent(typeof(UnityEngine.MeshRenderer))
	-- 	effectMeshRender.sortingOrder = 151
 -- 		effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu2'):GetComponent(typeof(UnityEngine.MeshRenderer))
	-- 	effectMeshRender.sortingOrder = 151



	self.Rank4Talent3Button=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (2)/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Rank4Talent3NameLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (2)/TalentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank4Talent3StatusLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (2)/TalentStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank4Unlock3Mask=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (2)/UnlockMask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank4Skill3Icon=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank4Talent/SelectBox/TalentSkill (2)/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank4Effect3 = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	self.Rank4Effect3.transform:SetParent(self.Rank4Skill3Icon.transform)
	self.Rank4Effect3.transform.localScale=Vector3(0.65, 0.65, 1);
	self.Rank4Effect3.transform.localPosition=Vector3(0, 0, 0);
	self.Rank4Effect3:SetActive(false)
	-- self.effectScript[6]=self.Rank4Effect3:AddComponent(typeof(ChangeMaterialValue))
	-- self.effectScript[6]:Init(self.MaskImage,self.Rank4Skill3Icon)

	--  effectTrans = self.Rank4Effect3.transform
	-- 	 effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu'):GetComponent(typeof(UnityEngine.MeshRenderer))
	-- 	effectMeshRender.sortingOrder = 151
 -- 		effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu2'):GetComponent(typeof(UnityEngine.MeshRenderer))
	-- 	effectMeshRender.sortingOrder = 151





	self.Rank5RankImage=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/FlagBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank5Talent1Button=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Rank5Talent1NameLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill/TalentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank5Talent1StatusLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill/TalentStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank5Unlock1Mask=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill/UnlockMask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank5Skill1Icon=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	self.Rank5Effect1 = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 
	self.Rank5Effect1.transform:SetParent(self.Rank5Skill1Icon.transform)
	self.Rank5Effect1.transform.localScale=Vector3(0.65, 0.65, 1);
	self.Rank5Effect1.transform.localPosition=Vector3(0, 0, 0);
	self.Rank5Effect1:SetActive(false)
	-- self.effectScript[7]=self.Rank5Effect1:AddComponent(typeof(ChangeMaterialValue))
	-- self.effectScript[7]:Init(self.MaskImage,self.Rank5Skill1Icon)
	-- 	 effectTrans = self.Rank5Effect1.transform
	-- 	 effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu'):GetComponent(typeof(UnityEngine.MeshRenderer))
	-- 	effectMeshRender.sortingOrder = 151
 -- 		effectMeshRender = effectTrans:Find('UI_kuang_donghua/UI_kuang_tianfu2'):GetComponent(typeof(UnityEngine.MeshRenderer))
	-- 	effectMeshRender.sortingOrder = 151

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))





	self.Rank5Talent2Button=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill (1)/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Rank5Talent2NameLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill (1)/TalentNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank5Talent2StatusLabel=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill (1)/TalentStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Rank5Unlock2Mask=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill (1)/UnlockMask'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank5Skill2Icon=transform:Find('PersonTalent/Scroll View/Viewport/Content/Rank5Talent/SelectBox/TalentSkill (1)/SkillIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Rank5Effect2 = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 	
	self.Rank5Effect2.transform:SetParent(self.Rank5Skill2Icon.transform)
	self.Rank5Effect2.transform.localScale=Vector3(0.65, 0.65, 1)
	self.Rank5Effect2.transform.localPosition=Vector3(0, 0, 0)
	self.Rank5Effect2:SetActive(false)
	-- self.effectScript[8]=self.Rank5Effect2:AddComponent(typeof(ChangeMaterialValue))
	-- self.effectScript[8]:Init(self.MaskImage,self.Rank5Skill2Icon)

	-- self.heroNameGameOnbject = {}
	-- for i = 1,5 do
	-- 	self.heroNameGameOnbject[i] = transform:Find("HeroCharacter/HeroCharacterPatern"..i)
	-- end
	-- self.heroNameLabel = {}
	-- for i = 1,5 do
	-- 	self.heroNameLabel[i] = transform:Find("HeroCharacter/HeroCharacterPatern1/HeroCharacterBase"..i.."/HeroCharacterBaseTextLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	-- end

	self.CardNameLabel=transform:Find("HeroCharacter/QualityGroup/QualityRank/Text"):GetComponent(typeof(UnityEngine.UI.Text))
  -- 品级颜色 --
    local qualityRank = transform:Find("HeroCharacter/QualityGroup/QualityRank")
    self.qualityRankImage = qualityRank:GetComponent(typeof(UnityEngine.UI.Image))
    self.raceIconImage=transform:Find("HeroCharacter/CardPreInfo/CardTypeBase"):GetComponent(typeof(UnityEngine.UI.Image))

	  -- 名字组 --
    local nameGroup1 = transform:Find("HeroCharacter/HeroNameGroup1")
    local nameGroup2 = transform:Find("HeroCharacter/HeroNameGroup2")
    local nameGroup3 = transform:Find("HeroCharacter/HeroNameGroup3")
    local nameGroup4 = transform:Find("HeroCharacter/HeroNameGroup4")
    local nameGroup5 = transform:Find("HeroCharacter/HeroNameGroup5")

    self.nameGroupObjects = {
        nameGroup1.gameObject,
        nameGroup2.gameObject,
        nameGroup3.gameObject,
        nameGroup4.gameObject,
        nameGroup5.gameObject,
    }

    self.nameGroupLabels = {
        nameGroup1:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup2:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup3:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup4:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup5:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
    }
    self.changeTalentButton=transform:Find("ChangeButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.changeTalentButtonText=transform:Find("ChangeButton/TextChongzhi"):GetComponent(typeof(UnityEngine.UI.Text))
    self.redDot=transform:Find("ChangeButton/RedDot"):GetComponent(typeof(UnityEngine.UI.Image))
 	self.personTalent=transform:Find("PersonTalent")
    ---团队天赋-----
    self.teamTalent=transform:Find("TeamTalent")
    self.teamTalentRank={}
    for i=1,3 do
    	self.teamTalentRank[#self.teamTalentRank+1]={}
    	self.teamTalentRank[#self.teamTalentRank].TalentNameLabel=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/TalentNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    	self.teamTalentRank[#self.teamTalentRank].TalentStatusLabel=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/TalentStatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    	self.teamTalentRank[#self.teamTalentRank].UnlockMask=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/UnlockMask")
    	self.teamTalentRank[#self.teamTalentRank].SkillIcon=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/SkillIcon"):GetComponent(typeof(UnityEngine.UI.Image))
    	self.teamTalentRank[#self.teamTalentRank].SkillIconButton=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/SkillIcon"):GetComponent(typeof(UnityEngine.UI.Button))

    	self.teamTalentRank[#self.teamTalentRank].FlagBase=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/FlagBase"):GetComponent(typeof(UnityEngine.UI.Image))
    	self.teamTalentRank[#self.teamTalentRank].RankText=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/FlagBase/RankText"):GetComponent(typeof(UnityEngine.UI.Text))
    	self.teamTalentRank[#self.teamTalentRank].name=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/Name"):GetComponent(typeof(UnityEngine.UI.Text))
    	self.teamTalentRank[#self.teamTalentRank].ExpendText=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/Expend/Text"):GetComponent(typeof(UnityEngine.UI.Text))
    	self.teamTalentRank[#self.teamTalentRank].ExpendImage=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/Expend/Image"):GetComponent(typeof(UnityEngine.UI.Image))
    	self.teamTalentRank[#self.teamTalentRank].Expend=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/Expend")
    	self.teamTalentRank[#self.teamTalentRank].Race=transform:Find("TeamTalent/Scroll View/Viewport/Content/Rank"..i.."Talent/SelectBox/TalentSkill/Race"):GetComponent(typeof(UnityEngine.UI.Image))
    	
    	self.teamTalentRank[#self.teamTalentRank].Expend.gameObject:SetActive(false)

    	self.teamTalentRank[#self.teamTalentRank].effect = Object.Instantiate(utility.LoadResourceSync(self.path, typeof(UnityEngine.GameObject))) 	
		self.teamTalentRank[#self.teamTalentRank].effect.transform:SetParent(self.teamTalentRank[#self.teamTalentRank].SkillIcon.transform)
		self.teamTalentRank[#self.teamTalentRank].effect.transform.localScale=Vector3(0.65, 0.65, 1)
		self.teamTalentRank[#self.teamTalentRank].effect.transform.localPosition=Vector3(0, 0, 0)
		self.teamTalentRank[#self.teamTalentRank].effect:SetActive(false)



    end
	self.personTalent.gameObject:SetActive(true)
	self.changeTalentButtonText.text="团队天赋"
	self.teamTalent.gameObject:SetActive(false)
-----------------------------------

	local resPathMgr = require "StaticData.ResPath"
	local data = resPathMgr:GetData(1032)
	local baozha_effect_path=data:GetPath()	
	local dialogTransform = self:GetUIManager():GetOverlayLayer()
	self.baozha_effect = Object.Instantiate(utility.LoadResourceSync(baozha_effect_path, typeof(UnityEngine.GameObject))) 
	self.baozha_effect.transform:SetParent(dialogTransform)
	self.baozha_effect:SetActive(false)
	self.baozha_effect.transform.localScale=Vector3(100, 100, 100)
	self.baozha_effect.transform.localPosition=Vector3(0, 0, 0)

	self:InitViews()
	self:InitNotice()
	self:InitTalentInfo()
	self:InitTeamTalentInfo()
	

end

--初始化人物团队天赋信息
function TalentCls:InitTeamTalentInfo()
	local roleMgr = require "StaticData.Role"
	local data = roleMgr:GetData(self.cardID)
	local teamTalents=data:GetTeamTalent()
	--debug_print(#teamTalents)
	local count = teamTalents.Count-1
		
	for i=0,count do
		local teamData = GetRoleTalentData(teamTalents[i])
		utility.LoadSpriteFromPath("UI/Atlases/Icon/TalentIcon/"..teamData:GetResourceID(),self.teamTalentRank[i+1].SkillIcon)
		self.teamTalentRank[i+1].TalentStatusLabel.text=teamData:GetDesc()
		self.teamTalentRank[i+1].name.text=teamData:GetName()
		local raceID = teamData:GetExtendID()
		if raceID>0 then
			utility.LoadRaceIcon(raceID,self.teamTalentRank[i+1].Race)
		else
			self.teamTalentRank[i+1].Race.gameObject:SetActive(false)
		end
	end
	--获取当前卡的类型
	local teamTalentBasisMgr = require "StaticData.Talent.TeamTalentBasis"
	local teamTalentBasisData=teamTalentBasisMgr:GetData(data:GetStar())

	--获取玩家卡牌的等级
	local UserDataType = require "Framework.UserDataType"
    local cardbagData = self:GetCachedData(UserDataType.CardBagData)
    local roleData=cardbagData:GetRoleById(self.cardID)
    local cardLevel = roleData:GetLv()
	for i=0,2 do
		local rank,level,needType,needNum = teamTalentBasisData:GetInfoByRank(i)
			
		--表示等级未达到
		if level>cardLevel then
			self.teamTalentRank[i+1].UnlockMask.gameObject:SetActive(true)
			self.teamTalentRank[i+1].TalentNameLabel.text=level.."级开启"
		--表示等级已达到
		else
			self.teamTalentRank[i+1].FlagBase.material=nil

			-- for i=0,count do
			-- 	debug_print(teamTalents[i],"count")
			-- end
			--debug_print(self.heroData:GetTeamTalentCount())

			local stageCount = self.heroData:GetTeamTalentCount()
			--表示已经开启
			if stageCount>i then
				-- debug_print(stageCount,"stageCount")
				self.teamTalentRank[i+1].UnlockMask.gameObject:SetActive(false)
				self.teamTalentRank[i+1].Expend.gameObject:SetActive(false)
				self.teamTalentRank[i+1].TalentNameLabel.text=""
				self.teamTalentRank[i+1].effect:SetActive(false)
				self.teamTalentRank[i+1].SkillIconButton.enabled=false
				
			--表示未开启
			else
				local _,data,_,icon = require "Utils.GameTools".GetItemDataById(needType)
				--local PropUtility = require "Utils.PropUtility"
				--local color = data:GetColor()
				--PropUtility.AutoSetColor(self.ExpItem01Color,color)
				utility.LoadSpriteFromPath(icon,self.teamTalentRank[i+1].ExpendImage)
				self.teamTalentRank[i+1].UnlockMask.gameObject:SetActive(false)
				self.teamTalentRank[i+1].Expend.gameObject:SetActive(true)
				self.teamTalentRank[i+1].ExpendText.text=needNum
				self.teamTalentRank[i+1].TalentNameLabel.text="消耗"
				self.teamTalentRank[i+1].effect:SetActive(true)
				self.teamTalentRank[i+1].SkillIconButton.enabled=true
			end			
		end
	end
end

local function ReloadNames(self, name)
    local StringUtility = require "Utils.StringUtility"
    local nameGroupCount = #self.nameGroupObjects
    local nameArray = StringUtility.CreateArray(name)
    local nameLength = math.min(nameGroupCount, #nameArray)
    for i = 1, nameGroupCount do
        local show = i <= nameLength
        self.nameGroupObjects[i]:SetActive(show)
        if show then
            self.nameGroupLabels[i].text = nameArray[i]
        end
    end
end

function TalentCls:InitViews()
	-- body
	local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local userRoleData = cardBagData:GetRoleById(self.cardID)
    require "Game.Role"
    if userRoleData == nil then
        userRoleData = Role.New()
        userRoleData:UpdateForStatic(data:GetId(), 1, 1)
    end
   	
	self.heroData = userRoleData

	utility.LoadRolePortraitImage(
		self.heroData:GetId(),
		self.Stature
	)
	 
	self.itemUID = self.heroData:GetUid()

	local PropUtility = require "Utils.PropUtility"
	local color = self.heroData:GetColor()
    self.qualityRankImage.color = PropUtility.GetColorValue(color)
    local stage = self.heroData:GetStage()

    if stage <= 0 then
        self.CardNameLabel.text = Color[color]
    else
        self.CardNameLabel.text = string.format("%s +%d", Color[color], stage)
    end
	ReloadNames(self,self.heroData:GetInfo())

	local x = 1
	utility.LoadRaceIcon(self.heroData:GetRace(),self.raceIconImage)
end

local function GetTalentNum(cardId,talentsIndex,index)
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(cardID)
	local talents=self.data:GetTalent()	
	return talents[talentsIndex]:get_Item(index)
end 

function TalentCls:InitNotice()
	local color = self.heroData:GetColor()
	local stage = self.heroData:GetStage()
	--蓝色
	if color<2 then
		self.UnlockNoticeLabel.text="<color=#26BAF4FF>蓝色  +  8 </color>时解锁下一阶天赋"
		self.rankTalent=0	
	elseif color==2 then
		self.UnlockNoticeLabel.text="<color=#FC5BFF>紫色</color>时解锁下一阶天赋"
		
		self.Rank1RankImage.material=nil	
		self.rankTalent=1	

	elseif color==3 then
		self.Rank1RankImage.material=nil
		
		if stage<2 then
			self.Rank2RankImage.material=nil
			self.UnlockNoticeLabel.text="<color=#FC5BFF>紫色  +  2 </color>时解锁下一阶天赋"
			self.rankTalent=2	
		elseif stage>=2 and stage<4 then
			
			self.UnlockNoticeLabel.text="<color=#FC5BFF>紫色  +  4 </color>时解锁下一阶天赋"
			self.rankTalent=3	
			self.Rank2RankImage.material=nil
			self.Rank3RankImage.material=nil
		elseif stage>=4 and stage<6 then
			self.Rank2RankImage.material=nil
			self.Rank3RankImage.material=nil
			self.Rank4RankImage.material=nil
			self.UnlockNoticeLabel.text="<color=#FC5BFF>紫色  +  6 </color>时解锁下一阶天赋"
			self.rankTalent=4
		else
			self.Rank2RankImage.material=nil
			self.Rank3RankImage.material=nil
			self.Rank4RankImage.material=nil
			self.Rank5RankImage.material=nil
			self.rankTalent=5	
			self.UnlockNoticeLabel.text="天赋全部解锁"
		end
	elseif color>3 then
		self.rankTalent=5
		self.UnlockNoticeLabel.text="天赋全部解锁"
	end

	--print("当前天赋的等级",self.rankTalent)
end




-------修改等级颜色----------------
function TalentCls:ChangeFlagBase(flag)
end

local function RefreshTalentControl(id, nameLabel, descLabel, icon)
	nameLabel.text = GetRoleTalentData(id):GetName()
	descLabel.text = GetRoleTalentData(id):GetDesc()
	utility.LoadSpriteFromPath("UI/Atlases/Icon/TalentIcon/" .. GetRoleTalentData(id):GetResourceID(), icon)
end


--初始化人物天赋信息
function TalentCls:InitTalentInfo()
	--print(self.heroData:GetStage(),self.heroData:GetTalent()[1],self.heroData:GetTalent()[2],self.heroData:GetTalent()[3],self.heroData:GetTalent()[4],self.heroData:GetTalent()[5])
	local AtlasesLoader = require "Utils.AtlasesLoader"
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents = self.data:GetTalent()

	-- 人物信息
	
	-- >>>>>> 天赋1
	local id = talents[1]:get_Item(0)
	RefreshTalentControl(id, self.Rank1TalentNameLabel, self.Rank1TalentStatusLabel, self.Rank1SkillIcon)
	if self.rankTalent >= 1 then
		if id == self.heroData:GetTalentByStage(1) then
			self.Rank1TalentButton.enabled=false
			self.Rank1UnlockMask.enabled=false
			self.Rank1Effect:SetActive(false)
		else    
			self.Rank1Effect:SetActive(true)
			self.Rank1TalentButton.enabled=true
			self.Rank1UnlockMask.enabled=false
		end
	else
		self.Rank1UnlockMask.enabled=true
	end

	-- >>>>>> 天赋2
	id = talents[2]:get_Item(0)
	RefreshTalentControl(id, self.Rank2TalentNameLabel, self.Rank2TalentStatusLabel, self.Rank2SkillIcon)
	if self.rankTalent >= 2 then
		--已经点过天赋
		if id == self.heroData:GetTalentByStage(2) then
			self.Rank2TalentButton.enabled = false
			self.Rank2UnlockMask.enabled = false
			self.Rank2Effect:SetActive(false)
		else
			--达到等级 未点击
			self.Rank2Effect:SetActive(true)
			self.Rank2TalentButton.enabled = true
			self.Rank2UnlockMask.enabled = false
		end
	else
			self.Rank2UnlockMask.enabled = true
	end

	-- >>>>>> 天赋3
	id = talents[3]:get_Item(0)
	RefreshTalentControl(id, self.Rank3TalentNameLabel, self.Rank3TalentStatusLabel, self.Rank3SkillIcon)
	if self.rankTalent >= 3 then
		if id == self.heroData:GetTalentByStage(3) then
			self.Rank3TalentButton.enabled=false
			self.Rank3UnlockMask.enabled=false
			self.Rank3Effect:SetActive(false)
		else    
		--	print("播放特效")
			self.Rank3Effect:SetActive(true)
			self.Rank3TalentButton.enabled=true
			self.Rank3UnlockMask.enabled=false
		end
	else
		--self.Rank3TalentButton.enabled=false
			self.Rank3UnlockMask.enabled=true
	end

	-- >>>>>> 天赋4 (0)
	RefreshTalentControl(talents[4]:get_Item(0), self.Rank4Talent1NameLabel, self.Rank4Talent1StatusLabel, self.Rank4Skill1Icon)

	-- >>>>>> 天赋4 (1)
	RefreshTalentControl(talents[4]:get_Item(1), self.Rank4Talent2NameLabel, self.Rank4Talent2StatusLabel, self.Rank4Skill2Icon)

	-- >>>>>> 天赋4 (2)
	RefreshTalentControl(talents[4]:get_Item(2), self.Rank4Talent3NameLabel, self.Rank4Talent3StatusLabel, self.Rank4Skill3Icon)
	if self.rankTalent>=4 then
			if (talents[4]:get_Item(0)==self.heroData:GetTalentByStage(4)) or (talents[4]:get_Item(1)== self.heroData:GetTalentByStage(4)) or (talents[4]:get_Item(2)== self.heroData:GetTalentByStage(4)) then
				if (talents[4]:get_Item(0)==self.heroData:GetTalentByStage(4)) then
				
					self.Rank4Talent1Button.enabled=false
					self.Rank4Unlock1Mask.enabled=false
					self.Rank4Talent2Button.enabled=false
					self.Rank4Unlock2Mask.enabled=true
					self.Rank4Talent3Button.enabled=false
					self.Rank4Unlock3Mask.enabled=true

				elseif (talents[4]:get_Item(1)== self.heroData:GetTalentByStage(4)) then
					
					self.Rank4Talent1Button.enabled=false
					self.Rank4Unlock1Mask.enabled=true
					self.Rank4Talent2Button.enabled=false
					self.Rank4Unlock2Mask.enabled=false
					self.Rank4Talent3Button.enabled=false
					self.Rank4Unlock3Mask.enabled=true
				else
					
					self.Rank4Talent1Button.enabled=false
					self.Rank4Unlock1Mask.enabled=true
					self.Rank4Talent2Button.enabled=false
					self.Rank4Unlock2Mask.enabled=true
					self.Rank4Talent3Button.enabled=false
					self.Rank4Unlock3Mask.enabled=false
				end				
				self.Rank4Effect1:SetActive(false)
				self.Rank4Effect2:SetActive(false)
				self.Rank4Effect3:SetActive(false)
			else
			--	print("播放3个特效")
				self.Rank4Effect1:SetActive(true)
				self.Rank4Effect2:SetActive(true)
				self.Rank4Effect3:SetActive(true)

				self.Rank4Talent1Button.enabled=true
				self.Rank4Unlock1Mask.enabled=false
				self.Rank4Talent2Button.enabled=true
				self.Rank4Unlock2Mask.enabled=false
				self.Rank4Talent3Button.enabled=true
				self.Rank4Unlock3Mask.enabled=false
			
			end	
			
		else

			--self.Rank4Talent1Button.enabled=false
			self.Rank4Unlock1Mask.enabled=true
			--self.Rank4Talent2Button.enabled=false
			self.Rank4Unlock2Mask.enabled=true
			--self.Rank4Talent3Button.enabled=false
			self.Rank4Unlock3Mask.enabled=true
	end


	-- >>>>>> 天赋5 (0)
	RefreshTalentControl(talents[5]:get_Item(0), self.Rank5Talent1NameLabel, self.Rank5Talent1StatusLabel, self.Rank5Skill1Icon)
	
	-- >>>>> 天赋5 (1)
	RefreshTalentControl(talents[5]:get_Item(1), self.Rank5Talent2NameLabel, self.Rank5Talent2StatusLabel, self.Rank5Skill2Icon)

	if self.rankTalent>=5 then
		if  talents[5]:get_Item(1)== self.heroData:GetTalentByStage(5) or talents[5]:get_Item(0)==self.heroData:GetTalentByStage(5)then
			if talents[5]:get_Item(1)== self.heroData:GetTalentByStage(5) then
				self.Rank5Talent2Button.enabled=false
				self.Rank5Unlock2Mask.enabled=false
				self.Rank5Talent1Button.enabled=false
				self.Rank5Unlock1Mask.enabled=true

			else 
				self.Rank5Talent2Button.enabled=false
				self.Rank5Unlock2Mask.enabled=true
				self.Rank5Talent1Button.enabled=false
				self.Rank5Unlock1Mask.enabled=false
			end
			self.Rank5Effect1:SetActive(false)
			self.Rank5Effect2:SetActive(false)
		else    
		--	print("播放两个特效")
			self.Rank5Effect1:SetActive(true)
			self.Rank5Effect2:SetActive(true)
			self.Rank5Talent2Button.enabled=true
			self.Rank5Unlock2Mask.enabled=false
			self.Rank5Talent1Button.enabled=true
			self.Rank5Unlock1Mask.enabled=false
		end

		else
			--self.Rank5Talent2Button.enabled=false
			self.Rank5Unlock2Mask.enabled=true
			--self.Rank5Talent1Button.enabled=false
			self.Rank5Unlock1Mask.enabled=true
	end
end

function TalentCls:RegisterControlEvents()
	-- 注册 TalentReturnButton 的事件
	self.__event_button_onTalentReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTalentReturnButtonClicked, self)
	self.TalentReturnButton.onClick:AddListener(self.__event_button_onTalentReturnButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTalentReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 ResetButton 的事件
	self.__event_button_onResetButtonClicked__ = UnityEngine.Events.UnityAction(self.OnResetButtonClicked, self)
	self.ResetButton.onClick:AddListener(self.__event_button_onResetButtonClicked__)

	-- -- 注册 Scroll_View 的事件
	-- self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	-- self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

	-- 注册 Scrollbar 的事件
	-- self.__event_scrollbar_onScrollbarValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnScrollbarValueChanged, self)
	-- self.Scrollbar.onValueChanged:AddListener(self.__event_scrollbar_onScrollbarValueChanged__)


	self.__event_button_onRank1TalentButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRank1TalentButtonClicked, self)
	self.Rank1TalentButton.onClick:AddListener(self.__event_button_onRank1TalentButtonClicked__)

	self.__event_button_onRank2TalentButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRank2TalentButtonClicked, self)
	self.Rank2TalentButton.onClick:AddListener(self.__event_button_onRank2TalentButtonClicked__)

	self.__event_button_onRank3TalentButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRank3TalentButtonClicked, self)
	self.Rank3TalentButton.onClick:AddListener(self.__event_button_onRank3TalentButtonClicked__)

	self.__event_button_onRank4Talent1ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRank4Talent1ButtonClicked, self)
	self.Rank4Talent1Button.onClick:AddListener(self.__event_button_onRank4Talent1ButtonClicked__)

	self.__event_button_onRank4Talent2ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRank4Talent2ButtonClicked, self)
	self.Rank4Talent2Button.onClick:AddListener(self.__event_button_onRank4Talent2ButtonClicked__)

	self.__event_button_onRank4Talent3ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRank4Talent3ButtonClicked, self)
	self.Rank4Talent3Button.onClick:AddListener(self.__event_button_onRank4Talent3ButtonClicked__)
	
	self.__event_button_onRank5Talent1ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRank5Talent1ButtonClicked, self)
	self.Rank5Talent1Button.onClick:AddListener(self.__event_button_onRank5Talent1ButtonClicked__)

	self.__event_button_onRank5Talent2ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRank5Talent2ButtonClicked, self)
	self.Rank5Talent2Button.onClick:AddListener(self.__event_button_onRank5Talent2ButtonClicked__)

	self.__event_button_onChangeTalentButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChangeTalentButtonClicked, self)
	self.changeTalentButton.onClick:AddListener(self.__event_button_onChangeTalentButtonClicked__)
	
	self.__event_button_SkillIcon1ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSkillIcon1ButtonClicked, self)
	self.teamTalentRank[1].SkillIconButton.onClick:AddListener(self.__event_button_SkillIcon1ButtonClicked__)
	
	self.__event_button_SkillIcon2ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSkillIcon2ButtonClicked, self)
	self.teamTalentRank[2].SkillIconButton.onClick:AddListener(self.__event_button_SkillIcon2ButtonClicked__)
	
	self.__event_button_SkillIcon3ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSkillIcon3ButtonClicked, self)
	self.teamTalentRank[3].SkillIconButton.onClick:AddListener(self.__event_button_SkillIcon3ButtonClicked__)
	
end

function TalentCls:UnregisterControlEvents()

	if self.__event_button_SkillIcon1ButtonClicked__ then
		self.teamTalentRank[1].SkillIconButton.onClick:RemoveListener(self.__event_button_SkillIcon1ButtonClicked__)
		self.__event_button_SkillIcon1ButtonClicked__ = nil
	end

	if self.__event_button_SkillIcon2ButtonClicked__ then
		self.teamTalentRank[2].SkillIconButton.onClick:RemoveListener(self.__event_button_SkillIcon2ButtonClicked__)
		self.__event_button_SkillIcon2ButtonClicked__ = nil
	end

	if self.__event_button_SkillIcon3ButtonClicked__ then
		self.teamTalentRank[3].SkillIconButton.onClick:RemoveListener(self.__event_button_SkillIcon3ButtonClicked__)
		self.__event_button_SkillIcon3ButtonClicked__ = nil
	end

	-- 取消注册 changeTalentButton 的事件
	if self.__event_button_onChangeTalentButtonClicked__ then
		self.changeTalentButton.onClick:RemoveListener(self.__event_button_onChangeTalentButtonClicked__)
		self.__event_button_onChangeTalentButtonClicked__ = nil
	end

	-- 取消注册 TalentReturnButton 的事件
	if self.__event_button_onTalentReturnButtonClicked__ then
		self.TalentReturnButton.onClick:RemoveListener(self.__event_button_onTalentReturnButtonClicked__)
		self.__event_button_onTalentReturnButtonClicked__ = nil
	end

	-- 取消注册 ResetButton 的事件
	if self.__event_button_onResetButtonClicked__ then
		self.ResetButton.onClick:RemoveListener(self.__event_button_onResetButtonClicked__)
		self.__event_button_onResetButtonClicked__ = nil
	end



	if self.__event_button_onRank1TalentButtonClicked__ then
		self.Rank1TalentButton.onClick:RemoveListener(self.__event_button_onRank1TalentButtonClicked__)
		self.__event_button_onRank1TalentButtonClicked__ = nil
	end


	if self.__event_button_onRank2TalentButtonClicked__ then
		self.Rank2TalentButton.onClick:RemoveListener(self.__event_button_onRank2TalentButtonClicked__)
		self.__event_button_onRank2TalentButtonClicked__ = nil
	end


	if self.__event_button_onRank3TalentButtonClicked__ then
		self.Rank3TalentButton.onClick:RemoveListener(self.__event_button_onRank3TalentButtonClicked__)
		self.__event_button_onRank3TalentButtonClicked__ = nil
	end


	if self.__event_button_onRank4Talent1ButtonClicked__ then
		self.Rank4Talent1Button.onClick:RemoveListener(self.__event_button_onRank4Talent1ButtonClicked__)
		self.__event_button_onRank4Talent1ButtonClicked__ = nil
	end

	if self.__event_button_onRank4Talent2ButtonClicked__ then
		self.Rank4Talent2Button.onClick:RemoveListener(self.__event_button_onRank4Talent2ButtonClicked__)
		self.__event_button_onRank4Talent2ButtonClicked__ = nil
	end

	
	if self.__event_button_onRank4Talent3ButtonClicked__ then
		self.Rank4Talent3Button.onClick:RemoveListener(self.__event_button_onRank4Talent3ButtonClicked__)
		self.__event_button_onRank4Talent3ButtonClicked__ = nil
	end

	if self.__event_button_onRank5Talent1ButtonClicked__ then
		self.Rank5Talent1Button.onClick:RemoveListener(self.__event_button_onRank5Talent1ButtonClicked__)
		self.__event_button_onRank5Talent1ButtonClicked__ = nil
	end

	if self.__event_button_onRank5Talent2ButtonClicked__ then
		self.Rank5Talent2Button.onClick:RemoveListener(self.__event_button_onRank5Talent2ButtonClicked__)
		self.__event_button_onRank5Talent2ButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

	-- -- 取消注册 Scroll_View 的事件
	-- if self.__event_scrollrect_onScroll_ViewValueChanged__ then
	-- 	self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
	-- 	self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	-- end

	-- 取消注册 Scrollbar 的事件
	-- if self.__event_scrollbar_onScrollbarValueChanged__ then
	-- 	self.Scrollbar.onValueChanged:RemoveListener(self.__event_scrollbar_onScrollbarValueChanged__)
	-- 	self.__event_scrollbar_onScrollbarValueChanged__ = nil
	-- end
end
local function GetNeedData(self)
	local UserDataType = require "Framework.UserDataType"
    local cardbagData = self:GetCachedData(UserDataType.CardBagData)
    local roleData=cardbagData:GetRoleById(self.cardID)
    local cardLevel = roleData:GetLv()
    local roleMgr = require "StaticData.Role"
	local data = roleMgr:GetData(self.cardID)
	local teamTalentBasisMgr = require "StaticData.Talent.TeamTalentBasis"
	local teamTalentBasisData=teamTalentBasisMgr:GetData(data:GetStar())
	return cardLevel,data,teamTalentBasisData
end 


function TalentCls:OnSkillIcon1ButtonClicked()
	local  cardLevel,data,teamTalentBasisData=GetNeedData(self)
    local  rank,level,needType,needNum = teamTalentBasisData:GetInfoByRank(0)
    --开启等级大于玩家等级
	if level>cardLevel then
		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"
		windowManager:Show(ConfirmDialogClass, level.."级开启")
	else
		debug_print("请求开启",data:GetTeamTalent()[0])
		self.game:SendNetworkMessage(require"Network.ServerService".CardTeamTalentChooseRequest(self.itemUID,data:GetTeamTalent()[0],0,0))
	end


end

function TalentCls:OnSkillIcon2ButtonClicked()

	local  cardLevel,data,teamTalentBasisData=GetNeedData(self)

    local  rank,level,needType,needNum = teamTalentBasisData:GetInfoByRank(1)
    --开启等级大于玩家等级
	if level>cardLevel then
		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"
		windowManager:Show(ConfirmDialogClass, level.."级开启")
	else
		debug_print("请求开启",data:GetTeamTalent()[1])
		self.game:SendNetworkMessage(require"Network.ServerService".CardTeamTalentChooseRequest(self.itemUID,0,data:GetTeamTalent()[1],0))
	end
end

function TalentCls:OnSkillIcon3ButtonClicked()
	local  cardLevel,data,teamTalentBasisData=GetNeedData(self)

    local  rank,level,needType,needNum = teamTalentBasisData:GetInfoByRank(2)
    --开启等级大于玩家等级
	if level>cardLevel then
		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"
		windowManager:Show(ConfirmDialogClass, level.."级开启")
	else
		debug_print("请求开启",data:GetTeamTalent()[2])
		self.game:SendNetworkMessage(require"Network.ServerService".CardTeamTalentChooseRequest(self.itemUID,0,0,data:GetTeamTalent()[2]))
	end

end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function TalentCls:OnTalentReturnButtonClicked()
	--TalentReturnButton控件的点击事件处理
	UnityEngine.Object.Destroy(self.baozha_effect)
	self:Close()
end
local function OnConfirmBuy(self)
  self.game:SendNetworkMessage(require"Network.ServerService".CardTalentResetRequest(self.itemUID))
end

local function OnCancelBuy(self)
  	 print("取消重置天赋")
end
function TalentCls:OnResetButtonClicked()

	local WorldBossData = require "StaticData.Boss.WorldBoss":GetData(1)
	local utility = require "Utils.Utility"
	utility.ShowBuyConfirmDialog("是否花费200钻石重置天赋？", self, OnConfirmBuy, OnCancelBuy)
	--ResetButton控件的点击事件处理
end

function TalentCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

function TalentCls:OnScrollbarValueChanged(value)
	--Scrollbar控件的点击事件处理
end
local function ShowTipDialog(str)
	local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, str)
end 

function TalentCls:OnRank1TalentButtonClicked()
	debug_print("OnRank1TalentButtonClicked")
	if self.rankTalent<1 then		
		ShowTipDialog("蓝色+8时解锁此天赋")
		return
	end
	print("OnRank1TalentButtonClicked")
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents=self.data:GetTalent()
	-- print(self.itemUID,talents[1]:get_Item(0))
	--ResetButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network.ServerService".CardTalentChooseRequest(self.itemUID,talents[1]:get_Item(0),0,0,0,0))
end
	
function TalentCls:OnRank2TalentButtonClicked()
	print("OnRank2TalentButtonClicked")
	if self.rankTalent<2 then
		ShowTipDialog("紫色时解锁此天赋")
		return
		
	end
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents=self.data:GetTalent()
	--ResetButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network.ServerService".CardTalentChooseRequest(self.itemUID,0,talents[2]:get_Item(0),0,0,0))
end

function TalentCls:OnRank3TalentButtonClicked()
	debug_print("OnRank3TalentButtonClicked")
	debug_print("OnRank3TalentButtonClicked")
	if self.rankTalent<3 then
	ShowTipDialog("紫色+2时解锁此天赋")
	return
		
	end
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents=self.data:GetTalent()
	--ResetButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network.ServerService".CardTalentChooseRequest(self.itemUID,0,0,talents[3]:get_Item(0),0,0))
end

function TalentCls:OnRank4Talent1ButtonClicked()
	debug_print("OnRank4Talent1ButtonClicked")
if self.rankTalent<4 then
	ShowTipDialog("紫色+4时解锁此天赋")
	return
	
	end
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents=self.data:GetTalent()
	--ResetButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network.ServerService".CardTalentChooseRequest(self.itemUID,0,0,0,talents[4]:get_Item(0),0))
end

function TalentCls:OnRank4Talent2ButtonClicked()
	debug_print("OnRank4Talent2ButtonClicked")
if self.rankTalent<4 then
		ShowTipDialog("紫色+4时解锁此天赋")
		return
	end
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents=self.data:GetTalent()
	--ResetButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network.ServerService".CardTalentChooseRequest(self.itemUID,0,0,0,talents[4]:get_Item(1),0))
end

function TalentCls:OnRank4Talent3ButtonClicked()
	debug_print("OnRank4Talent3ButtonClicked")
if self.rankTalent<4 then
		ShowTipDialog("紫色+4时解锁此天赋")
		return
	end
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents=self.data:GetTalent()
	--ResetButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network.ServerService".CardTalentChooseRequest(self.itemUID,0,0,0,talents[4]:get_Item(2),0))
end

function TalentCls:OnRank5Talent1ButtonClicked()
	debug_print("OnRank5Talent1ButtonClicked")
if self.rankTalent<5 then
	ShowTipDialog("紫色+6时解锁此天赋")
	return
	end
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents=self.data:GetTalent()
	--ResetButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network.ServerService".CardTalentChooseRequest(self.itemUID,0,0,0,0,talents[5]:get_Item(0)))
end

function TalentCls:OnRank5Talent2ButtonClicked()
	debug_print("OnRank5Talent2ButtonClicked")	
	if self.rankTalent<5 then
		ShowTipDialog("紫色+6时解锁此天赋")
		return
	end
	local roleMgr = require "StaticData.Role"
	self.data = roleMgr:GetData(self.cardID)
	local talents=self.data:GetTalent()
	--ResetButton控件的点击事件处理
	self.game:SendNetworkMessage(require"Network.ServerService".CardTalentChooseRequest(self.itemUID,0,0,0,0,talents[5]:get_Item(1)))
end


--监听网络事件
function TalentCls:RegisterNetworkEvents()
	 
    self.game:RegisterMsgHandler(net.S2CCardTalentChooseResult, self, self.CardTalentChooseResult)
    self.game:RegisterMsgHandler(net.S2CCardTalentResetResult, self, self.CardTalentResetResult)
    self.game:RegisterMsgHandler(net.S2CCardTeamTalentChooseResult, self, self.CardTeamTalentChooseResult)

end
--取消监听网络事件
function TalentCls:UnregisterNetworkEvents()
    self.game:UnRegisterMsgHandler(net.S2CCardTalentChooseResult, self, self.CardTalentChooseResult)
    self.game:UnRegisterMsgHandler(net.S2CCardTalentResetResult, self, self.CardTalentResetResult)
    self.game:UnRegisterMsgHandler(net.S2CCardTeamTalentChooseResult, self, self.CardTeamTalentChooseResult)

end
function TalentCls:CardTeamTalentChooseResult(msg)
	-- debug_print("msg ***********************",msg.cardUID,msg.teamTalentA,msg.teamTalentB,msg.teamTalentC)
	self:InitViews()
	self:InitNotice()
	self:InitTeamTalentInfo()
	local windowManager = utility:GetGame():GetWindowManager()
   	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
	windowManager:Show(ConfirmDialogClass, "团队天赋已激活")
	self.baozha_effect.transform:SetAsLastSibling()
	self.baozha_effect:SetActive(false)
	self.baozha_effect:SetActive(true)
end

function TalentCls:CardTalentChooseResult(msg)
	--print(self.heroData:GetStage(),self.heroData:GetTalentByStage(1),self.heroData:GetTalentByStage(2),self.heroData:GetTalentByStage(3),self.heroData:GetTalentByStage(4),self.heroData:GetTalentByStage(5))
	-- debug_print("*****************************",self.heroData:GetStage(),self.heroData:GetTalentByStage(1),self.heroData:GetTalentByStage(2),self.heroData:GetTalentByStage(3),self.heroData:GetTalentByStage(4),self.heroData:GetTalentByStage(5))
	self:InitViews()
	self:InitNotice()
	self:InitTalentInfo()
	local windowManager = utility:GetGame():GetWindowManager()
   	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
	windowManager:Show(ConfirmDialogClass, "天赋已激活")
	self.baozha_effect.transform:SetAsLastSibling()
	self.baozha_effect:SetActive(false)
	self.baozha_effect:SetActive(true)
	
	-- if msg.talent1==self.heroData:GetTalentByStage(1) then

	-- elseif msg.talent1==self.heroData:GetTalentByStage(2) then

	-- elseif msg.talent1==self.heroData:GetTalentByStage(3) then

	-- elseif msg.talent1==self.heroData:GetTalentByStage(4) then

	-- elseif msg.talent1==self.heroData:GetTalentByStage(5) then

	-- end


--	print("CardTalentChooseResult")
--	print(msg.cardUID,msg.talent1,msg.talent2,msg.talentA,msg.talentBID,msg.talentCID)


end

function TalentCls:CardTalentResetResult(msg)
	self:InitViews()
	self:InitNotice()
	self:InitTalentInfo()
end

function TalentCls:OnChangeTalentButtonClicked()
	self.clickNum=self.clickNum+1
	if self.clickNum%2==0 then
		self.personTalent.gameObject:SetActive(true)
		self.changeTalentButtonText.text="团队天赋"
		self.teamTalent.gameObject:SetActive(false)
		self.ResetButton.gameObject:SetActive(true)
		self.redDot.enabled =calculateRed.GetRoleTeamTalentRedDataByID(self.cardID)
		
	else
		self.personTalent.gameObject:SetActive(false)
		self.changeTalentButtonText.text="个人天赋"
		self.teamTalent.gameObject:SetActive(true)
		self.ResetButton.gameObject:SetActive(false)
		self.redDot.enabled =calculateRed.GetRoleTalentRedDataByID(self.cardID)
	end
end

return TalentCls

