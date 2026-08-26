---
name: wc3-lua-coding
description: 当用户编写、修改或讨论基于魔兽争霸3（War3）引擎的 Lua 脚本（YDWE / w3x2lni / jass2lua / 类 OOP 封装项目等）时启用。指导优先使用项目自身提供的面向对象封装层（通常位于 Base/、core/、lib/、src/ 等目录），而非直接调用 cj./cdz./bj_* 底层 API；遵循「底层封装层 → OOP 基础库层 → 业务代码」的三层架构。
---

# 魔兽争霸 3 Lua 脚本开发规范

## 适用场景

在以下场景中使用本 skill：

- 用户在**任意 War3 Lua 地图/项目**中要求编写、修改、重构 Lua 代码。
- 涉及魔兽地图的游戏逻辑、英雄技能、物品效果、UI、事件、伤害计算、触发器、计时器等。
- 用户提到项目里的 `Base`、`core`、`lib`、某 OOP 框架，或要求"用面向对象方式写"。

如果只是在讨论纯算法、与外部无关的逻辑，可不强制套用；但只要涉及 War3 引擎交互，就应优先走 OOP 封装层。

## 核心原则

1. **先识别项目的 OOP 封装层，并优先用它**。不同 War3 Lua 项目的封装层位置和命名不同（如 `map/lua/Base/`、`core/`、`lib/`、`src/`），但形态一致：每个模块是一个类，提供 `Xxx:new(...)` 构造、`obj:method(...)` 实例方法、`Xxx.static(...)` 静态方法，底层调用被收敛在 `cj.*` / `cdz.*` / `bj_*` 等全局表背后。
2. **禁止在业务代码里直接调用底层 API 写逻辑**。业务代码中不应直接写 `cj.CreateUnit`、`cj.AddSpecialEffect`、`cj.CreateGroup`、`cj.SetWidgetLife`、`cj.TriggerRegister...`、`cdz.DzCreateFrame` 等；创建/操作单位、玩家、英雄、计时器、特效、事件、物品、单位组、UI 框架等，都应通过项目封装层提供的类。
3. **禁止业务代码直接 `require "jass.common"` / `require "jass.japi"` / `require "jass.globals"`**。底层只在封装层内部被引用；使用者代码只依赖封装层暴露的全局类与 `cj./cdz./bj_` 命名空间。
4. **尊重项目自带的架构文档**。写新模块、改加载顺序、跨层引用前，先找并阅读项目根的 `README.md` / `ARCHITECTURE.md` / 顶部注释，了解分层定义、入口加载顺序、命名空间与扩展规范。
5. **新增模块只放进 OOP 基础库层**，并在入口文件（`lua.lua` / `main.lua` / `init.lua` 等）按既定顺序 `require`；不要塞进底层封装层。
6. **保持面向对象风格**：构造用 `ClassName:new(...)`，静态/工厂方法用 `ClassName.method(...)`，实例方法用 `obj:method(...)`，链式调用返回 `self`。
7. **异步判断必须包裹本地专属操作**：凡涉及特效显示、镜头控制、UI/界面操作、声音播放、文字标签创建/修改、模型替换、本地文件读写等**仅影响本地客户端、不影响游戏同步状态**的操作，必须用 `if GetLocalPlayer() == <玩家对象> then ... end` 包裹。通过 `Unit:new`、`Group:forEach` 等同步操作（影响所有玩家）**不加**异步判断。异步判断内允许直接调用底层 `cj.*` / `cdz.*`，因为封装层可能内部已有判断，但业务代码层面仍须显式包裹。

## 如何识别项目的 OOP 封装层

动手前按此流程探测（用 Glob/Grep 扫描项目 lua 目录）：

1. **找入口文件**：`lua.lua`、`main.lua`、`init.lua`、第一个被加载的文件。看它 `require` 了哪些模块，顺序即加载层级。
2. **找底层封装层**：搜索 `cj =` / `cdz =` / `bj_*` 的注册处（通常文件短、只做 `setmetatable`/赋值、无业务逻辑）。这是最底层，只读。
3. **找 OOP 基础库层**：搜索同时满足以下特征的文件：
   - 形如 `Xxx = {}` 且 `Xxx.__index = Xxx`
   - 含 `function Xxx:new(...)` 或 `function Xxx.fromHandle(...)` 这类构造/工厂
   - 内部引用 `cj.` / `cdz.` / `bj_`，但对外暴露语义化方法
   这些文件所在目录（如 `Base/`、`core/`）就是要优先使用的封装层。
