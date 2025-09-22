extends CharacterBody2D


const SPEED := 300.0
const RUN_MULTIPLIER := 1.6
const JUMP_VELOCITY := -400.0
const DECELERATION := 1200.0

# If your sprite's default frame faces left instead of right, set this to true to invert flip logic
const INVERT_SPRITE_FLIP := true

# Exported settings so you can tweak from the editor without editing code
@export var run_action_name: String = "ui_shift"
@export var run_scancode_l: int = 16777248
@export var run_scancode_r: int = 16777249

var sprite: AnimatedSprite2D

func _ready() -> void:
	sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Apply gravity when in the air
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump (Space / ui_accept)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal input: returns -1.0..1.0 depending on ui_left/ui_right
	var direction := Input.get_axis("ui_left", "ui_right")

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
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	# Move the character using the built-in helper
	move_and_slide()

	# Decide which animation to play
	_update_animation(direction, is_running)


func _update_animation(direction: float, is_running: bool) -> void:
	# Jump animations take precedence when not on floor
	if not is_on_floor():
		# Use upward / downward frame based on vertical velocity
		if velocity.y < 0:
			_play_animation_if_changed("jump_up")
		else:
			_play_animation_if_changed("jump_down")
		return

	# On floor: choose between idle, walk, run
	if direction == 0:
		_play_animation_if_changed("idle")
	else:
		if is_running:
			_play_animation_if_changed("run")
		else:
			_play_animation_if_changed("walk")

	# Flip sprite depending on movement direction
	if direction < 0:
		sprite.flip_h = not INVERT_SPRITE_FLIP
	elif direction > 0:
		sprite.flip_h = INVERT_SPRITE_FLIP


func _play_animation_if_changed(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.animation = anim_name
		sprite.play()
