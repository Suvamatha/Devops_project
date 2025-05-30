FROM wordpress:php8.1-apache
RUN a2enmod rewrite
COPY ./Application-website/ /var/www/html/wp-content/themes/shapely/
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html
EXPOSE 80