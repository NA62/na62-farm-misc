read -p "PC base name: " pc; echo
read -p "First PC num: " first; echo
read -p "Last PC num: " last; echo
read -p "User: " user; echo
stty -echo
read -p "Password: " password; echo
read -p "New Password: " newPassword; echo
stty echo

for i in `seq $first $last`
do
	ipmitool -H $pc$i-ipmi -U $user -P $password user set name 3 root
	ipmitool -H $pc$i-ipmi -U $user -P $password user set password 2 $newPassword
	ipmitool -H $pc$i-ipmi -U $user -P $newPassword user set password 3 $newPassword
	ipmitool -H $pc$i-ipmi -U $user -P $newPassword user enable 3
	ipmitool -H $pc$i-ipmi -U $user -P $newPassword user priv 3 4
done
