#!/bin/sh

#title:         menu.sh
#description:   Menu which allows multiple items to be selected
#==============================================================================

#Menu options
options[0]="LNMP/Redis/Libreoffice/Supervisord/Firewall/Ntp"
options[1]="Elasticsearch/Kibana/Filebeat"
options[2]="Mosquitto"
options[3]="Bolt"
options[4]="Docker ( Downloaded Location: /opt/face-detect.tar )"

if grep -q "SELINUX=enforcing" /etc/sysconfig/selinux
then
    options[5]="Close SELINUX (System restart required for close)"
fi

#Actions to take based on selection
function ACTIONS {
    if [[ ${choices[0]} ]]; then
        #Option 1 selected
        ./installScript/LNMPRedisLibreofficeSelinuxSupervisord.sh
    fi
    if [[ ${choices[1]} ]]; then
        #Option 2 selected
        ./installScript/ElasticsearchKibanaFilebeat.sh
    fi
    if [[ ${choices[2]} ]]; then
        #Option 3 selected
        ./installScript/Mosquitto.sh
    fi
    if [[ ${choices[3]} ]]; then
        #Option 4 selected
        ./installScript/Bolt.sh
    fi
     if [[ ${choices[4]} ]]; then
        #Option 5 selected
        ./installScript/Docker.sh
    fi

    if grep -q "SELINUX=enforcing" /etc/sysconfig/selinux
    then
        if [[ ${choices[5]} ]]; then
        #Option 6 selected
        ./installScript/Selinux.sh
        fi
    fi


}

#Variables
ERROR=" "

#Clear screen for menu
clear

#Menu function
function MENU {
    echo "Software Menu Options"
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$ERROR"

    if grep -q "SELINUX=enforcing" /etc/sysconfig/selinux
    then
         echo "Tip: SELINUX is enforcing"
    else
        echo "Tip: SELINUX is disabled"
    fi
}


#Menu loop
while MENU && read -e -p "Select the desired options using their number (again to uncheck, ENTER when done): " -n1 SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="+"
        fi
            ERROR=" "
    else
        ERROR="Invalid option: $SELECTION"
    fi
done

ACTIONS

