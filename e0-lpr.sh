#!/bin/bash

# Created by Michel Zimmer
#  https://github.com/michel-zimmer/e0-lpr
#  License: MIT
#
#  This script asks for printing options, copies the file over SSH, prints it and deletes it afterwards.

if [ "${#}" -ne 1 ]; then
    echo "Usage: ${0} filename"
    exit 0
fi

FILENAME="${1}"

if [ ! -f "${FILENAME}" ]; then
    echo "File not found: ${FILENAME}"
    exit 0
fi

if [ -z "${HOST+x}" ]; then
    HOST='x01.informatik.uni-bremen.de'
fi

ssh "${HOST}" -- 'echo "Printing from $( hostname -f )"'
ssh "${HOST}" -- pacc

STANDARD_PARAMETERS=true
PRINTER='lw0'
SIZE='A4'
DUPLEX='two-sided-long-edge'
COPIES=1

echo "Print using standard parameters (lw0, DIN A4, two-sided-long-edge, 1 cop\
y)? [Y/n]"
read -r STANDARD_PARAMETERS
case "${STANDARD_PARAMETERS}" in
    [yY])
        ;;
    '')
        ;;
    *)
        STANDARD_PARAMETERS=false
        ;;
esac

if [[ "${STANDARD_PARAMETERS}" = false ]]; then
    PS3='Select printer: '
    select OPT in 'lw0' 'lw1'; do
        case "${REPLY}" in
            1|2 )
                PRINTER="${OPT}"
                break
                ;;

            *)
                echo 'Please answer with "1" or "2".'
                continue
                ;;
        esac
    done

    PS3='Select paper size: '
    select OPT in 'DIN A4' 'DIN A3'; do
        case "${REPLY}" in
            1|2 )
                SIZE="${OPT}"
                break
                ;;

            *)
                echo 'Please answer with "1" or "2".'
                continue
                ;;
        esac
    done

    PS3='Select duplex options: '
    select OPT in 'one-sided' 'two-sided-long-edge' 'two-sided-short-edge'; do
        case "${REPLY}" in
            1|2|3 )
                DUPLEX="${OPT}"
                break
                ;;

            *)
                echo 'Please answer with "1", "2" or "3".'
                continue
                ;;
        esac
    done

    COPIES=0
    while [ ! "${COPIES}" -gt 0 ]; do
        printf 'Number of copies: '
        read -r COPIES
        if ! [[ "${COPIES}" =~ ^[0-9]+$ ]]; then
            COPIES=0
        fi
    done
fi

TMP="$( ssh ${HOST} -- mktemp --tmpdir=\"$\( pwd \)\" e0-lpr.sh.tmp.XXXXX )"
PARAMETERS="-P ${PRINTER} -# ${COPIES} -o sides=${DUPLEX} -o media=${SIZE}"

if [[ "${STANDARD_PARAMETERS}" = false ]]; then
    echo 'Print using the following parameters? [Y/n]'
    echo "${PARAMETERS}"
    read -r CONTINUE
    case "${CONTINUE}" in
        [yY])
            ;;
        '')
            ;;
        *)
            exit 0
            ;;
    esac
fi

scp "${FILENAME}" "${HOST}:${TMP}"
# shellcheck disable=SC2029
ssh "${HOST}" -- "lpr ${PARAMETERS} '${TMP}'"
# shellcheck disable=SC2029
ssh "${HOST}" -- "rm '${TMP}'"
