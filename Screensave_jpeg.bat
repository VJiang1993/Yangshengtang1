@echo off
:: 强制UTF-8编码+延迟扩展
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: 基础配置（保留你的路径，完全复用最初变量名）
set "output_folder=D:\screenshots"
set "log_file=%output_folder%\screenshot_log.txt"
set "temp_list=%output_folder%\file_list.tmp"

:: 第一步：清空旧文件，初始化日志（确保从头开始记录）
if exist "%log_file%" del /f /q "%log_file%"
if exist "%temp_list%" del /f /q "%temp_list%"
echo 【%date% %time:~0,-1%】截图任务开始 >> "%log_file%"
echo 截图保存路径：%output_folder% >> "%log_file%"
echo. >> "%log_file%"

:: 第二步：提示用户操作（极简，和最初完全一致）
echo 正在启动截图...
echo 保存路径：%output_folder%
echo 按【任意键】停止截图并生成完整日志！
echo.

:: 第三步：启动ffmpeg（核心调整：提升画质+适度缩放，清晰且体积可控）
:: -q:v 25（画质大幅提升），scale=iw*0.9:ih*0.9（仅缩小10%，保留大部分清晰度）
start /b "" ffmpeg -y -f gdigrab -framerate 2 -i desktop -vf "fps=2,scale=iw*0.9:ih*0.9" ^
-c:v mjpeg -q:v 25 -pix_fmt yuv420p ^
"%output_folder%\shot_%%05d.jpg"

:: 第四步：等待用户停止（脚本不退出）
pause >nul

:: 第五步：强制终止ffmpeg（确保截图停止）
taskkill /f /im ffmpeg.exe >nul 2>&1
echo 【%date% %time:~0,-1%】截图已停止，开始扫描所有文件... >> "%log_file%"
echo. >> "%log_file%"

:: 第六步：强制等待1秒（避免系统文件未刷新）
timeout /t 1 /nobreak >nul
echo 等待生成日志，等待时间可能较长...
echo.


:: 第七步：全量遍历（三重保障，仅将png改为jpg，其余完全一致）
echo ===== 所有截图文件列表（精确到0.1秒） ===== >> "%log_file%"
echo. >> "%log_file%"

:: 保障1：先导出所有jpg文件到临时列表
dir /b /a-d "%output_folder%\shot_*.jpg" > "%temp_list%" 2>&1

:: 保障2：遍历临时列表（确保无遗漏）
for /f "delims=" %%f in (%temp_list%) do (
    :: 保障3：用powershell强制提取创建时间（无视系统延迟）
    for /f "delims=" %%t in (
        'powershell -Command "(Get-Item '%output_folder%\%%f').CreationTime.ToString('yyyy/MM/dd HH:mm:ss.ff')"'
    ) do (
        set "ct=%%t"
        :: 写入日志（每条单独一行）
        echo 文件：%%f --- 创建时间：!ct:~0,-1! >> "%log_file%"
    )
)

:: 第八步：兜底验证（如果没找到文件，明确提示，仅将png改为jpg）
if not exist "%temp_list%" (
    echo 未找到任何截图文件！ >> "%log_file%"
) else (
    for /f %%a in (%temp_list%) do set "has_file=1"
    if not defined has_file echo 未找到任何截图文件！ >> "%log_file%"
)

:: 第九步：收尾日志+清理临时文件（完全复用最初逻辑）
echo. >> "%log_file%"
echo 【%date% %time:~0,-1%】日志生成完成，共扫描到文件：!has_file!个 >> "%log_file%"
del /f /q "%temp_list%" >nul 2>&1

:: 最终提示（和最初完全一致）
echo.
echo ======================
echo 操作完成！日志文件：
echo %log_file%
echo ======================
echo 请打开日志文件查看所有截图记录！
echo.

endlocal
pause