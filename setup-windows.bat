@echo off
setlocal

echo ==========================================
echo  Setup - Sistemi i restaurantit
echo ==========================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js nuk u gjet ne kompjuter.
  echo Shkarko dhe instalo Node.js LTS nga:
  echo https://nodejs.org/
  echo.
  pause
  exit /b 1
)

echo Node.js u gjet:
node -v
echo.

if not exist ".env" (
  echo Po krijohet file .env nga .env.example...
  copy ".env.example" ".env" >nul
  echo.
  echo U krijua .env.
  echo Hape .env dhe ndrysho DB_PASSWORD me password-in tend te SQL Server.
  echo.
) else (
  echo File .env ekziston tashme.
  echo.
)

echo Po instalohen paketat Node.js...
npm install
if errorlevel 1 (
  echo.
  echo Gabim gjate npm install.
  pause
  exit /b 1
)

echo.
echo ==========================================
echo  Setup perfundoi.
echo ==========================================
echo.
echo Hapat qe mbeten:
echo 1. Hape SQL Server Management Studio.
echo 2. Ekzekuto database\restaurant_db_sql_server.sql.
echo 3. Ndrysho .env me password-in tend.
echo 4. Starto website-in me start-restaurant.bat.
echo.
pause
