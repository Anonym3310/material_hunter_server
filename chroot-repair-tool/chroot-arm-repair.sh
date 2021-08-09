#!/system/bin/sh

ohayo=$(readlink -f $0)
. ${ohayo%/*}/environment

code_chroot() {
    [ ! -f $MNT/usr/bin/sudo ] && echo "[-] sudo binary error (not installed)." && return 1
    if ! $BUSYBOX chroot $MNT /usr/bin/uname; then
        echo "[-] $MNT not a chroot."
        return 1
    fi
    return 0
}

f_isAllReady(){
    local FS
    FS=(proc sys dev dev/pts)
    for i in "${FS[@]}"; do
        if [ "$(grep $MNT/$i /proc/mounts)" ]; then
            echo "[+] $i was mounted already."
            continue
        else
            echo "[-] FS is NOT all mounted yet."
            return 1
        fi
    done
    [ ! -e "/dev/net/tun" ] && return 1
    [ ! -e "/dev/fd" -o ! -e "/dev/stdin" -o ! -e "/dev/stdout" -o ! -e "/dev/stderr" ] && return 1
    echo "[+] The Chroot has been started already and not corruption detected." && return 0
}

f_mount_fs() {

    ######### SET FD, Thanks @feefik and @zer0conf ########
    if [ ! -e "/dev/fd" -o ! -e "/dev/stdin" -o ! -e "/dev/stdout" -o ! -e "/dev/stderr" ]; then
        [ -e "/dev/fd" ] || ln -s /proc/self/fd /dev/ && echo "[+] linked /proc/self/fd to /dev/"
        [ -e "/dev/stdin" ] || ln -s /proc/self/fd/0 /dev/stdin && echo "[+] linked /proc/self/fd/0 to /dev/stdin"
        [ -e "/dev/stdout" ] || ln -s /proc/self/fd/1 /dev/stdout && echo "[+] linked /proc/self/fd/1 to /dev/stdout"
        [ -e "/dev/stderr" ] || ln -s /proc/self/fd/2 /dev/stderr && echo "[+] linked /proc/self/fd/2 to /dev/stderr"
    fi

    ######### SET TUN ########
    if [ ! -e "/dev/net/tun" ]; then
        [ ! -d "/dev/net" ] && mkdir -p /dev/net
        mknod /dev/net/tun c 10 200 && echo "[+] created /dev/net/tun"
    fi

    ######### SET DEV ########
    if [ ! "$($BUSYBOX mountpoint $MNT/dev 2> /dev/null | grep 'is a')" ]; then
        [ -d $MNT/dev ] && rm -rf $MNT/dev
        [ ! -d $MNT/dev ] && mkdir -p $MNT/dev
        $BUSYBOX mount -o bind /dev $MNT/dev && echo "[+] mounted /dev"
    fi

    ######### SET DEV PTS ########
    if [ ! "$($BUSYBOX mountpoint $MNT/dev/pts 2> /dev/null | grep 'is a')" ]; then
        $BUSYBOX mount -t devpts devpts $MNT/dev/pts && echo "[+] mounted /dev/pts"
    fi

    ######### SET DEV SHM ########
    if [ ! "$($BUSYBOX mountpoint $MNT/dev/shm 2> /dev/null | grep 'is a')" ]; then
        [ ! -d $MNT/dev/shm ] && mkdir -p $MNT/dev/shm
        $BUSYBOX mount -o rw,nosuid,nodev,mode=1777 -t tmpfs tmpfs $MNT/dev/shm && echo "[+] mounted /dev/shm"
    fi

    ######### SET PROC ########
    if [ ! "$($BUSYBOX mountpoint $MNT/proc 2> /dev/null | grep 'is a')" ]; then
        [ -d $MNT/proc ] && rm -rf $MNT/proc
        [ ! -d $MNT/proc ] && mkdir -p $MNT/proc
        $BUSYBOX mount -t proc proc $MNT/proc && echo "[+] mounted /proc"
    fi

    ######### SET SYS ########
    if [ ! "$($BUSYBOX mountpoint $MNT/sys 2> /dev/null | grep 'is a')" ]; then
        [ -d $MNT/sys ] && rm -rf $MNT/sys
        [ ! -d $MNT/sys ] && mkdir -p $MNT/sys
        $BUSYBOX mount -t sysfs sys $MNT/sys && echo "[+] mounted /sys"
    fi

    ######### SET DNS ########
    echo "nameserver 8.8.8.8" | tee -a $MNT/etc/resolv.conf
    echo "nameserver 8.8.4.4" | tee -a $MNT/etc/resolv.conf

    chmod 644 $MNT/etc/resolv.conf

    ######### SET NETWORK AND HOSTNAME ########
    $BUSYBOX sysctl -w net.ipv4.ip_forward=1
    echo "127.0.0.1		 localhost chrootrepair"                              > $MNT/etc/hosts
    echo "::1				 localhost ip6-localhost ip6-loopback"         >> $MNT/etc/hosts
    echo "chrootrepair"                                                                           > $MNT/proc/sys/kernel/hostname


    echo "[+] The Chroot has been mounted. Doing fixes now..."
}

echo "[!] Checking chroot environment."
code_chroot
RES=$?
if [ $RES -eq 1 ]; then
    echo "[*] Error in chroot detected."
else
    echo "[*] Critical errors doesn't found but, continuing..."
fi

f_isAllReady
RES=$?
if [ $RES -eq 1 ]; then
    echo "[!] Mounting fs to chroot."
    f_mount_fs
fi

clear
## Combine android $PATH to chroot $PATH
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
echo "
Now you can work and adjust the choot as you need.
We remind you that if the system does not have an apt key, you can use a protection bypass:

apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update

Do not forget to return everything to its original form by changing the boolean to the false!
"
$BUSYBOX chroot $MNT /usr/bin/su -c bash
