@echo off & setlocal
chcp 65001
echo Начало работы скрипта...
rem pause

rem powershell "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
rd /s /q %USERPROFILE%\.konspekt 2>nul
md %USERPROFILE%\.konspekt 2>nul

echo ###Проверка наличия Winget в системе
where /q winget
IF ERRORLEVEL 1 (
    ECHO Winget не установлен. Попытка установки...
	powershell.exe "Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.11.400/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile $env:USERPROFILE\WinGet.msixbundle"
	ECHO Если что-то пошло не так, вы можете установите его вручную из магазина приложений Windows, или скачать по ссылке "https://github.com/microsoft/winget-cli/releases/download/v1.11.400/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
	powershell.exe "Add-AppxPackage -Path $env:USERPROFILE\WinGet.msixbundle"
	set "PATH=%PATH%;%USERPROFILE%\AppData\Local\Microsoft\WindowsApps"
	powershell.exe "$env:Path += \";$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\""
	rem powershell.exe "[Environment]::SetEnvironmentVariable(\"PATH\", \"$([Environment]::GetEnvironmentVariable(\"PATH\", \"User\"));$env:USERPROFILE\AppData\Local\Microsoft\Windows\", \"User\")"
    rem EXIT /B
) ELSE (
    ECHO Winget найден, отлично...
)

where /q winget
IF ERRORLEVEL 1 (
	ECHO Установка Winget не удалась. Установите его вручную или обновите вашу версию Windows.
	EXIT /B
)

echo ###Посмотрим, установлен ли Scoop...
where /q scoop
IF ERRORLEVEL 1 (
    ECHO Scoop не установлен. Устанавливаю...
	powershell.exe "Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
	set "PATH=%PATH%;%USERPROFILE%\scoop\shims"
	rem powershell.exe "[Environment]::SetEnvironmentVariable(\"PATH\", \"$([Environment]::GetEnvironmentVariable(\"PATH\", \"User\"));$env:USERPROFILE\scoop\shims\", \"User\")"
) ELSE (
    ECHO Scoop найден, отлично...
)

echo ###Ищем Git...
where /q git
IF ERRORLEVEL 1 (
    ECHO Git отсутствует. Он тоже нужен, установим его сейчас...
	powershell.exe "$env:Path += \";$env:USERPROFILE\scoop\shims\"; scoop install git"
) ELSE (
    ECHO Git найден, отлично...
)

echo ###Установка obsidian-cli и tectonic...
where /q obsidian-cli
IF ERRORLEVEL 1 (
    ECHO obsidian-cli не установлен. Устанавливаю...
	powershell.exe "$env:Path += \";$env:USERPROFILE\scoop\shims\"; scoop bucket add scoop-yakitrak https://github.com/yakitrak/scoop-yakitrak.git; scoop install obsidian-cli"
) ELSE (
	ECHO obsidian-cli найден, отлично...
)

where /q tectonic
IF ERRORLEVEL 1 (
    ECHO tectonic не установлен. Устанавливаю...
	powershell.exe "$env:Path += \";$env:USERPROFILE\scoop\shims\"; scoop install tectonic"
) ELSE (
	ECHO tectonic найден, отлично...
)

where /q pandoc
if errorlevel 1 (
	echo ###Pandoc не найден, устанавливаю ...
	winget install -e --id JohnMacFarlane.Pandoc --silent
) else (
	echo Pandoc уже установлен
)

rem set batchPath=%~dp0

rem echo ###Установка Zettlr ...
rem if not exist %userprofile%\AppData\Local\Programs\Zettlr\Zettlr.exe (
rem    winget install -e --id Zettlr.Zettlr --silent
rem )

echo ###Скачивание репозитория с настройками Obsidian и Zotero...
curl.exe -o %USERPROFILE%\.konspekt\konspekt.zip -L https://github.com/dadaismee/konspekt-starter-pack/archive/refs/heads/main.zip
tar -xf %USERPROFILE%\.konspekt\konspekt.zip -C %USERPROFILE%\.konspekt

