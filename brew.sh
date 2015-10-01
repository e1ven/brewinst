#!/bin/bash
# Script to install homebrew. 
# Uses an alternative subdirectory to avoid SIP issues, and a group for multi-user installs.
# MIT Licensed

# Detect if this is being run with sudo.
if [ `whoami` != 'root' ]
then
  echo "Please run this script with sudo."
  exit 1
fi

# Detect if command line tools are installed
if [ ! -f /usr/bin/git ]
then
  echo "Installing the Command Line Tools."
  echo "Please accept the GUI prompt, and press ENTER when it is complete.."
  xcode-select --install
  read
fi

# Detect if we already have a homebrew group
dscl . -list /Groups PrimaryGroupID | grep homebrew > /dev/null
if [ "$?" -ne 0 ]
then
  echo "Creating group for Homebrew"
  HIGHEST_GROUP_ID=$(dscl . -list /Groups PrimaryGroupID | awk '{print $2}' | sort -ug | tail -1)
  GROUP_ID=$((HIGHEST_GROUP_ID+1))
  sudo dscl . create /Groups/homebrew PrimaryGroupID $GROUP_ID
fi

sudo dseditgroup -o edit -a `logname` -t user homebrew

echo "Creating Homebrew directories"
mkdir -p /usr/local/homebrew
chgrp homebrew /usr/local/homebrew

chgrp -R homebrew /usr/local/homebrew
chmod -R g+w /usr/local/homebrew

mkdir -p /Library/Caches/Homebrew 
chgrp -R homebrew /Library/Caches/Homebrew 
sudo chmod -R g+w /Library/Caches/Homebrew


echo "Installing Homebrew"
cd /usr/local/homebrew
if [ -d /usr/local/homebrew/.git ]
then
  git pull origin master
else
  git clone --depth 1 https://github.com/Homebrew/homebrew.git /usr/local/homebrew
fi

echo "Adding homebrew to path"
echo /usr/local/homebrew/bin > /etc/paths.d/homebrew
PATH=$PATH:/usr/local/homebrew/bin

