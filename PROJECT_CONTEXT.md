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
| DialogAction | `res://script/globals/dialog_action.gd` | 对话动作处理器，暴露回调给对话系统 |
| SaveGameManager | `res://script/globals/save_game_manager.gd` | 存档系统全局入口 |

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
| DialogAction | `res://script/globals/dialog_action.gd` | 对话动作处理器，暴露回调给对话系统 |
| BaseGameDialogBalloon | `res://dialog/base_game_dialog_balloon.gd` | 对话气泡基础类 |
| GameDialogBalloon | `res://dialog/game_dialog_balloon.gd` | 游戏对话气泡，继承基础类 |
| Guide | `res://scene/characters/guide/guide.gd` | 引导NPC，提供种子和对话 |
| SaveLevelDataComponent | `res://scene/components/crucial/save_level_data_component.gd` | 场景级存档管理器 |
| SaveDataComponent | `res://scene/components/crucial/save_data_component.gd` | 节点级数据收集器 |
| Chest | `res://scene/objects/chest/chest.gd` | 宝箱系统，提交作物获得奖励 |
| FeedComponent | `res://scene/components/feed_component.gd` | 食物接收组件，检测作物提交 |
| BoundaryGenerator | `res://scene/level/game_tile_map.gd` | 地图边界碰撞生成器，基于可行走区域自动生成碰撞边界 |

## 4. Directory Structure

```
farm-exercise/
├── addons/                    # Godot 插件
│   └── dialogue_manager/      # Dialogue Manager 对话系统插件
├── assets/                    # 外部资源（图片、音频等）
├── dialog/                    # 对话系统
│   ├── conversation/          # 对话内容文件
│   │   └── guide.dialogue     # Guide NPC 对话
│   ├── base_game_dialog_balloon.gd  # 对话气泡基础类
│   ├── game_dialog_balloon.gd       # 游戏对话气泡
│   └── dialog_balloon_theme.tres    # 对话主题
├── scene/                     # 场景文件
│   ├── characters/            # 角色相关
│   │   ├── player/            # 玩家（Player.tscn + 状态脚本）
│   │   ├── chicken/           # 鸡 NPC
│   │   ├── cow/               # 牛 NPC
│   │   └── guide/             # 引导NPC
│   ├── components/            # 组件系统
│   │   └── crucial/           # 核心组件
│   │       ├── save_level_data_component.gd   # 场景存档管理器
│   │       ├── save_data_component.gd         # 节点存档收集器
│   │       └── test_scene_save_data_manager_component.gd  # 测试场景加载器
│   ├── houses/                # 建筑（小屋、中屋、大屋、门）
│   ├── objects/               # 可交互物体
│   │   ├── plant/             # 作物（玉米、番茄）+ 生长组件
│   │   ├── rock/              # 石头
│   │   ├── tree/              # 树木
│   │   └── chest/             # 宝箱（作物提交奖励系统）
│   ├── UI/                    # 用户界面
│   ├── pck_loader/           # PCK 加载器
│   └── test/                  # 测试场景
├── script/                    # GDScript 脚本
│   ├── globals/               # 全局管理器
│   │   ├── dialog_action.gd   # 对话动作处理器
│   │   └── save_game_manager.gd  # 存档管理器
│   ├── InputManager/          # 输入系统
│   └── state_machine/         # 状态机系统
├── resource/                  # 资源数据文件
│   ├── node_data_resource.gd          # 节点数据基类
│   ├── scene_data_resource.gd         # 场景对象数据
│   ├── tilemap_layer_data_resource.gd # 地图层数据
│   └── save_game_data_resource.gd     # 存档容器
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

### 5.1 GDScript 类型系统注意事项

**Array 类型严格性**:
在 Godot 4.x 中，`Array` 和 `Array[Type]` 是不同的类型，不能直接混用。

```gdscript
# ❌ 错误：类型不匹配
func process_items(items: Array[Dictionary]) -> Array[Dictionary]:
    if items.size() <= 1:
        return items  # 错误：items 是 Array[Dictionary]，但返回 Array

# ❌ 错误：变量类型声明不一致  
var items: Array = get_items()  # 返回 Array[Dictionary]
items.sort_custom(...)  # 编译错误

