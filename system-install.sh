apt-get update
apt-get upgrade
apt-get install git gcc make pkg-config libx11-dev libxtst-dev libxi-dev
sudo apt-get install tig
git clone https://github.com/alols/xcape.git && xcape
make
make install
cd
git clone git@github.com:ahillio/dotfiles.git
ln -s dotfiles/.xinitrc .xinitrc

sudo apt-get install httpie
sudo apt-get install curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
apt-get install zsh
chsh -s /bin/zsh
# reboot computer for shell to change
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
ln -s dotfiles/.zshrc .zshrc

apt-get install tmux
ln -s dotfiles/.tmux.conf .tmux.conf
sudo gem install tmuxinator

sudo apt-get install ack-grep

apt-get install vim-gtk

# requirements for youcompleteme vim plugin:
sudo apt install build-essential cmake python3-dev
git clone youcompleteme #into ~/.vim/bundle
cd youcompleteme
git submodule update --init --recursive
python3 install.py

apt-get install ctags

apt-get install tree

wget https://github.com/peco/peco/releases/download/v0.5.3/peco_linux_amd64.tar.gz
tar -xvf peco_linux_amd64.tar.gz
mv peco_linux_amd64/peco bin

cd ~/bin && git clone https://github.com/rupa/z && rm -rf z/.git

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
sudo vi /etc/apache2/apache2.conf && s/None/All for AllowOverride in the /var/www directory.

#? sudo echo 'ServerName 127.0.0.1' >> /etc/apache2/apache2.conf
# sendmail and postfix are for production servers
# sudo apt-get install sendmail
# sudo sendmailconfig // and choose yes for each prompt
# apt-get install postfix
# ssmtp is sufficient for local dev
sudo apt-get install ssmtp

sudo service apache2 restart

wget https://git.io/psysh
chmod +x psysh
sudo mv psysh /usr/local/bin/
wget http://psysh.org/manual/en/php_manual.sqlite
sudo mkdir /usr/local/share/psysh
sudo mv php_manual.sqlite /usr/local/share/psysh

sudo apt-get install texlive-latex-base texlive-fonts-recommended texlive-fonts-extra python-pygments texlive-latex-extra texlive-extra-utils
sudo apt-get install python-pip 
pip install Pygments

@todo install
- nodejs
- gulp
- sass
- php: install & configure
    - xdebug
    - composer
    - drush
    - drupal console
- mysql
- adminer
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
- xclip

apt-get install chromium-browser gimp inkscape scribus libreoffice
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

wget https://github.com/drush-ops/drush/releases/download/8.1.15/drush.phar
chmod +x drush.phar
sudo mv drush.phar /usr/local/bin/drush
# option: enrich bash startup file with completion and aliases
# drush init

---

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> .zshrc
composer global require drush/drush ##doesn't work :(

sudo gem install tmuxinator

sudo apt-get install imagemagick