4. **找使用示例**：在业务脚本里看别人怎么调用（例如 `Unit:new(...)`、`Timer:new(...)`），沿用同一套类名与风格，不要另起炉灶。

> 示例：在《电炸园区》项目中，该封装层即 `map/lua/Base/`（Unit/Player/Timer/Effect/Event/Item/Frame/Group/Hero/Skill 等），入口为 `map/lua/lua.lua`，架构说明见 `map/lua/README.md`。但本规范不绑定任何单一项目，仅以它为例说明形态。

## 通用映射表（按职责找封装类）

下表按"职责 → 优先使用的封装类"给出典型形态。**具体类名以你所探测到的项目为准**，不要假设下列名字逐一存在：

| 职责 | 优先使用（OOP 封装层） | 严禁在业务代码里直接写（底层） |
|---|---|---|
| 单位 | `Unit:new(player, id, x, y, face)`、`u:setLife(v)`、`u:destroy()` | `cj.CreateUnit`、`cj.SetWidgetLife`、`cj.RemoveUnit` |
| 玩家 | `Player:new(0)`、`p:send(msg)`、`Player.sendAll(msg)`、`Player.loc()` | `cj.Player(0)`、`cj.DisplayTextToPlayer` |
| 英雄 | `Hero:new(p, id, x, y)`、英雄相关方法 | `cj.CreateUnit` 后当英雄裸用 |
| 计时器 | `Timer:new(timeout, periodic, cb)` | `cj.CreateTimer`、`cj.TriggerRegisterTimerEvent` |
| 事件 | `Event:new(target, EVENT_*, fn)`、`Event.anyXxxEvent():register(fn)` | `cj.TriggerRegister*` 裸写 |
| 物品 | `Item:new(id, x, y)`、`item:destroy()` | `cj.CreateItem`、`cj.RemoveItem` |
| 特效 | `Effect:new(model, x, y, z, dur)`、`Effect:newAttach(...)` | `cj.AddSpecialEffect`、`cj.DestroyEffect` |
| 单位组 | `Group:new()`、`g:addUnit(u)`、`g:forEach(fn)` | `cj.CreateGroup`、`cj.GroupEnumUnitsInRect` |
| UI 框架 | `Frame:new(type, parent)`、`f:setSize(...):setPoint(...):show()` | `cdz.DzCreateFrame` 裸用 |
| 文字标签 | `TextTag:new(...)` | `cj.CreateTextTag` |
| 系统消息 | 项目提供的消息类（如 `SystemMessage` / `Player:send`） | `cj.DisplayTextToPlayer` |
| 物编读取 | 项目提供的物编类（如 `Obj.Item[id]` / `Obj.Unit[id]`） | 直接读 SLK / `cj.CreateImage` |

### 静态工厂方法的调用约定

- 从 handle 还原对象的方法（常见名 `fromHandle` / `fromHandleId`）是**静态方法，用点号调用**：
  - ✅ `Player.fromHandle(h)`
  - ❌ `Player:fromHandle(h)`
- 部分类（如某些项目里的 `Unit`）会有 `fromHandle` 缓存，保证同一 handle 返回同一 Lua 对象——优先用它而非重新 `:new`。

### 构造返回值约定（需按项目实际核实）

- 不同项目约定不同：有的 `Unit:new` 只返回 Unit；有的 `Hero:new` 返回 `Hero, Unit`；有的 `Player:Hero()` 返回 `Unit, Hero`。**写代码前用 Grep 查该类的 `:new`/工厂定义确认返回值个数与顺序**，不要臆测。

## 异步判断规范

War3 是 C/S 同步架构，所有玩家的游戏状态必须一致。但**视觉/听觉/UI 等纯本地效果**可以在不同客户端独立执行，无需同步。这称为"异步操作"。

### 需要异步判断的操作（必须包裹）

