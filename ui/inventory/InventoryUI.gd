# InventoryUI.gd
# Main inventory UI controller
extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var panel: Panel = $CanvasLayer/Panel
@onready var margin_container: MarginContainer = $CanvasLayer/Panel/MarginContainer
@onready var grid_container: GridContainer = $CanvasLayer/Panel/MarginContainer/GridContainer

# Preload the slot scene
const INVENTORY_SLOT_SCENE = preload("res://ui/inventory/InventorySlot.tscn")

# Settings
@export var grid_columns: int = 8
@export var grid_rows: int = 6
@export var slot_size: Vector2 = Vector2(64, 64)

# Inventory slots array
var inventory_slots: Array = []

# Signals
signal item_selected(item_id: String)
signal item_equipped(item_id: String)

func _ready():
	# Set up the grid
	grid_container.columns = grid_columns
	
	# Create inventory slots
	create_inventory_slots()
	
	# Connect to inventory data changes
	get_node("/root/InventoryData").inventory_changed.connect(_on_inventory_changed)
	
	# Populate with current inventory
	refresh_inventory()
	
	# Initially hide the inventory
	hide_inventory()

func _input(event):
	"""Handle input for opening/closing inventory."""
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		if visible:
			hide_inventory()
		else:
			show_inventory()

func create_inventory_slots():
	"""Create all inventory slot UI elements."""
	var total_slots = grid_columns * grid_rows
	
	for i in range(total_slots):
		var slot_instance = INVENTORY_SLOT_SCENE.instantiate()
		grid_container.add_child(slot_instance)
		inventory_slots.append(slot_instance)
		
		# Connect slot signals
		slot_instance.slot_clicked.connect(_on_slot_clicked)
		slot_instance.slot_right_clicked.connect(_on_slot_right_clicked)
		
		# Set slot size
		slot_instance.custom_minimum_size = slot_size

func refresh_inventory():
	"""Refresh all inventory slots with current inventory data."""
	# Clear all slots first
	for slot in inventory_slots:
		slot.clear_slot()
	
	# Get all inventory items
	var inventory_items = get_node("/root/InventoryData").get_all_items()
	var slot_index = 0
	
	# Fill slots with items
	for item_id in inventory_items.keys():
		if slot_index >= inventory_slots.size():
			break  # No more slots available
		
		var quantity = inventory_items[item_id]
		if quantity > 0:
			inventory_slots[slot_index].setup_slot(item_id, quantity)
			slot_index += 1

func show_inventory():
	"""Show the inventory UI."""
	visible = true
	refresh_inventory()

func hide_inventory():
	"""Hide the inventory UI."""
	visible = false

func toggle_inventory():
	"""Toggle inventory visibility."""
	if visible:
		hide_inventory()
	else:
		show_inventory()

func _on_slot_clicked(slot):
	"""Handle left click on a slot."""
	if slot.is_empty():
		return
	
	var item_id = slot.item_id
	var item_data = ItemDatabase.get_item_data(item_id)
	
	if item_data == null:
		return
	
	item_selected.emit(item_id)
	
	# Handle different item types
	match item_data.get("type"):
		ItemDatabase.ItemType.CLOTHES:
			equip_item(item_id)
		ItemDatabase.ItemType.CONSUMABLE:
			use_consumable(item_id)
		_:
			print("Item type not handled: ", item_id)

func _on_slot_right_clicked(slot):
	"""Handle right click on a slot."""
	if slot.is_empty():
		return
	
	var item_id = slot.item_id
	var item_data = ItemDatabase.get_item_data(item_id)
	
	if item_data == null:
		return
	
	# Show context menu or item details
	print("Right clicked on: ", item_data.get("name", item_id))
	print("Description: ", item_data.get("description", "No description"))

func equip_item(item_id: String):
	"""Attempt to equip an item."""
	# Get the player's equipment manager
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("No player found!")
		return
	
	var equipment_manager = player.get_node("Equipment")
	if not equipment_manager:
		print("No equipment manager found!")
		return
	
	# Try to equip the item
	if equipment_manager.equip_item(item_id):
		item_equipped.emit(item_id)
		print("Successfully equipped: ", item_id)
	else:
		print("Failed to equip: ", item_id)

func use_consumable(item_id: String):
	"""Use a consumable item."""
	if get_node("/root/InventoryData").use_item(item_id):
		print("Used item: ", item_id)
		refresh_inventory()
	else:
		print("Failed to use item: ", item_id)

func _on_inventory_changed(item_id: String, new_quantity: int):
	"""Handle inventory changes."""
	print("Inventory changed: ", item_id, " -> ", new_quantity)
	refresh_inventory()

# Utility functions for external use
func add_item_to_inventory(item_id: String, quantity: int = 1):
	"""Add an item to the inventory (wrapper for InventoryData)."""
	get_node("/root/InventoryData").add_item(item_id, quantity)

func remove_item_from_inventory(item_id: String, quantity: int = 1):
	"""Remove an item from the inventory (wrapper for InventoryData)."""
	get_node("/root/InventoryData").remove_item(item_id, quantity)

func get_selected_item() -> String:
	"""Get the currently selected item (if any)."""
	# This would need to be implemented based on UI selection state
	return ""

# Filter and sorting functions
func filter_by_type(item_type: int):
	"""Filter inventory display by item type."""
	# Clear all slots
	for slot in inventory_slots:
		slot.clear_slot()
	
	# Get filtered items
	var filtered_items = get_node("/root/InventoryData").get_items_by_type(item_type)
	var slot_index = 0
	
	# Fill slots with filtered items
	for item in filtered_items:
		if slot_index >= inventory_slots.size():
			break
		
		inventory_slots[slot_index].setup_slot(item["id"], item["quantity"])
		slot_index += 1

func sort_inventory():
	"""Sort inventory items (by name, type, etc.)."""
	# This would implement sorting logic
	refresh_inventory()