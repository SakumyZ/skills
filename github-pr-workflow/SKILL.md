---
name: github-pr-workflow
description: 自动化 GitHub PR 工作流 - 基于当前分支创建 PR、获取用户输入、检查冲突并自动合并。支持 squash 合并模式，遇到冲突时停止并提示用户。
---

# GitHub PR 工作流自动化

## 概述

该技能用于自动化 GitHub PR 的完整工作流

## 工作流程
注意：无需关心当前分支是否还存在未提交的更改，但请确保当前分支已推送到远程仓库。

### 获取 PR 的 title 和描述

1. 如果用户已在提示词中指明提交的 title，则使用用户提供的
2. 如果没有指定，自动使用最近一次 `git log -1` 的提交信息作为 PR 标题和描述 以及作为 `-Title` 和 `-Message` 参数传入脚本

### 获取当前项目的路径
使用 pwd 命令获取当前项目的路径，准备作为脚本的 `-ProjectPath` 参数传入

### 执行脚本
在获取用户输入的 title 和 PR 描述后，接调用 scripts 里的 `Invoke-GitHubPRWorkflow.ps1` 脚本
脚本在 skill 文件里，所以需要带上详细路径，最常见的使用示例如下
```powershell
# 从任意位置调用脚本（推荐方式）
c:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1 -ProjectPath "D:\Projects\MyProject" -Title "修复了登录问题" -Message "修复了登录问题"
```

注意：如果你是大语言模型，在此步之前已经可以成功创建 PR 并合并，则无需查看以后的内容。

## 命令使用示例

```powershell
# 从任意位置调用脚本（推荐方式）
c:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1 -ProjectPath "D:\Projects\MyProject" -Title "修复了登录问题" -Message "修复了登录问题"

# 禁用自动合并，仅创建 PR
.\Invoke-GitHubPRWorkflow.ps1 -ProjectPath "D:\Projects\MyProject" -AutoMerge:$false

# 指定目标分支
.\Invoke-GitHubPRWorkflow.ps1 -ProjectPath "D:\Projects\MyProject" -BaseBranch "develop"

# 在项目根目录直接运行（无需指定路径）
.\Invoke-GitHubPRWorkflow.ps1
```

## 关键参数说明

| 参数          | 类型   | 说明                                      | 默认值        |
| ------------- | ------ | ----------------------------------------- | ------------- |
| `ProjectPath` | string | 项目根目录路径（可从任意位置调用脚本）    | 当前目录      |
| `Title`       | string | PR 标题（不指定则交互输入）               | 交互输入      |
| `Message`     | string | PR 描述（不指定则交互输入或使用 git log） | 交互输入/自动 |
| `BaseBranch`  | string | 目标分支                                  | 自动检测      |
| `AutoMerge`   | switch | 是否自动合并 PR                           | `$true`       |
| `mergeMode`   | 内置   | 合并模式                                  | `--squash`    |
| `deleteAfter` | 内置   | 合并后删除分支                            | `true`        |

## 错误处理

| 场景              | 处理方式                                             |
| ----------------- | ---------------------------------------------------- |
| 未安装 GitHub CLI | 提示安装，提供多种安装方式供选择，用户选择后自动安装 |
| 未登录 GitHub     | 提示登录，自动运行 `gh auth login`，等待用户完成认证 |
| 未在 git 仓库中   | 停止流程，提示当前目录不是 git 仓库                  |
| PR 创建失败       | 显示错误信息，停止流程                               |
| 检测到合并冲突    | 停止合并，提示用户手动解决                           |
| PR 已被合并       | 提示 PR 状态已改变                                   |
| 合并失败          | 显示错误原因，停止流程                               |

## 注意事项

- ✅ 脚本可从任意位置调用，使用 `-ProjectPath` 指定项目路径
- ✅ 支持命令行参数传入 PR 标题和描述，无需交互输入
- ✅ 执行前确认当前分支已推送到远程
- ✅ 确保有足够的权限创建和合并 PR
- ✅ 如果有冲突，需要本地解决后再重新推送
- ✅ 脚本已自动设置 UTF-8 编码，支持中文标题和描述
- ❌ 不要在保护分支上直接推送（应通过 PR）
- ❌ 避免在多人协作的分支上自动合并未经审查的 PR