| 操作类型 | 典型场景 | 示例 |
|---------|---------|------|
| 特效 | 创建/销毁特效、修改特效颜色/大小 | `Effect:new(...)`、`effect:destroy()` |
| 镜头 | 震动、平移、锁定、FOV 调整 | `cj.CameraSetEQNoiseForPlayer`、`cj.PanCameraToTimed` |
| UI / 界面 | 创建/修改/显示/隐藏 Frame、多面板 | `Frame:new(...)`、`frame:show()`、`cdz.DzFrameShow` |
| 声音 | 播放音效、BGM、3D 声音 | `cj.StartSound`、`cj.PlayMusic` |
| 文字标签 | 创建/修改/销毁 TextTag | `TextTag:new(...)`、`tt:setText(...)` |
| 模型/皮肤替换 | 运行时替换单位模型 | `cj.SetUnitModel`、`cj.AddUnitAnimationProperties` |
| 本地文件读写 | 保存/读取本地设置、屏幕截图 | `cdz.DzFile` 系列 |
| 选择/框选 | 本地玩家选择单位（不触发同步事件时） | `cj.SelectUnit`、`cj.ClearSelection` |
| 小地图 | 小地图信号、图标 | `cj.SetMinimapIcon`、`cj.PingMinimap` |

### 不需要异步判断的操作（禁止包裹）

| 操作类型 | 原因 |
|---------|------|
| 单位创建/移除/移动/属性修改 | 影响游戏同步状态，所有玩家必须一致 |
| 技能释放/伤害计算/金币经验变动 | 核心游戏逻辑，必须同步 |
| 物品创建/拾取/丢弃 | 影响所有玩家可见的游戏世界 |
| 触发器/事件注册 | 事件系统本身是同步的 |
| 单位组/玩家组的遍历与逻辑判断 | 遍历结果影响后续同步逻辑时 |

### 判断 Player 对象是否为主控玩家

在 War3 Lua 中，`GetLocalPlayer()` 返回当前客户端对应的玩家对象。与目标玩家对象比较即可判断：

```lua
-- 标准写法：获取主控玩家
-- 不同项目可能有自己的封装，常见形式：
local PL = Player.loc()         -- 通过项目封装获取本地玩家
-- 或
local PL = cj.GetLocalPlayer()  -- 底层 API

-- 判断：如果当前客户端是目标玩家，执行本地操作
if GetLocalPlayer() == targetPlayer then
    -- 此处为目标玩家的客户端
end
```

### 代码示例

```lua
-- ✅ 正确：特效用异步判断包裹
local u = Unit:new(p, 'hfoo', x, y, 270)
local eff = nil
if GetLocalPlayer() == p:handle() then
    eff = Effect:new("war3mapImported\\HolyLight.mdx", x, y, 0, 2.0)
end

-- ✅ 正确：UI 操作用异步判断
if GetLocalPlayer() == p:handle() then
    local frame = Frame:new("BACKDROP", nil)
    frame:setSize(0.2, 0.1):setPoint("CENTER", nil, "CENTER", 0, 0):show()
end

-- ✅ 正确：镜头震动仅对目标玩家生效
if GetLocalPlayer() == targetPlayer:handle() then
    cj.CameraSetEQNoiseForPlayer(targetPlayer:handle(), 5.0)
end

-- ✅ 正确：选择单位
if GetLocalPlayer() == p:handle() then
    cj.SelectUnit(u:handle(), true)
end

-- ❌ 错误：创建单位放在异步判断内（单位创建必须同步）
if GetLocalPlayer() == p:handle() then
    local u = Unit:new(p, 'hfoo', x, y, 270)  -- 错误！其他玩家看不到这个单位
end

-- ❌ 错误：伤害计算放在异步判断内（会导致不同步/掉线）
if GetLocalPlayer() == p:handle() then
    target:damage(src, 100)  -- 错误！会导致掉线
end

-- ❌ 错误：特效不包裹异步判断（所有玩家都会看到，浪费性能但通常不会掉线）
Effect:new("model.mdx", x, y, 0, 2.0)  -- 应包裹
```

### 异步环境深度规则

