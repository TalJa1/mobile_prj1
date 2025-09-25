extends Node

# Example usage of the integrated Player Equipment System
# This helper Node provides safe example functions that demonstrate
# how to interact with the player equipment system at runtime.

# Reference the ItemDatabase autoload (if present)
@onready var ItemDatabaseRef := get_node_or_null("/root/ItemDatabase")

func _ready() -> void:
	# Helper node: nothing to initialize by default
	pass


### 1) Equip multiple items on a given player node (null-safe)
func example_equip_item(player: Node = null) -> void:
	if player == null:
		player = get_node_or_null("Player")

	if not player:
		push_warning("Player node not found for example_equip_item; pass a reference instead")
		return

	if not player.has_method("equip_item"):
		push_warning("Provided player node does not implement equip_item()")
		return

	player.equip_item("leather_armor")
	player.equip_item("long_hair")
	player.equip_item("sword")


### 2) Print currently equipped items (null-safe)
func example_check_equipment(player: Node = null) -> void:
	if player == null:
		player = get_node_or_null("Player")

	if not player:
		push_warning("Player node not found for example_check_equipment; pass a reference instead")
		return

	if not player.has_method("get_equipped_items"):
		push_warning("Provided player node does not implement get_equipped_items()")
		return

	var equipped: Dictionary = player.get_equipped_items() as Dictionary
	print("Currently wearing:")
	print("  Clothes: ", equipped.get("clothes", "none"))
	print("  Hair:    ", equipped.get("hair", "none"))
	print("  Weapon:  ", equipped.get("weapon", "none"))


### 3) Example inventory-driven equip (null-safe)
func example_inventory_integration(player: Node = null, selected_item_id: String = "basic_shirt") -> void:
	if player == null:
		player = get_node_or_null("Player")

	if not player:
		push_warning("Player node not found for example_inventory_integration; pass a reference instead")
		return

	if player.has_method("is_equipment_service_available") and player.is_equipment_service_available():
		player.equip_item(selected_item_id)
		print("Equipped: ", selected_item_id)
	else:
		print("Equipment system not available or player does not expose the check")


### 4) Add a custom item to the ItemDatabase autoload (if present)
func example_add_custom_item() -> void:
	if not ItemDatabaseRef:
		push_warning("ItemDatabase autoload not found; add it as an autoload or call add_item on your own database instance")
		return

	ItemDatabaseRef.add_item("magic_robe", {
		"type": "clothes",
		"path": "res://assets/custom/magic_robe.tres",
		"name": "Magic Robe"
	})


### 5) List available items by type (null-safe)
func example_get_items_by_type(item_type: String = "weapon") -> void:
	if not ItemDatabaseRef:
		push_warning("ItemDatabase autoload not found; cannot query items")
		return

	var items: Array = ItemDatabaseRef.get_items_by_type(item_type) as Array
	print("Available ", item_type, " items:")
	for entry in items:
		var id: String = str(entry.get("id", ""))
		var data: Dictionary = entry.get("data", {}) as Dictionary
		var item_name: String = str(data.get("name", "<unnamed>"))
		print("- ", item_name, " (ID: ", id, ")")


# Notes:
# - Attach this script to any helper Node in your scene tree when you want
#   to run the example functions via the debugger or by calling them from other scripts.
# - All functions are defensive: they accept an optional player Node or look
#   for a node called "Player" as a convenience. Pass explicit references for
#   reliability in larger projects.