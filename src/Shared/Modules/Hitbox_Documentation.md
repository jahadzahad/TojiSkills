# Hitbox.lua Documentation

## Overview

`Hitbox.lua` provides a flexible hitbox system for Roblox games, allowing you to create, move, and manage hitboxes for combat and interaction mechanics. It supports box-shaped hitboxes, custom filtering, visualization, and advanced interaction logic (blocking, parrying, evading, ragdoll, etc.).

## Usage

### Requiring the Module

```lua
local HitboxModule = require(path.to.Hitbox)
```

### Creating a Hitbox

Use `HitboxModule:createHitbox(data, onHit)` to create a hitbox.

#### Parameters

- `data` (table): Configuration for the hitbox.
  - `Caster`: The character/model casting the hitbox (**required**).
  - `Size`: `Vector3` size of the hitbox (default: `Vector3.new(5, 5, 5)`).
  - `Offset`: `CFrame` offset from the caster's root part (default: `CFrame.new(0, 0, 0)`).
  - `HitboxType`: `"Box"` (default).
  - `IgnoresBlock`, `IgnoresRagdoll`, `IgnoresIFrames`, `IgnoresParry`: Boolean flags to ignore certain states.
  - `BlockBreak`: Boolean, triggers block break logic.
  - `HitType`: `"OneHit"`, `"Tick"`, or `"SingleTarget"` (default: `"OneHit"`).
  - `TickInterval`: Time between hits for `"Tick"` type (default: `0.5`).
  - `DDamage`: Damage to apply to destructible objects.
  - `Debris`: Time before hitbox is destroyed.
  - `FilterList`: List of instances to include in hitbox checks.
  - `DelayTime`: Delay before hitbox starts.
  - `Visualize`: Boolean, enables hitbox visualization.

- `onHit` (function): Callback called when a character is hit.
  - Arguments: `(character, wcsCharacter)`

#### Example

```lua
local hitbox = HitboxModule:createHitbox({
    Caster = myCharacter,
    Size = Vector3.new(10, 5, 10),
    Offset = CFrame.new(0, 0, 5),
    HitType = "OneHit",
    Visualize = true,
}, function(character, wcsCharacter)
    print("Hit:", character.Name)
    -- Apply damage or effects here
end)
```

### Moving a Hitbox

Use `hitbox:Move(targetCFrame, duration, easingStyle, easingDirection, onComplete)` to animate the hitbox's position.

- `targetCFrame`: Target offset (relative to root part).
- `duration`: Time to move (seconds).
- `easingStyle`, `easingDirection`: Animation style (see Roblox Tween docs).
- `onComplete`: Callback when movement finishes.

### Stopping and Resetting Movement

- `hitbox:StopMove()`: Stops movement.
- `hitbox:ResetPosition()`: Resets to base offset.

### Destroying a Hitbox

- `hitbox:Destroy()`: Cleans up the hitbox, disconnects events, removes visualization.

### Automatic Destruction

- `hitbox:AddFor(length)`: Destroys the hitbox after `length` seconds.

## Hit Detection Logic

- Ignores caster and non-humanoid models.
- Handles blocking, parrying, evading, ragdoll, and destructible objects.
- Supports single hit, tick-based, and single target hit types.

## Visualization

If `Visualize` is true or workspace debugging is enabled, a semi-transparent part is created to show the hitbox.

## Notes

- Designed for use with WCS character system and custom combat modules.
- Extend or modify `shouldHit` logic for custom game rules.

---
