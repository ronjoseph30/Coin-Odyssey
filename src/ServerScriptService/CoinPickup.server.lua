local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local COIN_FOLDER_NAME = "Coins"
local DEFAULT_COIN_VALUE = 1
local DEFAULT_RESPAWN_TIME = 5
local DEFAULT_SPAWN_INTERVAL = 1
local DEFAULT_SPAWN_RADIUS = 30
local DEFAULT_MAX_COINS = 100

local coinStates = {}
local coinDefaults = {}
local randomGenerator = Random.new()
local coinSpawnerStarted = false

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
	coinsStat.Value = coinsStat.Value + coinValue

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

local function getFirstCoinTemplate(coinsFolder)
	for _, instance in ipairs(coinsFolder:GetChildren()) do
		if isCoinPart(instance) then
			return instance
		end
	end

	return nil
end

local function getCurrentCoinCount(coinsFolder)
	local count = 0
	for _, instance in ipairs(coinsFolder:GetChildren()) do
		if isCoinPart(instance) then
			count = count + 1
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

local function startCoinSpawner(coinsFolder)
	if coinSpawnerStarted then
		return
	end

	local templateCoin = getFirstCoinTemplate(coinsFolder)
	if not templateCoin then
		warn("[CoinPickup] No BasePart template coin found in Workspace.Coins.")
		return
	end

	coinSpawnerStarted = true

	task.spawn(function()
		while coinsFolder.Parent do
			local spawnInterval = getNumberAttribute(coinsFolder, "SpawnInterval", DEFAULT_SPAWN_INTERVAL)
			if spawnInterval <= 0 then
				spawnInterval = DEFAULT_SPAWN_INTERVAL
			end

			task.wait(spawnInterval)

			local hasTemplate = true

			if not templateCoin.Parent then
				templateCoin = getFirstCoinTemplate(coinsFolder)
				if not templateCoin then
					hasTemplate = false
				end
			end

			if hasTemplate then
				local maxCoins = getNumberAttribute(coinsFolder, "MaxCoins", DEFAULT_MAX_COINS)
				if getCurrentCoinCount(coinsFolder) < maxCoins then
					local spawnRadius = getNumberAttribute(coinsFolder, "SpawnRadius", DEFAULT_SPAWN_RADIUS)
					if spawnRadius < 0 then
						spawnRadius = DEFAULT_SPAWN_RADIUS
					end

					local clone = templateCoin:Clone()
					local randomPosition = getRandomCoinPosition(templateCoin, spawnRadius)
					local rotation = templateCoin.CFrame - templateCoin.Position
					clone.CFrame = CFrame.new(randomPosition) * rotation
					clone.Parent = coinsFolder
				end
			end
		end

		coinSpawnerStarted = false
	end)
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

	startCoinSpawner(coinsFolder)
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
