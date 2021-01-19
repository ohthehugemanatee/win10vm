#!/bin/sh

# Checks your CPU for support for 2M and 1G hugepage sizes.

if [ $(cat /proc/cpuinfo | grep -oh pse | uniq) == "pse" ]
  then echo "2048K = OK"
  else echo "2048K = NO"
fi

if [ $(cat /proc/cpuinfo | grep -oh pdpe1gb | uniq) == "pdpe1gb" ]
  then echo "1G = OK"
  else echo "1G = NO"
fi
