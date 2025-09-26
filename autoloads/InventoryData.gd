# InventoryData.gd
# Global autoload that manages the player's inventory
extends Node

# Dictionary structure: { "item_id": quantity }
var inventory_items = {}

# Signal emitted when inventory changes
signal inventory_changed(item_id: String, new_quantity: int)

func _ready():
	# Start with some test items
	_initialize_test_inventory()

func _initialize_test_inventory():
	# Give player some starting items
	add_item("blue_pants", 1)
	add_item("blue_skirt", 1)
	add_item("green_pants", 1)
	add_item("boots", 1)
	add_item("health_potion", 5)

func add_item(item_id: String, quantity: int = 1) -> bool:
	"""Add an item to the inventory. Returns true if successful."""
	var item_data = ItemDatabase.get_item_data(item_id)
	if item_data == null:
		print("Cannot add unknown item: ", item_id)
		return false
	
	var current_quantity = inventory_items.get(item_id, 0)
	
	# Check if item is stackable
	if item_data.get("stackable", false):
		var max_stack = item_data.get("max_stack", 1)
		var new_quantity = min(current_quantity + quantity, max_stack)
		inventory_items[item_id] = new_quantity
		inventory_changed.emit(item_id, new_quantity)
		return new_quantity > current_quantity
	else:
		# Non-stackable items: only add if we don't have it
		if current_quantity == 0:
			inventory_items[item_id] = 1
			inventory_changed.emit(item_id, 1)
			return true
		else:
			print("Cannot add non-stackable item that already exists: ", item_id)
			return false

func remove_item(item_id: String, quantity: int = 1) -> bool:
	"""Remove an item from the inventory. Returns true if successful."""
	if not inventory_items.has(item_id):
		print("Cannot remove item not in inventory: ", item_id)
		return false
	
	var current_quantity = inventory_items[item_id]
	var new_quantity = max(0, current_quantity - quantity)
	
	if new_quantity == 0:
		inventory_items.erase(item_id)
	else:
		inventory_items[item_id] = new_quantity
	
	inventory_changed.emit(item_id, new_quantity)
	return true

func has_item(item_id: String) -> bool:
	"""Check if the inventory contains an item."""
	return inventory_items.has(item_id) and inventory_items[item_id] > 0

func get_item_quantity(item_id: String) -> int:
	"""Get the quantity of a specific item."""
	return inventory_items.get(item_id, 0)

func get_all_items() -> Dictionary:
	"""Get all items in the inventory."""
	return inventory_items

func get_items_by_type(item_type: int) -> Array:
	"""Get all items of a specific type from inventory."""
	var result = []
	for item_id in inventory_items.keys():
		var item_data = ItemDatabase.get_item_data(item_id)
		if item_data != null and item_data.get("type") == item_type:
			result.append({
				"id": item_id,
				"quantity": inventory_items[item_id],
				"data": item_data
			})
	return result

func use_item(item_id: String) -> bool:
	"""Use/consume an item. Returns true if successful."""
	var item_data = ItemDatabase.get_item_data(item_id)
	if item_data == null or not has_item(item_id):
		return false
	
	match item_data.get("type"):
		ItemDatabase.ItemType.CONSUMABLE:
			# Handle consumable logic here
			_handle_consumable_use(item_id)
			remove_item(item_id, 1)
			return true
		ItemDatabase.ItemType.CLOTHES:
			# Equipment is handled by the equipment system
			return true
		_:
			print("Item type cannot be used: ", item_id)
			return false

func _handle_consumable_use(item_id: String):
	"""Handle the effects of using a consumable item."""
	match item_id:
		"health_potion":
			# Example: heal player
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("heal"):
				player.heal(50)
			print("Used health potion! +50 HP")
		_:
			print("No use effect defined for: ", item_id)