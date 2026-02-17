# ETN_PROJECT.md - 校园RPG存档系统设计文档

## 📋 项目概述

这是一个以**任务、好感度和剧情**为导向的校园RPG游戏存档系统设计方案。

**核心设计理念：**
- 存档是**系统行为**，玩家不能手动存档
- 玩家只能**读档回溯剧情**
- 自动存档保证数据不丢失，剧情存档提供回溯点

---

## 🎯 存档系统架构

### 存档类型区分

| 存档类型 | 创建者 | 用户可见 | 用途 | 存储位置 | 云同步 |
|---------|--------|---------|------|---------|--------|
| **自动存档** | 系统 | ❌ 不可见 | 防止数据丢失，异常恢复 | `user://auto_save/` | ❌ 不上传 |
| **剧情存档** | 系统 | ✅ 可读档 | 回溯到关键剧情节点 | `user://story_saves/` | ✅ 上传 |
| **游戏设置** | 系统 | ✅ 可见 | 音量、键位等 | `user://settings/` | ✅ 上传 |

### 文件组织结构

```
user://
├── auto_save/
│   ├── auto_001.tres          # 自动存档槽位1（循环覆盖）
│   ├── auto_002.tres          # 自动存档槽位2
│   └── auto_003.tres          # 自动存档槽位3
│
├── story_saves/
│   ├── save_ch1_001_start.tres           # 第一章-开学典礼
│   ├── save_ch1_002_meet_senpai.tres     # 第一章-初遇学姐
│   ├── save_ch1_003_festival.tres        # 第一章-学园祭
│   ├── save_ch2_001_start.tres           # 第二章开始
│   └── save_index.json                   # 存档索引（元数据）
│
└── settings/
    └── game_settings.tres     # 游戏设置
```

---

## 💾 数据结构设计

### 1. SaveDataContainer（存档数据容器）

```gdscript
class_name SaveDataContainer
extends Resource

# ========== 存档元数据 ==========
@export var save_id: String                    # 唯一ID："story_ch1_001"
@export var save_type: String                  # "auto" | "story"
@export var timestamp: int                     # Unix时间戳
@export var play_time_seconds: int             # 累计游戏时长
@export var chapter_id: String                 # 章节ID
@export var story_point_name: String           # 剧情节点名称
@export var user_note: String                  # 用户自定义备注
@export var screenshot_path: String            # 缩略图路径

# ========== 核心游戏状态 ==========
@export var global_state: GlobalStateResource
@export var current_scene_path: String
@export var player_position: Vector2
@export var player_facing: Vector2

# ========== 场景和NPC数据 ==========
@export var scene_states: Dictionary           # {场景路径: SceneStateResource}
@export var npc_states: Dictionary             # {npc_id: NPCStateResource}

# ========== 完整性校验 ==========
@export var checksum: String                   # SHA256哈希
```

### 2. GlobalStateResource（全局状态）

```gdscript
class_name GlobalStateResource
extends Resource

# 时间系统
@export var game_day: int
@export var game_hour: int
@export var game_minute: int
@export var total_play_minutes: int

# 任务系统
@export var active_quests: Array[QuestData]
@export var completed_quest_ids: Array[String]
@export var quest_progress: Dictionary
@export var quest_flags: Dictionary

# 好感度系统
@export var affection_data: Dictionary
# {"npc_001": {"value": 50, "rank": "friend", "flags": []}}

# 对话系统
@export var completed_dialogues: Array[String]
@export var dialogue_flags: Dictionary
@export var unlocked_topics: Array[String]

# 剧情标记（关键！）
@export var story_flags: Dictionary
# {"met_headmaster": true, "know_secret": false}

# 玩家数据
@export var inventory: Array[ItemData]
@export var money: int
@export var player_stats: Dictionary
```

### 3. NPCStateResource（NPC差异化状态）

```gdscript
class_name NPCStateResource
extends Resource

@export var npc_id: String
@export var npc_type: String                   # "main" | "side" | "background"

# ========== 主线NPC完整数据 ==========
@export var current_location: String
@export var current_schedule_index: int
@export var current_dialogue_node: String
@export var affection_value: int
@export var affection_rank: String
@export var personal_flags: Dictionary

# ========== 支线NPC关键数据 ==========
@export var side_quest_state: String
@export var key_dialogues_completed: Array[String]

# ========== 路人NPC最小数据 ==========
@export var has_met_player: bool
@export var interaction_count: int
```

---

## 🔧 SaveManager API

