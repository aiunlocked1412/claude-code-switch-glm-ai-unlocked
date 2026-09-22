# Claude Code Switch - AI Unlocked
# โหมดที่รองรับ: Claude Subscription, GLM (z.ai), DGX Spark (vLLM) และ LM Studio

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

# DGX Spark สองเครื่องเสิร์ฟทีละโมเดลที่ port เดียวกัน เพราะใช้ GPU ชุดเดียวกัน
# vLLM มี endpoint /v1/messages แบบ Anthropic อยู่แล้ว Claude Code จึงต่อตรงได้
# ไม่ต้องผ่าน proxy
$script:DgxSparkBaseUrl = "http://192.168.1.150:8888"
$script:DgxSparkHost = "dgx"
$script:DgxSparkSwitchScript = "/home/aiunlock/switch-model.sh"

# target คือชื่อที่ switch-model.sh รู้จัก, ModelId คือค่าที่ /v1/models ตอบกลับมา
$script:DgxSparkModels = @{
  qwen     = @{ ModelId = "qwen3.8-flash-next";        Label = "Qwen3.8 Flash Next";   CompactWindow = "200000" }
  glm      = @{ ModelId = "GLM-5.3-Flash-EXL3";        Label = "GLM-5.3 Flash EXL3";   CompactWindow = "400000" }
  deepseek = @{ ModelId = "DeepSeek-v4.1-Flash-EXL3";  Label = "DeepSeek v4.1 Flash";  CompactWindow = "400000" }
}

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
  Write-Host "Switched to GLM (z.ai)" -ForegroundColor Green
}

function claude_sub {
  Clear-ClaudeProviderEnv
  Write-Host "Switched to Claude Subscription" -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# DGX Spark (vLLM, /v1/messages)
# ---------------------------------------------------------------------------

function Get-DgxSparkModel {
  # คืน model id ที่กำลังเสิร์ฟอยู่ หรือ $null เมื่อเครื่องยังไม่พร้อม
  try {
    $models = Invoke-RestMethod -Uri "$script:DgxSparkBaseUrl/v1/models" -TimeoutSec 4
    return $models.data[0].id
  } catch {
    return $null
  }
}

function Get-DgxSparkTarget {
  param([string]$ModelId)
  if ([string]::IsNullOrWhiteSpace($ModelId)) { return $null }
  foreach ($target in $script:DgxSparkModels.Keys) {
    if ($script:DgxSparkModels[$target].ModelId -eq $ModelId) { return $target }
  }
  return $null
}

function dgx_switch {
  # สลับโมเดลบน DGX1 แล้วรอจน API ตอบ ใช้เวลา 12-40 นาทีแล้วแต่ checkpoint
  param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("qwen", "glm", "deepseek", "status", "stop")]
    [string]$Target
  )
  Write-Host "Running $script:DgxSparkSwitchScript $Target on $script:DgxSparkHost ..." -ForegroundColor Yellow
  ssh $script:DgxSparkHost "$script:DgxSparkSwitchScript $Target"
}

