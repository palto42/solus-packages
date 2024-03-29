#!/bin/sh

if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=/usr/lib64/openjdk-21
fi

exec $JAVA_HOME/bin/java -jar /usr/share/pdfsam/pdfsam.jar -Xmx512M -Dapp.name="pdfsam-basic" -Dapp.pid="$$" -Dapp.home=/usr/share/pdfsam -Dbasedir=/usr/share/pdfsam -Dprism.lcdtetxt=false  "$@"

# MODULEPATH="/usr/share/java/pdfsam"
# JAVA_OPTS=""
# BASEDIR="/usr/share/pdfsam"
# exec $JAVA_HOME/bin/java --enable-preview --module-path "$MODULEPATH" --module org.pdfsam.basic/org.pdfsam.basic.App $JAVA_OPTS -Xmx512M \
#   -splash:$BASEDIR/splash.png \
#   -Dapp.name="pdfsam-basic" \
#   -Dapp.pid="$$" \
#   -Dapp.home="$BASEDIR" \
#   -Dbasedir="$BASEDIR" \
#   -Dprism.lcdtext=false \
#   "$@"