echo ###Установка Obsidian ...
if not exist %userprofile%\AppData\Local\Programs\Obsidian\Obsidian.exe (
    winget install -e --id Obsidian.Obsidian --silent
)
md %appdata%\obsidian 2>nul

if not exist %userprofile%\konspekt_pack (
    md %userprofile%\konspekt_pack 2>nul
	xcopy /eqy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\konspekt_pack %userprofile%\konspekt_pack
    echo Файлы хранилища Obsidian скопированы
) else (
    echo Файлы хранилища Obsidian уже на месте, сохраним их под другим именем...
	powershell "$fdate = Get-Date -format 'yyyyMMdd-hhmmss'; Rename-Item $env:USERPROFILE\konspekt_pack $env:USERPROFILE\konspekt_pack_$fdate; Write-Output 'Файлы хранилища с таким же названием были перемещены'"
	md %userprofile%\konspekt_pack 2>nul
	xcopy /eqy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\konspekt_pack %userprofile%\konspekt_pack
    echo Файлы хранилища Obsidian скопированы
)

echo Сейчас все окна Obsidian будут закрыты.
pause
taskkill /f /t /im obsidian.exe
timeout 1
if not exist %appdata%\obsidian\obsidian.json (
    echo Конфиг Obsidian не найден. Используем нашу заготовку...
	copy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian_win.json %appdata%\obsidian\obsidian.json
	rem powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',(Split-Path -Path $env:userprofile -Leaf) | Out-File -encoding UTF8 $env:APPDATA\obsidian\obsidian.json"
	powershell.exe "$utf8 = New-Object Text.UTF8Encoding; $content = (Get-Content -Raw -PSPath $env:APPDATA\obsidian\obsidian.json) -replace 'test',(Split-Path -Path $env:userprofile -Leaf); Set-Content -Value $utf8.GetBytes($content) -Encoding Byte -PSPath $env:APPDATA\obsidian\obsidian.json"
) else (
	rem >nul find "konspekt_pack" %appdata%\obsidian\obsidian.json && (
		rem echo Хранилище Obsidian с именем konspekt_pack уже существует
		rem echo Переименуем его во избежание конфликтов...
		rem powershell "$fdate = Get-Date -format 'yyyyMMdd-hhmmss'; Rename-Item $env:APPDATA\obsidian\obsidian.json $env:APPDATA\obsidian\obsidian_$fdate.json; rem echo 'Старый конфиг хранилища был переименован в '$env:APPDATA\obsidian\obsidian_$fdate.json"
		rem copy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian_win.json %appdata%\obsidian\obsidian.json
		rem powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',(Split-Path -Path $env:userprofile -Leaf) | Out-File -encoding UTF8 $env:APPDATA\obsidian\obsidian.json"
		rem echo При необходимости просто снова добавьте ваше старое хранилище вручную
	rem ) || (
		rem echo Добавим наше хранилище Obsidian в существующий конфиг...
		rem powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace ',"open":true}','}'
		rem powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace '}}}','},\"8095a1a7a15b1e3d\":{\"path\":\"C:\\Users\\test\\konspekt_pack\",\"ts\":1739264225722,\"open\":true}},\"showReleaseNotes\":false}' | Out-File -encoding UTF8 $env:APPDATA\obsidian\obsidian.json"
		rem powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace '}},','}, \"8095a1a7a15b1e3d\":{\"path\":\"C:\\Users\\test\\konspekt_pack\",\"ts\":1739264225722,\"open\":true}},\"showReleaseNotes\":false}' | Out-File -encoding UTF8 $env:APPDATA\obsidian\obsidian.json"
		rem powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',(Split-Path -Path $env:userprofile -Leaf) | Out-File -encoding UTF8 $env:APPDATA\obsidian\obsidian.json"
	rem )
	echo По крайней мере одно хранилище Obsidian уже существует
	echo Переименуем его во избежание конфликтов...
	powershell "$fdate = Get-Date -format 'yyyyMMdd-hhmmss'; Rename-Item $env:APPDATA\obsidian\obsidian.json $env:APPDATA\obsidian\obsidian_$fdate.json; echo 'Старый конфиг хранилища был переименован в '$env:APPDATA\obsidian\obsidian_$fdate.json"
	copy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian_win.json %appdata%\obsidian\obsidian.json
	rem powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',(Split-Path -Path $env:userprofile -Leaf) | Out-File -encoding UTF8 $env:APPDATA\obsidian\obsidian.json"
	powershell.exe "$utf8 = New-Object Text.UTF8Encoding; $content = (Get-Content -Raw -PSPath $env:APPDATA\obsidian\obsidian.json) -replace 'test',(Split-Path -Path $env:userprofile -Leaf); Set-Content -Value $utf8.GetBytes($content) -Encoding Byte -PSPath $env:APPDATA\obsidian\obsidian.json"
	echo При необходимости просто снова добавьте ваше старое хранилище вручную
)

