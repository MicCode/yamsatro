extends Node2D

@export var max_rolls = 3

func _ready() -> void:
	await Game.game_ready
	Game.set_dice_reference(get_all_dice());
	roll_all()
	for die in Game.all_dice:
		die.pressed.connect(on_die_pressed.bind(die))
	Game.remaining_rolls_changed.connect(_on_remaining_rolls_changed)

func roll_all():
	Game.change_dice_rolling(true)
	var some_rolled = false
	for die in Game.all_dice:
		if !die.locked:
			die.roll()
			some_rolled = true
	if some_rolled:
		Game.change_remaining_rolls(Game.remaining_rolls - 1)
			
func unlock_all():
	for die in Game.all_dice:
		if die.locked:
			die.lock()
	

func get_all_dice() -> Array[Die]:
	var dice: Array[Die] = []
	for child in get_children():
		if child is Die:
			dice.append(child)
	return dice

func on_die_pressed(die: Die):
	die.lock()
	pass
	
func _on_dice_roll_finished():
	var all_finished = Game.all_dice.all(func(die): return !die.rolling)
	if all_finished:
		Game.update_active_figures()
		Game.change_dice_rolling(false)

func _on_remaining_rolls_changed():
	if Game.remaining_rolls <= 0:
		%Background.modulate = Color(0.7, 0.7, 1, 1)
	else:
		%Background.modulate = Color(1, 1, 1, 1)
