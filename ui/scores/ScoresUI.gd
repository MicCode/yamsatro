extends Control

func _ready() -> void:
	Game.game_variant_changed.connect(_on_game_variant_changed)

func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
	if new_game_variant == Enums.GameVariants.FULL:
		%HeaderB.show()
		%HeaderC.show()
	else:
		%HeaderB.hide()
		%HeaderC.hide()
