# Claude Code Switch - AI Unlocked
# โหมดที่รองรับ: Claude Subscription, GLM และ DGX (LM Studio)

$script:ClaudeProviderVariables = @(
  "ANTHROPIC_AUTH_TOKEN",
  "ANTHROPIC_BASE_URL",
  "ANTHROPIC_API_KEY",
  "API_TIMEOUT_MS",
  "ANTHROPIC_DEFAULT_HAIKU_MODEL",
  "ANTHROPIC_DEFAULT_SONNET_MODEL",
  "ANTHROPIC_DEFAULT_OPUS_MODEL",
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC",
  "CLAUDE_CODE_AUTO_COMPACT_WINDOW"
)

function Clear-ClaudeProviderEnv {
  foreach ($name in $script:ClaudeProviderVariables) {
    Remove-Item "Env:$name" -ErrorAction SilentlyContinue
  }
}

function glm_on {
  Clear-ClaudeProviderEnv
  $glmToken = [Environment]::GetEnvironmentVariable("AIUNLOCKED_GLM_TOKEN", "User")
  if ([string]::IsNullOrWhiteSpace($glmToken)) {
    throw "AIUNLOCKED_GLM_TOKEN is not configured in the User environment."
  }

  $env:ANTHROPIC_AUTH_TOKEN = $glmToken
  $env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"
  $env:API_TIMEOUT_MS = "3000000"
  $env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
  $env:CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000"
  $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"
  $env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5.3"
  $env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.3"
  Write-Host "Switched to GLM" -ForegroundColor Green
}

function claude_sub {
  Clear-ClaudeProviderEnv
  Write-Host "Switched to Claude Subscription" -ForegroundColor Cyan
}

function Ensure-DgxProxy {
  $healthUrl = "http://127.0.0.1:18150/health"
  try {
    Invoke-RestMethod -Uri $healthUrl -TimeoutSec 1 | Out-Null
    return
  } catch {
    $node = Get-Command node -ErrorAction Stop
    $proxyScript = Join-Path $PSScriptRoot "dgx-anthropic-proxy.js"
    Start-Process -FilePath $node.Source -ArgumentList @($proxyScript) -WindowStyle Hidden
  }

  foreach ($attempt in 1..20) {
    Start-Sleep -Milliseconds 250
    try {
      Invoke-RestMethod -Uri $healthUrl -TimeoutSec 1 | Out-Null
      return
    } catch {
      if ($attempt -eq 20) {
        throw "DGX compatibility proxy failed to start."
      }
    }
  }
}

function dgx_on {
  Clear-ClaudeProviderEnv
  Ensure-DgxProxy
  $env:ANTHROPIC_AUTH_TOKEN = "lm-studio"
  $env:ANTHROPIC_BASE_URL = "http://127.0.0.1:18150"
  $env:API_TIMEOUT_MS = "3000000"
  $env:CLAUDE_CODE_AUTO_COMPACT_WINDOW = "200000"
  $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "qwen3.8-27b-uncensored"
  $env:ANTHROPIC_DEFAULT_SONNET_MODEL = "openthai2.0-qwen3.8-27b"
  $env:ANTHROPIC_DEFAULT_OPUS_MODEL = "qwen3.8-flash-next@iq4_xs"
  Write-Host "Switched to DGX (LM Studio)" -ForegroundColor Yellow
}

@("claude_api", "ollama_on", "sglang_on", "cca", "cco", "ccq") | ForEach-Object {
  Remove-Item "Function:$_" -ErrorAction SilentlyContinue
}

function cc  { claude --dangerously-skip-permissions @args }
function ccg { glm_on; claude --dangerously-skip-permissions @args }
function ccs { claude_sub; claude --dangerously-skip-permissions @args }
function ccd { dgx_on; claude --dangerously-skip-permissions @args }

function claude_status {
  Write-Host "Current Claude Config" -ForegroundColor White
  Write-Host "----------------------------"
  if ($env:ANTHROPIC_BASE_URL -eq "http://127.0.0.1:18150") {
    Write-Host "Mode: DGX (LM Studio)" -ForegroundColor Yellow
    Write-Host "DGX: http://192.168.1.150:8080"
    Write-Host "Haiku:  $env:ANTHROPIC_DEFAULT_HAIKU_MODEL"
    Write-Host "Sonnet: $env:ANTHROPIC_DEFAULT_SONNET_MODEL"
    Write-Host "Opus:   $env:ANTHROPIC_DEFAULT_OPUS_MODEL"
  } elseif ($env:ANTHROPIC_BASE_URL -eq "https://api.z.ai/api/anthropic") {
    Write-Host "Mode: GLM" -ForegroundColor Green
    Write-Host "Base URL: $env:ANTHROPIC_BASE_URL"
    Write-Host "Sonnet: $env:ANTHROPIC_DEFAULT_SONNET_MODEL"
  } else {
    Write-Host "Mode: Claude Subscription" -ForegroundColor Cyan
  }
  Write-Host "----------------------------"
}

function ccc { claude_status }
