extends CanvasLayer

@onready var hearts_label: Label = $LeftHUD/VBoxContainer/HeartsLabel
@onready var courage_label: Label = $LeftHUD/VBoxContainer/CourageLabel
@onready var courage_bar: ProgressBar = $LeftHUD/VBoxContainer/CourageBar

@onready var message_panel: PanelContainer = $MessagePanel
@onready var message_label: Label = $MessagePanel/MarginContainer/MessageLabel

var max_health: int = 3
var health: int = 3

var max_courage: float = 100.0
var courage: float = 100.0


func _ready() -> void:
	update_health(health)
	update_courage(courage)
	
	message_panel.visible = false


func update_health(new_health: int) -> void:
	health = clampi(new_health, 0, max_health)

	var hearts_text := ""

	for i in range(max_health):
		if i < health:
			hearts_text += "♥ "
		else:
			hearts_text += "♡ "

	hearts_label.text = hearts_text.strip_edges()


func update_courage(new_courage: float) -> void:
	courage = clampf(new_courage, 0.0, max_courage)

	courage_bar.min_value = 0
	courage_bar.max_value = max_courage
	courage_bar.value = courage

	courage_label.text = "Coragem: %d/%d" % [int(courage), int(max_courage)]


func damage_player(amount: int = 1) -> void:
	update_health(health - amount)


func heal_player(amount: int = 1) -> void:
	update_health(health + amount)


func decrease_courage(amount: float) -> void:
	update_courage(courage - amount)


func increase_courage(amount: float) -> void:
	update_courage(courage + amount)

func show_message(message: String, duration: float = 2.0) -> void:
	message_label.text = message
	message_panel.modulate.a = 1.0
	message_panel.visible = true

	await get_tree().create_timer(duration).timeout

	if not message_panel.visible:
		return

	var tween := create_tween()
	tween.tween_property(message_panel, "modulate:a", 0.0, 0.25)

	await tween.finished

	message_panel.visible = false
	message_panel.modulate.a = 1.0


func hide_message() -> void:
	message_panel.visible = false
	message_panel.modulate.a = 1.0
