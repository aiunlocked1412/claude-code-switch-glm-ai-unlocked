# ========================================
# Claude Code Switch GLM - AI Unlocked
# ========================================
# โดย AI UNLOCKED
# 🌐 https://aiunlock.co/
# 📺 https://www.youtube.com/@AIUnlocked168
# 📘 https://www.facebook.com/aiunlockedvip
# ========================================
# สลับใช้งาน Claude Code ได้ 6 โหมด:
# - GLM (ผ่าน proxy API)
# - Claude Subscription (Max Plan)
# - Claude API
# - Ollama (Local)
# - SGLang (Local / Qwen3.8)
# - DGX Spark (vLLM สองเครื่อง: Qwen3.8 / GLM-5.3 / DeepSeek v4.1)
# ========================================

# --- GLM Config ---
glm_on() {
  export ANTHROPIC_AUTH_TOKEN="ใส่-GLM-TOKEN-ของคุณ-ตรงนี้"
  export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
  export API_TIMEOUT_MS="3000000"
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.3"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.3"
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
  unset CLAUDE_CODE_AUTO_COMPACT_WINDOW
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
  unset CLAUDE_CODE_AUTO_COMPACT_WINDOW
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
  unset CLAUDE_CODE_AUTO_COMPACT_WINDOW
  echo "✅ Switched to Ollama (Local)"
}

# --- SGLang Local Config (Qwen3.8) ---
sglang_on() {
  export ANTHROPIC_BASE_URL="http://localhost:30000"
  export ANTHROPIC_AUTH_TOKEN="sglang"
  export API_TIMEOUT_MS="3000000"
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW="120000"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="qwen3.8-27b"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="qwen3.8-27b"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="qwen3.8-27b"
  unset ANTHROPIC_API_KEY
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
  echo "✅ Switched to SGLang (Local)"
}

# ========================================
# DGX Spark (vLLM, 2 เครื่อง)
# ========================================
# ทั้งสามโมเดลใช้ GPU ชุดเดียวกันและ port เดียวกัน จึงเสิร์ฟได้ทีละตัว
# vLLM มี endpoint /v1/messages แบบ Anthropic อยู่แล้ว ต่อตรงได้ไม่ต้องใช้ proxy

DGX_SPARK_BASE_URL="http://192.168.1.150:8888"
DGX_SPARK_HOST="dgx"
DGX_SPARK_SWITCH="/home/aiunlock/switch-model.sh"

# model id ที่ /v1/models ตอบกลับมาของแต่ละ target
dgx_model_id() {
  case "$1" in
    qwen)     echo "qwen3.8-flash-next" ;;
    glm)      echo "GLM-5.3-Flash-EXL3" ;;
    deepseek) echo "DeepSeek-v4.1-Flash-EXL3" ;;
    *)        echo "" ;;
  esac
}

# ขนาด auto-compact ตาม context ของแต่ละโมเดล
dgx_compact_window() {
  case "$1" in
    qwen3.8-flash-next)       echo "200000" ;;
    GLM-5.3-Flash-EXL3)       echo "400000" ;;
    DeepSeek-v4.1-Flash-EXL3) echo "400000" ;;
    *)                        echo "200000" ;;
  esac
}

# โมเดลที่กำลังเสิร์ฟอยู่ ว่างเปล่าเมื่อ API ไม่ตอบ
dgx_served_model() {
  curl -s --max-time 4 "$DGX_SPARK_BASE_URL/v1/models" 2>/dev/null     | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4
}

# สลับโมเดลบนเครื่อง ใช้เวลา 12-40 นาทีแล้วแต่ checkpoint
dgx_switch() {
  local target="${1:-status}"
  echo "▶ $DGX_SPARK_SWITCH $target on $DGX_SPARK_HOST"
  ssh "$DGX_SPARK_HOST" "$DGX_SPARK_SWITCH $target"
}

