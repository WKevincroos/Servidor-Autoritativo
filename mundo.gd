extends Node2D

@export var cena_jogador: PackedScene
@export var cena_personagem: PackedScene

@onready var jogador: Jogador = $Jogador
@onready var mundo: Node2D = $Mapa

var personagens := {}

func _ready() -> void:
	#warning-ignore: return_value_discarded
	ConexaoServidor.recebeu_estado_inicial.connect(Callable(configuracao_inicial))

func configuracao_inicial( posicoes: Dictionary, entradas: Dictionary, apelidos: Dictionary) -> void:
	#warning-ignore: return_value_discarded
	ConexaoServidor.recebeu_estado_inicial.disconnect(Callable(configuracao_inicial))
	entrar_no_mundo(posicoes, entradas, apelidos)

# The main entry point. Sets up the client player and the various characters that
# are already logged into the world, and sets up the signal chain to respond to
# the server.
func entrar_no_mundo( estado_posicoes: Dictionary, estado_entradas: Dictionary, estado_apelidos: Dictionary) -> void:
	var id_cliente := ConexaoServidor.sessao.user_id
	assert(estado_posicoes.has(id_cliente), "Estado inválido")
	var apelido: String = estado_apelidos.get(id_cliente)

	var posicao: Vector2 = Vector2(estado_posicoes[id_cliente].x, estado_posicoes[id_cliente].y)
	jogador.setup(apelido, posicao)

	var presencas := ConexaoServidor.presencas
	for p in presencas.keys():
		var posicao_personagem := Vector2(estado_posicoes[p].x, estado_posicoes[p].y)
		criar_personagem(p, estado_apelidos[p], posicao_personagem, estado_entradas[p].dir, true)

	#warning-ignore: return_value_discarded
	ConexaoServidor.mudanca_presencas.connect(Callable(partida_presencas_mudanca))
	#warning-ignore: return_value_discarded
	ConexaoServidor.estado_de_jogo_atualizado.connect(Callable(partida_estado_mudanca))
	#warning-ignore: return_value_discarded
	ConexaoServidor.personagem_spawned.connect(Callable(personagem_criado))

##

func partida_presencas_mudanca() -> void:
	var presencas := ConexaoServidor.presencas

	for key in presencas:
		if not key in personagens:
			criar_personagem(key, "User", Vector2.ZERO, 0, false)

	var para_deletar := []
	for key in personagens.keys():
		if not key in presencas:
			para_deletar.append(key)

	for key in para_deletar:
		personagens[key].despawn()
		#warning-ignore: return_value_discarded
		personagens.erase(key)


func partida_estado_mudanca(posicoes: Dictionary, entradas: Dictionary) -> void:
	var atualizar := false
	for key in personagens:
		atualizar = false
		if key in posicoes:
			var atualizacao_posicao: Dictionary = posicoes[key]
			personagens[key].proxima_posicao = Vector2(atualizacao_posicao.x, atualizacao_posicao.y)
			atualizar = true
		if key in entradas:
			personagens[key].proxima_entrada = entradas[key].dir
			personagens[key].proximo_pulo = entradas[key].jmp == 1
			atualizar = true
		if atualizar:
			personagens[key].atualizar_estado()


func personagem_criado(id: String, apelido: String) -> void:
	if id in personagens:
		personagens[id].apelido = apelido
		personagens[id].spawn()
		personagens[id].mostrar()

##

func criar_personagem(id: String, apelido: String, posicao: Vector2, direcao_x: float, do_spawn: bool) -> void:
	var personagem: Personagem = cena_personagem.instantiate()
	personagem.position = posicao
	personagem.direcao.x = direcao_x

	#warning-ignore: return_value_discarded
	mundo.add_child(personagem)
	personagem.apelido = apelido
	personagens[id] = personagem
	if do_spawn:
		personagem.spawn()
	else:
		personagem.esconder()
