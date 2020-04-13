#!/bin/bash

apt-get update
apt-get upgrade
apt-get install git gcc make pkg-config libx11-dev libxtst-dev libxi-dev

########################
### enhance keyboard ###
###  using caps2esc  ###

sudo apt-get install cmake libyaml-cpp-dev build-essential libudev-dev libevdev-dev
#note libevdev is required.  On the package on Fedora is called `libevdev-devel`.  `libevdev` is not available and `libevdev2` is already installed (but doesn't provide libudev.h file) and a `libevdev-dev` is available but websearch reveals that `libudev-dev` contains the libudev.h file which makes sense.  After installing libudev-dev, libevdev.h file is missing.
cd bin 
git clone git@gitlab.com:interception/linux/tools.git
cd tools && mkdir build && cd build
cmake ..
make
#sudo mv -t /usr/bin intercept udevmon uinput
sudo make install
cd ../..
git clone git@gitlab.com:interception/linux/plugins/caps2esc.git
cd caps2esc && mkdir build && cdbuild
cmake ..
make
#sudo mv caps2esc /usr/bin/
sudo make install
#then create/edit some config files according to steps 3,4,5 at https://askubuntu.com/questions/979359/how-do-i-install-caps2esc

##### end caps2esc #####
########################


sudo apt-get install xclip
sudo apt-get install gimp inkscape scribus
sudo apt-get install tig
apt-get install tree peco

sudo apt-get install inotify-tools httpie curl
apt-get install zsh
chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# reboot computer for shell to change
sudo apt-get install fonts-powerline
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

#git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
ln -s dotfiles/.zshrc .zshrc

apt-get install tmux
ln -s dotfiles/.tmux.conf .tmux.conf
sudo gem install tmuxinator

sudo apt-get install ack-grep

apt-get install vim-gtk3
# @TODO vim solution for viewing csv files in tabular layout such as https://github.com/dhruvasagar/vim-table-mode
# @TODO install XSV tool for csv manipulation https://github.com/BurntSushi/xsv

# requirements for youcompleteme vim plugin:
sudo apt install build-essential cmake #note: "dev" is scarry :endnote# python3-dev
# note there might be better way to install python3... `python3-dev` may not be needed as we're on super old python3

# @TODO (possibly)
# use https://github.com/asdf-vm/asdf
# for **extendable** version management replacing nvm, pyenv, etc
# possibly use `pyenv` for python version management https://github.com/pyenv/pyenv
# https://realpython.com/intro-to-pyenv/
# https://github.com/pyenv/pyenv/issues/1054

git clone youcompleteme #into ~/.vim/bundle
cd youcompleteme
git submodule update --init --recursive
python3 install.py
# @TODO does vim have tagbar plugin?

apt-get install ctags #TODO:
# use universal ctags instead
# https://github.com/universal-ctags/ctags


cd ~/bin && git clone https://github.com/rupa/z && rm -rf z/.git

########################
### Handbuild Server ###

sudo apt-get install php php-xml libapache2-mod-php7.0 php7.0-sqlite3 php-mysql php-gd php-curl php-mbstring php-zip
sudo apt-get install mysql-server
sudo apt-get install apache2
sudo a2enmod rewrite
# geez, wtf re: threading!
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork
# end of threading hack
sudo apt-get install php-pear
sudp apt-get install php-dev
sudo echo '; ahillio custom config:' >> /etc/php/7.???/apache2/php.ini
sudo pecl install xdebug
find /usr -name 'xdebug.so' #returns: /usr/lib/php/20151012/xdebug.so
sudo echo 'zend_extension="/usr/lib/php/20151012/xdebug.so"' >> /etc/php/7.0/apache2/php.ini
sudo echo 'xdebug.idekey="xdebug"' >> /etc/php/7.0/apache2/php.ini
sudo echo 'xdebug.remote_enable=on' >> /etc/php/7.0/apache2/php.ini
sudo echo 'xdebug.remote_handler=dbgp' >> /etc/php/7.0/apache2/php.ini
sudo echo 'xdebug.remote_host=localhost' >> /etc/php/7.0/apache2/php.ini
sudo echo 'xdebug.remote_port=9000' >> /etc/php/7.0/apache2/php.ini
# and configure chromium xdebug extension to use PHPSTORM ide key
sudo vi /etc/apache2/apache2.conf # &then s/None/All for AllowOverride in the /var/www directory.
sudo usermod -a -G www-data alec

