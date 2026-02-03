param(
  [Parameter(Mandatory = $true)]
  [string]$Version
)

$raw = $Version.Trim()
if ($raw.StartsWith('v')) {
  $raw = $raw.Substring(1)
}
if ($raw -notmatch '^\d+\.\d+\.\d+(\+\d+)?$') {
  throw "Invalid version format. Expected like 1.7.17+45 or v1.7.17+45"
}

$pubVersion = $raw
$txtVersion = "v$raw"

function Replace-Line($path, $pattern, $replacement) {
  if (-not (Test-Path $path)) { return $false }
  $content = Get-Content $path -Raw
  if ($content -match $pattern) {
    $content = [regex]::Replace($content, $pattern, $replacement, 'Multiline')
    Set-Content -Path $path -Value $content
    return $true
  }
  return $false
}

# pubspec.yaml
Replace-Line "pubspec.yaml" '^version:\s*.*$' "version: $pubVersion" | Out-Null

# assets version
Set-Content -Path "lib\assets\version.txt" -Value $txtVersion

# ci version.code.txt
if (Test-Path "ci\version.code.txt") {
  Set-Content -Path "ci\version.code.txt" -Value $txtVersion
}

# ci version.info.txt (update first line only)
if (Test-Path "ci\version.info.txt") {
  $lines = Get-Content "ci\version.info.txt"
  if ($lines.Length -gt 0) {
    $lines[0] = $txtVersion
    Set-Content -Path "ci\version.info.txt" -Value $lines
  }
}

Write-Host "Updated version to $txtVersion"
