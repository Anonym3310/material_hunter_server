#! /bin/sh
######### Checking paranoid network #########
MNT="/data/local/nhsystem/kali-arm64"
echo "[!] Checking paranoid network..."
if [ -f "/proc/config.gz" ]; then
    config="CONFIG_ANDROID_PARANOID_NETWORK"
    get_result=`zcat /proc/config.gz | grep $config`
    if [ -z get_result ]; then
        echo "[!] Paranoid network not detected in kernel, skipping..."
    else
        echo "[+] Paranoid network detected, setting up inet..."
        if [ -f "$MNT/etc/group" ]; then
            check_inet=`egrep -w "android_inet|aid_inet" $MNT/etc/group`
            check_group=`grep -w "3003" $MNT/etc/group`
            grep_gi=`echo $check_inet | grep "3003"`
            if [ -z $check_inet ]; then
                echo "[!] Android inet group not found! Adding..."
                if [ ! -z $check_group ]; then
                    # Group 3003 is found
                    if [ -z $grep_gi ]; then
                        echo "[-] Group 3003 is busy and it isn't at Android inet. Skipping..."
                    else
                        echo "inet:x:3003:root" | tee -a $MNT/etc/group
                    fi
                fi
            else
                sed -i s/"$(echo $check_inet | cut -d ":" -f 1)"/"inet"/g $MNT/etc/group
                echo "[+] Adding inet (3003) group done."
            fi
        else
            echo "/etc/group file doesn't exist"
        fi
    fi
else
    echo "[!] Config file not found, skipping..."
fi
