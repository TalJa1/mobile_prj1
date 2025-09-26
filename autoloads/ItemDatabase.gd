# ItemDatabase.gd
# Global autoload that defines all items in the game
extends Node

# Item types
enum ItemType {
	CLOTHES,
	HAIR,
	WEAPON,
	CONSUMABLE,
	MISC
}

# Equipment slots for clothes
enum ClothingSlot {
	TOP,
	BOTTOM,
	SHOES,
	OVERLAY,
	ACCESSORY
}

# Dictionary structure for each item:
# {
#   "type": ItemType,
#   "name": String,
#   "description": String,
#   "icon_path": String,
#   "sprite_frames_path": String (for equipment),
#   "clothing_slot": ClothingSlot (for clothes),
#   "stackable": bool,
#   "max_stack": int
# }
var items_database = {}

func _ready():
	_initialize_items()

func _initialize_items():
	# Clothes
	items_database["blue_pants"] = {
		"type": ItemType.CLOTHES,
		"name": "Blue Pants",
		"description": "Comfortable blue pants for everyday wear.",
		"icon_path": "res://assets/icons/blue_pants_icon.png",
		"sprite_frames_path": "res://scenes/player/bare/blue_pants_sf.tres",
		"clothing_slot": ClothingSlot.BOTTOM,
		"stackable": false,
		"max_stack": 1
	}
	
	items_database["blue_skirt"] = {
		"type": ItemType.CLOTHES,
		"name": "Blue Skirt",
		"description": "A stylish blue skirt.",
		"icon_path": "res://assets/icons/blue_skirt_icon.png",
		"sprite_frames_path": "res://scenes/player/bare/blue_skirt_sf.tres",
		"clothing_slot": ClothingSlot.OVERLAY,
		"stackable": false,
		"max_stack": 1
	}
	
	items_database["green_pants"] = {
		"type": ItemType.CLOTHES,
		"name": "Green Pants",
		"description": "Nature-inspired green pants.",
		"icon_path": "res://assets/icons/green_pants_icon.png",
		"sprite_frames_path": "res://scenes/player/bare/green_pants_sf.tres",
		"clothing_slot": ClothingSlot.BOTTOM,
		"stackable": false,
		"max_stack": 1
	}
	
	items_database["boots"] = {
		"type": ItemType.CLOTHES,
		"name": "Leather Boots",
		"description": "Sturdy leather boots for any terrain.",
		"icon_path": "res://assets/icons/boots_icon.png",
		"sprite_frames_path": "res://scenes/player/bare/boots_sf.tres",
		"clothing_slot": ClothingSlot.SHOES,
		"stackable": false,
		"max_stack": 1
	}
	
	# Add more items as needed...
	
	# Example consumable
	items_database["health_potion"] = {
		"type": ItemType.CONSUMABLE,
		"name": "Health Potion",
		"description": "Restores 50 HP when consumed.",
		"icon_path": "res://assets/icons/health_potion_icon.png",
		"sprite_frames_path": "",
		"clothing_slot": -1,
		"stackable": true,
		"max_stack": 10
	}

func get_item_data(item_id: String) -> Variant:
	"""Get item data by ID. Returns the item dictionary or null if not found."""
	if items_database.has(item_id):
		return items_database[item_id]
	else:
		print("Warning: Item not found in database: ", item_id)
		return null

func get_all_items() -> Dictionary:
	"""Get the entire items database."""
	return items_database

func get_items_by_type(item_type: ItemType) -> Array:
	"""Get all items of a specific type."""
	var result = []
	for item_id in items_database.keys():
		if items_database[item_id].get("type") == item_type:
			result.append({
				"id": item_id,
				"data": items_database[item_id]
			})
	return result

func get_items_by_clothing_slot(clothing_slot: ClothingSlot) -> Array:
	"""Get all clothing items for a specific slot."""
	var result = []
	for item_id in items_database.keys():
		var item_data = items_database[item_id]
		if item_data.get("type") == ItemType.CLOTHES and item_data.get("clothing_slot") == clothing_slot:
			result.append({
				"id": item_id,
				"data": item_data
			})
	return result