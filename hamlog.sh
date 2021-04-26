#!/bin/bash

# hamlog.sh
# Copyright 2021 Luke (2E0RNG)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function usage {
  cat << EOF
Usage: $0 [COMMAND] [OPTIONS]...

An Amatuer Radio Logbook written in bash

Commands
    help           view this help text
    view           view the logbook
    new            create new logbook entry
    interactive    shows the logbook then reqeusts new input (repeatedly)

Options
    -h --help           view this help text
    -d --date-format    output date format (passed to 'date')
    -l --logbook        logbook file
EOF
}

function view {
  logbook="$1"
  dateformat="$2"

  if ! test -f "$logbook"; then
    echo "logbook ($logbook) doesn't exist"
    exit
  fi
  cat "$logbook" \
    | awk -F ',' \
        -v dateformat=$dateformat \
        '{system("date -d \"@"$1"\" +"dateformat"  | tr \"\n\" \",\"")} {OFS=","; print $2,$3,$4,$5,$6,$7,$8,$9}' \
    | column -t \
        -s ',' \
        -N 'DATE,FREQUENCY (MHz),MODE,POWER,CALL SIGN,QTH,RST RX,RST TX,NOTES'
}

function new {
  logbook="$1"
  dateformat="$2"
  if test -f "$logbook"; then
    lastfreq=$(tail -n1 "$logbook" | cut -d, -f2)
    lastmode=$(tail -n1 "$logbook" | cut -d, -f3)
    lastpower=$(tail -n1 "$logbook" | cut -d, -f4)
  else
    lastfreq="14.000"
    lastmode="SSB"
    lastpower=""
  fi

  read -p "Date [now]: " time
  if [ "$time" == "" ]; then
    time=$(date "+%s")
  else
    time=$(date -d "$time" "+%s")
  fi

  echo "Date: $(date -d @$time +$dateformat)"

  read -p "Frequency [$lastfreq]: " freq
  if [ "$freq" == "" ]; then
    freq="$lastfreq"
  fi

  read -p "Mode [$lastmode]: " mode
  if [ "$mode" == "" ]; then
    mode="$lastmode"
  fi

  read -p "Power [$lastpower]: " power
  if [ "$power" == "" ]; then
    power="$lastpower"
  fi

  read -p "Callsign []: " callsign

  if test -f "$logbook"; then
    lastqth=$(grep "$callsign" "$logbook" | tail -n1 | cut -d, -f6)
    grep "$callsign" "$logbook" \
    | awk -F ',' \
        -v dateformat=$dateformat \
        '{system("date -d \"@"$1"\" +"dateformat"  | tr \"\n\" \",\"")} {OFS=","; print $2,$3,$4,$5,$6,$7,$8,$9}' \
    | column -t \
        -s ',' \
        -N 'DATE,FREQUENCY (MHz),MODE,POWER,CALL SIGN,QTH,RST RX,RST TX,NOTES'
  else
    lastqth=""
  fi
  read -p "QTH [$lastqth]: " qth
  if [ "$qth" == "" ]; then
    qth="$lastqth"
  fi

  read -p "RST-RX [59]: " rstrx
  if [ "$rstrx" == "" ]; then
    rstrx="59"
  fi
  read -p "RST-TX [59]: " rsttx
  if [ "$rsttx" == "" ]; then
    rsttx="59"
  fi

  read -p "Notes []: " notes

  echo "$time,$freq,$mode,$power,$callsign,$qth,$rstrx,$rsttx,$notes" >> "$logbook"

}

function interactive {
  logbook="$1"
  dateformat="$2"
  clear
  view "$logbook" "$dateformat"
  new "$logbook" "$dateformat"
  interactive "$logbook" "$dateformat"
}

# =Argument Parsing=
# based on SO answer https://stackoverflow.com/a/14203146

POSITIONAL=()

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--date-format)
      DATEFORMAT="$2"
      shift
      shift
      ;;
    -l|--logbook)
      LOGBOOK="$2"
      shift
      shift
      ;;
    -h|--help)
      usage
      exit
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL[@]}"
CMD=${POSITIONAL[0]}

if [ -z "$HAMLOG_HOME" ]; then
  HAMLOG_HOME="$HOME/.hamlog"
fi
mkdir -p "$HAMLOG_HOME"

if [ -z "$DATEFORMAT" ]; then
  DATEFORMAT="%Y-%m-%d"
fi
if [ -z "$LOGBOOK" ]; then
  LOGBOOK="$HAMLOG_HOME/logbook.csv"
fi
if [ -z "$CMD" ]; then
  echo "Error: Missing argument COMMAND"
  usage
  exit
fi
case "$CMD" in
  "help")
    usage
    exit
    ;;
  "view")
    view "$LOGBOOK" "$DATEFORMAT"
    ;;
  "new")
    new "$LOGBOOK" "$DATEFORMAT"
    ;;
  "interactive")
    interactive "$LOGBOOK" "$DATEFORMAT"
    ;;
  *)
    echo "Error: Invalid command '$CMD'"
    usage
    exit
    ;;
esac
