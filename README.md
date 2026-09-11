# Claude Code Switch - AI Unlocked

สลับใช้งาน Claude Code บน Windows ได้ 3 โหมด:

| โหมด | คำสั่ง | รายละเอียด |
|---|---|---|
| GLM | `ccg` | GLM ผ่าน z.ai |
| Subscription | `ccs` | Claude Subscription / Max Plan |
| DGX | `ccd` | LM Studio ที่ `192.168.1.150:8080` ผ่าน compatibility proxy |

## DGX models

| Claude tier | LM Studio model |
|---|---|
| Haiku | `qwen3.8-27b-uncensored` |
| Sonnet | `openthai2.0-qwen3.8-27b` |
| Opus | `qwen3.8-flash-next@iq4_xs` |

LM Studio ต้องเปิด API ที่ `http://192.168.1.150:8080` สคริปต์จะเปิด
compatibility proxy ที่ `127.0.0.1:18150` อัตโนมัติ เพื่อจัดตำแหน่ง system
messages จาก Claude Code ให้ chat template ของ Qwen รองรับได้

## คำสั่ง

```powershell
ccg                 # สลับเป็น GLM แล้วเปิด Claude
ccs                 # สลับเป็น Subscription แล้วเปิด Claude
ccd                 # สลับเป็น DGX แล้วเปิด Claude
ccc                 # แสดงโหมดปัจจุบัน
cc                  # เปิด Claude ด้วยโหมดปัจจุบัน
dgx_on              # สลับเป็น DGX โดยยังไม่เปิด Claude
claude_sub          # สลับเป็น Subscription โดยยังไม่เปิด Claude
glm_on              # สลับเป็น GLM โดยยังไม่เปิด Claude
```

เลือกโมเดล DGX โดยตรงได้ เช่น:

```powershell
ccd --model "qwen3.8-flash-next@iq4_xs"
ccd --model "openthai2.0-qwen3.8-27b"
ccd --model "qwen3.8-27b-uncensored"
```

PowerShell Profile โหลดไฟล์นี้โดยตรง:

```powershell
. "C:\aiunlock-dev\claude-code-switch-glm-ai-unlocked\claude-code-switch-glm-ai-unlocked.ps1"
```

GLM token ถูกอ่านจาก User environment variable ชื่อ
`AIUNLOCKED_GLM_TOKEN` และจะไม่ถูกเก็บใน repository

> คำสั่งเปิด Claude ใช้ `--dangerously-skip-permissions` ตามพฤติกรรมเดิม
> ของโปรเจกต์ โปรดใช้งานด้วยความระมัดระวัง
