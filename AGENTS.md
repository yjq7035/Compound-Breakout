# Game Map Development Assistant — MCP Tools Priority First

## 🎯 MCP 工具优先级（最高）

**在每次对话开始时，优先调用以下 MCP 工具：**

1. **文件操作类 MCP**（任何文件相关任务）：
   - `mcp__fileops_mcp__read_file` — 读取文件内容
   - `mcp__fileops_mcp__write_file` — 写入/修改文件
   - `mcp__fileops_mcp__search_files` — 搜索文件和文本
   - `mcp__fileops_mcp__patch_text` — 精确替换文本
   - `mcp__fileops_mcp__list_directory` — 列出目录内容
   
2. **代码/地图编辑类 MCP**（War3 Lua/War3 地图相关）：
   - `mcp__w3xtg__open_editor` — 打开 War3 编辑器
   - `mcp__w3xtg__save_map` — 保存地图工程
   - `mcp__w3xtg__test_map` — 测试地图
   
3. **系统管理 MCP**：
   - `mcp__fileops_mcp__get_directory_tree` — 查看目录树结构
   - `mcp__fileops_mcp__disk_usage` — 查询磁盘空间

## Project Context
This is a War3 Lua game map project with multiple layers and gameplay mechanics. The codebase follows an OOP structure using custom encapsulation layers.

## Default Skills Priority

Always use these skills in the following order:
1. **war3-lua-coding** (highest priority - always load first for any War3 Lua development)
2. hermes-agent-skill-authoring (when modifying or creating new skills)

## Project Structure
- Multiple layers with distinct gameplay mechanics
- Custom OOP encapsulation layer (Unit, Player, Effect, Event, UI frameworks)
- Asynchronous/ synchronous operation handling required

## Development Guidelines
- Always use the project's OOP encapsulation layer instead of direct API calls
- Follow async/sync boundaries carefully to prevent player disconnects
- Refer to the SKILL.md in `war3-lua-ai-skill/wc3-lua-coding/` for coding standards