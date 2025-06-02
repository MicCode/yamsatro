extends HBoxContainer
class_name ScoreLine

@export var label: String
@export var score: int

func _ready() -> void:
	%Label.text = label
	%Score.text = "-"

func set_score(new_score: int):
	score = new_score
	%Score.text = str(score)

func _on_mouse_entered() -> void:
	modulate = Color(0.7, 0.7, 1.0)

func _on_mouse_exited() -> void:
	modulate = Color.WHITE
