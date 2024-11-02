extends Node

# Emitted when the server has received the game state dump for all connected characters
signal recebeu_estado_inicial (posicoes, entradas, apelidos)

# Emitted when the `presences` Dictionary has changed by joining or leaving clients
signal mudanca_presencas

# Emitted when the server has sent an updated game state. 10 times per second.
signal estado_de_jogo_atualizado(posicoes, entradas)

# Emitted when the server has been informed of a new character having been selected and is ready to
# spawn.
signal personagem_spawned(id, apelido)

enum OpCodes {
	UPDATE_POSITION = 1,
	UPDATE_INPUT,
	UPDATE_STATE,
	UPDATE_JUMP,
	DO_SPAWN,
	INITIAL_STATE
}

var cliente := Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
var sessao : NakamaSession
var socket : NakamaSocket

var multiplayer_bridge : NakamaMultiplayerBridge
var id_mundo : String
# Lists other clients present in the game world we connect to.
var presencas := {}

func registrar_cliente(email: String, apelido: String, senha: String):
	sessao = await cliente.authenticate_email_async(email, senha, apelido, true)
	if not sessao.is_exception():
		conectar_ao_servidor()
		return OK


func autenticar_cliente(email: String, senha: String):
	sessao = await cliente.authenticate_email_async(email, senha, null, false)
	if not sessao.is_exception():
		conectar_ao_servidor()
		return OK


func conectar_ao_servidor():
	socket = Nakama.create_socket_from(cliente)
	socket.connected.connect(self._on_socket_connected)
	socket.closed.connect(self._on_socket_closed)
	socket.received_error.connect(self._on_socket_error)
	await socket.connect_async(sessao)
	
	#warning-ignore: return_value_discarded
	socket.connected.connect(Callable(conectado_ao_servidor))
	#warning-ignore: return_value_discarded
	socket.closed.connect(Callable(desconectado_do_servidor))
	#warning-ignore: return_value_discarded
	socket.connection_error.connect(Callable(erro_conexao))
	#warning-ignore: return_value_discarded
	socket.received_error.connect(Callable(erro_inesperado))
	#warning-ignore: return_value_discarded
	socket.received_match_presence.connect(Callable(partida_presenca_recebida))
	#warning-ignore: return_value_discarded
	socket.received_match_state.connect(Callable(partida_estado_recebido))
##

func conectado_ao_servidor():
	pass

func desconectado_do_servidor():
	socket = null

func erro_conexao(erro):
	erro = "Erro %s" % erro
	socket = null
	print(erro)

func erro_inesperado(erro):
	print(erro)
	socket = null

func partida_presenca_recebida(novas_presencas: NakamaRTAPI.MatchPresenceEvent):
	for saida in novas_presencas.leaves:
		#warning-ignore: return_value_discarded
		presencas.erase(saida.user_id)

	for entrada in novas_presencas.joins:
		if not entrada.user_id == sessao.user_id:
			presencas[entrada.user_id] = entrada

	mudanca_presencas.emit()

# Mensagens customizadas do servidor
func partida_estado_recebido(estado_partida: NakamaRTAPI.MatchData):
	var codigo := estado_partida.op_code
	var raw := estado_partida.data

	match codigo:
		OpCodes.UPDATE_STATE:
			var conteudo: Dictionary = JSON.parse_string(raw)

			var posicoes: Dictionary = conteudo.pos
			var entradas: Dictionary = conteudo.inp

			estado_de_jogo_atualizado.emit(posicoes, entradas)

		OpCodes.INITIAL_STATE:
			var conteudo: Dictionary = JSON.parse_string(raw)

			var posicoes: Dictionary = conteudo.pos
			var entradas: Dictionary = conteudo.inp
			var apelidos: Dictionary = conteudo.nms

			recebeu_estado_inicial.emit(posicoes, entradas, apelidos)

		OpCodes.DO_SPAWN:
			var conteudo: Dictionary = JSON.parse_string(raw)

			var id: String = conteudo.id
			var apelido: String = conteudo.nm

			personagem_spawned.emit(id, apelido)

##

# Gets the id of a match being played or lets the server create it, joins the match, and stores the
# players in the match in a dictionary.
func conectar_ao_mundo():
	var mundo: NakamaAPI.ApiRpc = await cliente.rpc_async(sessao, "get_world_id", "")
	if not mundo.is_exception():
		id_mundo = mundo.payload

	# Request to join the match through the NakamaSocket API.
	var partida: NakamaRTAPI.Match = await socket.join_match_async(id_mundo)

	if not partida.is_exception():
		# If the request worked, we get a list of presences, that is to say, a list of clients in that
		# match.
		for presenca in partida.presences:
			presencas[presenca.user_id] = presenca
		return presencas
	return null


func enviar_spawn(apelido: String) -> void:
	if socket:
		var payload := {id = sessao.user_id, nm = apelido}
		socket.send_match_state_async(id_mundo, OpCodes.DO_SPAWN, JSON.stringify(payload))


func enviar_pulo():
	if socket:
		var payload := {id = sessao.user_id}
		socket.send_match_state_async(id_mundo, OpCodes.UPDATE_JUMP, JSON.stringify(payload))


func enviar_direcao(entrada : float):
	if socket:
		var payload := {id = sessao.user_id, inp = entrada}
		socket.send_match_state_async(id_mundo, OpCodes.UPDATE_INPUT, JSON.stringify(payload))


func enviar_posicao(posicao : Vector2):
	if socket:
		var payload := {id = sessao.user_id, pos = {x = posicao.x, y = posicao.y}}
		socket.send_match_state_async(id_mundo, OpCodes.UPDATE_POSITION, JSON.stringify(payload))





func _on_match_join_error(error):
	print ("Unable to join match: ", error.message)

func _on_match_joined() -> void:
	print ("Joined match with id: ", multiplayer_bridge.match_id)

func _on_socket_connected():
	print("Socket connected.")

func _on_socket_closed():
	print("Socket closed.")

func _on_socket_error(err):
	printerr("Socket error %s" % err)
