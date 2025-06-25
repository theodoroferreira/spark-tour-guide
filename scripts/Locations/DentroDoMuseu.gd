extends Node2D

var dialog_label = null
var dialog_open = false

func _ready():
	print("DentroDoMuseu.gd: _ready chamado")
	if has_node("VoltarButton"):
		print("VoltarButton encontrado")
		$VoltarButton.pressed.connect(_on_voltar_button_pressed)

	for i in range(1, 7):
		var btn_path = "Button%d" % i
		if $ButtonsContainer.has_node(btn_path):
			print("Botão encontrado:", btn_path)
		else:
			print("Botão NÃO encontrado:", btn_path)

	for idx in range(1, 7):
		var btn = $ButtonsContainer.get_node("Button%d" % idx)
		btn.pressed.connect(_on_button_pressed.bind(idx))

	for btn in $ButtonsContainer.get_children():
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _show_dialog(key: String):
	print("_show_dialog chamado com key:", key)
	if dialog_open or $UI/DialogBox.is_dialog_active or $UI/DialogBox.is_animating:
		print("Diálogo já está aberto ou animando, ignorando clique.")
		return
	dialog_open = true

	var text_map = {
		"chimarrao": {
			"en": "Chimarrão is a traditional hot drink from southern Brazil, made by steeping yerba mate leaves in hot water and drinking it from a gourd with a metal straw. It is a symbol of friendship and culture in the region.",
			"pt": "Chimarrão é uma bebida quente tradicional do sul do Brasil, feita com folhas de erva-mate em água quente e tomada em uma cuia com um canudo de metal. É um símbolo de amizade e cultura na região.",
			"portrait": "res://assets/characters/spark_face_dft_1.png"
		},
		"boitala": {
			"en": "Boitatá is a fiery serpent from Brazilian folklore. It's said to protect the forests from those who try to harm them.",
			"pt": "O Boitatá é uma serpente de fogo do folclore brasileiro. Dizem que protege as florestas contra quem tenta destruí-las.",
			"portrait": "res://assets/characters/spark_face_dft_1.png"
		},
		"chapeu": {
			"en": "A symbol of Gaúcho culture, this wide-brimmed hat is worn by men and women during festivals, horse rides, and daily life.",
			"pt": "Símbolo da cultura gaúcha, esse chapéu de aba larga é usado por homens e mulheres em festas, cavalgadas e no dia a dia.",
			"portrait": "res://assets/characters/spark_face_dft_1.png"
		},
		"bombacha": {
			"en": "The bombacha is a loose, comfortable pair of pants worn by gaúchos, perfect for horseback riding and farm work.",
			"pt": "A bombacha é uma calça larga e confortável usada por gaúchos, ideal para montar a cavalo e trabalhar no campo.",
			"portrait": "res://assets/characters/spark_face_dft_1.png"
		},
		"pilcha": {
			"en": "Part of the 'pilcha', the traditional gaúcho outfit includes a shirt, jacket, and a neck scarf, representing pride and tradition.",
			"pt": "Parte da pilcha, traje típico dos gaúchos, composta por camisa, jaqueta e lenço no pescoço, representando orgulho e tradição.",
			"portrait": "res://assets/characters/spark_face_dft_1.png"
		},
		"saci": {
			"en": "Saci is one of the most iconic characters in Brazilian folklore. He's a mischievous one-legged boy who wears a magical red cap and plays tricks, like hiding objects and creating little whirlwinds.",
			"pt": "O Saci é um dos personagens mais famosos do folclore brasileiro. É um menino travesso de uma perna só, que usa um gorro vermelho mágico e vive pregando peças, como esconder objetos e fazer redemoinhos de vento.",
			"portrait": "res://assets/characters/spark_face_dft_1.png"
		}
	}

	var entry = text_map.get(key, null)
	print("entry:", entry)
	if entry == null:
		dialog_open = false
		return

	var state = { "is_en": true }
	var en_text = entry.en
	var pt_text = entry.pt

	var dialog_data = [
		{
			"name": "Spark",
			"text": en_text,
			"portrait": "res://assets/characters/spark_face_dft_1.png"
		}
	]

	# Garantir que o sinal anterior foi desconectado
	if $UI/DialogBox.dialog_ended.is_connected(_on_dialog_ended):
		$UI/DialogBox.dialog_ended.disconnect(_on_dialog_ended)
	
	# Resetar DialogBox antes de iniciar
	$UI/DialogBox.reset()
	# Conectar o novo sinal
	$UI/DialogBox.dialog_ended.connect(_on_dialog_ended)
	$UI/DialogBox.start_dialog(dialog_data)

	print("Dialogo iniciado para:", key)
	print("DialogBox visible?", $UI/DialogBox.visible)
	print("Dialog queue:", $UI/DialogBox.dialog_queue)

	await get_tree().process_frame
	dialog_label = $UI/DialogBox.get_node("Panel/TextLabel")

	var toggle_btn = Button.new()
	toggle_btn.text = "*"
	toggle_btn.size = Vector2(32, 32)
	toggle_btn.position = Vector2($UI/DialogBox/Panel.size.x - 48, 8)
	toggle_btn.focus_mode = Control.FOCUS_NONE
	toggle_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$UI/DialogBox/Panel.add_child(toggle_btn)
	toggle_btn.move_to_front()

	toggle_btn.pressed.connect(func():
		state.is_en = !state.is_en
		if dialog_label:
			dialog_label.text = en_text if state.is_en else pt_text
	)

func _on_dialog_ended():
	dialog_open = false
	# Limpar o botão de toggle se ele ainda existir
	for child in $UI/DialogBox/Panel.get_children():
		if child is Button and child.text == "*":
			child.queue_free()
			break

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# Garantir que o sinal é desconectado quando o nó é destruído
		if $UI/DialogBox and $UI/DialogBox.dialog_ended.is_connected(_on_dialog_ended):
			$UI/DialogBox.dialog_ended.disconnect(_on_dialog_ended)

func _on_voltar_button_pressed():
	AudioManager.play_click_sound()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Museu.tscn")
	GameManager.current_location = "Museu"

func _on_button_pressed(idx):
	AudioManager.play_click_sound()
	match idx:
		1:
			_show_dialog("chimarrao")
		2:
			_show_dialog("boitala")
		3:
			_show_dialog("chapeu")
		4:
			_show_dialog("bombacha")
		5:
			_show_dialog("pilcha")
		6:
			_show_dialog("saci")
