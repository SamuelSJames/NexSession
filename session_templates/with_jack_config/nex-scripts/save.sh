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

# set it to 'false' if you want the script
# not to handle the ports of the PulseAudio -> JACK bridge
export NEX_MANAGE_PULSEAUDIO=true

# set it to 'false' if you want the script
# if you want the script to trust the parameters of JACK
export NEX_JACK_RELIABILITY_CHECK=true

# set it to 'false' if you want the script to not consider hostname
# then, a session can not be open on another machine
# if it doesn't have the same sound interface
export NEX_HOSTNAME_SENSIBLE=true

nex-jack_config_script save
nex_control run_step
exit 0
