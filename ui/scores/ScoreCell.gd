extends Panel
class_name ScoreCell

signal clicked
signal delete_clicked
signal score_changed

enum States {
	NEUTRAL,
	NEUTRAL_HOVERED,
	SELECTABLE,
	SELECTABLE_HOVERED,
}

@export var column: Enums.ScoreColumns
@export var figure: Enums.Figures
@export var score = -1

var neutral_bg_color
var neutral_hovered_bg_color
var selectable_bg_color: Color
var selectable_hovered_bg_color: Color

var is_selectable = false
var is_hovered = false
var state: States = States.NEUTRAL

var stylebox := StyleBoxFlat.new()

func _ready() -> void:
	Game.dice_rolling_changed.connect(update_state)
	Game.score_changed.connect(_on_score_changed)
	Game.active_figures_changed.connect(update_state)
	mouse_filter = MOUSE_FILTER_PASS
	
	selectable_bg_color = GUITheme.complementary_color
	selectable_hovered_bg_color = GUITheme.light(GUITheme.complementary_color)
	neutral_bg_color = GUITheme.background_color
	neutral_hovered_bg_color = GUITheme.light(GUITheme.background_color)
	
	self.add_theme_stylebox_override("panel", stylebox)
	update_state()

func set_score(new_score: int):
	score = new_score
	if score >= 0:
		%ScoreLabel.text = str(score)
		score_changed.emit()
	else:
		%ScoreLabel.text = "-"
	
func update_state():
	if Game.dice_rolling == false:
		is_selectable = Game.is_scorable(figure, column)
	else:
		is_selectable = false
	
	if score == -1:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	
	if is_selectable:
		if is_hovered:
			state = States.SELECTABLE_HOVERED
		else:
			state = States.SELECTABLE
	else:
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
		elif !Game.dice_rolling && score == -1:
			%DeleteButton.show()
		Sounds.click()

func _on_delete_button_mouse_exited() -> void:
	%DeleteButton.hide()

func _on_delete_button_pressed() -> void:
	delete_clicked.emit()
	%DeleteButton.hide()

func _on_score_changed():
	var value_in_scores = Scores.get_cell_score(column, figure)
	if value_in_scores != score:
		set_score(value_in_scores)
