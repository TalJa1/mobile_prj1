# Simple test script to debug equipment issues
extends Node

func _ready():
	print("=== Equipment Debug Test ===")
	
	# Wait for autoloads to be ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	test_equipment_system()

func test_equipment_system():
	print("\n--- Testing Equipment System ---")
	
	# Find player
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("ERROR: No player found in group 'player'")
		return
	
	print("Player found: ", player)
	
	# Find equipment service
	var equipment = player.get_node_or_null("Node2D_Equipment")
	if not equipment:
		print("ERROR: No equipment service found")
		return
	
	print("Equipment service found: ", equipment)
	
	# Check inventory
	var inventory = get_node("/root/InventoryData")
	if inventory:
		print("Inventory items:", inventory.get_all_items())
	else:
		print("ERROR: No inventory found")
	
	# Try manual equip
	print("Trying to manually equip blue_pants...")
	var result = equipment.equip_item("blue_pants")
	print("Manual equip result: ", result)
	
	await get_tree().create_timer(1.0).timeout
	
	print("Trying to manually equip boots...")  
	result = equipment.equip_item("boots")
	print("Manual equip result: ", result)