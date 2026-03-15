local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local COIN_FOLDER_NAME = "Coins"
local BAD_COIN_NAME = "The Bad Coin"
local DEFAULT_COIN_VALUE = 1
local DEFAULT_RESPAWN_TIME = 5
local DEFAULT_SPAWN_INTERVAL = 1
local DEFAULT_SPAWN_RADIUS = 30
local DEFAULT_MAX_COINS = 100
local DEFAULT_BAD_SPAWN_INTERVAL = 1
local DEFAULT_BAD_SPAWN_RADIUS = 30
local DEFAULT_BAD_MAX_COINS = 100
local DEFAULT_PICKUP_SOUND_ID = "rbxassetid://135303694517645"
local DEFAULT_PICKUP_VOLUME = 0.8

local coinStates = {}
local coinDefaults = {}
local randomGenerator = Random.new()
local coinSpawnerStarted = {}

local function getNumberAttribute(instance, attributeName, fallback)
	local value = instance:GetAttribute(attributeName)
	if type(value) == "number" then
		return value
	end

	if value ~= nil then
		warn(string.format("[CoinPickup] %s.%s must be a number. Using %s.", instance.Name, attributeName, tostring(fallback)))
	end

	return fallback
end

local function getStringAttribute(instance, attributeName, fallback)
	local value = instance:GetAttribute(attributeName)
	if type(value) == "string" and value ~= "" then
		return value
	end

	if value ~= nil and type(value) ~= "string" then
		warn(string.format("[CoinPickup] %s.%s must be a string. Using %s.", instance.Name, attributeName, fallback))
	end

	return fallback
end

local function playPickupSound(coin)
	local soundId = getStringAttribute(coin, "PickupSoundId", DEFAULT_PICKUP_SOUND_ID)
	if soundId == "" then
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "CoinPickupSound"
	sound.SoundId = soundId
	sound.Volume = getNumberAttribute(coin, "PickupVolume", DEFAULT_PICKUP_VOLUME)
	sound.RollOffMaxDistance = 40
	sound.RollOffMinDistance = 6
	sound.Parent = coin
	sound:Play()

	Debris:AddItem(sound, 3)
end

local function getCoinsStat(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then
		coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = 0
		coins.Parent = leaderstats
	end

	return coins
end

local function getPlayerFromHit(hit)
	if not hit or not hit.Parent then
		return nil
	end

	local character = hit.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

local function hideCoin(coin)
	local defaults = coinDefaults[coin]
	if defaults then
		coin.CFrame = defaults.cframe
	end

	coin.AssemblyLinearVelocity = Vector3.zero
	coin.AssemblyAngularVelocity = Vector3.zero
	coin.Anchored = true
	coin.CanTouch = false
	coin.CanCollide = false
	coin.Transparency = 1
end

local function showCoin(coin)
	local defaults = coinDefaults[coin]
	if defaults then
		coin.CFrame = defaults.cframe
		coin.AssemblyLinearVelocity = Vector3.zero
		coin.AssemblyAngularVelocity = Vector3.zero
		coin.Anchored = defaults.anchored
		coin.CanTouch = defaults.canTouch
		coin.CanCollide = defaults.canCollide
		coin.Transparency = defaults.transparency
		return
	end

	coin.CanTouch = true
	coin.CanCollide = true
	coin.Transparency = 0
end

local function onCoinTouched(coin, hit)
	if coinStates[coin] then
		return
	end

	local player = getPlayerFromHit(hit)
	if not player then
		return
	end

	coinStates[coin] = true

	local coinsStat = getCoinsStat(player)
	local coinValue = getNumberAttribute(coin, "CoinValue", DEFAULT_COIN_VALUE)
	local isBadCoin = coin.Name == BAD_COIN_NAME
	if isBadCoin then
		coinsStat.Value = math.max(0, coinsStat.Value - coinValue)
	else
		coinsStat.Value = coinsStat.Value + coinValue
	end

	playPickupSound(coin)

	hideCoin(coin)

	local respawnTime = getNumberAttribute(coin, "RespawnTime", DEFAULT_RESPAWN_TIME)
	if respawnTime < 0 then
		respawnTime = DEFAULT_RESPAWN_TIME
	end

	task.delay(respawnTime, function()
		if not coin.Parent then
			coinStates[coin] = nil
			return
		end

		showCoin(coin)
		coinStates[coin] = nil
	end)
end

local function setupCoin(coin)
	if coinStates[coin] ~= nil then
		return
	end

	coinStates[coin] = false
	coinDefaults[coin] = {
		cframe = coin.CFrame,
		anchored = coin.Anchored,
		canTouch = coin.CanTouch,
		canCollide = coin.CanCollide,
		transparency = coin.Transparency,
	}
	showCoin(coin)

	coin.Touched:Connect(function(hit)
		onCoinTouched(coin, hit)
	end)

	coin.AncestryChanged:Connect(function(_, parent)
		if parent ~= nil then
			return
		end

		coinStates[coin] = nil
		coinDefaults[coin] = nil
	end)
end

local function isCoinPart(instance)
	return instance:IsA("BasePart")
end

local function getFirstCoinTemplate(coinsFolder, templateName)
	for _, instance in ipairs(coinsFolder:GetChildren()) do
		if isCoinPart(instance) then
			if templateName then
				if instance.Name == templateName then
					return instance
				end
			elseif instance.Name ~= BAD_COIN_NAME then
				return instance
			end
		end
	end

	return nil
end

local function getCurrentCoinCount(coinsFolder, templateName)
	local count = 0
	for _, instance in ipairs(coinsFolder:GetChildren()) do
		if isCoinPart(instance) then
			if templateName then
				if instance.Name == templateName then
					count = count + 1
				end
			elseif instance.Name ~= BAD_COIN_NAME then
				count = count + 1
			end
		end
	end

	return count
end

local function getRandomCoinPosition(templateCoin, spawnRadius)
	local angle = randomGenerator:NextNumber(0, math.pi * 2)
	local distance = randomGenerator:NextNumber(0, spawnRadius)
	local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)

	return templateCoin.Position + offset
