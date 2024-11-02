class_name Jogador
extends Personagem

var esta_ativo = true : set = ativar
var ultima_direcao: Vector2 = Vector2.ZERO 

@onready var sincronizador: Timer = $Sincronizador

func _ready() -> void:
	sincronizador.timeout.connect(Callable(sincronizar))
	nasceu.connect(set_process_unhandled_input.bind(true))
	hide()


func _physics_process(delta: float) -> void:
	direcao = pegar_direcao()
	movimentar(delta)
	
	match estado:
		Estados.NO_CHAO:
			if not is_on_floor():
				estado = Estados.NO_AR
		Estados.NO_AR:
			if is_on_floor():
				estado = Estados.NO_CHAO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and estado == Estados.NO_CHAO:
		requisitar_pular()


func setup(_apelido: String, _posicao: Vector2) -> void:
	apelido = _apelido
	global_position = _posicao
	requisitar_spawn()
	set_process(true)
	show()


func requisitar_spawn() -> void:
	set_process_unhandled_input(false)
	spawn()


func requisitar_pular() -> void:
	pular()
	ConexaoServidor.enviar_pulo()


func ativar(valor: bool) -> void:
	esta_ativo = valor
	set_process(valor)
	set_process_unhandled_input(valor)
	sincronizador.paused = not valor


func pegar_direcao() -> Vector2:
	if not is_processing_unhandled_input():
		return Vector2.ZERO

	var nova_direcao := Vector2(Input.get_axis("ui_left", "ui_right"), 0)
	if nova_direcao != ultima_direcao:
		ConexaoServidor.enviar_direcao(nova_direcao.x)
		ultima_direcao = nova_direcao
	return nova_direcao


func sincronizar() -> void:
	ConexaoServidor.enviar_posicao(global_position)
