# BGF Daily Brief — Scheduled Automation & 60-Day Executive Dashboard

ระบบสร้าง **Executive HTML5 Dashboard** สำหรับผู้บริหาร (CEO, COO, CFO) วิเคราะห์ข้อมูลตลาดจริงสำหรับ **KBI** (Float Glass) และ **BGA** (Aluminium) พร้อมระบบเก็บประวัติรายวันย้อนหลัง **60 วัน**, **ตัวกรองเดือน (Month Filter)**, และปุ่มสลับ **Desktop / Mobile** ในไฟล์เดียวจบสำหรับเปิดบน **SharePoint / OneDrive (Microsoft Edge Mobile)**

---

## 1. สถาปัตยกรรมลด Usage (>98% Token Savings)
แทนที่จะให้ AI อ่านไฟล์ HTML ย้อนหลัง 60 วันทั้งหมดทุกเช้า (ซึ่งกินข้อมูลหลายแสนถึงล้าน Token ต่อรอบ) ระบบนี้แยกขั้นตอนเป็น:

1. **Zero-Token Fetcher (`scripts/fetch_market_data.py`)**:
   - ดึงราคา KPI จริง (Yahoo Finance / Westmetall / RSS) ด้วย Python stdlib โดย **ไม่ใช้ LLM Token เลย**
   - ใช้กติกา **08:00 UTC+7 (Open vs Prior Close)**: ถ้าตลาดเปิดและมีราคาเปิดวันนี้ ใช้ `Today Open`; ถ้าตลาดปิดหรือยังไม่เปิด (เช่น LME หรือวันเสาร์-อาทิตย์) ใช้ `Prior Close`
   - ใช้ `data/soda_ash_cache.json` เก็บสถานะรายเดือน ไม่ต้องดึงซ้ำทุกวัน
   - เขียนผลลัพธ์ขนาดเล็ก (~4–12 KB) ลง `data/today_raw.json`
2. **Incremental History (`data/history/YYYY-MM-DD.json`)**:
   - เก็บข้อมูลแต่ละวันเป็น JSON ขนาดเล็ก (~6–8 KB/วัน) และใช้ `data/history_manifest.json` เป็นดัชนี
   - หากใช้ AI เขียนบทวิเคราะห์เพิ่ม AI จะอ่าน **เฉพาะ `today_raw.json` + ไฟล์เมื่อวาน 1 ไฟล์** เท่านั้น
3. **Single-File Dashboard Compiler (`scripts/build_dashboard.py`)**:
   - รวมข้อมูลล่าสุด **60 วัน** จาก `data/history/` (ตัดไฟล์เก่ากว่า 60 วันออกเมื่อส่ง `--prune`) ลงใน `dist/BGF_DAILY_BRIEF.html` ไฟล์เดียวจบ
   - ไม่มี external CDN / CSS / JS ทำให้เปิดผ่าน SharePoint / OneDrive บน Edge Mobile ได้ทันทีโดยไม่ติดปัญหา CORS

---

## 2. วิธีตั้ง Schedule Run อัพเดททุก 08:00 น. (UTC+7)

### วิธีที่ 1: GitHub Actions (แนะนำ — ฟรี & รันอัตโนมัติบนคลาวด์)
ไฟล์ `.github/workflows/daily_brief.yml` ถูกตั้งค่าไว้แล้วที่ `cron: "0 1 * * *"` (= **08:00 น. เวลาไทย UTC+7**):
1. Push โฟลเดอร์ `bgf-daily-brief` ขึ้น GitHub Repository
2. เปิด GitHub Actions (`Settings -> Actions -> Workflow permissions -> Read and write permissions`)
3. (ทางเลือกสำหรับ SharePoint/OneDrive) ใช้ Power Automate เชื่อมต่อเมื่อไฟล์ `dist/BGF_DAILY_BRIEF.html` ใน GitHub อัปเดต ให้ Copy ไปทับไฟล์ใน SharePoint / OneDrive อัตโนมัติ

### วิธีที่ 2: Linux / macOS Cron (รันบนเครื่องเซิร์ฟเวอร์)
```bash
crontab -e
```
เพิ่มบรรทัดนี้ (บังคับ Timezone `Asia/Bangkok`):
```cron
CRON_TZ=Asia/Bangkok
0 8 * * * cd /path/to/bgf-daily-brief && python3 scripts/fetch_market_data.py --create-snapshot && python3 scripts/build_dashboard.py --retention 60 --prune >> /tmp/bgf_brief.log 2>&1
```

### วิธีที่ 3: Windows Task Scheduler (Sync ตรงเข้าโฟลเดอร์ OneDrive/SharePoint)
ตั้ง Trigger เวลา **08:00 Daily** ให้รันคำสั่ง:
```bat
cmd /c "cd /d C:\path\to\bgf-daily-brief && python scripts\fetch_market_data.py --create-snapshot && python scripts\build_dashboard.py --retention 60 --prune && copy /Y dist\BGF_DAILY_BRIEF.html C:\Users\<User>\OneDrive\BGF_Brief\"
```

### วิธีที่ 4: รันผ่าน AI Platform Scheduled Prompt
คัดลอก Prompt จาก `prompts/BGF_MASTER_PROMPT_V5_TOKEN_SAVER.md` ไปตั้งเป็น Scheduled Prompt เวลา 08:00 UTC+7 ซึ่งระบุชัดเจนให้ AI อ่านเฉพาะข้อมูลล่าสุด 1 วัน + `today_raw.json` เท่านั้น

---

## 3. ทดสอบรันด้วยตนเอง (Manual Run)
```bash
python3 scripts/fetch_market_data.py --create-snapshot
python3 scripts/build_dashboard.py --retention 60 --prune
```
ไฟล์ผลลัพธ์พร้อมใช้งานอยู่ที่: `dist/BGF_DAILY_BRIEF.html`
