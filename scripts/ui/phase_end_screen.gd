extends CanvasLayer

signal closed

@onready var root: Control = $Root
@onready var message_label: Label = $Root/CenterContainer/VBoxContainer/MessageLabel
@onready var back_button: Button = $Root/CenterContainer/VBoxContainer/BackButton


func _ready() -> void:
	root.visible = false
	back_button.pressed.connect(_on_back_button_pressed)


func show_message(message: String = "Fase não implementada") -> void:
	message_label.text = message
	root.visible = true
	back_button.grab_focus()


func hide_message() -> void:
	root.visible = false


func _on_back_button_pressed() -> void:
	hide_message()
	closed.emit()
