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