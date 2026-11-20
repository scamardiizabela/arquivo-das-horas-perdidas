extends Control

# Protótipo vertical: exploração, inventário, dependências, puzzle e persistência.
const SAVE_PATH := "user://vespera_save.json"
const BG := Color("111a27")
const GOLD := Color("d5b783")
const TEXT := Color("f0e7d7")
const SCENES := ["Plataforma", "Sala de espera", "Bilheteria"]
var current_scene := 0
var inventory: Array[String] = []
var flags := {"gear_1": false, "gear_2": false, "clock": false, "ticket": false, "cabinet": false}
var dialog := "O trem partiu. O relógio da estação marca 00:13."
var puzzle_open := false
var rings := [0, 0, 0]
var symbols := ["☾", "✦", "☼", "◇"]
var status_label: Label
var inventory_bar: HBoxContainer
var scene_content: VBoxContainer
var puzzle_panel: PanelContainer
var scene_title: Label
var main_buttons: VBoxContainer
var station_view: Control

func _ready() -> void:
	_build_ui()
	_load_game()
	_refresh()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)
	var header := HBoxContainer.new()
	root.add_child(header)
	var title := _label("O ARQUIVO DAS HORAS PERDIDAS", 24, GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(_button("Salvar", _save_game))
	header.add_child(_button("Reiniciar", _reset_game))
	root.add_child(HSeparator.new())
	scene_title = _label("", 31, TEXT)
	root.add_child(scene_title)
	var desc := _label("VESPERA • CAPÍTULO 1: A CARTA IMPOSSÍVEL", 15, GOLD)
	root.add_child(desc)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 22)
	root.add_child(body)
	var left := PanelContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(left)
	var center := MarginContainer.new()
	center.add_theme_constant_override("margin_left", 24)
	center.add_theme_constant_override("margin_top", 24)
	left.add_child(center)
	station_view = Control.new()
	station_view.set_script(preload("res://scripts/station_view.gd"))
	station_view.custom_minimum_size = Vector2(0, 350)
	station_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	station_view.hotspot_selected.connect(_on_hotspot)
	center.add_child(station_view)
	scene_content = VBoxContainer.new()
	scene_content.add_theme_constant_override("separation", 16)
	left.add_child(scene_content)
	scene_content.visible = false
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(340, 0)
	body.add_child(right)
	right.add_child(_label("EXPLORAR", 19, GOLD))
	main_buttons = VBoxContainer.new()
	main_buttons.add_theme_constant_override("separation", 10)
	right.add_child(main_buttons)
	puzzle_panel = PanelContainer.new()
	puzzle_panel.visible = false
	right.add_child(puzzle_panel)
	root.add_child(HSeparator.new())
	status_label = _label("", 18, TEXT)
	status_label.custom_minimum_size.y = 48
	root.add_child(status_label)
	root.add_child(_label("INVENTÁRIO  •  Toque nos objetos para investigar", 15, GOLD))
	inventory_bar = HBoxContainer.new()
	inventory_bar.custom_minimum_size.y = 55
	root.add_child(inventory_bar)

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _button(value: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = value
	b.custom_minimum_size = Vector2(0, 48)
	b.add_theme_font_size_override("font_size", 18)
	b.pressed.connect(callback)
	return b

func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _refresh() -> void:
	_clear(scene_content)
	_clear(main_buttons)
	_clear(inventory_bar)
	scene_title.text = SCENES[current_scene]
	station_view.location = current_scene
	station_view.clock_repaired = flags["clock"]
	station_view.queue_redraw()
	status_label.text = dialog
	var scene_descriptions := [
		"A névoa encobre os trilhos. Um relógio monumental permanece imóvel. A estação parece abandonada.",
		"Bancos vazios, uma mala esquecida e um cartaz antigo. Há algo sob uma das tábuas.",
		"Atrás do balcão, um armário de latão tem três discos com símbolos. A porta está lacrada."
	]
	scene_content.add_child(_label(scene_descriptions[current_scene], 22, TEXT))
	scene_content.add_child(_label("PONTOS DE INTERESSE", 16, GOLD))
	match current_scene:
		0:
			main_buttons.add_child(_button("Examinar relógio", _inspect_clock))
			main_buttons.add_child(_button("Examinar banco da plataforma", _inspect_bench))
		1:
			main_buttons.add_child(_button("Investigar tábua solta", _inspect_floor))
			main_buttons.add_child(_button("Examinar cartaz", _inspect_poster))
		2:
			main_buttons.add_child(_button("Examinar armário de símbolos", _open_puzzle))
			main_buttons.add_child(_button("Examinar balcão", _inspect_counter))
	main_buttons.add_child(HSeparator.new())
	for i in SCENES.size():
		var target := i
		var nav := _button("Ir para: " + SCENES[i], func(): _go(target))
		nav.disabled = i == current_scene
		main_buttons.add_child(nav)
	for item in inventory:
		inventory_bar.add_child(_button(item, func(): _inspect_item(item)))
	if inventory.is_empty():
		inventory_bar.add_child(_label("Vazio", 17, TEXT))
	puzzle_panel.visible = puzzle_open
	if puzzle_open:
		_draw_puzzle()

func _on_hotspot(action: String) -> void:
	match action:
		"clock": _inspect_clock()
		"bench": _inspect_bench()
		"floor": _inspect_floor()
		"poster": _inspect_poster()
		"cabinet": _open_puzzle()
		"counter": _inspect_counter()

func _go(index: int) -> void:
	current_scene = index
	puzzle_open = false
	dialog = "Você entra em: " + SCENES[index] + "."
	_refresh()

func _collect(item: String) -> void:
	if not inventory.has(item):
		inventory.append(item)
	dialog = "Item coletado: " + item + "."
	_refresh()

func _inspect_bench() -> void:
	if not flags["gear_1"]:
		flags["gear_1"] = true
		_collect("Engrenagem pequena")
	else:
		_say("Há marcas de ferrugem no banco. Nada mais por aqui.")

func _inspect_floor() -> void:
	if not flags["gear_2"]:
		flags["gear_2"] = true
		_collect("Engrenagem grande")
	else:
		_say("A tábua já foi examinada.")

func _inspect_clock() -> void:
	if flags["clock"]:
		_say("O relógio funciona. Uma passagem antiga caiu de seu compartimento.")
	elif inventory.has("Engrenagem pequena") and inventory.has("Engrenagem grande"):
		inventory.erase("Engrenagem pequena")
		inventory.erase("Engrenagem grande")
		flags["clock"] = true
		flags["ticket"] = true
		inventory.append("Passagem com símbolos")
		_say("Você instala as duas engrenagens. O relógio avança e revela uma passagem: ESTRELA, LUA, SOL.")
	else:
		_say("Faltam duas engrenagens no mecanismo do relógio.")

func _inspect_poster() -> void:
	_say("O cartaz diz: 'Toda chegada é uma lembrança; toda partida, um esquecimento.'")

func _inspect_counter() -> void:
	_say("Uma inscrição no balcão: 'A ordem certa abre o que o tempo fechou.'")

func _inspect_item(item: String) -> void:
	if item == "Passagem com símbolos":
		_say("A passagem mostra três figuras, nesta ordem: ESTRELA • LUA • SOL.")
	elif item == "Lente de revelação":
		_say("Uma lente de vidro azul. Sua superfície revela marcas invisíveis à luz comum.")
	else:
		_say("Você examina: " + item + ".")

func _open_puzzle() -> void:
	if flags["cabinet"]:
		_say("O armário está aberto. Você já retirou seu conteúdo.")
		return
	if not inventory.has("Passagem com símbolos"):
		_say("O armário possui três discos. Falta uma pista sobre a sequência correta.")
		return
	puzzle_open = true
	_say("Alinhe os três símbolos conforme a passagem encontrada no relógio.")

func _draw_puzzle() -> void:
	_clear(puzzle_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	puzzle_panel.add_child(column)
	column.add_child(_label("ARMÁRIO DE LATÃO", 17, GOLD))
	var row := HBoxContainer.new()
	column.add_child(row)
	for i in 3:
		var slot := i
		row.add_child(_button(symbols[rings[i]], func(): _rotate(slot)))
	column.add_child(_button("Acionar mecanismo", _check_puzzle))
	column.add_child(_button("Fechar", func(): _close_puzzle()))

func _rotate(index: int) -> void:
	rings[index] = (rings[index] + 1) % symbols.size()
	_draw_puzzle()

func _check_puzzle() -> void:
	if rings == [1, 0, 2]:
		flags["cabinet"] = true
		puzzle_open = false
		inventory.append("Lente de revelação")
		inventory.append("Documento rasgado")
		_say("Os discos giram e o armário se abre! Você encontra uma lente azul e um documento rasgado. FIM DO PROTÓTIPO.")
		_save_game()
	else:
		_say("O mecanismo não responde. Verifique a ordem dos símbolos.")

func _close_puzzle() -> void:
	puzzle_open = false
	_refresh()

func _say(value: String) -> void:
	dialog = value
	_refresh()

func _save_game() -> void:
	var data := {"scene": current_scene, "inventory": inventory, "flags": flags, "rings": rings}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))
		dialog = "Progresso salvo neste dispositivo."
		status_label.text = dialog

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) != TYPE_DICTIONARY:
		return
	current_scene = clampi(int(data.get("scene", 0)), 0, SCENES.size() - 1)
	inventory.clear()
	for item in data.get("inventory", []):
		inventory.append(str(item))
	var saved_flags: Dictionary = data.get("flags", {})
	for key in flags.keys():
		flags[key] = bool(saved_flags.get(key, false))
	var saved_rings: Array = data.get("rings", [0, 0, 0])
	if saved_rings.size() == 3:
		rings = [int(saved_rings[0]), int(saved_rings[1]), int(saved_rings[2])]
	dialog = "Bem-vinda de volta a Vespera."

func _reset_game() -> void:
	current_scene = 0
	inventory.clear()
	flags = {"gear_1": false, "gear_2": false, "clock": false, "ticket": false, "cabinet": false}
	rings = [0, 0, 0]
	puzzle_open = false
	dialog = "O trem partiu. O relógio da estação marca 00:13."
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	_refresh()
