FROM almalinux:8

RUN dnf install -y httpd zip unzip && dnf clean all

COPY . /var/www/html

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
