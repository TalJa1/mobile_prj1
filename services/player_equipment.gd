# player_equipment.gd
# Manages the visual appearance and animations of the player character
extends Node

# --- References to the sprite layers ---
@onready var body_sprite = get_node("../AnimatedSprite2D_Body")
@onready var clothes_sprite = get_node("../AnimatedSprite2D_Cloths") 
@onready var hair_sprite = get_node("../AnimatedSprite2D_Hairs")
@onready var weapon_sprite = get_node("../AnimatedSprite2D_Weapons")

# An array to easily access all layers at once
var all_sprites = []

# Currently equipped items by slot
var equipped_items = {
	"body": null,
	"clothes": null,
	"hair": null, 
	"weapon": null
}

# Track multiple clothing pieces
var clothing_items = {
	"top": null,
	"bottom": null,
	"shoes": null,
	"accessory": null
}

# Signals
signal equipment_changed(slot: String, item_id: String)

func _ready():
	print("Equipment manager starting...")
	
	# Populate the array when the game starts
	all_sprites = [body_sprite, clothes_sprite, hair_sprite, weapon_sprite]
	
	print("Sprite references - Body: ", body_sprite, " Clothes: ", clothes_sprite, " Hair: ", hair_sprite, " Weapon: ", weapon_sprite)
	
	# Load default body sprite frames
	if body_sprite and ResourceLoader.exists("res://scenes/player/bare/body_sf.tres"):
		body_sprite.sprite_frames = load("res://scenes/player/bare/body_sf.tres")
		body_sprite.play("idle")  # Start playing animation
		equipped_items["body"] = "body"
		print("Body sprite loaded and playing")
	
	# Auto-equip starter items if available
	call_deferred("_auto_equip_starting_items")

# Convert player animation names to match the expected format
func _convert_player_to_equipment_anim(player_anim: String) -> String:
	match player_anim:
		"jump_up":
			return "jumpUp"
		"jump_down": 
			return "jumpDown"
		_:
			return player_anim

# --- MAIN EQUIPMENT FUNCTION ---
func equip_item(item_id: String) -> bool:
	"""Equip an item. Returns true if successful."""
	var item_data = get_node("/root/ItemDatabase").get_item_data(item_id)
	if item_data == null:
		print("ERROR: Item not found: ", item_id)
		return false
	
	# Check if item is in inventory
	if not get_node("/root/InventoryData").has_item(item_id):
		print("ERROR: Item not in inventory: ", item_id)
		return false
	
	var item_type = item_data.get("type")
	var sprite_frames_path = item_data.get("sprite_frames_path", "")
	
	if sprite_frames_path == "" or not ResourceLoader.exists(sprite_frames_path):
		print("ERROR: Invalid sprite frames path for item: ", item_id)
		return false
	
	var new_sprite_frames = load(sprite_frames_path)
	var success = false
	
	# Handle different item types
	match item_type:
		0:  # ItemType.CLOTHES
			var clothing_slot = item_data.get("clothing_slot", -1)
			success = _equip_clothing(item_id, clothing_slot, new_sprite_frames)
		1:  # ItemType.HAIR  
			if hair_sprite:
				hair_sprite.sprite_frames = new_sprite_frames
				hair_sprite.play("idle")
				equipped_items["hair"] = item_id
				success = true
		2:  # ItemType.WEAPON
			if weapon_sprite:
				weapon_sprite.sprite_frames = new_sprite_frames
				weapon_sprite.play("idle")
				equipped_items["weapon"] = item_id
				success = true
		_:
			print("ERROR: Unsupported item type: ", item_type)
	
	if success:
		equipment_changed.emit("equipped", item_id)
		print("Successfully equipped: ", item_data.get("name", item_id))
	
	return success

func _equip_clothing(item_id: String, clothing_slot: int, sprite_frames: Resource) -> bool:
	"""Handle equipping clothing items to the clothes layer."""
	if not clothes_sprite:
		return false
	
	# For now, all clothing goes to the clothes sprite layer
	# In a more complex system, you might have separate sprites for different clothing types
	clothes_sprite.sprite_frames = sprite_frames
	clothes_sprite.play("idle")
	
	# Track what type of clothing is equipped
	match clothing_slot:
		0, 1, 2, 3:  # TOP, BOTTOM, SHOES, ACCESSORY
			equipped_items["clothes"] = item_id
			var slot_names = ["top", "bottom", "shoes", "accessory"]
			if clothing_slot < slot_names.size():
				clothing_items[slot_names[clothing_slot]] = item_id
	
	return true

func _auto_equip_starting_items():
	"""Auto-equip starting items from inventory"""
	print("Auto-equipping starting items...")
	var inventory = get_node("/root/InventoryData")
	
	if not inventory:
		print("ERROR: Could not find InventoryData!")
		return
	
	# Try to equip starting items in priority order
	# For now, just equip the most visible item (pants/skirt)
	var priority_items = ["blue_pants", "blue_skirt"]  
	
	for item_id in priority_items:
		print("Checking item: ", item_id, " - Has item: ", inventory.has_item(item_id))
		if inventory.has_item(item_id):
			var result = equip_item(item_id)
			print("Equip result for ", item_id, ": ", result)
			if result:
				break  # Only equip the first available item
	
	# Also try to equip boots separately if they exist
	if inventory.has_item("boots"):
		print("Note: Boots available but current system uses single clothing layer")

func unequip_item(slot: String) -> bool:
	"""Unequip an item from a slot. Returns true if successful."""
	if not equipped_items.has(slot):
		return false
	
	var target_sprite = null
	match slot:
		"clothes":
			target_sprite = clothes_sprite
		"hair":
			target_sprite = hair_sprite
		"weapon":
			target_sprite = weapon_sprite
	
	if target_sprite:
		target_sprite.sprite_frames = null
		equipped_items[slot] = null
		equipment_changed.emit(slot, "")
		print("Unequipped from slot: ", slot)
		return true
	
	return false

func get_equipped_item(slot: String) -> String:
	"""Get the currently equipped item ID for a slot."""
	return equipped_items.get(slot, "")

func is_item_equipped(item_id: String) -> bool:
	"""Check if a specific item is currently equipped."""
	for slot in equipped_items.keys():
		if equipped_items[slot] == item_id:
			return true
	return false

# --- ANIMATION FUNCTIONS ---
func play_animation(anim_name: String):
	"""Play animation on all equipped layers that have it."""
	var equipment_anim = _convert_player_to_equipment_anim(anim_name)
	
	for sprite in all_sprites:
		if not sprite or not sprite.sprite_frames:
			continue
		
		# Only play animation if this layer has equipment and the animation exists
		if sprite.sprite_frames.has_animation(equipment_anim):
			sprite.play(equipment_anim)
		elif sprite.sprite_frames.has_animation(anim_name):
			# Fallback to original name if converted name doesn't exist
			sprite.play(anim_name)

func flip_sprites(is_flipped: bool):
	"""Flip all sprite layers horizontally."""
	for sprite in all_sprites:
		if sprite:
			sprite.flip_h = is_flipped

func stop_all_animations():
	"""Stop animations on all layers."""
	for sprite in all_sprites:
		if sprite:
			sprite.stop()

func set_animation_speed(speed: float):
	"""Set animation speed for all layers."""
	for sprite in all_sprites:
		if sprite:
			sprite.speed_scale = speed