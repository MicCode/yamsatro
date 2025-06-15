extends Node
class_name PastScore

var date: String;
var score: int;

static func create_new(new_score_value: int) -> PastScore:
	var new_score = PastScore.new()
	new_score.score = new_score_value

	var now := Time.get_datetime_dict_from_system()
	var day := str(now["day"]).pad_zeros(2)
	var month := str(now["month"]).pad_zeros(2)
	var year := str(now["year"])
	var hour := str(now["hour"]).pad_zeros(2)
	var minute := str(now["minute"]).pad_zeros(2)
	var date_string := "%s/%s/%s - %s:%s" % [day, month, year, hour, minute]
	new_score.date = date_string
	
	return new_score

static func from_dict(dict: Dictionary) -> PastScore:
	var past_score = PastScore.new()
	past_score.score = dict.get("score", 0)
	past_score.date = dict.get("date", "")

	return past_score

func to_dict() -> Dictionary:
	return {
		"date": date,
		"score": score
	}
