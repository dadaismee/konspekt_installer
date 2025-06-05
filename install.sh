#!/bin/zsh

bold=$(tput bold)
normal=$(tput sgr0)

# Install Homebrew if not installed
echo "${bold}Проверяем, установлен ли Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew не найден. Устанавливаем..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ ! -f /Users/$USER/.zprofiles ]; then
    echo >> /Users/$USER/.zprofile
fi
arch=$(sysctl -n machdep.cpu.brand_string |cut -w -f1)
if ! grep 'brew shellenv' /Users/$USER/.zprofile &> /dev/null; then
    if [[ $arch = "Apple" ]]; then echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$USER/.zprofile; else echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/$USER/.zprofile; fi
fi
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
git clone https://github.com/dadaismee/konspekt-starter-pack.git $HOME/.konspekt
mkdir -p $HOME/Library/Application\ Support/obsidian
if [ ! -f $HOME/Library/Application\ Support/obsidian/obsidian.json ]; then
    echo "Конфиг Obsidian не найден. Используем нашу заготовку..."
    cp $HOME/.konspekt/obsidian.json $HOME/Library/Application\ Support/obsidian/
    sed -i '' -e "s|test|$(whoami)|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
else
    if grep -q konspekt_pack $HOME/Library/Application\ Support/obsidian/obsidian.json; then
        echo "Хранилище с таким именем уже существует"
        echo "Переимнуем его во избежание конфликтов"
        fdate=$(date +%Y%m%d-%H%M%S)
        mv $HOME/Library/Application\ Support/obsidian/obsidian.json "$HOME/Library/Application\ Support/obsidian/obsidian_$fdate.json"
        cp $HOME/.konspekt/obsidian.json $HOME/Library/Application\ Support/obsidian/
        sed -i '' -e "s|test|$(whoami)|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
        echo "Старый конфиг хранилищ был переименован в obsidian_$fdate.json"
    else
        echo "Добавим новое хранилище Obsidian в существующий конфиг..."
        sed -i '' -e "s|}}}|}, \"8095a1a7a15b1e3d\":{\"path\":\"/Users/$USER/Documents/konspekt_pack\",\"ts\":1739264225722,\"open\":true}}}|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
        sed -i '' -e "s|e}},|e}, \"8095a1a7a15b1e3d\":{\"path\":\"/Users/$USER/Documents/konspekt_pack\",\"ts\":1739264225722,\"open\":true}},|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
    fi
fi

if [ ! -d $HOME/Documents/konspekt_pack ]; then
    cp -R $HOME/.konspekt/konspekt_pack $HOME/Documents
    echo "Файлы хранилища Obsidian скопированы"
else
    echo "Файлы хранилища Obsidian уже на месте, сохраним их под другим именем..."
    fdate=$(date +%Y%m%d-%H%M%S)
    mv $HOME/Documents/konspekt_pack $HOME/Documents/konspekt_pack_$fdate
    echo "Файлы хранилища с таким же названием были перемещены"
    cp -R $HOME/.konspekt/konspekt_pack $HOME/Documents
    echo "Файлы хранилища Obsidian скопированы"
fi

obsidian-cli set-default konspekt_pack
sleep 1

echo 'Настраиваю плагины Obsidian...'
sed -i '' -e "s|/usr/local/bin/tectonic|$tectonic_path|g" $HOME/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/usr/local/bin/pandoc|$pandoc_path|g" $HOME/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/Users/test|/Users/$USER|g" $HOME/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/usr/local/bin/pandoc|$pandoc_path|g" $HOME/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc-reference-list/data.json
sed -i '' -e "s|/Users/test|/Users/$USER|g" $HOME/Documents/konspekt_pack/.obsidian/plugins/obsidian-pandoc-reference-list/data.json

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
curl -o $HOME/.konspekt/zotmoov.zip -L https://github.com/wileyyugioh/zotmoov/releases/download/1.2.18/zotmoov-1.2.18-fx.xpi
mkdir -p $HOME/.konspekt/zotmoov
unzip $HOME/.konspekt/zotmoov.zip -d ~/.konspekt/zotmoov &> /dev/null
echo 'Загрузка плагина zotmoov завершена...'
curl -o $HOME/.konspekt/bibtex.zip -L https://github.com/retorquere/zotero-better-bibtex/releases/download/v7.0.5/zotero-better-bibtex-7.0.5.xpi
mkdir -p $HOME/.konspekt/bibtex
unzip $HOME/.konspekt/bibtex.zip -d ~/.konspekt/bibtex &> /dev/null
echo 'Загрузка плагина bibtex завершена...'

if [ ! -f $HOME/Library/Application\ Support/Zotero/profiles.ini ]; then
    echo 'Сейчас откроется окно Zotero, выйдите из него через Command+Q'
    open -a Zotero
    lsof -p $(pgrep -n zotero) +r 1 &>/dev/null
    sleep 1
fi

if [ ! -f $HOME/Zotero/zotero.sqlite ]; then
    echo "Копирую библиотеку Zotero..."
    cp $HOME/.konspekt/zotero.sqlite /Users/$USER/Zotero/zotero.sqlite
else
    fdate=$(date +%Y%m%d-%H%M%S)
    mv /Users/$USER/Zotero/zotero.sqlite /Users/$USER/Zotero/zotero_$fdate.sqlite
    echo "Существующая база Зотеро сохранена как ~/Zotero/zotero_$fdate.sqlite. Вы можете восстановить её, если необходимо, удалив _$fdate в названии этого файла."
    cp $HOME/.konspekt/zotero.sqlite /Users/$USER/Zotero/zotero.sqlite
    echo "Новая библиотека Зотеро установлена вместо существующей"
fi

echo 'Устанавливаю и настраиваю плагины Zotero...'
zotero_profile_name=$(grep 'Path=Profiles/' $HOME/Library/Application\ Support/Zotero/profiles.ini | cut -d/ -f2-)
mkdir -p /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions
cp -R $HOME/.konspekt/zotmoov /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions/zotmoov@wileyy.com
cp -R $HOME/.konspekt/bibtex /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions/better-bibtex@iris-advies.com
#echo /Users/$USER/Documents/Zotero/zotmoov >> /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions/zotmoov@wileyy.com
#echo /Users/$USER/Documents/Zotero/bibtex >> /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions/better-bibtex@iris-advies.com
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
sed -i '' -e 's|active":false,"userDisabled":true|active":true,"userDisabled":false|g' $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions.json
sleep 1
echo 'Настраиваю авто-экспорт библиотеки Zotero...'
cat $HOME/.konspekt/zotero.pref.js >> $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
sed -i '' -e "s|testuser|$(whoami)|g" $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js

echo 'Очистка временных файлов...'
rm -rf $HOME/.konspekt
echo 'Очистка временных файлов завершена'

echo 'Ещё раз откроем Zotero для финальных штрихов, закройте его через секунд 10'
open -a Zotero
lsof -p $(pgrep -n zotero) +r 1 &> /dev/null
sleep 2

echo 'Попытка настройки отображения Citation key...'
#sed -i '' -e "s|better-bibtex-iris-advies-com-citationKey","ordinal":33,"hidden":true|better-bibtex-iris-advies-com-citationKey","ordinal":33,"hidden":false|g" $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
sed -i '' -e "s|true}}}|false}}}|g" $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/treePrefs.json

echo 'Установка завершена, открываю Obsidian. Всего доброго!'
open -a obsidian
