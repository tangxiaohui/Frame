--
-- User: fbmly
-- Date: 4/18/17
-- Time: 1:45 PM
--

local utility = require "Utils.Utility"

local Resources = UnityEngine.Resources

require "Class"

local Atlases = Class()

function Atlases:Ctor(assets)
    self.sprites = {}

    local length = assets.Length
    for i = 0, length - 1 do
        self.sprites[assets[i].name] = assets[i]
    end
end

function Atlases:Get(name)
    return self.sprites[name]
end

local AtlasesLoader = Class()

function AtlasesLoader:Ctor()
    self.loadedAtlases = {}
end

local function GetAtlas(self, atlasName)
    return self.loadedAtlases[atlasName]
end

local function LoadAtlasImpl(self, atlasPath, atlasName)
    -- 检查是否已经加载过 --
    if self.loadedAtlases[atlasName] ~= nil then
        return self.loadedAtlases[atlasName]
    end

    
    
    local assets = _G.AssetManager.LoadAllAssets(atlasPath .. ".png", typeof(UnityEngine.Sprite))

    if assets == nil or assets.Length == 0 then
        return nil
    end

    -- 加载图集
    local newAtlas = Atlases.New(assets)
    self.loadedAtlases[atlasName] = newAtlas
    return newAtlas
end

function AtlasesLoader:UnloadUnusedAtlases()
    -- TODO 未实现
end

function AtlasesLoader:LoadAtlasSprite(spritePath)
    --debug_print(spritePath)
    if type(spritePath) ~= "string" or string.len(spritePath) == 0 then
        error("spritePath 必须是有效的字符串!")
    end

    local names = utility.Split(spritePath, '/')

    local len = #names
	if len <= 1 then
		names = utility.Split(spritePath, '\\')
		len = #names
	end

    if len <= 1 then
        error("路径不对, 应该是 全路径/图集名/精灵名")
    end

    local atlasName = names[len - 1]

    local atlas = GetAtlas(self, atlasName)

    -- 不存在就加载 --
    if atlas == nil then
        local atlasPath = table.concat(names, "/", 1, len - 1)
--        print(atlasPath, atlasName)
        atlas = LoadAtlasImpl(self, atlasPath, atlasPath)
        if atlas == nil then
            error(string.format("图集加载失败, 路径: %s", atlasPath))
        end
    end

    -- 取得精灵的名字
    local spriteName = names[len]

--    print(spriteName)
    return atlas:Get(spriteName)
end

function AtlasesLoader:PreloadAtlas(atlasPath)
    if type(atlasPath) ~= "string" or string.len(atlasPath) == 0 then
        error("atlasPath必须是有效的字符串!")
    end

    local names = utility.Split(atlasPath, '/')

    local atlasName = names[#names]

    local atlas = LoadAtlasImpl(self, atlasPath, atlasName)
    if atlas == nil then
        error(string.format("图集加载失败, 路径: %s", atlasPath))
    end

    return atlas
end

return AtlasesLoader.New()
