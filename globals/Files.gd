extends Node

const GAME_JSON_FILE = "user://game.json"
const SCORES_JSON_FILE = "user://scores.json"
const PAST_SCORES_JSON_FILE = "user://past-scores.json"

func read_scores() -> Dictionary:
    return _read_file(SCORES_JSON_FILE)

func write_scores(data: Dictionary):
    _write_file(SCORES_JSON_FILE, data)
    _write_file(SCORES_JSON_FILE, data)

func read_past_scores() -> Array:
    return _read_file(PAST_SCORES_JSON_FILE, true)

func write_past_scores(data: Array):
    _write_file(PAST_SCORES_JSON_FILE, data)

func read_game_state() -> Dictionary:
    return _read_file(GAME_JSON_FILE)

func write_game_state(data: Dictionary):
    _write_file(GAME_JSON_FILE, data)


func _read_file(file_path: String, as_array: bool = false):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var json_content = file.get_as_text()
        file.close()
        var json := JSON.new()
        var error := json.parse(json_content)
        if error == OK:
            return json.data
        else:
            push_error("Impossible de lire les données du fichier [" + file_path + "], data: " + json_content)
    else:
        push_error("Impossible de lire les données du fichier [" + file_path + "]")

    if as_array:
        return []
    else:
        return {}

func _write_file(file_path: String, data):
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        var json_content = JSON.stringify(data, "\t")
        file.store_string(json_content)
        file.close()
    else:
        push_error("Impossible d'écrire dans le fichier [" + file_path + "]")
