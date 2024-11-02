extends Control

# ENTRAR
@export var inserir_email: LineEdit
@export var inserir_senha: LineEdit
@export var botao_entrar: Button
@export var saida_entrar: Label
@export var entrar: VBoxContainer

#CADASTRAR
@export var criar_email: LineEdit
@export var criar_apelido: LineEdit
@export var criar_senha: LineEdit
@export var botao_cadastrar: Button
@export var saida_cadastrar: Label
@export var cadastrar: VBoxContainer


func _ready() -> void:
	botao_entrar.pressed.connect(Callable(_enviar_credenciais_autenticacao))
	botao_cadastrar.pressed.connect(Callable(_enviar_credenciais_cadastro))


func _enviar_credenciais_autenticacao():
	var email_inserido = inserir_email.text
	var senha_inserida = inserir_senha.text
	
	var resultado = await ConexaoServidor.autenticar_cliente(email_inserido, senha_inserida)

	if resultado == OK:
		resultado = await ConexaoServidor.conectar_ao_mundo()
		if resultado != null:
			get_tree().change_scene_to_file("res://mundo.tscn")
			ConexaoServidor.enviar_spawn(ConexaoServidor.sessao.username)


func _enviar_credenciais_cadastro():
	var email_inserido = criar_email.text
	var apelido_inserido = criar_apelido.text
	var senha_inserida = criar_senha.text
	
	var resultado = await ConexaoServidor.registrar_cliente(email_inserido, apelido_inserido, senha_inserida)
	
	if resultado == OK:
		resultado = await ConexaoServidor.conectar_ao_mundo()
		if resultado != null:
			get_tree().change_scene_to_file("res://mundo.tscn")
			ConexaoServidor.enviar_spawn(ConexaoServidor.sessao.username)
