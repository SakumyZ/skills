# GitHub PR 自动化工作流脚本
# 功能: 基于当前分支创建 PR -> 获取用户输入 -> 检查冲突 -> 自动合并 (squash 模式)

param(
    [string]$ProjectPath = "",
    [string]$Title = "",
    [string]$Message = "",
    [string]$BaseBranch = "",
    [switch]$AutoMerge = $true
)

# 设置 UTF-8 编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$env:PYTHONIOENCODING = 'utf-8'
$env:LANG = 'en_US.UTF-8'

# 颜色输出辅助函数
function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# 显示菜单供用户选择
function Show-Menu {
    param(
        [string[]]$Options,
        [string]$Title = "请选择"
    )

    Write-Host ""
    Write-Host $Title
    Write-Host ""

    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$($i + 1)] $($Options[$i])"
    }

    Write-Host ""
    $choice = Read-Host "请输入选项 (1-$($Options.Count))"

    # 验证输入
    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $Options.Count) {
        return [int]$choice - 1
    }

    Write-Error-Custom "无效的选择，请重试"
    return Show-Menu -Options $Options -Title $Title
}

# 安装 GitHub CLI
function Install-GitHubCLI {
    Write-Warning-Custom "未找到 GitHub CLI (gh) 命令"
    Write-Host ""

    $installOptions = @(
        "使用 winget 安装（推荐）",
        "使用 Scoop 安装",
        "手动下载安装程序",
        "取消安装"
    )

    $choice = Show-Menu -Options $installOptions -Title "请选择安装方式:"

    switch ($choice) {
        0 {
            # winget 安装
            Write-Info "正在使用 winget 安装 GitHub CLI..."
            Write-Host ""
            Write-Host "执行命令: winget install --id GitHub.cli" -ForegroundColor Yellow
            Write-Host ""

            try {
                winget install --id GitHub.cli --silent
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "GitHub CLI 安装成功"
                    Write-Info "请关闭当前 PowerShell 窗口，重新打开后再运行此脚本"
                    exit 0
                }
                else {
                    Write-Error-Custom "winget 安装失败，请尝试其他方式"
                    return $false
                }
            }
            catch {
                Write-Error-Custom "执行 winget 出错: $_"
                return $false
            }
        }
        1 {
            # Scoop 安装
            Write-Info "正在使用 Scoop 安装 GitHub CLI..."
            Write-Host ""
            Write-Host "执行命令: scoop install gh" -ForegroundColor Yellow
            Write-Host ""

            try {
                scoop install gh
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "GitHub CLI 安装成功"
                    Write-Info "请关闭当前 PowerShell 窗口，重新打开后再运行此脚本"
                    exit 0
                }
                else {
                    Write-Error-Custom "Scoop 安装失败，请尝试其他方式"
                    return $false
                }
            }
            catch {
                Write-Error-Custom "执行 scoop 出错（Scoop 未安装？）: $_"
                Write-Info "如未安装 Scoop，可先运行: iwr -useb get.scoop.sh | iex"
                return $false
            }
        }
        2 {
            # 手动下载
            Write-Info "请访问以下链接手动下载 GitHub CLI："
            Write-Host "https://cli.github.com/" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "下载完成后，请运行安装程序，然后关闭此窗口重新打开后再运行此脚本" -ForegroundColor Yellow
            exit 0
        }
        3 {
            # 取消
            Write-Warning-Custom "已取消安装"
            exit 1
        }
    }
}

# 处理 GitHub 登录
function Invoke-GitHubLogin {
    Write-Warning-Custom "未登录 GitHub，需要进行身份验证"
    Write-Host ""

    $confirm = Read-Host "是否现在进行登录? (y/n)"
    if ($confirm -ne "y") {
        Write-Warning-Custom "已取消登录"
        exit 1
    }

    Write-Info "启动 GitHub 登录流程..."
    Write-Host ""
    Write-Host "浏览器将会打开，请完成登录流程。" -ForegroundColor Yellow
    Write-Host ""

    try {
        gh auth login

        if ($LASTEXITCODE -eq 0) {
            Write-Success "GitHub 登录成功！"
            Write-Host ""
            return $true
        }
        else {
            Write-Error-Custom "登录过程被取消或出错"
            return $false
        }
    }
    catch {
        Write-Error-Custom "执行登录命令失败: $_"
        return $false
    }
}

