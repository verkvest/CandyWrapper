extends Control
## Phone shell around the 144x144 playfield.
## The game stays pixel-perfect and integer-scaled. Touch buttons sit outside it.
## Portrait is the primary layout (larger stage, thumbs along the bottom).
## Landscape still keeps the stage clear and moves the buttons into the side columns.

const GAME_SCENE := "res://src/game/game.tscn"
const CREDITS_PATH := "res://THIRD_PARTY_LICENSES.md"
const CREAM := Color(1.0, 0.984314, 0.8, 1.0)
const BROWN := Color(0.455, 0.192, 0.004, 1.0)
const INK := Color(0.165, 0.094, 0.047, 1.0)
const ORANGE := Color(0.996, 0.616, 0.086, 1.0)

var bus := HoldBus.new()
var game: Node
var viewport: SubViewport
var stage: SubViewportContainer
var frame: ColorRect
var name_label: Label
var credits_btn: Button
var left_btn: TouchButton
var right_btn: TouchButton
var jump_btn: TouchButton
var credits_panel: Control
var credits_body: RichTextLabel
var ui := 1.0
var _swipe_index := -999
var _swipe_origin := Vector2.ZERO
var _swipe_jump := false
var _shot_dir := ""


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	get_tree().root.size_changed.connect(_layout)
	_layout()
	var args := OS.get_cmdline_user_args()
	var shot := args.find("--screenshot")
	if shot >= 0 and shot + 1 < args.size():
		_shot_dir = args[shot + 1]
		_run_shots()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED or what == NOTIFICATION_APPLICATION_RESUMED:
		_layout()


func _build() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = CREAM
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	frame = ColorRect.new()
	frame.color = INK
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)

	viewport = SubViewport.new()
	viewport.size = Vector2i(144, 144)
	viewport.transparent_bg = false
	viewport.disable_3d = true
	viewport.handle_input_locally = false
	viewport.gui_disable_input = true
	viewport.physics_object_picking = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.snap_2d_transforms_to_pixel = true
	viewport.snap_2d_vertices_to_pixel = true
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	game = load(GAME_SCENE).instantiate()
	viewport.add_child(game)

	stage = SubViewportContainer.new()
	stage.stretch = true
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stage.add_child(viewport)
	add_child(stage)

	name_label = Label.new()
	name_label.text = "Liltkin"
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.add_theme_color_override("font_color", BROWN)
	add_child(name_label)

	credits_btn = Button.new()
	credits_btn.text = "Credits"
	credits_btn.focus_mode = Control.FOCUS_NONE
	credits_btn.pressed.connect(func() -> void: _set_credits(true))
	add_child(credits_btn)

	left_btn = TouchButton.new()
	left_btn.setup("left", "left", bus)
	add_child(left_btn)
	right_btn = TouchButton.new()
	right_btn.setup("right", "right", bus)
	add_child(right_btn)
	jump_btn = TouchButton.new()
	jump_btn.setup("jump", "jump", bus)
	add_child(jump_btn)

	_build_credits()


func _build_credits() -> void:
	credits_panel = Control.new()
	credits_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	credits_panel.visible = false
	credits_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	credits_panel.z_index = 20
	add_child(credits_panel)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.1, 0.05, 0.02, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	credits_panel.add_child(dim)

	var card := ColorRect.new()
	card.name = "Card"
	card.color = CREAM
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	credits_panel.add_child(card)

	var title := Label.new()
	title.name = "Title"
	title.text = "Credits & licenses"
	title.add_theme_color_override("font_color", INK)
	card.add_child(title)

	credits_body = RichTextLabel.new()
	credits_body.name = "Body"
	credits_body.bbcode_enabled = false
	credits_body.scroll_active = true
	credits_body.selection_enabled = true
	credits_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credits_body.add_theme_color_override("default_color", INK)
	credits_body.text = _credits_text()
	card.add_child(credits_body)

	var close := Button.new()
	close.name = "Close"
	close.text = "Close"
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(func() -> void: _set_credits(false))
	card.add_child(close)


func _credits_text() -> String:
	if FileAccess.file_exists(CREDITS_PATH):
		var f := FileAccess.open(CREDITS_PATH, FileAccess.READ)
		if f:
			var text := f.get_as_text()
			f.close()
			if not text.is_empty():
				return text
	return "Liltkin\nA mobile port of the MIT-licensed game by Harmony Honey Monroe.\nSee THIRD_PARTY_LICENSES.md."