rem %USERPROFILE%\scoop\shims\obsidian-cli set-default konspekt_pack
powershell "obsidian-cli set-default konspekt_pack"
timeout 1

echo Настраиваю плагины Obsidian...
copy /Y %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian-pandoc_data_win.json %userprofile%\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json
rem powershell.exe "(Get-Content $env:userprofile\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json) -replace 'testuser',(Split-Path -Path $env:userprofile -Leaf) | Out-File -encoding UTF8 $env:userprofile\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json"
powershell.exe "$utf8 = New-Object Text.UTF8Encoding; $content = (Get-Content -Raw -PSPath $env:userprofile\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json) -replace 'testuser',(Split-Path -Path $env:userprofile -Leaf); Set-Content -Value $utf8.GetBytes($content) -Encoding Byte -PSPath $env:userprofile\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json"
copy /Y %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian-pandoc-reference-list_data_win.json %userprofile%\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json
rem powershell.exe "(Get-Content $env:userprofile\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json) -replace 'testuser',(Split-Path -Path $env:userprofile -Leaf) | Out-File -encoding UTF8 $env:userprofile\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json"
powershell.exe "$utf8 = New-Object Text.UTF8Encoding; $content = (Get-Content -Raw -PSPath $env:userprofile\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json) -replace 'testuser',(Split-Path -Path $env:userprofile -Leaf); Set-Content -Value $utf8.GetBytes($content) -Encoding Byte -PSPath $env:userprofile\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json"

echo Сейчас откроется Obsidian, нажмите "Доверять автору" и закройте приложение
timeout 2
start /wait %userprofile%\AppData\Local\Programs\Obsidian\Obsidian.exe

echo ###Установка Zotero ...
if not exist "C:\Program Files\Zotero\zotero.exe" winget install -e --id DigitalScholar.Zotero --silent

echo ###Загрузка плагинов Зотеро
if not exist %userprofile%\.konspekt\bibtex.zip (
	curl.exe -o %USERPROFILE%\.konspekt\bibtex.zip -L https://github.com/retorquere/zotero-better-bibtex/releases/download/v7.0.5/zotero-better-bibtex-7.0.5.xpi
	md %USERPROFILE%\.konspekt\bibtex 2>nul & tar -xf %USERPROFILE%\.konspekt\bibtex.zip -C %USERPROFILE%\.konspekt\bibtex
	echo ###Загрузка плагина better-bibtex завершена...
)
if not exist %userprofile%\.konspekt\zotmoov.zip (
	curl.exe -o %USERPROFILE%\.konspekt\zotmoov.zip -L https://github.com/wileyyugioh/zotmoov/releases/download/1.2.11/zotmoov-1.2.11-fx.xpi
	md %USERPROFILE%\.konspekt\zotmoov 2>nul & tar -xf %USERPROFILE%\.konspekt\zotmoov.zip -C %USERPROFILE%\.konspekt\zotmoov
	echo ###Загрузка плагина zotmoov завершена...
)

