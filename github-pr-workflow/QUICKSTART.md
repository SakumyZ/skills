# 快速开始

## 第一次使用

### 1. 检查系统要求

- Windows 系统（推荐 Windows 10 或更新版本）
- PowerShell 5.0+
- git 已安装（如未安装，请访问 https://git-scm.com/download/win）

### 2. 首次运行脚本

脚本位置: `c:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1`

首次运行时，脚本会自动：

1. **检测 GitHub CLI** - 如未安装，会提示你选择安装方式
2. **检测 GitHub 登录** - 如未登录，会自动打开浏览器进行认证
3. 完成设置后再继续执行工作流

### 3. 添加到 PowerShell Profile（可选）

为了方便使用，可以在 PowerShell Profile 中添加别名：

```powershell
# 打开 profile
notepad $PROFILE

# 添加以下内容
function Start-PRWorkflow {
    & "C:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1" @args
}

# 保存并重新加载
. $PROFILE
```

## 基本用法

### 方式 1: 直接运行脚本

```powershell
cd D:\Projects\Private\Housei\sk-gs\sk-gs-mgt-frontend
& "C:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1"
```

### 方式 2: 使用别名（配置后）

```powershell
Start-PRWorkflow
```

### 方式 3: 禁用自动合并

```powershell
& "C:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1" -AutoMerge $false
```

## 工作流程详解

### 步骤 1: 输入 PR 信息

```
PR 标题: 修复登录页面样式问题
Commit Message:
- 修复按钮颜色不符合设计规范
- 调整输入框边距
- 更新错误提示文案
```

### 步骤 2: 确认信息

脚本会显示你输入的内容，要求确认是否继续

### 步骤 3: PR 创建

- 获取当前分支名称
- 检测目标分支（main/master）
- 创建 PR 并返回链接

### 步骤 4: 冲突检查

- 如果无冲突 → 继续合并
- 如果有冲突 → 停止并提示手动解决

### 步骤 5: 合并确认

询问是否立即合并，使用 squash 模式合并

## 常见场景

### 场景 1: 快速创建并合并 PR

```powershell
cd <your-project>
& "C:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1"
# 按提示输入信息，输入 y 确认
```

### 场景 2: 仅创建 PR 不自动合并

```powershell
& "C:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1" -AutoMerge $false
```

### 场景 3: 遇到冲突的处理

脚本会提示：

```
❌ 检测到合并冲突！
⚠️  请手动解决冲突后再合并

冲突解决步骤:
  1. 本地运行: git pull origin <base-branch>
  2. 手动解决冲突文件
  3. git add .
  4. git commit --amend --no-edit
  5. git push --force
  6. 重新运行此脚本
```

### 场景 4: 检查 PR 状态而不合并

```powershell
# 使用 gh 命令直接查看
gh pr list
gh pr view <pr-number>
```

## 故障排除

### 问题 1: "未找到 GitHub CLI"

脚本会自动提示你选择安装方式：

- **winget** - 自动下载和安装（推荐）
- **Scoop** - 如果你已安装了 Scoop
- **手动下载** - 访问 https://cli.github.com/ 手动下载

安装完成后，关闭当前 PowerShell 窗口，重新打开再运行脚本。

### 问题 2: "未登录 GitHub"

脚本会自动提示你登录：

1. 你需要确认 `是否现在进行登录? (y/n)`
2. 脚本会自动运行 `gh auth login`
3. 浏览器会打开，请完成登录流程
4. 登录成功后脚本会继续执行

无需手动运行 `gh auth login`。

### 问题 3: "分支未推送到远程"

```powershell
git push -u origin <branch-name>
```

### 问题 4: "PR 创建失败"

- 检查网络连接
- 验证 token 权限：`gh auth status`
- 检查分支是否真的推送了：`git push`

### 问题 5: 合并后分支未删除

脚本默认使用 `--delete-branch` 标志。如果分支被保护，可能需要手动删除：

```powershell
git push origin --delete <branch-name>
```

## 自定义配置

### 修改默认合并目标分支

在脚本中修改这一行（第 107 行）：

```powershell
$BaseBranch = "develop"  # 改成你的目标分支
```

### 修改脚本颜色主题

编辑脚本中的 `Write-Success`, `Write-Error-Custom` 等函数

### 添加日志记录

在脚本末尾添加：

```powershell
"[$(Get-Date)] PR #$prNumber created and merged" | Add-Content -Path "C:\logs\pr-workflow.log"
```

## 安全建议

- ✅ 使用脚本前检查分支是否正确
- ✅ 确保 commit message 准确
- ✅ 在重要项目上先禁用 `-AutoMerge` 测试
- ✅ 定期检查 GitHub token 权限
- ❌ 不要在保护分支上运行此脚本
- ❌ 不要硬编码 token（GitHub CLI 会自动管理）

## 获取帮助

```powershell
# 查看脚本的完整参数
Get-Help "C:\Users\housei\.claude\skills\github-pr-workflow\scripts\Invoke-GitHubPRWorkflow.ps1" -Full

# 查看 gh 命令帮助
gh pr --help
gh pr create --help
gh pr merge --help
```