# 切换到项目目录
function Set-ProjectDirectory {
    if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
        if (Test-Path $ProjectPath) {
            Write-Info "切换到项目目录: $ProjectPath"
            Set-Location $ProjectPath
        }
        else {
            Write-Error-Custom "项目路径不存在: $ProjectPath"
            exit 1
        }
    }

    Write-Info "当前工作目录: $(Get-Location)"
}

# 检查前置条件
function Test-Prerequisites {
    Write-Info "检查前置条件..."

    # 检查 gh 命令
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        $installed = Install-GitHubCLI
        if (-not $installed) {
            Write-Error-Custom "请先安装 GitHub CLI 后再运行此脚本"
            exit 1
        }
    }

    # 检查 git 命令
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error-Custom "未找到 git，请先安装 git"
        Write-Host "访问: https://git-scm.com/download/win" -ForegroundColor Cyan
        exit 1
    }

    # 检查是否在 git 仓库中
    if (-not (Test-Path .git)) {
        Write-Error-Custom "当前目录不是 git 仓库"
        Write-Info "当前目录: $(Get-Location)"
        exit 1
    }

    # 检查 gh 登录状态
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        $loggedIn = Invoke-GitHubLogin
        if (-not $loggedIn) {
            Write-Error-Custom "未能成功登录 GitHub，无法继续"
            exit 1
        }
    }

    Write-Success "前置条件检查通过"
}

# 获取用户输入
function Get-UserInput {
    # 如果命令行参数已提供，直接使用
    if (-not [string]::IsNullOrWhiteSpace($Title) -and -not [string]::IsNullOrWhiteSpace($Message)) {
        Write-Info "使用命令行参数提供的 PR 信息"
        Write-Host "  标题: $Title"
        Write-Host "  Message: $($Message -replace "`n", "`n          ")"
        Write-Host ""

        return @{
            title   = $Title
            message = $Message
        }
    }

    Write-Info "请输入 PR 信息"
    Write-Host ""

    # 获取 PR 标题
    $inputTitle = $Title
    if ([string]::IsNullOrWhiteSpace($inputTitle)) {
        $inputTitle = Read-Host "PR 标题"
        if ([string]::IsNullOrWhiteSpace($inputTitle)) {
            Write-Error-Custom "PR 标题不能为空"
            exit 1
        }
    }

    # 获取 commit message
    $inputMessage = $Message
    if ([string]::IsNullOrWhiteSpace($inputMessage)) {
        Write-Host "Commit Message (按 Enter 后输入，输入 'END' 后回车结束，直接输入 'END' 则使用最近一次 commit 信息):"
        $messages = @()
        while ($true) {
            $line = Read-Host
            if ($line -ieq "END") {
                break
            }
            $messages += $line
        }
        $inputMessage = $messages -join "`n"

        # 如果未输入任何内容，使用最近一次 git commit
        if ([string]::IsNullOrWhiteSpace($inputMessage)) {
            Write-Info "未输入描述，使用最近一次 git commit 信息"
            $inputMessage = git log -1 --pretty=format:"%s%n%n%b"
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($inputMessage)) {
                Write-Error-Custom "无法获取 git commit 信息"
                exit 1
            }
            Write-Host "  使用信息: $($inputMessage -replace "`n", "`n            ")"
            Write-Host ""
        }
    }

    Write-Host ""
    Write-Info "PR 信息确认:"
    Write-Host "  标题: $inputTitle"
    Write-Host "  Message: $($inputMessage -replace "`n", "`n          ")"
    Write-Host ""

    $confirm = Read-Host "是否继续? (y/n)"
    if ($confirm -ne "y") {
        Write-Warning-Custom "已取消操作"
        exit 0
    }

    return @{
        title   = $inputTitle
        message = $inputMessage
    }
}

# 获取当前分支信息
function Get-BranchInfo {
    Write-Info "获取分支信息..."

    # 获取当前分支
    $currentBranch = git rev-parse --abbrev-ref HEAD
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "无法获取当前分支"
        exit 1
    }

    # 检查是否有未推送的更改
    $remoteCommit = git ls-remote origin $currentBranch 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "分支未推送到远程，请先运行: git push -u origin $currentBranch"
        exit 1
    }

    # 获取目标分支
    if ([string]::IsNullOrWhiteSpace($BaseBranch)) {
        $BaseBranch = git remote show origin | Select-String "HEAD branch" | ForEach-Object { $_ -split '\s+' | Select-Object -Last 1 }
        if ([string]::IsNullOrWhiteSpace($BaseBranch)) {
            $BaseBranch = "main"
        }
    }

    Write-Success "当前分支: $currentBranch"
    Write-Success "目标分支: $BaseBranch"

    return @{
        current = $currentBranch
        base    = $BaseBranch
    }
}

