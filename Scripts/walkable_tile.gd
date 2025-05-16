extends Node2D

@export var alt_texture: Texture2D
var is_alt_tile = false

func _ready():
	# Get the grid position by dividing global position by cell size (typically 64)
	var grid_x = int(global_position.x / 64)
	var grid_y = int(global_position.y / 64)
	# Apply checkered pattern
	is_alt_tile = alt_texture != null and (grid_x + grid_y) % 2 == 1
	if is_alt_tile:
		$Sprite2D.texture = alt_texture
		
	# Make sure animations are initially stopped and hidden
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.visible = false
		$AnimatedSprite2D.stop()
	
	if has_node("AnimatedSprite2D2"):
		$AnimatedSprite2D2.visible = false
		$AnimatedSprite2D2.stop()

func play_explosion_animation():
	print("DUAR")
	
	# Choose which animation to play based on tile type
	var anim_sprite = $AnimatedSprite2D
	if is_alt_tile:
		print("atl")
		anim_sprite = $AnimatedSprite2D2
	
	if anim_sprite:
		anim_sprite.visible = true
		anim_sprite.play()
		await anim_sprite.animation_finished
		
		# Hide animation when done
		anim_sprite.visible = false
		anim_sprite.stop()
	
func _process(delta):
	pass

func _on_area_2d_body_entered(body):
	if body:
		print("IM WALKIN HERE")
		
# Add this function to allow setting is_alt_tile from outside
func set_is_alt_tile(value: bool):
	is_alt_tile = value