# dgx_on            = ใช้โมเดลที่กำลังเสิร์ฟอยู่
# dgx_on qwen       = ต้องการ Qwen; ถ้าเครื่องเสิร์ฟตัวอื่นอยู่จะเตือน ไม่สลับให้เอง
dgx_on() {
  local want="$1"
  local served
  served="$(dgx_served_model)"

  if [ -z "$served" ]; then
    echo "❌ DGX Spark ที่ $DGX_SPARK_BASE_URL ไม่ตอบ ตรวจด้วย: ssh $DGX_SPARK_HOST $DGX_SPARK_SWITCH status"
    return 1
  fi

  if [ -n "$want" ]; then
    local wanted_id
    wanted_id="$(dgx_model_id "$want")"
    if [ -z "$wanted_id" ]; then
      echo "❌ target ไม่ถูกต้อง: $want (ใช้ qwen | glm | deepseek)"
      return 1
    fi
    if [ "$wanted_id" != "$served" ]; then
      # ไม่สลับให้เองเพราะต้องดับโมเดลที่คนอื่นอาจกำลังใช้อยู่
      echo "❌ ตอนนี้เสิร์ฟ '$served' ไม่ใช่ $want — สลับก่อนด้วย: dgx_switch $want"
      return 1
    fi
  fi

  unset ANTHROPIC_API_KEY
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
  export ANTHROPIC_AUTH_TOKEN="dgx"
  export ANTHROPIC_BASE_URL="$DGX_SPARK_BASE_URL"
  export API_TIMEOUT_MS="3000000"
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW="$(dgx_compact_window "$served")"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="$served"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="$served"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="$served"
  echo "✅ Switched to DGX Spark ($served)"
}

# โมเดลที่ติดตั้งไว้ กับตัวที่กำลังเสิร์ฟอยู่ตอนนี้
dgx_models() {
  local served
  served="$(dgx_served_model)"
  echo "🖥  DGX Spark models:"
  echo "----------------------------"
  for target in qwen glm deepseek; do
    local id
    id="$(dgx_model_id "$target")"
    if [ "$id" = "$served" ]; then
      echo "* $target -> $id"
    else
      echo "  $target -> $id"
    fi
  done
  echo "----------------------------"
  if [ -z "$served" ]; then
    echo "❌ API ไม่ตอบที่ $DGX_SPARK_BASE_URL"
  else
    echo "* = เสิร์ฟอยู่ตอนนี้"
  fi
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

# ccq = สลับเป็น SGLang (Local / Qwen3.8) แล้วเปิด
# ต้องใช้ --effort medium: ถ้า effort เป็น high เซิร์ฟเวอร์ SGLang จะตอบ 500
alias ccq='sglang_on && claude --effort medium --dangerously-skip-permissions'

# ccd  = DGX Spark โมเดลที่กำลังเสิร์ฟอยู่
# ccdq / ccdg / ccdd = เจาะจง Qwen3.8 / GLM-5.3 / DeepSeek v4.1
alias ccd='dgx_on && claude --dangerously-skip-permissions'
alias ccdq='dgx_on qwen && claude --dangerously-skip-permissions'
alias ccdg='dgx_on glm && claude --dangerously-skip-permissions'
alias ccdd='dgx_on deepseek && claude --dangerously-skip-permissions'

# ========================================
# คำสั่งเช็คสถานะ
# ========================================

claude_status() {
  echo "🔍 Current Claude Config:"
  echo "----------------------------"
  if [ "$ANTHROPIC_AUTH_TOKEN" = "dgx" ]; then
    echo "Mode: DGX Spark (vLLM)"
    echo "Base URL: $ANTHROPIC_BASE_URL"
    echo "Configured model: $ANTHROPIC_DEFAULT_SONNET_MODEL"
    local serving
    serving="$(dgx_served_model)"
    if [ -z "$serving" ]; then
      echo "Serving now: ❌ API ไม่ตอบ"
    else
      echo "Serving now: $serving"
      [ "$serving" != "$ANTHROPIC_DEFAULT_SONNET_MODEL" ] && echo "⚠️  โมเดลบนเครื่องเปลี่ยนแล้ว รัน ccd อีกครั้ง"
    fi
  elif [ "$ANTHROPIC_AUTH_TOKEN" = "ollama" ]; then
    echo "Mode: Ollama (Local)"
    echo "Base URL: $ANTHROPIC_BASE_URL"
    echo "Sonnet Model: $ANTHROPIC_DEFAULT_SONNET_MODEL"
  elif [ "$ANTHROPIC_AUTH_TOKEN" = "sglang" ]; then
    echo "Mode: SGLang (Local)"
    echo "Base URL: $ANTHROPIC_BASE_URL"
    echo "Sonnet Model: $ANTHROPIC_DEFAULT_SONNET_MODEL"
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
alias ccm='dgx_models'

# ========================================
# 🚀 Powered by AI UNLOCKED
# 🌐 https://aiunlock.co/
# 📺 https://www.youtube.com/@AIUnlocked168
# 📘 https://www.facebook.com/aiunlockedvip
# ========================================
