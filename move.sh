#!/bin/sh

#title:         menu.sh
#description:   Menu which allows multiple items to be selected
#==============================================================================

#Menu options
options[0]="Move Mariadb"
options[1]="Move Elasticsearch"
options[2]="Move Mosquitto"
options[3]="Move Redis"

#Actions to take based on selection
function ACTIONS {
    if [[ ${choices[0]} ]]; then
        #Option 1 selected
        ./moveScript/moveMariadb.sh
    fi
    if [[ ${choices[1]} ]]; then
        #Option 2 selected
        ./moveScript/moveElasticsearch.sh
    fi
    if [[ ${choices[2]} ]]; then
        #Option 3 selected
        ./moveScript/moveMosquitto.sh
    fi
    if [[ ${choices[3]} ]]; then
        #Option 4 selected
        ./moveScript/moveRedis.sh
    fi

}

#Variables
ERROR=" "

#Clear screen for menu
clear

#Menu function
function MENU {
    echo "Menu Options"
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$ERROR"
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

