extends Control


@export_file("*.tscn")
var next_level_path: String = (
	"res://scenes/cutscenes/second_map_intro.tscn"
)

@export_file("*.tscn")
var main_menu_path: String = (
	"res://scenes/menus/main_menu.tscn"
)


@onready var continue_button: Button = (
	$CenterContainer/Panel/Margin/Content/ContinueButton
)

@onready var main_menu_button: Button = (
	$CenterContainer/Panel/Margin/Content/MainMenuButton
)


func _ready() -> void:
	continue_button.pressed.connect(
		_on_continue_button_pressed
	)

	main_menu_button.pressed.connect(
		_on_main_menu_button_pressed
	)

	continue_button.grab_focus()


func _on_continue_button_pressed() -> void:
	if next_level_path.is_empty():
		push_error(
			"O caminho do próximo mapa não foi configurado."
		)
		return

	if not ResourceLoader.exists(next_level_path):
		push_error(
			"A cena do próximo mapa não existe: "
			+ next_level_path
		)
		return

	set_buttons_enabled(false)

	SceneTransition.change_scene(
		next_level_path
	)


func _on_main_menu_button_pressed() -> void:
	if main_menu_path.is_empty():
		return

	set_buttons_enabled(false)

	SceneTransition.change_scene(
		main_menu_path
	)


func set_buttons_enabled(enabled: bool) -> void:
	continue_button.disabled = not enabled
	main_menu_button.disabled = not enabled
