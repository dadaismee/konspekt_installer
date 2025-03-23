@echo off & setlocal
chcp 65001
md C:\test
echo ###Проверка наличия Winget в системе
where /q winget
IF ERRORLEVEL 1 (
    ECHO Winget не установлен. Установите его, например, из магазина приложений Windows, или скачайте по ссылке "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
	pause
    EXIT /B
) ELSE (
    ECHO Winget найден, отлично...
)

powershell.exe Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

echo ###Посмотрим, установлен ли Scoop...
where /q scoop
IF ERRORLEVEL 1 (
    ECHO Scoop не установлен. Устанавливаю...
	powershell.exe "Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
) ELSE (
    ECHO Scoop найден, отлично...
)

echo ###Установка obsidian-cli и tectonic...
where /q obsidian-cli
IF ERRORLEVEL 1 (
    ECHO obsidian-cli не установлен. Устанавливаю...
	C:\Users\%username%\scoop\shims\scoop bucket add scoop-yakitrak https://github.com/yakitrak/scoop-yakitrak.git"
	C:\Users\%username%\scoop\shims\scoop install obsidian-cli
) ELSE (
    ECHO obsidian-cli найден, отлично...
)
rem for /f %%i in ('where obsidian-cli') do set obscli_path=%%i

where /q tectonic
IF ERRORLEVEL 1 (
    ECHO tectonic не установлен. Устанавливаю...
	C:\Users\%username%\scoop\shims\scoop install tectonic
) ELSE (
    ECHO tectonic найден, отлично...
)
rem for /f %%i in ('where tectonic') do set tectonic_path=%%i

where /q pandoc
if errorlevel 1 (
	echo ###Pandoc не найден, устанавливаю ...
	winget install -e --id JohnMacFarlane.Pandoc
) else (
	echo Pandoc уже установлен
)
for /f %%i in ('where pandoc') do set pandoc_path=%%i

rem set batchPath=%~dp0

echo ###Клонируем репозиторий с настройками Obsidian и Zotero...
curl.exe -o C:\test\obstest.zip -LC - https://github.com/openmindead/obsidian-test/archive/refs/heads/main.zip
tar -xf C:\test\obstest.zip -C C:\test

echo ###Установка Obsidian ...
if not exist C:\Users\%username%\AppData\Local\Programs\Obsidian\Obsidian.exe winget install -e --id Obsidian.Obsidian
md %appdata%\obsidian

if not exist %appdata%\obsidian\obsidian.json (
    echo Конфиг Obsidian не найден. Используем нашу заготовку...
	copy C:\test\obsidian-test-main\obsidian_win.json %appdata%\obsidian\obsidian.json
	powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',$env:USERNAME | Out-File -encoding ASCII $env:APPDATA\obsidian\obsidian.json"
) else (
	>nul find "konspekt_pack" %appdata%\obsidian\obsidian.json && (
		echo Хранилище с таким именем уже существует
	) || (
		echo Добавим новое хранилище Obsidian в существующий конфиг...
		powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace '}}}','},\"8095a1a7a15b1e3d\":{\"path\":\"C:\\Users\\test\\Documents\\konspekt_pack\",\"ts\":1739264225722,\"open\":true}}}' | Out-File -encoding ASCII $env:APPDATA\obsidian\obsidian.json"
		powershell.exe "(Get-Content $env:APPDATA\obsidian\obsidian.json) -replace 'test',$env:USERNAME | Out-File -encoding ASCII $env:APPDATA\obsidian\obsidian.json"
	)
)

if not exist C:\Users\%username%\Documents\konspekt_pack (
    md C:\Users\%username%\Documents\konspekt_pack
	xcopy /E C:\test\obsidian-test-main\konspekt_pack C:\Users\%username%\Documents\konspekt_pack
    echo Файлы хранилища Obsidian скопированы
) else (
    echo Файлы хранилища Obsidian уже на месте
)

powershell "obsidian-cli set-default konspekt_pack"
timeout 1

echo Настраиваю плагины Obsidian...
copy /Y C:\test\obsidian-test-main\obsidian-pandoc_data_win.json C:\Users\%username%\Documents\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json
powershell.exe "(Get-Content C:\Users\$env:USERNAME\Documents\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json) -replace 'testuser',$env:USERNAME | Out-File -encoding ASCII C:\Users\$env:USERNAME\Documents\konspekt_pack\.obsidian\plugins\obsidian-pandoc\data.json"
copy /Y C:\test\obsidian-test-main\obsidian-pandoc-reference-list_data_win.json C:\Users\%username%\Documents\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json
powershell.exe "(Get-Content C:\Users\$env:USERNAME\Documents\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json) -replace 'testuser',$env:USERNAME | Out-File -encoding ASCII C:\Users\$env:USERNAME\Documents\konspekt_pack\.obsidian\plugins\obsidian-pandoc-reference-list\data.json"