func _set_credits(open: bool) -> void:
	credits_panel.visible = open
	if game:
		game.process_mode = Node.PROCESS_MODE_DISABLED if open else Node.PROCESS_MODE_INHERIT
	if open:
		bus.release_all()
		_end_swipe()


func _safe_rect() -> Rect2:
	var win := Rect2(Vector2.ZERO, Vector2(get_window().size))
	var raw := Rect2(DisplayServer.get_display_safe_area())
	var safe := raw.intersection(win)
	if safe.size.x < 64.0 or safe.size.y < 64.0:
		safe = win
	if OS.has_feature("mobile"):
		ui = clampf(minf(win.size.x, win.size.y) / 390.0, 0.85, 8.0)
		var top_inset := safe.position.y
		var bot_inset := win.end.y - safe.end.y
		var min_top := 28.0 * ui
		var min_bot := 16.0 * ui
		if top_inset < min_top:
			var add := min_top - top_inset
			safe.position.y += add
			safe.size.y -= add
		if bot_inset < min_bot:
			safe.size.y -= min_bot - bot_inset
	if safe.size.y < 64.0:
		safe = win
	return safe


func _layout() -> void:
	if stage == null:
		return
	var safe := _safe_rect()
	ui = clampf(minf(safe.size.x, safe.size.y) / 390.0, 0.85, 8.0)
	if safe.size.y >= safe.size.x:
		_layout_portrait(safe)
	else:
		_layout_landscape(safe)
	_layout_credits(safe)
	name_label.add_theme_font_size_override("font_size", int(maxf(18.0, 22.0 * ui)))
	credits_btn.add_theme_font_size_override("font_size", int(maxf(16.0, 18.0 * ui)))
	left_btn.ui = ui
	right_btn.ui = ui
	jump_btn.ui = ui
	left_btn.queue_redraw()
	right_btn.queue_redraw()
	jump_btn.queue_redraw()


func _layout_portrait(safe: Rect2) -> void:
	var top_h := 56.0 * ui
	var control_h := clampf(safe.size.y * 0.30, 170.0 * ui, 340.0 * ui)
	# Keep at least a 144-tall stage when the screen is short.
	var max_control := safe.size.y - top_h - 144.0
	if max_control > 96.0 * ui:
		control_h = minf(control_h, max_control)
	var top := safe.position.y
	name_label.position = Vector2(safe.position.x + 12.0 * ui, top + 8.0 * ui)
	name_label.size = Vector2(safe.size.x * 0.52, top_h - 10.0 * ui)
	var btn_w := 128.0 * ui
	var btn_h := top_h - 14.0 * ui
	credits_btn.position = Vector2(safe.end.x - 12.0 * ui - btn_w, top + 7.0 * ui)
	credits_btn.size = Vector2(btn_w, btn_h)

	var play := Rect2(
		safe.position.x,
		top + top_h,
		safe.size.x,
		safe.size.y - top_h - control_h
	)
	_place_stage(play)

	var side := minf(control_h * 0.58, safe.size.x * 0.24)
	var jump := minf(control_h * 0.72, safe.size.x * 0.36)
	var gap := 14.0 * ui
	var band_top := safe.end.y - control_h
	var y := band_top + (control_h - side) * 0.46
	var yj := band_top + (control_h - jump) * 0.40
	left_btn.position = Vector2(safe.position.x + 16.0 * ui, y)
	left_btn.size = Vector2(side, side)
	right_btn.position = Vector2(left_btn.position.x + side + gap, y)
	right_btn.size = Vector2(side, side)
	jump_btn.size = Vector2(jump, jump)
	jump_btn.position = Vector2(safe.end.x - 16.0 * ui - jump, yj)


func _layout_landscape(safe: Rect2) -> void:
	var top_h := 48.0 * ui
	var col := clampf(safe.size.x * 0.22, 120.0 * ui, 240.0 * ui)
	name_label.position = Vector2(safe.position.x + col + 8.0 * ui, safe.position.y + 6.0 * ui)
	name_label.size = Vector2(safe.size.x * 0.4, top_h - 8.0 * ui)
	var btn_w := 120.0 * ui
	credits_btn.position = Vector2(safe.end.x - col - btn_w - 8.0 * ui, safe.position.y + 4.0 * ui)
	credits_btn.size = Vector2(btn_w, top_h - 8.0 * ui)
	var play := Rect2(
		safe.position.x + col,
		safe.position.y + top_h,
		safe.size.x - col * 2.0,
		safe.size.y - top_h
	)
	_place_stage(play)
	var side := minf(col * 0.72, safe.size.y * 0.28)
	var jump := minf(col * 0.86, safe.size.y * 0.36)
	var gap := 12.0 * ui
	var stack := side * 2.0 + gap
	var y0 := safe.position.y + top_h + maxf(0.0, (safe.size.y - top_h - stack) * 0.55)
	left_btn.position = Vector2(safe.position.x + (col - side) * 0.5, y0)
	left_btn.size = Vector2(side, side)
	right_btn.position = Vector2(left_btn.position.x, y0 + side + gap)
	right_btn.size = Vector2(side, side)
	jump_btn.size = Vector2(jump, jump)
	jump_btn.position = Vector2(
		safe.end.x - col + (col - jump) * 0.5,
		safe.position.y + top_h + (safe.size.y - top_h - jump) * 0.55
	)