# 创建 PR
function New-GitHubPR {
    param(
        [string]$Title,
        [string]$Body,
        [string]$HeadBranch,
        [string]$BaseBranch
    )

    Write-Info "创建 PR..."

    $prOutput = gh pr create --title $Title --body $Body --base $BaseBranch --head $HeadBranch 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "PR 创建失败: $prOutput"
        exit 1
    }

    Write-Success "PR 创建成功"
    Write-Host $prOutput

    # 提取 PR 编号
    $prUrl = $prOutput | Select-String "https://"
    if ($prUrl) {
        $prNumber = [regex]::Match($prUrl.ToString(), '/pull/(\d+)').Groups[1].Value
        return $prNumber
    }

    return $null
}

# 检查合并冲突
function Test-MergeConflict {
    param([int]$PRNumber)

    Write-Info "检查合并冲突..."

    $prStatus = gh pr view $PRNumber --json mergeable --jq '.mergeable' 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "无法获取 PR 状态: $prStatus"
        exit 1
    }

    if ($prStatus -eq "false") {
        Write-Error-Custom "检测到合并冲突！"
        Write-Warning-Custom "请手动解决冲突后再合并"
        Write-Host ""
        Write-Host "冲突解决步骤:"
        Write-Host "  1. 本地运行: git pull origin <base-branch>"
        Write-Host "  2. 手动解决冲突文件"
        Write-Host "  3. git add ."
        Write-Host "  4. git commit --amend --no-edit"
        Write-Host "  5. git push --force"
        Write-Host "  6. 重新运行此脚本"
        return $false
    }

    Write-Success "无合并冲突，可以合并"
    return $true
}

# 合并 PR
function Merge-GitHubPR {
    param([int]$PRNumber)

    Write-Info "合并 PR (squash 模式)..."

    $mergeOutput = gh pr merge $PRNumber --squash --delete-branch 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "PR 合并失败: $mergeOutput"
        exit 1
    }

    Write-Success "PR 合并成功"
    Write-Host $mergeOutput
}

# 主工作流
function Invoke-GitHubPRWorkflow {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  GitHub PR 自动化工作流                ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # 0. 切换到项目目录（如果指定）
    Set-ProjectDirectory

    # 1. 检查前置条件
    Test-Prerequisites

    # 2. 获取分支信息
    $branchInfo = Get-BranchInfo

    # 3. 获取用户输入
    $userInput = Get-UserInput

    # 4. 创建 PR
    $prNumber = New-GitHubPR -Title $userInput.title -Body $userInput.message `
        -HeadBranch $branchInfo.current -BaseBranch $branchInfo.base

    if ([string]::IsNullOrEmpty($prNumber)) {
        Write-Warning-Custom "无法从 PR 输出中提取编号，跳过自动合并"
        Write-Info "请手动检查 PR: gh pr view --web"
        exit 0
    }

    Write-Host ""

    # 5. 检查合并冲突
    $canMerge = Test-MergeConflict -PRNumber $prNumber

    if (-not $canMerge) {
        exit 1
    }

    Write-Host ""

    # 6. 自动合并（如果启用）
    if ($AutoMerge) {
        $confirm = Read-Host "是否立即合并 PR #$prNumber? (y/n)"
        if ($confirm -eq "y") {
            Merge-GitHubPR -PRNumber $prNumber
            Write-Host ""
            Write-Success "工作流完成！"
            Write-Info "PR 已成功创建并合并"
        }
        else {
            Write-Info "跳过自动合并"
            Write-Info "稍后可运行: gh pr merge $prNumber --squash --delete-branch"
        }
    }
    else {
        Write-Info "自动合并已禁用"
        Write-Info "手动合并命令: gh pr merge $prNumber --squash --delete-branch"
    }

    Write-Host ""
}

# 执行工作流
Invoke-GitHubPRWorkflow
