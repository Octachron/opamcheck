#!/usr/bin/dash
echo Launching opamcheck for $*

PATH="${PATH}:."
PATH=${PATH##*.opam}
PATH=${PATH#*:}
PARAMS=$@
OPCSANDBOX=/app/sandbox
LOG=/app/log
export OPCSANDBOX=$OPCSANDBOX
set $PARAMS
unset OPAMSWITCH
printf "launching nginx"
sudo nginx -c /app/nginx.conf
printf "<p>opamcheck launched on %s<br>" "$(date -u +"%F %T UTC")"
printf "<p>opamcheck launched on %s<br>" "$(date -u +"%F %T UTC")" \
  > $LOG/launch-info
printf "with arguments: %s</p>" "$*"
printf "with arguments: %s</p>" "$*" >>$LOG/launch-info
opamcheck -sandbox $OPCSANDBOX -logdir $LOG $PARAMS
rm -rf $LOG/summary
shift
opamcheck summarize -logdir $LOG -head "$(<$LOG/launch-info)" $@
