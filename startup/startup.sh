#!/bin/bash

# Set this variable to "linux", "windows", or "macos"
OS="linux"

if [ "$OS" == "linux" ]; then
    # Linux installation commands

    # Update package lists
    echo "Updating package lists..."
    sudo apt update

    # Install Visual Studio Code
    echo "Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
    rm -f packages.microsoft.gpg

    # Install Git
    echo "Installing Git..."
    sudo apt install -y git

    # Install Python3
    echo "Installing Python3..."
    sudo apt install -y python3 python3-pip

    # Install Node.js
    echo "Installing Node.js..."
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs

    # Install Docker
    echo "Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER

    # Install Docker Compose
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    # Install curl
    echo "Installing curl..."
    sudo apt install -y curl

    # Install wget
    echo "Installing wget..."
    sudo apt install -y wget

    # Install zsh
    echo "Installing Zsh..."
    sudo apt install -y zsh
    # Install Oh My Zsh
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install Postman
    echo "Installing Postman..."
    sudo snap install postman

    # Install Slack
    echo "Installing Slack..."
    sudo snap install slack --classic

    # Install Vim
    echo "Installing Vim..."
    sudo apt install -y vim

    # Install Neovim
    echo "Installing Neovim..."
    sudo apt install -y neovim

    # Install Java JDK
    echo "Installing Java JDK..."
    sudo apt install -y default-jdk

    # Install Enpass
    echo "Installing Enpass..."
    wget -O - https://apt.enpass.io/keys/enpass-linux.key | sudo apt-key add -
    echo "deb https://apt.enpass.io/ stable main" | sudo tee /etc/apt/sources.list.d/enpass.list
    sudo apt update
    sudo apt install -y enpass

    # Install GCC
    echo "Installing GCC..."
    sudo apt install -y build-essential

    # Clean up
    echo "Cleaning up..."
    sudo apt autoremove -y

    echo "Installation of necessary programs completed for Linux!"

elif [ "$OS" == "windows" ]; then
    # Windows installation commands (using Chocolatey)
    echo "Installing programs on Windows..."

    # Ensure Chocolatey is installed
    if ! choco -v > /dev/null 2>&1; then
        echo "Installing Chocolatey..."
        powershell -NoProfile -ExecutionPolicy Bypass -Command \
            "Set-ExecutionPolicy AllSigned; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    fi

    # Install Visual Studio Code
    echo "Installing Visual Studio Code..."
    choco install -y vscode

    # Install Git
    echo "Installing Git..."
    choco install -y git

    # Install Python3
    echo "Installing Python3..."
    choco install -y python

    # Install Node.js
    echo "Installing Node.js..."
    choco install -y nodejs

    # Install Docker
    echo "Installing Docker..."
    choco install -y docker-desktop

    # Install Docker Compose
    echo "Installing Docker Compose..."
    choco install -y docker-compose

    # Install curl
    echo "Installing curl..."
    choco install -y curl

    # Install wget
    echo "Installing wget..."
    choco install -y wget

    # Install zsh
    echo "Installing Zsh..."
    choco install -y zsh

    # Install Oh My Zsh
    echo "Installing Oh My Zsh..."
    powershell -NoProfile -ExecutionPolicy Bypass -Command \
        "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.ps1'))"

    # Install Postman
    echo "Installing Postman..."
    choco install -y postman

    # Install Slack
    echo "Installing Slack..."
    choco install -y slack

    # Install Vim
    echo "Installing Vim..."
    choco install -y vim

    # Install Neovim
    echo "Installing Neovim..."
    choco install -y neovim

    # Install Java JDK
    echo "Installing Java JDK..."
    choco install -y openjdk

    # Install Enpass
    echo "Installing Enpass..."
    choco install -y enpass

    # Install GCC (mingw)
    echo "Installing GCC (mingw)..."
    choco install -y mingw

    echo "Installation of necessary programs completed for Windows!"

elif [ "$OS" == "macos" ]; then
    # macOS installation commands (using Homebrew)
    echo "Installing programs on macOS..."

    # Ensure Homebrew is installed
    if ! brew -v > /dev/null 2>&1; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install Visual Studio Code
    echo "Installing Visual Studio Code..."
    brew install --cask visual-studio-code

    # Install Git
    echo "Installing Git..."
    brew install git

    # Install Python3
    echo "Installing Python3..."
    brew install python

    # Install Node.js
    echo "Installing Node.js..."
    brew install node

    # Install Docker
    echo "Installing Docker..."
    brew install --cask docker
    open /Applications/Docker.app

    # Install Docker Compose
    echo "Installing Docker Compose..."
    brew install docker-compose

    # Install curl
    echo "Installing curl..."
    brew install curl

    # Install wget
    echo "Installing wget..."
    brew install wget

    # Install zsh
    echo "Installing Zsh..."
    brew install zsh
    # Install Oh My Zsh
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install Postman
    echo "Installing Postman..."
    brew install --cask postman

    # Install Slack
    echo "Installing Slack..."
    brew install --cask slack

    # Install Vim
    echo "Installing Vim..."
    brew install vim

    # Install Neovim
    echo "Installing Neovim..."
    brew install neovim

    # Install Java JDK
    echo "Installing Java JDK..."
    brew install openjdk

    # Install Enpass
    echo "Installing Enpass..."
    brew install --cask enpass

    # Install GCC
    echo "Installing GCC..."
    brew install gcc

    echo "Installation of necessary programs completed for macOS!"

else
    echo "Unsupported OS specified. Please set OS variable to 'linux', 'windows', or 'macos'."
fi
