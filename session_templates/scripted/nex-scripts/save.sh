#!/bin/bash

########################################################################
#                                                                      #
#  Here you can edit the script runned each time the session is saved  #
#                                                                      #
#  You have access the following environment variables                 #
#  NEX_SESSION_PATH : Folder of the current session                    #
#  NEX_SCRIPTS_DIR  : Folder containing this script                    #
#     nex-scripts folder can be directly in current session            #
#     or in a parent folder                                            #
#  NEX_PARENT_SCRIPT_DIR : Folder containing the scripts that would    #
#     be runned if NEX_SCRIPTS_DIR would not exists                    #
#                                                                      #
#  To get any other session informations, refers to nex_control help   #
#     typing: nex_control --help                                       #
#                                                                      #
########################################################################


# script here some actions to run before saving the session

# This command orders to nex-daemon to save the session
# If you don't run it, session won't be saved
nex_control run_step

# alternatively, you can run the save command without saving the clients
# with the following command :
# nex_control run_step without_clients


# script here some actions to run after saving the session
