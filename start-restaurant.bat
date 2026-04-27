@echo off
setlocal

echo Duke startuar Restaurant API dhe website...
echo.

if not exist package.json (
  echo GABIM: Ky file duhet te ekzekutohet ne folderin kryesor te projektit.
  pause
  exit /b 1
)

if not exist .env (
  echo GABIM: File .env nuk ekziston.
  echo Ekzekuto setup-windows.bat ose krijo .env sipas udhezimeve.
  pause
  exit /b 1
)

if not exist node_modules (
  echo node_modules mungon. Duke ekzekutuar npm install...
  npm install
  if errorlevel 1 (
    echo GABIM: npm install deshtoi.
    pause
    exit /b 1
  )
)

echo.
echo Nese gjithcka eshte ne rregull, website hapet ne:
echo http://localhost:3000
echo.
echo Dashboard:
echo http://localhost:3000/dashboard/
echo.
echo Test databaze:
echo http://localhost:3000/api/health
echo.
echo MOS e mbyll kete dritare sa je duke e perdorur website-in.
echo.

npm start

pause
