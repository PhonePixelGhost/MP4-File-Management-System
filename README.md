# MP4 File Management System

## คำอธิบาย

สคริปต์นี้ใช้สำหรับจัดการไฟล์ .mp4 ระหว่างโฟลเดอร์ Server, User (Production) และ Backup โดยจะสำรองไฟล์, คัดลอกไฟล์ใหม่ และลบไฟล์จาก Server อัตโนมัติ พร้อมบันทึก Log การทำงาน

---

## โฟลเดอร์ที่เกี่ยวข้อง

- **SERVER_PATH**: โฟลเดอร์ต้นทาง (Server)  
  `\\ServerName\SharedFolder\NewFiles`
- **USER_PATH**: โฟลเดอร์ปลายทาง (Production/User)  
  `\\ServerName\SharedFolder\Production`
- **BACKUP_PATH**: โฟลเดอร์สำรองไฟล์ (Backup)  
  `\\ServerName\SharedFolder\Backup`

---

## ขั้นตอนการทำงานของสคริปต์

1. **ตรวจสอบโฟลเดอร์**  
   ตรวจสอบว่าโฟลเดอร์ SERVER_PATH, USER_PATH, BACKUP_PATH มีอยู่หรือไม่  
   - ถ้าไม่มี BACKUP_PATH จะสร้างใหม่

2. **ตรวจสอบไฟล์ MP4 ใน Production**  
   - ถ้าไม่มีไฟล์ .mp4 ใน USER_PATH จะข้ามไปขั้นตอนคัดลอกไฟล์จาก Server

3. **สำรองไฟล์ MP4 เดิม**  
   - ลบไฟล์สำรองเก่าใน BACKUP_PATH
   - คัดลอกไฟล์ .mp4 จาก USER_PATH ไป BACKUP_PATH

4. **ตรวจสอบไฟล์ MP4 ใน Server**  
   - ถ้าไม่มีไฟล์ .mp4 ใน SERVER_PATH จะจบการทำงาน

5. **คัดลอกไฟล์ MP4 จาก Server ไป Production**  
   - คัดลอกไฟล์ .mp4 จาก SERVER_PATH ไป USER_PATH (แทนที่ไฟล์เดิม)

6. **ลบไฟล์ MP4 ใน Server**  
   - ลบไฟล์ .mp4 ทั้งหมดใน SERVER_PATH หลังคัดลอกเสร็จ

7. **สรุปผลและแสดง Log**  
   - แสดง Log ล่าสุดของการทำงาน

---

## วิธีใช้งาน

1. **เตรียมโฟลเดอร์**  
   ตรวจสอบให้แน่ใจว่าโฟลเดอร์ SERVER_PATH, USER_PATH, BACKUP_PATH มีอยู่จริง  
   (สคริปต์จะสร้าง BACKUP_PATH ให้อัตโนมัติถ้ายังไม่มี)

2. **วางไฟล์ .bat**  
   วางไฟล์ `MP4 File Management System.bat` ไว้ที่ใดก็ได้

3. **ดับเบิลคลิกเพื่อรัน**  
   ดับเบิลคลิกไฟล์ `MP4 File Management System.bat`  
   หรือคลิกขวาเลือก "Run as administrator" (ถ้าต้องการสิทธิ์สูงสุด)

4. **ตรวจสอบผลลัพธ์**  
   - ดูข้อความสรุปบนหน้าจอ
   - ดูไฟล์ Log ที่สร้างขึ้นในโฟลเดอร์เดียวกับ .bat

---

## หมายเหตุ

- สคริปต์นี้ใช้คำสั่ง `robocopy` สำหรับคัดลอกและลบไฟล์
- Log จะถูกสร้างใหม่ทุกครั้งที่รัน โดยมีชื่อไฟล์ตามวันที่และเวลา
- หากเกิดข้อผิดพลาด ให้ตรวจสอบ Log เพื่อดูรายละเอียด

---

## ตัวอย่าง Log

```
[2024-06-01 10:30:00.00] MP4 Backup Process Started
[2024-06-01 10:30:01.00] Created backup directory
[2024-06-01 10:30:02.00] Backup process completed successfully
[2024-06-01 10:30:03.00] File copy completed successfully
[2024-06-01 10:30:04.00] Server cleanup completed successfully
[2024-06-01 10:30:05.00] MP4 Backup Process Completed
```

---

## คำถามที่พบบ่อย

- **Q:** ถ้าไม่มีไฟล์ .mp4 ใน Server จะเกิดอะไรขึ้น?  
  **A:** สคริปต์จะแจ้งว่าไม่มีไฟล์ใหม่ และจบการทำงาน

- **Q:** ถ้าไม่มีไฟล์ .mp4 ใน Production จะเกิดอะไรขึ้น?  
  **A:** สคริปต์จะข้ามขั้นตอนสำรองไฟล์ และไปคัดลอกไฟล์จาก Server ทันที

---

หากต้องการปรับเปลี่ยน Path หรือพฤติกรรมอื่น ๆ สามารถแก้ไขค่าตัวแปรในไฟล์ .bat ได้โดยตรง

