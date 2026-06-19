#!/bin/bash

nex_control get_session_path >/dev/null || exit 1

trashed_clients=`nex_control list_trashed_clients`
for trashed in $trashed_clients;do
    nex_control trashed_client $trashed remove_definitely
done