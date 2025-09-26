extends Node

# This manager will instantiate the InventoryUI scene and provide a
# global toggle for it. To enable it, add this script as an Autoload
# (singleton) in Project Settings -> Autoload with the name
# `InventoryUIManager`.

var inventory_ui: Node = null

func _ready() -> void:
	# Wait a frame for other autoloads and the current scene to be ready
	await get_tree().process_frame

	# Try to preload and instantiate the InventoryUI scene
	var ui_scene = preload("res://ui/inventory/InventoryUI.tscn")
	if ui_scene:
		inventory_ui = ui_scene.instantiate()
		# Add to the current scene so it sits above gameplay nodes
		var parent = get_tree().current_scene if get_tree().current_scene else get_tree().get_root()
		parent.add_child(inventory_ui)
		inventory_ui.visible = false

	# Ensure the input action exists (fallback) so the I key works
	if not InputMap.has_action("inventory"):
		InputMap.add_action("inventory")
		var ev := InputEventKey.new()
		ev.keycode = KEY_I
		InputMap.action_add_event("inventory", ev)

	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		print("[InventoryUIManager] inventory action pressed")
		if inventory_ui:
			inventory_ui.toggle_inventory()
		else:
			print("[InventoryUIManager] InventoryUI not found — make sure res://ui/inventory/InventoryUI.tscn exists and the manager is autoloaded")
