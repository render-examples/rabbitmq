FROM rabbitmq:3-management

# Switch to root to install openssl and generate certificates
USER root

# Install openssl for certificate generation
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Create SSL directory
RUN mkdir -p /etc/rabbitmq/ssl && chown -R rabbitmq:rabbitmq /etc/rabbitmq/ssl

# Generate self-signed certificates
RUN openssl req -new -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes \
    -out /etc/rabbitmq/ssl/ca-cert.pem \
    -keyout /etc/rabbitmq/ssl/ca-key.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=RabbitMQ-CA" && \
    openssl req -new -newkey rsa:4096 -nodes \
    -out /etc/rabbitmq/ssl/server-req.pem \
    -keyout /etc/rabbitmq/ssl/server-key.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=rabbitmq" && \
    openssl x509 -req -in /etc/rabbitmq/ssl/server-req.pem \
    -CA /etc/rabbitmq/ssl/ca-cert.pem \
    -CAkey /etc/rabbitmq/ssl/ca-key.pem \
    -CAcreateserial -out /etc/rabbitmq/ssl/server-cert.pem \
    -days 3650 -sha256 && \
    chmod 644 /etc/rabbitmq/ssl/*.pem && \
    chown -R rabbitmq:rabbitmq /etc/rabbitmq/ssl

COPY rabbitmq.conf /etc/rabbitmq/

ENV RABBITMQ_NODENAME=rabbit@localhost

RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rabbitmq.conf

# Expose AMQP, AMQPS, and Management ports
EXPOSE 5672 5671 15672

USER rabbitmq:rabbitmq
