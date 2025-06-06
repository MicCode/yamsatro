class_name DieFace

@export var name: String;
@export var value: int;
@export var special: bool;

static func build(_name: String, _value: int, _special: bool = false):
	var die = DieFace.new()
	die.name = _name
	die.value = _value
	die.special = _special
	return die
