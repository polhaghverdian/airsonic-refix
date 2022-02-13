#!/usr/bin/env bash

# echo $SERVER_URL
# echo $BASE_URL

echo -------------------------- Cloning Airsonic-refix repo --------------------------------
git clone https://github.com/tamland/airsonic-refix.git && cd /airsonic-refix
cp /vue.config.js ./
echo Building...
yarn install
yarn build

echo Moving assets to nginx public folder...
# Create a public folder nginx
mkdir -p /var/www/html/$BASE_URL
# Copy assets to nginx static folder.
cp -a ./dist/. /var/www/html/$BASE_URL

if [ -z $SERVER_URL ]; then
   echo no pre-defined SERVER_URL
else
   echo SERVER_URL $SERVER_URL
   envsubst < /env.js.template > /var/www/html/$BASE_URL/env.js
fi

echo cleaning up...
# rm -rf /airsonic-refix

echo -------------------------- Starting Airsonic-refix -------------------------
envsubst < /etc/nginx/conf.d/default.conf
nginx
sleep infinity
