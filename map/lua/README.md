# 魔兽 Dota Lua 库 — 构建架构文档

> **⚠️ 警告：本文档仅供库的修改/创造者维护，普通使用者无需也不应修改此文件内容。**
> 任何对架构层级的破坏性修改（如直接修改 api 层、打乱加载顺序、跨层逆向引用）可能导致整个库不可用。

---

## 一、总览

```
map/lua/
├── lua.lua              ← 入口文件：按顺序加载 api → Base
├── api/                  ← [底层代码层] 只暴露，不修改，不可直接用于业务代码
│   ├── common.lua        →   全局表 cj      (Jass Common API 封装)
│   ├── blizzard.lua      →   全局变量 bj_*  (暴雪原生常量) + FRAME_ALIGN_* / MOUSE_ORDER_*
│   ├── KK_japi.lua       →   全局表 cdz     (DzAPI/KKAPI 扩展，含 DzFrame* 系列)
│   ├── deBug.lua         →   调试工具 (print / error_handle)
│   └── LeakDetect.lua    →   游戏资源泄露检测（默认开启，UI TXT 播报）
│
└── Base/                 ← [基础库层] 引用 api 层构建，供 AI/用户使用者调用
    ├── Time.lua          →   定时器系统（含真计时器方法）
    ├── Player.lua        →   玩家系统
    ├── Unit.lua          →   单位系统
    ├── Hero.lua          →   英雄系统
    ├── Skill.lua         →   技能系统
    ├── Item.lua          →   物品系统
    ├── Group.lua         →   单位组系统
    ├── Event.lua         →   事件系统
    ├── Destroyable.lua   →   可破坏物系统（cj.CreateDestructable 封装，生命/伤害/特效）
    ├── Effect.lua        →   特效系统
    ├── Lightning.lua     →   闪电效果
    ├── Sound.lua         →   音效系统
    ├── Texture.lua       →   纹理系统
    ├── TextTag.lua       →   文字标签
    ├── Camera.lua        →   镜头系统
    ├── CameraScroll.lua  →   滚轮视距调整（鼠标滚轮缩放）
    ├── Dialog.lua        →   对话框系统
    ├── Frame.lua         →   FDF 框架控件系统
    ├── Quest.lua         →   任务系统
    ├── Rect.lua          →   区域系统
    ├── Terrain.lua       →   地形系统
    ├── Weather.lua       →   天气系统
    ├── Pool.lua          →   对象池
    ├── Sync.lua          →   数据同步
    ├── Obj.lua           →   物编数据读取（Obj.Item/Unit/Ability）
    ├── SystemMessage.lua →   系统消息提示（屏幕中央，带渐隐）
    └── Multiboard.lua    →   多面板 / 排行榜
```

**可破坏物系统说明：**
- `Destroyable.lua` 是可破坏物的基础 OOP 层，提供完整的元表对象和方法封装
- 所有可破坏物的破坏/销毁操作都通过对象方法实现：`:takeDamage()`, `:destroy()`, `:heal()`, `:onDamage()`, `:onDestroy()`
- 可破坏物状态管理：`:isValid()`, `:IsDestroyed()`, `:getHpPercent()`, `:getRemainingHp()`
- 伤害类型支持：普通伤害、穿透伤害、致命伤害、治疗修复
- 特效系统：受伤特效、破坏特效自动播放

---

## 二、三层架构定义

### 第 1 层：入口层 — `lua.lua`

**职责：**
- 按**固定顺序** require 所有模块：**先 api 层（前 4 个），再 Base 层，最后加载 api/LeakDetect**
- 自身不包含业务逻辑

**加载顺序规则：**
```lua
-- 1. api 层（底层必须最先加载）
require "lua.api.common"      -- 暴露 cj 全局表
require "lua.api.blizzard"    -- 暴露 bj_* 全局常量
require "lua.api.KK_japi"     -- 暴露 cdz 全局表
require "lua.api.deBug"       -- 调试工具

-- 2. Base 层（依赖 api 层已就绪）
require "lua.Base.Time"
require "lua.Base.Sync"
require "lua.Base.Player"
-- ... 其余 Base 模块

-- 3. 底层资源泄露检测（最后加载）
require "lua.api.LeakDetect"
```

### 第 2 层：底层代码层 — `api/`

**定义：**
- `common.lua` — 将 Jass 原生 API（来自 `jass.common`）注册到全局表 `cj`，例如 `cj.CreateUnit`, `cj.GetUnitX`
- `blizzard.lua` — 将 Blizzard.j 常量（来自 `jass.globals`）注册为 `bj_*` 全局变量
- `KK_japi.lua` — 将 DzAPI / KKAPI 扩展函数注册到全局表 `cdz`，例如 `cdz.DzSetUnitName`
- `deBug.lua` — 调试运行时环境，接管 `print` 和错误处理
- `LeakDetect.lua` — 游戏资源泄露检测，钩住各资源类的创建/销毁，周期性扫描泄露并播报

