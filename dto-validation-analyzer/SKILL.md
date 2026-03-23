---
name: dto-validation-analyzer
description: 分析给定的 JSON 请求数据是否与 Java 后台 DTO 定义吻合，检查字段缺失、字段名不匹配、类型不匹配、必填校验等问题。
---

# DTO Validation Analyzer

分析用户提供的 JSON 请求数据是否与 Java 后台 DTO 类定义吻合，找出所有不匹配的问题。

## 触发条件

当用户提供了一段 JSON 数据和一个 Java DTO 类定义（或文件路径），并要求检查数据是否与 DTO 吻合、能否通过 validation 时，使用本技能。

## 操作步骤

1. 获取 JSON 数据和 Java DTO 定义（用户直接提供或通过文件路径读取）
2. 解析 DTO 结构（字段名、类型、注解、嵌套类）
3. 按照【分析规则】逐项对比
4. 按照【输出格式】生成分析报告

## 分析规则

### 1. 字段名匹配

确定 DTO 字段的实际序列化名称，优先级如下：

1. `@JsonProperty("name")` 的值
2. `@Schema(name = "name")` 的值（仅在框架使用 Schema name 做序列化时）
3. Java 字段名本身

> **重要**：对比时使用 DTO 字段的**序列化名称**（而非 Java 字段名），与 JSON 中的 key 进行匹配。

检查项：

- JSON 中是否存在 DTO 中没有的字段（多余字段）
- DTO 中是否存在 JSON 中没有的字段（缺失字段）
- 字段名是否存在拼写差异（如 `teikiBusu` vs `teikiBunBusu`）

### 2. 必填字段校验

识别以下注解标注的必填字段：

- `@Required`
- `@NotNull`
- `@NotBlank`
- `@NotEmpty`

检查 JSON 中这些字段是否：

- 存在（缺失 → 必定 validation 失败）
- 非 null
- 非空字符串（对于 `@NotBlank`）
- 非空集合/数组（对于 `@NotEmpty`）

### 3. 类型匹配

对比 JSON 中值的类型与 DTO 字段声明的类型：

| DTO Java 类型                       | JSON 期望类型     | 常见问题                 |
| ----------------------------------- | ----------------- | ------------------------ |
| `String`                            | string            | 发送了 number 或 boolean |
| `Integer` / `Long` / `int` / `long` | number (整数)     | 发送了 string 或小数     |
| `Double` / `Float` / `BigDecimal`   | number            | 发送了 string            |
| `Boolean` / `boolean`               | boolean           | 发送了 string `"true"`   |
| `List<T>` / `Set<T>`                | array             | 发送了单个对象而非数组   |
| `Date` / `LocalDateTime` 等         | string (日期格式) | 格式不正确               |

> 注意：Spring 默认的 Jackson 会自动做一些类型转换（如 number → String），但这属于隐式转换，仍应标记为⚠️ 提醒。

### 4. 格式校验

检查带格式注解的字段值是否符合要求：

- `@DateFormat("yyyyMM")` → 值应匹配 `yyyyMM` 格式（如 `"202603"`）
- `@DateFormat("yyyyMMdd")` → 值应匹配 `yyyyMMdd` 格式
- `@Pattern(regexp = "...")` → 值应匹配正则
- `@TrueNumber` → 值应为合法数字（字符串形式时也应为数字字符串）
- `@Email` → 值应为邮箱格式
- `@Size(min=x, max=y)` → 字符串长度或集合大小应在范围内

### 5. 嵌套对象递归分析

- 如果 DTO 中的字段类型是另一个 DTO 类（如内部类或引用类），递归地对 JSON 中对应的嵌套对象进行同样的分析
- 如果是 `List<T>` 类型，对数组中的**每一个元素**进行分析，并在报告中标注是第几个元素出的问题

### 6. `@Valid` 级联校验

如果字段或泛型参数上有 `@Valid` 注解，说明 Spring 会对该嵌套对象/列表元素做级联校验，需要递归检查嵌套结构内的 validation 注解。

## 输出格式

按照问题严重程度分组输出：

### 报告结构

```
## 数据与 DTO 匹配分析报告

### ❌ 必定失败（Validation Error）
> 这些问题会导致请求被后台拒绝

| 级别 | 位置 | 问题 | 说明 |
|------|------|------|------|
| ... | ... | ... | ... |

### ⚠️ 潜在问题（Warning）
> 这些问题可能导致数据丢失或行为异常

| 级别 | 位置 | 问题 | 说明 |
|------|------|------|------|
| ... | ... | ... | ... |

### ℹ️ 信息提示（Info）
> 非必填且未发送的字段，不会导致错误

| 字段 | 说明 |
|------|------|
| ... | ... |

### ✅ 总结
简要概括主要问题和建议修复方向。
```

### 严重程度定义

- **❌ 必定失败**：
  - 缺少 `@Required` / `@NotNull` / `@NotBlank` / `@NotEmpty` 标注的字段
  - 格式不符合 `@DateFormat` / `@Pattern` 要求
  - 类型完全不兼容（如传 object 给 String 字段）

- **⚠️ 潜在问题**：
  - JSON 中的字段名在 DTO 中不存在（数据会被忽略/丢失）
  - 类型隐式转换（如 number → String，Jackson 可能自动处理但不推荐）
  - `@TrueNumber` 字段传了非字符串类型的数字

- **ℹ️ 信息提示**：
  - DTO 中存在但 JSON 未发送的非必填字段

## 示例

### 输入

**JSON 数据：**

```json
{
  "seikyuKikanFrom": "202603",
  "seikyuKikanTo": "202603",
  "kodokuId": 19,
  "kodokuInfo": {
    "yusoKbn": "2",
    "hinList": [
      {
        "hinCd": "01",
        "kihonBusu": 1,
        "teikiBunBusu": 0
      }
    ]
  }
}
```

**Java DTO（关键部分）：**

```java
@Data
public class CalcKdYsPriceReqDto {
  @Required
  @DateFormat("yyyyMM")
  private String seikyuKikanFrom;

  @Required
  @DateFormat("yyyyMM")
  private String targetMonth;  // ← @Required

  private Integer kodokuId;

  @Valid
  private KodokuInfo kodokuInfo;

  public static class HinItem {
    @TrueNumber
    @Schema(name = "kihonBusu")
    private String kihonBusu;  // ← 类型是 String

    @TrueNumber
    @Schema(name = "teikiBusu")  // ← 注意 Schema name
    private String teikiBusu;
  }
}
```

### 输出

```
## 数据与 DTO 匹配分析报告

### ❌ 必定失败（Validation Error）

| 级别 | 位置 | 问题 | 说明 |
|------|------|------|------|
| ❌ | `targetMonth` | 缺少必填字段 | 标注了 `@Required` + `@DateFormat("yyyyMM")`，但 JSON 中未提供 |

### ⚠️ 潜在问题（Warning）

| 级别 | 位置 | 问题 | 说明 |
|------|------|------|------|
| ⚠️ | `kodokuInfo.hinList[0].teikiBunBusu` | 字段名不匹配 | JSON 用 `teikiBunBusu`，DTO @Schema name 为 `teikiBusu` |
| ⚠️ | `kodokuInfo.hinList[0].kihonBusu` | 类型隐式转换 | JSON 发送 number `1`，DTO 类型为 `String`，Jackson 会自动转换但不推荐 |

### ✅ 总结
主要问题是缺少必填字段 `targetMonth`。此外 `teikiBunBusu` 字段名与 DTO 不匹配，数据会丢失。
```
