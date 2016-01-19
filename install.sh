#!/bin/bash

# PhpMyAdmin Honeypot Configuration
# greg.foss[at]owasp.org
# v0.1 - June 2015
#
# This script will customize and configure the phpmyadmin honeypot

echo "===================="
echo "PhpMyAdmin Honeypot Configuration"
echo "===================="
sleep 1
echo ""
echo "Where would you like to install the Honeypot? ( ex: /var/www )"
read directory
echo ""
echo "Installing honeypot to: $directory/phpmyadmin/"
echo ""
echo "What Username would you like to use for PhpMyAdmin? (default: root)"
read phpmyadminUsername
if [ -z "$phpmyadminUsername" ]; then
    phpmyadminUsername="root"
fi
echo "What Password would you like to use for PhpMyAdmin? (default: root)"
read phpmyadminPassword
if [ -z "$phpmyadminPassword" ]; then
    phpmyadminPassword="root"
fi
echo ""
echo "PhpMyAdmin Username and Password Configured ($phpmyadminUsername/$phpmyadminPassword)"
echo ""
mv ./phpmyadmin-interactive $directory/phpmyadmin
chmod 700 $directory/phpmyadmin/log.txt
echo ""
echo "What web user is used on this machine? (default: www-data)"
echo ""
read webUser
if [ -z "$webUser" ]; then
    webUser="www-data"
fi
chown -R $webUser:$webUser $directory/phpmyadmin/
echo -e "# Directories\nDisallow: /phpmyadmin/\n# Files\nDisallow: /phpmyadmin/index.php" > $directory/robots.txt
echo "Where would you like the log.txt file to be moved to? (default: /var/log/phpadmin_honeypot.txt)"
read phpmyadminLog
if [ -z "$phpmyadminLog" ]; then
    phpmyadminLog="/var/log/phpadmin_honeypot.txt"
else
mv $directory/phpmyadmin/log.txt $phpmyadminLog

    echo "Using $phpmyadminLog to capture authentication attempts"
    echo ""
fi
echo "Configure LogRhythm to extract data from $directory/phpmyadmin/$phpmyadminLog.txt"
sed -i "/\$File = \"log.txt\";/c\\\$File = \"$phpmyadminLog\";" $directory/phpmyadmin/index.php
sed -i "/\$myFile = \"log.txt\";/c\\\$myFile = \"$phpmyadminLog\";" $directory/phpmyadmin/login.php
sed -i 's/log.txt/'$phpmyadminLog'/g' $directory/phpmyadmin/master-config/index.php
sed -i 's/log.txt/'$phpmyadminLog'/g' $directory/phpmyadmin/master-config/phpinfo.php
sed -i 's/USERNAME/'$phpmyadminUsername'/g' $directory/phpmyadmin/login.php
sed -i 's/PASSWORD/'$phpmyadminPassword'/g' $directory/phpmyadmin/login.php
if [ -f ../phpmyadmin_honeypot/README.md ]; then
     rm -rf ../phpmyadmin_honeypot/
fi
echo ""
echo "Fake PhpMyAdmin has been configured successfully and can be accessed via http://127.0.0.1/phpmyadmin/"
echo "There are also one fake phpinfo page: $directory/phpmyadmin/phpinfo.php"
echo "Logs will write to: $phpmyadminLog"
echo "Username set to => $phpmyadminUsername"
echo "Password set to => $phpmyadminPassword"
echo ""
