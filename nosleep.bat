@echo off
echo Setting system to never sleep, hibernate or turn off monitor...
echo ==============================================
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-dc 0
powercfg /hibernate off

echo ==============================================
echo Settings completed! Press any key to exit...
pause >nul