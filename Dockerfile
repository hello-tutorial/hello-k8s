# syntax=docker/dockerfile:1
FROM node:17-alpine
RUN apk add --no-cache python2 g++ make
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "app/index.js"]
EXPOSE 3000