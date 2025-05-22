FROM quay.io/centos/centos:stream8

RUN yum install -y httpd zip unzip && yum clean all

COPY . /var/www/html

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
