FROM node:11-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install -g prisma
RUN npm install

COPY ./prisma ./prisma
COPY ./src ./src

EXPOSE 4000
CMD [ "node", "src/index.js" ]