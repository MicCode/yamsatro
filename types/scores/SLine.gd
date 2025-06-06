extends Node
class_name SLine

var figure: Enums.Figures
var score: int = -1

static func withFigure(new_figure: Enums.Figures):
	var line = new()
	line.figure = new_figure
	return line
