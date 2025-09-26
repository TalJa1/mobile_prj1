# Example usage and testing script
# This file shows how to use the complete inventory and equipment system

extends Node

func _ready():
	print("=== Inventory & Equipment System Demo ===")
	
	# Wait a frame for autoloads to be ready
	await get_tree().process_frame
	
	demo_inventory_system()
	demo_equipment_system()

func demo_inventory_system():
	print("\n--- Inventory System Demo ---")
	
	# Get references to autoloads
	var inventory_data = get_node("/root/InventoryData")
	var item_database = get_node("/root/ItemDatabase")
	
	# Show starting inventory
	print("Starting inventory:")
	var items = inventory_data.get_all_items()
	for item_id in items.keys():
		var item_data = item_database.get_item_data(item_id)
		var item_name = item_data.get("name", item_id) if item_data else item_id
		print("  - ", item_name, " x", items[item_id])
	
	# Add some items
	print("\nAdding items...")
	inventory_data.add_item("health_potion", 3)
	inventory_data.add_item("blue_skirt", 1)
	
	# Try to use a consumable
	print("\nUsing health potion...")
	inventory_data.use_item("health_potion")
	
	print("Updated inventory:")
	items = inventory_data.get_all_items()
	for item_id in items.keys():
		var item_data = item_database.get_item_data(item_id)
		var item_name = item_data.get("name", item_id) if item_data else item_id
		print("  - ", item_name, " x", items[item_id])

func demo_equipment_system():
	print("\n--- Equipment System Demo ---")
	
	# Find the player
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("No player found! Make sure the player scene is loaded and in group 'player'")
		return
	
	var equipment_service = player.get_node("Equipment")
	if not equipment_service:
		print("No equipment service found! Make sure the player has an Equipment node.")
		return
	
	# Try to equip items
	print("Trying to equip blue pants...")
	var success = equipment_service.equip_item("blue_pants")
	print("Result: ", "Success" if success else "Failed")
	
	print("Trying to equip blue skirt...")
	success = equipment_service.equip_item("blue_skirt")
	print("Result: ", "Success" if success else "Failed")
	
	# Show equipped items
	print("Currently equipped:")
	var equipped = equipment_service.equipped_items
	for slot in equipped.keys():
		if equipped[slot]:
			print("  ", slot, ": ", equipped[slot])
		else:
			print("  ", slot, ": (empty)")

# Function to test the inventory UI
func open_inventory_ui():
	"""Helper function to open the inventory UI programmatically"""
	# You would need to instantiate and add the inventory UI scene to the tree
	var inventory_ui_scene = preload("res://ui/inventory/InventoryUI.tscn")
	var inventory_ui = inventory_ui_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", inventory_ui)
	inventory_ui.show_inventory()

# Function to demonstrate adding the inventory UI to a scene
func setup_inventory_ui_in_scene():
	"""Example of how to add inventory UI to your main scene"""
	print("\nTo add inventory UI to your game scene:")
	print("1. Load the InventoryUI.tscn scene")
	print("2. Add it as a child of your main scene")
	print("3. The UI will handle input (ESC or 'inventory' action) automatically")
	print("4. Players can click items to equip them or use consumables")