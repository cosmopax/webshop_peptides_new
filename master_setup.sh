#!/bin/bash
# ==============================================================================
#           MASTER E-COMMERCE SETUP SCRIPT (v9 - Final & Idempotent)
# ==============================================================================
# This single script handles: Server Dependencies & Config, Python Web Scraper
# for Site Structure, WordPress Install, Plugin Install, and SSL.

set -e
export DEBIAN_FRONTEND=noninteractive

# --- CONFIGURATION ---
DOMAIN_NAME="eu-peptides.org"
ADMIN_USER="cosmopax"
ADMIN_PASSWORD="Alevenja1."
ADMIN_EMAIL="cosmopax.research@gmail.com"
DB_NAME="woocommerce_db"
DB_USER="wc_user"
DB_PASSWORD=$(openssl rand -hex 16)
WP_PATH="/var/www/$DOMAIN_NAME/public_html"
PYTHON_SCRIPT_PATH="/tmp/scrape_site.py"
STRUCTURE_SCRIPT_PATH="/tmp/setup_structure.sh"

print_header() { echo -e "\n======================================\n▶ $1\n======================================"; }

# --- SCRIPT EXECUTION ---

print_header "PART 1: SERVER PREPARATION & CONFIGURATION"
apt-get update > /dev/null
apt-get install -y apache2 mysql-server php php-mysql php-curl php-gd php-xml php-mbstring php-zip php-intl unzip certbot python3-certbot-apache wget python3-pip > /dev/null
pip3 install -q requests beautifulsoup4
if ! swapon --show | grep -q '/swapfile'; then fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile && echo '/swapfile none swap sw 0 0' >> /etc/fstab; fi
cat <<CONF > "/etc/mysql/mysql.conf.d/99-default-auth.cnf"
[mysqld]
default_authentication_plugin=mysql_native_password
CONF
systemctl restart mysql
PHP_INI_PATH=$(find /etc/php -name "php.ini" -path "*apache2*")
if [ -f "$PHP_INI_PATH" ]; then
    sed -i 's/memory_limit = .*/memory_limit = 512M/' "$PHP_INI_PATH"
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' "$PHP_INI_PATH"
    sed -i 's/post_max_size = .*/post_max_size = 64M/' "$PHP_INI_PATH"
    sed -i 's/max_execution_time = .*/max_execution_time = 300/' "$PHP_INI_PATH"
fi

print_header "PART 2: CORE WORDPRESS & APACHE SETUP"
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "DROP USER IF EXISTS '$DB_USER'@'localhost';"
mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
mkdir -p "$WP_PATH"
cat <<VHOST > "/etc/apache2/sites-available/$DOMAIN_NAME.conf"
<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    ServerAlias www.$DOMAIN_NAME
    DocumentRoot $WP_PATH
    <Directory $WP_PATH>
        AllowOverride All
    </Directory>
</VirtualHost>
VHOST
chown -R www-data:www-data "/var/www/$DOMAIN_NAME"
a2ensite "$DOMAIN_NAME.conf" > /dev/null && a2dissite 000-default.conf > /dev/null && a2enmod rewrite > /dev/null
systemctl restart apache2
if ! command -v wp &> /dev/null; then wget -qO /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x /usr/local/bin/wp; fi
if ! sudo -u www-data wp core is-installed --path="$WP_PATH"; then
    sudo -u www-data wp core download --path="$WP_PATH" --force
    sudo -u www-data wp config create --path="$WP_PATH" --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --force
    sudo -u www-data wp core install --path="$WP_PATH" --url="https://www.$DOMAIN_NAME" --title="EU Peptides" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$ADMIN_EMAIL"
fi

print_header "PART 3: CLEANING & CREATING SITE STRUCTURE"
# This section now deletes old content to ensure a clean run
echo "Deleting old menus, pages, and categories for a clean start..."
sudo -u www-data wp menu delete main-navigation --yes --path="$WP_PATH" 2>/dev/null || true
sudo -u www-data wp post delete $(sudo -u www-data wp post list --post_type=page --post_status=publish --format=ids --path="$WP_PATH") --force --path="$WP_PATH" 2>/dev/null || true
ALL_TERMS=$(sudo -u www-data wp term list product_cat --field=term_id --format=ids --path="$WP_PATH")
if [ -n "$ALL_TERMS" ]; then sudo -u www-data wp term delete product_cat $ALL_TERMS --yes --path="$WP_PATH"; fi
# Now create the new structure using an embedded Python script
cat << 'EOF_PYTHON' > "$PYTHON_SCRIPT_PATH"
import requests,bs4,re
PAGES=["shipping","terms-and-conditions","privacy-policy","contact-us","affiliate-program","cookies","about-us","peptide-calculator","blog","wholesale","returns"]
print("#!/bin/bash\nWP_PATH=\"/var/www/eu-peptides.org/public_html\"\n")
try:
    s=bs4.BeautifulSoup(requests.get("https://particlepeptides.com/en/",headers={'User-Agent':'Mozilla/5.0'}).content,'html.parser')
    for p in s.find('li',id='desktop-menu-item-29').find('ul').find_all('li',recursive=False):
        pa=p.find('a',recursive=False);n=pa.get_text(strip=True).replace("'","\\'");v=re.sub(r'\W+','',n.upper().replace(' ','_'))
        print(f"{v}_ID=$(wp term create product_cat \"{n}\" --path=\"$WP_PATH\" --porcelain)")
        if sm:=p.find('ul'):
            for c in sm.find_all('li'):
                if ca:=c.find('a'):print(f"wp term create product_cat \"{ca.get_text(strip=True).replace(\"'\",\"\\\\'\")}\" --parent=\"${{{v}_ID}}\" --path=\"$WP_PATH\"")
    for ps in PAGES:
        pt=ps.replace('-',' ').title();l=s.find('a',href=re.compile(f'/{ps}/?$'));pt=l.get_text(strip=True) if l else pt
        print(f'wp post create --post_type=page --post_title="{pt}" --post_status=publish --path="$WP_PATH" > /dev/null')
    print("m='main-navigation';wp menu create 'Main Navigation' --path=\"$WP_PATH\";wp menu location assign \"$m\" primary --path=\"$WP_PATH\"")
    print("h=$(wp post list --post_type=page --name=home --field=ID --path=\"$WP_PATH\"||wp post create --post_type=page --post_title=Home --post_status=publish --porcelain --path=\"$WP_PATH\");wp option update show_on_front page --path=\"$WP_PATH\"&&wp option update page_on_front \"$h\" --path=\"$WP_PATH\"")
except Exception as e:print(f"echo '# PYTHON ERROR: {e}'")
EOF_PYTHON
python3 "$PYTHON_SCRIPT_PATH" > "$STRUCTURE_SCRIPT_PATH"
sudo -u www-data bash "$STRUCTURE_SCRIPT_PATH"

print_header "PART 4: INSTALLING PLUGINS & SECURING SITE"
sudo -u www-data wp plugin install woocommerce yith-woocommerce-wishlist calculated-fields-form affiliatewp newsletter wpforms wp-mail-smtp wp-latex astra --activate --skip-installed --path="$WP_PATH"
certbot --apache -n --redirect --agree-tos -m "$ADMIN_EMAIL" -d "$DOMAIN_NAME" -d "www.$DOMAIN_NAME"
systemctl restart apache2

print_header "✓✓✓ MASTER SETUP COMPLETE ✓✓✓"
echo "The server and site structure are ready. Please review your site."
