# 📘 Claude Code Switch GLM - AI Unlocked

## คู่มือติดตั้งสำหรับ Mac / Windows

---

## 🎬 แนะนำ GLM - ใช้ Claude Code ราคาประหยัด!

[![GLM แนะนำ](https://img.youtube.com/vi/5W9felMfuVw/maxresdefault.jpg)](https://youtu.be/5W9felMfuVw)

## 🚀 ลองใช้ GLM ด้วย Claude Code ทำเว็บ Frontend Simulator แบบโคตรง่าย

[![GLM แนะนำ](https://img.youtube.com/vi/N9mwJgN3yrw/maxresdefault.jpg)](https://youtu.be/N9mwJgN3yrw)

👆 **คลิกดูคลิปแนะนำ GLM**: https://youtu.be/5W9felMfuVw

### 💰 สมัคร GLM ลดเพิ่ม 10%! จากโปร 50% และ BFD

🔗 **ลิงก์สมัคร (รับส่วนลด 10%)**: https://z.ai/subscribe?ic=UE6DWDNJQY

---

ไฟล์ config นี้ช่วยให้คุณสลับใช้งาน Claude Code ได้ 5 โหมด:

| โหมด | คำอธิบาย |
|------|----------|
| 🟢 **GLM** | ใช้ GLM ผ่าน proxy API |
| 🔵 **Subscription** | ใช้ Claude แท้ผ่าน Max Plan |
| 🟣 **API** | ใช้ Claude แท้ผ่าน API Key |
| 🟠 **Ollama** | ใช้ model local ผ่าน Ollama |
| 🔴 **SGLang** | ใช้ model local ผ่าน SGLang (เช่น Qwen3.8) |

---

## 📦 ไฟล์ที่ได้รับ

```
claude-code-switch-glm-ai-unlocked/
├── README.md                              ← คู่มือนี้
├── claude-code-switch-glm-ai-unlocked.sh  ← ไฟล์ config (Mac/Linux)
└── claude-code-switch-glm-ai-unlocked.ps1 ← ไฟล์ config (Windows PowerShell)
```

---

## 🔑 ขั้นตอนที่ 1: ตั้งค่า API Keys

### ⚠️ สำคัญ: ต้องใส่ API Key ก่อนติดตั้ง

เปิดไฟล์ `claude-code-switch-glm-ai-unlocked.sh` ด้วย TextEdit หรือ VS Code แล้วแก้ไข:

---

### 🟢 สำหรับ GLM

หาบรรทัดนี้:
```bash
export ANTHROPIC_AUTH_TOKEN="ใส่-GLM-TOKEN-ของคุณ-ตรงนี้"
```

เปลี่ยนเป็น GLM Token ของคุณ:
```bash
export ANTHROPIC_AUTH_TOKEN="abc123xyz456..."
```

**วิธีหา GLM Token:**
1. สมัคร GLM ที่: https://z.ai/subscribe?ic=UE6DWDNJQY (ลดเพิ่ม 10%!)
2. เข้าไปที่เว็บ GLM หลังสมัครเสร็จ
3. ไปที่หน้า API Keys หรือ Settings
4. คัดลอก Token มาใส่

📺 **ดูวิธีสมัครแบบละเอียด**: https://youtu.be/5W9felMfuVw

> **🆕 Default model = `glm-5.3` (1M context, output สูงสุด 128K)**
> ไฟล์ config ตั้งค่า GLM ให้ใช้ `glm-5.3` พร้อม `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000` เพื่อเปิด context 1 ล้าน token โดยอัตโนมัติ
> - GLM-5.3 รองรับ context 1M ในตัวเอง **ไม่ต้องใส่ suffix `[1m]`** แบบ 5.2 แล้ว
> - GLM-5.3 เปิด deep thinking เป็นค่าเริ่มต้น (ปิดไม่ได้) ระดับการคิดคุมด้วย `reasoning_effort` (ค่าเริ่มต้น `max`)
> - GLM-5.3 เป็น premium model (เทียบเท่า Claude Opus) หักโควต้าแบบ 2–3 เท่า โปรดดูเงื่อนไขล่าสุดที่เอกสาร z.ai
> - **เคยติดตั้งเวอร์ชันเก่า (5.1 / 5.2) ไว้แล้ว?** ดูวิธีอัพเดตที่ [how-to-update-5-3.md](how-to-update-5-3.md)

---

### 🟣 สำหรับ Claude API

หาบรรทัดนี้:
```bash
export ANTHROPIC_API_KEY="ใส่-ANTHROPIC-API-KEY-ของคุณ-ตรงนี้"
```

เปลี่ยนเป็น API Key ของคุณ:
```bash
export ANTHROPIC_API_KEY="sk-ant-api03-xxxxx..."
```

**วิธีหา Anthropic API Key:**
1. ไปที่ https://console.anthropic.com
2. Login เข้าบัญชี
3. ไปที่ Settings → API Keys
4. กด "Create Key" แล้วคัดลอกมาใส่

---

### 🟠 สำหรับ Ollama (Local)

ไม่ต้องแก้ไข key ใดๆ! แค่ต้อง:
1. ติดตั้ง Ollama: https://ollama.com
2. Pull model ที่ต้องการ:
   ```bash
   ollama pull gemma4:e4b
   ```
3. ตรวจสอบว่า Ollama กำลังรันอยู่:
   ```bash
   ollama list
   ```

> **หมายเหตุ:** ค่า default model ในไฟล์ config คือ `gemma4:e4b` — ถ้าใช้ model อื่น ให้แก้ใน `ollama_on()` ฟังก์ชัน

---

### 🔴 สำหรับ SGLang (Local)

ไม่ต้องแก้ไข key ใดๆ! แค่ต้องรัน SGLang server ไว้ที่ port `30000` เช่น:
```bash
python -m sglang.launch_server --model-path <model> --port 30000
```

ตรวจสอบว่ารันอยู่:
```bash
curl http://localhost:30000/v1/models
```

SGLang เสิร์ฟ Anthropic Messages API (`/v1/messages`) ให้ในตัว จึงต่อ Claude Code ได้ตรงๆ ไม่ต้องมี proxy แปลง

> **หมายเหตุ:**
> - ค่า default model ในไฟล์ config คือ `qwen3.8-27b` — ถ้าใช้ model อื่น ให้แก้ใน `sglang_on()` ฟังก์ชัน (ชื่อต้องตรงกับที่ `/v1/models` แสดง)
> - `ccq` บังคับใช้ `--effort medium` เพราะถ้า effort เป็น `high` Claude Code จะส่ง `output_config.effort=high` แล้ว SGLang ตอบ `500 Internal server error`
> - `CLAUDE_CODE_AUTO_COMPACT_WINDOW` ตั้งไว้ `120000` ให้ต่ำกว่า KV cache ของ server (ดูค่า `max_total_num_tokens` จาก `curl http://localhost:30000/get_server_info`)

---

### 🔵 สำหรับ Claude Subscription

ไม่ต้องตั้งค่าอะไร! ใช้ account ที่ login ไว้กับ Claude Code ได้เลย

---

## 🚀 ขั้นตอนที่ 2: ติดตั้ง

### วิธีที่ 1: ใช้ Terminal (แนะนำ)

```bash
# 1. แตกไฟล์ zip (ถ้ายังไม่ได้แตก)
unzip ~/Downloads/claude-code-switch-glm-ai-unlocked.zip -d ~/Downloads/

# 2. เปิดไฟล์แก้ไข API Key (ทำตามขั้นตอนที่ 1 ก่อน)
nano ~/Downloads/claude-code-switch-glm-ai-unlocked/claude-code-switch-glm-ai-unlocked.sh

# 3. เพิ่ม config เข้า .zshrc
cat ~/Downloads/claude-code-switch-glm-ai-unlocked/claude-code-switch-glm-ai-unlocked.sh >> ~/.zshrc

# 4. โหลด config ใหม่
source ~/.zshrc

# 5. ทดสอบ
ccc
```

### วิธีที่ 2: แก้ไขด้วย TextEdit

1. แตกไฟล์ zip
2. คลิกขวาที่ไฟล์ `.sh` → Open With → TextEdit
3. แก้ไข API Keys ตามขั้นตอนที่ 1
4. บันทึกไฟล์
5. เปิด Terminal แล้วรัน:
```bash
cat ~/Downloads/claude-code-switch-glm-ai-unlocked/claude-code-switch-glm-ai-unlocked.sh >> ~/.zshrc
source ~/.zshrc
```

---

## 📝 ขั้นตอนที่ 3: วิธีใช้งาน

### คำสั่งลัด

| คำสั่ง | ความหมาย |
|--------|----------|
| `ccg` | 🟢 สลับเป็น GLM แล้วเปิด Claude |
| `ccs` | 🔵 สลับเป็น Claude Subscription แล้วเปิด |
| `cca` | 🟣 สลับเป็น Claude API แล้วเปิด |
| `cco` | 🟠 สลับเป็น Ollama (Local) แล้วเปิด Claude |
| `ccq` | 🔴 สลับเป็น SGLang (Local) แล้วเปิด Claude |
| `cc` | ⚪ เปิด Claude ด้วย config ปัจจุบัน |
| `ccc` | 🔍 เช็คว่าตอนนี้ใช้ config อะไร |

### ตัวอย่างการใช้งาน

```bash
# ใช้ GLM
ccg

# ใช้ Claude Subscription (Max Plan)
ccs

# ใช้ Claude API
cca

# ใช้ Ollama (Local)
cco

# ใช้ SGLang (Local / Qwen3.8)
ccq

# เช็คสถานะ
ccc
```

### สลับ config โดยไม่เปิด Claude

```bash
# สลับเป็น GLM
glm_on

# สลับเป็น Subscription
claude_sub

# สลับเป็น API
claude_api

# สลับเป็น Ollama
ollama_on

# สลับเป็น SGLang
sglang_on

# แล้วค่อยเปิด Claude เอง
cc
```

---

## ⚠️ หมายเหตุสำคัญ

1. **ทุกคำสั่งจะเปิด Claude พร้อม `--dangerously-skip-permissions`** 
   - หมายความว่า Claude จะไม่ถามยืนยันก่อนรันคำสั่ง
   - ใช้ด้วยความระมัดระวัง

2. **API Key เป็นความลับ**
   - อย่าแชร์ไฟล์ `.zshrc` ให้คนอื่น
   - อย่า commit ขึ้น GitHub

3. **ต้อง login Claude Code ก่อน** (สำหรับ Subscription)
   ```bash
   claude login
   ```

---

## 🔧 แก้ไขปัญหา

### ปัญหา: คำสั่ง ccg, ccs, cca ใช้ไม่ได้

```bash
source ~/.zshrc
```

### ปัญหา: GLM ใช้ไม่ได้

ตรวจสอบว่า:
1. ใส่ Token ถูกต้อง
2. Token ยังไม่หมดอายุ
3. Base URL ถูกต้อง

### ปัญหา: Claude API ใช้ไม่ได้

ตรวจสอบว่า:
1. API Key ขึ้นต้นด้วย `sk-ant-`
2. มี credit ใน account
3. API Key ยังไม่ถูก revoke

### ปัญหา: Ollama ใช้ไม่ได้

ตรวจสอบว่า:
1. Ollama กำลังรันอยู่ (`ollama list` ต้องแสดง model)
2. Port 11434 ไม่ถูกใช้โดยโปรแกรมอื่น
3. Model ที่ตั้งไว้ใน config ตรงกับที่ pull มา
4. ทดสอบ: `curl http://localhost:11434` ต้องได้ response

### ปัญหา: SGLang ใช้ไม่ได้

ตรวจสอบว่า:
1. SGLang server รันอยู่ (`curl http://localhost:30000/v1/models` ต้องได้ JSON)
2. Port 30000 ไม่ถูกใช้โดยโปรแกรมอื่น
3. ชื่อ model ใน `sglang_on()` ตรงกับที่ `/v1/models` แสดง
4. ถ้าเจอ `API Error: 500` ให้เช็คว่าใช้ `--effort medium` อยู่ (effort `high` ทำให้ SGLang พัง)

### ปัญหา: ต้องการแก้ไข API Key ภายหลัง

```bash
nano ~/.zshrc
# หา ANTHROPIC_AUTH_TOKEN หรือ ANTHROPIC_API_KEY แล้วแก้ไข
# บันทึกด้วย Ctrl+O, ออกด้วย Ctrl+X
source ~/.zshrc
```

### ปัญหา: ต้องการลบ config ออกทั้งหมด

```bash
nano ~/.zshrc
# ลบตั้งแต่ "# ========================================"
# ถึงท้ายไฟล์
source ~/.zshrc
```

---

## 📋 สรุป Config แต่ละโหมด

| โหมด | ต้องใช้ | วิธีได้มา |
|------|---------|-----------|
| GLM | `ANTHROPIC_AUTH_TOKEN` | จากเว็บ GLM provider |
| Subscription | Login account | `claude login` |
| API | `ANTHROPIC_API_KEY` | console.anthropic.com |
| Ollama | Ollama + model | `ollama pull <model>` |
| SGLang | SGLang server ที่ port 30000 | `sglang.launch_server --port 30000` |

---

## 🔗 ลิงก์ที่เป็นประโยชน์

- Anthropic Console: https://console.anthropic.com
- Claude Code Docs: https://docs.anthropic.com/claude-code
- Anthropic API Docs: https://docs.anthropic.com/api

---

## 🚀 AI UNLOCKED

ติดตามเนื้อหาดีๆ เกี่ยวกับ AI ได้ที่:

| แพลตฟอร์ม | ลิงก์ |
|-----------|-------|
| 🌐 Website | [aiunlock.co](https://aiunlock.co/) |
| 📺 YouTube | [@AIUnlocked168](https://www.youtube.com/@AIUnlocked168) |
| 📘 Facebook | [AI Unlocked VIP](https://www.facebook.com/aiunlockedvip) |

---

---

## 🪟 คู่มือติดตั้งสำหรับ Windows (PowerShell)

### ขั้นตอนที่ 1: ตั้งค่า API Keys

เปิดไฟล์ `claude-code-switch-glm-ai-unlocked.ps1` ด้วย Notepad หรือ VS Code แล้วแก้ไข API Keys เหมือนกับ Mac (ดูด้านบน)

### ขั้นตอนที่ 2: ติดตั้ง

```powershell
# 1. ตรวจสอบว่ามี PowerShell Profile หรือยัง
Test-Path $PROFILE

# 2. ถ้ายังไม่มี ให้สร้างก่อน
New-Item -Path $PROFILE -Type File -Force

# 3. เปิดไฟล์ .ps1 แก้ไข API Key ก่อน แล้ว append เข้า Profile
Get-Content .\claude-code-switch-glm-ai-unlocked.ps1 | Add-Content $PROFILE

# 4. โหลด config ใหม่
. $PROFILE

# 5. ทดสอบ
ccc
```

### ขั้นตอนที่ 3: วิธีใช้งาน

คำสั่งลัดเหมือนกับ Mac ทุกประการ:

| คำสั่ง | ความหมาย |
|--------|----------|
| `ccg` | 🟢 สลับเป็น GLM แล้วเปิด Claude |
| `ccs` | 🔵 สลับเป็น Claude Subscription แล้วเปิด |
| `cca` | 🟣 สลับเป็น Claude API แล้วเปิด |
| `cco` | 🟠 สลับเป็น Ollama (Local) แล้วเปิด Claude |
| `ccq` | 🔴 สลับเป็น SGLang (Local) แล้วเปิด Claude |
| `cc` | ⚪ เปิด Claude ด้วย config ปัจจุบัน |
| `ccc` | 🔍 เช็คว่าตอนนี้ใช้ config อะไร |

### ⚠️ หมายเหตุสำหรับ Windows

1. **ต้องอนุญาต Execution Policy** ถ้าเจอ error:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Profile อยู่ที่:**
   ```
   C:\Users\<ชื่อผู้ใช้>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
   ```

3. **แก้ไข API Key ภายหลัง:**
   ```powershell
   notepad $PROFILE
   ```

---

*Claude Code Switch GLM - AI Unlocked v2.2 (GLM 5.3 · 1M context)*

*Powered by AI UNLOCKED 🚀*
