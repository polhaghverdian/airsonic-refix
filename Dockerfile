FROM nginx:alpine
MAINTAINER Pol Haghverdian <pol_r@hotmail.com>

ENV ALPINE_MIRROR "http://dl-cdn.alpinelinux.org/alpine"
RUN echo "${ALPINE_MIRROR}/edge/main" >> /etc/apk/repositories

ENV BASE_URL=/airsonic
ENV SERVER_URL=

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
RUN apk update && apk add bash curl git gettext
RUN apk add --no-cache nodejs yarn --repository="http://dl-cdn.alpinelinux.org/alpine/edge/community"

EXPOSE 80

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY env.js.template /env.js.template
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY vue.config.js /vue.config.js
RUN chmod +x /docker-entrypoint.sh

CMD ["nginx", "-g", "daemon off;"]
