import openpyxl
from openpyxl.utils.exceptions import InvalidFileException
import logging
import os
import sys
import argparse

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def get_merged_cell_value(ws, row, col, merged_ranges):
    """获取合并单元格的值：如果 (row, col) 在某个合并区域内，返回该区域左上角的值"""
    for merge_range in merged_ranges:
        if (
            merge_range.min_row <= row <= merge_range.max_row
            and merge_range.min_col <= col <= merge_range.max_col
        ):
            return ws.cell(row=merge_range.min_row, column=merge_range.min_col).value
    return ws.cell(row=row, column=col).value


def get_cell_style_annotations(ws, row, col):
    """提取单元格样式的语义标注"""
    cell = ws.cell(row=row, column=col)
    annotations = []

    # 粗体
    if cell.font and cell.font.bold:
        annotations.append("bold")

    # 背景色（非白色/无填充）
    if cell.fill and cell.fill.fgColor and cell.fill.fgColor.rgb:
        rgb = str(cell.fill.fgColor.rgb)
        if rgb not in ("00000000", "FFFFFFFF", "0", "00"):
            color_map = {
                "FFFFFF00": "yellow",
                "FFFF0000": "red",
                "FF00FF00": "green",
                "FF0000FF": "blue",
                "FFFFC000": "orange",
                "FFFF00FF": "pink",
                "FFC0C0C0": "gray",
                "FFD9E1F2": "light-blue",
                "FFE2EFDA": "light-green",
                "FFFFF2CC": "light-yellow",
                "FFFCE4D6": "light-orange",
            }
            color_name = color_map.get(rgb, f"#{rgb[-6:]}")
            annotations.append(f"bg:{color_name}")

    # 删除线
    if cell.font and cell.font.strikethrough:
        annotations.append("strikethrough")

    return annotations


def compute_actual_dimensions(ws, max_row, max_col):
    """计算实际有数据的行列范围，避免空白区域"""
    actual_max_col = 0
    actual_max_row = 0
    for row in range(1, max_row + 1):
        for col in range(1, max_col + 1):
            if ws.cell(row=row, column=col).value is not None:
                actual_max_col = max(actual_max_col, col)
                actual_max_row = max(actual_max_row, row)
    return actual_max_row, actual_max_col


def format_cell_value(value, annotations=None):
    """格式化单元格值为 Markdown 安全的字符串"""
    if value is None:
        return ""

    text = str(value)
    # 换行符转为 <br>
    text = text.replace("\r\n", "<br>").replace("\n", "<br>").replace("\r", "<br>")
    # 转义 Markdown 表格分隔符
    text = text.replace("|", "\\|")
    # 去除首尾空白
    text = text.strip()

    # 应用样式标注
    if annotations:
        if "bold" in annotations:
            text = f"**{text}**"
        if "strikethrough" in annotations:
            text = f"~~{text}~~"

    return text


def sheet_to_markdown(ws, sheet_name, extract_styles=False):
    """将单个工作表转换为 Markdown"""
    max_row = ws.max_row or 0
    max_col = ws.max_column or 0

    if max_row == 0 or max_col == 0:
        return f"## {sheet_name}\n\n*该工作表为空*\n\n"

    # 优化：计算实际有数据的范围
    if max_col > 50 or max_row > 10000:
        actual_max_row, actual_max_col = compute_actual_dimensions(ws, max_row, max_col)
        if actual_max_col > 0:
            max_col = actual_max_col
        if actual_max_row > 0:
            max_row = actual_max_row

    logger.info(f"工作表 [{sheet_name}]: {max_row} 行 x {max_col} 列")

    # 收集合并单元格信息
    merged_ranges = list(ws.merged_cells.ranges)

    # 构建表格数据
    rows = []
    style_rows = [] if extract_styles else None

    for row in range(1, max_row + 1):
        row_data = []
        row_styles = [] if extract_styles else None
        for col in range(1, max_col + 1):
            value = get_merged_cell_value(ws, row, col, merged_ranges)
            annotations = (
                get_cell_style_annotations(ws, row, col) if extract_styles else None
            )
            row_data.append(format_cell_value(value, annotations))
            if extract_styles and row_styles is not None:
                row_styles.append(annotations or [])
        rows.append(row_data)
        if extract_styles and style_rows is not None:
            style_rows.append(row_styles)

    if not rows:
        return f"## {sheet_name}\n\n*该工作表为空*\n\n"

    # 生成合法 Markdown 表格
    md = f"## {sheet_name}\n\n"

    # 表头（第一行）
    header = rows[0]
    md += "| " + " | ".join(header) + " |\n"
    # 分隔行
    md += "| " + " | ".join(["---"] * len(header)) + " |\n"
    # 数据行
    for row_data in rows[1:]:
        # 确保列数与表头一致
        while len(row_data) < len(header):
            row_data.append("")
        md += "| " + " | ".join(row_data[: len(header)]) + " |\n"

    # 样式注解区域（如果有非空样式信息）
    if extract_styles and style_rows:
        has_any_style = any(
            any(annotations for annotations in row_annotations)
            for row_annotations in style_rows
        )
        if has_any_style:
            md += "\n<details><summary>样式标注</summary>\n\n"
            for r_idx, row_annotations in enumerate(style_rows):
                for c_idx, annotations in enumerate(row_annotations):
                    if annotations:
                        md += f"- [{r_idx + 1},{c_idx + 1}]: {', '.join(annotations)}\n"
            md += "\n</details>\n"

    md += "\n"
    return md


