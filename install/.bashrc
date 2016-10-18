# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cdhdlog="cd /usr/local/hadoop/logs"
alias Aconda='source activate $1'
alias Dconda='source deactivate'


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Define environment variables
export PATH=$PATH:./:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin:/usr/local/java/bin
export JAVA_HOME=/usr/local/java
export CLASSPATH=/usr/local/hadoop/share/hadoop/hdfs:/usr/local/hadoop/share/hadoop/yarn:/usr/local/hadoop/share/hadoop/yarn/lib/
export HADOOP_PREFIX=/usr/local/hadoop
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
export YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop
export PYSPARK_PYTHON=python2.7
export PYTHONPATH=$HOME/develop/


# If miniconda is installed
if [ -d $HOME/miniconda ]
then
    export PATH=$PATH:/home/$user_login/miniconda/bin
    echo 
    echo "INFO miniconda:  Use 'source activate deepy ' to activate 'deepy' environment (loaded with numpy scikit-learn scipy) and 'source deactivate' to deactivate it"
    echo
fi

# if CUDA is installed, define its environment variables
if [ -L /usr/local/cuda ] 
then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"
    export CUDA_HOME=/usr/local/cuda
fi

# if Torch is installed, activate Torch
if [ -d $HOME/torch ]
then
    . $HOME/torch/install/bin/torch-activate
fi



function fw-allow {
	# Find the IP address of the remote SSH connecction to open the firewall
	ip=$(sudo grep -e "^.*Accepted.*$(whoami).* ssh2$" /var/log/auth.log  | tail -1 | cut -d" " -f11)
	echo "Opening the firewall on port 80 and 443 for your remote IP address $ip"
	sudo ufw allow proto tcp from $ip to any port 80
	sudo ufw allow proto tcp from $ip to any port 443
	sudo ufw reload
	sudo ufw status
        FIREWALL_PUPLIC_IP_ALLOWED=$ip
        export FIREWALL_PUPLIC_IP_ALLOWED
}

function fw-delete {
        if [ -z $FIREWALL_PUPLIC_IP_ALLOWED ] 
        then
		# is there a known IP address that has opened the firewall ? If so, use it to close the firewall
                echo "Trying to close the firewall on port 80 and 443 for your remote IP address $FIREWALL_PUPLIC_IP_ALLOWED"
		sudo ufw delete allow proto tcp from $FIREWALL_PUPLIC_IP_ALLOWED to any port 80
        	sudo ufw delete allow proto tcp from $FIREWALL_PUPLIC_IP_ALLOWED to any port 443
 		set -u $FIREWALL_PUPLIC_IP_ALLOWED
	else
        	# Find the IP address of my remote SSH connecction to try to close the firewall    	
		ip=$(sudo grep -e "^.*Accepted.*$(whoami).* ssh2$" /var/log/auth.log  | tail -1 | cut -d" " -f11)
		echo "Closing the firewall on port 80 and 443 for your remote IP address $ip"
        	sudo ufw delete allow proto tcp from $ip to any port 80
        	sudo ufw delete allow proto tcp from $ip to any port 443
	fi
        sudo ufw reload
        sudo ufw status
}

function hd-start {
	echo "Starting Hadoop/Yarn"
	start-dfs.sh  
	start-yarn.sh
        if [ -z $FIREWALL_PUPLIC_IP_ALLOWED ]
        then
		echo "Firewall appears to be already open on port 80 and 443 for your remote IP address $ip"
	else
		fw-allow
	fi
}

function hd-stop {
	echo "Stopping Hadoop/Yarn"
	stop-yarn.sh 
        stop-dfs.sh
	# We don't automatically close the firewall as the user might still need to access other services
	echo "Don't forget to close the firewall if needed !"
}

function jp-start {
	echo "Starting Jupyter notebook" 
	unset XDG_RUNTIME_DIR
	cd /home/hduser/develop
	jupyter notebook --no-browser > /dev/null 2>&1 &
}

function jp-stop {
        echo "Stopping Jupyter notebook"
	killall jupyter-notebook
}

