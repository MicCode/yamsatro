extends TextureButton
class_name Die

signal finished_rolling

@export var locked = false
@export var hovered = false
@export var rolling = false

func _ready() -> void:
	change_visual_state()


func set_face(face: DieFace):
	var face_sprite = load("res://assets/die/die-" + face.name + ".png");
	if face_sprite:
		%value.texture = face_sprite
	else:
		push_error("Die face " + face.name + " has no defined sprite")
		
func roll(possible_faces: Array[DieFace]):
	rolling = true
	disabled = true
	scale = Vector2(0.9, 0.9)
	var roll_count = (randi() % 5) + 5 
	for i in roll_count:
		set_face(possible_faces[randi() % possible_faces.size()])
		%hit.pitch_scale = randf_range(1.5, 1.7)
		%hit.play()
		rotation = randf_range(-0.1, 0.1)
		await get_tree().create_timer(randf() / (10 / (i + 1))).timeout
	
	rotation = 0
	disabled = false
	rolling = false
	change_visual_state()
	finished_rolling.emit()
	%hit.pitch_scale = 1.8
	%hit.play()
	scale = Vector2(1, 1)
	
func lock():
	locked = !locked
	%click.pitch_scale = randf_range(0.9, 1.1)
	%click.play()
	change_visual_state()
		
func change_visual_state():
	if !rolling:
		if locked:
			%lock.show()
		else:
			%lock.hide()
		if hovered:
			modulate = Color(0.7, 0.7, 1.0)
		else:
			modulate = Color.WHITE
	else:
		modulate = Color.WHITE


func _on_mouse_entered() -> void:
	hovered = true
	change_visual_state()

func _on_mouse_exited() -> void:
	hovered = false
	change_visual_state()
