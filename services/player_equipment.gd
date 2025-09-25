extends Node

# --- References to the sprite layers ---
# We use get_node("..") because the sprites are siblings of this node.
@onready var body_sprite = get_node("../AnimatedSprite2D_Body")
@onready var clothes_sprite = get_node("../AnimatedSprite2D_Cloths")
@onready var hair_sprite = get_node("../AnimatedSprite2D_Hairs")
@onready var weapon_sprite = get_node("../AnimatedSprite2D_Weapons")
@onready var ItemDatabase = get_node("/root/ItemDatabase")

# An array to easily access all layers at once
var all_sprites = []

# A dictionary to keep track of what is currently equipped
var equipped_items = {
	"clothes": null,
	"hair": null,
	"weapon": null
}

func _ready():
	# Populate the array when the game starts
	all_sprites = [body_sprite, clothes_sprite, hair_sprite, weapon_sprite]

# --- THE MAIN FUNCTION TO CHANGE GEAR ---
func equip_item(item_id):
	var item_data = ItemDatabase.get_item_data(item_id)
	if item_data == null:
		print("ERROR: Item not found: ", item_id)
		return

	var new_sprite_frames = load(item_data["path"])

	# Find the correct layer and equip the item
	match item_data["type"]:
		"clothes":
			clothes_sprite.sprite_frames = new_sprite_frames
			equipped_items["clothes"] = item_id
		"hair":
			hair_sprite.sprite_frames = new_sprite_frames
			equipped_items["hair"] = item_id
		"weapon":
			weapon_sprite.sprite_frames = new_sprite_frames
			equipped_items["weapon"] = item_id

# --- FUNCTIONS THE PLAYER SCRIPT WILL CALL ---
func play_animation(anim_name):
	for sprite in all_sprites:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
			sprite.play(anim_name)

func flip_sprites(is_flipped):
	for sprite in all_sprites:
		sprite.flip_h = is_flipped