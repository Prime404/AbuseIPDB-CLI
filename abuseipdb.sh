#!/bin/bash
# AbuseIPDB Tools by GethPrime
# A shitty attempt at parsing and fetching information from AbuseIPDB in bash

#Get an API key for AbuseIPDB and insert it below
# More info here https://www.abuseipdb.com/api.html
API_KEY="INSERT_API_KEY_HERE"

#Define AbuseIPDB Categories for lookup (to show an understandable output instead of numbers)
declare -A ABUSE_CATEGORIES
ABUSE_CATEGORIES[3]="Fraud Orders"
ABUSE_CATEGORIES[4]="DDoS Attack"
ABUSE_CATEGORIES[5]="FTP Brute Force"
ABUSE_CATEGORIES[9]="Open Proxy"
ABUSE_CATEGORIES[10]="Web Spam"
ABUSE_CATEGORIES[11]="Email Spam"
ABUSE_CATEGORIES[12]="Blog Spam"
ABUSE_CATEGORIES[14]="Port Scan"
ABUSE_CATEGORIES[15]="Hacking"
ABUSE_CATEGORIES[18]="Brute Force"
ABUSE_CATEGORIES[19]="Bad Web Bot"
ABUSE_CATEGORIES[20]="Exploited Host"
ABUSE_CATEGORIES[21]="Web App Attack"
ABUSE_CATEGORIES[22]="SSH"
ABUSE_CATEGORIES[23]="IoT Targeted"

#Get arguments from the user and store as variables
while getopts ":i: :r: :c: l v" opt; do
  case $opt in
    i)
      IP="$OPTARG"
      ;;
    r)
      COMMENT="$OPTARG"
      ;;
    c)
      CAT="$OPTARG"
      ;;
    l)
      LOOKUP="TRUE"
      ;;
    v)
      VERBOSE="TRUE"
      ;;
  esac
done

#Prevent script from running if no arguments are provided
if [ $# -eq 0 ]; then
  echo "Example: abuseipdb_tools.sh -i 127.0.0.1 -l"
  exit 1
fi

#Function intended for looking up information from database
function lookup {
  LOOKUP_DATA=$(curl --silent https://www.abuseipdb.com/check/"$IP"/json?key="$API_KEY"&days=30 2>/dev/null | jq .)
  COUNTRY=$(echo $LOOKUP_DATA | jq -r '.[-1] .country')
  LAST_SEEN=$(echo $LOOKUP_DATA | jq -r '.[-1] .created')
  CATEGORY=$(echo $LOOKUP_DATA | jq -r '.[-1] .category' | tr -d '\n' | sed 's/[^0-9]*//g')
  printf "IP: $IP\nCountry: $COUNTRY\nLast reported: $LAST_SEEN\nCategory: ${ABUSE_CATEGORIES[$CATEGORY]}\n"
}

#Function for filing reports
function report {
  if [ "$CAT" -eq "$CAT" ] 2>/dev/null; then
    REPORT=$(curl --silent --data-urlencode "key=$API_KEY" --data-urlencode "category=$CAT" --data-urlencode comment="$COMMENT" --data-urlencode "ip=$IP" https://www.abuseipdb.com/report/json | jq -r '.success' | tr -d '\n')
    if [ "$REPORT" = true ] ; then
      printf "The report has been submitted successfully. The following data was submitted to the abuse database:\nIP: $IP\nCategory:${ABUSE_CATEGORIES[$CAT]}\nComment:$COMMENT\n"
    else
      echo "Error: The report could not be submitted. This may be due to an error in the syntax, revoked API-key or a previously reported hostname."
    fi
  else
    echo "Error: Categories need to be entered as numbers."
  fi
}

# Detect what function to run based upon arguments set by user
if [ -z "$LOOKUP" ]; then
  if [[ -z $COMMENT || -z $CAT || -z $IP ]]; then
    echo "Error: Not enought arguments provided."
    exit 1
  else
    report
  fi
else
  if [ -z $IP ]; then
    echo "Error: Not enought arguments provided."
    exit
  else
    lookup
  fi
fi
