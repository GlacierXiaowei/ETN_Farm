# AI_CONTEXT.md - 输入控制系统文档

## 文档说明
本文档记录输入控制系统的设计思路、实现细节和使用方法，供后续 AI 维护参考。

---

## 修改历史

### 2026-02-16 - 输入控制系统改进

#### 问题背景
之前的输入控制系统存在一个问题：点击 UI 时会触发鼠标左键的游戏动作（如使用工具）。这导致玩家在点击工具栏或物品栏时，游戏角色会同时执行对应的工具操作。

#### 解决思路
采用 **双重保险** 策略：
1. **Godot 原生机制**：利用 Control 节点的 mouse_filter 默认 STOP 模式阻止事件传递
2. **代码逻辑保险**：在 GameInputEvent 和 Player 中添加模式检查

#### 具体修改

##### 1. GameInputEvent.gd (`script/InputManager/game_input_events.gd`)
在以下函数中添加模式检查，非 GAMEPLAY 模式时返回无效值：

```gdscript
static func use_tool() -> bool:
    # 检查游戏模式，非GAMEPLAY模式下不允许使用工具
    if current_mode != Mode.GAMEPLAY:
        return false
    # ... 原有逻辑

static func undo_use_tool() -> bool:
    # 检查游戏模式，非GAMEPLAY模式下不允许撤销工具
    if current_mode != Mode.GAMEPLAY:
        return false
    # ... 原有逻辑

static func use_tool_select() -> int:
    # 检查游戏模式，非GAMEPLAY模式下不允许切换工具
    if current_mode != Mode.GAMEPLAY:
        return -1
    # ... 原有逻辑
```

##### 2. Player.gd (`scene/characters/player/player.gd`)
在 `_unhandled_input` 函数开头添加模式检查：

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    ## 如果当前不是GAMEPLAY模式，不处理任何游戏输入
    if GameInputEvent.current_mode != GameInputEvent.Mode.GAMEPLAY:
        return
    # ... 原有逻辑
```

#### 使用方法

##### 切换输入模式

```gdscript
# 启用游戏输入（默认状态）
GameInputEvent.set_mode(GameInputEvent.Mode.GAMEPLAY)

# 禁用游戏输入（UI交互模式）
GameInputEvent.set_mode(GameInputEvent.Mode.UI)

# 过场动画模式
GameInputEvent.set_mode(GameInputEvent.Mode.CUTSCENE)

# 完全禁用输入
GameInputEvent.set_mode(GameInputEvent.Mode.DISABLED)
```

##### 使用场景示例

**打开菜单时禁用游戏输入：**
```gdscript
func open_menu():
    GameInputEvent.set_mode(GameInputEvent.Mode.UI)
    menu.visible = true

func close_menu():
    menu.visible = false
    GameInputEvent.set_mode(GameInputEvent.Mode.GAMEPLAY)
```

**对话框弹出时：**
```gdscript
func show_dialog(text: String):
    GameInputEvent.set_mode(GameInputEvent.Mode.UI)
    dialog.show_text(text)
    await dialog.closed
    GameInputEvent.set_mode(GameInputEvent.Mode.GAMEPLAY)