#? sudo echo 'ServerName 127.0.0.1' >> /etc/apache2/apache2.conf
# sendmail and postfix are for production servers
# sudo apt-get install sendmail
# sudo sendmailconfig // and choose yes for each prompt
# apt-get install postfix
# ssmtp is sufficient for local dev
sudo apt-get install ssmtp
# configure ssmtp:
sudo vi /etc/ssmtp/ssmtp.conf
# add the following:
#root=accounts@ahill.io
#mailhub=smtp.sendgrid.net:587
#rewriteDomain=
#UseTLS=YESUseSTARTTLS=YES
#AuthUser=ahillio
#AuthPass=<enter password here>
#FromLineOverride=YES
sudo vi /etc/ssmtp/revaliases
# add the following:
#root:accounts@ahill.io:smtp.sendgrid.net:587
#alec:accounts@ahill.io:smtp.sendgrid.net:587
# to test ssmtp:
ssmtp -v web@ahill.io
# then after hitting enter you'll get a blank line
# type some text to send via email
# then hit [Ctrl]+[D]

sudo service apache2 restart

wget https://git.io/psysh && chmod +x psysh && sudo mv psysh /usr/local/bin/
wget http://psysh.org/manual/en/php_manual.sqlite
sudo mkdir /usr/local/share/psysh
sudo mv php_manual.sqlite /usr/local/share/psysh


### End Handbuilt Server ###
############################

####################
### Install DDEV ###

curl -L https://raw.githubusercontent.com/drud/ddev/master/scripts/install_ddev.sh | bash
# needed for mkcert i think
sudo apt install libnss3-tools
# mkcert for local ssl - get binary file from https://github.com/FiloSottile/mkcert/releases
wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 && mv mkcert-v1.4.1-linux-amd64 ~/bin/mkcert && chmod +x ~/bin/mkcert
mkcert -install
# composer steps:
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
# verify fingerprint https://docs.docker.com/install/linux/docker-ce/ubuntu/
# using $(lsb_release) with Linux Mint does not work
# sudo add-apt-repository \
#   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) \
#   stable"
# with Mint, use "Xenial" instead :/
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
wget https://github.com/docker/compose/releases/download/1.25.1/docker-compose-Linux-x86_64
sudo chmod +x docker-compose-Linux-x86_64
sudo mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose

sudo groupadd docker
sudo usermod -aG docker $USER
# then log out & back in for new group to be applied.
# or do:
newgrp docker

### end DDEV ###
################



sudo apt-get install texlive-latex-base texlive-fonts-recommended texlive-fonts-extra python-pygments texlive-latex-extra texlive-extra-utils
# re: pip.... see yenv?
sudo apt-get install python-pip python3-pip
pip install --upgrade pip #???
pip install Pygments
apt-get install python-setuptools python3-setuptools
pip3 install pygments-style-solarized

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install nodejs
sudo npm install -g nodejs/repl


# @TODO install
# - gulp
# - sass
# - adminer
    # access it via http://localhost/adminer.php
    - sudo mkdir /usr/share/adminer
    # should retreive from git instead?
    - sudo wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php
    - sudo ln -s /usr/share/adminer/latest.php /usr/share/adminer/adminer.php
    - echo "Alias /adminer.php /usr/share/adminer/adminer.php" | sudo tee /etc/apache2/conf-available/adminer.conf
    - sudo a2enconf adminer.conf
    - sudo service apache2 restart
    # when wanting to update:
    # sudo wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php
    # per: https://www.leaseweb.com/labs/2014/06/install-adminer-manually-ubuntu-14-04/
sudo apt-get install
# - & then go and modify the [Print] key to use shutter for full-screen shot

# following lines might be no good
# the SHA might change
# here's a script https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
# and the following lines are from https://getcomposer.org/download/
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

wget https://github.com/drush-ops/drush/releases/download/8.3.2/drush.phar
chmod +x drush.phar
sudo mv drush.phar /usr/local/bin/drush
# option: enrich bash startup file with completion and aliases
# drush init

---

sudo gem install tmuxinator

sudo apt-get install imagemagick

# install nvm to manage nodejs versions
# nvm needs some config in .zshrc to work
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
nvm install node
npm install gulp-cli -g

sudo pip3 install asciinema # or with `-H`?
sudo -H pip3 install asciinema

#awesome mysql cli :)
pip3 install -U mycli

### CREATE SYMLINKS FOR DOTFILES ###
.gitconfig
.myclirc
.vim
.tmux.conf
.drush
.zshrc
.vimrc
.xinitrc

sudo snap install spotify
sudo snap install chromium

sudo apt-get install taskwarrior
sudo apt-get install timewarrior
cp /usr/share/doc/timewarrior/ext/on-modify.timewarrior ~/.task/hooks/
chmod +x ~/.task/hooks/on-modify.timewarrior
# get task hook script for watson too, not sure how these will be versioned, I guess in ~/.dotfiles would make sense more so than ~/bin
pip install timew-report #required for certain timewarrior extension
pip3 install td-watson

sudo apt-get install pass
pip install upass

sudo apt-get install irssi #irc client for terminal

#===============
# Dumping Ground:
#===============

sudo pip3 install tasklib

pip3 install vit


sudo apt-get install universal-ctags

