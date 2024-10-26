#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

ask_install() {
    while true; do
        echo -e "${GREEN}Do you want to install $1? (y/n)${NC}"
        read -r ans
        case $ans in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

install_snap() {
    print_header "Installing $1"
    sudo snap install "$2" "${3:---classic}"
}

update_system() {
    print_header "Updating System"
    sudo apt update -y
    sudo apt upgrade -y
}

configure_git() {
    print_header "Configuring Git"
    echo "Enter your GitHub username:"
    read -r username
    git config --global user.name "$username"
    
    echo "Enter your GitHub email:"
    read -r email
    git config --global user.email "$email"
    echo "Git configured successfully!"
}

setup_vision_env() {
    print_header "Setting up Computer Vision Environment"
    if ask_install "Computer Vision Environment (OpenCV, PyTorch, TensorFlow, etc.)"; then
        source ~/miniconda3/etc/profile.d/conda.sh
        conda create -n vision python=3.8 -y
        conda activate vision
        conda install -y -c conda-forge -c pytorch \
            opencv \
            pillow \
            scikit-image \
            matplotlib \
            imageio \
            open3d \
            pyvista \
            vtk \
            pytorch \
            torchvision \
            torchaudio \
            pandas
        conda deactivate
        echo -e "${GREEN}Vision environment created successfully!${NC}"
        echo -e "${BLUE}To activate: conda activate vision${NC}"
    fi
}

install_development_tools() {
    print_header "Development Tools Installation"
    
    if ask_install "Git"; then
        sudo apt install git libz-dev libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc -y
        configure_git
    fi
    
    if ask_install "Visual Studio Code"; then
        sudo snap install code --classic
    fi
    
    if ask_install "Miniconda"; then
        wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.10.3-Linux-x86_64.sh --no-check-certificate
        bash ./Miniconda3-py38_4.10.3-Linux-x86_64.sh
        rm ./Miniconda3-py38_4.10.3-Linux-x86_64.sh
        source ~/miniconda3/etc/profile.d/conda.sh
        setup_vision_env
    fi
}

install_browsers() {
    print_header "Web Browsers Installation"
    
    if ask_install "Google Chrome"; then
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb --no-check-certificate
        sudo apt install ./google-chrome-stable_current_amd64.deb
        rm google-chrome-stable_current_amd64.deb
    fi
    
    if ask_install "Brave Browser"; then
        sudo apt install apt-transport-https curl -y
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        sudo apt update
        sudo apt install brave-browser -y
    fi
}

install_system_utilities() {
    print_header "System Utilities Installation"
    
    sudo apt install -y \
        nvtop \
        tmux \
        net-tools \
        openssh-server \
        gnome-tweak-tool \
        gnome-shell-extensions \
        chrome-gnome-shell
    
    if ask_install "Multi-touch trackpad gestures"; then
        if [ -f ./fusuma-config.sh ] && [ -f ./fusuma-config2.sh ]; then
            bash ./fusuma-config.sh
            bash ./fusuma-config2.sh
        else
            echo "Fusuma configuration scripts not found!"
        fi
    fi
}

clear
echo -e "${GREEN}Welcome to Ubuntu System Setup Script${NC}"
echo -e "${RED}Note: This script will install and configure various applications on your Ubuntu system.${NC}"
echo -e "${RED}Make sure you have a stable internet connection before proceeding.${NC}"
echo ""
read -p "Press Enter to continue..."

update_system
install_development_tools
install_browsers
install_system_utilities

print_header "Cleaning Up"
sudo apt autoremove -y
sudo apt autoclean -y

print_header "Setup Complete!"
echo -e "${GREEN}Your system has been successfully configured!${NC}"
echo -e "${BLUE}Please restart your system to ensure all changes take effect.${NC}"