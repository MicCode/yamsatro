class_name DieFace

@export var name: String;
@export var value: int;
@export var special: bool;

static func build(name: String, value: int, special: bool = false):
	var die = DieFace.new()
	die.name = name
	die.value = value
	die.special = special
	return die
