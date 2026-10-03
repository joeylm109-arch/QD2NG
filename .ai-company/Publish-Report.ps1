param(
    [Parameter(Mandatory = $true)][string]$Report,
    [Parameter(Mandatory = $true)][string]$Review,
    [Parameter(Mandatory = $true)][string]$Config,
    [switch]$LocalOnly
)
$ErrorActionPreference = 'Stop'
$cfg = Get-Content -LiteralPath $Config -Raw | ConvertFrom-Json
$receipt = Get-Content -LiteralPath $Review -Raw | ConvertFrom-Json
$source = (Resolve-Path -LiteralPath $Report).Path
$name = Split-Path $source -Leaf
if ($name -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*\.md$') { throw 'Use a simple Markdown report filename.' }
if ($receipt.verdict -cne 'PASS' -or $receipt.directorApproved -isnot [bool] -or !$receipt.directorApproved -or !$receipt.evidence) {
    throw 'Publication requires PASS, Director approval and review evidence.'
}
$hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
if ($hash -ine $receipt.sha256) { throw 'Report changed or approval hash is missing. Request a fresh review.' }
$body = Get-Content -LiteralPath $source -Raw
if ([string]::IsNullOrWhiteSpace($body)) { throw 'Report is empty.' }
if ($body -match '(?i)(gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|-----BEGIN .*PRIVATE KEY-----)') {
    throw 'Possible secret found. Redact and request a fresh review.'
}
$repo = (Resolve-Path -LiteralPath $cfg.repositoryPath).Path
$vault = (Resolve-Path -LiteralPath $cfg.obsidianVault).Path
$remote = & git -C $repo remote get-url origin
if ($LASTEXITCODE -ne 0 -or $remote.Trim() -notin @('https://github.com/joeylm109-arch/QD2NG.git', 'https://github.com/joeylm109-arch/QD2NG', 'git@github.com:joeylm109-arch/QD2NG.git')) {
    throw 'Unexpected GitHub destination.'
}
$relative = 'reports/' + $name
$gitTarget = Join-Path $repo $relative
$obsidianDir = Join-Path $vault 'AI Company'
$obsidianTarget = Join-Path $obsidianDir $name
# Existing notes and linked directories are not overwritten or followed.
foreach ($directory in @((Join-Path $repo 'reports'), $obsidianDir)) {
    if (Test-Path -LiteralPath $directory) {
        if ((Get-Item -LiteralPath $directory).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked output directory refused: $directory" }
    }
}
foreach ($target in @($gitTarget, $obsidianTarget)) {
    if (Test-Path -LiteralPath $target) {
        if ((Get-Item -LiteralPath $target).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked output file refused.' }
        if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ine $hash) { throw "Existing different report refused: $target" }
    }
}
if (!$LocalOnly) {
    $staged = & git -C $repo diff --cached --name-only
    if ($LASTEXITCODE -ne 0 -or $staged) { throw 'Git index must be empty before publishing.' }
    $branch = & git -C $repo branch --show-current
    if ($LASTEXITCODE -ne 0 -or $branch.Trim() -ne 'main') { throw 'Publication checkout must be on main.' }
}
New-Item -ItemType Directory -Path (Split-Path $gitTarget), $obsidianDir -Force | Out-Null
foreach ($target in @($gitTarget, $obsidianTarget)) {
    if (!(Test-Path -LiteralPath $target)) { Copy-Item -LiteralPath $source -Destination $target }
    if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ine $hash) { throw 'Output verification failed.' }
}
if ($LocalOnly) {
    Write-Output "LOCAL_ONLY: copied and hash-verified; no commit or push. Obsidian: $obsidianTarget"
    exit 0
}
& git -C $repo add -- $relative
if ($LASTEXITCODE -ne 0) { throw 'Could not stage the report.' }
& git -C $repo diff --cached --quiet
if ($LASTEXITCODE -eq 1) {
    & git -C $repo commit -m "Publish reviewed report: $name" -- $relative
    if ($LASTEXITCODE -ne 0) { throw 'Commit failed; copied files remain local.' }
} elseif ($LASTEXITCODE -ne 0) { throw 'Could not inspect staged report.' }
& git -C $repo -c credential.interactive=false push origin main
if ($LASTEXITCODE -ne 0) { throw 'GitHub push failed. Local report remains available; do not claim publication succeeded.' }
$commit = & git -C $repo rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Could not read published commit.' }
Write-Output "PUBLISHED: https://github.com/joeylm109-arch/QD2NG/commit/$commit"
Write-Output "OBSIDIAN: $obsidianTarget"
