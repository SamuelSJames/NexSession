#!/bin/bash

true_or_false(){
    if [ -n "$1" ];then
        [[ "${1,,}" != false ]] && echo true || echo false
    elif [ -n "$2" ];then
        echo "$2"
    else
        echo false
    fi
}

operation="$1"
shift

if [ -z "$NEX_SESSION_PATH" ];then
    possible_sesspath="$1"
    if [ -n "$possible_sesspath" ];then
        NEX_SESSION_PATH="$possible_sesspath"
    fi
fi

if [ -z "$NEX_SESSION_PATH" ];then
    case "$operation" in
        load|save)
            echo "this script has to be used by nex session scripts or this way :
$0 operation [SESSION_PATH]
where operation can be 'load', 'save', 'putback','get_diff' or 'set_jack_parameters'" >/dev/stderr
            exit 1
            ;;
    esac
fi

[ -z "$NEX_SWITCHING_SESSION" ] && NEX_SWITCHING_SESSION=false

NEX_MANAGE_PULSEAUDIO=$(true_or_false "$NEX_MANAGE_PULSEAUDIO" true)
NEX_JACK_RELIABILITY_CHECK=$(true_or_false "$NEX_JACK_RELIABILITY_CHECK" true)
NEX_HOSTNAME_SENSIBLE=$(true_or_false "$NEX_HOSTNAME_SENSIBLE" true)

cd "$(dirname "`readlink -f "$(realpath "$0")"`")"

case "$operation" in
    load )
        source ./load_config.sh
        ;;
    save )
        source ./save_config.sh
        ;;
    putback )
        source ./putback_config.sh
        ;;
    get_diff )
        source ./get_diff.sh
        ;;
    set_jack_parameters )
        source ./set_jack_parameters.sh
        ;;
esac

exit 0
