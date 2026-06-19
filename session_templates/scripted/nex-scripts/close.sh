#!/bin/bash

########################################################################
#                                                                      #
#  Here you can edit the script runned                                 #
#  each time daemon order this session to be closed                    #
#  WARNING: You can be here in a switch situation,                     #
#           a session can be opened just after.                        #
#                                                                      #
#  You have access the following environment variables                 #
#  NEX_SESSION_PATH : Folder of the current session                    #
#  NEX_FUTURE_SESSION_PATH: Folder of the session that will be opened  #
#     just after current session close.                                #
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


# script here some actions to run before closing the session.


# some clients may keep alive because
# they are needed by the session to open just after.
# if for some reasons you want all clients to stop
# set this variable true !
close_all_clients=false



if $close_all_clients;then
    # This command orders to nex-daemon to close the session closing all clients
    # even if a session has to be opened just after.
    nex_control run_step close_all
else
    # This command orders to nex-daemon to close the session
    # If you don't run it, session will be closed after running the script
    nex_control run_step
fi



# script here some actions to run once the session is closed


