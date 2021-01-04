FROM debian

RUN apt-get update
RUN apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install docker-ce


# Utils
RUN wget https://github.com/digitalocean/doctl/releases/download/v1.54.0/doctl-1.54.0-linux-amd64.tar.gz -P /tmp && \
    tar xf /tmp/doctl-1.54.0-linux-amd64.tar.gz -C /tmp && \
    mv /tmp/doctl /usr/local/bin

COPY run.sh /run/run.sh
RUN chmod +x /run/run.sh

