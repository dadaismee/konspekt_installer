#!/bin/zsh

# bold=$(tput bold)
# normal=$(tput sgr0)

# Install Homebrew if not installed
# echo "${bold}Проверяем, установлен ли Homebrew..."
echo "Проверяем, установлен ли Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew не найден. Устанавливаем . . ."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ ! -f /Users/$USER/.zprofile ]; then
    echo >> /Users/$USER/.zprofile
fi
arch=$(sysctl -n machdep.cpu.brand_string |cut -w -f1)
if ! grep 'brew shellenv' /Users/$USER/.zprofile &> /dev/null; then
    if [[ $arch = "Apple" ]]; then echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$USER/.zprofile; else echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/$USER/.zprofile; fi
fi
source ~/.zprofile
brew_path=$(which brew)
if [[ $brew_path = "brew not found" ]]; then echo "Не удалось установить Homebrew. Возможно, вам следует отключить или включить ваш VPN, или же подключиться к другой точке доступа / мобильной сети. Попробуем ещё раз."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; source ~/.zprofile; brew_path=$(which brew); fi

# Installing packages

which pandoc &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка Pandoc . . .'
    brew install pandoc
else
    echo "Pandoc уже установлен."
fi
pandoc_path=$(which pandoc)
if [[ $pandoc_path = "pandoc not found" ]]; then echo "Не удалось установить Pandoc. Возможно, вам следует отключить или включить ваш VPN, или же подключиться к другой точке доступа / мобильной сети. Попробуем ещё раз."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; brew install pandoc; pandoc_path=$(which pandoc); fi

which tectonic &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка Tectonic . . .'
    brew install tectonic
else
    echo "Tectonic уже установлен."
fi
tectonic_path=$(which tectonic)
if [[ $tectonic_path = "tectonic not found" ]]; then echo "Не удалось установить tectonic. Возможно, вам следует отключить или включить ваш VPN, или же подключиться к другой точке доступа / мобильной сети. Попробуем ещё раз."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; brew install tectonic; tectonic_path=$(which tectonic); fi

# ls -l /Applications |grep Zettlr &> /dev/null
# if [ $? -ne 0 ]; then
#    echo 'Установка Zettlr...'
#    brew install --cask zettlr
# else
#    echo "Zettlr уже установлен."
# fi

ls -l /Applications |grep Obsidian &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка Obsidian . . .'
    brew install --cask obsidian
else
    echo "Obsidian уже установлен."
fi
obsidian_path=$(ls /Applications |grep Obsidian)
if [[ $obsidian_path = "" ]]; then echo "Не удалось установить Obsidian. Возможно, вам следует отключить или включить ваш VPN, или же подключиться к другой точке доступа / мобильной сети. Попробуем ещё раз."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; brew install --cask obsidian; obsidian_path=$(ls /Applications |grep Obsidian); fi

which obsidian-cli &> /dev/null
if [ $? -ne 0 ]; then
    echo 'Установка obsidian-cli . . .'
    brew tap yakitrak/yakitrak
    brew install yakitrak/yakitrak/obsidian-cli
else
    echo "obsidian-cli уже установлен."
fi
obcli_path=$(which obsidian-cli)
if [[ $obcli_path = "obsidian-cli not found" ]]; then echo "Не удалось установить obsidian-cli. Возможно, вам следует отключить или включить ваш VPN, или же подключиться к другой точке доступа / мобильной сети. Попробуем ещё раз."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; brew tap yakitrak/yakitrak; brew install yakitrak/yakitrak/obsidian-cli; obcli_path=$(which obsidian-cli); fi

echo 'Клонируем репозиторий с настройками Obsidian . . .'
rm -rf $HOME/.konspekt
git clone https://github.com/dadaismee/konspekt-research-pack.git $HOME/.konspekt
if [ ! -f $HOME/.konspekt/obsidian.json ]; then	echo "Произошла ошибка при клонировании репозитория с настройками Obsidian. Проверьте подключение к интернету."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; git clone https://github.com/dadaismee/konspekt-research-pack.git $HOME/.konspekt; fi

echo "Сейчас все окна Obsidian будут закрыты."
echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null
killall Obsidian
sleep 1
if [ ! -d $HOME/research_pack ]; then
    cp -R $HOME/.konspekt/research_pack $HOME
    echo "Файлы хранилища Obsidian скопированы"
