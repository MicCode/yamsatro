extends Panel

@export var label: String = "TOTAL"
@export var category: Enums.SumCategories

var cells: Dictionary = {
	Enums.ScoreColumns.DOWN: {
		value = 0,
		label = null
	},
	Enums.ScoreColumns.FREE: {
		value = 0,
		label = null
	},
	Enums.ScoreColumns.UP: {
		value = 0,
		label = null
	},
}

func _ready() -> void:
	Game.game_variant_changed.connect(_on_game_variant_changed)
	Game.scores_changed.connect(_on_scores_changed)

	%Label.text = label
	cells[Enums.ScoreColumns.DOWN].label = %ValueA
	cells[Enums.ScoreColumns.FREE].label = %ValueB
	cells[Enums.ScoreColumns.UP].label = %ValueC
	refresh_display()

func set_cell_value(column: Enums.ScoreColumns, new_value: int):
	if cells[column].value != new_value:
		cells[column].value = new_value
		GUITheme.emphases(cells[column].label, GUITheme.complementary_color)
		refresh_display()

func refresh_display():
	cells[Enums.ScoreColumns.DOWN].label.text = str(cells[Enums.ScoreColumns.DOWN].value)
	cells[Enums.ScoreColumns.FREE].label.text = str(cells[Enums.ScoreColumns.FREE].value)
	cells[Enums.ScoreColumns.UP].label.text = str(cells[Enums.ScoreColumns.UP].value)

			
func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
	if new_game_variant == Enums.GameVariants.FULL:
		cells[Enums.ScoreColumns.FREE].label.show()
		cells[Enums.ScoreColumns.UP].label.show()
	else:
		cells[Enums.ScoreColumns.FREE].label.hide()
		cells[Enums.ScoreColumns.UP].label.hide()

func _on_scores_changed():
	set_cell_value(Enums.ScoreColumns.DOWN, Scores.columns[Enums.ScoreColumns.DOWN].totals[category])
	set_cell_value(Enums.ScoreColumns.FREE, Scores.columns[Enums.ScoreColumns.FREE].totals[category])
	set_cell_value(Enums.ScoreColumns.UP, Scores.columns[Enums.ScoreColumns.UP].totals[category])
