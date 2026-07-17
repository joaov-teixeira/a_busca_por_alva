extends Control

@onready var new_game_button: Button = (
	$CenterContainer/MenuContainer/NewGame
)

@onready var continue_button: Button = (
	$CenterContainer/MenuContainer/Continue
)

@onready var options_button: Button = (
	$CenterContainer/MenuContainer/Options
)

@onready var exit_button: Button = (
	$CenterContainer/MenuContainer/Exit
)

@onready var message_label: Label = $MessageLabel


func _ready() -> void:
	message_label.visible = false

	# Será habilitado quando criarmos o sistema de salvamento.
	continue_button.disabled = true

	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	set_buttons_enabled(false)

	SceneTransition.change_scene(
		"res://scenes/map/initial_level.tscn"
	)


func _on_continue_pressed() -> void:
	message_label.text = (
		"O sistema de salvamento ainda não foi implementado."
	)
	message_label.visible = true


func _on_options_pressed() -> void:
	message_label.text = "Opções ainda não implementadas."
	message_label.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func set_buttons_enabled(enabled: bool) -> void:
	new_game_button.disabled = not enabled
	options_button.disabled = not enabled
	exit_button.disabled = not enabled
