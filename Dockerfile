FROM resin/rpi-raspbian as builder
SHELL ["/bin/bash", "-c"]
ENV GOPATH=/app

# Setup
RUN mkdir -p /app
WORKDIR /app

# Add libraries
RUN apt-get update
RUN \
  apt-get install golang && \
  apt-get install git && \
  go get "github.com/namsral/flag" && \
  go get "github.com/op/go-logging" && \
  apt-get remove git

# Copy & build
ADD . /app/
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /traefik-forward-auth .

# Copy into scratch container
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /traefik-forward-auth ./
ENTRYPOINT ["./traefik-forward-auth"]
