#!/bin/bash

HOME=/home/ubuntu
EMACS=$HOME/.emacs.d
REPO=$HOME/repos
SSHFILE=id_rsa

sudo locale-gen en_GB.UTF-8

# Mount EBS
sudo mkdir -m 000 /mnt/ebs
echo "/dev/xvdf /mnt/ebs auto noatime 0 0" | sudo tee -a /etc/fstab
sudo mount /mnt/ebs

# Update for emacs repository and install all packages
sudo add-apt-repository ppa:cassou/emacs
sudo apt-get update -q
# sudo apt-get install -yq emacs24 emacs24-el emacs24-common-non-dfsg git aspell r-base ess nodejs npm tree texlive texlive-latex-extra latexmk auctex octave
sudo apt-get install -yq emacs24 emacs24-el emacs24-common-non-dfsg git aspell r-base ess nodejs npm tree auctex octave
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g express stylus jade

# Setup git, dot-files and custom
git config --global push.default simple
git config --global user.name "mkota"
git config --global user.email jg.emmanuel@outlook.com

ssh-keygen -t rsa -C "jg.emmanuel@outlook.com" -f $SSHFILE -N ""
ssh-agent /bin/bash
ssh-add ~/.ssh/$SSHFILE
cat ~/.ssh/$SSHFILE.pub

read -p "Setup github and hit ENTER"

git clone git@github.com:mkota/dotfiles.git $REPO/dotfiles
ln -sf ~/repos/dotfiles/emacs.d ~/.emacs.d
ln -sf ~/repos/dotfiles/bashrc ~/.bashrc
ln -sf ~/repos/dotfiles/bashrc_custom ~/.bashrc_custom
ln -sf ~/repos/dotfiles/profile ~/.profile
ln -sf ~/repos/dotfiles/screenrc ~/.screenrc
ln -sf ~/repos/dotfiles/octaverc ~/.octaverc
ln -sf ~/repos/dotfiles/latexmkrc ~/.latexmkrc
source ~/.profile
source ~/.bashrc

wget http://adamspiers.org/computing/elisp/smooth-scrolling.el -P $EMACS
wget https://raw.githubusercontent.com/winterTTr/ace-jump-mode/master/ace-jump-mode.el -P $EMACS
git clone https://github.com/brianc/jade-mode.git $EMACS/jade-mode

# texlive
TMP=$HOME/tmp-texlive
git clone git@github.org:mkota/aws.git $REPO/aws
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -P $TMP
tar xzvf $TMP/install-tl-unx.tar.gz -d $TMP
sudo perl $TMP/install-tl-20140417/install-tl --profile $REPO/aws/texlive.profile
rm -rf $TMP
cat<<EOF >> ~/.profile
# texlive paths
PATH=/usr/local/texlive/2013/bin/x86_64-linux:$PATH; export PATH
MANPATH=/usr/local/texlive/2013/texmf-dist/doc/man:$MANPATH; export MANPATH
INFOPATH=/usr/local/texlive/2013/texmf-dist/doc/info:$INFOPATH; export INFOPATH
EOF
source ~/.profile
sudo env PATH=$PATH tlmgr install latexmk # fix this with tlmgr internal variables

git clone git@bitbucket.org:mkota/custom.git $REPO/custom
mkdir -p ~/texmf/tex/latex
ln -sf ~/repos/custom/latex/*.sty ~/texmf/tex/latex/

# Cron
# sudo cp $REPO/aws/backup /etc/cron.hourly/
# sudo chmod +x /etc/cron.hourly/backup

echo "Init done."
