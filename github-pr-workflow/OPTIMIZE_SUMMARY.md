## 优化总结

### 完成的优化

✅ **1. 自动检测和安装 GitHub CLI**

用户如果未安装 `gh` 命令，脚本会：

1. 提示"未找到 GitHub CLI (gh)"
2. 显示安装选项菜单：
   - [1] 使用 winget 安装（推荐）- 自动调用安装命令
   - [2] 使用 Scoop 安装 - 如果已安装 Scoop
   - [3] 手动下载安装程序 - 打开官网链接
   - [4] 取消安装

用户选择后，脚本会：

- 自动执行安装命令（winget 或 Scoop）
- 成功安装后提示用户关闭并重新打开 PowerShell
- 或打开下载页面供用户手动下载

✅ **2. 自动检测和处理 GitHub 登录**

用户如果未登录，脚本会：

1. 提示"未登录 GitHub"
2. 询问"是否现在进行登录? (y/n)"
3. 如用户确认，脚本会：
   - 提示"浏览器将会打开，请完成登录流程"
   - 自动运行 `gh auth login`
   - 等待用户在浏览器完成认证
   - 认证成功后自动继续执行工作流

无需用户手动运行命令！

### 修改的文件

1. **Invoke-GitHubPRWorkflow.ps1**
   - 新增 `Show-Menu()` 函数 - 显示选择菜单
   - 新增 `Install-GitHubCLI()` 函数 - 处理 GitHub CLI 安装
   - 新增 `Invoke-GitHubLogin()` 函数 - 处理 GitHub 登录
   - 更新 `Test-Prerequisites()` 函数 - 调用新的安装和登录函数

2. **SKILL.md**
   - 更新前置要求 - 强调脚本会自动处理
   - 更新工作流程 - 添加自动检测和安装的步骤
   - 更新错误处理 - 说明新的处理方式

3. **QUICKSTART.md**
   - 更新第一次使用 - 强调脚本会自动处理
   - 更新故障排除 - 说明新的自动处理流程

4. **README.md**
   - 新增"智能安装功能"清单
   - 新增"智能登录功能"清单
   - 更新前置条件 - 不需要预先安装和登录
   - 更新安装步骤 - 只需首次运行脚本
   - 更新常见问题 - 添加关于自动安装和登录的说明

### 使用体验提升

**优化前：**

- 用户必须手动安装 GitHub CLI
- 用户必须手动运行 `gh auth login`
- 失败时需要手动纠正

**优化后：**

- 脚本自动检测，缺少时自动提示
- 用户只需选择安装方式，脚本自动完成
- 脚本自动处理登录流程，用户无需手动命令
- 更加用户友好，减少出错可能

### 核心代码实现

#### 选择菜单函数

```powershell
function Show-Menu {
    param([string[]]$Options, [string]$Title = "请选择")

    # 显示选项
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$($i + 1)] $($Options[$i])"
    }

    # 获取用户选择
    $choice = Read-Host "请输入选项 (1-$($Options.Count))"

    # 验证并返回
    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $Options.Count) {
        return [int]$choice - 1
    }
}
```

#### 自动安装函数

```powershell
function Install-GitHubCLI {
    # 检测 gh 命令
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        # 显示安装选项菜单
        $choice = Show-Menu -Options @(
            "使用 winget 安装（推荐）",
            "使用 Scoop 安装",
            "手动下载安装程序",
            "取消安装"
        )

        # 根据选择执行安装
        switch ($choice) {
            0 { winget install --id GitHub.cli --silent }
            1 { scoop install gh }
            2 { # 打开官网下载页面 }
            3 { exit 1 }
        }
    }
}
```

#### 自动登录函数

```powershell
function Invoke-GitHubLogin {
    # 获取登录状态
    $authStatus = gh auth status 2>&1

    if ($LASTEXITCODE -ne 0) {
        # 提示用户
        $confirm = Read-Host "是否现在进行登录? (y/n)"

        if ($confirm -eq "y") {
            # 自动运行登录
            gh auth login

            if ($LASTEXITCODE -eq 0) {
                Write-Success "GitHub 登录成功！"
                return $true
            }
        }
    }

    return $false
}
```

### 下一步建议

如需进一步优化，可以考虑：

1. 添加 `--auto` 标志自动合并（无需用户确认）
2. 记录操作日志到文件
3. 支持配置文件自定义默认选项
4. 添加 Bash/Shell 版本支持 Mac/Linux
5. 集成到 Git hooks 中自动触发
