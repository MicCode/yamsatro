class_name DieFace

@export var name: String;
@export var value: int;
@export var special: bool;
@export var pattern: String;
# Pattern bits:
#  .           .
#  0           3
#
#  .     .     .
#  1     6     4
#
#  .           .
#  2           5
#

static func build(_name: String, _value: int, _pattern: String, _special: bool = false):
	var die = DieFace.new()
	die.name = _name
	die.value = _value
	die.special = _special
	die.pattern = _pattern
	return die
