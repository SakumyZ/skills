# 🧰 AI Coding Skills Collection

一套为 AI 编码助手设计的技能集合，涵盖前端开发、项目管理、数据处理等场景，提升开发效率。

[English](./README.md) | **中文**

## 📋 技能一览

| 技能                                                  | 描述                   | 类别     |
| ----------------------------------------------------- | ---------------------- | -------- |
| [add-form-validation-rule](#add-form-validation-rule) | 表单校验规则新增工作流 | 前端开发 |
| [code-review](#code-review)                           | 多维度代码审查         | 代码质量 |
| [component-scaffolder](#component-scaffolder)         | 组件脚手架生成器       | 前端开发 |
| [excel-sheet-splitter](#excel-sheet-splitter)         | Excel 工作表拆分工具   | 数据处理 |
| [excel-to-markdown](#excel-to-markdown)               | Excel 转 Markdown 表格 | 数据处理 |
| [github-pr-workflow](#github-pr-workflow)             | GitHub PR 自动化工作流 | 项目管理 |
| [chat-to-obsidian-note](#chat-to-obsidian-note)       | 聊天转 Obsidian 笔记   | 工具     |
| [model-id-lookup](#model-id-lookup)                   | AI 模型 ID 查询        | 工具     |
| [perf-analyzer](#perf-analyzer)                       | 前端性能分析           | 代码质量 |
| [redmine-search](#redmine-search)                     | Redmine 工单查询       | 项目管理 |
| [redmine-ticket-to-task](#redmine-ticket-to-task)     | Redmine 工单转开发计划 | 项目管理 |
| [smart-debugger](#smart-debugger)                     | 智能调试助手           | 代码质量 |
| [test-generator](#test-generator)                     | 测试用例生成器         | 代码质量 |

---

## 🔧 前端开发

### add-form-validation-rule

为 **Vue 3 + Ant Design Vue** 表单系统新增自定义校验规则的标准化工作流。

- 支持正则校验、值范围校验、日期校验等多种规则类型
- 包含类型定义 → 规则实现 → 验证函数 → 单元测试的完整流程
- 提供简单规则和复杂规则的代码示例

### component-scaffolder

根据组件描述自动生成符合项目规范的组件代码。

- 自动识别技术栈（React + MUI 或 Vue 3 + Ant Design）
- 探测项目现有规范（目录结构、命名规范、样式方案等）
- 支持页面组件、业务组件、共通组件三种类型
- 生成组件主文件、类型定义、样式文件和导出文件

---

## 🛡️ 代码质量

### code-review

对暂存区代码或指定文件进行深度审查。

- **5 级严重度分级**：P0 错误 → P1 安全 → P2 性能 → P3 可维护性 → P4 风格
- 支持暂存区审查、全项目审查、指定文件审查三种模式
- 自动识别技术栈并加载对应审查规则
- 输出结构化审查报告（`.local/code-review.md`）

### perf-analyzer

分析组件渲染性能、Bundle 大小、网络请求效率，给出优化建议。

- **渲染性能**：重渲染检测、大列表虚拟化、状态更新频率
- **Bundle 分析**：全量导入检测、未使用依赖、代码分割
- **网络请求**：请求瀑布流、缓存策略、竞态保护
- **内存泄漏**：事件监听、定时器、闭包持有大对象
- 支持 React 和 Vue 3 双技术栈

### smart-debugger

从错误信息快速定位问题根因并给出修复建议。

- 支持运行时错误、渲染异常、性能问题、网络请求、样式异常、构建错误等
- 内置高频错误模式匹配
- 自动收集上下文信息辅助诊断
- 与 BugHunter 互补：smart-debugger 快速定位，BugHunter 完整闭环修复

### test-generator

为组件和函数自动生成测试用例骨架。

- 支持 Jest / Vitest 测试框架
- 支持 React Testing Library / Vue Test Utils
- 自动探测项目测试环境和规范
- 覆盖渲染、Props、交互、边界值等基础场景
- 遵循 AAA 模式（Arrange → Act → Assert）

---

## 📊 数据处理

### excel-sheet-splitter

将 Excel 工作簿按工作表拆分为独立文件。

- 保留单元格值和公式、格式、列宽行高、合并单元格
- 支持命令行和 Python API 两种调用方式
- 支持自定义输出目录、文件名前缀
- 依赖：Python 3.7+ 和 openpyxl

### excel-to-markdown

将 Excel 文件转换为 Markdown 表格格式。

- 自动处理合并单元格、保留换行符
- 可选样式语义提取（粗体、背景色、删除线等）
- 支持批量转换多个文件
- 适用于式样书阅读、上下文提供等场景
- 依赖：Python 3.7+ 和 openpyxl

---

## 📁 项目管理

### github-pr-workflow

自动化 GitHub PR 的完整工作流。

- 自动创建 PR → 检查冲突 → Squash 合并
- 支持命令行参数或交互式输入 PR 信息
- 自动检测 GitHub CLI 安装状态和登录状态
- 支持自定义目标分支、禁用自动合并等选项
- 环境：Windows (PowerShell 5.0+)

### redmine-search

通过 API Token 认证访问 Redmine 系统，查询工单信息。

- 支持工单列表查询、单票详情、项目工单筛选
- 按状态、指派人、优先级、跟踪器类型等维度筛选
- 默认查询指派给当前用户的工单

### redmine-ticket-to-task

从 Redmine 票据自动生成可执行的开发计划。

- 自动提取需求、分析任务范围、拆解开发步骤
- 按票据类型（Feature / Bug / Todo）采用不同分析策略
- 自动关联相关式样书和代码文件
- 联动其他 Skill（excel-to-markdown、component-scaffolder、code-review 等）
- 依赖 `redmine-search` skill

---

## 🔍 工具

### chat-to-obsidian-note

从 AI 聊天内容中提取有价值的技术信息，生成结构化文档并保存到 Obsidian 知识库。

- 支持三种文档类型：问题解决型、知识学习型、方案对比型
- 自动推断知识库分类目录，用户确认后保存
- 生成符合 Obsidian 规范的 Markdown（含 frontmatter 和 `[[双链]]`）
- 遵循知识库现有目录结构和命名规范

### model-id-lookup

查询和验证 AI 模型 ID。

- 本地缓存优先，找不到时从 [models.dev](https://models.dev) 在线更新
- 支持大小写不敏感搜索和部分匹配
- 智能模糊匹配（即使用户记错模型名称）

---

## 📂 目录结构

```
skills/
├── add-form-validation-rule/   # 表单校验规则
│   └── SKILL.md
├── code-review/                # 代码审查
│   ├── SKILL.md
│   └── references/
├── component-scaffolder/       # 组件脚手架
│   ├── SKILL.md
│   └── references/
├── excel-sheet-splitter/       # Excel 拆分
│   ├── SKILL.md
│   └── scripts/
├── excel-to-markdown/          # Excel 转 Markdown
│   ├── SKILL.md
│   ├── scripts/
│   └── references/
├── github-pr-workflow/         # GitHub PR 工作流
│   ├── SKILL.md
│   └── scripts/
├── chat-to-obsidian-note/      # 聊天转 Obsidian 笔记
│   ├── SKILL.md
│   └── references/
├── model-id-lookup/            # 模型 ID 查询
│   ├── SKILL.md
│   ├── scripts/
│   └── references/
├── perf-analyzer/              # 性能分析
│   └── SKILL.md
├── redmine-search/             # Redmine 查询
│   └── SKILL.md
├── redmine-ticket-to-task/     # 工单转开发计划
│   └── SKILL.md
├── smart-debugger/             # 智能调试
│   └── SKILL.md
└── test-generator/             # 测试生成
    └── SKILL.md
```

## 🚀 使用方法

每个 skill 目录中包含一个 `SKILL.md` 文件，描述了该技能的完整工作流程。将 skill 目录放置到 AI 编码助手的 skills 目录中即可使用。

部分 skill 包含 `scripts/` 目录（可执行脚本）和 `references/` 目录（参考资料），AI 助手会在执行流程中自动调用。

## 📄 许可证

[MIT License](./LICENSE) © 2026 sakumyz
