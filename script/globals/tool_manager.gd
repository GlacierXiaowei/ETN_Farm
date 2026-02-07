extends Node

var selected_tool : DataType.Tools =DataType.Tools.None
##为了防止因为命名而找不到这个变量 因此多储存一次
var current_tool :DataType.Tools =DataType.Tools.None
signal tool_selected(tool : DataType.Tools) 

func select_tool (tool: DataType.Tools) -> void:
	tool_selected.emit(tool)
	selected_tool = tool
	current_tool = tool
