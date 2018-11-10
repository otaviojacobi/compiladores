FROM debian:testing

RUN mkdir -p /usr/compiladores
COPY . /usr/compiladores

# set proxy for SAP -> If you're at SAP computer, uncomment this :)
# ENV http_proxy http://proxy:8080
# ENV https_proxy http://proxy:8080

RUN apt-get -y update
RUN apt-get -y install make
RUN apt-get -y install gcc
RUN apt-get -y install flex
RUN apt-get -y install bison
RUN apt-get -y install valgrind
RUN apt-get -y install python