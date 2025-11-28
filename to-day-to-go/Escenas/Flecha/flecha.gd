extends Area2D

var velocidad = 150
var direccion = Vector2.LEFT  # se setea desde el jugador
var offset_inicio = Vector2(0, 0)

func _ready():
	position += offset_inicio

	# Conectar señales correctamente
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	position += direccion * velocidad * delta

func _on_body_entered(body):
	queue_free()

func _on_area_entered(area):
	queue_free()
