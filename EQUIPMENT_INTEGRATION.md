# Player Equipment System Integration

This document explains how the Player script integrates with the Player_Equipment service to manage character appearance (clothes, hair, weapons, etc.).

## How It Works

### 1. **Multi-Layer Sprite System**
Instead of using a single `AnimatedSprite2D`, the system uses multiple sprite layers:
- `AnimatedSprite2D_Body` - Base character body
- `AnimatedSprite2D_Cloths` - Clothing layer
- `AnimatedSprite2D_Hairs` - Hair/hairstyle layer  
- `AnimatedSprite2D_Weapons` - Weapon layer

### 2. **Automatic Synchronization**
The player script automatically:
- Plays the same animation on all equipped layers
- Flips all sprites together when changing direction
- Falls back to single sprite mode if equipment service is unavailable

### 3. **Equipment Management**
- Items are defined in `ItemDatabase.gd` (autoload singleton)
- `Player_Equipment.gd` handles equipping/switching items
- Player script provides convenient functions to change equipment

## Scene Structure

```
Player (CharacterBody2D) - player.gd script
├── CollisionShape2D
├── Player_Equipment (Node) - player_equipment.gd script  
├── AnimatedSprite2D_Body
├── AnimatedSprite2D_Cloths
├── AnimatedSprite2D_Hairs
└── AnimatedSprite2D_Weapons
```

## Usage Examples

### Change Equipment During Gameplay
```gdscript
# Get player reference
var player = $Player

# Equip different items
player.equip_item("leather_armor")  # Change clothes
player.equip_item("long_hair")      # Change hair
player.equip_item("sword")          # Equip weapon
```

### Check Current Equipment
```gdscript
var equipped = player.get_equipped_items()
print("Wearing: ", equipped["clothes"])
print("Hair: ", equipped["hair"]) 
print("Weapon: ", equipped["weapon"])
```

### Add Custom Items
```gdscript
ItemDatabase.add_item("magic_staff", {
    "type": "weapon",
    "path": "res://assets/weapons/magic_staff.tres",
    "name": "Magic Staff"
})
```

## Setting Up SpriteFrames

For each equipment piece:

1. Create a new `SpriteFrames` resource in Godot
2. Add animations matching player animations:
   - `idle`, `walk`, `run`, `jump_up`, `jump_down`, `attack`
3. Import sprite sheets and assign frames
4. Save as `.tres` files 
5. Update `ItemDatabase.gd` with correct paths

## Key Features

✅ **Backwards Compatible** - Falls back to single sprite if equipment service unavailable  
✅ **Automatic Animation Sync** - All layers play the same animation together  
✅ **Flexible Equipment Types** - Supports clothes, hair, weapons, and custom types  
✅ **Runtime Equipment Changes** - Switch items during gameplay  
✅ **Database-Driven** - Easy to add new items via ItemDatabase  

## Integration Benefits

- **Layered Character Customization** - Mix and match different equipment pieces
- **Performance Efficient** - Only equipped items are loaded and animated
- **Easy to Extend** - Add new equipment types by updating the database
- **Visual Consistency** - All layers stay synchronized during animations
- **Modular Design** - Equipment system is separate from core player logic

The player script now seamlessly manages both movement/combat and visual appearance through the integrated equipment system!