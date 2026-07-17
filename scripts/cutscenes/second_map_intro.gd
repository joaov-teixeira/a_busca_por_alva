extends Control


@export_category("Lore")

@export var lore_title: String = ""

@export_multiline var lore_text: String = (
	"O Rei Demônio capturou a Alva"
	+ " 
em seus ultimos esforços, ela protegeu todo o reino e lhe transferiu parte da sua força"
)

@export var lore_texture: Texture2D


@export_category("Next Scene")

@export_file("*.tscn")
var second_map_path: String = (
	"res://scenes/map/second_level.tscn"
)


@onready var lore_image: TextureRect = (
	get_node_or_null("%LoreImage") as TextureRect
)

@onready var title_label: Label = (
	get_node_or_null("%TitleLabel") as Label
)

@onready var lore_label: Label = (
	get_node_or_null("%LoreLabel") as Label
)

@onready var continue_button: Button = (
	get_node_or_null("%ContinueButton") as Button
)


var changing_scene: bool = false


func _ready() -> void:
	if not validate_nodes():
		print_tree_pretty()
		return

	print("Cena de introdução do mapa 2 carregada.")

	title_label.text = lore_title
	lore_label.text = lore_text

	if lore_texture != null:
		lore_image.texture = lore_texture

	if not continue_button.pressed.is_connected(
		_on_continue_button_pressed
	):
		continue_button.pressed.connect(
			_on_continue_button_pressed
		)

	continue_button.grab_focus()


func validate_nodes() -> bool:
	var valid: bool = true

	if lore_image == null:
		push_error(
			"LoreImage não foi encontrado. "
			+ "Marque o nó como Access as Unique Name."
		)
		valid = false

	if title_label == null:
		push_error(
			"TitleLabel não foi encontrado. "
			+ "Marque o nó como Access as Unique Name."
		)
		valid = false

	if lore_label == null:
		push_error(
			"LoreLabel não foi encontrado. "
			+ "Marque o nó como Access as Unique Name."
		)
		valid = false

	if continue_button == null:
		push_error(
			"ContinueButton não foi encontrado. "
			+ "Marque o nó como Access as Unique Name."
		)
		valid = false

	return valid


func _unhandled_input(event: InputEvent) -> void:
	if changing_scene:
		return

	if continue_button == null:
		return

	var accept_pressed: bool = event.is_action_pressed(
		"ui_accept"
	)

	var interact_pressed: bool = (
		InputMap.has_action("interact")
		and event.is_action_pressed("interact")
	)

	if accept_pressed or interact_pressed:
		get_viewport().set_input_as_handled()
		open_second_map()


func _on_continue_button_pressed() -> void:
	open_second_map()


func open_second_map() -> void:
	if changing_scene:
		return

	if second_map_path.is_empty():
		push_error(
			"O caminho do segundo mapa está vazio."
		)
		return

	if not ResourceLoader.exists(second_map_path):
		push_error(
			"O segundo mapa não foi encontrado: "
			+ second_map_path
		)
		return

	changing_scene = true
	continue_button.disabled = true

	SceneTransition.change_scene(
		second_map_path
	)
