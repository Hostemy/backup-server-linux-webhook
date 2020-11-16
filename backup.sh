#!/bin/bash
DIRS="/var /lib" #Directories to be copied
BACKUP=/tmp/backup.$$
NOW=$(date +"%Y-%m-%d")
INCFILE="/root/tar-inc-backup.dat"
DAY=$(date +"%a")
FULLBACKUP="Mon"

FTPD="//incremental-backups"
FTPU="USER-FTP"
FTPP="PASS-FTP"
FTPS="HOST-FTP"
NCFTP="$(which ncftpput)"

WEBHOOK="url"

dpkg --get-selections >/etc/installed-software-dpkg.log

# ----------- Check if we want to make a full or incremental backup ---------- #

[ ! -d $BACKUP ] && mkdir -p $BACKUP || :
if [ "$DAY" == "$FULLBACKUP" ]; then
    FTPD="//full-backups-sa1"
    FILE="backup-$NOW.tar.gz"
    tar -zcvf $BACKUP/$FILE $DIRS
else
    i=$("%Hh%Mm%Ss")
    FILE="backup-$NOW-$i.tar.gz"
    tar -g $INCFILE -zcvf $BACKUP/$FILE $DIRS
fi

# --------------- Check the Date for Old Files on FTP to Delete -------------- #

REMDATE=$(date --date="30 days ago" +%Y-%m-%d)

# --------------------- Start the FTP backup using ncftp --------------------- #

ncftp -u"$FTPU" -p"$FTPP" $FTPS <<EOF
cd $FTPD
cd $REMDATE
rm -rf *.*
cd ..
rmdir $REMDATE
mkdir $FTPD
mkdir $FTPD/$NOW
cd $FTPD/$NOW
lcd $BACKUP
mput *
quit
EOF

# ------------------- Find out if ftp backup failed or not ------------------- #

if [ "$?" == "0" ]; then
    rm -f $BACKUP/*
    curl -X POST --data "{ \"embeds\": [{\"title\": \"BACKUP SUCCESSFUL\", \"url\": \"https://$FTPS/$FTPD/$FILE\", \"description\": \"Copy successful\", \"type\": \"link\", \"thumbnail\": {\"url\": \"https://tetranoodle.com/wp-content/uploads/2018/07/tick-gif.gif\"}}] }" -H "Content-Type: application/json" "$WEBHOOK"
else
    T=/tmp/backup.fail
    echo "Date: $(date)" >$T
    echo "Hostname: $(hostname)" >>$T
    echo "Backup failed" >>$T
    curl -X POST --data "{ \"embeds\": [{\"title\": \"BACKUP SUCCESSFUL\", \"url\": \"https://$FTPS/\", \"description\": \"Copy successful $date\", \"type\": \"link\", \"thumbnail\": {\"url\": \"https://tetranoodle.com/wp-content/uploads/2018/07/tick-gif.gif\"}}] }" -H "Content-Type: application/json" "$WEBHOOK"
    rm -f $T
fi
