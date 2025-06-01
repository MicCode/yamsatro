extends TextureRect

var possible_faces = DieFace.load_from_json()
var remaining_rolls = 3

func _ready() -> void:
	roll_all()
	for die in get_all_dice():
		die.pressed.connect(on_die_pressed.bind(die))
	pass

func roll_all():
	if remaining_rolls > 0:
		var some_rolled = false
		for die in get_all_dice():
			if !die.locked:
				die.roll(possible_faces)
				some_rolled = true
		if some_rolled:
			change_roll_count(remaining_rolls - 1)
	

func get_all_dice() -> Array[Die]:
	var dice: Array[Die] = []
	for child in get_children():
		if child is Die:
			dice.append(child)
	return dice

func on_die_pressed(die: Die):
	die.lock()
	pass
	
func change_roll_count(count: int):
	remaining_rolls = count
	if remaining_rolls <= 0:
		%RollButton.disabled = true
	else:
		%RollButton.disabled = false
	%RollButton.text = str("ROLL (%s)" % remaining_rolls)


func _on_roll_button_pressed() -> void:
	roll_all()
