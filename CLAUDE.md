# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 提供该仓库的代码操作指引。

## 项目概述

Z-City 是一个 Garry's Mod (GMod) 插件兼游戏模式，拥有自己的武器基础，用于修改角色伤害与控制机制。它基于 Homigrad 框架构建。仓库同时包含插件部分 (`lua/`) 和游戏模式部分 (`gamemodes/zcity/`)。

当前版本：`1.4.1`（定义于 `lua/autorun/loader.lua`）。

## 开发环境

这是一个**纯 Lua** 项目，没有构建步骤、包管理器或测试套件。代码在 Garry's Mod 内部运行。

### 安装（本地测试）
1. 将仓库复制到 GMod 服务器的 `addons/` 文件夹以安装插件部分。
2. 将 `gamemodes/zcity/` 复制到 GMod 服务器的 `gamemodes/` 文件夹以安装游戏模式。
3. 确保已安装所需依赖（见下方依赖项）。
4. 启动**多人**监听服务器或专用服务器。

### 所需依赖
- **ULX & ULib** — 插件启动时会检查这两项，缺失时会打印警告。许多功能依赖它们。
- **8bit 模块** — 编译后的二进制文件位于 `lua/bin/`（`gmsv_eightbit_win64.dll` 等）。源码地址：`https://github.com/uzelezz123/8bit_zcity`。
- **Workshop 内容** — 通过 `lua/autorun/loader.lua` 中的 `resource.AddWorkshop` 强制下载五个 Workshop 插件。
- 客户端可选 Discord RPC 模块（详见 `README.md`）。

## 文件加载约定

### 插件加载器 (`lua/autorun/loader.lua`)
插件入口点，递归加载 `lua/homigrad/`，根据文件名前缀判断运行端：
- `sv_` 或 `_sv` → 仅服务端 (`include`)
- `cl_` 或 `_cl` → 仅客户端（服务端执行 `AddCSLuaFile`，客户端执行 `include`）
- `sh_` 或 `_sh` → 共享（`AddCSLuaFile` + `include`）
- 无前缀 → 视为共享（`AddCSLuaFile` + `include`）

子目录中的文件递归加载；目录按深度优先遍历。

### 游戏模式加载器 (`gamemodes/zcity/gamemode/loader.lua`)
从 `zcity/gamemode/libraries/` 加载库文件，使用类似的前缀规则，但**子目录中的文件先于父目录中的文件加载**。

### 游戏模式玩法模式 (`gamemodes/zcity/gamemode/modes/`)
每个模式是一个文件夹，包含 `sh_`、`sv_`、`cl_` 文件。模式使用全局 `MODE` 表注册到 `zb.modes`。模式支持通过 `MODE.base` 继承。`MODE` 中的每个函数会自动通过 `zb.modesHooks` 挂接到钩子系统。

### GMod 标准自动加载
- `lua/weapons/weapon_*.lua` — 自动注册为 SWEP（脚本化武器）。
- `lua/entities/*/shared.lua`（及 `init.lua`、`cl_init.lua`）— 自动注册为 SENT（脚本化实体）。
- `lua/effects/*.lua` — 自动注册为特效。
- `lua/autorun/*.lua` — 游戏加载时自动运行。

## 全局命名空间

- `hg` — Homigrad 框架全局变量（伤害、生理系统、库存、工具函数）。
- `zb` — Z-City 游戏模式全局变量（回合系统、模式、队伍、地图点、经验）。
- `zb.modes` — 所有已加载游戏模式模式的表（tdm、homicide、coop、defense 等）。
- `zb.modesHooks` — 模式函数的内部钩子分发表。

## 高层架构

### 生理 / 伤害系统 (`lua/homigrad/organism/`)
Z-City 游戏玩法的核心。用详细的生理模拟替代了标准 GMod 伤害机制：
- **tier_0** (`tier_0/`) — 命中框-器官映射 (`sh_hitboxorgans.lua`)。决定对身体特定区域造成伤害时会击中哪些器官。
- **tier_1** (`tier_1/`) — 主生理模拟 (`sv_organism.lua`)。追踪每个玩家的状态：血容量、脉搏、疼痛、耐力、肺/肝功能、新陈代谢、体温、意识、断肢、骨折、伤口（子弹/刺伤/割伤/瘀伤/烧伤/爆炸伤）以及药物效果。
- 模块注册在 `hg.organism.module` 中（脉搏、血液、疼痛、耐力、肺、肝、新陈代谢、随机事件）。
- 生理状态会同步到客户端用于 HUD 渲染。

