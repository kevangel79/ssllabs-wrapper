#!/bin/bash

# -----------------------------------------------------------------
# GRNET S.A
# 
# grade_ssl.sh script needs go and ssllabs-scan-v3 script installed
#
# Arguments: -H hostname
# Return value: 0,1,2,3 (OK,WARNING,CRITICAL,UNKNOWN respectively)
# -----------------------------------------------------------------

set -e
# Get Arguments 
while getopts "H:" opt; do
  case ${opt} in
    h )
        echo "Usage: grade_ssl.sh"
        echo "Required arguments:"
        echo "   -H  hostname"
        exit 0
      ;;
    H ) hostname=${OPTARG} ;;
    \? ) echo "Usage: grade_ssl.sh [-h] Hostname"
         exit 1
      ;;
  esac
done

#Run ssllabs script and get grade
OUTPUT=`./ssllabs-scan-v3 -grade $hostname 2>/dev/null | grep -E '\"([0-9]{1,3}[\.]){3}[0-9]{1,3}\"' `
eval GRADE=`echo $OUTPUT | awk -F ":" '/1/ {print $2}'`
echo $hostname':' $GRADE

#Exit code based on grade
case $GRADE in
  # OK status
  'A' | 'A-' | 'A+')
    exit 0
    ;;
  # WARNING status
  'B' )
    exit 1
    ;;
  # CRITICAL status
  'C' | 'D' | 'E' | 'F' )
    exit 2
    ;;
  # UNKNOWN status
  *)
    exit 3
    ;;
esac
