echo Launching opamcheck for $(cat params)

PATH="${PATH}:."
PATH=${PATH##*.opam}
PATH=${PATH#*:}
PARAMS=$(cat params)
OPCSANDBOX=/app/sandbox
LOG=/app/log
export OPCSANDBOX=$OPCSANDBOX
set $PARAMS
unset OPAMSWITCH
printf "<p>opamcheck launched on %s<br>" "$(date -u +"%F %T UTC")"
printf "<p>opamcheck launched on %s<br>" "$(date -u +"%F %T UTC")" \
  > $LOG/launch-info
printf "with arguments: %s</p>" "$*"
printf "with arguments: %s</p>" "$*" >>$LOG/launch-info
opamcheck -sandbox $OPCSANDBOX -retries 1 -smoke -logdir $LOG $@
rm -rf $OPCSAN/summary
while [ $# -gt 1 ]; do shift; done
opamcheck summarize -logdir $LOG -head "$(<$OPCSANDBOX/launch-info)" "$1"
