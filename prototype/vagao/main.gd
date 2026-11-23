extends Control

# Protótipo 0.1: interface jogável sem assets externos.
const INK := Color("#e8dfcb")
const GOLD := Color("#c6a476")
const DARK := Color("#151c27")
const PANEL := Color("#29303b")
const GOOD := Color("#91c4a5")
var font: Font
var active := ""
var message := "O condutor se afastou. Preciso encontrar meu estojo antes de sair."
var inventory: Array[String] = []
var journal: Array[String] = []
var dials := [0, 0, 0]
var case_open := false
var drawer_open := false
var isolated := false
var door_open := false
var reflection_seen := false
var box_open := false
var hotspots := {
	"assento": Rect2(110, 385, 240, 160),
	"mesa": Rect2(440, 350, 150, 115),
	"bagageiro": Rect2(130, 125, 340, 90),
	"janela": Rect2(665, 135, 230, 245),
	"armario": Rect2(975, 320, 180, 210),
	"porta": Rect2(1000, 95, 145, 210)
}

func _ready() -> void:
	font = ThemeDB.fallback_font
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), DARK)
	# Cenário provisório desenhado em camadas
	draw_rect(Rect2(0, 70, 1280, 500), Color("#30333b"))
	draw_rect(Rect2(0, 545, 1280, 95), Color("#4a3333"))
	draw_rect(Rect2(0, 70, 1280, 45), Color("#59463a"))
	for x in [80, 390, 625, 925, 1190]:
		draw_rect(Rect2(x, 100, 12, 445), Color("#866a50"))
	draw_rect(hotspots["janela"], Color("#253d53"))
	for i in range(9):
		var xx = 677 + i * 23
		draw_line(Vector2(xx, 145), Vector2(xx - 30, 366), Color("#7890a0", 0.3), 2)
	draw_rect(hotspots["assento"], Color("#623b46"))
	draw_rect(Rect2(135, 407, 175, 26), Color("#885560"))
	draw_rect(hotspots["mesa"], Color("#71513c"))
	draw_rect(hotspots["bagageiro"], Color("#655142"))
	draw_rect(hotspots["armario"], Color("#57473b"))
	draw_rect(hotspots["porta"], Color("#463a39"))
	draw_rect(Rect2(1105, 192, 12, 12), GOLD)
	for key in hotspots:
		var r: Rect2 = hotspots[key]
		draw_rect(r, GOLD, false, 2)
		draw_label(key.capitalize(), r.position + Vector2(8, 24), 16)
	draw_rect(Rect2(0, 0, 1280, 65), Color("#111822"))
	draw_label("O ARQUIVO DAS HORAS PERDIDAS  |  PRÓLOGO: PRIMEIRO VAGÃO", Vector2(24, 40), 23)
	draw_rect(Rect2(0, 640, 1280, 80), Color("#141a24"))
	draw_label("INVENTÁRIO: " + (", ".join(inventory) if not inventory.is_empty() else "(vazio)"), Vector2(22, 670), 16)
	draw_label("DIÁRIO [D]     REINICIAR [R]     ESC: fechar painel", Vector2(22, 702), 15)
	draw_label(message, Vector2(25, 605), 17)
	if active != "":
		draw_rect(Rect2(210, 110, 860, 435), Color("#0c111a", 0.96))
		draw_rect(Rect2(210, 110, 860, 435), GOLD, false, 2)
		draw_label(_title(), Vector2(245, 154), 26)
		_draw_panel()

func draw_label(t: String, pos: Vector2, s: int = 18, color: Color = INK) -> void:
	draw_string(font, pos, t, HORIZONTAL_ALIGNMENT_LEFT, -1, s, color)

func _title() -> String:
	match active:
		"assento": return "Assento de Elara"
		"mesa": return "Mesa lateral"
		"bagageiro": return "Guarda-volumes ferroviário"
		"janela": return "Janela e cortina"
		"armario": return "Armário de manutenção"
		"porta": return "Porta do corredor"
		"diario": return "Diário de Elara"
		"estojo": return "Estojo de documentos"
		"fim": return "Fim do protótipo 0.1"
	return ""

func _draw_panel() -> void:
	match active:
		"assento":
			draw_label("Minha bolsa está aqui. O estojo não está.", Vector2(250, 205))
			_option("Pegar comprovante de depósito", 0)
			_option("Pegar grampo metálico", 1)
		"mesa":
			draw_label("Formulário: mão = MALA; documentos = ENVELOPE; autorizada = CHAVE.", Vector2(250, 210), 17)
			_option("Registrar instruções no diário", 0)
		"bagageiro":
			if box_open:
				draw_label("Compartimento aberto. O estojo está dentro.", Vector2(250, 210))
				_option("Recolher estojo", 0)
			else:
				draw_label("Três discos: escolha os símbolos e tente abrir.", Vector2(250, 202))
				var symbols := ["Mala", "Envelope", "Chave", "Estrela"]
				for i in range(3):
					draw_label("Disco %d: %s" % [i+1, symbols[dials[i]]], Vector2(270, 253 + i * 49))
				_option("Girar disco 1", 0)
				_option("Girar disco 2", 1)
				_option("Girar disco 3", 2)
				_option("Testar combinação", 3)
		"janela":
			draw_label("A chuva escorre pelo vidro. Uma etiqueta está presa na moldura.", Vector2(250, 205), 17)
			_option("Usar grampo para puxar etiqueta", 0)
			_option("Observar reflexo", 1)
		"armario":
			draw_label("Gavetas de manutenção numeradas. Uma delas é M-17.", Vector2(250, 205))
			_option("Abrir gaveta M-17", 0)
		"porta":
			draw_label("Trava pneumática. É preciso abrir o painel e isolar a pressão.", Vector2(250, 205), 17)
			draw_label("Pressão: " + ("SEGURA" if isolated else "ALTA"), Vector2(250, 246), 19, GOOD if isolated else GOLD)
			_option("Abrir painel com ferramenta", 0)
			_option("Isolar pressão", 1)
			_option("Acionar liberação", 2)
			_option("Atravessar porta", 3)
		"estojo":
			draw_label("Uma fotografia, uma carta incompleta e um medalhão de latão.", Vector2(250, 205), 17)
			_option("Examinar fotografia", 0)
			_option("Ler carta", 1)
			_option("Guardar medalhão", 2)
		"diario":
			if journal.is_empty():
				draw_label("Nenhuma observação registrada.", Vector2(250, 205))
			for i in range(min(journal.size(), 8)):
				draw_label("- " + journal[i], Vector2(250, 205 + i * 35), 16)
		"fim":
			draw_label("Você destravou a saída do vagão!", Vector2(250, 210), 22, GOOD)
			draw_label("Próxima versão: corredor, animações e arte em camadas.", Vector2(250, 260), 18)
	draw_label("Clique fora do painel ou pressione ESC para voltar.", Vector2(245, 515), 15, GOLD)

