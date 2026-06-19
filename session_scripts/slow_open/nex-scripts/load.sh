#!/bin/bash

########################################################################
#                                                                      #
#  Here you can edit the script runned                                 #
#  each time daemon order this session to be loaded                    #
#  WARNING: You can be here in a switch situation,                     #
#           some clients may be still alive                            #
#           if they are NSM compatible and capable of switch           #
#           or if they are not NSM compatible at all                   #
#           and launched with NSM Protocol.                            #
#                                                                      #
#  You have access the following environment variables                 #
#  NEX_SESSION_PATH : Folder of the current session                    #
#  NEX_SCRIPTS_DIR  : Folder containing this script                    #
#     nex-scripts folder can be directly in current session            #
#     or in a parent folder.                                           #
#  NEX_PARENT_SCRIPT_DIR : Folder containing the scripts that would    #
#     be runned if NEX_SCRIPTS_DIR would not exists                    #
#                                                                      #
#  NEX_SWITCHING_SESSION: 'true' or 'false'                            #
#     'true' if session is switching from another session              #
#     and probably some clients are still alive.                       #
#                                                                      #
#  To get any other session informations, refers to nex_control help   #
#     typing: nex_control --help                                       #
#                                                                      #
########################################################################


# Load the session without start any client
nex_control run_step open_off

# Start all clients supposed to be started at session load
# But each time, wait the client to be ready to start the next
for client_id in nex_control list_clients auto_start;do
    nex_control client "$client_id" open
done
