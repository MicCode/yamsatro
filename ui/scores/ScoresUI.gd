extends Control

var actual_total_score: int

func _ready() -> void:
	Game.game_variant_changed.connect(_on_game_variant_changed)
	Game.scores_changed.connect(_on_scores_changed)
	%TotalScoreLabel.text = str(Scores.get_total())

func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
	if new_game_variant == Enums.GameVariants.FULL:
		%HeaderB.show()
		%HeaderC.show()
	else:
		%HeaderB.hide()
		%HeaderC.hide()

func _on_scores_changed():
	if actual_total_score != Scores.get_total():
		actual_total_score = Scores.get_total()
		%TotalScoreLabel.text = str(Scores.get_total())
		GUITheme.emphases(%TotalScoreLabel, GUITheme.complementary_color)
