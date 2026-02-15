# PROJECT_CONTEXT.md

## 1. Project Overview

| Property | Value |
| :--- | :--- |
| **Engine Version** | Godot 4.6 (Forward Plus) |
| **Project Name** | farm_exercise |
| **Core Gameplay** | 2D Farming Simulation |
| **Architecture Pattern** | State Machine + Component-based |
| **Viewport Size** | 640x360 (scaled to 1280x720) |
| **Physics Engine** | Jolt Physics |

## 2. Global Autoloads (Singletons)

| Singleton | Script Path | Description |
| :--- | :--- | :--- |
| ToolManager | `res://script/globals/tool_manager.gd` | 工具选择系统，管理当前选中的工具 |
| InventoryManager | `res://script/globals/inventory_manager.gd` | 库存系统，管理玩家物品收集 |
| DayNightManager | `res://script/globals/DayNightManager.gd` | 日夜循环系统，控制游戏时间流逝 |

## 3. Key Class Index

| Class Name | Script Path | Description |
| :--- | :--- | :--- |
| DataType | `res://script/globals/data_types.gd` | 枚举定义：工具类型、作物生长状态 |
| GameInputEvent | `res://script/InputManager/game_input_events.gd` | 输入管理：模式切换、工具使用请求缓存 |
| NodeState | `res://script/state_machine/node_state.gd` | 状态机基础状态类 |
| NodeStateMachine | `res://script/state_machine/node_state_machine.gd` | 状态机管理器 |
| Player | `res://scene/characters/player/player.gd` | 玩家角色主体 |
| ToolPanel | `res://scene/UI/tool_panel.gd` | 工具选择面板UI |
| InventoryPanel | `res://scene/UI/inventory_panel.gd` | 物品栏面板UI |
| DayNightPanel | `res://scene/UI/day_night_panel.gd` | 时间显示面板UI |
| DirtCursorComponent | `res://scene/components/dirt_cursor_component.gd` | 耕地光标组件 |
| CropsCursorComponent | `res://scene/components/crops_cursor_component.gd` | 作物种植组件 |
| GrowthCycleComponent | `res://scene/objects/plant/growth_cycle_component.gd` | 作物生长周期组件 |
| InteractableComponent | `res://scene/components/interactable_component.gd` | 可交互组件 |
| CollectableComponent | `res://scene/components/collectable_component.gd` | 可收集物品组件 |
| NoPlacement | `res://scene/characters/player/no_placement.gd` | 禁止放置区域检测 |

## 4. Directory Structure

```
farm-exercise/
├── addons/                    # Godot 插件
├── assets/                    # 外部资源（图片、音频等）
├── scene/                     # 场景文件
│   ├── characters/            # 角色相关
│   │   ├── player/            # 玩家（Player.tscn + 状态脚本）
│   │   ├── chicken/           # 鸡 NPC
│   │   └── cow/               # 牛 NPC
│   ├── components/            # 组件系统
│   ├── houses/                # 建筑（小屋、中屋、大屋、门）
│   ├── objects/               # 可交互物体
│   │   ├── plant/             # 作物（玉米、番茄）+ 生长组件
│   │   ├── rock/              # 石头
│   │   └── tree/              # 树木
│   ├── UI/                    # 用户界面
│   ├── pck_loader/           # PCK 加载器
│   └── test/                  # 测试场景
├── script/                    # GDScript 脚本
│   ├── globals/               # 全局管理器
│   ├── InputManager/          # 输入系统
│   └── state_machine/         # 状态机系统
├── Tilesets/                  # 瓦片集
└── project.godot              # 项目配置
```

## 5. Coding Conventions

- **变量命名**: snake_case
- **类名**: PascalCase
- **函数名**: snake_case
- **信号回调**: `_on_Node_signal` 格式
- **导出属性**: `@export` 标记可配置属性
- **延迟初始化**: `@onready` 延迟节点引用初始化
- **注释**: 使用注释说明复杂逻辑和意图

## 6. Systems Architecture

### 6.1 工具系统 (Tool System)

