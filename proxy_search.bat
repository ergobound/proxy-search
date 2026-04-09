@echo off
setlocal
chcp 65001 >nul
:: chcp 1251

:: команда pushd принудительно переводит контекст консоли в папку, где лежит батник
pushd "%~dp0" 
set "MAIN_DIR=%~dp0"

:: Репозиторий telegram-proxy-collector
set "REPOSITORY_URL=https://github.com/kort0881/telegram-proxy-collector/archive/refs/heads/main.zip"
set "ZIP_FILE=telegram-proxy-collector-main.zip"
set "REPOSITORY_FOLDER=telegram-proxy-collector-main"

:: Python 3.11
set "PY_FINAL_FOLDER=WinPython311"
set "URL=https://github.com/winpython/winpython/releases/download/7.1.20240203final/Winpython64-3.11.8.0dot.exe"
set "ARCHIVE_NAME=WPy64-31180"
set "EXE=Winpython64-3.11.8.0dot.exe"
set "PYTHON_FOLDER=python-3.11.8.amd64"

:: Проверяем, есть ли уже скаченный репозиторий telegram-proxy-collector
if not exist "%~dp0%REPOSITORY_FOLDER%" (

    echo Скачивание репозитория telegram-proxy-collector...
    powershell -Command "Invoke-WebRequest -Uri '%REPOSITORY_URL%' -OutFile '%ZIP_FILE%'"

    echo Разархивация репозитория тест: %ZIP_FILE%

    echo Пробуем метод tar...
    tar -xf "%ZIP_FILE%" -C "%MAIN_DIR%" 2>nul

    if not exist "%~dp0%REPOSITORY_FOLDER%" (
        echo [ОШИБКА] tar не сработал. Пробуем через PowerShell...

        powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%MAIN_DIR%' -Force" 2>nul
    )

    if not exist "%~dp0%REPOSITORY_FOLDER%" (
        echo [КРИТИЧЕСКАЯ ОШИБКА] Ни один метод разархивации не сработал.
        echo Разархивируйте %ZIP_FILE% вручную в корневую папку.
        echo Путь должен быть : папка_с_батником/%REPOSITORY_FOLDER%
        pause
    )

    echo Удаление zip архива репозитория...
    del "%ZIP_FILE%"
    rd /s /q "%ARCHIVE_NAME%"
    
    :success
    echo Репозиторий telegram-proxy-collector извлечен в соответствующую папку.
)



:: Проверяем, есть ли уже скаченный WinPython311
if not exist "%~dp0%PY_FINAL_FOLDER%" (

    echo Скачивание WinPython311...
    powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%EXE%'"

    echo Распаковка...
    "%EXE%" x -y

    echo Перемещение и переименовывание необходимой папки
    move "%~dp0%ARCHIVE_NAME%\%PYTHON_FOLDER%" "%~dp0%PY_FINAL_FOLDER%"
    
    echo WinPython311 извлечен в соответствующую папку.

    echo Обновление pip...
    "WinPython311/python.exe" -m pip install --upgrade pip --no-warn-script-location

    echo Подгружаем необходимые модули...
    "WinPython311/python.exe" -m pip install requests telethon --no-warn-script-location

    echo Удаление временных файлов и папок...
    del "%EXE%"
    rd /s /q "%ARCHIVE_NAME%"

    :success
    echo WinPython311 на месте, все на месте спортсмены
)

echo Поиск прокси...
"WinPython311/python.exe" "%REPOSITORY_FOLDER%/main.py"

echo ================================================
echo TOP10 EU PROXY:

setlocal enabledelayedexpansion
set "file=%MAIN_DIR%/verified/proxy_eu_verified.txt"
set "lines=11"
set "count=1" 

for /f "usebackq skip=5 delims=" %%a in ("%file%") do (
    if !count! lss %lines% (
        echo ................................................
        echo !count!. %%a
        set /a count+=1
    )
)

echo ================================================
echo TOP10 RU PROXY:

setlocal enabledelayedexpansion
set "file=%MAIN_DIR%/verified/proxy_ru_verified.txt"
set "lines=11"
set "count=1"

for /f "usebackq skip=5 delims=" %%a in ("%file%") do (
    if !count! lss %lines% (
        echo ................................................
        echo !count!. %%a
        set /a count+=1
    )
)
echo ================================================
echo Так же можно найти все остальные найденные proxy в txt-файлах внутри папки "verified"
echo ================================================
pause