def excel_to_markdown(excel_file, output_file=None, extract_styles=False):
    """
    Excel 转 Markdown 主函数

    Args:
        excel_file: 输入 Excel 文件路径
        output_file: 输出 Markdown 文件路径（默认与 Excel 同名）
        extract_styles: 是否提取样式语义标注
    """
    if isinstance(excel_file, bytes):
        excel_file = excel_file.decode("utf-8")

    if not os.path.exists(excel_file):
        abs_path = os.path.abspath(excel_file)
        if os.path.exists(abs_path):
            excel_file = abs_path
        else:
            logger.error(f"文件不存在: {excel_file}")
            return None

    supported = {".xlsx", ".xlsm", ".xltx", ".xltm", ".xls"}
    ext = os.path.splitext(excel_file)[1].lower()
    if ext not in supported:
        logger.error(f"不支持的格式 {ext}，支持: {supported}")
        return None

    try:
        wb = openpyxl.load_workbook(excel_file, data_only=True)
    except InvalidFileException as e:
        logger.error(f"文件格式错误: {e}")
        return None
    except Exception as e:
        logger.error(f"打开文件失败: {e}")
        return None

    markdown_content = f"# {os.path.basename(excel_file)}\n\n"

    for sheet_name in wb.sheetnames:
        ws = wb[sheet_name]
        markdown_content += sheet_to_markdown(ws, sheet_name, extract_styles)

    if output_file is None:
        output_file = os.path.splitext(excel_file)[0] + ".md"

    os.makedirs(
        os.path.dirname(output_file) if os.path.dirname(output_file) else ".",
        exist_ok=True,
    )

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(markdown_content)

    logger.info(f"转换完成: {output_file}")
    return output_file


def batch_convert(excel_files, extract_styles=False):
    """批量转换"""
    results = []
    for f in excel_files:
        try:
            result = excel_to_markdown(f, extract_styles=extract_styles)
            results.append((f, result))
        except Exception as e:
            logger.error(f"转换 {f} 失败: {e}")
            results.append((f, None))
    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Excel 转 Markdown 工具")
    parser.add_argument("--input", "-i", help="输入 Excel 文件路径")
    parser.add_argument("--output", "-o", help="输出 Markdown 文件路径")
    parser.add_argument("--batch", "-b", nargs="+", help="批量转换多个 Excel 文件")
    parser.add_argument("--styles", "-s", action="store_true", help="提取样式语义标注")

    # 兼容旧的调用方式（无参数名直接传文件路径）
    args, unknown = parser.parse_known_args()

    if args.batch:
        batch_convert(args.batch, extract_styles=args.styles)
    elif args.input:
        excel_to_markdown(args.input, args.output, extract_styles=args.styles)
    elif unknown:
        # 兼容: python script.py file.xlsx [output.md]
        excel_to_markdown(
            unknown[0],
            unknown[1] if len(unknown) > 1 else None,
            extract_styles=args.styles,
        )
    else:
        parser.print_help()
        sys.exit(1)
