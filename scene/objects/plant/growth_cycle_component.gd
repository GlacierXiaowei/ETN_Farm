extends Node
class_name GrowthCycleComponent

@export var current_growth_state: DataType.GrowthState = DataType.GrowthState.Germination
@export_range(5,365) var days_until_harvest: int = 7

signal crop_maturity
signal crop_harvesting

var is_watered: bool = false
var starting_day: int = -1
#var current_day: int

func _ready() -> void:
	DayNightManager.time_tick_day.connect(on_time_tick_day)
	
func on_time_tick_day(day: int) -> void:
	#current_day = day
	if is_watered:
		if starting_day == -1:
			starting_day = day
			
		growth_state(starting_day, day)	
		harvest_state(starting_day , day)
			
func growth_state(_starting_day: int,_current_day: int) -> void :
	if current_growth_state == DataType.GrowthState.Maturity:
		return
	
	var day_passed := _current_day - _starting_day
	if day_passed < 0:
		return
	
	##seed不算 他是从 第二个阶段开始的 这里只计算到成熟状态
	##循环周期 一般不算seed 和 harvest
	var num_state: int = 4
	
	#var state_index : int= (_current_day - _starting_day) % num_state + 1
	#current_growth_state = state_index as DataType.GrowthState
	
	var stage_length := float(days_until_harvest) / num_state
	var stage_index := int(day_passed / stage_length)
	stage_index = clamp(stage_index, 0, num_state - 1)
	
	##因为从 Germination(1) 开始
	##注意 只改变显示逻辑 但是内部的stage 是代表var num_state: int = 4 这个的 
	##我们尽量不该本来 stage内部的10-3的顺序
	current_growth_state = (stage_index+1) as DataType.GrowthState
	
	var _name = DataType.GrowthState.keys()[current_growth_state]
	
	if current_growth_state == DataType.GrowthState.Maturity:
		crop_maturity.emit()
		
func harvest_state(_starting_day: int,_current_day: int) -> void:
	if current_growth_state==DataType.GrowthState.Harvesting:
		return
		
	var day_passed := _current_day - _starting_day
	if day_passed >= days_until_harvest:
		current_growth_state = DataType.GrowthState.Harvesting
		crop_harvesting.emit()
		
#这个函数 有一点多余 其实 可以直接访问 属性 毕竟是公开的嘛
func get_current_growth_state() -> DataType.GrowthState:
	return current_growth_state
