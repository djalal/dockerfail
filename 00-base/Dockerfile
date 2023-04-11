FROM postgres:11-bullseye

ARG GO_VERSION=1.18.10
ARG PLATFORM=linux-amd64
RUN apt-get update && apt-get install -y openssh-server supervisor wget
RUN mkdir -p /var/run/sshd /var/log/supervisor

RUN wget -P /tmp "https://dl.google.com/go/go${GO_VERSION}.${PLATFORM}.tar.gz"

RUN tar -C /usr/local -xzf "/tmp/go${GO_VERSION}.${PLATFORM}.tar.gz"
RUN rm "/tmp/go${GO_VERSION}.${PLATFORM}.tar.gz"

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

COPY web/dispatcher.go .
RUN go build dispatcher.go
COPY web/static /static/

RUN apt-get install -yq openjdk-11-jdk maven

WORKDIR /home/lab
COPY words .
RUN mvn verify -DskipTests --fail-never

WORKDIR /app
RUN cp -rp /home/lab/target .

COPY db/words.sql /docker-entrypoint-initdb.d/
RUN apt-get install -yq net-tools htop curl
# Supervisord configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf
EXPOSE 80 8080
CMD ["/usr/bin/supervisord"]
