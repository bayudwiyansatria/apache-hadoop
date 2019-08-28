#!/bin/bash

echo "################################################"
echo "##  Welcom To Bayu Dwiyan Satria Installation ##"
echo "################################################"

# User Access
if [ $(id -u) -eq 0 ]; then

    echo "################################"
    echo "##  System Compability Check  ##"
    echo "################################"

    echo "Please wait! Checking System Compability";

    read -p "Enter hadoop distribution version, (NULL FOR STABLE) [ENTER] : "  version;

    if [ -z "$version" ] ; then 
        echo "Hadoop version is not specified! Installing hadoop with lastest stable version";
        distribution="stable";
        version="3.2.0"
        packages="hadoop-$version";
    else
        distribution="hadoop-$version";
        packages=$distribution;
    fi

    # Packages Available
    url=https://www-eu.apache.org/dist/hadoop/common/$distribution/$packages.tar.gz
    echo "Checking availablility hadoop $version";
    if curl --output /dev/null --silent --head --fail "$url"; then
        echo "Hadoop version is available: $url"
    else
        echo "Hadoop version isn't available: $url"
        exit 1;
    fi

    echo "Hadoop version $version install is in progress, Please keep your computer power on";

    wget https://www-eu.apache.org/dist/hadoop/common/$distribution/$packages.tar.gz -O /tmp/$packages.tar.gz;

    # System Operation Information
    if type lsb_release >/dev/null 2>&1 ; then
    os=$(lsb_release -i -s)
    elif [ -e /etc/os-release ] ; then
    os=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
    elif [ -e /etc/*-os-release ] ; then
    os=$(awk -F= '$1 == "ID" {print $3}' /etc/*-os-release)
    fi

    os=$(printf '%s\n' "$os" | LC_ALL=C tr '[:upper:]' '[:lower:]')

    read -p "Update Distro (y/n) [ENTER] (y)(Recommended): " update
    if [ $update == "y" ] ; then
        if [ $os == "ubuntu" ] ; then
            apt-get -y update && apt-get -y upgrade
        else 
            yum -y update && yum -y upgrade
        fi
    fi

    if [ $os == "ubuntu" ] ; then
        apt-get -y install git && apt-get -y install wget
    else 
        yum -y install git && yum -y install wget
    fi

    echo "################################"
    echo "## Installing Hadoop Version  ##"
    echo "################################"

    # Extraction Packages
    tar -xvf /tmp/$packages.tar.gz;
    mkdir -p /usr/local/hadoop;
    mv /tmp/$packages /usr/local/hadoop;

    # User Generator
    read -p "Enter username : " username
    read -s -p "Enter password : " password
    egrep "^$username" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        echo "$username exists!"
    else
        pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
        useradd -m -p $pass $username
        [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
    fi

    usermod -aG $username $password
    chown $username:root -R /usr/local/hadoop
    chmod g+rwx -R /usr/local/hadoop

    echo "################################"
    echo "## Hadoop Configuration Setup ##"
    echo "################################"

    read -p "Using default configuration (y/n) [ENTER] (y): " conf
    if $conf == "y" ; then
        # Configuration Variable
        configuration=(core-site.xml hdfs-site.xml httpfs-site.xml kms-site.xml mapred-site.xml yarn-site.xml);
        for xml in "${configuration[@]}"
        do 
            wget https://raw.githubusercontent.com/bayudwiyansatria/Apache-Hadoop-Environment/master/$packages/etc/hadoop/$xml -O /tmp/$xml;
        done
    fi

    echo "############################################"
    echo "## Thank You For Using Bayu Dwiyan Satria ##"
    echo "############################################"

    echo "Installed Directory /usr/local/hadoop";
    echo "Installing Hadoop $version Successfully";
    echo "User $username";
    echo "Pass $password";

else
    echo "Only root may add a user to the system"
    exit 2;
fi