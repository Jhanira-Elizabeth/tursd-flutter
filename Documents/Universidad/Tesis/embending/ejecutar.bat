@echo off
setlocal

:: --- 1. Verificar y eliminar el archivo zip existente ---
echo Verificando si existe menu.zip...
if exist "menu.zip" (
    echo menu.zip encontrado. Eliminando...
    del "menu.zip"
    if errorlevel 1 (
        echo Error al eliminar menu.zip. Abortando.
        pause
        exit /b 1
    ) else (
        echo menu.zip eliminado correctamente.
    )
) else (
    echo menu.zip no encontrado. No es necesario eliminarlo.
)

echo.

:: --- 2. Comprimir los archivos en menu.zip ---
echo Comprimiendo archivos...
powershell.exe -Command "Compress-Archive -Path .env, app.py, firebase_key.json, requirements.txt -DestinationPath menu.zip"
if errorlevel 1 (
    echo Error al comprimir los archivos. Abortando.
    pause
    exit /b 1
) else (
    echo Archivos comprimidos exitosamente en menu.zip.
)

echo.

:: --- 3. Ejecutar el comando de despliegue de Azure ---
echo Ejecutando despliegue en Azure...
az webapp deploy --resource-group tursd --name tursd-asistente-menu --src-path "C:\Users\arand\Documents\Universidad\Tesis\embending\menu.zip"

echo.

echo Despliegue completado.
pause