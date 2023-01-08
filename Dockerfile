FROM node:16.17.0-alpine

USER node

WORKDIR /usr/src/app

COPY --chown=node:node package.json /usr/src/app/
RUN npm i

COPY --chown=node:node server.js /usr/src/app/

EXPOSE 3000

CMD node server.js
