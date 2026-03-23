# 🧰 AI Coding Skills Collection

A collection of skills designed for AI coding assistants, covering frontend development, backend DTO workflows, project management, data processing, and more to boost development efficiency.

**English** | [中文](./README_CN.md)

## 📋 Skills Overview

| Skill                                                 | Description                     | Category        |
| ----------------------------------------------------- | ------------------------------- | --------------- |
| [add-form-validation-rule](#add-form-validation-rule) | Form validation rule workflow   | Frontend Dev    |
| [code-review](#code-review)                           | Multi-dimensional code review   | Code Quality    |
| [component-scaffolder](#component-scaffolder)         | Component scaffolding generator | Frontend Dev    |
| [dto-validation-analyzer](#dto-validation-analyzer)   | JSON and Java DTO validator     | Backend / DTO   |
| [excel-sheet-splitter](#excel-sheet-splitter)         | Excel worksheet splitter        | Data Processing |
| [excel-to-markdown](#excel-to-markdown)               | Excel to Markdown converter     | Data Processing |
| [github-pr-workflow](#github-pr-workflow)             | GitHub PR automation workflow   | Project Mgmt    |
| [java-dto-to-ts](#java-dto-to-ts)                     | Java DTO to TypeScript typings  | Backend / DTO   |
| [chat-to-obsidian-note](#chat-to-obsidian-note)       | Chat to Obsidian knowledge note | Utilities       |
| [model-id-lookup](#model-id-lookup)                   | AI model ID lookup              | Utilities       |
| [perf-analyzer](#perf-analyzer)                       | Frontend performance analysis   | Code Quality    |
| [redmine-search](#redmine-search)                     | Redmine ticket search           | Project Mgmt    |
| [redmine-ticket-to-task](#redmine-ticket-to-task)     | Redmine ticket to dev plan      | Project Mgmt    |
| [smart-debugger](#smart-debugger)                     | Smart debugging assistant       | Code Quality    |
| [test-generator](#test-generator)                     | Test case generator             | Code Quality    |

---

## 🔧 Frontend Development

### add-form-validation-rule

A standardized workflow for adding custom validation rules to **Vue 3 + Ant Design Vue** form systems.

- Supports regex validation, value range checks, date validation, and more
- Complete flow: type definition → rule implementation → validation function → unit tests
- Includes code examples for both simple and complex rules

### component-scaffolder

Automatically generates project-compliant component code from descriptions.

- Auto-detects tech stack (React + MUI or Vue 3 + Ant Design)
- Probes existing project conventions (directory structure, naming conventions, styling, etc.)
- Supports page, business, and common/atom component types
- Generates component files, type definitions, styles, and exports

---

## 🔌 Backend / DTO

### dto-validation-analyzer

Analyzes whether a JSON request payload matches a Java DTO definition.

- Checks missing fields, unknown fields, naming mismatches, type mismatches, and required validation rules
- Understands annotations such as `@Required`, `@NotNull`, `@NotBlank`, `@JsonProperty`, and `@Schema`
- Recursively inspects nested DTOs, collections, and `@Valid` cascaded validation
- Outputs findings grouped by validation errors, warnings, and informational notes

### java-dto-to-ts

Converts Java DTO classes into TypeScript interface definitions.

- Maps common Java types to TypeScript types, including collections, optionals, maps, and date/time types
- Uses `@Schema(name = ...)` and `@Schema(description = ...)` for field naming and JSDoc generation
- Treats `@Required` fields as required properties and other fields as optional
- Expands static nested classes into standalone exported interfaces in dependency-safe order

---

## 🛡️ Code Quality

### code-review

Deep code review for staged changes or specified files.

- **5-level severity classification**: P0 Errors → P1 Security → P2 Performance → P3 Maintainability → P4 Style
- Three modes: staged area review, full project review, targeted file review
- Auto-detects tech stack and loads corresponding review rules
- Outputs structured review report (`.local/code-review.md`)

### perf-analyzer

Analyzes component rendering performance, bundle size, and network request efficiency.

- **Rendering**: Re-render detection, list virtualization, state update frequency
- **Bundle**: Full import detection, unused dependencies, code splitting
- **Network**: Request waterfalls, caching strategies, race condition protection
- **Memory leaks**: Event listeners, timers, closures holding large objects
- Supports both React and Vue 3

### smart-debugger

Quickly locates root causes from error messages and provides fix suggestions.

- Covers runtime errors, rendering issues, performance problems, network requests, style anomalies, build errors
- Built-in pattern matching for high-frequency errors
- Automatic context collection for diagnosis
- Complements BugHunter: smart-debugger for quick diagnosis, BugHunter for complete fix lifecycle

### test-generator

Automatically generates test case skeletons for components and functions.

- Supports Jest / Vitest test frameworks
- Supports React Testing Library / Vue Test Utils
- Auto-detects project test environment and conventions
- Covers rendering, props, interactions, and edge cases
- Follows AAA pattern (Arrange → Act → Assert)

---

## 📊 Data Processing

### excel-sheet-splitter

Splits Excel workbooks into individual files by worksheet.

- Preserves cell values, formulas, formatting, column widths, row heights, and merged cells
- Supports both CLI and Python API usage
- Customizable output directory and filename prefix
- Requirements: Python 3.7+ and openpyxl

### excel-to-markdown

Converts Excel files to Markdown table format.

- Handles merged cells and preserves line breaks
- Optional style semantic extraction (bold, background color, strikethrough, etc.)
- Supports batch conversion of multiple files
- Ideal for reading specification documents and providing context
- Requirements: Python 3.7+ and openpyxl

---

## 📁 Project Management

### github-pr-workflow

End-to-end GitHub PR workflow automation.

- Auto-creates PR → checks conflicts → squash merges
- Supports CLI arguments or interactive input for PR details
- Auto-detects GitHub CLI installation and login status
- Configurable target branch, auto-merge toggle, and more
- Environment: Windows (PowerShell 5.0+)

### redmine-search

Access Redmine via API Token authentication to query ticket information.

- Prerequisite: set environment variable `REDMINE_API_TOKEN` before using this skill

- Supports ticket listing, single ticket details, and project ticket filtering
- Filter by status, assignee, priority, tracker type, and more
- Defaults to querying tickets assigned to the current user

### redmine-ticket-to-task

Automatically generates actionable development plans from Redmine tickets.

- Extracts requirements, analyzes scope, and breaks down development steps
- Adapts analysis strategy by ticket type (Feature / Bug / Todo)
- Automatically links related specification documents and code files
- Integrates with other skills (excel-to-markdown, component-scaffolder, code-review, etc.)
- Depends on the `redmine-search` skill

---

## 🔍 Utilities

### chat-to-obsidian-note

Extracts valuable technical content from AI chat sessions and saves it as structured Obsidian notes.

- Three document types: Problem-solving, Knowledge-learning, Solution-comparison
- Auto-infers knowledge base category with user confirmation
- Generates Obsidian-compatible Markdown with frontmatter and `[[wiki links]]`
- Follows existing knowledge base folder structure and naming conventions

### model-id-lookup

Look up and verify AI model IDs.

- Local cache first, updates from [models.dev](https://models.dev) online when needed
- Case-insensitive search with partial matching
- Smart fuzzy matching (even when users misremember model names)

---

## 📂 Directory Structure

```
.
├── LICENSE
├── README.md
├── README_CN.md
├── add-form-validation-rule/
│   └── SKILL.md
├── chat-to-obsidian-note/
│   ├── SKILL.md
│   └── references/
├── code-review/
│   ├── SKILL.md
│   └── references/
├── component-scaffolder/
│   ├── SKILL.md
│   └── references/
├── dto-validation-analyzer/
│   └── SKILL.md
├── excel-sheet-splitter/
│   ├── LICENSE.txt
│   ├── README.md
│   ├── SKILL.md
│   └── scripts/
├── excel-to-markdown/
│   ├── SKILL.md
│   └── scripts/
├── github-pr-workflow/
│   ├── OPTIMIZATION_REPORT.md
│   ├── OPTIMIZE_SUMMARY.md
│   ├── QUICKSTART.md
│   ├── README.md
│   ├── SKILL.md
│   └── scripts/
├── java-dto-to-ts/
│   └── SKILL.md
├── model-id-lookup/
│   ├── SKILL.md
│   ├── references/
│   └── scripts/
├── perf-analyzer/
│   └── SKILL.md
├── redmine-search/
│   └── SKILL.md
├── redmine-ticket-to-task/
│   └── SKILL.md
├── smart-debugger/
│   └── SKILL.md
└── test-generator/
    └── SKILL.md
```

## 🚀 Usage

Each skill directory contains a `SKILL.md` file that documents the complete workflow. Place the skill directory into your AI coding assistant's skills directory to use it.

Some skills include a `scripts/` directory (executable scripts) and a `references/` directory (reference materials) that the AI assistant will automatically invoke during execution.

## 📄 License

[MIT License](./LICENSE) © 2026 sakumyz
