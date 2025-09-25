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

	# Player bare / default clothing resources (local to scenes/player/bare)
	items_database["blue_pants"] = {
		"type": "clothes",
		"path": "res://scenes/player/bare/blue_pants_sf.tres",
		"name": "Blue Pants"
	}

	items_database["blue_skirt"] = {
		"type": "clothes",
		"path": "res://scenes/player/bare/blue_skirt_sf.tres",
		"name": "Blue Skirt"
	}

	items_database["boots"] = {
		"type": "clothes",
		"path": "res://scenes/player/bare/boots_sf.tres",
		"name": "Boots"
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