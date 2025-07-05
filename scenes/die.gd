extends TextureButton
class_name Die

signal finished_rolling

@export var locked = false
@export var hovered = false
@export var rolling = false
var face: DieFace
var dots: Array[Panel] = []

@export var lock_color = Color(0, 0, 1.0)
@export var dot_color = Color(0, 0, 0)

func _ready() -> void:
	dots = [%P0, %P1, %P2, %P3, %P4, %P5, %P6]
	change_dimensions()
	change_visual_state()

func set_face(new_face: DieFace):
	face = new_face
	var dots_to_activate = get_pattern_dots(face.pattern)
	for i in dots.size():
		if dots_to_activate.find(i) >= 0:
			dots[i].show()
		else:
			dots[i].hide()
		
func roll():
	rolling = true
	disabled = true
	scale = Vector2(0.75, 0.75)
	Sounds.roll()
	var roll_count = (randi() % 5) + 5
	for i in roll_count:
		set_face(Game.all_dice_faces[randi() % Game.all_dice_faces.size()])
		rotation = randf_range(-0.1, 0.1)
		await get_tree().create_timer(randf() / (10.0 / (i + 1.0))).timeout
	
	rotation = 0
	disabled = false
	rolling = false
	change_visual_state()
	finished_rolling.emit()
	Sounds.finish_roll()
	scale = Vector2(1, 1)
	
func toggle_lock():
	Sounds.click()
	set_lock(!locked)

func set_lock(new_lock: bool):
	locked = new_lock
	change_visual_state()

func change_visual_state():
	if !rolling:
		if locked:
			%lock.show()
			for dot in dots:
				change_dot_color(dot, lock_color)
		else:
			%lock.hide()
			for dot in dots:
				change_dot_color(dot, dot_color)
		if hovered:
			modulate = Color(0.7, 0.7, 1.0)
		else:
			modulate = Color.WHITE
	else:
		modulate = Color.WHITE
		for dot in dots:
			change_dot_color(dot, dot_color)

func change_dot_color(dot: Panel, color: Color):
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	stylebox.set_corner_radius_all(100)
	dot.add_theme_stylebox_override("panel", stylebox)

func _on_mouse_entered() -> void:
	hovered = true
	change_visual_state()

func _on_mouse_exited() -> void:
	hovered = false
	change_visual_state()

func get_pattern_dots(pattern: String) -> Array[int]:
	var result: Array[int] = []
	for i in pattern.length():
		if pattern[i] == "1": result.append(i)
	return result

func change_dimensions():
	var width = GUITheme.die_width
	var dot_diameter = GUITheme.die_dot_diameter

	var grid_width = width / 14
	var grid_step_1 = (grid_width * 3) - (dot_diameter / 2) # first row or colum center
	var grid_step_2 = (grid_width * 7) - (dot_diameter / 2) # middle
	var grid_step_3 = (grid_width * 11) - (dot_diameter / 2) # last

	%Background.size = Vector2(width, width)
	%lock.size = Vector2(dot_diameter, dot_diameter)
	%lock.position = Vector2(grid_step_2, grid_step_3)
	%lock.pivot_offset = Vector2(dot_diameter / 2, dot_diameter / 2)
	%lock.scale = Vector2(1.5, 1.5)
	
	for i in dots.size():
		var x: float
		var y: float

		match i:
			0, 1, 2: x = grid_step_1
			3, 4, 5: x = grid_step_3
			6: x = grid_step_2
		match i:
			0, 3: y = grid_step_1
			1, 4: y = grid_step_2
			2, 5: y = grid_step_3
			6: y = grid_step_2
		
		dots[i].pivot_offset = Vector2(dot_diameter / 2, dot_diameter / 2)
		dots[i].position = Vector2(x, y)
		dots[i].size = Vector2(dot_diameter, dot_diameter)
