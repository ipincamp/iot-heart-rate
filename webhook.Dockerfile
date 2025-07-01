FROM node:20.17.0-alpine

RUN apk add --no-cache git

WORKDIR /usr/src/app

COPY webhook-listener.js .

CMD ["node", "webhook-listener.js"]