以下规则是 War3 异步编程的核心陷阱，违反将直接导致玩家异常掉线。

#### 1. 异步块内禁止同步操作

一旦进入 `if GetLocalPlayer() == xxx then` 块，**内部所有操作均为异步环境**。严禁在块内调用任何同步函数：

| 禁止（同步操作） | 允许（异步操作） |
|---|---|
| `Unit:new(...)` — 单位创建必须同步 | `Frame:show()` / `Frame:hide()` — UI 操作 |
| `target:damage(src, n)` — 伤害计算必须同步 | `Frame:setText(...)` / `Frame:setSize(...)` — UI 属性修改 |
| `Item:new(...)` — 物品创建必须同步 | 读写本地变量的数值/坐标等纯数据 |
| `Hero:new(...)` — 英雄创建必须同步 | `cj.SetUnitScale(...)` — 模型缩放（仅本地视觉） |
| `cj.CreateUnit(...)` — 底层单位创建 | `cj.SelectUnit(...)` / `cj.ClearSelection(...)` — 本地选择 |
| `cj.CreateItem(...)` — 底层物品创建 | `cj.PlayMusic(...)` / `cj.StartSound(...)` — 声音播放 |

异步环境典型用途：**UI 显示/隐藏、数值显示更新、坐标文本刷新、特效播放、镜头控制、声音播放、本地选择**等纯本地视觉效果。

#### 2. 异步 set 后禁止同步 set（掉线元凶）

这是 War3 异步编程中最危险的陷阱。核心规则：

> **如果某个变量在异步环境下被修改（set），之后在同步环境下禁止再次修改该变量，只能读取（get）。否则不同客户端对该变量的值不一致，直接触发玩家异常掉线。**

```lua
-- ❌ 致命错误：异步 set 后同步再 set → 掉线
local data = { value = 0 }

if GetLocalPlayer() == p:handle() then
    data.value = 100  -- 异步 set（仅主控玩家客户端执行）
end
-- 此时 data.value 在不同客户端不一致：主控玩家=100，其他玩家=0

data.value = 200  -- 同步 set → 掉线！各客户端基于不同的旧值计算

-- ✅ 正确做法：异步块内只做纯展示，不改任何后续同步环境会依赖的变量
local displayValue = 0  -- 仅用于 UI 展示的变量

if GetLocalPlayer() == p:handle() then
    displayValue = someLocalCalc()  -- 可以 set，但 displayValue 后续只能在同步环境 get
    frame:setText(tostring(displayValue))  -- 立即用于 UI 展示
end
-- 注意：此后 displayValue 不能再在同步环境 set，只能 get
```

**需要特别注意的隐式 set 场景**：
- 异步块内给 table 的字段赋值，同步环境又修改同一字段
- 异步块内修改全局变量，同步环境又用该变量做条件分支后赋值
- 异步块内通过引用修改对象属性，同步环境又修改同一属性

**安全原则**：异步块内只做纯展示（UI/特效/声音），不修改任何后续同步环境会依赖的变量。如需将异步计算结果反馈到同步环境，必须通过**同步事件**传递（见下文第 3 节）。

#### 3. Frame 的特殊异步规则

Frame（UI 框架）在 War3 中有独特的异步行为：

**Frame 对象本身是异步安全的**：大部分 Frame 函数默认已对所有玩家异步执行，创建/显示/隐藏/修改属性可以在异步和同步环境之间自由使用，不会导致掉线。

```lua
-- ✅ Frame 属性修改在同步/异步环境均可安全使用
frame:show()
frame:hide()
frame:setText("文本")
frame:setSize(0.3, 0.1)
frame:setPoint("CENTER", nil, "CENTER", 0, 0)
```

**Frame 的点击事件和鼠标事件是异步事件**：事件回调运行在异步环境中，**无法在回调内直接调用同步函数**（如创建单位、造成伤害、修改金币等）。

```lua
-- ❌ 错误：Frame 点击回调内直接调用同步操作
frame:onClick(function()
    local u = Unit:new(p, 'hfoo', x, y, 270)  -- 异步环境禁止同步操作！
    target:damage(src, 100)                     -- 异步环境禁止同步操作！
end)
```

