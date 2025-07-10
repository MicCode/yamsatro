extends Node
class_name SLine

var figure: Enums.Figures
var score: int = -1

static func withFigure(new_figure: Enums.Figures):
    var line = new()
    line.figure = new_figure
    return line

func to_dict() -> Dictionary:
    return {
        "figure": figure,
        "score": score
    }

static func from_dict(data: Dictionary) -> SLine:
    var line = SLine.withFigure(Enums.Figures.values()[int(data.get("figure", 0))])
    line.score = int(data.get("score", -1))
    return line