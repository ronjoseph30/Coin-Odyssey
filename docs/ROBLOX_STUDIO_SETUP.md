# Roblox Studio Setup

Use this guide after cloning the repository to get a playable local setup in Studio.

## 1) Connect Rojo

1. Start Rojo from repo root:

   ```bash
   rojo serve
   ```

2. Open Roblox Studio and your place.
3. Use the Rojo plugin to connect to the running server.

## 2) Create Required Workspace Objects

Create this folder hierarchy in Studio Explorer:

- `Workspace`
  - `Coins` (Folder)

The gameplay scripts expect this exact folder name: `Workspace/Coins`.

## 3) Add Coin Templates

Inside `Workspace/Coins`, add at least one `BasePart` template for each coin type below:

- Normal coin (any name except special names)
- `The Bad Coin`
- `Speed Coin`
- `Diamoid Coin`

Notes:
- Normal-coin spawner clones from a non-special coin template.
- Special spawners clone by exact coin type name.

## 4) Basic Part Requirements

For each coin template part:

- Must be a `BasePart` (`Part`, `MeshPart`, `Union`, etc.)
- Keep `CanTouch = true`
- Position coins where players can reach them
- Recommended for stable behavior: `Anchored = true`

## 5) Sound Behavior

- Do not manually add `Sound` objects for pickups.
- The server script creates/plays pickup sound at runtime.
- Default sound comes from `CoinPickup.server.lua`.
- Optional per-coin override attributes:
  - `PickupSoundId` (String)
  - `PickupVolume` (Number)

## 6) Optional Tuning Attributes

### Per Coin Part

- `CoinValue` (Number)
- `RespawnTime` (Number)

Speed-coin only:
- `SpeedBoostAmount` (Number)
- `SpeedBoostDuration` (Number)

### On `Workspace/Coins` Folder

Normal coins:
- `SpawnInterval`
- `SpawnRadius`
- `MaxCoins`

Bad coins:
- `BadCoinSpawnInterval`
- `BadCoinSpawnRadius`
- `BadCoinMaxCoins`

Speed coins:
- `SpeedCoinSpawnInterval`
- `SpeedCoinSpawnRadius`
- `SpeedCoinMaxCoins`

Diamoid coins:
- `DiamoidCoinSpawnInterval`
- `DiamoidCoinSpawnRadius`
- `DiamoidCoinMaxCoins`

## 7) Quick Verification

1. Press Play.
2. Confirm `leaderstats/Coins` appears for your player.
3. Touch normal coin -> coins increase.
4. Touch `The Bad Coin` -> coins decrease (not below 0).
5. Touch `Speed Coin` -> temporary speed boost.
6. Touch `Diamoid Coin` -> larger reward (default +5).

If a special coin does not spawn, verify its template part exists in `Workspace/Coins` with the correct name.
