extends Control


const INITIAL_LEVEL_PATH: String = (
	"res://scenes/map/initial_level.tscn"
)

const MAIN_MENU_PATH: String = (
	"res://scenes/menus/main_menu.tscn"
)


@onready var retry_button: Button = (
	$CenterContainer/Panel/Margin/Content/RetryButton
)

@onready var main_menu_button: Button = (
	$CenterContainer/Panel/Margin/Content/MainMenuButton
)


func _ready() -> void:
	retry_button.pressed.connect(
		_on_retry_button_pressed
	)

	main_menu_button.pressed.connect(
		_on_main_menu_button_pressed
	)

	retry_button.grab_focus()


func _on_retry_button_pressed() -> void:
	set_buttons_enabled(false)

	SceneTransition.change_scene(
		INITIAL_LEVEL_PATH
	)


func _on_main_menu_button_pressed() -> void:
	set_buttons_enabled(false)

	SceneTransition.change_scene(
		MAIN_MENU_PATH
	)


func set_buttons_enabled(enabled: bool) -> void:
	retry_button.disabled = not enabled
	main_menu_button.disabled = not enabled
