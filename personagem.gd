class_name Personagem
extends CharacterBody2D

signal nasceu

enum Estados {NO_CHAO, NO_AR}

const VELOCIDADE = 300.0
const VELOCIDADE_PULO = -400.0

var estado := Estados.NO_CHAO

var direcao: Vector2 = Vector2.ZERO
var apelido = null : set = colocar_apelido

@onready var apelido_texto: Label = $Apelido

# Puppet
var ultima_posicao := Vector2.ZERO
var ultima_entrada := 0.0
var proxima_posicao := Vector2.ZERO
var proxima_entrada := 0.0
var proximo_pulo := false

func _physics_process(delta: float) -> void:
	movimentar(delta)
	
	match estado:
		Estados.NO_CHAO:
			if not is_on_floor():
				estado = Estados.NO_AR
		Estados.NO_AR:
			if is_on_floor():
				estado = Estados.NO_CHAO

func movimentar(delta: float):
	velocity += get_gravity() * delta
	if direcao:
		velocity.x = direcao.x * VELOCIDADE
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE)

	move_and_slide()

func pular():
	velocity.y = VELOCIDADE_PULO
	estado = Estados.NO_AR

func spawn():
	nasceu.emit()

func despawn():
	queue_free()

func atualizar_estado():
	if proximo_pulo:
		pular()
		proximo_pulo = false

	global_position = ultima_posicao

	direcao.x = ultima_entrada

	ultima_entrada = proxima_entrada
	ultima_posicao = proxima_posicao

func esconder():
	hide()

func mostrar():
	show()

func colocar_apelido(_apelido):
	apelido = _apelido
	apelido_texto.text = apelido
