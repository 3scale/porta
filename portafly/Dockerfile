FROM node:10-alpine as builder
WORKDIR /tmp/portafly
COPY . ./
ENV PUBLIC_URL="/portafly"
RUN yarn install \
    && yarn build --production --frozen-lockfile

FROM node:10-alpine
RUN npm install -g local-web-server
WORKDIR /opt/portafly
COPY --from=builder /tmp/portafly/build ./
EXPOSE 5000
CMD ws -p 5000 --rewrite '/portafly/(.*)->$1' -d /opt/portafly --spa index.html
