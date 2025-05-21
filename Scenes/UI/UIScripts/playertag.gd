extends Control



@onready var tex_p1 = $TexP1
@onready var tex_p2 = $TexP2

@export_enum("P1", "P2") var player := "P1"  # Don't call update here
@export var is_ready: bool = true           # Don't call update here

func _ready():
	_update_texture_visibility()
	_update_ready_state()

# Optional: If you want runtime changes from outside script to trigger updates:
func _set_player(value):
	player = value
	_update_texture_visibility()

func _set_ready(value):
	is_ready = value
	_update_ready_state()

func _update_texture_visibility():
	# Hide both first
	tex_p1.visible = false
	tex_p2.visible = false

	# Show based on selection
	match player:
		"P1":
			tex_p1.visible = true
		"P2":
			tex_p2.visible = true

	# Also update the brightness if needed
	_update_ready_state()

func _update_ready_state():
	# Determine the visible texture node
	var current_texture: Node = null
	match player:
		"P1":
			current_texture = tex_p1
		"P2":
			current_texture = tex_p2

	if current_texture:
		if is_ready:
			current_texture.modulate = Color(1, 1, 1, 1)  # normal color
		else:
			current_texture.modulate = Color(0.5, 0.5, 0.5, 1)  # darker (50% brightness)
