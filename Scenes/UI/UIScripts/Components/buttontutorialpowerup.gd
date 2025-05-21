extends Button

@export var rte_item: RichTextLabel
@export var item_description: String

@onready var rte_selected_item := $"../../../VBoxContainer/RTESelectedItem"
@onready var rte_selected_item_desc := $"../../../VBoxContainer/ScrollContainer/VBoxContainer/RTESelectedItemDesc"
@onready var audio_ui = $AudioUI

var tween: Tween


func _ready():
	connect("pressed", _on_button_pressed)
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	set_pivot_offset(size * 0.5) # ensure scaling from center
	
	tween = create_tween()
	tween.kill()  # We will reuse this tween later

func _on_button_pressed():
	audio_ui.play()
	if rte_selected_item and rte_selected_item_desc and rte_item:
		rte_selected_item.text = rte_item.text
		rte_selected_item_desc.text = item_description


func _on_mouse_entered():
	_animate_scale(Vector2(1.05, 1.05))  # Scale up

func _on_mouse_exited():
	_animate_scale(Vector2(1.0, 1.0))  # Scale back to normal

func _animate_scale(target_scale: Vector2):
	if tween:
		tween.kill()  # Cancel any ongoing tween
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
