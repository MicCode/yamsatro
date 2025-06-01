class_name DieFace

@export var name: String;
@export var value: int;
@export var special: bool;

static func load_from_json() -> Array[DieFace]:
	var all_faces: Array[DieFace] = []
	
	var json_file := FileAccess.open("res://data/die-faces.json", FileAccess.READ)
	if !json_file:
		push_error("Unable to load JSON file [res://data/die-faces.json]")
		return all_faces
	
	var content := json_file.get_as_text()
	json_file.close()
	
	var json := JSON.new()
	var result := json.parse(content)
	if result != OK:
		push_error("Unable to parse JSON file: %s" % json.get_error_message())
		return all_faces
	
	var data_array = json.data
	for entry in data_array:
		var face := DieFace.new()
		face.name = entry.get("name", "")
		face.value = entry.get("value", 0)
		face.special = entry.get("special", false)
		all_faces.append(face)
		
	return all_faces
