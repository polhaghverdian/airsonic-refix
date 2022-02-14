#!/usr/bin/env bash
# vim:sw=4:ts=4:et

# echo $SERVER_URL
# echo $BASE_URL

set -e

if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

if [ "$1" = "nginx" -o "$1" = "nginx-debug" ]; then
    if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        echo >&3 "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"

        echo >&3 "$0: Looking for shell scripts in /docker-entrypoint.d/"
        find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo >&3 "$0: Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        echo >&3 "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *) echo >&3 "$0: Ignoring $f";;
            esac
        done

        echo >&3 "$0: Configuration complete; ready for start up"
    else
        echo >&3 "$0: No files found in /docker-entrypoint.d/, skipping configuration"
    fi
fi


echo -------------------------- Cloning Airsonic-refix repo --------------------------------
git clone https://github.com/tamland/airsonic-refix.git && cd /airsonic-refix
envsubst < /vue.config.js > /airsonic-refix/vue.config.js
# cp /vue.config.js /airsonic-refix/vue.config.js

echo Building...
yarn install
yarn build

echo Moving assets to nginx public folder...
# Create a public folder nginx
mkdir -p /var/www/html/
# Copy assets to nginx static folder.
cp -a ./dist/. /var/www/html/

if [ -z $SERVER_URL ]; then
   echo no pre-defined SERVER_URL
else
   echo SERVER_URL $SERVER_URL
   envsubst < /env.js.template > /var/www/html/env.js
fi

echo cleaning up...
# rm -rf /airsonic-refix

echo -------------------------- Starting Airsonic-refix -------------------------
#sleep infinity


exec "$@"