```

#### 注意事项

1. **UI 节点无需修改**：Godot 4.x 中 Control 节点的默认 `mouse_filter` 为 STOP，会自动阻止事件传递
2. **双重保险机制**：
   - 第一层：MouseFilter STOP 阻止 UI 区域的鼠标事件传递到下层
   - 第二层：GameInputEvent.Mode 检查确保非 GAMEPLAY 模式下不会执行游戏逻辑
   - 第三层：Player._unhandled_input 检查作为额外保护
3. **键盘输入也受控**：通过 Mode 检查，键盘快捷键（1-9切换工具）也会被正确禁用
4. **性能优化**：`set_mode()` 会调用 `player.set_process_unhandled_input()` 完全禁用 `_unhandled_input` 处理

#### 设计优点

1. **可靠性高**：多重保护机制，即使一层失效还有其他层保护
2. **易于维护**：集中的模式管理，代码逻辑清晰
3. **扩展性强**：可轻松添加新模式（如 PAUSE、SETTINGS 等）
4. **Godot 原生**：充分利用引擎特性，无需额外开销

---

## 系统架构

### 输入流程图

```
用户输入
    │
    ├─► UI 区域（MouseFilter STOP）
    │       └─► 事件被捕获，不传递到下层的游戏世界
    │
    └─► 游戏世界区域
            │
            ├─► Player._unhandled_input()
            │       └─► 检查 GameInputEvent.current_mode
            │               ├─► != GAMEPLAY：直接返回，不处理
            │               └─► == GAMEPLAY：缓存请求
            │
            └─► GameInputEvent.use_tool() / use_tool_select() / undo_use_tool()
                    └─► 再次检查 current_mode
                            ├─► != GAMEPLAY：返回 false/-1
                            └─► == GAMEPLAY：执行逻辑
```

### 模式状态机

```
                    set_mode(GAMEPLAY)
    DISABLED ◄────────────────────────────────────► GAMEPLAY
       ▲                                               │
       │                                               │
       │              set_mode(DISABLED)              │
       │                                               │
       │                                               │
    UI ◄─────────── set_mode(UI) ─────────────────►
       │                                               │
       │              set_mode(CUTSCENE)              │
       └──────────────────────────────────────────────► CUTSCENE
```

### 关键函数说明

| 函数 | 文件 | 作用 | 修改说明 |
|------|------|------|----------|
| `set_mode(mode)` | GameInputEvent | 切换输入模式，控制玩家输入处理 | 调用时会启用/禁用 Player 的 _unhandled_input |
| `use_tool()` | GameInputEvent | 消耗并使用工具请求 | 新增：非 GAMEPLAY 模式返回 false |
| `undo_use_tool()` | GameInputEvent | 消耗并撤销工具请求 | 新增：非 GAMEPLAY 模式返回 false |
| `use_tool_select()` | GameInputEvent | 消耗并切换工具 | 新增：非 GAMEPLAY 模式返回 -1 |
| `movement_input()` | GameInputEvent | 获取移动输入 | 已存在检查，保持不变 |
| `_unhandled_input()` | Player | 处理原始输入事件 | 新增：开头检查模式，非 GAMEPLAY 直接返回 |

---

## 调试建议

1. **验证 MouseFilter**：检查 UI 根节点是否为 PanelContainer 或 Control，确认继承默认 STOP 模式
2. **添加日志**：在切换模式时打印日志，确认模式切换正确
   ```gdscript
   static func set_mode(mode: Mode) -> void:
       print("Input mode changed from ", current_mode, " to ", mode)
       current_mode = mode
       # ...
   ```
3. **测试覆盖**：
   - 点击工具栏/物品栏时不应触发游戏动作
   - 在 UI 显示时按 1-9 不应切换工具
   - 关闭 UI 后游戏输入应恢复正常
   - 过场动画时所有输入都应被禁用

---

## 未来扩展

### 可能的新模式

```gdscript
enum Mode {
    GAMEPLAY,
    UI,
    CUTSCENE,
    DISABLED,
    PAUSE,          # 暂停菜单
    INVENTORY,      # 库存界面（可能需要不同的输入映射）
    DIALOG,         # 对话系统
    BUILD_MODE,     # 建筑模式
}
```

### 输入重映射

可以为不同模式设置不同的输入映射：
```gdscript
static func set_mode(mode: Mode) -> void:
    current_mode = mode
    match mode:
        Mode.GAMEPLAY:
            InputMap.load_from_project_settings()
        Mode.INVENTORY:
            # 加载库存界面专用输入映射
            pass
```

---

## 相关文件

- `script/InputManager/game_input_events.gd` - 输入管理核心
- `scene/characters/player/player.gd` - 玩家输入处理
- `AI_CONTEXT.md` - 本文档
- `PROJECT_CONTEXT.md` - 项目整体架构文档