echo Сейчас все окна Zotero будут закрыты.
pause
taskkill /f /t /im zotero.exe
timeout 1
if not exist %userprofile%\Zotero\zotero.sqlite (
	echo Сейчас откроется окно Zotero, закройте его через одну-две секунды
	timeout 2
	powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"
) else (
	powershell "$fdate = Get-Date -format 'yyyyMMdd-hhmmss'; Rename-Item $env:USERPROFILE\Zotero\zotero.sqlite $env:USERPROFILE\Zotero\zotero_$fdate.sqlite; $oldname1 = '      Существующая база Зотеро сохранена как ~/Zotero/zotero_'; $restore = '      Вы можете восстановить её, если необходимо, переименовав этот файл в zotero.sqlite'; $oldname2 = '.sqlite'; Write-Output $oldname1$fdate$oldname2; Write-Output $restore"
	echo Сейчас откроется окно Zotero, закройте его через одну-две секунды
	timeout 2
	powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"
)

echo Устанавливаю и настраиваю плагины Zotero...
for /f "tokens=1,2delims=/" %%i in ('powershell "Get-Content $env:APPDATA\Zotero\Zotero\profiles.ini | Select-String -Pattern Path"') do set zotero_profile_name=%%j
md %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions 2>nul
if not exist %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\better-bibtex@iris-advies.com (
	md %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\better-bibtex@iris-advies.com 2>nul
	xcopy /eqy %USERPROFILE%\.konspekt\bibtex %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\better-bibtex@iris-advies.com
)
if not exist %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\zotmoov@wileyy.com (
	md %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\zotmoov@wileyy.com 2>nul
	xcopy /eqy %USERPROFILE%\.konspekt\zotmoov %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\zotmoov@wileyy.com
)

for /f "tokens=1,3delims=\" %%i in ('echo %userprofile%') do set profilename=%%j
type %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js | findstr /v lastAppVersion | findstr /v lastAppBuildId > prefs.js
echo user_pref("extensions.zotero.translators.better-bibtex.citekeyFormat", "auth.lower + year");>> prefs.js
echo user_pref("extensions.zotero.translators.better-bibtex.citekeyFormatEditing", "auth.lower + year");>> prefs.js
echo user_pref("extensions.zotmoov.dst_dir", "C:\\Users\\%profilename%\\konspekt_pack\\05_service\\literature-PDF");>> prefs.js
copy /y prefs.js %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js

echo Сейчас для установки плагинов откроется окно Zotero, выйдите из него через одну-две секунды
timeout 2
powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"
echo Активирую плагины Zotero...
powershell.exe "(Get-Content $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions.json) -replace 'active\":false,\"userDisabled\":true','active\":true,\"userDisabled\":false' | Out-File -encoding UTF8 $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions.json"

echo Настраиваю авто-экспорт библиотеки Zotero...
type %USERPROFILE%\.konspekt\konspekt-starter-pack-main\zotero.pref_win.js >> %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js
rem powershell.exe "(Get-Content $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js) -replace 'testuser',(Split-Path -Path $env:userprofile -Leaf) | Out-File -encoding UTF8 $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js"
powershell.exe "$utf8 = New-Object Text.UTF8Encoding; $content = (Get-Content -Raw -PSPath $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js) -replace 'testuser',(Split-Path -Path $env:userprofile -Leaf); Set-Content -Value $utf8.GetBytes($content) -Encoding Byte -PSPath $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js"


echo Очистка временных файлов...
rd /s /q %USERPROFILE%\.konspekt
del prefs.js
echo Очистка временных файлов завершена

echo Ещё раз откроем Zotero для финальных штрихов, закройте его через секунд 10
timeout 2
powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"

echo Попытка настройки отображения Citation key...
rem powershell.exe "(Get-Content $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\treePrefs.json) -replace 'true}}}','false}}}' | Out-File -encoding UTF8 $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\treePrefs.json"
powershell.exe "$utf8 = New-Object Text.UTF8Encoding; $content = (Get-Content -Raw -PSPath $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\treePrefs.json) -replace 'true}}}','false}}}'; Set-Content -Value $utf8.GetBytes($content) -Encoding Byte -PSPath $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\treePrefs.json"

echo Установка завершена, открываю Obsidian. Всего доброго!
timeout 2
start %userprofile%\AppData\Local\Programs\Obsidian\Obsidian.exe

pause
