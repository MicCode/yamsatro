extends Panel

@export var label: String = "TOTAL"

var values: Dictionary = {
	"A" = 0,
	"B" = 0,
	"C" = 0,
}

func _ready() -> void:
	Game.game_variant_changed.connect(_on_game_variant_changed)
	%Label.text = label
	%ValueA.text = str(values["A"])
	%ValueB.text = str(values["B"])
	%ValueC.text = str(values["C"])

func set_value(column: Enums.ScoreColumns, new_value: int):
	match column:
		Enums.ScoreColumns.DOWN:
			values["A"] = new_value
			%ValueA.text = str(new_value)
		Enums.ScoreColumns.FREE:
			values["B"] = new_value
			%ValueB.text = str(new_value)
		Enums.ScoreColumns.UP:
			values["C"] = new_value
			%ValueC.text = str(new_value)
			
func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
	if new_game_variant == Enums.GameVariants.FULL:
		%ValueB.show()
		%ValueC.show()
	else:
		%ValueB.hide()
		%ValueC.hide()
