extends TextureButton
class_name Die

@export var locked = false
@export var hovered = false

func _ready() -> void:
	change_visual_state()

func set_face(face: DieFace):
	var face_sprite = load("res://assets/die/die-" + face.name + ".png");
	if face_sprite:
		%value.texture = face_sprite
	else:
		push_error("Die face " + face.name + " has no defined sprite")
		
func roll(possible_faces: Array[DieFace]):
	#TODO animate roll
	var i = randi() % possible_faces.size()
	set_face(possible_faces[i])
	
func lock():
	locked = !locked
	change_visual_state()
		
func change_visual_state():
	if hovered:
		modulate = Color(0.7, 0.7, 1.0)
	else:
		modulate = Color.WHITE


func _on_mouse_entered() -> void:
	hovered = true
	change_visual_state()

func _on_mouse_exited() -> void:
	hovered = false
	change_visual_state()
