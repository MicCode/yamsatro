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
       var show_extra := new_game_variant == Enums.GameVariants.FULL
       for node in [%HeaderB, %HeaderC]:
               if show_extra:
                       node.show()
               else:
                       node.hide()
