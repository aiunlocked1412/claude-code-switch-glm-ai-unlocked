# ========================================
# Claude Code Switch GLM - AI Unlocked
# ========================================
# โดย AI UNLOCKED
# 🌐 https://aiunlock.co/
# 📺 https://www.youtube.com/@AIUnlocked168
# 📘 https://www.facebook.com/aiunlockedvip
# ========================================
# สลับใช้งาน Claude Code ได้ 4 โหมด:
# - GLM (ผ่าน proxy API)
# - Claude Subscription (Max Plan)
# - Claude API
# - Ollama (Local)
# ========================================

# --- GLM Config ---
glm_on() {
  export ANTHROPIC_AUTH_TOKEN="ใส่-GLM-TOKEN-ของคุณ-ตรงนี้"
  export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
  export API_TIMEOUT_MS="3000000"
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1"
  unset ANTHROPIC_API_KEY
  echo "✅ Switched to GLM"
}

# --- Claude Official (Subscription/Max Plan) ---
claude_sub() {
  unset ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_BASE_URL
  unset ANTHROPIC_API_KEY
  unset API_TIMEOUT_MS
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_OPUS_MODEL
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
  echo "✅ Switched to Claude Subscription"
}

# --- Claude API ---
claude_api() {
  unset ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_BASE_URL
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_OPUS_MODEL
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
  export ANTHROPIC_API_KEY="ใส่-ANTHROPIC-API-KEY-ของคุณ-ตรงนี้"
  echo "✅ Switched to Claude API"
}

# --- Ollama Local Config ---
ollama_on() {
  export ANTHROPIC_BASE_URL="http://localhost:11434"
  export ANTHROPIC_API_KEY=""
  export ANTHROPIC_AUTH_TOKEN="ollama"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="gemma4:e4b"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="gemma4:e2b"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="gemma4:e4b"
  unset API_TIMEOUT_MS
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
  echo "✅ Switched to Ollama (Local)"
}

# ========================================
# Alias ลัดเรียกใช้งาน
# ========================================

# cc  = Claude ปกติ + skip permissions
alias cc='claude --dangerously-skip-permissions'

# ccg = สลับเป็น GLM แล้วเปิด Claude
alias ccg='glm_on && claude --dangerously-skip-permissions'

# ccs = สลับเป็น Claude Subscription แล้วเปิด
alias ccs='claude_sub && claude --dangerously-skip-permissions'

# cca = สลับเป็น Claude API แล้วเปิด
alias cca='claude_api && claude --dangerously-skip-permissions'

# cco = สลับเป็น Ollama (Local) แล้วเปิด
alias cco='ollama_on && claude --dangerously-skip-permissions'

# ========================================
# คำสั่งเช็คสถานะ
# ========================================

claude_status() {
  echo "🔍 Current Claude Config:"
  echo "----------------------------"
  if [ "$ANTHROPIC_AUTH_TOKEN" = "ollama" ]; then
    echo "Mode: Ollama (Local)"
    echo "Base URL: $ANTHROPIC_BASE_URL"
  elif [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
    echo "Mode: GLM"
    echo "Base URL: $ANTHROPIC_BASE_URL"
    echo "Sonnet Model: $ANTHROPIC_DEFAULT_SONNET_MODEL"
  elif [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "Mode: Claude API"
    echo "API Key: ${ANTHROPIC_API_KEY:0:15}..."
  else
    echo "Mode: Claude Subscription"
  fi
  echo "----------------------------"
  echo "🚀 Powered by AI UNLOCKED"
}

alias ccc='claude_status'

# ========================================
# 🚀 Powered by AI UNLOCKED
# 🌐 https://aiunlock.co/
# 📺 https://www.youtube.com/@AIUnlocked168
# 📘 https://www.facebook.com/aiunlockedvip
# ========================================
