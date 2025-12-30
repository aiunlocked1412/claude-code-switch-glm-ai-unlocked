# วิธีอัพเดตเป็น GLM 4.7

## สำหรับคนที่ติดตั้งไปแล้ว

ถ้าเคยติดตั้ง script นี้ไปแล้ว และอยากอัพเดตเป็น GLM 4.7 ให้ทำตามนี้ค่ะ:

### วิธีที่ 1: รันคำสั่งนี้ใน Terminal (แนะนำ)

```bash
sed -i '' 's/glm-4\.6/glm-4.7/g' ~/.zshrc && source ~/.zshrc
```

หรือถ้าใช้ bash:
```bash
sed -i 's/glm-4\.6/glm-4.7/g' ~/.bashrc && source ~/.bashrc
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

2. หาบรรทัดที่มี `glm-4.6` แล้วเปลี่ยนเป็น `glm-4.7`:
   ```bash
   # จาก
   export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.6"
   export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.6"

   # เป็น
   export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
   export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7"
   ```

3. บันทึกไฟล์ แล้ว reload:
   ```bash
   source ~/.zshrc
   ```

### ตรวจสอบว่าอัพเดตสำเร็จ

```bash
ccc
```

ถ้าขึ้น `Sonnet Model: glm-4.7` แสดงว่าสำเร็จแล้วค่ะ

---

## สำหรับคนที่ติดตั้งใหม่

ถ้ายังไม่เคยติดตั้ง ให้ดูวิธีที่ README.md ได้เลยค่ะ (เป็น 4.7 อยู่แล้ว)

---

Powered by AI UNLOCKED
- https://aiunlock.co/
- https://www.youtube.com/@AIUnlocked168
- https://www.facebook.com/aiunlockedvip
