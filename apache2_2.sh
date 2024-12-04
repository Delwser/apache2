#!/bin/bash
COUNTER=0
APACHE="${APACHE_LOG_DIR}"

echo "Vamos Instalar o Apache2"
echo "Coloque o nome do seu dominio - (Sem acentos por favor)"
read DOMAIN
echo "Qual porta seu dominio vai rodar?"
read PORTA
echo "Vai ter Certificado SSL? - (y/n)"
read SSL


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
apt install openssl -y > /dev/null
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
cd /etc/apache2/sites-available
touch $DOMAIN.conf
if [ $SSL == "y" ]; then
    a2enmod ssl
    systemctl restart apache2
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$DOMAIN-selfsigned.key -out /etc/ssl/certs/$DOMAIN-selfsigned.crt
    echo "<VirtualHost *:$PORTA>" | tee -a $DOMAIN.conf
    echo "   ServerAdmin webmaster@localhost" | tee -a $DOMAIN.conf
    echo "  ServerName $DOMAIN" | tee -a $DOMAIN.conf
    echo "  DocumentRoot /var/www/$DOMAIN" | tee -a $DOMAIN.conf
    echo "  SSLEngine on" | tee -a $DOMAIN.conf
    echo "  SSLCertificateFile /etc/ssl/certs/$DOMAIN-selfsigned.crt" | tee -a $DOMAIN.conf
    echo "  SSLCertificateKey /etc/ssl/private/$DOMAIN-selfsigned.key" | tee -a $DOMAIN.conf
    echo "</VirtualHost>" | tee -a $DOMAIN.conf
elif [ $SSL == "n" ]; then
    echo "<VirtualHost *:$PORTA>" | tee -a $DOMAIN.conf
    echo "    ServerAdmin webmaster@localhost" | tee -a $DOMAIN.conf
    echo "    ServerName $DOMAIN" | tee -a $DOMAIN.conf
    echo "    ServerAlias www.$DOMAIN" | tee -a $DOMAIN.conf
    echo "    DocumentRoot /var/www/$DOMAIN" | tee -a $DOMAIN.conf
    echo "    ErrorLog ${APACHE_LOG_DIR}/error.log" | tee -a $DOMAIN.conf
    echo "    CustomLog ${APACHE_LOG_DIR}/access.log combined" | tee -a $DOMAIN.conf
    echo "</VirtualHost>" | tee -a $DOMAIN.conf
fi
echo "O diretório /var/www/$DOMAIN/ foi criado"
echo "O arquivo /etc/apache2/sites-available/$DOMAIN.conf foi criado e configurado com sucesso"
a2ensite $DOMAIN.conf
systemctl reload apache2
a2dissite 000-default.conf
systemctl reload apache2
systemctl restart apache2
