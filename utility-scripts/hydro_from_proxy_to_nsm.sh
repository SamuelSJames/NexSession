#!/bin/bash

# This script can be used to transform all hydrogen clients launched via proxy
# to clients launching directly hydrogen
# it applies this change to all sessions.

# This script works for Hydrogen but could not works for any client
# It depends on the way the client saves its files under NSM (in a folder..)
executable=hydrogen

if ! which nex_control >/dev/null;then
    echo "nex_control is missing, abort."
    exit 1
fi

all_sessions=`nex_control list_sessions`
ns=`echo "$all_sessions"|wc -l` #number of sessions

if [ -z "$all_sessions" ];then
    echo "No sessions...quit."
    exit 0
fi

# parse all sessions
for ((i=1; i<=$ns; i++));do
    session=`echo "$all_sessions"|sed -n ${i}p`
    
    # open session ('off' means -> without launching any client)
    if ! nex_control open_session_off "$session";then
        echo "failed to open session: $session"
        continue
    fi
    
    session_name=$(nex_control get_session_name)
    echo "treating session: $session"
    
    # parse all proxy clients of the session
    for client_id in `nex_control list_clients "executable:nex-proxy"`;do
        proxy_properties=`nex_control client $client_id get_proxy_properties`
        
        if ! echo "$proxy_properties"|grep ^"executable:$executable"$ >/dev/null;then
            # executable in the proxy is not hydrogen, skip it.
            echo "  skipping client $client_id"
            continue
        fi
        
        client_files=`nex_control client $client_id list_files`
        
        if [ -z "$client_files" ] || [ -z "$proxy_properties" ];then
            # No client files or error asking nex_control, skip.
            echo "  client untreated $client_id"
            continue
        fi
        
        if [ `echo "$client_files"|wc -l` != 1 ];then
            echo "  client untreated $client_id"
            echo "  A proxy should only contains one directory. and no more files."
            echo "$client_files"
            continue
        fi
        
        echo "  treating client $client_id"
        
        # here config_file is the *.h2song file (hydrogen project).
        config_file=$(echo "$proxy_properties" |grep ^"config_file:" |sed 's/^config_file://' \
                        |sed "s/\$NEX_SESSION_NAME/$session_name/g" \
                        |sed "s/\${NEX_SESSION_NAME}/$session_name/g")
        
        proxy_dir="$client_files"
        full_config_file="$proxy_dir/$config_file"
        
        if ! [ -f "$full_config_file" ];then
            echo "    file $full_config_file doesn't exists"
            continue
        fi
        
        config_file_short=`basename "$config_file"`
        
        extension="${config_file_short##*.}" # should be h2song here.
        config_file_base="${config_file_short%.*}" # the file name without .h2song
        
        # change executable from nex-proxy to hydrogen
        if ! nex_control client $client_id set_properties "executable:$executable";then
            echo "  abort for client $client_id. Impossible to change its executable."
            continue
        fi
        
        # move *.h2song file to the wanted path
        if ! mv "$full_config_file" "$proxy_dir.$extension";then
            echo "  Impossible to move $full_config_file to $proxydir.$extension. abort"
            
            # move didn't work, so reset client executable to nex-proxy
            nex_control client $client_id set_properties "executable:nex-proxy"
            continue
        fi
        
        # remove proxy directory if it only contains nex-proxy.xml
        if [[ `ls "$proxy_dir"` == 'nex-proxy.xml' ]];then
            rm -R "$proxy_dir"
        else
            echo "  $proxy_dir has not been removed because it still contains other files"
        fi
    done
done
        
        
        