# ✅ 正确：统一使用 Array[Dictionary]
func process_items(items: Array[Dictionary]) -> Array[Dictionary]:
    if items.size() <= 1:
        return items  # 正确：类型一致
    
var items: Array[Dictionary] = get_items()
items.sort_custom(...)  # 正确

# ✅ 正确：空数组初始化
var empty: Array[Dictionary] = Array[Dictionary]([])
```

**常见错误及解决方案**:
| 错误信息 | 原因 | 解决方案 |
|:---|:---|:---|
| `Trying to return an array of type "Array" where expected return type is "Array[Dictionary]"` | 函数参数/返回值类型不匹配 | 统一改为 `Array[Dictionary]` |
| 无法调用数组方法 | 变量声明为 `Array` 但实际是 `Array[Type]` | 改为 `var items: Array[Type] = ...` |

**最佳实践**:
1. 函数参数和返回值明确标注类型：`func process(items: Array[Dictionary]) -> Array[Dictionary]`
2. 变量声明使用完整类型：`var items: Array[Dictionary] = []`
3. 空数组初始化：`Array[Type]([])`
4. 避免使用裸 `Array` 类型，除非确实需要混合类型

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
| FeedComponent | `feed_component.gd` | 食物接收组件，用于宝箱提交作物检测 |
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

### 6.8 对话系统 (Dialogue System)

**系统架构**: Dialogue Manager 插件 + Mutation 回调机制

**核心组件**:

| 组件 | 脚本 | 描述 |
| :--- | :--- | :--- |
| DialogAction | `script/globals/dialog_action.gd` | 对话动作处理器，暴露给 `.dialogue` 文件的回调接口 |
| BaseGameDialogBalloon | `dialog/base_game_dialog_balloon.gd` | 对话气泡基础类，处理对话显示逻辑 |
| GameDialogBalloon | `dialog/game_dialog_balloon.gd` | 游戏对话气泡，继承基础类，添加表情等功能 |
| Guide | `scene/characters/guide/guide.gd` | 引导NPC，演示对话系统使用 |

**对话文件格式** (`.dialogue`):
```
~ start
Glacier: Hi! Welcome to your farm!
do DialogAction.give_item("Corn", 3)
Glacier: I've given you 3 corn seeds!
=> END
```

**Mutation 回调**: 使用 `do` 命令调用游戏代码
- `do DialogAction.give_item(item_name, amount)` - 给予物品
- 支持 InventoryManager / 未来的 QuestManager / AffectionManager 等

**使用步骤**:
1. 安装 Dialogue Manager 插件到 `addons/dialogue_manager/`
2. 创建 `DialogAction` Autoload 单例
3. 创建 `.dialogue` 对话文件
4. NPC 脚本中实例化 Balloon 并调用 `start()` 开始对话

### 6.9 存档系统 (Save System)

**系统架构**: 组件化 + Resource 资源驱动

**核心组件**:

| 组件 | 脚本 | 组名 | 职责 |
| :--- | :--- | :--- | :--- |
| SaveGameManager | `script/globals/save_game_manager.gd` | - | 全局入口，提供 save_game() / load_game() |
| SaveLevelDataComponent | `scene/components/crucial/save_level_data_component.gd` | `save_level_manager` | 场景级存档管理器，每个场景1个 |
| SaveDataComponent | `scene/components/crucial/save_data_component.gd` | `save_data_component` | 节点级数据收集器，标记需要保存的节点 |

**两个组的分工**:
- `save_level_manager`: 供 SaveGameManager 查找，定位当前场景的存档管理器
- `save_data_component`: 供 SaveLevelDataComponent 查找，收集所有需要保存的节点

**存储路径**:
- Windows: `%APPDATA%/Godot/app_userdata/farm_exercise/game_data/`
- 文件名: `save_{场景名}_game_data.tres`

**数据资源类**:
- `NodeDataResource` (`resource/node_data_resource.gd`): 基础数据（位置、路径）
- `SceneDataResource` (`resource/scene_data_resource.gd`): 场景对象（玩家、NPC、作物）
- `TileMapLayerDataResource` (`resource/tilemap_layer_data_resource.gd`): 地图层（耕地状态）
- `SaveGameDataResource` (`resource/save_game_data_resource.gd`): 存档容器，聚合所有数据

**使用步骤**:
1. 场景根节点添加 `SaveLevelDataComponent`（必须！）
2. 需要保存的节点添加 `SaveDataComponent`，并配置 `save_data_resource`:
   - 普通节点/NPC/作物 → 拖拽 `scene_data_resource.tres`
   - TileMapLayer（耕地层） → 拖拽 `tilemap_layer_data_resource.tres`
3. 调用 `SaveGameManager.save_game()` / `load_game()`

**已知问题**:
- `get_used_cells()` 返回顺序不确定，保存 TileMap 时需遍历所有格子寻找正确 terrain
- 作物状态（生长阶段等）尚未实现保存
- 玩家位置恢复已修复（SceneDataResource 优先查找已存在节点）

**重要**: `.tscn` 场景文件只能由用户在 Godot 编辑器中手动操作，不应直接修改，以免破坏 UID 引用。

### 6.10 宝箱提交奖励系统 (Chest Reward System)

**系统功能**: 玩家向宝箱提交收集的作物，获得随机奖励

**核心组件**:

| 组件 | 脚本 | 描述 |
| :--- | :--- | :--- |
| Chest | `scene/objects/chest/chest.gd` | 宝箱主体，管理提交动画和奖励生成 |
| FeedComponent | `scene/components/feed_component.gd` | 食物接收区域检测 |
| InteractableComponent | `scene/components/interactable_component.gd` | 玩家交互检测 |

**工作流程**:
1. 玩家靠近宝箱，按交互键打开对话
2. 对话中触发 `DialogAction.on_feed_animal` 信号
3. 宝箱播放开启动画
4. 玩家库存中的作物逐个飞向宝箱（tween动画）
5. `FeedComponent` 检测到作物进入触发区域
6. 调用 `add_reward_scene()` 在奖励标记点周围随机位置生成奖励

**配置属性**:
- `food_drop_height`: 作物飞入高度偏移（默认40像素）
- `reward_output_radius`: 奖励生成半径（默认20像素）
- `output_reward_scenes`: 奖励场景数组（可配置多种奖励）

**测试场景**: `test_scene_chest.tscn`

### 6.11 地图边界碰撞生成系统 (Boundary Generator System)

**系统功能**: 根据可行走区域自动生成碰撞边界，防止玩家走出安全区域（如草地边缘）

**核心组件**:

| 组件 | 脚本 | 描述 |
| :--- | :--- | :--- |
| BoundaryGenerator | `scene/level/game_tile_map.gd` | 挂在 GameTileMap 上，运行时生成边界碰撞 |

**工作流程**:
1. 读取配置的 `walkable_layers`（如 Grass、UnderGrowth 等）
2. 收集所有安全区域的瓦片格子
3. 检测每个格子的四个邻居方向
4. 如果邻居不在安全区域，则在该方向生成边界
5. 合并相邻的边界段（优化碰撞体数量）
6. 生成 `StaticBody2D` + `RectangleShape2D` 碰撞体

**配置参数**:
| 参数 | 类型 | 说明 |
|:---|:---|:---|
| `walkable_layers` | `Array[TileMapLayer]` | 哪些层构成安全行走区域 |
| `require_all_layers` | `bool` | false=任一存在即安全，true=全部存在才安全 |
| `boundary_mode` | `BoundaryMode` | OUTER_ONLY/INNER_ONLY/BOTH |
| `merge_segments` | `bool` | 是否合并相邻碰撞段（优化性能） |
| `collision_layer` | `int` | 碰撞层（默认1=Wall） |

**支持的地图结构**:
- 水铺满底层 + 草地在上方（OUTER_ONLY）
- 草地中的水洞（INNER_ONLY）
- 多个装饰层叠加（多层检测）

**复用方式**: 复制 GameTileMap 节点到其他关卡，修改 `walkable_layers` 指向新层即可

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
- `test_scene_npc_guide.tscn`: Guide NPC（对话系统）测试
- `test_scene_objects_rock.tscn`: 石头物体测试
- `test_scene_objects_tree.tscn`: 树木物体测试
- `test_scene_save_data.tscn`: 存档系统测试
- `test_scene_dialogue.tscn`: 对话系统测试
- `test_scene_chest.tscn`: 宝箱提交奖励系统测试