func _place_stage(area: Rect2) -> void:
	var scale := int(minf(area.size.x, area.size.y) / 144.0)
	if scale < 1:
		scale = 1
	var box := float(144 * scale)
	var origin := area.position + (area.size - Vector2(box, box)) * 0.5
	origin = Vector2(round(origin.x), round(origin.y))
	var border := maxf(2.0, round(2.0 * ui))
	frame.position = origin - Vector2(border, border)
	frame.size = Vector2(box, box) + Vector2(border * 2.0, border * 2.0)
	stage.position = origin
	stage.size = Vector2(box, box)


func _layout_credits(safe: Rect2) -> void:
	var card := credits_panel.get_node("Card") as ColorRect
	var margin := 16.0 * ui
	card.position = safe.position + Vector2(margin, margin)
	card.size = safe.size - Vector2(margin, margin) * 2.0
	var title := card.get_node("Title") as Label
	var close := card.get_node("Close") as Button
	var font_size := int(maxf(18.0, 20.0 * ui))
	title.add_theme_font_size_override("font_size", int(maxf(22.0, 26.0 * ui)))
	close.add_theme_font_size_override("font_size", font_size)
	credits_body.add_theme_font_size_override("normal_font_size", font_size)
	var pad := 16.0 * ui
	title.position = Vector2(pad, pad * 0.6)
	title.size = Vector2(card.size.x - pad * 2.0, 40.0 * ui)
	var close_h := maxf(52.0 * ui, 48.0)
	close.position = Vector2(pad, card.size.y - close_h - pad)
	close.size = Vector2(card.size.x - pad * 2.0, close_h)
	credits_body.position = Vector2(pad, title.position.y + title.size.y)
	credits_body.size = Vector2(card.size.x - pad * 2.0, close.position.y - credits_body.position.y - 8.0 * ui)


func _unhandled_input(event: InputEvent) -> void:
	if credits_panel.visible:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if _swipe_index == -999:
				_swipe_index = touch.index
				_swipe_origin = touch.position
				_swipe_jump = false
		elif touch.index == _swipe_index:
			_end_swipe()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index != _swipe_index:
			return
		var delta := drag.position - _swipe_origin
		var thr := 28.0 * ui
		bus.set_source("left", "swipe", delta.x < -thr)
		bus.set_source("right", "swipe", delta.x > thr)
		if delta.y < -thr * 1.25:
			_swipe_jump = true
		bus.set_source("jump", "swipe", _swipe_jump)


func _end_swipe() -> void:
	_swipe_index = -999
	_swipe_jump = false
	bus.set_source("left", "swipe", false)
	bus.set_source("right", "swipe", false)
	bus.set_source("jump", "swipe", false)


func _run_shots() -> void:
	await get_tree().process_frame
	await get_tree().create_timer(0.9).timeout
	_layout()
	await RenderingServer.frame_post_draw
	_save_shot("menu.png")
	_set_credits(true)
	await RenderingServer.frame_post_draw
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_save_shot("credits.png")
	_set_credits(false)
	await get_tree().process_frame
	Input.action_press("jump")
	await get_tree().process_frame
	Input.action_release("jump")
	await get_tree().create_timer(1.3).timeout
	_layout()
	await RenderingServer.frame_post_draw
	_save_shot("gameplay.png")
	get_tree().quit(0)


func _save_shot(file_name: String) -> void:
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	var img := get_viewport().get_texture().get_image()
	var path := _shot_dir.path_join(file_name)
	var err := img.save_png(path)
	print("screenshot ", path, " ", img.get_width(), "x", img.get_height(), " err=", err)
	if err != OK:
		get_tree().quit(1)


