extends CharacterBody2D

# --- NODOS ---
@onready var animacion = $AnimatedSprite2D
@onready var area_colision = $Area2D  

# --- MOVIMIENTO ---
var _velocidad = 150
var _velocidad_salto = 300

# --- ATAQUE ---
var Flecha = preload("res://Escenas/Flecha/Flecha.tscn")
var offset_flecha = Vector2(20, -5)

# --- SALUD ---
var vida_maxima = 3
var vida_actual = 3
var esta_muerto = false

func _ready():
	# Asegúrate de que el Area2D del jugador detecte colisiones
	if area_colision != null:
		area_colision.area_entered.connect(_on_area_entered)
	else:
		push_error("Error: Area2D no encontrado")
	
	# Agregar jugador al grupo "jugador" para detección por la flecha
	add_to_group("jugador")
	
func _physics_process(delta):
	if esta_muerto:
		velocity = Vector2.ZERO
		return  # bloquea movimiento y animaciones normales

	# --- GRAVEDAD ---
	velocity += get_gravity() * delta

	# --- MOVIMIENTO LATERAL ---
	if Input.is_action_pressed("mover_derecha_J2"):
		velocity.x = _velocidad
		animacion.flip_h = true
	elif Input.is_action_pressed("mover_izquierda_J2"):
		velocity.x = -_velocidad
		animacion.flip_h = false
	else:
		velocity.x = 0

	# --- SALTO ---
	if Input.is_action_just_pressed("saltar_j2") and is_on_floor():
		velocity.y = -_velocidad_salto

	# --- MOVIMIENTO ---
	move_and_slide()

	# --- ANIMACIONES ---
	_actualizar_animaciones()

	# --- ATAQUE ---
	_disparar_si_corresponde()

func _actualizar_animaciones():
	if esta_muerto:
		return  # no cambiar animaciones si está muerto

	if Input.is_action_just_pressed("atacar_j2"):
		if not is_on_floor():
			animacion.play("atacar_saltando")
		elif Input.is_action_pressed("agacharse_j2"):
			animacion.play("atacar_agachado")
		else:
			animacion.play("atacar")
	elif not is_on_floor():
		animacion.play("saltar")
	elif Input.is_action_pressed("agacharse_j2"):
		animacion.play("agacharse")
	elif velocity.x != 0:
		animacion.play("correr")
	else:
		animacion.play("idle")

func _disparar_si_corresponde():
	if Input.is_action_just_pressed("atacar_j2"):
		disparar_flecha()

func disparar_flecha():
	if Flecha == null:
		return

	var flecha = Flecha.instantiate()

	# Ajuste de offset según flip_h
	var factor = 1 if animacion.flip_h else -1
	flecha.position = global_position + Vector2(offset_flecha.x * factor, offset_flecha.y)

	# Dirección de la flecha
	flecha.direccion = Vector2.RIGHT if animacion.flip_h else Vector2.LEFT

	# Añadir a la escena y grupo "flechas"
	get_tree().current_scene.add_child(flecha)
	flecha.add_to_group("flechas")

# --- DAÑO ---
func recibir_dano(cantidad: int):
	if esta_muerto:
		return

	vida_actual -= cantidad

	if vida_actual <= 0:
		vida_actual = 0
		morir()
	else:
		animacion.play("recibir_dano")

func morir():
	if esta_muerto:
		return

	esta_muerto = true
	animacion.play("morir")
	velocity = Vector2.ZERO
	# opcional: si quieres eliminar el jugador al final de la animación:
	# await animacion.animation_finished
	# queue_free()

# --- COLISION CON FLECHAS ---
func _on_area_entered(area):
	if area.is_in_group("flechas"):
		recibir_dano(1)
		area.queue_free()
