# get variables
SITENAME=$1
DB_USER=''
DB_PW=''
WP_USER=''
WP_PW=''
WP_EMAIL=''
WP_GENESIS_LOCATION=''

# create and enter folder
cd ~/Sites
mkdir $SITENAME
cd $SITENAME

# create DB
mysql -h localhost -u $DB_USER -p$DB_PW -Bse "CREATE DATABASE $SITENAME; "

# download and install WP
wp core download
wp core config --dbname=$SITENAME --dbuser=$DB_USER --dbpass=$DB_PW --extra-php <<PHP
define( 'WP_DEBUG', true );

/**
 * Manually define site location
 */
define('WP_SITEURL', 'http://$SITENAME.dev');
define('WP_HOME', 'http://$SITENAME.dev');

/**
 * Limit post revision history
 */
define('WP_POST_REVISIONS', 3);

/**
 * Increase PHP memory limit
 */
define('WP_MEMORY_LIMIT', '64M');

/**
 * Empty trash more frequently
 */
define('EMPTY_TRASH_DAYS', 15 );

/**
 * Prevent theme/plugin file editing
 */
define('DISALLOW_FILE_EDIT', true);
PHP
wp core install --url=http://$SITENAME.dev --title=$SITENAME --admin_user=$WP_USER --admin_password=$WP_PW --admin_email=$WP_EMAIL

# install plugins
wp plugin uninstall akismet
wp plugin uninstall hello
wp plugin install advanced-custom-fields
wp plugin install login-security-solution
wp plugin install regenerate-thumbnails
wp plugin install theme-check
wp plugin install developer
wp plugin install underconstruction
wp plugin install velvet-blues-update-urls
wp plugin install wordpress-seo
wp plugin install wp-smushit
wp plugin install wordpress-importer
wp plugin activate advanced-custom-fields
wp plugin activate regenerate-thumbnails
wp plugin activate wordpress-importer

# cleanup themes
wp theme delete twentytwelve
wp theme install $WP_GENESIS_LOCATION

# add test XML
wp site empty --yes
curl -O https://raw.github.com/manovotny/wptest/master/wptest.xml
wp import wptest.xml --authors=create
rm wptest.xml

# clean db
wp db repair
wp db optimize

# flush permalinks
wp rewrite structure '/%postname%/' --hard

# update site options
wp option update blogdescription ''
wp option update blog_public '0'
wp option update default_comment_status 'closed'
wp option update timezone_string 'America/New_York'

# bones theme
cd wp-content/themes
git clone https://github.com/cdukes/bones-for-genesis-2-0.git genesis-$SITENAME