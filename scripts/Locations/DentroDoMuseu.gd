extends Node2D

var dialog_label = null
var dialog_open = false

func _ready():
	if has_node("VoltarButton"):
		$VoltarButton.pressed.connect(_on_voltar_button_pressed)

	$ButtonsContainer/Button1.pressed.connect(_show_dialog_chimarrao)

	for btn in $ButtonsContainer.get_children():
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _show_dialog_chimarrao():
	if dialog_open:
		return
	dialog_open = true

	var en_text = "Chimarrão is a traditional hot drink from southern Brazil, made by steeping yerba mate leaves in hot water and drinking it from a gourd with a metal straw. It is a symbol of friendship and culture in the region."
	var pt_text = "Chimarrão é uma bebida quente tradicional do sul do Brasil, feita com folhas de erva-mate em água quente e tomada em uma cuia com um canudo de metal. É um símbolo de amizade e cultura na região."
	var state = { "is_en": true }

	var dialog_data = [
		{
			"name": "Spark",
			"text": en_text,
			"portrait": "res://assets/characters/spark_reborn_face.png"
		}
	]
	$UI/DialogBox.start_dialog(dialog_data)

	await get_tree().process_frame
	dialog_label = $UI/DialogBox.get_node("Panel/TextLabel")

	# CRIAR O BOTÃO DENTRO DO PANEL DA DIALOGBOX
	var toggle_btn = Button.new()
	toggle_btn.text = "*"
	toggle_btn.size = Vector2(32, 32)
	toggle_btn.position = Vector2($UI/DialogBox/Panel.size.x - 48, 8) # Fica no canto superior direito do painel
	toggle_btn.focus_mode = Control.FOCUS_NONE
	toggle_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$UI/DialogBox/Panel.add_child(toggle_btn)
	toggle_btn.move_to_front()

	toggle_btn.pressed.connect(func():
		state.is_en = !state.is_en
		if dialog_label:
			dialog_label.text = en_text if state.is_en else pt_text
	)

	$UI/DialogBox.dialog_ended.connect(func():
		dialog_open = false
		if is_instance_valid(toggle_btn):
			toggle_btn.queue_free()
	)

func _on_voltar_button_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Museu.tscn")
	GameManager.current_location = "Museu"
