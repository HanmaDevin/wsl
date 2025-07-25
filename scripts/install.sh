#! /bin/bash
#    ____           __        ____   _____           _       __
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/
#                                                  /_/
clear

location="$HOME/wsl"

installPackages() {
    sudo apt install -y $(cat "$location/packages.txt")
}

copy_config() {
  gum spin --spinner dot --title "Creating bakups..." -- sleep 2

  if [[ -f "$HOME/.zshrc" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi

  if [[ -d "$HOME/.config" ]]; then
    mv "$HOME/.config" "$HOME/.config.bak"
  fi
  cp -r "$location/.config/" "$HOME/"

  cp "$location/.zshrc" "$HOME/"

  sudo cp "$location/scripts/pullall" "/usr/bin"
  sudo cp "$location/superfile_app/spf" "/usr/bin"
}

configure_git() {
  echo "Want to configure git?"
  gitconfig=$(gum choose "Yes" "No")
  if [[ "$gitconfig" == "Yes" ]]; then

    username=$(gum input --prompt "> What is your github user name?")
    git config --global user.name "$username"
    useremail=$(gum input --prompt "> What is your github email?")
    git config --global user.email "$useremail"
    git config --global pull.rebase true
  fi

  echo "Want to create a ssh-key?"
  ssh=$(gum choose "Yes" "No")
  if [[ "$ssh" == "Yes" ]]; then
    ssh-keygen -t ed25519 -C "$useremail"
  fi

  echo "Want to create a physical key?"
  key=$(gum choose "Yes" "No")
  if [[ $key == "Yes" ]]; then
    read -r -p "Insert a device like a YubiKey and press enter..."
    ssh-keygen -t ecdsa-sk -b 521
  fi
}

MAGENTA='\033[0;35m'
NONE='\033[0m'

# Header
echo -e "${MAGENTA}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF

echo "WSL Setup"
echo -e "${NONE}"

sudo apt full-upgrade
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update

installPackages

gum spin --spinner dot --title "Starting setup now..." -- sleep 2
copy_config
configure_git

curl -o- https://fnm.vercel.app/install | bash
curl -sSf https://sh.rustup.rs | sh
curl -fsSL https://ollama.com/install.sh | sh

echo -e "${MAGENTA}"
cat <<"EOF"
____             
| __ ) _   _  ___ 
|  _ \| | | |/ _ \
| |_) | |_| |  __/
|____/ \__, |\___|
       |___/      
EOF
echo -e "${NONE}"

