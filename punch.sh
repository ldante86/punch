#!/bin/bash -
#
# SCRIPT: punch
# AUTHOR: Luciano D. Cecere
# DATE: 11/29/2015-05:29:47 PM
########################################################################
#
# punch - Convert text to punch cards
# Copyright (C) 2015 Luciano D. Cecere <ldante86@aol.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################

export PATH=/bin:/usr/bin
unalias -a

########################## DEFINE GLOBALS ##############################

PROGRAM="${0##*/}"
COLUMNS=48
declare -u str

CHARS=( \! \" \# $ % \& \' \( \) + \, - . /
        : \; \< = \> ? @ \` \{ \| \} \~
        \[ \\ \] \^ _

        {0..9} {A..Z}
)

# ASCII table that cooresponds to CHARS
DEC=(   33 34 35 36 37 38 39 40 41 43 44
        45 46 47 58 59 60 61 62 63 64
        96 123 124 125 126 91 92 93 94 95

        48 49 50 51 52 53 54 55 56 57

        65 66 67 68 69 70 71 72 73 74 75
        76 77 78 79 80 81 82 83 84 85 86
        87 88 89 90
)

ROWCHARS=( " " " " " " 1 2 3 4 5 6 7 8 9)

HOLES=(	0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 518
	522 66 1090 546 2048 1030 2066 1042 1058 2560 578 1024 2114 768 512 256
	128 64 32 16 8 4 2 1 18 1034 2058 530 10 6 34 2304 2176 2112 2080 2064
	2056 2052 2050 2049 1280 1152 1088 1056 1040 1032 1028 1026 1025 640
	576 544 528 520 516 514 513 130 2082 1536 642 783 2304 2176 2112 2080
	2064 2056 2052 2050 2049 1280 1152 1088 1056 1040 1032 1028 1026 1025
	640 576 544 528 520 516 514 513 130 2054 2082 1536 642 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 518 522 66 1090 546
	2048 1030 2066 1042 1058 2560 578 1024 2114 768 512 256 128 64 32 16 8
	4 2 1 18 1034 2058 530 10 6 34 2304 2176 2112 2080 2064 2056 2052 2050
	2049 1280 1152 1088 1056 1040 1032 1028 1026 1025 640 576 544 528 520
	516 514 513 130 2054 2082 1536 642 783 2304 2176 2112 2080 2064 2056
	2052 2050 2049 1280 1152 1088 1056 1040 1032 1028 1026 1025 640 576 544
	528 520 516 514 513 130 2054 2082 1536 642 0
)

USAGE="\
PROGRAM: $PROGRAM
DESCRIPTION: Convert text to punch cards
AUTHOR: Luciano D. Cecere
LICENSE: GPLv2 (2015)

USAGE:
 $PROGRAM string
 $PROGRAM -h

FLAG:
 -h    Print this help and exit.\
"

########################## DEFINE FUNCTIONS ############################

_bit() { echo $(( $1 & (1<<$2) )); }

_getchar()
{
    for (( g=0; g<${#DEC[@]}; g++ ))
    do
      if [ "$1" = "${CHARS[g]}" ]; then
        echo ${DEC[g]}
        break
      fi
    done
}

_print_card()
{
    str="$@"

    if [ ${#str} -gt $COLUMNS ]; then
      str=${str:0:COLUMNS}
    fi

    echo -n " "
    for ((i=0; i<=$COLUMNS; i++))
    do
      echo -n "_"
    done
    echo

    echo -n "/"
    for ((i=0; i<${#str}; i++))
    do
      p=$(_getchar ${str:i:1})
      if [ ${HOLES[p]} ]; then
        echo -n "${str:i:1}"
      else
        echo -n " "
      fi
    done
    while [ $((i++)) -lt $COLUMNS ]
    do
      echo -n " "
    done
    echo "|"

    for ((row=0; row<=11; row++))
    do
      echo -n "|"
      for ((i=0; i<${#str}; i++))
      do
        p=$(_getchar ${str:i:1})
        if [ $(_bit ${HOLES[p]} $((11 - row)) ) -ne 0 ]; then
          echo -n "]"
        else
          echo -n "${ROWCHARS[row]}"
        fi
      done
      while [ $((i++)) -lt $COLUMNS ]
      do
        echo -n "${ROWCHARS[row]}"
      done
      echo "|"
    done

    for ((i=0; i<=$COLUMNS; i++))
    do
      echo -n "_"
    done
    echo "|"
}

########################## END OF FUNCTIONS ############################

########################## PROGRAM START ###############################

case $1 in
  "")
    while read
    do
      _print_card "$REPLY"
    done
    ;;

  -[Hh]|--help)
    echo "$USAGE"
    exit
    ;;

   *)
    _print_card "$@"
    ;;
esac

################################ EOF ###################################