### 假死 / 布娃娃系统 (`lua/homigrad/fake/`)
处理玩家死亡状态。玩家不会进入标准 GMod 死亡，而是进入"假死"状态，身体变成可拖拽、可搜刮、可复活的布娃娃。参见 `sv_control.lua`、`sv_input.lua`、`sv_tier_0.lua`。

### 武器系统 (`lua/weapons/`)
武器继承自多个基类：
- `weapon_tpik_base` — 第三人称逆运动学（TPIK）动画武器。定义 `AnimList`、`weaponPos`/`weaponAng`、冲刺/待机动画角度。
- `weapon_hg_medicine_base` — 医疗物品（绷带、吗啡等）带治疗动画。
- `weapon_melee` — 带挥砍机制的近战武器。
- `weapon_base` — 标准 GMod SWEP 基类。
- 前缀为 `weapon_hg_*` 的武器通常是近战/手雷/杂项物品。带有真实枪械名称的武器（如 `weapon_ak74`、`weapon_m4a1`）是 firearms。

### 回合 / 模式系统 (`gamemodes/zcity/gamemode/modes/`)
游戏模式支持多种回合类型，每种类型有独立文件夹：
- `tdm` — 团队死斗
- `homicide` — 社交推理 / 叛徒模式
- `coop` — 带地图切换的协作战役
- `defense` — 带指挥官/角色的波次防御
- `dm`、`hl2dm`、`gwars`、`riot`、`sfd`、`scugarena`、`pathowogen`、`criresp`、`cstrike`

回合生命周期（由 `libraries/sv_roundsystem.lua` 管理）：
- `zb.ROUND_STATE` — `0` = 等待中，`1` = 进行中，`2` = 结束，`3` = 回合结束
- `CurrentRound()` 返回当前激活的模式表。
- `zb:RoundStart()` / `zb:EndRound()` 控制状态切换。

### 地图点 (`gamemodes/zcity/gamemode/libraries/mappoints/`)
每张地图可配置的出生点和目标点。类型包括 `Spawnpoint`、`RandomSpawns` 以及自定义类型。管理员可在游戏中通过 `zb_drawpoints 1` 可视化查看点位。点位在服务端存储并同步到客户端。

### 网络系统 (`lua/homigrad/libraries/core/sh_networking.lua`)
基于 GMod net 消息构建的自定义 NetVar 系统：
- `SetNetVar(key, value, receiver)` — 实体本地网络变量。
- `GetNetVar(key, default)` — 客户端获取。
- `SetGlobalVar(key, value)` / `GetGlobalVar(key, default)` — 全局网络变量。
- 事件：`OnNetVarSet`、`OnGlobalVarSet`、`OnLocalVarSet`。

### 库存系统 (`lua/homigrad/new_inventory/`)
自定义库存，带物品实体（`entities/attachment_base`、`entities/ammo_base`、`entities/armor_base`）。物品可安装到武器上或作为护甲穿戴。

## 重要文件与入口点

| 文件 | 用途 |
|------|------|
| `lua/autorun/loader.lua` | 插件入口；递归加载 `homigrad/` |
| `gamemodes/zcity/gamemode/init.lua` | 游戏模式服务端入口 |
| `gamemodes/zcity/gamemode/cl_init.lua` | 游戏模式客户端入口（观战 UI、记分板、字体） |
| `gamemodes/zcity/gamemode/shared.lua` | 游戏模式共享代码（队伍设置、出生限制、模糊效果工具） |
| `gamemodes/zcity/gamemode/loader.lua` | 加载库和模式 |
| `gamemodes/zcity/gamemode/libraries/sv_roundsystem.lua` | 回合生命周期管理器 |
| `lua/homigrad/organism/tier_1/sv_organism.lua` | 核心生理模拟 |
| `lua/homigrad/fake/sv_control.lua` | 死亡/布娃娃状态管理 |

## 编码规范

- 新文件必须使用 `sh_`、`sv_`、`cl_` 前缀，以便加载器正确处理。
- 全局函数/变量需加上 `hg.` 或 `zb.` 前缀以避免命名冲突。
- 代码库中英文和俄文注释混用；新代码建议使用英文。
- 前缀为 `hg_` 的 ConVar 通常是客户端设置；`zb_` 是服务端或游戏模式设置。
- 伤害和生命值由生理系统管理，而非标准的 `Entity:Health()`。除非与生理系统集成，否则避免直接调用 `SetHealth`。
