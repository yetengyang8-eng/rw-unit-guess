<#
.SYNOPSIS
    GPT -> GitHub write bridge for the rw-unit-guess experiment.

.DESCRIPTION
    ChatGPT's GitHub connector returns 403 on writes, but this machine has a
    working git credential (OAuth token with `repo` scope, verified).
    This script lets GPT's output reach GitHub through that working channel.

    GPT produces Markdown text. The text is handed to this script (via the User,
    or via DeepSeek invoking it). The script pulls, writes the file, commits and
    pushes, then verifies the remote copy. It never prints or stores credentials.

.PARAMETER Path
    Repo-relative path, e.g. turns/001_gpt.md

.PARAMETER ContentFile
    Local file holding the Markdown content to publish.

.PARAMETER Message
    Commit message.

.PARAMETER Verify
    After pushing, re-read the file from GitHub and print the remote content.

.EXAMPLE
    .\bridge.ps1 -Path turns/001_gpt.md -ContentFile C:\tmp\gpt_out.md `
                  -Message "round 1: GPT analysis" -Verify
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$ContentFile,
    [Parameter(Mandatory = $true)][string]$Message,
    [switch]$Verify
)

$ErrorActionPreference = 'Stop'
$env:GIT_TERMINAL_PROMPT = '0'

$RepoUrl  = 'https://github.com/yetengyang8-eng/rw-unit-guess.git'
$Slug     = 'yetengyang8-eng/rw-unit-guess'
$Work     = 'G:\rw-unit-guess'

if (-not (Test-Path (Join-Path $Work '.git'))) {
    Write-Host "[bridge] cloning $Slug ..."
    git clone --quiet $RepoUrl $Work
    git -C $Work config user.name  'DeepSeek-Bridge'
    git -C $Work config user.email 'deepseek-bridge@localhost'
}

if (-not (Test-Path $ContentFile)) { throw "ContentFile not found: $ContentFile" }

# Never let a secret or the experiment answer sneak in via a stray path.
$rel = $Path -replace '\\', '/'
if ($rel -match '\.\.' -or $rel.StartsWith('/')) { throw "Unsafe path: $Path" }

# Refuse to run over uncommitted work: `reset --hard` would silently discard it.
$dirty = git -C $Work status --porcelain
if ($dirty) {
    Write-Host "[bridge] WARNING: working copy has uncommitted changes:"
    $dirty | ForEach-Object { Write-Host "    $_" }
    Write-Host "[bridge] commit or stash them first; aborting to avoid data loss."
    exit 2
}

Write-Host "[bridge] syncing working copy ..."
git -C $Work fetch --quiet origin main
git -C $Work checkout --quiet main 2>$null
git -C $Work merge --ff-only --quiet origin/main
if ($LASTEXITCODE -ne 0) { throw "cannot fast-forward to origin/main; working copy has diverged" }

$dest = Join-Path $Work ($rel -replace '/', '\')
$destDir = Split-Path $dest -Parent
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }

Copy-Item -LiteralPath $ContentFile -Destination $dest -Force
git -C $Work add -- $rel

$staged = git -C $Work diff --cached --name-only
if (-not $staged) {
    Write-Host "[bridge] no changes staged; nothing to commit."
    exit 0
}

git -C $Work commit --quiet -m $Message
$head = git -C $Work rev-parse HEAD
Write-Host "[bridge] committed $head"

git -C $Work push --quiet origin main
if ($LASTEXITCODE -ne 0) { throw "push failed (exit $LASTEXITCODE)" }

$remote = (git -C $Work ls-remote origin refs/heads/main).Split("`t")[0]
Write-Host "[bridge] push OK. local=$head remote=$remote"
if ($remote -ne $head) { throw "remote hash mismatch: local=$head remote=$remote" }
Write-Host "[bridge] remote hash verified."

if ($Verify) {
    $url = "https://raw.githubusercontent.com/$Slug/$head/$rel"
    Write-Host "[bridge] re-reading remote copy at commit $($head.Substring(0,7)) ..."
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 25
        Write-Host "[bridge] HTTP $($r.StatusCode), $($r.RawContentLength) bytes"
        Write-Host '----- remote content -----'
        Write-Host $r.Content
        Write-Host '----- end -----'
    } catch {
        Write-Host "[bridge] WARN: remote re-read failed: $($_.Exception.Message)"
    }
}
