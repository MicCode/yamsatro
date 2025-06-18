extends HBoxContainer
class_name MenuScoreLine

var score: PastScore

static func create(past_score: PastScore) -> MenuScoreLine:
	var line = preload("res://ui/menu/MenuScoreLine.tscn").instantiate()
	line.score = past_score
	return line

func print_score():
	%Date.text = score.date
	%Score.text = str(score.score)
