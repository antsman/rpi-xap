#!/bin/bash
# xAP Docker wrapper script
# Based on original /etc/init.d/xap by Brett England / dbzoo

###
# Provides:          xap
# Short-Description: xAP HAH system
# Description:       xAP Home automation hub
###

subsystem="hub plugboard xively livebox iServer klone sms serial currentcost twitter googlecal urfrx mail"
#MYDEV="-i wlan0"
#LOGLEVEL="-d 5"
BIN=/usr/bin
LOG=/var/log/xap

start_klone() {
  rm -f /tmp/klone_sess*
  if [ -f /etc/kloned.conf ]; then
    sudo $BIN/kloned -f /etc/kloned.conf
  else
    sudo $BIN/kloned
  fi
}

start_hub() {
  $BIN/xap-hub $MYDEV $LOGLEVEL >$LOG/xap-hub.log 2>&1 &
  sleep 1
}

start_livebox() {
  INI="/etc/xap.d/xap-livebox.ini"
  if [ `iniget $INI livebox enable 0` -eq 1 ] ;  then
    $BIN/xap-livebox $MYDEV $LOGLEVEL >$LOG/xap-livebox.log 2>&1 &
  fi
}

start_serial() {
  INI="/etc/xap.d/xap-serial.ini"
  if [ `iniget $INI serial enable 0` -eq 1 ] ;  then
    $BIN/xap-serial $MYDEV $LOGLEVEL >$LOG/xap-serial.log 2>&1 &
  fi
}

start_mail() {
  INI="/etc/xap.d/xap-mail.ini"
  if [ `iniget $INI mail enable 0` -eq 1 ] ;  then
    $BIN/xap-mail $MYDEV $LOGLEVEL >$LOG/xap-mail.log 2>&1 &
  fi
}

start_twitter() {
  INI="/etc/xap.d/xap-twitter.ini"
  if [ `iniget $INI twitter enable 0` -eq 1 ] ;  then
    $BIN/xap-twitter $MYDEV $LOGLEVEL >$LOG/xap-twitter.log 2>&1 &
  fi
}

start_sms() {
  INI="/etc/xap.d/xap-sms.ini"
  if [ `iniget $INI sms enable 0` -eq 1 ] ;  then
    USBSERIAL=`iniget $INI sms usbserial /dev/ttyUSB0`
    $BIN/xap-sms -s $USBSERIAL $MYDEV $LOGLEVEL >$LOG/xap-sms.log 2>&1 &
  fi
}

start_xively() {
  INI="/etc/xap.d/xap-xively.ini"
  if [ `iniget $INI xively enable 0` -eq 1 ] ;  then
    $BIN/xap-xively $MYDEV $LOGLEVEL >$LOG/xap-xively.log 2>&1 &
  fi
}

start_currentcost() {
  INI="/etc/xap.d/xap-currentcost.ini"
  if [ `iniget $INI currentcost enable 0` -eq 1 ] ;  then
    USBSERIAL=`iniget $INI currentcost usbserial /dev/ttyUSB0`
    $BIN/xap-currentcost -s $USBSERIAL $MYDEV $LOGLEVEL >$LOG/xap-currentcost.log 2>&1 &
  fi
}

start_googlecal() {
  INI="/etc/xap.d/xap-googlecal.ini"
  if [ `iniget $INI googlecal enable 0` -eq 1 ] ;  then
    $BIN/xap-googlecal $MYDEV $LOGLEVEL >$LOG/xap-googlecal.log 2>&1 &
  fi
}

start_plugboard() {
  INI="/etc/xap.d/plugboard.ini"
  if [ `iniget $INI plugboard enable 0` -eq 1 ] ;  then
    $BIN/xap-plugboard >$LOG/xap-plugboard.log 2>&1 &
  fi
}

start_iServer() {
  INI="/etc/xap.d/iserver.ini"
  if [ `iniget $INI iserver enable 0` -eq 1 ] ;  then
    $BIN/iServer $MYDEV $LOGLEVEL >$LOG/iserver.log 2>&1 &
  fi
}

start_urfrx() {
  INI="/etc/xap.d/xap-urfrx.ini"
  if [ `iniget $INI urfrx enable 0` -eq 1 ] ;  then
    SERIALPORT=`iniget $INI urfrx serialport /dev/ttyUSB0`
    $BIN/xap-urfrx $MYDEV $LOGLEVEL -s $SERIALPORT >$LOG/xap-urfrx.log 2>&1 &
  fi
}

# turn on bash's job control
set -m

# hub needs to start first to bind default 3639 port

IFS=" "
for i in $subsystem; do
  cmd="start_$i"
  $cmd
  ps -ef | grep $i | grep -v grep >/dev/null && echo "Started $i"
done

sleep 5

# bring back into the foreground
# - job #2 i.e. plugboard if enabled
# - job #1 i.e. hub if no other subsystems enabled

[ $(grep enable=1 /etc/xap.d/* | wc -l) -gt 0 ] && fg %2 || fg %1