func _option(t: String, i: int) -> void:
	var y := 310 + i * 46
	if active == "bagageiro" and not box_open:
		y = 416 + i * 27
	if active == "porta":
		y = 300 + i * 47
	draw_rect(Rect2(260, y - 23, 650, 34), PANEL)
	draw_label("%d. %s" % [i + 1, t], Vector2(275, y), 17)

func _option_at(pos: Vector2) -> int:
	var start := 287
	var step := 46
	if active == "bagageiro" and not box_open:
		start = 393
		step = 27
	if active == "porta":
		start = 277
		step = 47
	for i in range(4):
		if Rect2(260, start + i * step, 650, 35).has_point(pos):
			return i
	return -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var p: Vector2 = event.position
		if active != "":
			if not Rect2(210, 110, 860, 435).has_point(p):
				active = ""
			else:
				var i := _option_at(p)
				if i >= 0:
					_choose(i)
		else:
			for key in hotspots:
				if hotspots[key].has_point(p):
					active = key
					break
		queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		active = ""
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_D:
			active = "diario"
		elif event.keycode == KEY_R:
			inventory.clear()
			journal.clear()
			dials = [0, 0, 0]
			case_open = false
			drawer_open = false
			isolated = false
			door_open = false
			reflection_seen = false
			box_open = false
			active = ""
			message = "Recomeçamos. Preciso recuperar meu estojo."
	queue_redraw()

func _add_item(t: String) -> void:
	if not inventory.has(t):
		inventory.append(t)

func _note(t: String) -> void:
	if not journal.has(t):
		journal.append(t)

func _choose(i: int) -> void:
	match active:
		"assento":
			if i == 0:
				_add_item("Comprovante")
				message = "Comprovante: bagagem de mão, documentos pessoais, retirada autorizada."
			elif i == 1:
				_add_item("Grampo")
				message = "Um grampo de metal preso ao assento. Pode servir para alcançar algo."
		"mesa":
			if i == 0:
				_note("Classificação: mala / envelope / chave.")
				message = "Anotei a correspondência dos símbolos."
		"bagageiro":
			if box_open:
				if i == 0:
					_add_item("Estojo")
					active = "estojo"
					message = "Encontrei meu estojo."
			elif i < 3:
				dials[i] = (dials[i] + 1) % 4
			elif i == 3:
				if inventory.has("Comprovante") and dials == [0, 1, 2]:
					box_open = true
					message = "Os pinos recuam. O guarda-volumes abriu."
				else:
					message = "A trava não cede. Preciso relacionar o comprovante ao formulário."
		"janela":
			if i == 0:
				if inventory.has("Grampo"):
					_add_item("Etiqueta M-17")
					message = "Consegui retirar a etiqueta: M-17."
				else:
					message = "Está fora do alcance. Preciso de algo fino para puxá-la."
			elif i == 1:
				if not reflection_seen:
					reflection_seen = true
					_note("Meu reflexo pareceu atrasar um instante.")
					message = "Por um segundo, meu reflexo demorou a acompanhar meu movimento."
				else:
					message = "Agora o vidro reflete normalmente."
		"armario":
			if i == 0:
				if inventory.has("Etiqueta M-17"):
					drawer_open = true
					_add_item("Ferramenta")
					message = "A gaveta M-17 contém a ferramenta de manutenção."
				else:
					message = "Há muitas gavetas. Preciso identificar a caixa correta."
		"porta":
			if i == 0:
				if inventory.has("Ferramenta"):
					case_open = true
					message = "Retirei a tampa do painel de segurança."
				else:
					message = "Preciso de uma ferramenta para remover a tampa."
			elif i == 1:
				if case_open:
					isolated = true
					message = "A válvula fechou. O indicador caiu para a faixa segura."
				else:
					message = "A válvula fica atrás da tampa."
			elif i == 2:
				if isolated:
					door_open = true
					message = "A trava se recolheu. A porta está aberta."
				else:
					message = "O mecanismo permanece bloqueado enquanto houver pressão."
			elif i == 3:
				if door_open:
					active = "fim"
				else:
					message = "A porta ainda está travada."
		"estojo":
			if i == 0:
				_note("Fotografia antiga de uma estação. Verso: Onde tudo começou.")
				message = "A estação da foto parece familiar, mas não sei por quê."
			elif i == 1:
				_note("Carta: procure aquilo que permanece quando tudo desaparece.")
				message = "A assinatura está ilegível."
			elif i == 2:
				_add_item("Medalhão")
				message = "O medalhão de latão traz círculos entrecruzados."
	queue_redraw()
