# Guia para Estrutura Fundamental de Jogo 2D no Godot - Projeto Educacional para Crianças Brasileiras (8-12 anos)

## Objetivo do Jogo

    - Linguagem de programação: GDScript.

    - Jogo 2D para crianças brasileiras (8 a 12 anos) aprenderem inglês (nível básico a intermediário).

    - Ambientação na cidade de Ijuí, RS, Brasil, com pontos turísticos reais.

    - Jogabilidade com exploração e minigames focados no aprendizado de inglês.

    - Fluxo: jogador escolhe local -> personagem vai até lá -> joga minigame -> recebe recompensa -> escolhe próximo local.

---

## Estrutura Geral do Projeto Godot

res://
├── assets/                 # Imagens, sons, spritesheets, fontes
│   ├── backgrounds/
│   ├── characters/
│   ├── ui/
│   └── sounds/
│
├── scenes/                 # Cenas Godot
│   ├── Home.tscn           # Tela inicial / mapa principal (com Spark e caminhos)
│   ├── Locations/
│   │   ├── TrainStation.tscn
│   │   └── ... outros locais
│   ├── Minigames/
│   │   ├── PackUpMinigame.tscn
│   │   └── ... outros minigames
│   ├── UI/
│   │   ├── DialogBox.tscn  # Caixa de diálogo para Spark
│   │   └── FeedbackLabel.tscn # Feedback visual (e.g. "Nice!", "Super Cool!")
│   └── Player.tscn         # Personagem principal, controlado pelo jogador
│
├── scripts/                # Scripts GDScript
│   ├── GameManager.gd      # Controlador global do fluxo e estados do jogo
│   ├── Player.gd
│   ├── Minigames/
│   │   ├── PackUpMinigame.gd
│   │   └── MinigameBase.gd # Script base para herança em minigames
│   ├── UI/
│   │   ├── DialogBox.gd
│   │   └── FeedbackLabel.gd
│   └── Locations/
│       ├── TrainStation.gd
│       └── ... outros scripts de local
│
├── autoload/               # Nó singleton para GameManager (autoload)
│   └── GameManager.gd
│
└── project.godot           # Configurações do projeto

---

## Cenas Principais e Componentes

**1. Home.tscn (Mapa Principal)**

    Mostra o mapa com caminhos para diferentes locais.

    Personagem Spark (cachorro) apresenta diálogo de boas-vindas.

    Pontos de interesse clicáveis (placas de madeira ou sinalizações da cidade).

    Ao clicar em um ponto, jogador é movido para o local correspondente.

**2. Player.tscn**

    Personagem do jogador com movimentação controlada por clique.

    Deve incluir animações básicas (andar parado, andar em movimento).

**3. Locais (e.g. TrainStation.tscn)**

    Cenário do local escolhido.

    Apresenta o minigame correspondente.

    Inclui área para interação com o minigame.

**4. Minigames (e.g. PackUpMinigame.tscn)**

    Implementar minigame específico para aprendizado de inglês.

    Exemplo: Arrastar objetos para a mala correta.

    Feedback visual e textual positivo para acertos.

**5. UI - Caixa de Diálogo e Feedback**

    DialogBox.tscn: Caixa para mostrar falas do Spark.

    FeedbackLabel.tscn: Texto que aparece para incentivar o jogador ("Nice!", "Super Cool!").

---

## Fluxo do Jogo

    Início em Home.tscn

        Spark se apresenta no diálogo.

        Jogador vê caminhos e placas clicáveis.

    Clique em uma placa (ex: Estação Ferroviária)

        Jogador é movido para a cena do local (ex: TrainStation.tscn).

    Apresentação do minigame do local

        Minigame inicia (ex: "Arrume a Bagagem").

        Jogador interage, aprendendo vocabulário.

    Após sucesso no minigame

        Feedback positivo aparece.

        Jogador é retornado ao mapa Home para escolher outro local.

---

## Padrões e Boas Práticas de Código

**GameManager.gd (Singleton)**
    Controla estado global (qual local, minigame, progresso).

    Responsável por trocar cenas.

    Fornece funções para iniciar minigames, dar feedback e salvar progresso.

**Player.gd**

    Controla movimentação do personagem via pathfinding simples.

    Movimenta personagem até o destino clicado.

**MinigameBase.gd**

    Classe base para minigames (métodos: start(), end(success: bool), reset()).

    Minigames devem herdar e implementar lógica específica.

**Scripts organizados por pasta e função**

    Separar lógica de UI, locais e minigames.

    Evitar scripts monolíticos.

    Comentários claros e documentação interna.

**Facilitar adição de novos minigames**

    Cada minigame herda MinigameBase.

    GameManager chama minigame via sinal ou função.

    Assets e cenas novos organizados por nome e categoria.

---

## Exemplo básico de GameManager.gd (pseudocódigo)

``extends Node

var current_scene = null
var player = null

func _ready():
    load_home_scene()

func load_home_scene():
    change_scene("res://scenes/Home.tscn")

func load_location_scene(location_name):
    var path = "res://scenes/Locations/%s.tscn" % location_name
    change_scene(path)

func start_minigame(minigame_name):
    var path = "res://scenes/Minigames/%s.tscn" % minigame_name
    change_scene(path)

func change_scene(scene_path):
    if current_scene:
        current_scene.queue_free()
    current_scene = load(scene_path).instance()
    get_tree().current_scene = current_scene
    add_child(current_scene)

func give_feedback(text):
    # mostra texto visual "Nice!", "Super Cool!"
    pass

func on_minigame_completed(success):
    if success:
        give_feedback("Nice!")
    load_home_scene()``

---

## Requisitos para Movimentação do Jogador

    Clicar no destino (placa no mapa).

    Personagem se move suavemente pelo caminho.

    Bloquear entrada de comandos enquanto o personagem estiver se movendo.

---

## Exemplo de Minigame (Arrumar a Bagagem)

    Lista de itens com nome em inglês e imagem.

    Arrastar item correto para a mala.

    Confirmar se item está correto.

    Exibir feedback imediato ("Correct!", "Try again").

    Contar acertos para finalizar o minigame.

    Emitir sinal minigame_completed(success) para o GameManager.

---

## Organização de Assets e UI

    Ícones e sprites organizados em pastas claras.

    Usar TextureRects, Buttons customizados para objetos arrastáveis.

    Usar sinalização para feedback visual.

---

## Expansão Futuras

    Adicionar novos locais no mapa e cenas.

    Criar novos minigames herdando MinigameBase.

    Possível sistema de pontuação e progresso.