else
    echo "Файлы хранилища Obsidian уже на месте, сохраним их под другим именем . . ."
    fdate=$(date +%Y%m%d-%H%M%S)
    mv $HOME/research_pack $HOME/research_pack_$fdate
    echo "Файлы хранилища с таким же названием были перемещены"
    cp -R $HOME/.konspekt/research_pack $HOME
    echo "Файлы хранилища Obsidian скопированы"
fi

mkdir -p $HOME/Library/Application\ Support/obsidian
if [ ! -f $HOME/Library/Application\ Support/obsidian/obsidian.json ]; then
    echo "Конфиг Obsidian не найден. Используем нашу заготовку . . ."
    cp $HOME/.konspekt/obsidian.json $HOME/Library/Application\ Support/obsidian/
    sed -i '' -e "s|test|$(whoami)|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
else
    # if grep -q research_pack $HOME/Library/Application\ Support/obsidian/obsidian.json; then
        # echo "Хранилище Obsidian с именем research_pack уже существует"
        #echo "Переименуем его во избежание конфликтов"
        # fdate=$(date +%Y%m%d-%H%M%S)
        # mv $HOME/Library/Application\ Support/obsidian/obsidian.json $HOME/Library/Application\ Support/obsidian/obsidian_$fdate.json
        # echo "Старый конфиг хранилищ был переименован в obsidian_$fdate.json"
        # cp $HOME/.konspekt/obsidian.json $HOME/Library/Application\ Support/obsidian/
        # sed -i '' -e "s|test|$(whoami)|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
		# echo "При необходимости просто снова добавьте ваше старое хранилище вручную"
    # else
        # echo "Добавим новое хранилище Obsidian в существующий конфиг . . ."
		# sed -i '' -e "s|,"open":true}|}|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
        # sed -i '' -e "s|}}}|}, \"8095a1a7a15b1e3d\":{\"path\":\"/Users/$USER/research_pack\",\"ts\":1739264225722,\"open\":true}},\"showReleaseNotes\":false}|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
        # sed -i '' -e "s|}},|}, \"8095a1a7a15b1e3d\":{\"path\":\"/Users/$USER/research_pack\",\"ts\":1739264225722,\"open\":true}},\"showReleaseNotes\":false}|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
    # fi
    echo "Как минимум одно хранилище Obsidian уже существует"
    echo "Переименуем его во избежание конфликтов"
    fdate=$(date +%Y%m%d-%H%M%S)
    mv $HOME/Library/Application\ Support/obsidian/obsidian.json $HOME/Library/Application\ Support/obsidian/obsidian_$fdate.json
    echo "Старый конфиг хранилищ был переименован в obsidian_$fdate.json"
    cp $HOME/.konspekt/obsidian.json $HOME/Library/Application\ Support/obsidian/
    sed -i '' -e "s|test|$(whoami)|g" $HOME/Library/Application\ Support/obsidian/obsidian.json
    echo "При необходимости просто снова добавьте ваше старое хранилище вручную"
fi


obsidian-cli set-default research_pack
sleep 1

echo 'Настраиваю плагины Obsidian . . .'
sed -i '' -e "s|/usr/local/bin/tectonic|$tectonic_path|g" $HOME/research_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/usr/local/bin/pandoc|$pandoc_path|g" $HOME/research_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/Users/test|/Users/$USER|g" $HOME/research_pack/.obsidian/plugins/obsidian-pandoc/data.json
sed -i '' -e "s|/usr/local/bin/pandoc|$pandoc_path|g" $HOME/research_pack/.obsidian/plugins/obsidian-pandoc-reference-list/data.json
sed -i '' -e "s|/Users/test|/Users/$USER|g" $HOME/research_pack/.obsidian/plugins/obsidian-pandoc-reference-list/data.json

open -a Obsidian
echo 'Сейчас откроется Obsidian, нажмите "Доверять автору" (если будет такой запрос) и закройте приложение через Command+Q'
sleep 2
lsof -p $(pgrep -n Obsidian) +r 1 &> /dev/null
sleep 2

ls -l /Applications |grep Zotero &> /dev/null
if [ $? -ne 0 ]; then
	echo 'Установка Zotero...'
	brew install --cask zotero
else
	echo "Zotero уже установлен."
fi
zotero_path=$(ls /Applications |grep Zotero)
if [[ $zotero_path = "" ]]; then echo "Не удалось установить Zotero. Возможно, вам следует отключить или включить ваш VPN, или же подключиться к другой точке доступа / мобильной сети. Попробуем ещё раз."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; brew install --cask zotero; zotero_path=$(ls /Applications |grep Zotero); fi

