---
name: java-dto-to-ts
description: 将 Java DTO 类文件转换为 TypeScript interface，自动处理类型映射、@Required/@Schema 注解、嵌套类，并生成完整的 JSDoc 注释。
---

# Java DTO → TypeScript Interface

将 Java DTO（Data Transfer Object）类文件转换为 TypeScript interface 定义。

## 操作步骤

1. 读取用户指定的 Java DTO 源文件
2. 按照下方【转换规则】解析类结构、字段、注解和注释
3. 生成 TypeScript interface 代码，输出到控制台或用户指定的 `.ts` 文件中

## 转换规则

### 1. 类型映射

| Java 类型                                                                     | TypeScript 类型 |
| ----------------------------------------------------------------------------- | --------------- |
| `String` / `CharSequence` / `char` / `Character`                              | `string`        |
| `int` / `Integer` / `long` / `Long` / `short` / `Short`                       | `number`        |
| `float` / `Float` / `double` / `Double` / `BigDecimal` / `BigInteger`         | `number`        |
| `boolean` / `Boolean`                                                         | `boolean`       |
| `Date` / `LocalDate` / `LocalDateTime` / `LocalTime` / `Instant` 等日期时间类 | `string`        |
| `List<T>` / `Set<T>` / `Collection<T>`                                        | `T[]`           |
| `Map<K, V>`                                                                   | `Record<K, V>`  |
| `Optional<T>`                                                                 | `T`             |
| 其他自定义类型（如内部类）                                                    | 同名 interface  |

> 注意：`List<@Valid T>` 等带校验注解的泛型参数，忽略注解，只取类型 `T`。

### 2. 字段可选性

- 标注了 `@Required` 的字段 → **必填**（字段名后无 `?`）
- 未标注 `@Required` 的字段 → **可选**（字段名后加 `?`）

### 3. 字段命名

- 优先使用 `@Schema(name = "xxx")` 中的 `name` 值作为 TypeScript 字段名
- 若无 `@Schema` 注解，使用 Java 字段名（保持原始 camelCase）

### 4. Interface 命名

- 优先使用类上 `@Schema(name = "xxx")` 中的 `name` 值作为 interface 名
- 若无 `@Schema`，使用 Java 类名

### 5. 注释生成

每个字段上方添加 `/** ... */` 格式的 JSDoc 注释：

- 优先使用 `@Schema(description = "xxx")` 的值
- 若无 `@Schema`，使用 Java 源码中的 Javadoc 注释内容（去掉 `/**`、`*/`、`*` 标记和尾部 `.`）

interface 级别的注释同理，使用多行 `/** ... */` 格式。

### 6. 嵌套类

- Java 的 `public static class` 内部类 → 独立的 `export interface`
- 被引用的内部类 interface 放在引用者**前面**输出，保证类型引用顺序正确

### 7. 输出格式

```typescript
/** interface 描述 */
export interface InterfaceName {
  /** 字段描述 */
  fieldName: type
  /** 字段描述 */
  optionalField?: type
}
```

- 缩进按照当前文件已有的缩进格式
- 每个 interface 之间空一行
- 文件末尾保留一个换行

## 示例

### 输入（Java）

```java
/**
 * 購読料・郵送料の算出APIのリクエストDto.
 */
@Data
@Schema(name = "CalcSubscriptionShippingPriceReqDto", description = "購読料・郵送料の算出APIのパラメータ")
public class CalcKdYsPriceReqDto {

  @Required
  @Schema(name = "seikyuKikanFrom", description = "対象期間（FROM）")
  private String seikyuKikanFrom;

  @Schema(name = "kodokuId", description = "購読ID")
  private Integer kodokuId;

  @Schema(name = "kodokuInfo", description = "購読情報")
  private KodokuInfo kodokuInfo;

  private Date criteriaDate;

  @Data
  @Schema(name = "KodokuInfo", description = "購読情報")
  public static class KodokuInfo {
    @Schema(name = "yusoKbn", description = "郵送区分")
    private String yusoKbn;

    @Schema(name = "hinList", description = "品目リスト")
    private List<@Valid HinItem> hinList;
  }

  @Data
  @Schema(name = "HinItem", description = "品目項目")
  public static class HinItem {
    @Schema(name = "hinCd", description = "品目コード")
    private String hinCd;
  }
}
```

### 输出（TypeScript）

```typescript
/**
 * 品目項目
 */
export interface HinItem {
  /** 品目コード */
  hinCd?: string
}

/**
 * 購読情報
 */
export interface KodokuInfo {
  /** 郵送区分 */
  yusoKbn?: string
  /** 品目リスト */
  hinList?: HinItem[]
}

/**
 * 購読料・郵送料の算出APIのパラメータ
 */
export interface CalcSubscriptionShippingPriceReqDto {
  /** 対象期間（FROM） */
  seikyuKikanFrom: string
  /** 購読ID */
  kodokuId?: number
  /** 購読情報 */
  kodokuInfo?: KodokuInfo
  /** 基準日 */
  criteriaDate?: string
}
```

### 要点说明

| 输入特征                 | 输出结果                                                   |
| ------------------------ | ---------------------------------------------------------- |
| `@Required` + `String`   | `seikyuKikanFrom: string;`（无 `?`，必填）                 |
| `Integer` 无 `@Required` | `kodokuId?: number;`（有 `?`，可选）                       |
| `Date` 无 `@Schema`      | `criteriaDate?: string;`（Javadoc 作为注释来源）           |
| `List<@Valid HinItem>`   | `hinList?: HinItem[];`（忽略 `@Valid`，数组类型）          |
| `public static class`    | 独立的 `export interface`，排在引用者前面                  |
| 类上 `@Schema(name=...)` | 用作 interface 名（`CalcSubscriptionShippingPriceReqDto`） |
