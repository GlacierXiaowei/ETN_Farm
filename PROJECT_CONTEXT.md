# PROJECT_CONTEXT.md

## 1. Project Overview
- **Engine Version:** Godot 4.x
- **Core Gameplay:** 2D Farming Sim
- **Architecture Pattern:** State Machine with Component-based architecture

## 2. Global Autoloads (Singletons)
| Singleton Name | Script Path | Description |
| :--- | :--- | :--- |
| ToolManager | res://script/globals/tool_manager.gd | 管理当前选中的工具 |
| InventoryManager | res://script/globals/inventory_manager.gd | 管理玩家物品库存 |
| DayNightManager | res://script/globals/DayNightManager.gd | 管理游戏日夜循环系统 |

## 3. Key Class Index (class_name)
*方便 AI 知道去哪里找代码*
- `DataType`: `res://script/globals/data_types.gd` - 定义工具和作物生长状态枚举
- `GameInputEvent`: `res://script/InputManager/game_input_events.gd` - 处理全局输入事件和模式管理
- `NodeState`: `res://script/state_machine/node_state.gd` - 状态机基础状态类
- `NodeStateMachine`: `res://script/state_machine/node_state_machine.gd` - 状态机管理器
- `Player`: `res://scene/characters/player/player.gd` - 玩家角色主体类
- `ToolPanel`: `res://scene/UI/tool_panel.gd` - 工具选择面板UI类
- `DirtCursorComponent`: `res://scene/components/dirt_cursor_component.gd` - 耕地光标组件

## 4. Directory Structure Map
- `res://scene/characters`: 玩家和NPC角色相关
- `res://scene/components`: 游戏组件系统
- `res://scene/UI`: 用户界面相关
- `res://scene/test`: 测试场景
- `res://script/globals`: 全局管理器和数据类型
- `res://script/state_machine`: 状态机系统
- `res://script/InputManager`: 输入管理系统

## 5. Coding Conventions (Infer from code)
- 变量命名使用 snake_case
- 类名使用 PascalCase
- 信号回调使用 _on_Node_signal 格式
- 函数名使用 snake_case
- 使用注释说明复杂逻辑和代码意图
- 使用 @export 标记可配置属性
- 使用 @onready 延迟初始化节点引用