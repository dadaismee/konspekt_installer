@echo off & setlocal
chcp 65001
echo Начало работы скрипта...
pause

md %USERPROFILE%\.konspekt 2>nul

echo ###Проверка наличия Winget в системе
where /q winget
IF ERRORLEVEL 1 (
    ECHO Winget не установлен. Установите его, например, из магазина приложений Windows, или скачайте по ссылке "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
	pause
    EXIT /B
) ELSE (
    ECHO Winget найден, отлично...
)

powershell.exe Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force 2>nul

echo ###Посмотрим, установлен ли Scoop...
where /q scoop
IF ERRORLEVEL 1 (
    ECHO Scoop не установлен. Устанавливаю...
	powershell.exe "Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
	set "PATH=%PATH%;%USERPROFILE%\scoop\shims"
) ELSE (
    ECHO Scoop найден, отлично...
)

echo ###Ищем Git...
where /q scoop
IF ERRORLEVEL 1 (
    ECHO Git отсутствует. Он тоже нужен, установим его сейчас...
	powershell.exe "scoop install git"
) ELSE (
    ECHO Git найден, отлично...
)

echo ###Установка obsidian-cli и tectonic...
where /q obsidian-cli
IF ERRORLEVEL 1 (
    ECHO obsidian-cli не установлен. Устанавливаю...
	powershell.exe "$env:Path = '~\scoop\shims;' + $env:Path"
	powershell.exe "scoop bucket add scoop-yakitrak https://github.com/yakitrak/scoop-yakitrak.git"
	powershell.exe "scoop install obsidian-cli"
) ELSE (
	ECHO obsidian-cli найден, отлично...
)

