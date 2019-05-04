FROM node:12.1.0-alpine

RUN mkdir /workspace

WORKDIR /workspace
COPY ./index.js .
COPY ./package.json .

RUN npm install --prod

ENV PORT 3000
ENV HOSTNAME 0.0.0.0

EXPOSE 3000
CMD ["node", "index.js"]

