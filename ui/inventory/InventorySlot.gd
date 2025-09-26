# InventorySlot.gd
# Script for a single inventory slot UI element
extends Button

@onready var icon_texture_rect: TextureRect = get_node_or_null("TextureRect")
@onready var quantity_label: Label = get_node_or_null("QuantityLabel")  # Will be added if needed

var item_id: String = ""
var quantity: int = 0

# Signals
signal slot_clicked(slot)
signal slot_right_clicked(slot)

func _ready():
	# Connect button signals
	pressed.connect(_on_button_pressed)
	gui_input.connect(_on_gui_input)
	
	# Create quantity label if it doesn't exist
	if not has_node("QuantityLabel"):
		quantity_label = Label.new()
		quantity_label.name = "QuantityLabel"
		quantity_label.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		quantity_label.anchors_preset = Control.PRESET_BOTTOM_RIGHT
		quantity_label.offset_left = -20
		quantity_label.offset_top = -20
		quantity_label.size = Vector2(18, 18)
		call_deferred("add_child", quantity_label)
	else:
		quantity_label = $QuantityLabel

func setup_slot(new_item_id: String, new_quantity: int = 1):
	"""Set up the slot with item data."""
	item_id = new_item_id
	quantity = new_quantity
	
	if item_id == "":
		clear_slot()
		return
	
	var item_data = ItemDatabase.get_item_data(item_id)
	if item_data == null:
		clear_slot()
		return
	
	# Set icon (guard if node missing)
	var icon_path = item_data.get("icon_path", "")
	if icon_texture_rect:
		if icon_path != "" and ResourceLoader.exists(icon_path):
			icon_texture_rect.texture = load(icon_path)
		else:
			# intentionally set to null if no icon found
			icon_texture_rect.texture = null
	else:
		push_warning("InventorySlot: icon TextureRect not found for slot; cannot set texture.")

	# Set quantity text (guard if label missing)
	if not quantity_label:
		quantity_label = get_node_or_null("QuantityLabel")

	if quantity_label:
		if quantity > 1:
			quantity_label.text = str(quantity)
			quantity_label.visible = true
		else:
			quantity_label.visible = false
	else:
		# Not fatal — slot can function without a quantity label
		if quantity > 1:
			push_warning("InventorySlot: QuantityLabel missing but quantity > 1 for item %s" % item_id)
	
	# Set tooltip
	var item_name = item_data.get("name", item_id)
	var item_description = item_data.get("description", "")
	tooltip_text = item_name + "\n" + item_description

func clear_slot():
	"""Clear the slot of any item."""
	item_id = ""
	quantity = 0
	if icon_texture_rect:
		icon_texture_rect.texture = null
	if quantity_label:
		quantity_label.visible = false
	tooltip_text = ""

func is_empty() -> bool:
	"""Check if the slot is empty."""
	return item_id == "" or quantity <= 0

func get_item_data() -> Dictionary:
	"""Get the item data for the current item."""
	if item_id == "":
		return {}
	return ItemDatabase.get_item_data(item_id)

func _on_button_pressed():
	"""Handle left click."""
	slot_clicked.emit(self)

func _on_gui_input(event):
	"""Handle right click and other input."""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			slot_right_clicked.emit(self)

func _can_drop_data(_pos, data) -> bool:
	"""Check if we can accept dropped data."""
	if data is Dictionary and data.has("item_id"):
		return true
	return false

func _drop_data(_pos, data):
	"""Handle dropped item data."""
	if data is Dictionary and data.has("item_id"):
		var dropped_item_id = data["item_id"]
		var dropped_quantity = data.get("quantity", 1)
		
		# Swap items if both slots have items
		if not is_empty():
			var _current_data = {
				"item_id": item_id,
				"quantity": quantity,
				"source_slot": self
			}
			# This would need to be handled by the inventory UI
			print("Swapping items not implemented yet")
		else:
			setup_slot(dropped_item_id, dropped_quantity)

func _get_drag_data(_pos):
	"""Get data for dragging this item."""
	if is_empty():
		return null
	
	# Create drag preview if possible
	if icon_texture_rect and icon_texture_rect.texture:
		var preview = TextureRect.new()
		preview.texture = icon_texture_rect.texture
		preview.size = icon_texture_rect.size
		set_drag_preview(preview)
	else:
		# No preview available — continue returning data so the inventory UI can handle it
		push_warning("InventorySlot: No icon available for drag preview for item %s" % item_id)

	return {
		"item_id": item_id,
		"quantity": quantity,
		"source_slot": self
	}

# Animation helpers
func highlight():
	"""Highlight the slot."""
	modulate = Color.YELLOW

func unhighlight():
	"""Remove highlight from the slot."""
	modulate = Color.WHITE
