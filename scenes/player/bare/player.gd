extends CharacterBody2D


const SPEED := 200.0
const RUN_MULTIPLIER := 2.5
const JUMP_VELOCITY := -400.0
const DECELERATION := 1200.0

# If your sprite's default frame faces left instead of right, set this to true to invert flip logic
const INVERT_SPRITE_FLIP := true

# Exported settings so you can tweak from the editor without editing code
@export var run_action_name: String = "ui_shift"
@export var run_scancode_l: int = 16777248
@export var run_scancode_r: int = 16777249
@export var attack_action_name: String = "attack"
@export var attack_scancode: int = 74 # J key scancode fallback (may be engine/platform dependent)
@export var attack_lock_time: float = 0.65
@export var inventory_action_name: String = "inventory"
@export var inventory_key: int = KEY_I # use engine key constant for I

@export var sprite_path: NodePath = NodePath("AnimatedSprite2D")
@export var equipment_service_path: NodePath = NodePath("Equipment")
var sprite: AnimatedSprite2D = null
var equipment_service = null
var _prev_j_pressed: bool = false
var _is_attacking: bool = false
var _attack_timer: float = 0.0
var _prev_i_pressed: bool = false
var inventory_ui = null
const INVENTORY_UI_SCENE = preload("res://ui/inventory/InventoryUI.tscn")

func _ready() -> void:
	# Try to get the Player_Equipment service
	if equipment_service_path and equipment_service_path != NodePath(""):
		equipment_service = get_node_or_null(equipment_service_path)
	
	# Fallback: look for Equipment as child
	if not equipment_service:
		equipment_service = get_node_or_null("Equipment")
	
	# Fallback: look for Node2D_Equipment as child
	if not equipment_service:
		equipment_service = get_node_or_null("Node2D_Equipment")
	
	# If we have equipment service, we'll use it for animations
	# Otherwise, fallback to single sprite system
	if not equipment_service:
		print("Equipment service not found, falling back to single sprite system")
		# Try configured NodePath first (Inspector)
		if sprite_path and sprite_path != NodePath(""):
			sprite = get_node_or_null(sprite_path) as AnimatedSprite2D

		# Fallback: direct child with that name
		if not sprite:
			sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

		# Fallback: recursive search among descendants
		if not sprite:
			sprite = _find_animated_sprite_descendant(self)

		if not sprite:
			push_error("AnimatedSprite2D node not found for player script; animation calls will be skipped.")
	else:
		print("Equipment service found and connected")

func _physics_process(delta: float) -> void:
	# Apply gravity when in the air
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump (Space / ui_accept)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal input: returns -1.0..1.0 depending on ui_left/ui_right
	# Also allow physical 'A' and 'D' keys for left/right movement
	var direction := Input.get_axis("ui_left", "ui_right")

	# Combine axis with physical A/D key presses so both arrow keys and A/D work
	var a_pressed := Input.is_physical_key_pressed(KEY_A)
	var d_pressed := Input.is_physical_key_pressed(KEY_D)
	if a_pressed:
		direction -= 1.0
	if d_pressed:
		direction += 1.0

	# Keep direction in the -1..1 range (preserves analog input if present)
	direction = clamp(direction, -1.0, 1.0)

	# Determine if running: Shift held while moving with A or D
	var is_running := false
	var shift_pressed := false
	
	# Check for Shift key using InputMap action first
	if run_action_name != "" and InputMap.has_action(run_action_name):
		shift_pressed = Input.is_action_pressed(run_action_name)
	
	# Fallback: check physical Shift keys with Godot 4 Key enum
	if not shift_pressed:
		shift_pressed = Input.is_physical_key_pressed(KEY_SHIFT)
	
	# Enable running only when Shift is held AND there's horizontal movement
	is_running = shift_pressed and direction != 0
	
	# Debug output to help diagnose issues
	# if shift_pressed or direction != 0:
	# 	print("Debug - Shift:", shift_pressed, " Direction:", direction, " Running:", is_running)

	var current_speed := SPEED
	if direction != 0:
		if is_running:
			current_speed *= RUN_MULTIPLIER
		velocity.x = direction * current_speed
	else:
		# Smoothly decelerate to 0 when no input (use DECELERATION to control stopping)
		# velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.x = 0

	# Move the character using the built-in helper
	move_and_slide()

	# Update attack timer (lock animation for a short time)
	if _is_attacking:
		_attack_timer += delta
		if _attack_timer >= attack_lock_time:
			_is_attacking = false

	# Handle attack input after movement to avoid missing the key
	_handle_attack_input()

	# Handle inventory input (toggle with action or physical I key)
	_handle_inventory_input()

	# Decide which animation to play (attack lock check inside will prevent override)
	_update_animation(direction, is_running)