**铁律：**
- ✅ **只读层** — api 层代码**不可修改**（除非重构整个架构）
- ✅ **只暴露** — api 层只负责注册全局变量/函数到 `cj`、`cdz`、`bj_*` 等命名空间
- ❌ **不可直接用于业务代码** — 不能在任何游戏逻辑代码中直接调用 `cj.CreateUnit(...)`，必须通过 Base 层的 OOP 封装
- ❌ **不可被逆向引用** — api 层的文件不能 `require` Base 层的任何文件

### 第 3 层：基础库层 — `Base/`

**定义：**
- 通过引用 **api 层暴露的函数和常量**（`cj.xxx`、`cdz.xxx`、`bj_*`）构建面向对象的模块
- 每个文件是一个独立的类/模块，提供链式调用和语义化接口

**引用规则：**
- 只能引用：
  - `cj.xxx` — 来自 `api/common.lua`
  - `cdz.xxx` — 来自 `api/KK_japi.lua`
  - `bj_*` — 来自 `api/blizzard.lua`
  - Base 层其他模块（模块间可互相引用）
- 禁止引用：
  - 原始的 `jass.common` / `jass.japi` / `jass.globals` / `jass.runtime` 等底层 require

**使用方式：**
```lua
-- ✅ 正确：通过 Base 层接口
local u = Unit:new(player, 'hfoo', 0, 0, 270)
u:setLife(500):setName("步兵")

-- ✅ 正确：通过 Frame 层接口
local f = Frame:new("EscMenuBackdrop", cdz.DzGetGameUI())
f:setSize(0.4, 0.3):setAbsolutePoint(FRAME_ALIGN_CENTER, 0.4, 0.3)
f:show()

-- ❌ 错误：绕过 Base 直接调用 api 层
local h = cj.CreateUnit(pl, 1741932848, 0, 0, 270)
cj.SetWidgetLife(h, 500)

-- ❌ 错误：直接 require 底层库
JassCommon = require "jass.common"

-- ✅ 正确：fromHandle 方法
local player = Player.fromHandle(Player.loc())
-- ❌ 错误：fromHandle 方法
local player = Player:fromHandle(Player.loc())

```
---

## 三、命名空间与全局表

| 全局符号 | 来源文件 | 说明 |
|---------|----------|------|
| `cj.*` | `api/common.lua` | Jass 原生 API（700+ 函数） |
| `bj_*` | `api/blizzard.lua` | Blizzard.j 常量（~200 个） |
| `cdz.*` | `api/KK_japi.lua` | DzAPI/KKAPI 扩展（723+ 个函数，含 DzFrame*） |
| `c2i()`, `i2c()` | `api/common.lua` | 字符串/整数 ID 互转 |
| `FRAME_ALIGN_*` | `api/blizzard.lua` | 框架锚点常量（0-8） |
| `MOUSE_ORDER_*` | `api/blizzard.lua` | 鼠标事件常量 |
| `GAME_KEY_*` | `api/blizzard.lua` | 键盘按键常量 |
| `TEXT_ALIGN_*` | `api/blizzard.lua` | 文本对齐常量 |
| `Unit`, `Player`, `Timer`, `Frame`, ... | `Base/*.lua` | 基础类（每个文件一个） |

---

## 四、模块间依赖关系

```
                    ┌─────────────────────────┐
                    │   AI / 用户 使用者代码    │
                    │  (游戏逻辑 / 地图脚本)    │
                    └─────────┬───────────────┘
                              │
                    ┌─────────▼───────────────┐
                    │      Base 基础库层      │
                    │  Unit, Player, Event..  │
                    │  (OOP 封装 / 语义接口)   │
                    └─────────┬───────────────┘
                              │ 仅引用 cj./cdz./bj_
                    ┌─────────▼───────────────┐
                    │      api 底层代码层      │
                    │  common / blizzard /    │
                    │  KK_japi / deBug /      │
                    │  LeakDetect             │
                    │  (Jass 原生 / 扩展封装)  │
                    └─────────┬───────────────┘
                              │
                    ┌─────────▼───────────────┐
                    │   魔兽争霸 3 引擎        │
                    │  (jass.common / runtime) │
                    └─────────────────────────┘
```

**核心原则：单向依赖，不可反向。**
- 使用者代码 → Base → api → 引擎
- api 层永不依赖 Base 层
- Base 层永不依赖使用者代码

---

