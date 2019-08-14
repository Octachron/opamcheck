echo Launching opamcheck for $(cat params)

PATH="${PATH}:."
PATH=${PATH##*.opam}
PATH=${PATH#*:}
PARAMS=$(cat params)
OPCSANDBOX=/app/sandbox
export OPCSANDBOX=$OPCSANDBOX
set $PARAMS
unset OPAMSWITCH
printf "<p>opamcheck launched on %s<br>" "$(date -u +"%F %T UTC")"
printf "<p>opamcheck launched on %s<br>" "$(date -u +"%F %T UTC")" \
  > $OPCSANDBOX/launch-info
printf "with arguments: %s</p>" "$*"
printf "with arguments: %s</p>" "$*" >>$OPCSANDBOX/launch-info
opamcheck run -retries 2 -log-dir /log "$@"
#rm -rf $OPCSANDBOX/summary
while [ $# -gt 1 ]; do shift; done
opamcheck summarize -log-dir /log -head "$(<$OPCSANDBOX/launch-info)" "$1"
