FROM node:20.17.0-alpine

RUN apk add --no-cache git openssh-client

RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN git config --global --add safe.directory /usr/src/app

WORKDIR /usr/src/app

COPY webhook-listener.js .

CMD ["node", "webhook-listener.js"]