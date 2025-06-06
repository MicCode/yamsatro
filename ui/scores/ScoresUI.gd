extends Control

func _ready() -> void:
	Game.game_variant_changed.connect(_on_game_variant_changed)
	Game.score_changed.connect(_on_score_changed)
	%TotalScoreLabel.text = str(Scores.get_total())

func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
	if new_game_variant == Enums.GameVariants.FULL:
		%HeaderB.show()
		%HeaderC.show()
	else:
		%HeaderB.hide()
		%HeaderC.hide()

func _on_score_changed():
	%TotalScoreLabel.text = str(Scores.get_total())
