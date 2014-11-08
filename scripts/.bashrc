# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

source /afs/cern.ch/sw/IntelSoftware/linux/all-setup.sh &>/dev/null
#source /sw/compilers/IntelSoftware/linux/all-setup.sh &>/dev/null


#source /afs/cern.ch/sw/lcg/contrib/gcc/4.9.0/x86_64-slc6/setup.sh &>/dev/null
#source /sw/compilers/gcc/4.9.0/x86_64-slc6/setup.sh  /sw/compilers/ &>/dev/null
source /sw/compilers/gcc/4.8.0/x86_64-slc6/setup.sh  /sw/compilers/ &>/dev/null

## ICC is not compatible with 4.9.0
##source /afs/cern.ch/sw/lcg/contrib/gcc/4.8.0/x86_64-slc6/setup.sh &>/dev/null

source /etc/sysconfig/dim &>/dev/null

