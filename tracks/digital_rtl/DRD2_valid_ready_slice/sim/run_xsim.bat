@echo off
setlocal enabledelayedexpansion

set SEED=%1
if "%SEED%"=="" set SEED=7
set N=%2
if "%N%"=="" set N=2000
set TAG=%3
if "%TAG%"=="" set TAG=regslice_smoke

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set DATE=%%i
set RUN_DIR=results\run_%DATE%_seed%SEED%_%TAG%
mkdir %RUN_DIR% 2>nul

echo xvlog -sv rtl/reg_slice.sv tb/tb_reg_slice.sv > %RUN_DIR%\command.txt
echo xelab tb_reg_slice -debug typical -s sim_slice >> %RUN_DIR%\command.txt
echo xsim sim_slice -R +seed=%SEED% +n=%N% -log %RUN_DIR%\transcript.log -wdb %RUN_DIR%\waves.wdb >> %RUN_DIR%\command.txt

xvlog -sv rtl/reg_slice.sv tb/tb_reg_slice.sv
if errorlevel 1 (
  echo [ERROR] xvlog failed
  exit /b 1
)

xelab tb_reg_slice -debug typical -s sim_slice
if errorlevel 1 (
  echo [ERROR] xelab failed
  exit /b 1
)

xsim sim_slice -R +seed=%SEED% +n=%N% -log %RUN_DIR%\transcript.log -wdb %RUN_DIR%\waves.wdb
if errorlevel 1 (
  echo [ERROR] xsim failed
  exit /b 1
)

echo seed=%SEED%> %RUN_DIR%\run_info.txt
echo n=%N%>> %RUN_DIR%\run_info.txt
echo tag=%TAG%>> %RUN_DIR%\run_info.txt
echo Run folder: %RUN_DIR%