echo Сейчас откроется Obsidian, нажмите "Доверять автору" и закройте приложение
timeout 2
start /wait C:\Users\%username%\AppData\Local\Programs\Obsidian\Obsidian.exe

echo ###Установка Zotero ...
if not exist "C:\Program Files\Zotero\zotero.exe" winget install -e --id DigitalScholar.Zotero

echo ###Загрузка плагинов Зотеро
curl.exe -o C:\test\bibtex.zip -LC - https://github.com/retorquere/zotero-better-bibtex/releases/download/v7.0.5/zotero-better-bibtex-7.0.5.xpi
md C:\test\bibtex & tar -xf C:\test\bibtex.zip -C C:\test\bibtex
echo ###Загрузка плагина better-bibtex завершена...
curl.exe -o C:\test\zotmoov.zip -LC - https://github.com/wileyyugioh/zotmoov/releases/download/1.2.11/zotmoov-1.2.11-fx.xpi
md C:\test\zotmoov & tar -xf C:\test\zotmoov.zip -C C:\test\zotmoov
echo ###Загрузка плагина zotmoov завершена...

echo Сейчас откроется окно Zotero, закройте его через одну-две секунды
timeout 2
powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"
powershell "Rename-Item $env:USERPROFILE\Zotero\zotero.sqlite $env:USERPROFILE\Zotero\zotero.sqlite.original"
echo Существующая база Зотеро сохранена как ~/Zotero/zotero.sqlite.original. Вы можете восстановить её, если необходимо, удалив '.original' в названии этого файла.
copy C:\test\obsidian-test-main\zotero.sqlite %userprofile%\Zotero\zotero.sqlite
echo Новая библиотека Зотеро установлена вместо существующей

echo Устанавливаю и настраиваю плагины Zotero...
for /f "tokens=1,2delims=/" %%i in ('powershell "Get-Content $env:APPDATA\Zotero\Zotero\profiles.ini | Select-String -Pattern Path"') do set zotero_profile_name=%%j
md %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions
md %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\better-bibtex@iris-advies.com
xcopy /E C:\test\bibtex %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\better-bibtex@iris-advies.com
md %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\zotmoov@wileyy.com
xcopy /E C:\test\zotmoov %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions\zotmoov@wileyy.com
type %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js | findstr /v lastAppVersion | findstr /v lastAppBuildId > prefs.js
echo user_pref("extensions.zotero.translators.better-bibtex.citekeyFormat", "auth.lower + year");>> prefs.js
echo user_pref("extensions.zotero.translators.better-bibtex.citekeyFormatEditing", "auth.lower + year");>> prefs.js
echo user_pref("extensions.zotmoov.dst_dir", "C:\\Users\\%USERNAME%\\Documents\\konspekt_pack\\Literature");>> prefs.js
copy /y prefs.js %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js

echo Сейчас для установки плагинов откроется окно Zotero, выйдите из него через одну-две секунды
timeout 2
powershell "start-process -wait 'C:\Program Files\Zotero\zotero.exe'"
echo Активирую плагины Zotero...
powershell.exe "(Get-Content $env:%appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions.json) -replace 'active\":false,\"userDisabled\":true','active\":true,\"userDisabled\":false' | Out-File -encoding ASCII $env:%appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\extensions.json"

echo 'Настраиваю авто-экспорт библиотеки Zotero...'
type C:\test\obsidian-test-main\zotero.pref_win.js >> %appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js
powershell.exe "(Get-Content $env:%appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js) -replace 'testuser',$env:USERNAME | Out-File -encoding ASCII $env:%appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\prefs.js"

echo Вишенка на торте (Citation key)...
powershell.exe "(Get-Content $env:%appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\treePrefs.json) -replace 'better-bibtex-iris-advies-com-citationKey\",\"ordinal\":33,\"hidden\":true','better-bibtex-iris-advies-com-citationKey\",\"ordinal\":33,\"hidden\":false' | Out-File -encoding ASCII $env:%appdata%\Zotero\Zotero\Profiles\%zotero_profile_name%\treePrefs.json"


echo Очистка временных файлов...
rd /s /q C:\test
del prefs.js
echo 'Очистка временных файлов завершена'
echo 'Установка завершена, всего доброго.'

pause