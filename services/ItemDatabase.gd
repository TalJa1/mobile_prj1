# ItemDatabase.gd
# This is an autoload singleton that manages item data for the Player_Equipment system

extends Node

# Dictionary to store all item data
# Structure: { "item_id": { "type": "clothes|hair|weapon", "path": "res://path/to/sprite_frames.tres", "name": "Item Name" } }
var items_database = {}

func _ready():
	# Initialize with some example items
	# You should populate this with your actual game items
	_load_default_items()

func _load_default_items():
	# Example items - replace with your actual item data
	# These should point to actual SpriteFrames resources you've created
	
	# Example clothes items
	items_database["basic_shirt"] = {
		"type": "clothes",
		"path": "res://assets/GandalfHardcore/GandalfHardcore 43x Female Clothing/basic_shirt.tres",
		"name": "Basic Shirt"
	}
	
	items_database["leather_armor"] = {
		"type": "clothes", 
		"path": "res://assets/GandalfHardcore/GandalfHardcore 43x Female Clothing/leather_armor.tres",
		"name": "Leather Armor"
	}
	
	# Example hair items
	items_database["short_hair"] = {
		"type": "hair",
		"path": "res://assets/GandalfHardcore/GandalfHardcore 58x Hair/short_hair.tres",
		"name": "Short Hair"
	}
	
	items_database["long_hair"] = {
		"type": "hair",
		"path": "res://assets/GandalfHardcore/GandalfHardcore 58x Hair/long_hair.tres", 
		"name": "Long Hair"
	}
	
	# Example weapon items
	items_database["sword"] = {
		"type": "weapon",
		"path": "res://assets/GandalfHardcore/GandalfHardcore 36x Hand Items/sword.tres",
		"name": "Basic Sword"
	}
	
	items_database["staff"] = {
		"type": "weapon",
		"path": "res://assets/GandalfHardcore/GandalfHardcore 36x Hand Items/staff.tres",
		"name": "Magic Staff"
	}

func get_item_data(item_id: String) -> Dictionary:
	"""Get item data by item ID"""
	if items_database.has(item_id):
		return items_database[item_id]
	else:
		print("Warning: Item not found in database: ", item_id)
		return {}

func add_item(item_id: String, item_data: Dictionary):
	"""Add a new item to the database"""
	items_database[item_id] = item_data

func get_items_by_type(item_type: String) -> Array:
	"""Get all items of a specific type (clothes, hair, weapon)"""
	var result = []
	for item_id in items_database.keys():
		if items_database[item_id].get("type", "") == item_type:
			result.append({
				"id": item_id,
				"data": items_database[item_id]
			})
	return result

func get_all_items() -> Dictionary:
	"""Get the entire items database"""
	return items_database