class HoldBus:
	var down := {"left": {}, "right": {}, "jump": {}}

	func set_source(action: String, source: String, pressed: bool) -> void:
		var bucket: Dictionary = down[action]
		var was_any := not bucket.is_empty()
		var had: bool = bool(bucket.get(source, false))
		if had == pressed:
			return
		if pressed:
			bucket[source] = true
		else:
			bucket.erase(source)
		var now_any := not bucket.is_empty()
		if now_any and not was_any:
			Input.action_press(action)
		elif was_any and not now_any:
			Input.action_release(action)

	func release_all() -> void:
		for action in down.keys():
			(down[action] as Dictionary).clear()
			Input.action_release(action)


class TouchButton extends Control:
	const CREAM := Color(1.0, 0.984314, 0.8, 1.0)
	const BROWN := Color(0.455, 0.192, 0.004, 1.0)
	const ORANGE := Color(0.996, 0.616, 0.086, 1.0)
	var action := ""
	var kind := ""
	var bus
	var held := false
	var pointer := -999
	var saw_touch := false
	var ui := 1.0

	func setup(button_action: String, button_kind: String, hold_bus) -> void:
		action = button_action
		kind = button_kind
		bus = hold_bus
		focus_mode = Control.FOCUS_NONE
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventScreenTouch:
			var touch := event as InputEventScreenTouch
			if touch.pressed and not held:
				saw_touch = true
				_press(touch.index)
				accept_event()
		elif event is InputEventMouseButton:
			var mouse := event as InputEventMouseButton
			if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT and not held and not saw_touch:
				_press(-2)
				accept_event()

	func _input(event: InputEvent) -> void:
		if not held:
			return
		if event is InputEventScreenTouch:
			var touch := event as InputEventScreenTouch
			if not touch.pressed and touch.index == pointer:
				_release()
		elif event is InputEventMouseButton:
			var mouse := event as InputEventMouseButton
			if not mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT and pointer == -2:
				_release()

	func _press(id: int) -> void:
		held = true
		pointer = id
		bus.set_source(action, "button", true)
		if action == "jump":
			Input.vibrate_handheld(12)
		queue_redraw()

	func _release() -> void:
		held = false
		pointer = -999
		bus.set_source(action, "button", false)
		queue_redraw()

	func _draw() -> void:
		var fill := ORANGE if held else BROWN
		var radius := maxf(8.0, minf(size.x, size.y) * 0.22)
		draw_rounded_rect(Rect2(Vector2.ZERO, size), radius, fill)
		var glyph := CREAM
		var c := size * 0.5
		var s := minf(size.x, size.y) * 0.22
		var w := maxf(4.0, minf(size.x, size.y) * 0.09)
		if kind == "jump":
			c.y -= size.y * 0.08
			draw_line(c + Vector2(-s, s * 0.35), c + Vector2(0, -s), glyph, w, true)
			draw_line(c + Vector2(0, -s), c + Vector2(s, s * 0.35), glyph, w, true)
			var font := ThemeDB.fallback_font
			var fsize := int(maxf(14.0, minf(size.y * 0.22, 28.0 * ui)))
			var label := "JUMP"
			var tw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, fsize).x
			draw_string(font, Vector2((size.x - tw) * 0.5, size.y - fsize * 0.55), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, glyph)
		elif kind == "left":
			draw_line(c + Vector2(s * 0.7, -s), c + Vector2(-s * 0.55, 0), glyph, w, true)
			draw_line(c + Vector2(-s * 0.55, 0), c + Vector2(s * 0.7, s), glyph, w, true)
		else:
			draw_line(c + Vector2(-s * 0.7, -s), c + Vector2(s * 0.55, 0), glyph, w, true)
			draw_line(c + Vector2(s * 0.55, 0), c + Vector2(-s * 0.7, s), glyph, w, true)

	func draw_rounded_rect(rect: Rect2, radius: float, color: Color) -> void:
		var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
		draw_rect(Rect2(rect.position.x + r, rect.position.y, rect.size.x - r * 2.0, rect.size.y), color)
		draw_rect(Rect2(rect.position.x, rect.position.y + r, rect.size.x, rect.size.y - r * 2.0), color)
		draw_circle(rect.position + Vector2(r, r), r, color)
		draw_circle(rect.position + Vector2(rect.size.x - r, r), r, color)
		draw_circle(rect.position + Vector2(r, rect.size.y - r), r, color)
		draw_circle(rect.position + Vector2(rect.size.x - r, rect.size.y - r), r, color)
