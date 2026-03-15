# Coin Odyssey

Roblox coin-collection game built with **Rojo**.

## Project Structure

- `default.project.json` - Rojo mapping file
- `src/ServerScriptService/CoinPickup.server.lua` - coin logic, spawning, and effects
- `src/ServerScriptService/Main.server.lua` - basic server startup script
- `src/StarterPlayer/StarterPlayerScripts/Client.client.lua` - basic client startup script

## Requirements

- Roblox Studio
- [Rojo](https://rojo.space/)

## Run With Rojo

From project root:

```bash
rojo serve
```

Then connect from Roblox Studio using the Rojo plugin.

## Build Place File

```bash
mkdir -p build
rojo build default.project.json --output "build/MyNewGame.rbxlx"
```

## Coin System

Put all coin parts in `Workspace/Coins`.

### Coin Types

- **Normal coin**: adds coins (default `+1`)
- **The Bad Coin**: removes coins (default `-1`, clamped at `0`)
- **Speed Coin**: adds coins and gives temporary movement speed boost
- **Diamoid Coin**: rare coin worth `+5` by default

### Common Coin Attributes

Set these attributes on a coin part to override defaults:

- `CoinValue` (Number)
- `RespawnTime` (Number)
- `PickupSoundId` (String)
- `PickupVolume` (Number)

### Speed Coin Attributes

- `SpeedBoostAmount` (Number)
- `SpeedBoostDuration` (Number)

### Folder Spawn Attributes (`Workspace/Coins`)

Normal coin spawner:
- `SpawnInterval`
- `SpawnRadius`
- `MaxCoins`

Bad coin spawner:
- `BadCoinSpawnInterval`
- `BadCoinSpawnRadius`
- `BadCoinMaxCoins`

Speed coin spawner:
- `SpeedCoinSpawnInterval`
- `SpeedCoinSpawnRadius`
- `SpeedCoinMaxCoins`

Diamoid coin spawner:
- `DiamoidCoinSpawnInterval`
- `DiamoidCoinSpawnRadius`
- `DiamoidCoinMaxCoins`

## Notes

- Keep at least one template part for each special coin type in `Workspace/Coins`:
  - `The Bad Coin`
  - `Speed Coin`
  - `Diamoid Coin`
- Spawners clone from these template parts.