**解决方案：通过同步事件回到同步环境**。在异步事件回调中触发一个同步事件，让执行流回到同步环境后再执行同步操作。不同项目实现同步事件的方式不同，以下为常见模式：

```lua
-- 方案一：通过项目封装的同步事件机制（推荐，按项目实际 API）
frame:onClick(function()
    -- 异步环境：只收集数据
    local clickData = { targetId = target:handleId(), skillId = "A000" }
    -- 触发同步事件，让流回到同步环境
    SyncEvent:fire(clickData)
end)

-- 同步事件监听（同步环境，可以安全执行同步操作）
SyncEvent:register(function(data)
    local tgt = Unit.fromHandleId(data.targetId)
    local src = Player.loc():hero()
    tgt:damage(src, 100)  -- 同步环境，安全
end)

-- 方案二：使用 War3 原生同步机制（底层写法，不推荐业务代码直接使用）
-- cj.BlzTriggerRegisterPlayerSyncEvent / cj.BlzSendSyncData 等
```

**Frame 异步总结**：

| 场景 | 环境 | 能否操作同步函数 |
|------|------|:---:|
| Frame 属性修改（show/hide/setText/setSize 等） | 可在同步/异步任意环境 | — |
| Frame 点击/鼠标事件回调内部 | 异步环境 | ❌ 禁止 |
| 通过同步事件回到同步环境后 | 同步环境 | ✅ 允许 |

#### 4. 硬件事件的异步环境

硬件事件（键盘按键、鼠标点击/移动/滚轮等）**同属异步环境**。与 Frame 点击事件同理，硬件事件回调内无法直接执行同步操作。

**硬件事件范围**：

| 事件类型 | 典型 API | 环境 |
|---------|---------|:--:|
| 键盘按键按下/释放 | `cj.TriggerRegisterPlayerKeyEventBJ`、`cdz.DzTriggerRegisterKeyEvent` | 异步 |
| 鼠标点击/移动/滚轮 | `cj.TriggerRegisterPlayerMouseEventBJ`、`cdz.DzTriggerRegisterMouseEvent` | 异步 |
| 硬件计时器（本地） | 基于 `cdz.DzFrameSetUpdateCallback` 等的逐帧回调 | 异步 |

**处理方式**：与 Frame 事件完全一致——在硬件事件回调中收集数据，通过同步事件回到同步环境：

```lua
-- ✅ 键盘事件：异步收集 → 同步执行
local keyTrigger = cj.CreateTrigger()
cj.TriggerRegisterPlayerKeyEventBJ(keyTrigger, p:handle(), cj.BJ_KEYEVENTTYPE_DEPRESS, cj.BJ_KEYEVENTKEY_ESC)

cj.TriggerAddAction(keyTrigger, function()
    -- 异步环境：不能直接调用同步函数
    -- ✅ 允许：get 任何数据、计算、判断真假值
    local hero = Player.loc():hero()
    if hero and hero:getLife() > 100 then  -- get 读取数据，安全
        local pos = { x = hero:getX(), y = hero:getY() }  -- get 坐标，安全
        -- 通过同步事件传递
        SyncEvent:fire({ action = "escape", pos = pos })
    end
end)

SyncEvent:register(function(data)
    if data.action == "escape" then
        -- 同步环境：可以安全执行
        local u = Unit:new(Player.loc(), 'hfoo', data.pos.x, data.pos.y, 270)
    end
end)
```

**异步环境下的 get 权限**：

> 异步环境下可以 **get 任何东西**（读取单位属性、玩家资源、坐标、生命值等），也可以做**算数运算和真假值判断**。唯一的限制是：禁止调用任何会修改游戏同步状态的函数（即同步函数）。

```lua
-- 异步环境内允许的操作：
if GetLocalPlayer() == p:handle() then
    -- ✅ get：读取数据
    local hp = hero:getLife()
    local x, y = hero:getX(), hero:getY()
    local gold = p:getGold()

    -- ✅ 算术计算
    local ratio = hp / hero:getMaxLife()
    local dist = math.sqrt((x - tx)^2 + (y - ty)^2)

    -- ✅ 真假值判断
    if hp > 500 and gold >= 300 then
        frame:setText("可释放")
    else
        frame:setText("资源不足")
    end

    -- ❌ 禁止：同步函数
    -- hero:setLife(1000)      -- set 会修改同步状态
    -- p:addGold(-300)         -- 修改玩家资源
    -- Unit:new(...)           -- 创建单位
end
```

