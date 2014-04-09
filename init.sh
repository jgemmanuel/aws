#!/bin/bash

HOME=/home/ubuntu
EMACS=$HOME/.emacs.d
REPO=$HOME/repos

sudo locale-gen en_GB.UTF-8

# Mount EBS
sudo mkdir -m 000 /mnt/ebs
echo "/dev/xvdb /mnt/ebs auto noatime 0 0" | sudo tee -a /etc/fstab
sudo mount /mnt/ebs

# Emacs
sudo add-apt-repository ppa:cassou/emacs
sudo apt-get update -qy
sudo apt-get install -y emacs24 emacs24-el emacs24-common-non-dfsg

# Install everything else
sudo apt-get install -y git aspell r-base ess nodejs npm tree texlive auctex octave
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g express stylus jade

# Setup git, dot-files and custom
git config --global push.default simple
git config --global user.name "mkota"
git config --global user.email jg.emmanuel@outlook.com

ssh-keygen -t rsa -C "jg.emmanuel@outlook.com"
ssh-agent /bin/bash
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub

read -p "Setup github and hit ENTER"

git clone git@github.com:mkota/dotfiles.git $REPO
ln -sf ~/repos/dotfiles/emacs.d ~/.emacs.d
ln -sf ~/repos/dotfiles/bashrc ~/.bashrc
ln -sf ~/repos/dotfiles/bashrc_custom ~/.bashrc_custom
ln -sf ~/repos/dotfiles/profile ~/.profile
ln -sf ~/repos/dotfiles/screenrc ~/.screenrc
ln -sf ~/repos/dotfiles/octaverc ~/.octaverc
source ~/.profile
source ~/.bashrc

wget http://adamspiers.org/computing/elisp/smooth-scrolling.el -P $EMACS
wget https://raw.githubusercontent.com/winterTTr/ace-jump-mode/master/ace-jump-mode.el -P $EMACS
wget http://orgmode.org/org-8.2.5h.tar.gz -P $EMACS
tar xzvf $EMACS/org-8.2.5h.tar.gz
rm -f $EMACS/org-8.2.5h.tar.gz

git clone git@bitbucket.org:mkota/custom.git $REPO
mkdir -p ~/texmf/tex/latex
ln -sf ~/repos/custom/latex/*.sty ~/texmf/tex/latex/

# Cron
git clone git@github.org:mkota/aws.git $REPO
sudo cp $REPO/aws/backup /etc/cron.hourly/
sudo chmod +x /etc/cron.hourly/backup

echo "Init done."