where /q tectonic
IF ERRORLEVEL 1 (
    ECHO tectonic не установлен. Устанавливаю...
	powershell.exe "$env:Path = '~\scoop\shims;' + $env:Path"
	powershell.exe "scoop install tectonic"
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
rem if not exist C:\Users\%username%\AppData\Local\Programs\Zettlr\Zettlr.exe (
rem    winget install -e --id Zettlr.Zettlr --silent
rem )

echo ###Скачивание репозитория с настройками Obsidian и Zotero...
curl.exe -o %USERPROFILE%\.konspekt\konspekt.zip -L https://github.com/dadaismee/konspekt-starter-pack/archive/refs/heads/main.zip
tar -xf %USERPROFILE%\.konspekt\konspekt.zip -C %USERPROFILE%\.konspekt

echo ###Установка Obsidian ...
if not exist C:\Users\%username%\AppData\Local\Programs\Obsidian\Obsidian.exe (
    winget install -e --id Obsidian.Obsidian --silent
)
md %appdata%\obsidian 2>nul

if not exist %appdata%\obsidian\obsidian.json (
    echo Конфиг Obsidian не найден. Используем нашу заготовку...
	copy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian_win.json %appdata%\obsidian\obsidian.json
	powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',$env:USERNAME | Out-File -encoding ASCII $env:APPDATA\obsidian\obsidian.json"
) else (
	>nul find "konspekt_pack" %appdata%\obsidian\obsidian.json && (
		echo Хранилище Obsidian с именем konspekt_pack уже существует
		echo Переименуем его во избежание конфликтов...
		powershell "$fdate = Get-Date -format 'yyyyMMdd-hhmmss'; Rename-Item $env:APPDATA\obsidian\obsidian.json $env:APPDATA\obsidian\obsidian_$fdate.json; echo 'Старый конфиг хранилища был переименован в 'obsidian_$fdate.json"
		copy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian_win.json %appdata%\obsidian\obsidian.json
		powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',$env:USERNAME | Out-File -encoding ASCII $env:APPDATA\obsidian\obsidian.json"
	) || (
		echo Добавим новое хранилище Obsidian в существующий конфиг...
		powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace '}}}','},\"8095a1a7a15b1e3d\":{\"path\":\"C:\\Users\\test\\konspekt_pack\",\"ts\":1739264225722,\"open\":true}}}' | Out-File -encoding ASCII $env:APPDATA\obsidian\obsidian.json"
		powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'e}},','e}, \"8095a1a7a15b1e3d\":{\"path\":\"C:\\Users\\test\\konspekt_pack\",\"ts\":1739264225722,\"open\":true}},' | Out-File -encoding ASCII $env:APPDATA\obsidian\obsidian.json"
		powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',$env:USERNAME | Out-File -encoding ASCII $env:APPDATA\obsidian\obsidian.json"
	)
)

if not exist C:\Users\%username%\konspekt_pack (
    md C:\Users\%username%\konspekt_pack 2>nul
	xcopy /eqy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\konspekt_pack C:\Users\%username%\konspekt_pack
    echo Файлы хранилища Obsidian скопированы
) else (
    echo Файлы хранилища Obsidian уже на месте, сохраним их под другим именем...
	powershell "$fdate = Get-Date -format 'yyyyMMdd-hhmmss'; Rename-Item $env:USERPROFILE\konspekt_pack $env:USERPROFILE\konspekt_pack_$fdate; Write-Output 'Файлы хранилища с таким же названием были перемещены'"
	md C:\Users\%username%\konspekt_pack 2>nul
	xcopy /eqy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\konspekt_pack C:\Users\%username%\konspekt_pack
    echo Файлы хранилища Obsidian скопированы
)

rem %USERPROFILE%\scoop\shims\obsidian-cli set-default konspekt_pack
powershell "obsidian-cli set-default konspekt_pack"
timeout 1

echo Настраиваю плагины Obsidian...
copy /Y %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian-pandoc_data_win.json C:\Users\%username%\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json
powershell.exe "(Get-Content C:\Users\$env:USERNAME\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json) -replace 'testuser',$env:USERNAME | Out-File -encoding ASCII C:\Users\$env:USERNAME\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json"
copy /Y %USERPROFILE%\.konspekt\konspekt-starter-pack-main\obsidian-pandoc-reference-list_data_win.json C:\Users\%username%\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json
powershell.exe "(Get-Content C:\Users\$env:USERNAME\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json) -replace 'testuser',$env:USERNAME | Out-File -encoding ASCII C:\Users\$env:USERNAME\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json"

echo Сейчас откроется Obsidian, нажмите "Доверять автору" и закройте приложение
timeout 2
start /wait C:\Users\%username%\AppData\Local\Programs\Obsidian\Obsidian.exe

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

if not exist %userprofile%\Zotero\zotero.sqlite (
    rem echo Копирую библиотеку Zotero...
	rem copy %userprofile%\.konspekt\konspekt-starter-pack-main\zotero.sqlite %userprofile%\Zotero\zotero.sqlite
	echo Сейчас откроется окно Zotero, закройте его через одну-две секунды
	timeout 2
	powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"
) else (
	rem powershell "$fdate = Get-Date -format 'yyyyMMdd-hhmmss'; Rename-Item $env:USERPROFILE\Zotero\zotero.sqlite $env:USERPROFILE\Zotero\zotero_$fdate.sqlite; $oldname1 = '      Существующая база Зотеро сохранена как ~/Zotero/zotero_'; $oldname2 = '.sqlite'; Write-Output $oldname1$fdate$oldname2"
	rem copy %USERPROFILE%\.konspekt\konspekt-starter-pack-main\zotero.sqlite %userprofile%\Zotero\zotero.sqlite
	rem echo Новая библиотека Зотеро установлена вместо существующей
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

type %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js | findstr /v lastAppVersion | findstr /v lastAppBuildId > prefs.js
echo user_pref("extensions.zotero.translators.better-bibtex.citekeyFormat", "auth.lower + year");>> prefs.js
echo user_pref("extensions.zotero.translators.better-bibtex.citekeyFormatEditing", "auth.lower + year");>> prefs.js
echo user_pref("extensions.zotmoov.dst_dir", "C:\\Users\\%USERNAME%\\konspekt_pack\\07 service\\literature PDF");>> prefs.js
copy /y prefs.js %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js

echo Сейчас для установки плагинов откроется окно Zotero, выйдите из него через одну-две секунды
timeout 2
powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"
echo Активирую плагины Zotero...
powershell.exe "(Get-Content $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions.json) -replace 'active\":false,\"userDisabled\":true','active\":true,\"userDisabled\":false' | Out-File -encoding ASCII $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions.json"

echo Настраиваю авто-экспорт библиотеки Zotero...
type %USERPROFILE%\.konspekt\konspekt-starter-pack-main\zotero.pref_win.js >> %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js
powershell.exe "(Get-Content $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js) -replace 'testuser',$env:USERNAME | Out-File -encoding ASCII $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js"


echo Очистка временных файлов...
rd /s /q %USERPROFILE%\.konspekt
del prefs.js
echo Очистка временных файлов завершена

echo Ещё раз откроем Zotero для финальных штрихов, закройте его через секунд 10
timeout 2
powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"

echo Попытка настройки отображения Citation key...
powershell.exe "(Get-Content $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\treePrefs.json) -replace 'true}}}','false}}}' | Out-File -encoding ASCII $env:APPDATA\Zotero\Zotero\Profiles\%zotero_profile_name%\treePrefs.json"

echo Установка завершена, открываю Obsidian. Всего доброго!
timeout 2
start C:\Users\%username%\AppData\Local\Programs\Obsidian\Obsidian.exe

pause