@echo off
setlocal
color 0A
echo.
echo ========================================
echo  ASISTENTE TURISTICO - DEPLOYMENT
echo ========================================
echo.

:: --- 1. Verificar archivos requeridos ---
echo [1/5] Verificando archivos requeridos...
set "archivos_requeridos=.env app.py requirements.txt"
set "archivos_faltantes="

for %%f in (%archivos_requeridos%) do (
    if not exist "%%f" (
        set "archivos_faltantes=!archivos_faltantes! %%f"
    ) else (
        echo   ✓ %%f encontrado
    )
)

if defined archivos_faltantes (
    echo   ❌ Archivos faltantes: %archivos_faltantes%
    echo.
    pause
    exit /b 1
)

:: Verificar archivos opcionales
if exist "firebase_key.json" (
    echo   ✓ firebase_key.json encontrado
    set "incluir_firebase=firebase_key.json, "
) else (
    echo   ⚠ firebase_key.json no encontrado (opcional)
    set "incluir_firebase="
)

echo   ✅ Verificación completada
echo.

:: --- 2. Limpiar deployment anterior ---
echo [2/5] Limpiando archivos anteriores...
if exist "menu.zip" (
    echo   🗑 Eliminando menu.zip anterior...
    del "menu.zip"
    if errorlevel 1 (
        echo   ❌ Error al eliminar menu.zip
        pause
        exit /b 1
    )
    echo   ✓ menu.zip eliminado
) else (
    echo   ✓ No hay archivos anteriores que limpiar
)
echo.

:: --- 3. Crear nuevo package ---
echo [3/5] Creando package de deployment...
echo   📦 Comprimiendo archivos...

if defined incluir_firebase (
    powershell.exe -Command "Compress-Archive -Path .env, app.py, %incluir_firebase%requirements.txt -DestinationPath menu.zip -Force"
) else (
    powershell.exe -Command "Compress-Archive -Path .env, app.py, requirements.txt -DestinationPath menu.zip -Force"
)

if errorlevel 1 (
    echo   ❌ Error al comprimir archivos
    pause
    exit /b 1
)

echo   ✅ Package creado exitosamente
echo.

:: --- 4. Verificar Azure CLI ---
echo [4/5] Verificando Azure CLI...
az --version >nul 2>&1
if errorlevel 1 (
    echo   ❌ Azure CLI no encontrado
    echo   Por favor instala Azure CLI desde: https://aka.ms/installazurecliwindows
    pause
    exit /b 1
)
echo   ✅ Azure CLI disponible
echo.

:: --- 5. Ejecutar deployment ---
echo [5/5] Ejecutando deployment en Azure...
echo   🚀 Subiendo a Azure App Service...
echo   📍 Resource Group: tursd
echo   📍 App Name: tursd-asistente-menu
echo.

az webapp deploy --resource-group tursd --name tursd-asistente-menu --src-path menu.zip --type zip --restart true