host=$1
ksFile=$2
aims2client remhost ${host}-out
aims2client remhost ${host}
aims2client addhost --hostname ${host}-out --kickstart $ksFile --kopts  "text network ks ksdevice=bootif latefcload" --pxe --name slc6X_x86_64