```gdscript
class_name SaveManager
extends Node

# ========== 常量 ==========
const MAX_AUTO_SAVES = 3
const MAX_STORY_SAVES_PER_CHAPTER = 50
const AUTO_SAVE_PATH = "user://auto_save/"
const STORY_SAVE_PATH = "user://story_saves/"

# ========== 剧情存档（系统调用） ==========
func create_story_save(story_point_id: String, story_point_name: String, user_note: String = "") -> String
func load_story_save(save_id: String) -> bool
func get_story_save_list(chapter_id: String = "") -> Array[SaveInfo]
func delete_story_save(save_id: String) -> bool

# ========== 自动存档（系统内部） ==========
func create_auto_save() -> void
func load_latest_auto_save() -> bool

# ========== 存档验证 ==========
func verify_save_integrity(save_id: String) -> bool

# ========== 截图功能 ==========
func capture_screenshot() -> Image
```

---

## 🔄 存档触发时机

### 必须存档的剧情节点
- 章节开始/结束
- 重要对话后（表白、剧情揭示等）
- 关键选择前（让玩家可以回退重选）
- 获得重要物品后
- 第一次进入新场景

### 自动存档触发时机
- 游戏正常退出
- 切换场景时
- NPC对话开始时
- 重要剧情事件发生时

---

## 🎭 NPC管理

### NPC数量预估
- **总数**：约50个（不超过100个）
- **主线NPC**：约5%（2-3个）
- **支线NPC**：约25%（12-13个）
- **路人NPC**：约70%（35个左右）

### 差异化存储策略
- **主线NPC**：保存所有状态（位置、日程、好感度、对话节点等）
- **支线NPC**：保存关键状态（位置、支线任务状态、关键对话）
- **路人NPC**：最小化存储（是否见过玩家、交互次数）

### 对象池设计
```gdscript
# 场景加载时只生成当前场景需要的NPC
var npc_pool: Dictionary = {}  # npc_id -> NPC实例

func spawn_npc(npc_id: String, state: NPCStateResource):
    if state.current_location == current_scene_path:
        # 生成NPC并应用状态
```

---

## 🎨 UI设计

### 读档界面信息展示
- 缩略图（当时的游戏画面）
- 章节和剧情点名称
- 游戏内日期和时间
- 累计游戏时长
- 当前场景
- 主要任务进度
- 关键NPC好感度
- 用户自定义备注

### 存档命名格式
```
story_ch{章节号}_{序号}_{剧情点ID}
例：story_ch1_001_start, story_ch1_002_meet_senpai
```

---

## 🛡️ 防修改方案

### 简单校验
1. **SHA256哈希**：存档时计算并存储，读取时验证
2. **文件头标记**：添加魔数快速识别
3. **版本号**：存档格式变更时兼容处理

```gdscript
func calculate_checksum(data: SaveDataContainer) -> String:
    var bytes = var_to_bytes(data)
    return sha256(bytes)
```

---

## 🗺️ 实施路线图

### 第一阶段：基础框架
- [ ] 创建所有Resource类
- [ ] 创建SaveManager单例
- [ ] 测试场景验证数据结构

### 第二阶段：核心功能
- [ ] 实现剧情存档（create_story_save）
- [ ] 实现读档功能（load_story_save）
- [ ] 实现自动存档（3槽位循环）
- [ ] 截图功能

### 第三阶段：NPC系统
- [ ] NPC差异化存储
- [ ] NPCManager集成
- [ ] 场景加载时恢复NPC

### 第四阶段：UI和优化
- [ ] 读档界面
- [ ] 存档验证
- [ ] 异步保存

### 第五阶段：测试和完善
- [ ] 边界情况处理
- [ ] 异常恢复
- [ ] 二周目数据继承

---

## ⚠️ 关键设计决策

### 已确认的选择
1. **存档格式**：`.tres`（文本格式，方便调试）
2. **存储上限**：自动存档3个，剧情存档每章50个
3. **云同步**：只同步剧情存档和游戏设置，不同步自动存档
4. **NPC数量**：约50个，差异化存储
5. **防修改**：简单SHA256校验
6. **二周目**：支持继承部分数据（待详细设计）
7. **读档限制**：只能在特定时间和地点读档

### 待确认事项
- [ ] 具体剧情存档触发点列表
- [ ] 读档地点和条件设计
- [ ] 二周目继承数据的具体范围
- [ ] 是否需要章节选择功能（通关后）
- [ ] 截图分辨率（原分辨率 vs 压缩）

---

## 📝 讨论记录

### 2026-02-17 存档系统需求讨论
- 确定存档为系统行为，玩家只能读档回溯
- 设计三级NPC存储策略（主线/支线/路人）
- 确定自动存档3槽位，剧情存档50上限
- 明确云同步策略（只同步剧情存档）
- 选择.tres格式，保留调试便利性

---

**文档版本**: 1.0  
**最后更新**: 2026-02-17  
**下次讨论**: 待确认具体实现细节
