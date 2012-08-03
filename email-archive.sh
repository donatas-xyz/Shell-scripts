#!/bin/sh
# Managing the archive (works on ISPconfig v.3.0.4.6)
# Version 0.1 / Donatas Stonys / Blue Whale SEO / 01/08/2012

# DO NOT FORGET to add 'always_bcc = archive_mailbox@example.com' to /etc/postfixt/main.cf file
# if you want to archive all incoming/outgoing mail on your server

# Domain which emails you want to archive
DOMAIN=example.com
# User receiving emails (This normally will be existing email account on a server, i.e. archive@example.com - use only 'archive' part)
USER=archive_mailbox
# Path to maildirmake (The maildirmake command creates maildirs, and maildir folders.)
MAILDIRMAKEDIR=/usr/bin
# Path to Maildir folder
KEEP=/var/vmail/$DOMAIN/$USER
# Path to the location of new mail messages
STORE=/var/vmail/$DOMAIN/$USER/new
# Directory where domain's archived messages will be stored
INTDARCHIVEDIR=Archive
# Directory where messages of external domains will be stored
EXTDARCHIVEDIR=External
# Subdirectory of directory defined above
EXTDARCHIVESBUDIR=domain
# Owner of Maildir folders (vmail in ISPconfig)
VIRTUSER=vmail
VIRTGROUP=vmail

for x in `find $STORE -type f`;
 do
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  RSLT=`cat $x | grep "Return-Path"`
  PERSONTMP=`echo $RSLT | cut -f 2 -d "<"`
  PERSON=`echo $PERSONTMP | cut -f 1 -d ">"`
  echo "-checking email.. $x"
  echo "-get sender.. $PERSON"
  RSLT1=`echo $PERSON | grep -i -e "@$DOMAIN" 1> /dev/null ; echo $?`
  if [ "$RSLT1" == "0" ];
   then
    NAME=`echo $PERSON | cut -f 1 -d "@"`
    echo "-sender is a $DOMAIN person.. $NAME"
    if [ -d $KEEP/.$INTDARCHIVEDIR.$NAME ];
         then
          echo "--archive folder exists"
         else
          echo "--archive folder does not exist .. so create it"
          $MAILDIRMAKEDIR/maildirmake -f $INTDARCHIVEDIR.$NAME $KEEP
		  echo "--make sure all files and directories are owned by right user/group"
		  `chown -R $VIRTUSER:$VIRTGROUP $KEEP/.$INTDARCHIVEDIR.$NAME`
		  echo "--add new folder to the folders list"
		  `echo "INBOX.$INTDARCHIVEDIR.$NAME" >> $KEEP/courierimapsubscribed`
    fi
   echo "-so lets move the email.."
   mv -uv $x $KEEP/.$INTDARCHIVEDIR.$NAME/new
   else
    echo "-sender is not a $DOMAIN person.."
        NAME=`echo $PERSON | cut -f 2 -d "@"`
        echo "-external senders domain is $NAME"
        if [ -d $KEEP/.$EXTDARCHIVEDIR.$EXTDARCHIVESBUDIR ];
     then
       echo "--archive folder exists"
     else
       echo "--archive folder does not exist .. so create it"
       $MAILDIRMAKEDIR/maildirmake -f $EXTDARCHIVEDIR.$EXTDARCHIVESBUDIR $KEEP
	   echo "--make sure all files and directories are owned by right user/group"
       `chown -R $VIRTUSER:$VIRTGROUP $KEEP/.$EXTDARCHIVEDIR.$EXTDARCHIVESBUDIR`
	   echo "--add new folder to the folders list"
	   `echo "INBOX.$EXTDARCHIVEDIR.$EXTDARCHIVESBUDIR" >> $KEEP/courierimapsubscribed`
    fi
        echo "-so lets move the email.."
    mv -uv $x $KEEP/.$EXTDARCHIVEDIR.$EXTDARCHIVESBUDIR/new
  fi
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  
  done