**工具类型枚举** (`DataType.Tools`):
| Index | Tool Name | 功能 |
| :--- | :--- | :--- |
| 0 | None | 无工具 |
| 1 | AxeWood | 砍伐树木 |
| 2 | TillGround | 耕地（将草地转为耕地） |
| 3 | WaterCrops | 浇水（促进作物生长） |
| 4 | PlantCorn | 种植玉米 |
| 5 | PlantTomato | 种植番茄 |

**工具选择机制**:
- `ToolManager` 单例通过 `tool_selected` 信号通知工具变更
- 快捷键 1-9 切换工具
- UI 面板点击切换工具

### 6.2 状态机系统 (State Machine)

**玩家状态列表**:
| State | Script | Trigger Condition |
| :--- | :--- | :--- |
| Idle | `idle_state.gd` | 静止状态，默认状态 |
| Walking | `walk_state.gd` | 检测到移动输入 |
| Tilling | `tilling_state.gd` | 选中锄头并按下左键 |
| Planting | `plantingstate.gd` | 选中种子并按下左键 |
| Watering | `watering_state.gd` | 选中水壶并按下左键 |
| Chopping | `chopping.gd` | 选中斧头并按下左键 |

**状态辅助类**:
- `NoPlacement` (`no_placement.gd`): 禁止放置区域检测，用于判断玩家是否在建筑物内部或周围

**状态机工作流程**:
1. `NodeStateMachine` 在 `_ready()` 中收集所有子状态
2. 状态通过 `transition` 信号触发状态切换
3. 每个状态实现 `_on_enter()`, `_on_exit()`, `_on_process()`, `_on_physics_process()`, `_on_next_transitions()` 生命周期方法
4. `_on_next_transitions()` 中判断转换条件并发出 `transition.emit("new_state")`

### 6.3 输入管理系统 (Input System)

**输入映射** (`project.godot`):
| Action | Keys | Description |
| :--- | :--- | :--- |
| walk_up | W / ↑ | 向上移动 |
| walk_down | S / ↓ | 向下移动 |
| walk_left | A / ← | 向左移动 |
| walk_right | D / → | 向右移动 |
| hit | Left Mouse Button | 使用工具 |
| undo_hit | Ctrl + Left Mouse Button | 撤销工具操作 |
| num_1~num_9 | 1~9 | 快捷工具选择 |

**输入模式** (`GameInputEvent.Mode`):
- `GAMEPLAY`: 正常游戏输入
- `UI`: UI 交互模式，禁用角色移动
- `CUTSCENE`: 过场动画模式
- `DISABLED`: 完全禁用输入

**请求缓存机制**:
- `request_use_tool()`: 缓存工具使用请求
- `request_undo_use_tool()`: 缓存撤销请求
- `request_tool_select()`: 缓存工具切换请求
- 状态机在 `_physics_process` 中消耗请求

### 6.4 作物系统 (Crop System)

**生长状态** (`DataType.GrowthState`):
| State | Index | Description |
| :--- | :--- | :--- |
| Seed | 0 | 种子阶段 |
| Germination | 1 | 发芽阶段 |
| Vegetative | 2 | 生长期 |
| Reproduction | 3 | 开花/结果阶段 |
| Maturity | 4 | 成熟阶段 |
| Harvesting | 5 | 可收获阶段 |

**生长周期逻辑**:
- `GrowthCycleComponent` 监听 `DayNightManager.time_tick_day` 信号
- 作物需要浇水(`is_watered = true`)才能开始生长
- 根据 `days_until_harvest` 和当前天数计算生长阶段
- 达到收获阶段后发出 `crop_harvesting` 信号

**当前作物类型**:
- 玉米 (Corn): 默认 7 天收获
- 番茄 (Tomato): 默认 7 天收获
- 玉米收获体 (CornHarvest)
- 番茄收获体 (TomatoHarvest)

**可收集物品**:
- 鸡蛋 (Egg)
- 牛奶 (Milk)

### 6.5 日夜循环系统 (DayNight System)

**时间系统**:
- `MINUTE_PER_DAY = 1440` (24小时 × 60分钟)
- `GAME_MINUTE_DURATION = TAU / 1440` (一天对应 2π 弧度)
- 默认游戏速度: `game_speed = 5.0`
- 初始时间: 第1天 12:30

