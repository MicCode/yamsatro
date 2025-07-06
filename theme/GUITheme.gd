extends Node

var die_width: float = 180.0
var die_dot_diameter: float = 35.0
var tray_space_between_dice: float = 10.0
var default_padding_px := 10.0

var theme: Theme = load("res://theme/theme.tres")

var primary_color: Color;
var secondary_color: Color;
var accent_color: Color;
var complementary_color: Color;
var neutral_color: Color;
var background_color: Color;

func _enter_tree() -> void:
	var palette: ColorPalette = load("res://theme/rust_gold_palette.tres")
	primary_color = palette.colors[1]
	secondary_color = palette.colors[4]
	accent_color = palette.colors[0]
	complementary_color = palette.colors[8]
	neutral_color = palette.colors[6]
	background_color = palette.colors[7]
	
	init_theme()
	
func init_theme():
	change_theme_color("panel", "Panel", transparent(background_color, 0.5))
	get_tree().root.theme = theme
	
func change_theme_color(style_name: String, theme_type: String, color: Color):
	var stylebox = theme.get_stylebox(style_name, theme_type)
	if stylebox is StyleBoxFlat:
		stylebox.bg_color = color

func light(color: Color) -> Color:
	return color.lightened(0.5)

func transparent(color: Color, opacity: float) -> Color:
	return Color(color.r, color.g, color.b, opacity)

## Fait rapidement grossir et colore un objet avant de le remettre à son état initial
func emphases(object: Object, color: Color):
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(object, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(object, "modulate", color, 0.05)
	tween.tween_property(object, "scale", Vector2(1, 1), 0.20)
	tween.tween_property(object, "modulate", Color.WHITE, 0.20)