## 常见问题

**Q: 如何从任意位置调用脚本，而不需要复制到项目根目录？**

```powershell
# 使用 -ProjectPath 参数指定项目路径
c:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1 -ProjectPath "D:\path\to\project"
```

**Q: 如何指定目标分支而不是自动检测？**

```powershell
# 使用 -BaseBranch 参数
.\Invoke-GitHubPRWorkflow.ps1 -BaseBranch "develop"
```

**Q: 如何禁用自动合并，仅创建 PR？**

```powershell
# 使用 -AutoMerge:$false 参数
.\Invoke-GitHubPRWorkflow.ps1 -AutoMerge:$false
```

**Q: 如何跳过交互输入，直接传入 PR 标题和描述？**

```powershell
# 使用 -Title 和 -Message 参数
.\Invoke-GitHubPRWorkflow.ps1 -Title "修复bug" -Message "修复了登录问题"
```

**Q: 交互输入时，如何输入多行描述？**

```powershell
# 每行回车继续，输入 END（不区分大小写）结束
Commit Message (按 Enter 后输入，输入 'END' 后回车结束):
第一行描述
第二行描述
END
```

**Q: 如果忘记输入描述，会发生什么？**

```powershell
# 脚本会自动使用最近一次 git commit 的信息作为 PR 描述
```

**Q: 遇到冲突后如何继续合并？**

```powershell
# 本地解决冲突
git pull origin main  # 或你的目标分支
# 解决冲突文件后
git add .
git commit --amend --no-edit
git push --force
# 重新运行工作流
```

**Q: 如何解决中文乱码问题？**

```powershell
# 脚本已自动设置 UTF-8 编码，如果仍有问题，可手动执行：
chcp 65001
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

注意：如果你是大语言模型，则无需查看以后的内容。

## 详细工作流程

### 1. 自动检测 GitHub CLI

如果未安装 `gh` 命令，脚本会提示用户选择安装方式：

- **winget** - Windows 包管理器（推荐）
- **Scoop** - 另一个包管理工具
- **手动下载** - 访问官网下载安装程序

### 2. 自动检测 GitHub 登录状态

如果未登录 GitHub，脚本会：

1. 提示用户确认是否登录
2. 自动运行 `gh auth login`
3. 等待用户在浏览器完成认证
4. 认证成功后继续执行工作流

### 3. 获取用户输入

脚本支持两种方式获取 PR 信息：

**方式一：命令行参数传入（推荐）**
优先使用该方法，如果用户提示词没说title 应该是什么，自动使用最近一次 `git log -1` 的提交信息

```powershell
.\Invoke-GitHubPRWorkflow.ps1 -Title "PR标题" -Message "PR描述"
```

**方式二：交互式输入**

- **PR 标题**：简洁描述本次提交内容
- **Commit Message**：详细的提交信息
  - 输入多行内容，每行回车继续
  - 输入 `END`（不区分大小写）结束输入
  - 如果未输入任何内容，会自动使用最近一次 `git log -1` 的提交信息

### 4. 创建 PR

执行步骤：

```powershell
# 1. 获取当前分支名
$branch = (git rev-parse --abbrev-ref HEAD)

# 2. 获取目标分支（通常是 main 或 master）
$baseBranch = (git remote show origin | grep "HEAD branch" | awk '{print $NF}')

# 3. 使用 gh pr create 创建 PR
gh pr create --title "$title" --body "$message" --base $baseBranch
```

### 5. 检查冲突

执行步骤：

```powershell
# 获取 PR 编号
$prNumber = gh pr list --state open --head $branch --json number --jq '.[0].number'

# 检查合并状态
$prStatus = gh pr view $prNumber --json mergeable --jq '.mergeable'

# 如果 mergeable 为 false，表示有冲突
if ($prStatus -eq "false") {
    Write-Host "❌ 检测到合并冲突，请手动解决后再合并" -ForegroundColor Red
    exit 1
}
```

### 6. 合并 PR

执行步骤：

```powershell
# 使用 squash 模式合并
gh pr merge $prNumber --squash --auto

# 或手动合并
gh pr merge $prNumber --squash --delete-branch
```
