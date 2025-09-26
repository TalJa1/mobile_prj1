# Complete 2D Paper-Doll Equipment and Inventory System

This is a comprehensive inventory and equipment system for Godot 4 that implements a paper-doll style character customization system.

## System Overview

### Architecture Components

1. **ItemDatabase.gd** (Autoload) - Global item definitions
2. **InventoryData.gd** (Autoload) - Player's inventory management  
3. **player_equipment_new.gd** - Visual layer and animation management
4. **InventoryUI.gd** - Inventory user interface
5. **InventorySlot.gd** - Individual slot UI components

### Scene Structure

```
Player Scene (player.tscn):
├── CharacterBody2D_Player (player.gd, group: "player")
├── Equipment (player_equipment_new.gd)  
├── AnimatedSprite2D_Body
├── AnimatedSprite2D_Cloths
├── AnimatedSprite2D_Hairs
└── AnimatedSprite2D_Weapons

Inventory UI (InventoryUI.tscn):
├── Control (InventoryUI.gd)
└── CanvasLayer
    └── Panel
        └── MarginContainer
            └── GridContainer (populated with InventorySlot instances)

Inventory Slot (InventorySlot.tscn):
├── Button (InventorySlot.gd)
└── TextureRect (item icon display)
```

## Setup Instructions

### 1. Autoload Configuration

Add these to your project.godot autoloads:
```
ItemDatabase="*res://autoloads/ItemDatabase.gd"
InventoryData="*res://autoloads/InventoryData.gd"
```

### 2. Player Scene Setup

1. Create a CharacterBody2D named "CharacterBody2D_Player"
2. Add the `player.gd` script to it
3. Add the player to group "player"
4. Add child nodes:
   - Equipment (Node with `player_equipment_new.gd`)
   - AnimatedSprite2D_Body
   - AnimatedSprite2D_Cloths  
   - AnimatedSprite2D_Hairs
   - AnimatedSprite2D_Weapons

### 3. Equipment Resources

Create SpriteFrames (.tres) resources for each equipment item with these animation names:
- `idle` - standing still
- `walk` - normal walking
- `run` - fast movement  
- `attack` - combat action
- `jumpUp` - jumping upward
- `jumpDown` - falling downward
- `die` - death animation

### 4. Item Icons

Create icon textures for inventory display and place them in `res://assets/icons/`

### 5. Input Map

Add an "inventory" action to your Input Map for toggling the inventory UI.

## Usage Examples

### Adding Items to Database

```gdscript
# In ItemDatabase.gd _initialize_items()
items_database["sword"] = {
    "type": ItemType.WEAPON,
    "name": "Iron Sword",
    "description": "A sturdy iron sword.",
    "icon_path": "res://assets/icons/sword_icon.png",
    "sprite_frames_path": "res://equipment/weapons/sword_sf.tres",
    "clothing_slot": -1,  # Not clothing
    "stackable": false,
    "max_stack": 1
}
```

### Giving Items to Player

```gdscript
# Add items to player inventory
InventoryData.add_item("blue_pants", 1)
InventoryData.add_item("health_potion", 5)
```

### Equipping Items

```gdscript
# Get player equipment service
var player = get_tree().get_first_node_in_group("player")
var equipment = player.get_node("Equipment")

# Equip an item
equipment.equip_item("blue_pants")

# Check what's equipped
var equipped_clothes = equipment.get_equipped_item("clothes")
```

### Opening Inventory UI

```gdscript
# Instantiate and add inventory UI to scene
var inventory_ui_scene = preload("res://ui/inventory/InventoryUI.tscn")
var inventory_ui = inventory_ui_scene.instantiate()
get_tree().current_scene.add_child(inventory_ui)
```

## How It Works

### Equipment System
1. Items are defined in ItemDatabase with sprite paths and metadata
2. Player starts with items in their InventoryData
3. Equipment service loads SpriteFrames and applies them to appropriate layers
4. All layers play synchronized animations using standard names
5. Animation conversion handles different naming conventions

### Inventory System  
1. InventoryData tracks what items the player owns
2. InventoryUI displays items in a grid of slots
3. Players can click items to equip or consume them
4. Drag and drop is supported for item management
5. Different item types have different behaviors when used

### Integration
- Player script connects to Equipment service for visual management
- Inventory UI connects to both systems for item interaction
- Autoloads provide global access to item data and inventory state
- Signals keep UI synchronized with inventory changes

## File Locations

```
/autoloads/
  ├── ItemDatabase.gd
  └── InventoryData.gd
/services/
  └── player_equipment_new.gd  
/ui/inventory/
  ├── InventoryUI.gd
  ├── InventoryUI.tscn
  ├── InventorySlot.gd
  └── InventorySlot.tscn
/scenes/player/bare/
  ├── player.gd
  ├── player.tscn
  └── [equipment sprite frames].tres
/examples/
  └── SystemDemo.gd
```

## Features

- ✅ Complete item database system
- ✅ Inventory management with stacking
- ✅ Paper-doll equipment visualization  
- ✅ Synchronized multi-layer animations
- ✅ Drag and drop inventory UI
- ✅ Consumable item system
- ✅ Equipment slot management
- ✅ Flexible item type system
- ✅ Automatic starting equipment
- ✅ UI integration with game systems

## Next Steps

1. Create your equipment SpriteFrames resources
2. Add item icons to the assets folder
3. Configure your player scene with the correct node structure
4. Add the inventory UI to your main game scene
5. Test the system using the provided demo script

The system is designed to be modular and extensible - you can easily add new item types, equipment slots, or UI features as needed for your game.