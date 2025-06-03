extends Node2D

func _ready() -> void:
	Game.init_game(Enums.GameVariants.FULL)
	randomize()