end

local function startCoinSpawner(
	coinsFolder,
	spawnerKey,
	templateName,
	intervalAttribute,
	radiusAttribute,
	maxCountAttribute,
	defaultInterval,
	defaultRadius,
	defaultMaxCount
)
	if coinSpawnerStarted[spawnerKey] then
		return
	end

	local templateCoin = getFirstCoinTemplate(coinsFolder, templateName)
	if not templateCoin then
		if templateName then
			warn(string.format("[CoinPickup] Template coin '%s' not found in Workspace.Coins.", templateName))
		else
			warn("[CoinPickup] No normal coin template found in Workspace.Coins.")
		end
		return
	end

	coinSpawnerStarted[spawnerKey] = true

	task.spawn(function()
		while coinsFolder.Parent do
			local spawnInterval = getNumberAttribute(coinsFolder, intervalAttribute, defaultInterval)
			if spawnInterval <= 0 then
				spawnInterval = defaultInterval
			end

			task.wait(spawnInterval)

			local hasTemplate = true

			if not templateCoin.Parent then
				templateCoin = getFirstCoinTemplate(coinsFolder, templateName)
				if not templateCoin then
					hasTemplate = false
				end
			end

			if hasTemplate then
				local maxCoins = getNumberAttribute(coinsFolder, maxCountAttribute, defaultMaxCount)
				if getCurrentCoinCount(coinsFolder, templateName) < maxCoins then
					local spawnRadius = getNumberAttribute(coinsFolder, radiusAttribute, defaultRadius)
					if spawnRadius < 0 then
						spawnRadius = defaultRadius
					end

					local clone = templateCoin:Clone()
					local randomPosition = getRandomCoinPosition(templateCoin, spawnRadius)
					local rotation = templateCoin.CFrame - templateCoin.Position
					clone.CFrame = CFrame.new(randomPosition) * rotation
					clone.Parent = coinsFolder
				end
			end
		end

		coinSpawnerStarted[spawnerKey] = false
	end)
end

local function startAllCoinSpawners(coinsFolder)
	startCoinSpawner(
		coinsFolder,
		"normal",
		nil,
		"SpawnInterval",
		"SpawnRadius",
		"MaxCoins",
		DEFAULT_SPAWN_INTERVAL,
		DEFAULT_SPAWN_RADIUS,
		DEFAULT_MAX_COINS
	)

	startCoinSpawner(
		coinsFolder,
		"bad",
		BAD_COIN_NAME,
		"BadCoinSpawnInterval",
		"BadCoinSpawnRadius",
		"BadCoinMaxCoins",
		DEFAULT_BAD_SPAWN_INTERVAL,
		DEFAULT_BAD_SPAWN_RADIUS,
		DEFAULT_BAD_MAX_COINS
	)
end

local function setupCoinsInFolder(coinsFolder)
	for _, instance in ipairs(coinsFolder:GetDescendants()) do
		if isCoinPart(instance) then
			setupCoin(instance)
		end
	end

	coinsFolder.DescendantAdded:Connect(function(instance)
		if isCoinPart(instance) then
			setupCoin(instance)
		end
	end)

	startAllCoinSpawners(coinsFolder)
end

Players.PlayerAdded:Connect(function(player)
	getCoinsStat(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	getCoinsStat(player)
end

local coinsFolder = Workspace:FindFirstChild(COIN_FOLDER_NAME)
if coinsFolder then
	setupCoinsInFolder(coinsFolder)
else
	warn("[CoinPickup] Workspace.Coins folder not found. Add BasePart coins under Workspace/Coins.")
	Workspace.ChildAdded:Connect(function(child)
		if child.Name == COIN_FOLDER_NAME then
			setupCoinsInFolder(child)
		end
	end)
end
