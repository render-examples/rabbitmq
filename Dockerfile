FROM rabbitmq:3.7.17-management

COPY rabbitmq.conf /etc/rabbitmq/

RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rabbitmq.conf
