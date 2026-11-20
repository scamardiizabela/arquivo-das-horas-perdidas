extends Control
## Ilustração vetorial temporária, substituível por camadas de arte definitiva.
signal hotspot_selected(action: String)
var location := 0
var clock_repaired := false
var mist_phase := 0.0
const INK := Color("#101b28")
const STONE := Color("#304354")
const BRASS := Color("#c7a46a")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)

func _process(delta: float) -> void:
	mist_phase += delta * 0.22
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 0 or s.y <= 0: return
	draw_rect(Rect2(Vector2.ZERO,s),INK)
	var scale_x := s.x / 900.0
	var scale_y := s.y / 520.0
	draw_set_transform(Vector2.ZERO,0,Vector2(scale_x,scale_y))
	# Céu e vitrais
	for i in 6:
		var x := 55.0 + i * 150.0
		draw_rect(Rect2(x,50,90,245),Color("#263e50"))
		draw_rect(Rect2(x+7,58,76,226),Color("#426171"))
		draw_line(Vector2(x+45,58),Vector2(x+45,285),Color("#192b37"),7)
		draw_line(Vector2(x+7,167),Vector2(x+83,167),Color("#192b37"),7)
	# Colunas e piso em perspectiva
	for i in 7:
		var x := float(i)*150.0
		draw_rect(Rect2(x,0,25,355),STONE)
		draw_rect(Rect2(x-8,338,42,22),Color("#56606a"))
	draw_colored_polygon(PackedVector2Array([Vector2(0,350),Vector2(900,350),Vector2(900,520),Vector2(0,520)]),Color("#36414a"))
	for i in 9:
		draw_line(Vector2(450,350),Vector2(float(i)*125-50,520),Color("#647079"),2)
	for i in 4:
		var y := 372.0 + i*i*10.0
		draw_line(Vector2(0,y),Vector2(900,y),Color("#69717a"),2)
	# Silhuetas por local
	if location == 0:
		_draw_clock(Vector2(452,132),75)
		_draw_bench(Vector2(165,340))
		_draw_luggage(Vector2(750,366))
	elif location == 1:
		_draw_bench(Vector2(340,370))
		_draw_luggage(Vector2(655,395))
		draw_rect(Rect2(125,145,120,135),Color("#7a644d"))
		draw_rect(Rect2(135,155,100,115),Color("#b59b72"))
	else:
		draw_rect(Rect2(100,315,700,105),Color("#56483c"))
		draw_rect(Rect2(470,160,200,165),Color("#76634a"))
		for i in 3:
			draw_circle(Vector2(510+i*58,235),23,BRASS)
	# Neblina em camadas, com movimento leve
	for i in 5:
		var offset := sin(mist_phase+float(i))*28.0
		draw_circle(Vector2(120+i*185+offset,400+float(i%2)*35),130,Color(0.67,0.77,0.81,0.055))
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _draw_clock(center: Vector2, radius: float) -> void:
	draw_circle(center,radius+11,Color("#584a3b"))
	draw_circle(center,radius,BRASS)
	draw_circle(center,radius-8,Color("#d4c8aa"))
	for i in 12:
		var a := float(i)*TAU/12.0
		draw_line(center+Vector2(sin(a),-cos(a))*52,center+Vector2(sin(a),-cos(a))*62,INK,3)
	draw_line(center,center+Vector2(0,-43 if clock_repaired else -35),INK,5)
	draw_line(center,center+Vector2(35,0 if clock_repaired else 15),INK,4)
	draw_circle(center,5,INK)

func _draw_bench(p: Vector2) -> void:
	draw_rect(Rect2(p.x,p.y,205,24),Color("#a18056"))
	draw_rect(Rect2(p.x+8,p.y-54,190,43),Color("#806244"))
	draw_line(p+Vector2(20,24),p+Vector2(14,75),INK,9)
	draw_line(p+Vector2(186,24),p+Vector2(192,75),INK,9)

func _draw_luggage(p: Vector2) -> void:
	draw_rect(Rect2(p.x,p.y,85,65),Color("#70513d"))
	draw_rect(Rect2(p.x+10,p.y-13,65,13),BRASS)
	draw_line(p+Vector2(25,0),p+Vector2(25,65),BRASS,5)
	draw_line(p+Vector2(60,0),p+Vector2(60,65),BRASS,5)

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT): return
	var p: Vector2 = event.position / size * Vector2(900,520)
	if location == 0:
		if p.distance_to(Vector2(452,132)) < 95: hotspot_selected.emit("clock")
		elif Rect2(140,275,260,155).has_point(p): hotspot_selected.emit("bench")
	elif location == 1:
		if Rect2(290,270,280,190).has_point(p): hotspot_selected.emit("floor")
		elif Rect2(115,140,140,155).has_point(p): hotspot_selected.emit("poster")
	elif location == 2:
		if Rect2(465,155,220,180).has_point(p): hotspot_selected.emit("cabinet")
		elif Rect2(100,315,700,110).has_point(p): hotspot_selected.emit("counter")
