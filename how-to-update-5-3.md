# วิธีอัพเดตเป็น GLM 5.3 (1M context)

## สำหรับคนที่ติดตั้งไปแล้ว

ถ้าเคยติดตั้ง script นี้ไปแล้ว (เป็น GLM 5.2, 5.1 หรือเก่ากว่า) และอยากอัพเดตเป็น GLM 5.3 ให้ทำตามนี้ค่ะ

> GLM 5.3 รองรับ context 1M ในตัวเอง **ไม่ต้องใส่ suffix `[1m]`** แบบ 5.2 แล้ว แต่ยังควรตั้ง `CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"` ไว้เพื่อให้ Claude Code ใช้ context เต็ม 1 ล้าน token

### วิธีที่ 1: รันคำสั่งนี้ใน Terminal (แนะนำ)

zsh (macOS ค่าเริ่มต้น):
```bash
sed -i '' -E 's/glm-5\.[0-9]+(\[1m\])?/glm-5.3/g' ~/.zshrc
grep -q CLAUDE_CODE_AUTO_COMPACT_WINDOW ~/.zshrc || sed -i '' '/export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"/i\
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
' ~/.zshrc
source ~/.zshrc
```

bash:
```bash
sed -i -E 's/glm-5\.[0-9]+(\[1m\])?/glm-5.3/g' ~/.bashrc
grep -q CLAUDE_CODE_AUTO_COMPACT_WINDOW ~/.bashrc || sed -i '/export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"/i\  export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"' ~/.bashrc
source ~/.bashrc
```

Windows PowerShell:
```powershell
(Get-Content $PROFILE) -replace 'glm-5\.\d+(\[1m\])?', 'glm-5.3' | Set-Content $PROFILE -Encoding utf8
. $PROFILE
```

### วิธีที่ 2: แก้ไขเอง

1. เปิดไฟล์ config:
   ```bash
   nano ~/.zshrc
   ```
   หรือ
   ```bash
   nano ~/.bashrc
   ```
   (Windows: `notepad $PROFILE`)

2. หาฟังก์ชัน `glm_on()` แล้วแก้ให้เป็นแบบนี้:
   ```bash
   # จาก (5.2)
   export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.2[1m]"
   export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2[1m]"

   # เป็น (5.3)
   export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
   export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.3"
   export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.3"
   ```

3. บันทึกไฟล์ แล้ว reload:
   ```bash
   source ~/.zshrc
   ```

### ตรวจสอบว่าอัพเดตสำเร็จ

```bash
ccc
```

ถ้าขึ้น `Sonnet Model: glm-5.3` แสดงว่าสำเร็จแล้วค่ะ

หรือเปิด Claude Code ด้วย `ccg` แล้วพิมพ์ `/status` เพื่อดูว่าใช้ GLM-5.3 จริง

### มีอะไรใหม่ใน GLM 5.3

- Context สูงสุด 1M, output สูงสุด 128K
- เปิด deep thinking เป็นค่าเริ่มต้น (ปิดไม่ได้ — ถ้าส่ง `thinking` แบบปิดจะ error) ระดับการคิดคุมด้วย `reasoning_effort` (`low` / `high` / `max`, ค่าเริ่มต้น `max`)
- รองรับ streaming ระหว่าง tool call (`tool_stream=true`)
- `temperature` ค่าเริ่มต้น `1.0`, `top_p` ค่าเริ่มต้น `0.95` — แนะนำปรับอย่างใดอย่างหนึ่ง

> หมายเหตุ: GLM-5.3 เป็น premium model (ระดับเทียบเท่า Claude Opus) จะหักโควต้าแบบ 2–3 เท่า โปรดดูเงื่อนไขล่าสุดที่เอกสาร z.ai

---

## สำหรับคนที่ติดตั้งใหม่

ถ้ายังไม่เคยติดตั้ง ให้ดูวิธีที่ README.md ได้เลยค่ะ (เป็น 5.3 อยู่แล้ว)

---

Powered by AI UNLOCKED
- https://aiunlock.co/
- https://www.youtube.com/@AIUnlocked168
- https://www.facebook.com/aiunlockedvip