**异步环境操作总结**：

| 操作类型 | 异步环境 | 说明 |
|---------|:---:|------|
| `get` 读取（属性/坐标/资源等） | ✅ 允许 | 只读不写，不影响同步 |
| 算数运算、逻辑判断 | ✅ 允许 | 纯本地计算 |
| 字符串处理、table 操作（本地变量） | ✅ 允许 | 不影响同步状态 |
| UI/特效/声音/镜头等本地效果 | ✅ 允许 | 异步核心用途 |
| `set` 修改同步状态（生命/金钱/单位创建等） | ❌ 禁止 | 必须回到同步环境 |
| 同步函数调用（Unit:new / damage / addGold 等） | ❌ 禁止 | 必须通过同步事件 |

如果项目的封装层（如 `Effect:new`、`Frame:new`）**内部已经做了异步判断**，业务代码可以不再重复包裹。但编写/修改封装层时，必须确保异步操作已正确保护。

判断封装层是否已做异步判断的方法：
- 查看对应类文件，搜索 `GetLocalPlayer` 或 `Player.loc`
- 若类方法内部有判断，文档应注明"本地方法，自动处理异步"
- **不确定时，业务代码一律显式包裹，多一层判断无害**

## 代码风格（通用）

```lua
-- ✅ 正确：通过项目 OOP 封装层
local p = Player:new(0)
local u = Unit:new(p, 'hfoo', 0, 0, 270)
u:setName("步兵"):setLife(500)

-- ✅ 正确：事件（形态因项目而异，下面是常见模式）
Event:anyUnitDamageEvent():register(function(e)
    local src = Unit.fromHandle(e.damageSource)
    local tgt = Unit.fromHandle(e.unit)
end)

-- ❌ 错误：绕过封装层直接调用底层
local h = cj.CreateUnit(p, 1741932848, 0, 0, 270)
cj.SetWidgetLife(h, 500)

-- ❌ 错误：直接 require 底层库
JassCommon = require "jass.common"
```

## 工作流程

1. **理解需求**：明确用户要改哪个文件、实现什么功能。
2. **探测封装层**（首次接触项目时必做）：按上文"如何识别项目的 OOP 封装层"扫描入口文件与目录，确认类名、构造签名、`fromHandle` 用法、加载顺序。
3. **查阅项目架构文档**：若项目有 `README.md` / `ARCHITECTURE.md`，先读分层与加载规则。
4. **选择封装类**：按职责表找到最合适的类；若项目没有对应封装，优先扩展封装层（新建模块）而非在业务代码里直接调底层。
5. **查找方法签名**：记不清方法名/参数时，Grep 搜索对应类文件中的 `function ClassName:` / `function ClassName.`。**务必核实构造返回值个数**。
6. **编写/修改代码**：严格 OOP 风格，避免业务代码里出现 `cj.` / `cdz.` / `bj_` 裸调用（封装层内部除外）。
7. **校验**：
   - 业务代码中是否残留 `cj.` / `cdz.` / `bj_` 直接调用（封装层内部允许）。
   - `fromHandle` 类静态方法是否用点号。
   - 是否遵循项目约定的细节（如 `math.random` 必须带参数、Lua 字符串反斜杠转义、文件行尾 CRLF/LF，详见各项目 working memory）。

## 例外情况

- **底层封装层内部**（如 api 层、cj/cdz 注册文件）允许直接调用底层 API，用户通常不应要求修改这里；若确需改动，先读架构文档并说明破坏风险。
- **性能/特殊 hook 场景**：极少数需要挂接底层触发器的系统级逻辑，应先确认项目是否已有集中入口（如统一的伤害事件、统一的单位进入地图事件），不要随意新增裸触发器。
- 若项目**根本没有 OOP 封装层**（纯脚本式 Lua），则本规范不适用，按项目既有约定写；但新建功能时仍建议抽出一个封装层。