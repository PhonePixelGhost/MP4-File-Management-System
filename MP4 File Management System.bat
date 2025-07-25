@echo off
setlocal enabledelayedexpansion

:: ===================================================================
:: MP4 Backup and Copy Script - Production Version with Robocopy
:: ===================================================================
:: กำหนด Path ตัวแปร (แก้ไข Path จริงตามสภาพแวดล้อม Server)
set "\\ServerName\SharedFolder\NewFiles"
set "USER_PATH=\\ServerName\SharedFolder\Production"
set "BACKUP_PATH=\\ServerName\SharedFolder\Backup"

:: Log file สำหรับ Monitoring
set "LOG_FILE=%~dp0mp4_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.log"
set "LOG_FILE=!LOG_FILE: =0!"

:: แสดงข้อมูล Script
echo ===================================================================
echo MP4 File Backup and Copy Management System - Production Version
echo ===================================================================
echo Server Path  : %SERVER_PATH%
echo User Path    : %USER_PATH%
echo Backup Path  : %BACKUP_PATH%
echo Log File     : %LOG_FILE%
echo ===================================================================
echo.

:: เริ่มการ Log
echo [%date% %time%] MP4 Backup Process Started >> "%LOG_FILE%"

:: ตรวจสอบว่า Directory ทั้งหมดมีอยู่หรือไม่
echo Step 1: Verifying directory access...
if not exist "%SERVER_PATH%" (
    echo ERROR: Server path not accessible: %SERVER_PATH%
    echo [%date% %time%] ERROR: Server path not accessible >> "%LOG_FILE%"
    :: สำหรับ Task Scheduler - ไม่ต้อง pause
if "%1"=="scheduled" (
    exit /b 0
) else (
    pause
)
    exit /b 1
)