**信号**:
- `game_time(time: float)`: 每帧发送当前游戏时间(弧度)
- `time_tick(day, hour, minute)`: 每游戏分钟发送
- `time_tick_day(day)`: 每游戏天发送

### 6.6 库存系统 (Inventory System)

**存储结构**:
- 使用 `Dictionary` 存储，键为物品名称(首字母大写)
- 值 为数量 (Integer)

**可收集物品类型**:
- 鸡蛋 (Egg): 来自鸡 NPC
- 牛奶 (Milk): 来自牛 NPC
- 玉米 (Corn): 来自成熟作物
- 番茄 (Tomato): 来自成熟作物

**API**:
- `add_collectable(collectable_name: String)`: 添加物品，自动累加数量
- `inventory_change` 信号: 库存变更时发送

### 6.7 组件系统 (Components)

**可用组件列表**:
| Component | Script | Description |
| :--- | :--- | :--- |
| DirtCursorComponent | `dirt_cursor_component.gd` | 负责耕地操作，支持鼠标点击/角色前方格子优先模式 |
| CropsCursorComponent | `crops_cursor_component.gd` | 负责种植/移除作物，检测目标格子是否为耕地 |
| InteractableComponent | `interactable_component.gd` | 可交互物体基础组件 |
| CollectableComponent | `collectable_component.gd` | 可收集物品组件 |
| DamageComponent | `damage_component.gd` | 伤害组件 |
| HurtComponent | `hurt_component.gd` | 受伤组件 |
| HitComponent | `hit_component.gd` | 打击组件 |
| DayNightCycleComponent | `day_night_cycle_component.gd` | 日夜循环组件 |

**DirtCursorComponent** (`dirt_cursor_component.gd`):
- 负责耕地操作
- 支持两种模式: 鼠标点击优先 / 角色前方格子优先
- 通过 TileMap 的 Terrain Set 实现草地→耕地转换
- 最大交互距离: 25 像素

**CropsCursorComponent** (`crops_cursor_component.gd`):
- 负责种植/移除作物
- 检测目标格子是否为耕地 (通过 `dirt_tilemap_layer` 的 source_id)
- 实例化作物体到 `crop_parent` 节点下

## 7. Physics Layers

| Layer | Name | 用途 |
| :--- | :--- | :--- |
| 1 | Wall | 墙壁/障碍物 |
| 2 | Player | 玩家 |
| 3 | Interactable | 可交互物体 |
| 4 | Tool | 工具 |
| 5 | Object | 场景物体 |
| 6 | Collectable | 可收集物品 |
| 7 | NPC | NPC 角色 |

## 8. UI System

**UI 场景** (`scene/UI/`):
- `game_screen.tscn`: 游戏主界面
- `tool_panel.tscn`: 工具栏
- `inventory_panel.tscn`: 物品栏
- `day_night_panel.tscn`: 时间显示
- `game_ui_theme.tres`: UI 主题资源

## 9. Test Scenes

测试场景位于 `scene/test/`:
- `test_scene_default.tscn`: 默认测试
- `test_scene_player.tscn`: 玩家测试
- `test_scene_tile_map.tscn`: 瓦片地图测试
- `test_scene_dirt.tscn`: 耕地系统测试
- `test_scene_crop.tscn`: 作物系统测试
- `test_scene_daynight_circle.tscn`: 日夜循环测试
- `test_scene_inventory_management.tscn`: 库存系统测试
- `test_scene_npc_and_navigation.tscn`: NPC 导航测试
- `test_scene_collectables.tscn`: 可收集物品测试
- `test_scene_game_screen.tscn`: 游戏界面测试
- `test_scene_house_tilemap.tscn`: 房屋瓦片地图测试
- `test_scene_layer.tscn`: 图层测试
- `test_scene_npc_chicken.tscn`: 鸡 NPC 测试
- `test_scene_npc_cow.tscn`: 牛 NPC 测试
- `test_scene_objects_rock.tscn`: 石头物体测试
- `test_scene_objects_tree.tscn`: 树木物体测试