func _update_animation(direction: float, is_running: bool) -> void:
	# If currently in attack lock, keep attack animation
	if _is_attacking and is_on_floor():
		_play_animation_if_changed("attack")
		return

	# Jump animations take precedence when not on floor
	if not is_on_floor():
		# Use upward / downward frame based on vertical velocity
		if velocity.y < 0:
			_play_animation_if_changed("jumpUp")
		else:
			_play_animation_if_changed("jumpDown")
		return

	# On floor: choose between idle, walk, run
	if direction == 0:
		_play_animation_if_changed("idle")
	else:
		if is_running:
			_play_animation_if_changed("run")
		else:
			_play_animation_if_changed("walk")

	# Flip sprites depending on movement direction
	if direction < 0:
		_flip_sprites(not INVERT_SPRITE_FLIP)
	elif direction > 0:
		_flip_sprites(INVERT_SPRITE_FLIP)


func _play_animation_if_changed(anim_name: String) -> void:
	# If we have equipment service, use it for multi-layer animations
	if equipment_service:
		equipment_service.play_animation(anim_name)
	# Fallback to single sprite system
	elif sprite:
		if sprite.animation != anim_name:
			sprite.animation = anim_name
			sprite.play()


func _flip_sprites(is_flipped: bool) -> void:
	# If we have equipment service, use it for multi-layer flipping
	if equipment_service:
		equipment_service.flip_sprites(is_flipped)
	# Fallback to single sprite system
	elif sprite:
		sprite.flip_h = is_flipped


func _handle_attack_input() -> void:
	# Detect attack via InputMap action or physical J key (edge-detected)
	var attack_pressed := false
	if attack_action_name != "" and InputMap.has_action(attack_action_name):
		attack_pressed = Input.is_action_just_pressed(attack_action_name)
	else:
		var j_pressed := Input.is_physical_key_pressed(KEY_J)
		attack_pressed = j_pressed and not _prev_j_pressed
		_prev_j_pressed = j_pressed

	if attack_pressed:
		_start_attack()


func _handle_inventory_input() -> void:
	# Edge-detect inventory key: prefer InputMap action, fallback to engine key constant
	var i_pressed := false
	if inventory_action_name != "" and InputMap.has_action(inventory_action_name):
		i_pressed = Input.is_action_just_pressed(inventory_action_name)
	else:
		# Use engine key constant for fallback (edge-detect)
		var phys := Input.is_physical_key_pressed(inventory_key)
		i_pressed = phys and not _prev_i_pressed
		_prev_i_pressed = phys

	if i_pressed:
		# Instantiate inventory UI if needed
		if not inventory_ui:
			if INVENTORY_UI_SCENE:
				inventory_ui = INVENTORY_UI_SCENE.instantiate()
				if get_tree().current_scene:
					get_tree().current_scene.add_child(inventory_ui)
				else:
					get_tree().get_root().add_child(inventory_ui)
				# ensure input processing on the UI
				inventory_ui.set_process_input(true)
			else:
				print("Inventory scene missing: res://ui/inventory/InventoryUI.tscn")
		# Toggle visibility
		if inventory_ui:
			inventory_ui.toggle_inventory()


func _start_attack() -> void:
	# Begin attack: play animation and lock for the configured time
	_is_attacking = true
	_attack_timer = 0.0
	_play_animation_if_changed("attack")


func _find_animated_sprite_descendant(root):
	for child in root.get_children():
		if child is AnimatedSprite2D:
			return child
		var found = _find_animated_sprite_descendant(child)
		if found:
			return found
	return null


# --- EQUIPMENT MANAGEMENT FUNCTIONS ---
# These functions provide easy access to the Player_Equipment service

func equip_item(item_id: String) -> void:
	"""Equip an item using the Equipment service"""
	if equipment_service:
		equipment_service.equip_item(item_id)
	else:
		push_warning("Cannot equip item: Equipment service not available")

func get_equipped_items() -> Dictionary:
	"""Get currently equipped items"""
	if equipment_service:
		return equipment_service.equipped_items
	else:
		return {}

func is_equipment_service_available() -> bool:
	"""Check if the Equipment service is available"""
	return equipment_service != null

# Add a heal function for consumables
func heal(amount: int):
	"""Heal the player by a certain amount"""
	print("Player healed for ", amount, " HP")
