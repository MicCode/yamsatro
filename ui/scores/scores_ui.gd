extends Control

func _ready() -> void:
	load_all_figures()
	Game.active_figures_changed.connect(_on_active_figures_changed)
	
func load_all_figures():
	pass

func _on_active_figures_changed():
	pass
