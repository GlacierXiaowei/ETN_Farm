extends Node2D

var tomato_harvest_scene = preload("res://scene/objects/plant/tomato_harvest.tscn")

@onready var water_particles: GPUParticles2D = $WaterParticles
@onready var flower_particles: GPUParticles2D = $FlowerParticles
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var hurt_component: HurtComponent = $HurtComponent

var growth_state: DataType.GrowthState = DataType.GrowthState.Germination


func _ready() -> void:
	water_particles.emitting = false
	flower_particles.emitting = false

	hurt_component.hurt.connect(on_hurt)
	growth_cycle_component.crop_maturity.connect(on_crop_maturity)
	growth_cycle_component.crop_harvesting.connect(on_crop_harvesting)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	growth_state = growth_cycle_component.get_current_growth_state()
	sprite_2d.frame = int(growth_state) +6


func on_hurt(_hit_damage: int) -> void:
	if !growth_cycle_component.is_watered:
		water_particles.emitting = true
		await get_tree().create_timer(5.0).timeout
		water_particles.emitting = false
		growth_cycle_component.is_watered = true
		
func on_crop_maturity() -> void:
	flower_particles.emitting = true


func on_crop_harvesting() -> void:
	var tomato_harvest_instance = tomato_harvest_scene.instantiate() as Node2D
	tomato_harvest_instance.global_position = global_position
	get_parent().add_child(tomato_harvest_instance)
	self.queue_free()
