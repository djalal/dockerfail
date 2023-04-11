FROM postgres:11-bullseye

ARG GO_VERSION=1.18.10
ARG PLATFORM=linux-amd64
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    openssh-server=1:8.4p1-5+deb11u1 wget=1.21-1+deb11u1 \
    supervisor=4.2.2-2 maven=3.6.3-5 openjdk-11-jdk=11.0.18+10-1~deb11u1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*  && \
    mkdir -p /var/run/sshd /var/log/supervisor && \
    wget -q -P /tmp "https://dl.google.com/go/go${GO_VERSION}.${PLATFORM}.tar.gz" && \
    tar -C /usr/local -xzf "/tmp/go${GO_VERSION}.${PLATFORM}.tar.gz" && \
    rm "/tmp/go${GO_VERSION}.${PLATFORM}.tar.gz"

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

COPY /web/dispatcher.go /
RUN go build dispatcher.go
COPY /web/static /static/

COPY words /home/lab
WORKDIR /home/lab
RUN mvn verify -DskipTests --fail-never && \
    cp -rp /home/lab/target/ /app

COPY db/words.sql /docker-entrypoint-initdb.d/

# Supervisord configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf
EXPOSE 80 8080
CMD ["/usr/bin/supervisord"]
