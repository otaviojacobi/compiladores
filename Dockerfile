FROM debian:testing

RUN mkdir -p /usr/compiladores
COPY . /usr/compiladores

# set proxy for SAP -> If you're at SAP computer, uncomment this :)
# ENV http_proxy http://proxy:8080
# ENV https_proxy http://proxy:8080

RUN apt-get update
RUN apt-get install make
RUN apt-get install gcc
RUN apt-get install flex
RUN apt-get install bison
RUN apt-get install valgrind