if not exist "%USER_PATH%" (
    echo ERROR: User path not accessible: %USER_PATH%
    echo [%date% %time%] ERROR: User path not accessible >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: สร้าง Backup Directory หากยังไม่มี
if not exist "%BACKUP_PATH%" (
    echo Creating backup directory: %BACKUP_PATH%
    mkdir "%BACKUP_PATH%"
    echo [%date% %time%] Created backup directory >> "%LOG_FILE%"
)

echo Step 2: Checking for existing MP4 files in Production directory...
:: ตรวจสอบว่ามีไฟล์ .mp4 ใน User directory หรือไม่
set "mp4_found=0"
for %%f in ("%USER_PATH%\VDO-L.mp4" "%USER_PATH%\VDO-M.mp4" "%USER_PATH%\VDO-S.mp4") do (
    if exist "%%f" (
        set "mp4_found=1"
        echo Found MP4 file: %%~nxf
    )
)

if !mp4_found!==0 (
    echo No MP4 files found in Production directory.
    echo [%date% %time%] No existing MP4 files found >> "%LOG_FILE%"
    echo Proceeding to copy new files from Server...
    goto :copy_from_server
)

echo.
echo Step 3: Backing up existing MP4 files...
echo [%date% %time%] Starting backup process >> "%LOG_FILE%"

:: ล้าง Backup เก่าก่อน (ตามที่ระบุในขั้นตอน)
echo Clearing old backup files...
robocopy "%BACKUP_PATH%" "%BACKUP_PATH%_temp" *.mp4 /MOV /NFL /NDL /NJH /NJS >nul 2>&1
rmdir /s /q "%BACKUP_PATH%_temp" >nul 2>&1
echo [%date% %time%] Old backup files cleared >> "%LOG_FILE%"

:: Backup ไฟล์ MP4 ที่มีอยู่ใน User directory ด้วย robocopy
echo Backing up current MP4 files...
robocopy "%USER_PATH%" "%BACKUP_PATH%" VDO-L.mp4 VDO-M.mp4 VDO-S.mp4 /COPY:DAT /R:3 /W:5 /LOG+:"%LOG_FILE%" /TEE

if !errorlevel! leq 1 (
    echo Backup completed successfully.
    echo [%date% %time%] Backup process completed successfully >> "%LOG_FILE%"
) else (
    echo WARNING: Backup process encountered issues. Check log file.
    echo [%date% %time%] Backup process had issues - Exit Code: !errorlevel! >> "%LOG_FILE%"
)

:copy_from_server
echo.
echo Step 4: Checking for MP4 files in Server directory...
:: ตรวจสอบว่ามีไฟล์ .mp4 ใน Server directory หรือไม่
set "server_mp4_found=0"
for %%f in ("%SERVER_PATH%\VDO-L.mp4" "%SERVER_PATH%\VDO-M.mp4" "%SERVER_PATH%\VDO-S.mp4") do (
    if exist "%%f" (
        set "server_mp4_found=1"
        echo Found MP4 file in Server: %%~nxf
    )
)

if !server_mp4_found!==0 (
    echo No MP4 files found in Server directory.
    echo [%date% %time%] No new MP4 files found in server >> "%LOG_FILE%"
    echo Process completed - No new files to copy.
    goto :end
)

echo.
echo Step 5: Copying MP4 files from Server to Production directory...
echo [%date% %time%] Starting file copy from server >> "%LOG_FILE%"

:: Copy ไฟล์ MP4 จาก Server ไป User ด้วย robocopy (แทนที่ไฟล์เก่า)
robocopy "%SERVER_PATH%" "%USER_PATH%" VDO-L.mp4 VDO-M.mp4 VDO-S.mp4 /COPY:DAT /R:5 /W:10 /LOG+:"%LOG_FILE%" /TEE

set "copy_result=!errorlevel!"
if !copy_result! leq 1 (
    echo File copy completed successfully.
    echo [%date% %time%] File copy completed successfully >> "%LOG_FILE%"
) else (
    echo ERROR: File copy encountered issues - Exit Code: !copy_result!
    echo [%date% %time%] File copy failed - Exit Code: !copy_result! >> "%LOG_FILE%"
    echo Check the log file for details.
    goto :end
)

echo.
echo Step 6: Cleaning up Server directory...
echo [%date% %time%] Starting server cleanup >> "%LOG_FILE%"

:: ลบไฟล์ MP4 จาก Server หลังจาก Copy เสร็จ ด้วย robocopy
:: สร้าง temp directory เปล่าเพื่อใช้ในการ "mirror" (ลบไฟล์)
mkdir "%TEMP%\empty_temp_dir" >nul 2>&1

:: ใช้ robocopy mirror เพื่อลบไฟล์ MP4 (ปลอดภัยกว่า del)
robocopy "%TEMP%\empty_temp_dir" "%SERVER_PATH%" VDO-L.mp4 VDO-M.mp4 VDO-S.mp4 /PURGE /NFL /NDL /NJH /NJS

:: ลบ temp directory
rmdir "%TEMP%\empty_temp_dir" >nul 2>&1

:: ตรวจสอบว่าลบสำเร็จ
set "remaining_files=0"
for %%f in ("%SERVER_PATH%\VDO-L.mp4" "%SERVER_PATH%\VDO-M.mp4" "%SERVER_PATH%\VDO-S.mp4") do (
    if exist "%%f" set "remaining_files=1"
)

if !remaining_files!==0 (
    echo Server cleanup completed successfully.
    echo [%date% %time%] Server cleanup completed successfully >> "%LOG_FILE%"
) else (
    echo WARNING: Some files may still remain in server directory.
    echo [%date% %time%] Server cleanup incomplete - some files remain >> "%LOG_FILE%"
)

:end
echo.
echo ===================================================================
echo Process completed!
echo ===================================================================
echo Check log file for detailed information: %LOG_FILE%
echo ===================================================================

echo [%date% %time%] MP4 Backup Process Completed >> "%LOG_FILE%"

:: แสดง Summary จาก Log
echo.
echo Recent Log Entries:
echo -------------------
type "%LOG_FILE%" | findstr /C:"[%date:~-4,4%-%date:~-10,2%-%date:~-7,2%"
