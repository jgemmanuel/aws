#!/bin/bash

while true; do
    read -p "Provide your email for the configuration: " EMAIL
    echo "You entered: $EMAIL"
    read -p "Should I proceed? [y/n/q]: " yn
    case $yn in
	[Yy]* ) break;;
	[Nn]* ) continue;;
	[Qq]* ) kill -SIGINT $$;;
	* ) echo "***Error: answer [y]es, [n]o, or [q]uit.";;
    esac
done

HOME=/home/ubuntu
EBS=/mnt/ebs
EMACS=$HOME/.emacs.d
REPO=$HOME/repos
SSHFILE=id_rsa

sudo locale-gen en_GB.UTF-8

# Mount EBS
sudo mkdir -m 000 $EBS
echo "/dev/xvdf /mnt/ebs auto noatime 0 0" | sudo tee -a /etc/fstab
sudo mount $EBS

# Update for emacs repository and install all packages
sudo add-apt-repository ppa:cassou/emacs
sudo aptitude update -q
sudo aptitude install -yq emacs24 emacs24-el emacs24-common-non-dfsg git aspell r-base ess nodejs npm tree octave
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g express-generator stylus jade nodemon

# Setup git, dot-files and custom
git config --global push.default simple
git config --global user.name "mkota"
git config --global user.email $EMAIL

ssh-keygen -t rsa -f $SSHFILE -N "" -C $EMAIL
ssh-agent /bin/bash
ssh-add ~/.ssh/$SSHFILE
cat ~/.ssh/$SSHFILE.pub

read -p "Setup github and hit ENTER"

git clone git@github.com:mkota/dotfiles.git $REPO/dotfiles
ln -sf $REPO/dotfiles/bashrc_custom ~/.bashrc_custom
ln -sf $REPO/dotfiles/emacs.d $EMACS
ln -sf $REPO/dotfiles/screenrc ~/.screenrc
ln -sf $REPO/dotfiles/latexmkrc ~/.latexmkrc
ln -sf $REPO/dotfiles/octaverc ~/.octaverc

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
sudo env PATH=$PATH tlmgr install latexmk # fix this with tlmgr internal variables. also add standalone installation.

git clone git@bitbucket.org:mkota/custom.git $REPO/custom
mkdir -p ~/texmf/tex/latex
ln -sf $REPO/custom/latex/*.sty ~/texmf/tex/latex/

# Cron
# sudo cp $REPO/aws/backup /etc/cron.hourly/
# sudo chmod +x /etc/cron.hourly/backup

# Environment variables et al
cat<<EOF >> ~/.profile

## Custom

export SUDO_EDITOR=/usr/bin/emacs
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB:en_US:en"

# texlive paths
PATH=/usr/local/texlive/2013/bin/x86_64-linux:$PATH; export PATH
MANPATH=/usr/local/texlive/2013/texmf-dist/doc/man:$MANPATH; export MANPATH
INFOPATH=/usr/local/texlive/2013/texmf-dist/doc/info:$INFOPATH; export INFOPATH
EOF
cat<<EOF >> .bashrc

# Custom
if [ -f ~/.bashrc_custom ]; then
    . ~/.bashrc_custom
fi
EOF
source ~/.profile
source ~/.bashrc

echo "Init done."
