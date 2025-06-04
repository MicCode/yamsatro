extends Control

func _ready() -> void:
	load_all_figures()
	Game.active_figures_changed.connect(_on_active_figures_changed)
	Game.game_variant_changed.connect(_on_game_variant_changed)
	
func load_all_figures():
	pass

func _on_active_figures_changed():
	pass

func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
	if new_game_variant == Enums.GameVariants.FULL:
		%HeaderB.show()
		%HeaderC.show()
	else:
		%HeaderB.hide()
		%HeaderC.hide()
