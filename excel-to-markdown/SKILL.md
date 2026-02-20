---
name: excel-to-markdown
description: 将Excel文件转换为Markdown格式，保留原表格结构和内容。支持合并单元格、样式语义提取、多工作表处理和批量转换。当需要将Excel式样书、数据表转为可读的Markdown文档时使用。
---

# Excel 转 Markdown

## 任务目标

将 Excel 文件(.xlsx/.xls/.xlsm)转换为合法的 Markdown 表格格式，用于式样书阅读、上下文提供等场景。

## 核心能力

- **合并单元格处理**：自动识别合并区域，每个单元格填充合并区域左上角的值
- **换行符保留**：单元格内换行转为 `<br>` 标签
- **合法 Markdown 表格**：包含表头分隔行 `|---|---|`
- **样式语义提取**（可选）：提取粗体、背景色、删除线等样式信息作为标注
- **大文件优化**：自动检测实际数据范围，跳过空白区域

## 前置依赖

```
openpyxl>=3.0.0
```

## 使用方法

### 基本转换

```bash
python scripts/excel_to_markdown_general.py --input <excel文件> [--output <md文件>]
```

### 带样式语义提取

```bash
python scripts/excel_to_markdown_general.py --input <excel文件> --styles
```

样式标注以折叠区块附在表格下方，标注格式：`[行,列]: bold, bg:yellow`

### 批量转换

```bash
python scripts/excel_to_markdown_general.py --batch file1.xlsx file2.xlsx [--styles]
```

### 兼容旧调用方式

```bash
python scripts/excel_to_markdown_general.py file.xlsx [output.md]
```

## 转换规则

详细转换规则参见 [references/excel-format-guide.md](references/excel-format-guide.md)。

关键规则速览：
- 空单元格 → 空字符串
- 换行符 → `<br>`
- 竖线 `|` → `\|`
- 合并单元格 → 每个子单元格都填充合并值
- 粗体 → `**文本**`（需 `--styles`）
- 删除线 → `~~文本~~`（需 `--styles`）
- 背景色 → 标注在折叠区块中（需 `--styles`）

## 使用场景

### 式样书转换

将项目式样书 Excel 转为 Markdown 后，可直接作为开发任务的上下文：

```bash
python scripts/excel_to_markdown_general.py --input ./式様書.xlsx --styles
```

样式标注有助于理解式样书中的语义：黄色背景通常表示必须项，粗体通常表示标题或重点。

## 资源索引

- 核心脚本：[scripts/excel_to_markdown_general.py](scripts/excel_to_markdown_general.py)
- 格式参考：[references/excel-format-guide.md](references/excel-format-guide.md)