## 五、入口加载顺序（lua.lua）

加载顺序至关重要，不可随意调换：

```
 1. api/common.lua              — 先注册 cj 表，后面的模块才能用
 2. api/blizzard.lua            — 注册 bj_* 常量 + FRAME_ALIGN / MOUSE_ORDER 等
 3. api/KK_japi.lua             — 注册 cdz 扩展表
 4. api/deBug.lua               — 调试工具（需依赖部分 jass 已就绪）
 5. Base/Time.lua               — 定时器优先，多个模块依赖 Timer
 6. Base/Sync.lua               — 数据同步
 7. Base/Player.lua             — 玩家系统
 8. Base/Sound.lua              — 音效
 9. Base/Texture.lua            — 纹理
10. Base/Lightning.lua          — 闪电
11. Base/Weather.lua            — 天气
12. Base/Camera.lua             — 镜头
13. Base/CameraScroll.lua       — 滚轮视距调整
14. Base/Event.lua              — 事件系统
15. Base/TextTag.lua            — 文字标签
16. Base/Rect.lua               — 区域
17. Base/Unit.lua               — 单位（依赖 Timer/Player/Event）
18. Base/Group.lua              — 单位组（依赖 Unit）
19. Base/Hero.lua               — 英雄（依赖 Unit）
20. Base/Skill.lua              — 技能（依赖 Unit/Hero）
21. Base/Item.lua               — 物品（依赖 Unit/Timer）
22. Base/Frame.lua              — FDF 框架控件（无 Base 依赖）
23. Base/Pool.lua               — 对象池
24. Base/Obj.lua                — 物编数据读取
25. Base/Dialog.lua             — 对话框
26. Base/Quest.lua              — 任务
27. Base/Terrain.lua            — 地形
28. Base/SystemMessage.lua      — 系统消息提示
29. Base/Effect.lua             — 特效（依赖 Timer）
30. Base/Multiboard.lua         — 多面板 / 排行榜

最后加载（底层资源泄露检测）：
31. api/LeakDetect.lua          — 游戏资源泄露检测（默认开启，UI TXT 播报）
```

---

## 六、扩展新模块的规范

### 新增 Base 模块步骤

1. 在 `Base/` 下新建 `.lua` 文件
2. 仅引用 `cj.xxx` / `cdz.xxx` / `bj_*` / 已有 Base 模块
3. 在 `lua.lua` 末尾追加 require 语句
4. 遵循本库的命名和风格规范

### 代码风格

```lua
-- 模块声明
ModuleName = {}
ModuleName.__index = ModuleName

-- 构造
function ModuleName:new(...)
    local obj = { ... }
    setmetatable(obj, ModuleName)
    return obj
end

-- 方法（链式返回 self）
function ModuleName:doSomething(...)
    -- 仅通过 cj./cdz./bj_ 访问底层
    return self
end

-- 静态方法（类方法）
function ModuleName.someStatic(...)
end

-- 创建 单位/英雄
local U , H = Unit:new(...)  -- 创建单位是返回的第一个值为单位第二个是英雄
local H , U = Hero:new(...)  -- 创建英雄是返回的第一个值为英雄第二个是单位


```

---

## 七、安全与约束

1. **api 层不可修改** — 任何对 `api/common.lua`、`api/blizzard.lua`、`api/KK_japi.lua`、`api/deBug.lua`、`api/LeakDetect.lua` 的修改都需要整个架构评审
2. **不直接调用底层 API** — 业务代码中不应出现 `cj.CreateUnit`，应使用 `Unit:new(...)`
3. **不绕过 Base 层** — 使用者代码不应直接 `require "jass.common"`
4. **加载顺序不可乱** — `lua.lua` 中必须先 api 后 Base，Base 内部有依赖关系的（如 Unit 依赖 Player/Timer）需保持顺序
5. **创建 LUA.md 的修改者** — 一旦架构确定，后续只应由库的修改/创造者维护此文件

---

## 八、ID引用规范

1.根目录\table 下的ini 文件是自定义物理编辑器的配置文件，用于配置物理编辑体等参数。

## 九、严禁直接调用底层 API
1. 业务代码中不应出现 `cj.CreateUnit`，应使用 `Unit:new(...)`
2. 业务代码中不应出现 `cj.CreateGroup`，应使用 `Group:new(...)`
3. 业务代码中不应出现 `cj.CreateImage`，应通过 `Obj.Unit/Item/Ability` 读取物编数据

..其他 API 优先使用Base层的实现


*本文档由库构建者维护，反映了 `map/lua/` 下整个 Dota Lua 库的架构定义、分层规则和构建规范。*
*最后更新：2026-07-23*
*by:1663171114*