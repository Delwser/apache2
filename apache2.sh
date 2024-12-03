#!/bin/bash
COUNTER=0

echo "Vamos Instalar o Apache2"
echo "Coloque o nome do seu dominio - (Sem acentos por favor)"
read DOMAIN
echo "Qual porta seu dominio vai rodar?"
read PORTA


while [ $COUNTER -eq 0 ]; do
    if [ $USER != "root" ]; then
        echo "Are you Root?"
        echo "Logue como root | sudo su, ou su -"
        exit 1
    elif [ $USER == "root" ]; then
        break
    else
        return Tetando novamente!
    fi
done

apt update > /dev/null
apt install apache2 -y
systemctl restart apache2
mkdir -p /var/www/$DOMAIN
chmod -R 755 /var/www/$DOMAIN
cd /var/www/$DOMAIN
touch index.html
echo "<html>" | tee -a index.html
echo "  <head>" | tee -a index.html
echo "      <title>Seja bem vindo a $DOMAIN!</title>" | tee -a index.html
echo "  </head>" | tee -a index.html
echo "  <body>" | tee -a index.html
echo "  <h1> Parabens! Seu dominio $DOMAIN foi criado com sucesso</h1>" | tee -a index.html
echo "  </body>" | tee -a index.html
echo "</html>" | tee -a index.html
clear
touch /etc/apache2/sites-available/$DOMAIN.conf
cd /etc/apache2/sites-available
echo "<VirtualHost *:$PORTA>" | tee -a $DOMAIN.conf
echo "    ServerAdmin webmaster@localhost" | tee -a $DOMAIN.conf
echo "    ServerName $DOMAIN" | tee -a $DOMAIN.conf
echo "    ServerAlias www.$DOMAIN" | tee -a $DOMAIN.conf
echo "    DocumentRoot /var/www/$DOMAIN" | tee -a $DOMAIN.conf
echo "    ErrorLog ${APACHE_LOG_DIR}/error.log" | tee -a $DOMAIN.conf
echo "    CustomLog ${APACHE_LOG_DIR}/access.log combined" | tee -a $DOMAIN.conf
echo "</VirtualHost>" | tee -a $DOMAIN.conf
echo "O arquivo em /var/www/$DOMAIN/$DOMAIN.conf foi criado"
a2ensite $DOMAIN.conf
systemctl reload apache2
a2dissite 000-default.conf
systemctl reload apache2
systemctl restart apache2
