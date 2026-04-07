# ========================================
# Claude Code Switch GLM - AI Unlocked
# ========================================
# โดย AI UNLOCKED
# https://aiunlock.co/
# https://www.youtube.com/@AIUnlocked168
# https://www.facebook.com/aiunlockedvip
# ========================================
# สลับใช้งาน Claude Code ได้ 4 โหมด:
# - GLM (ผ่าน proxy API)
# - Claude Subscription (Max Plan)
# - Claude API
# - Ollama (Local)
# ========================================

# --- GLM Config ---
function glm_on {
  $env:ANTHROPIC_AUTH_TOKEN = "ใส่-GLM-TOKEN-ของคุณ-ตรงนี้"
  $env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"
  $env:API_TIMEOUT_MS = "3000000"
  $env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
  $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"
  $env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5.1"
  $env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.1"
  Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
  Write-Host "✅ Switched to GLM" -ForegroundColor Green
}

# --- Claude Official (Subscription/Max Plan) ---
function claude_sub {
  Remove-Item Env:ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
  Remove-Item Env:API_TIMEOUT_MS -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_DEFAULT_HAIKU_MODEL -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_DEFAULT_SONNET_MODEL -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_DEFAULT_OPUS_MODEL -ErrorAction SilentlyContinue
  Remove-Item Env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC -ErrorAction SilentlyContinue
  Write-Host "✅ Switched to Claude Subscription" -ForegroundColor Cyan
}

# --- Claude API ---
function claude_api {
  Remove-Item Env:ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_DEFAULT_HAIKU_MODEL -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_DEFAULT_SONNET_MODEL -ErrorAction SilentlyContinue
  Remove-Item Env:ANTHROPIC_DEFAULT_OPUS_MODEL -ErrorAction SilentlyContinue
  Remove-Item Env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC -ErrorAction SilentlyContinue
  $env:ANTHROPIC_API_KEY = "ใส่-ANTHROPIC-API-KEY-ของคุณ-ตรงนี้"
  Write-Host "✅ Switched to Claude API" -ForegroundColor Magenta
}

# --- Ollama Local Config ---
function ollama_on {
  $env:ANTHROPIC_BASE_URL = "http://localhost:11434"
  $env:ANTHROPIC_API_KEY = ""
  $env:ANTHROPIC_AUTH_TOKEN = "ollama"
  $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "gemma4:e4b"
  $env:ANTHROPIC_DEFAULT_SONNET_MODEL = "gemma4:e2b"
  $env:ANTHROPIC_DEFAULT_OPUS_MODEL = "gemma4:e4b"
  Remove-Item Env:API_TIMEOUT_MS -ErrorAction SilentlyContinue
  Remove-Item Env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC -ErrorAction SilentlyContinue
  Write-Host "✅ Switched to Ollama (Local)" -ForegroundColor Yellow
}

# ========================================
# Alias ลัดเรียกใช้งาน
# ========================================

# cc  = Claude ปกติ + skip permissions
function cc { claude --dangerously-skip-permissions @args }

# ccg = สลับเป็น GLM แล้วเปิด Claude
function ccg { glm_on; claude --dangerously-skip-permissions @args }

# ccs = สลับเป็น Claude Subscription แล้วเปิด
function ccs { claude_sub; claude --dangerously-skip-permissions @args }

# cca = สลับเป็น Claude API แล้วเปิด
function cca { claude_api; claude --dangerously-skip-permissions @args }

# cco = สลับเป็น Ollama (Local) แล้วเปิด
function cco { ollama_on; claude --dangerously-skip-permissions @args }

# ========================================
# คำสั่งเช็คสถานะ
# ========================================

function claude_status {
  Write-Host "🔍 Current Claude Config:" -ForegroundColor White
  Write-Host "----------------------------"
  if ($env:ANTHROPIC_AUTH_TOKEN -eq "ollama") {
    Write-Host "Mode: Ollama (Local)" -ForegroundColor Yellow
    Write-Host "Base URL: $env:ANTHROPIC_BASE_URL"
  } elseif ($env:ANTHROPIC_AUTH_TOKEN) {
    Write-Host "Mode: GLM" -ForegroundColor Green
    Write-Host "Base URL: $env:ANTHROPIC_BASE_URL"
    Write-Host "Sonnet Model: $env:ANTHROPIC_DEFAULT_SONNET_MODEL"
  } elseif ($env:ANTHROPIC_API_KEY) {
    Write-Host "Mode: Claude API" -ForegroundColor Magenta
    Write-Host "API Key: $($env:ANTHROPIC_API_KEY.Substring(0,15))..."
  } else {
    Write-Host "Mode: Claude Subscription" -ForegroundColor Cyan
  }
  Write-Host "----------------------------"
  Write-Host "🚀 Powered by AI UNLOCKED" -ForegroundColor White
}

function ccc { claude_status }

# ========================================
# 🚀 Powered by AI UNLOCKED
# https://aiunlock.co/
# https://www.youtube.com/@AIUnlocked168
# https://www.facebook.com/aiunlockedvip
# ========================================
