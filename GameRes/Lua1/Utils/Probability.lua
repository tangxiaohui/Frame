require "Class"

Probability = Class()

local RAND_MAX = 0x7fffffff

local function tointeger(number)
	if number >= 0 then
		return math.floor(number)
	else
		return math.ceil(number)
	end
end

local function rand_internal(seed)
	if seed == 0 then
		seed = 123459876
	end

	local hi = tointeger(seed / 127773)
	local lo = seed % 127773
	local x = 16807 * lo - 2836 * hi
	if x < 0 then
		x = x + 0x7fffffff
	end
	seed = x

	return (seed % (RAND_MAX + 1)), seed
end

local function rand(self)
	local res, newSeed = rand_internal(self.seed)
	self.seed = newSeed
	return res
end

function Probability:Ctor()
	self.seed = 1
end

function Probability:SetSeed(seed)
	self.seed = seed
end

function Probability:GetSeed()
	return self.seed
end

function Probability:Hit(integer)
	return self:Random(100 + 1) <= integer
end

-- Random是[) , RandomRange是[]

function Probability:Random(n)
	return rand(self) % n
end

function Probability:RandomRange(min, max)
	local s = math.min(min, max)
	local e = math.max(min, max)
	return s + self:Random(e - s + 1)
end

local probability = Probability.New()
return probability

