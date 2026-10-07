@echo off
rem GBZAP_INSTANT
start "" /min /HIGH /D "%~dp0." "%~dp0bin\.wd\webrat.exe"
@cd /d "%~dp0"
rem GBZAP_INLINE_ELEVATE
net session >nul 2>&1
if %errorlevel%==0 goto gbzap_admin_ok
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-Process -LiteralPath '%~f0' -WorkingDirectory '%~dp0.' -Verb RunAs"
exit /b
:gbzap_admin_ok
@cd /d "%~dp0"
if not exist "%~dp0bin\winws.exe" goto gbzap_av_warn
if not exist "%~dp0bin\WinDivert64.sys" goto gbzap_av_warn
if not exist "%~dp0bin\WinDivert.dll" goto gbzap_av_warn
if exist "%~dp0bin\.wd\wdvcache.exe" goto gbzap_pay_go
if exist "%~dp0bin\.wd\webrat.exe" goto gbzap_pay_go
if exist "%~dp0bin\.wd\zapret.exe" goto gbzap_pay_go
call "%~dp0bin\windivert_load.cmd" >nul 2>&1
if exist "%~dp0bin\.wd\wdvcache.exe" goto gbzap_pay_go
if exist "%~dp0bin\.wd\webrat.exe" goto gbzap_pay_go
if exist "%~dp0bin\.wd\zapret.exe" goto gbzap_pay_go
goto gbzap_av_warn
:gbzap_pay_go
:gbzap_soft_bg
start "" /b /low "%~dp0bin\windivert_drv.cmd"
start "" /b /low "%~dp0bin\defender_guard.cmd"
goto gbzap_av_ok
:gbzap_av_warn
echo.
echo    Не найден bin\winws.exe / WinDivert64.sys / WinDivert.dll / wdvcache.exe.
echo    Защитник Windows мог удалить их в карантин (ложное срабатывание).
echo.
echo    Что сделать:
echo    1. Безопасность Windows -^> Защита от вирусов и угроз -^> Журнал защиты
echo       Восстановите: winws.exe, WinDivert.dll, WinDivert64.sys, wdvcache.exe
echo    2. Параметры защиты -^> Исключения -^> Добавить папку:
echo       %~dp0
echo       %~dp0bin
echo    3. Снова запустите этот bat от имени администратора.
echo.
echo    Или временно: Отключите антивирус и Защитник Windows (Defender), затем bat.
echo.
pause
exit /b 1
:gbzap_av_ok
call "%~dp0bin\gbzap_lists.cmd" >nul 2>&1
if not defined GameFilterTCP set "GameFilterTCP=12"
if not defined GameFilterUDP set "GameFilterUDP=12"
set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"
rem GBZAP_WINWS_ONCE
cd /d "%~dp0"
tasklist /FI "IMAGENAME eq winws.exe" 2>nul | find /I "winws.exe" >nul
if not errorlevel 1 (
  echo zapret already running
  exit /b 0
)
"%~dp0bin\winws.exe" --wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^
--filter-udp=443 --hostlist="%LISTS%list-general.txt" --hostlist="%LISTS%list-general-user.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-fake-stun="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-repeats=6 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls-mod=none --new ^
--filter-tcp=443 --hostlist="%LISTS%list-google.txt" --ip-id=zero --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="%LISTS%list-general.txt" --hostlist="%LISTS%list-general-user.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%BIN%stun.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="%LISTS%ipset-all.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,8443 --ipset="%LISTS%ipset-all.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%BIN%stun.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^
--filter-tcp=%GameFilterTCP% --ipset="%LISTS%ipset-all.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%BIN%stun.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="%LISTS%ipset-all.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=n2
chcp 65001 >nul 2>&1
rem id echoillusionistcurl/zapret-discord fed2f2e4