function dgx_on {
  # ไม่ระบุ -Target = ใช้โมเดลที่กำลังเสิร์ฟอยู่
  # -Switch = ถ้าโมเดลไม่ตรง ให้สั่งสลับบนเครื่องแล้วรอ
  param(
    [ValidateSet("qwen", "glm", "deepseek")]
    [string]$Target,
    [switch]$Switch,
    [switch]$Thinking
  )

  $served = Get-DgxSparkModel
  if ($null -eq $served) {
    throw "DGX Spark API at $script:DgxSparkBaseUrl is not answering. Check with: ssh $script:DgxSparkHost $script:DgxSparkSwitchScript status"
  }

  $servedTarget = Get-DgxSparkTarget -ModelId $served
  if ($Target -and $servedTarget -ne $Target) {
    if ($Switch) {
      dgx_switch -Target $Target
      $served = Get-DgxSparkModel
      $servedTarget = Get-DgxSparkTarget -ModelId $served
      if ($servedTarget -ne $Target) {
        throw "Switch to $Target did not finish; the API is serving '$served'."
      }
    } else {
      # สลับเองไม่ได้เงียบ ๆ เพราะต้องดับโมเดลที่คนอื่นอาจกำลังใช้อยู่
      throw "DGX Spark is serving '$served', not $Target. Switch first: dgx_switch $Target   (หรือ dgx_on -Target $Target -Switch)"
    }
  }

  $known = if ($servedTarget) { $script:DgxSparkModels[$servedTarget] } else { $null }

  Clear-ClaudeProviderEnv
  # ผ่าน proxy ไม่ได้ยิงตรง: thinking mode ของ Qwen3 เปิดอยู่เป็นค่าเริ่มต้น และ
  # Anthropic API ไม่มีช่องให้ปิด ตัว proxy จึงใส่ chat_template_kwargs ให้
  # -Thinking เมื่อเป็นงานที่คุ้มจะให้มันคิดก่อนตอบ
  Ensure-AnthropicProxy -Port 18151 -Upstream $script:DgxSparkBaseUrl -Thinking:$Thinking
  $env:ANTHROPIC_AUTH_TOKEN = "dgx"
  $env:ANTHROPIC_BASE_URL = "http://127.0.0.1:18151"
  $env:API_TIMEOUT_MS = "3000000"
  $env:CLAUDE_CODE_AUTO_COMPACT_WINDOW = if ($known) { $known.CompactWindow } else { "200000" }
  $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = $served
  $env:ANTHROPIC_DEFAULT_SONNET_MODEL = $served
  $env:ANTHROPIC_DEFAULT_OPUS_MODEL = $served

  $label = if ($known) { $known.Label } else { $served }
  Write-Host "Switched to DGX Spark - $label ($served)" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# LM Studio (ยังใช้ compatibility proxy เพราะ chat template ต้องการ system
# message รวมไว้ที่เดียว)
# ---------------------------------------------------------------------------

function Ensure-AnthropicProxy {
  # หนึ่ง instance ต่อหนึ่ง upstream แยกพอร์ตกัน ตัว proxy อ่านค่าจาก env
  # ตอนสตาร์ต จึงต้องเช็กว่าตัวที่รันอยู่ชี้ไป upstream เดียวกันจริง
  param(
    [Parameter(Mandatory)][int]$Port,
    [Parameter(Mandatory)][string]$Upstream,
    [switch]$Thinking
  )

  $healthUrl = "http://127.0.0.1:$Port/health"
  try {
    $health = Invoke-RestMethod -Uri $healthUrl -TimeoutSec 1
    if ($health.upstream -eq $Upstream -and [bool]$health.thinking -eq [bool]$Thinking) { return }
    throw "proxy on $Port points at $($health.upstream) (thinking=$($health.thinking)); restart it"
  } catch [System.Net.WebException] {
  } catch [System.Net.Http.HttpRequestException] {
  }

  $node = Get-Command node -ErrorAction Stop
  $proxyScript = Join-Path $PSScriptRoot "dgx-anthropic-proxy.js"
  $env:DGX_PROXY_PORT = "$Port"
  $env:DGX_PROXY_UPSTREAM = $Upstream
  $env:DGX_THINKING = if ($Thinking) { "1" } else { "0" }
  Start-Process -FilePath $node.Source -ArgumentList @($proxyScript) -WindowStyle Hidden

  foreach ($attempt in 1..20) {
    Start-Sleep -Milliseconds 250
    try {
      Invoke-RestMethod -Uri $healthUrl -TimeoutSec 1 | Out-Null
      return
    } catch {
      if ($attempt -eq 20) {
        throw "compatibility proxy on port $Port failed to start."
      }
    }
  }
}

function Ensure-LmStudioProxy {
  Ensure-AnthropicProxy -Port 18150 -Upstream "http://192.168.1.150:8080"
}

function lmstudio_on {
  param([string]$Model)
  Clear-ClaudeProviderEnv
  Ensure-LmStudioProxy
  $env:ANTHROPIC_AUTH_TOKEN = "lm-studio"
  $env:ANTHROPIC_BASE_URL = "http://127.0.0.1:18150"
  $env:API_TIMEOUT_MS = "3000000"
  $env:CLAUDE_CODE_AUTO_COMPACT_WINDOW = "200000"
  if ($Model) {
    $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = $Model
    $env:ANTHROPIC_DEFAULT_SONNET_MODEL = $Model
    $env:ANTHROPIC_DEFAULT_OPUS_MODEL = $Model
  } else {
    $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "qwen3.8-27b-uncensored"
    $env:ANTHROPIC_DEFAULT_SONNET_MODEL = "openthai2.0-qwen3.8-27b"
    $env:ANTHROPIC_DEFAULT_OPUS_MODEL = "qwen3.8-flash-next@iq4_xs"
  }
  Write-Host "Switched to LM Studio" -ForegroundColor Magenta
}

@("claude_api", "ollama_on", "sglang_on", "cca", "cco", "ccq") | ForEach-Object {
  Remove-Item "Function:$_" -ErrorAction SilentlyContinue
}

# อาร์กิวเมนต์ที่ส่งต่อ ตกไปที่ claude เสมอ ส่วนการเลือกโมเดลอยู่ในชื่อคำสั่ง
function cc   { claude --dangerously-skip-permissions @args }
function ccg  { glm_on; claude --dangerously-skip-permissions @args }
function ccs  { claude_sub; claude --dangerously-skip-permissions @args }
function ccd  { dgx_on; claude --dangerously-skip-permissions @args }
function ccl  { lmstudio_on; claude --dangerously-skip-permissions @args }

# ลัดไปที่โมเดลใดโมเดลหนึ่งบน DGX Spark โดยตรง จะไม่สั่งสลับเองถ้าเสิร์ฟอยู่คนละตัว
function ccdq { dgx_on -Target qwen;     claude --dangerously-skip-permissions @args }

# เหมือน ccdq แต่เปิด thinking ไว้ ช้ากว่ามาก ใช้กับงานที่ต้องคิดจริง ๆ
function ccdqt { dgx_on -Target qwen -Thinking; claude --dangerously-skip-permissions @args }
function ccdg { dgx_on -Target glm;      claude --dangerously-skip-permissions @args }
function ccdd { dgx_on -Target deepseek; claude --dangerously-skip-permissions @args }

function claude_status {
  Write-Host "Current Claude Config" -ForegroundColor White
  Write-Host "----------------------------"
  if ($env:ANTHROPIC_BASE_URL -eq "http://127.0.0.1:18151") {
    $served = Get-DgxSparkModel
    $target = Get-DgxSparkTarget -ModelId $served
    $label = if ($target) { $script:DgxSparkModels[$target].Label } else { "unknown" }
    Write-Host "Mode: DGX Spark (vLLM)" -ForegroundColor Yellow
    Write-Host "Base URL: $script:DgxSparkBaseUrl"
    Write-Host "Configured model: $env:ANTHROPIC_DEFAULT_SONNET_MODEL"
    if ($null -eq $served) {
      Write-Host "Serving now: API not answering" -ForegroundColor Red
    } else {
      Write-Host "Serving now: $served ($label)"
      if ($served -ne $env:ANTHROPIC_DEFAULT_SONNET_MODEL) {
        Write-Host "Model changed on the server - run ccd to pick it up" -ForegroundColor Red
      }
    }
  } elseif ($env:ANTHROPIC_BASE_URL -eq "http://127.0.0.1:18150") {
    Write-Host "Mode: LM Studio" -ForegroundColor Magenta
    Write-Host "Upstream: http://192.168.1.150:8080 (via proxy 127.0.0.1:18150)"
    Write-Host "Haiku:  $env:ANTHROPIC_DEFAULT_HAIKU_MODEL"
    Write-Host "Sonnet: $env:ANTHROPIC_DEFAULT_SONNET_MODEL"
    Write-Host "Opus:   $env:ANTHROPIC_DEFAULT_OPUS_MODEL"
  } elseif ($env:ANTHROPIC_BASE_URL -eq "https://api.z.ai/api/anthropic") {
    Write-Host "Mode: GLM (z.ai)" -ForegroundColor Green
    Write-Host "Base URL: $env:ANTHROPIC_BASE_URL"
    Write-Host "Sonnet: $env:ANTHROPIC_DEFAULT_SONNET_MODEL"
  } else {
    Write-Host "Mode: Claude Subscription" -ForegroundColor Cyan
  }
  Write-Host "----------------------------"
}

function ccc { claude_status }

function dgx_models {
  # โมเดลที่ติดตั้งไว้บนเครื่อง กับตัวที่กำลังเสิร์ฟอยู่ตอนนี้
  $served = Get-DgxSparkModel
  Write-Host "DGX Spark models" -ForegroundColor White
  Write-Host "----------------------------"
  foreach ($target in @("qwen", "glm", "deepseek")) {
    $entry = $script:DgxSparkModels[$target]
    $mark = if ($entry.ModelId -eq $served) { "* " } else { "  " }
    Write-Host ("{0}{1,-9} {2,-26} {3}" -f $mark, $target, $entry.ModelId, $entry.Label)
  }
  Write-Host "----------------------------"
  if ($null -eq $served) {
    Write-Host "API not answering at $script:DgxSparkBaseUrl" -ForegroundColor Red
  } else {
    Write-Host "* = serving now"
  }
}
