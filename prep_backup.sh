#!/bin/bash
TMUX_SESSION="minecraft-volny"
LOGFILE="${OPENSHIFT_DIY_LOG_DIR}minecraft.log"
BACKUP_MESSAGE_START="Saving world snapshot, auto-saving disabled."
BACKUP_MESSAGE_STOP="Save Complete, auto-saving enabled."
TMP_FILENAME="$OPENSHIFT_TMP_DIR$TMUX_SESSION"
MC_SAVE_MSG="Saved the world"

# Warn and disable backups (for consistant snapshot)
tmux send -t $TMUX_SESSION "say $BACKUP_MESSAGE_START" C-m
tmux send -t $TMUX_SESSION "save-off" C-m

# https://bitbucket.org/fboender/mcram/src/d27f44fab719c98cead11dc8421ef6c407e30adf/mc?at=master
SAVE_COMPLETE=`grep "$MC_SAVE_MSG" $LOGFILE | wc -l`
tmux send -t $TMUX_SESSION "save-all" C-m
while true; do
    sleep 0.2
    TMP=`grep "$MC_SAVE_MSG" $LOGFILE | wc -l`
    if [ $TMP -gt $SAVE_COMPLETE ]; then
        break
    fi
done

# Do backup
if [ -f "$TMP_FILENAME.tar" ]; then
	rm -f "$TMP_FILENAME.tar"
fi
if [ -f "$TMP_FILENAME.tar.bz2" ]; then
	rm -f "$TMP_FILENAME.tar.bz2"
fi
if [ -d "${OPENSHIFT_DATA_DIR}world.working" ]; then
	rm -rf "${OPENSHIFT_DATA_DIR}world.working"
fi
cp -ar "${OPENSHIFT_DATA_DIR}world" "${OPENSHIFT_DATA_DIR}world.working"
tar -cpf "$TMP_FILENAME.tar" "${OPENSHIFT_DATA_DIR}world.working"
bzip2 "$TMP_FILENAME.tar"
if [ -f "$TMP_FILENAME.tar.bz2" ]; then
	echo "$TMP_FILENAME.tar.bz2"
fi

# Re-enable auto saving
tmux send -t $TMUX_SESSION "save-on" C-m
tmux send -t $TMUX_SESSION "say $BACKUP_MESSAGE_STOP" C-m
