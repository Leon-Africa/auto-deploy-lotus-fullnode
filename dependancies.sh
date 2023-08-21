#!/bin/bash

function escalte_and_update () {
    echo "Escalate Privileges"
    sudo apt update 
    install_apt_transport
}

function install_apt_transport (){
       sudo apt-get install apt-transport-https ca-certificates
}

function is_ubuntu () {

echo "Ensure that the system is Ubuntu"

    CHECK=$(cat /etc/issue)
    if [ -z "$CHECK" ]
    then
        echo "The current automation is specifically for Ubuntu Machines. Please run this program from Ubuntu."
        echo "Exiting the program...."
        exit 0
    else
        escalte_and_update
    fi
}

function check_python3 () {

    echo "Ensuring that Python3 is installed"
   
        if [[ "$(python3 -V)" =~ "Python 3" ]] ; then
        echo "Python 3 is installed"
        else
        sudo apt-get install python3
        fi
        
}

function check_go () {
    echo "Ensuring that go is installed"

    CHECK=$(which go)
       if [ -z "$CHECK" ]
    then
      echo "Installing go"
      sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
      sudo export PATH=$PATH:/usr/local/go/bin
    else
      echo "Go is installed"
    fi
}

function install_terraform () {

    echo "Installing Terraform"
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
        gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update
        sudo apt-get install terraform
}

function install_ansible () {
    echo "Installing Ansible"

    sudo apt install software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible
}

function install_metal_cli () {
    go install github.com/equinix/metal-cli/cmd/metal@latest
    export PATH=$PATH:$HOME/go/bin
    source <(metal completion bash)
}

function configure_matal_cli () {
    metal init
}

function confirm_dependancies () {
    python3 --version
    go version
    terraform version
    ansible --version
    metal organization get
}

#Bash run order
main() {
    echo "Installing required dependancies for preparation of automated deployment of lotus node"

    is_ubuntu

    check_python3

    check_go

    install_terraform

    install_ansible  

    install_metal_cli

    configure_matal_cli

    confirm_dependancies
}

#runs here
main


