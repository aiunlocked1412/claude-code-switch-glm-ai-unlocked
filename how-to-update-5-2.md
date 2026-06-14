# วิธีอัพเดตเป็น GLM 5.2 (1M context)

## สำหรับคนที่ติดตั้งไปแล้ว

ถ้าเคยติดตั้ง script นี้ไปแล้ว (เป็น GLM 5.1 หรือเก่ากว่า) และอยากอัพเดตเป็น GLM 5.2 แบบ 1M context ให้ทำตามนี้ค่ะ

> GLM 5.2 ต้องใส่ suffix `[1m]` เพื่อเปิด context 1 ล้าน token และต้องตั้งค่า `CLAUDE_CODE_AUTO_COMPACT_WINDOW` ควบคู่กันด้วย

### วิธีที่ 1: รันคำสั่งนี้ใน Terminal (แนะนำ)

zsh (macOS ค่าเริ่มต้น):
```bash
sed -i '' 's/glm-5\.1/glm-5.2[1m]/g' ~/.zshrc
grep -q CLAUDE_CODE_AUTO_COMPACT_WINDOW ~/.zshrc || sed -i '' '/export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"/i\
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
' ~/.zshrc
source ~/.zshrc
```

bash:
```bash
sed -i 's/glm-5\.1/glm-5.2[1m]/g' ~/.bashrc
grep -q CLAUDE_CODE_AUTO_COMPACT_WINDOW ~/.bashrc || sed -i '/export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"/i\  export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"' ~/.bashrc
source ~/.bashrc
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

2. หาฟังก์ชัน `glm_on()` แล้วแก้ให้เป็นแบบนี้ (เพิ่มบรรทัด `CLAUDE_CODE_AUTO_COMPACT_WINDOW` และเปลี่ยน model เป็น `glm-5.2[1m]`):
   ```bash
   # จาก
   export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1"
   export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1"

   # เป็น
   export CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
   export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.2[1m]"
   export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2[1m]"
   ```

3. บันทึกไฟล์ แล้ว reload:
   ```bash
   source ~/.zshrc
   ```

### ตรวจสอบว่าอัพเดตสำเร็จ

```bash
ccc
```

ถ้าขึ้น `Sonnet Model: glm-5.2[1m]` แสดงว่าสำเร็จแล้วค่ะ

หรือเปิด Claude Code ด้วย `ccg` แล้วพิมพ์ `/status` เพื่อดูว่าใช้ GLM-5.2 จริง

> หมายเหตุ: GLM-5.2 เป็น premium model (ระดับเทียบเท่า Claude Opus) จะหักโควต้าแบบ 2–3 เท่า โปรดดูเงื่อนไขล่าสุดที่เอกสาร z.ai
> ถ้า Claude Code แจ้งว่าไม่มี model ที่มี suffix `[1m]` ให้อัปเดต Claude Code เป็นเวอร์ชันล่าสุดก่อน (`claude update`)

---

## สำหรับคนที่ติดตั้งใหม่

ถ้ายังไม่เคยติดตั้ง ให้ดูวิธีที่ README.md ได้เลยค่ะ (เป็น 5.2 อยู่แล้ว)

---

Powered by AI UNLOCKED
- https://aiunlock.co/
- https://www.youtube.com/@AIUnlocked168
- https://www.facebook.com/aiunlockedvip
