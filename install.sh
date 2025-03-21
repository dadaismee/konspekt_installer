#!/bin/zsh

# Install Homebrew if not installed
echo "Проверяем, установлен ли Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew не найден. Устанавливаем..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ ! -f /Users/$USER/.zprofiles ]; then
    echo >> /Users/$USER/.zprofile
fi
if ! grep 'brew shellenv' /Users/$USER/.zprofile &> /dev/null; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/$USER/.zprofile
fi
eval "$(/usr/local/bin/brew shellenv)"
source ~/.zprofile

# Installing packages

which pandoc &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка Pandoc...'
    brew install pandoc
    pandoc_path=$(which pandoc)
else
    echo "Pandoc уже установлен."
    pandoc_path=$(which pandoc)
fi
echo $pandoc_path

which tectonic &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка Tectonic...'
    brew install tectonic
    tectonic_path=$(which tectonic)
else
    echo "Tectonic уже установлен."
    tectonic_path=$(which tectonic)
fi
echo $tectonic_path

ls -l /Applications |grep Zettlr &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка Zettlr...'
    brew install --cask zettlr
else
    echo "Zettlr уже установлен."
fi

ls -l /Applications |grep Obsidian &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка Obsidian...'
    brew install --cask obsidian
else
    echo "Obsidian уже установлен."
fi

which obsidian-cli &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка obsidian-cli...'
    brew tap yakitrak/yakitrak
    brew install yakitrak/yakitrak/obsidian-cli
else
    echo "obsidian-cli уже установлен."
fi
obcli_path=$(which obsidian-cli)
#echo $obcli_path

echo 'Клонируем репозиторий с настройками Obsidian...'
git clone https://github.com/dadaismee/konspekt-starter-pack.git $HOME/testroot
mkdir -p ~/Library/Application\ Support/obsidian
if [ ! -f ~/Library/Application\ Support/obsidian/obsidian.json ]; then
    echo "Конфиг Obsidian не найден. Используем нашу заготовку..."
    cp $HOME/testroot/obsidian.json ~/Library/Application\ Support/obsidian/
    sed -i '' -e "s|test|$(whoami)|g" ~/Library/Application\ Support/obsidian/obsidian.json
else
    if grep -q konspekt_pack ~/Library/Application\ Support/obsidian/obsidian.json; then
        echo "Хранилище с таким именем уже существует"
    else
        echo "Добавим новое хранилище Obsidian в существующий конфиг..."
        sed -i '' -e "s|}}}|}, \"8095a1a7a15b1e3d\":{\"path\":\"/Users/$USER/Documents/konspekt_pack\",\"ts\":1739264225722,\"open\":true}}}|g" ~/Library/Application\ Support/obsidian/obsidian.json
    fi
fi

if [ ! -d ~/Documents/konspekt_pack ]; then
    cp -R $HOME/testroot/konspekt_pack ~/Documents
    echo "Файлы хранилища Obsidian скопированы"
else
    echo "Файлы хранилища Obsidian уже на месте"
fi

obsidian-cli set-default konspekt_pack
sleep 1

echo 'Настраиваю плагины Obsidian...'
sed -i '' -e "s|/opt/homebrew/bin/tectonic|$tectonic_path|g" ~/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/usr/local/bin/pandoc|$pandoc_path|g" ~/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/Users/test|/Users/$USER|g" ~/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/usr/local/bin/pandoc|$pandoc_path|g" ~/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc-reference-list/data.json
open -a Obsidian
echo 'Сейчас откроется Obsidian, нажмите "Доверять автору" и закройте приложение через Command+Q'
lsof -p $(pgrep -n Obsidian) +r 1 &> /dev/null
sleep 2

ls -l /Applications |grep Zotero &> /dev/null
if [ $? -ne 0 ]; then
	echo 'Установка Zotero...'
	brew install --cask zotero
else
	echo "Zotero уже установлен."
fi

echo 'Загрузка плагинов Zotero...'
mkdir -p ~/Documents/Zotero
curl -o $HOME/zotmoov.zip -LC - https://github.com/wileyyugioh/zotmoov/releases/download/1.2.18/zotmoov-1.2.18-fx.xpi
unzip $HOME/zotmoov.zip -d ~/Documents/Zotero/zotmoov &> /dev/null
curl -o $HOME/bibtex.zip -LC - https://github.com/retorquere/zotero-better-bibtex/releases/download/v7.0.5/zotero-better-bibtex-7.0.5.xpi
unzip $HOME/bibtex.zip -d ~/Documents/Zotero/bibtex &> /dev/null

if [ ! -f ~/Library/Application\ Support/Zotero/profiles.ini ]; then
    echo 'Сейчас откроется окно Zotero, выйдите из него через Command+Q'
    open -a Zotero
    lsof -p $(pgrep -n zotero) +r 1 &>/dev/null
    sleep 1
fi

if [ ! -f ~/Zotero/zotero.sqlite ]; then
    echo "Копирую библиотеку Zotero..."
    cp $HOME/testroot/zotero.sqlite /Users/$USER/Zotero/zotero.sqlite
else
    mv /Users/$USER/Zotero/zotero.sqlite /Users/$USER/Zotero/zotero.sqlite.original
    echo "Существующая база Зотеро сохранена как ~/Zotero/zotero.sqlite.original. Вы можете восстановить её, если необходимо, удалив '.original' в названии этого файла."
    cp $HOME/testroot/zotero.sqlite /Users/$USER/Zotero/zotero.sqlite
    echo "Новая библиотека Зотеро установлена вместо существующей"
fi

echo 'Устанавливаю и настраиваю плагины Zotero...'
zotero_profile_name=$(grep 'Path=Profiles/' ~/Library/Application\ Support/Zotero/profiles.ini | cut -d/ -f2-)
mkdir -p /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions

echo /Users/$USER/Documents/Zotero/zotmoov >> /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions/zotmoov@wileyy.com
echo /Users/$USER/Documents/Zotero/bibtex >> /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions/better-bibtex@iris-advies.com
sed -i '' "/lastAppVersion/d" /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
sed -i '' "/lastAppBuildId/d" /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
echo 'user_pref("extensions.zotero.translators.better-bibtex.citekeyFormat", "auth.lower + year");' >> /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
echo 'user_pref("extensions.zotero.translators.better-bibtex.citekeyFormatEditing", "auth.lower + year");' >> /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
echo 'user_pref("extensions.zotmoov.dst_dir", "/Users/'$USER'/Documents/konspekt_pack/07 service/literature PDF");' >> /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
echo 'Окно Zotero откроется для установки плагинов, выйдите из него через Command+Q'
open -a Zotero
lsof -p $(pgrep -n zotero) +r 1 &> /dev/null
sleep 2
echo 'Активирую плагины Zotero...'
sed -i '' -e 's|active":false,"userDisabled":true|active":true,"userDisabled":false|g' ~/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions.json
sleep 1
echo 'Настраиваю авто-экспорт библиотеки Zotero...'
cat $HOME/testroot/zotero.pref.js >> ~/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
sed -i '' -e "s|testuser|$(whoami)|g" ~/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js

echo 'Очистка временных файлов...'
rm -rf $HOME/testroot
echo 'Удалён репозиторий с  шаблонными настройками Obsidian'
rm -rf $HOME/bibtex.zip $HOME/zotmoov.zip
echo 'Удалёны исходники плагинов Zotero'
echo 'Очистка временных файлов завершена'
echo 'Установка завершена, открываю Obsidian. Всего доброго!'
open -a obsidian
