extends TextureRect

var possible_faces = DieFace.load_from_json()

func _ready() -> void:
	roll_all()
	for die in get_all_dice():
		die.pressed.connect(on_die_pressed.bind(die))
	pass

func roll_all():
	for die in get_all_dice():
		if !die.locked:
			die.roll(possible_faces)

func get_all_dice() -> Array[Die]:
	var dice: Array[Die] = []
	for child in get_children():
		if child is Die:
			dice.append(child)
	return dice

func on_die_pressed(die: Die):
	die.lock()
	pass
