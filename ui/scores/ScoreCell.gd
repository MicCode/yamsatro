extends Panel
class_name ScoreCell

signal clicked
signal score_changed

enum States {
	NEUTRAL,
	NEUTRAL_HOVERED,
	SELECTABLE,
	SELECTABLE_HOVERED,
}

@export var column: Enums.ScoreColumns
@export var score = -1
@export var neutral_bg_color: Color = Color(0.2, 0.2, 0.2)
@export var neutral_hovered_bg_color: Color = Color(0.3, 0.3, 0.3)
@export var selectable_bg_color: Color = Color(0.2, 0.5, 0.5)
@export var selectable_hovered_bg_color: Color = Color(0.6, 0.7, 0.7)

var is_selectable = false
var is_hovered = false
var state: States = States.NEUTRAL

var stylebox := StyleBoxFlat.new()

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	self.add_theme_stylebox_override("panel", stylebox)
	change_visual_state()

func set_score(new_score: int):
	score = new_score
	if score >= 0:
		%ScoreLabel.text = str(score)
		score_changed.emit()
	else:
		%ScoreLabel.text = "-"
		
func set_selectable(b: bool):
	is_selectable = b && score < 0
	update_state()
	
func update_state():
	if is_selectable:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if is_hovered:
			state = States.SELECTABLE_HOVERED
		else:
			state = States.SELECTABLE
	else:
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		if is_hovered:
			state = States.NEUTRAL_HOVERED
		else:
			state = States.NEUTRAL
	change_visual_state()

func change_visual_state():
	match state:
		States.NEUTRAL:
			stylebox.bg_color = neutral_bg_color
		States.NEUTRAL_HOVERED:
			stylebox.bg_color = neutral_hovered_bg_color
		States.SELECTABLE:
			stylebox.bg_color = selectable_bg_color
		States.SELECTABLE_HOVERED:
			stylebox.bg_color = selectable_hovered_bg_color
			
func _on_mouse_entered() -> void:
	is_hovered = true
	update_state()

func _on_mouse_exited() -> void:
	is_hovered = false
	update_state()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_selectable:
			clicked.emit()
	# TODO ajouter le clic gauche pour sacrifier une cellule
