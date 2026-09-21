# Claude Code Switch - AI Unlocked

สลับใช้งาน Claude Code บน Windows ได้ 4 โหมด:

| โหมด | คำสั่ง | รายละเอียด |
|---|---|---|
| GLM | `ccg` | GLM ผ่าน z.ai |
| Subscription | `ccs` | Claude Subscription / Max Plan |
| DGX Spark | `ccd` | vLLM ที่ `192.168.1.150:8888` ต่อตรง ไม่ผ่าน proxy |
| LM Studio | `ccl` | LM Studio ที่ `192.168.1.150:8080` ผ่าน compatibility proxy |

## DGX Spark (3 โมเดล)

DGX Spark สองเครื่องเสิร์ฟผ่าน vLLM แบบ tensor parallel ขนาด 2 ทั้งสามโมเดล
ใช้ GPU ชุดเดียวกันและ port เดียวกัน จึง **เสิร์ฟได้ทีละตัว**

| คำสั่ง | Target | Model ID | Context |
|---|---|---|---|
| `ccdq` | `qwen` | `qwen3.8-flash-next` | 262,144 |
| `ccdg` | `glm` | `GLM-5.3-Flash-EXL3` | 850,000 |
| `ccdd` | `deepseek` | `DeepSeek-v4.1-Flash-EXL3` | 600,000 |

`ccd` ใช้โมเดลที่กำลังเสิร์ฟอยู่โดยไม่สนว่าเป็นตัวไหน ส่วน `ccdq` / `ccdg` / `ccdd`
เจาะจงโมเดล ถ้าเครื่องเสิร์ฟคนละตัวจะเตือนและไม่เปิด Claude ให้ — ไม่สลับให้เอง
เพราะการสลับคือการดับโมเดลที่คนอื่นอาจกำลังใช้อยู่ และใช้เวลา 12–40 นาที

vLLM มี endpoint `/v1/messages` แบบ Anthropic อยู่แล้ว (รองรับ streaming,
tool use และ thinking blocks) Claude Code จึงต่อตรงได้ ไม่ต้องใช้ proxy
เหมือนโหมด LM Studio

```powershell
dgx_models           # ดูว่ามีโมเดลอะไรบ้าง และตัวไหนกำลังเสิร์ฟอยู่
dgx_switch qwen      # สั่งสลับโมเดลบนเครื่อง แล้วรอจน /health ตอบ 200
dgx_switch status    # ถามสถานะเฉย ๆ ไม่แตะอะไร
dgx_on -Target glm -Switch   # สลับให้ด้วยถ้าไม่ตรง แล้วตั้ง env ให้เลย
```

## LM Studio

| Claude tier | LM Studio model |
|---|---|
| Haiku | `qwen3.8-27b-uncensored` |
| Sonnet | `openthai2.0-qwen3.8-27b` |
| Opus | `qwen3.8-flash-next@iq4_xs` |

LM Studio ต้องเปิด API ที่ `http://192.168.1.150:8080` สคริปต์จะเปิด
compatibility proxy ที่ `127.0.0.1:18150` อัตโนมัติ เพื่อจัดตำแหน่ง system
messages จาก Claude Code ให้ chat template ของ Qwen รองรับได้

เลือกโมเดล LM Studio โดยตรงได้:

```powershell
lmstudio_on "qwen3.8-flash-next@iq4_xs"
```

## คำสั่ง

```powershell
ccg                 # สลับเป็น GLM (z.ai) แล้วเปิด Claude
ccs                 # สลับเป็น Subscription แล้วเปิด Claude
ccd                 # DGX Spark โมเดลที่กำลังเสิร์ฟอยู่ แล้วเปิด Claude
ccdq                # DGX Spark - Qwen3.8 Flash Next
ccdg                # DGX Spark - GLM-5.3 Flash EXL3
ccdd                # DGX Spark - DeepSeek v4.1 Flash EXL3
ccl                 # สลับเป็น LM Studio แล้วเปิด Claude
ccc                 # แสดงโหมดปัจจุบัน + โมเดลที่เครื่องเสิร์ฟอยู่จริง
cc                  # เปิด Claude ด้วยโหมดปัจจุบัน
dgx_on              # ตั้ง env เป็น DGX Spark โดยยังไม่เปิด Claude
dgx_models          # รายการโมเดลบน DGX Spark
dgx_switch <target> # สลับโมเดลบนเครื่อง (qwen | glm | deepseek | status | stop)
claude_sub          # สลับเป็น Subscription โดยยังไม่เปิด Claude
glm_on              # สลับเป็น GLM โดยยังไม่เปิด Claude
lmstudio_on         # สลับเป็น LM Studio โดยยังไม่เปิด Claude
```

`ccc` จะบอกทั้งโมเดลที่ตั้งไว้ใน env และโมเดลที่เครื่องเสิร์ฟอยู่จริง ถ้าไม่ตรงกัน
(มีคนสลับโมเดลระหว่างทาง) จะเตือนให้รัน `ccd` ใหม่

PowerShell Profile โหลดไฟล์นี้โดยตรง:

```powershell
. "C:\aiunlock-dev\claude-code-switch-glm-ai-unlocked\claude-code-switch-glm-ai-unlocked.ps1"
```

บน bash/zsh ใช้ `claude-code-switch-glm-ai-unlocked.sh` ซึ่งมีโหมดเดียวกัน
บวก Claude API, Ollama และ SGLang

GLM token ถูกอ่านจาก User environment variable ชื่อ
`AIUNLOCKED_GLM_TOKEN` และจะไม่ถูกเก็บใน repository

`dgx_switch` เรียกผ่าน ssh host ชื่อ `dgx` ไปรัน
`/home/aiunlock/switch-model.sh` บน DGX1

> คำสั่งเปิด Claude ใช้ `--dangerously-skip-permissions` ตามพฤติกรรมเดิม
> ของโปรเจกต์ โปรดใช้งานด้วยความระมัดระวัง
