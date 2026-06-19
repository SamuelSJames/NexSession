#!/bin/bash

########################################################################
#                                                                      #
#  Here you can edit the script runned                                 #
#  each time daemon order this session to be loaded                    #
#  WARNING: You can be here in a switch situation,                     #
#           some clients may be still alive                            #
#           if they are NSM compatible and capable of switch,          #
#           or if they are not NSM compatible at all                   #
#           but launched with NSM protocol.                            #
#                                                                      #
#  You have access the following environment variables                 #
#  NEX_SESSION_PATH : Folder of the current session                    #
#  NEX_SCRIPTS_DIR  : Folder containing this script                    #
#     nex-scripts folder can be directly in current session            #
#     or in a parent folder.                                           #
#  NEX_PARENT_SCRIPT_DIR : Folder containing the scripts that would    #
#     be runned if NEX_SCRIPTS_DIR would not exists                    #
#  NEX_SWITCHING_SESSION: 'true' or 'false'                            #
#     'true' if session is switching from another session              #
#     and probably some clients are still alive.                       #
#                                                                      #
#  To get any other session informations, refers to nex_control help   #
#     typing: nex_control --help                                       #
#                                                                      #
########################################################################



# script here some actions to run before loading the session.


# set this var true if you want all running clients to stop (see top of this file).
clear_all_clients=false

if $clear_all_clients;then
    nex_control script_info "Clearing clients..."
    nex_control clear_clients
    nex_control hide_script_info
fi

# order daemon to load the session
nex_control run_step


# script here some actions to run once the session is loaded.