echo 'Загрузка плагинов Zotero . . .'
curl -o $HOME/.konspekt/zotmoov.zip -L https://github.com/wileyyugioh/zotmoov/releases/download/1.2.18/zotmoov-1.2.18-fx.xpi
if [ ! -f $HOME/.konspekt/zotmoov.zip ]; then echo "Произошла ошибка при загрузке плагина zotmoov. Проверьте подключение к интернету."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; curl -o $HOME/.konspekt/zotmoov.zip -L https://github.com/wileyyugioh/zotmoov/releases/download/1.2.18/zotmoov-1.2.18-fx.xpi; fi
echo 'Загрузка плагина zotmoov завершена';
mkdir -p $HOME/.konspekt/zotmoov
unzip $HOME/.konspekt/zotmoov.zip -d ~/.konspekt/zotmoov &> /dev/null

curl -o $HOME/.konspekt/bibtex.zip -L https://github.com/retorquere/zotero-better-bibtex/releases/download/v7.0.5/zotero-better-bibtex-7.0.5.xpi
if [ ! -f $HOME/.konspekt/bibtex.zip ]; then echo "Произошла ошибка при загрузке плагина bibtex. Проверьте подключение к интернету."; echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null; $HOME/.konspekt/bibtex.zip -L https://github.com/retorquere/zotero-better-bibtex/releases/download/v7.0.5/zotero-better-bibtex-7.0.5.xpi; fi
echo 'Загрузка плагина bibtex завершена'
mkdir -p $HOME/.konspekt/bibtex
unzip $HOME/.konspekt/bibtex.zip -d ~/.konspekt/bibtex &> /dev/null

echo "Сейчас все окна Zotero будут закрыты."
echo "Нажмите Enter, когда будете готовы . . ."; read -s &>/dev/null
killall Zotero
sleep 1
if [ -f $HOME/Zotero/zotero.sqlite ]; then
    echo "Копирую библиотеку Zotero..."
    fdate=$(date +%Y%m%d-%H%M%S)
    mv /Users/$USER/Zotero/zotero.sqlite /Users/$USER/Zotero/zotero_$fdate.sqlite
    echo "Существующая база Зотеро сохранена как ~/Zotero/zotero_$fdate.sqlite. Вы можете восстановить её, если необходимо, удалив _$fdate в названии этого файла."
    sleep 1
fi

if [ ! -f $HOME/Library/Application\ Support/Zotero/profiles.ini ]; then
    echo 'Сейчас откроется окно Zotero, выйдите из него через Command+Q'
    open -a Zotero
    sleep 2
    lsof -p $(pgrep -n zotero) +r 1 &>/dev/null
    sleep 2
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
echo 'user_pref("extensions.zotmoov.dst_dir", "/Users/'$USER'/research_pack/07 service/literature PDF");' >> /Users/$USER/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
echo 'Окно Zotero откроется для установки плагинов, выйдите из него через Command+Q'
open -a Zotero
sleep 2
lsof -p $(pgrep -n zotero) +r 1 &> /dev/null
sleep 2
echo 'Активирую плагины Zotero...'
sed -i '' -e 's|active":false,"userDisabled":true|active":true,"userDisabled":false|g' $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/extensions.json
sleep 2
echo 'Настраиваю авто-экспорт библиотеки Zotero...'
cat $HOME/.konspekt/zotero.pref.js >> $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
sed -i '' -e "s|testuser|$(whoami)|g" $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js

echo 'Очистка временных файлов...'
rm -rf $HOME/.konspekt
echo 'Очистка временных файлов завершена'

echo 'Ещё раз откроем Zotero для финальных штрихов, закройте его через секунд 10'
open -a Zotero
sleep 2
lsof -p $(pgrep -n zotero) +r 1 &> /dev/null
sleep 2

echo 'Попытка настройки отображения Citation key...'
#sed -i '' -e "s|better-bibtex-iris-advies-com-citationKey","ordinal":33,"hidden":true|better-bibtex-iris-advies-com-citationKey","ordinal":33,"hidden":false|g" $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/prefs.js
sed -i '' -e "s|true}}}|false}}}|g" $HOME/Library/Application\ Support/Zotero/Profiles/$zotero_profile_name/treePrefs.json

echo 'Установка завершена, открываю Obsidian. Всего доброго!'
open -a obsidian
