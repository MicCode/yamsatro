extends Panel
class_name ScoreLine

@export var figure: Enums.Figures
@export var bg_color = Color(0.2, 0.2, 0.2)

var hover_border_color: Color = Color.SKY_BLUE
var border_width: int = 1

var stylebox := StyleBoxFlat.new()
var game_variant: Enums.GameVariants = Enums.GameVariants.FULL
var is_active = false

var cells: Dictionary = {
	Enums.ScoreColumns.DOWN: null,
	Enums.ScoreColumns.FREE: null,
	Enums.ScoreColumns.UP: null,
}

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	self.add_theme_stylebox_override("panel", stylebox)
	set_border(Color(0, 0, 0, 0), 0)
	Game.game_variant_changed.connect(_on_game_variant_changed)
	
	%Label.text = Enums.figure_display_name(figure)
	cells[Enums.ScoreColumns.DOWN] = %ScoreCellA
	cells[Enums.ScoreColumns.FREE] = %ScoreCellB
	cells[Enums.ScoreColumns.UP] = %ScoreCellC
	
	for cell: ScoreCell in cells.values():
		cell.set_score(-1)
		cell.clicked.connect(func(): _on_score_cell_clicked(cell))
		cell.delete_clicked.connect(func(): _on_score_cell_delete_clicked(cell))
		cell.figure = figure
	
func set_border(border_color: Color = Color(0, 0, 0, 0), border_size: int = 0):
	stylebox.border_color = border_color
	stylebox.border_width_left = border_size
	stylebox.border_width_top = border_size
	stylebox.border_width_right = border_size
	stylebox.border_width_bottom = border_size
	stylebox.draw_center = true
	stylebox.bg_color = bg_color

func set_value(column: Enums.ScoreColumns, new_value: int):
	(cells[column] as ScoreCell).set_score(new_value)

func _on_mouse_entered() -> void:
	set_border(hover_border_color, border_width)

func _on_mouse_exited() -> void:
	set_border(hover_border_color, 0)

func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
	game_variant = new_game_variant
	if game_variant == Enums.GameVariants.FULL:
		cells[Enums.ScoreColumns.FREE].show()
		cells[Enums.ScoreColumns.UP].show()
	else:
		cells[Enums.ScoreColumns.FREE].hide()
		cells[Enums.ScoreColumns.UP].hide()

func _on_score_cell_clicked(cell: ScoreCell):
	var score = Game.compute_score(figure);
	cell.set_score(score)
	Game.registerScore(cell.column, figure, score)

func _on_score_cell_delete_clicked(cell: ScoreCell):
	cell.set_score(0)
	Game.registerScore(cell.column, figure, 0)
