################################################################################
#   tobi's zsh config                                                          #
#                                                                              #
#                                                                              #
################################################################################
#                  Variables and variable-related utils                        #
################################################################################
export EDITOR=vim

# Prevent tmux from using vi keybindings:
#    http://matija.suklje.name/zsh-vi-and-emacs-modes
bindkey -e 

function paths() { echo $PATH | tr ':' '\n' | sort }
alias ls='/bin/ls --color'

if [[ -f ~/etc/local.yaml ]]; then
	export KUBECONFIG=~/etc/local.yaml
fi
if [[ -d ~/bin ]]; then
	export PATH=$PATH:~/bin
fi

################################################################################
#                  ZSH history                                                 #
################################################################################
export HISTFILE=/home/tobi/.zhistory
export HISTSIZE=10000
export SAVEHIST=50000
# Appends every command to the history file once it is executed
setopt inc_append_history
# Reloads the history whenever you use it
setopt share_history


################################################################################
#                  OS-specific stuff                                           #
################################################################################
case `uname` in
	Darwin)

	eval "$(/opt/homebrew/bin/brew shellenv)"
	export PATH=$PATH:~/Downloads/cwebx/
	alias code='open -a Visual\ Studio\ Code'
	
	# K8s auto-complete
	autoload -U +X compinit && compinit
	source <(kubectl completion zsh)
	source <(kind completion zsh)
	;;
	Linux)
esac
################################################################################
#                  Tab completion                                              #
################################################################################
autoload -U +X compinit && compinit
source <(kubectl completion zsh)
if command which helm &> /dev/null; then
	source <(helm completion zsh)
fi

################################################################################
#                  Check dependencies                                          #
################################################################################
typeset -a DEPS
DEPS=("zsh" "git" "ssh" "tmux" "jq" "fq" "yq" "fzf")
for ((i = 1; i <= $#DEPS; i++)) {
	if command which $DEPS[i] &> /dev/null; then
		# yay, nothing to do here
	else
		dep=$DEPS[i]
		print "$dep is not installed"
    fi
}
################################################################################
#                  Git info in the prompt                                      #
################################################################################
# git aliases
alias g=git
# Load version control information
autoload -Uz vcs_info
precmd() {
	# Format the vcs_info_msg_0_ variable
	zstyle ':vcs_info:*' check-for-changes true
	
	# Only run this if you are actually _in_ a git repo
	if command git rev-parse --is-bare-repository 2> /dev/null > /dev/null; then
		# show first 4 chars of HEAD commit
		head=$(git rev-parse HEAD | cut -c -4)
		git="git($head…)"
		# if there are no uncommitted changes
		if command git diff --quiet HEAD 2> /dev/null; then
			zstyle ':vcs_info:git:*' formats "$git:%b"
		elif [[ $(git status --short | grep '^[M ]M' | wc -l) -gt 0 ]]; then
			# Show red if there are ANY unstanged changes
			zstyle ':vcs_info:git:*' formats "$git:%b%F{red}*%f"
		elif [[ $(git status --short | grep '^\W.' | wc -l) -eq 0 ]]; then
			# If everything is staged, show a green *
			if [[ $(git status --short | grep '^\w.' | wc -l) -gt 0 ]]; then
				zstyle ':vcs_info:git:*' formats "$git:%b%F{green}*%f"
			fi
		fi
	fi
 
	vcs_info
}


################################################################################
#                  Kubernetes (k8s, K8s, k3s, etc,)                            #
################################################################################
# k8s aliases
#alias k='kubectl --insecure-skip-tls-verify'
alias k=kubectl
if ! command $(type -p "helm" > /dev/null); then
	source <(kubectl completion zsh)
	source <(helm completion zsh)
fi

################################################################################
#                  The PROMPTS                                                 #
################################################################################
setopt PROMPT_SUBST
#PROMPT="%F{green}%n@%m%f:%F{cyan}%~%f %% "


# https://unix.stackexchange.com/a/273567 (shorten pwd after 4 levels deep)
PROMPT="%F{green}%n@%m%f:%F{cyan}%(4~|.../%3~|%~)%f %% "
RPROMPT="%F{yellow}\$vcs_info_msg_0_%f"

# Current Kubernetes Context
kubectx() { k config view --minify | yq .current-context }

if command kubectl --insecure-skip-tls-verify config view >/dev/null; then 
	RPROMPT="$RPROMPT %F{cyan}k8s⎈ \$(kubectx)%f"
fi

################################################################################
#                  Flowlog                                                     #
################################################################################
# flowlog is for logging what you are doing while in a state of flow. 
# See the .readme.md for more
# RECOMMENDED: bind this to a key like <F9>
flowlog () {
	echo "$(date +'%Y-%m-%d %H:%M') $(zenity --entry)" >> ~/.flowlog
	# NOTE: ~/.flowlog should be local, not checked into the repo, 
    # the goal is a log you can revisit, clean up and summarize 
    # in your central note-keeping software
}
alias fl=flowlog
if [ -f ~/.flowlog ]; then
	print "There are $(wc -l ~/.flowlog | awk '{print $1}') lines in .flowlog, please process and delete the file"
fi

################################################################################
#                  Go language settings                                        #
################################################################################
if [ -d /usr/local/go ]; then 
	export PATH=$PATH:~/go/bin:/usr/local/go/bin
fi

################################################################################
#                  Hue bulbs                                                   #
################################################################################
hue_api_get() {
	curl -s "http://lights/api/$(cat /etc/hueuser)/lights" 
}
hue_lights_ls_on() {
	hue_api_get | jq '.[] | {name: .name, on: .state.on} | select(.on == true)'
}
hue_lights_ls_off() {
	hue_api_get | jq '.[] | {name: .name, on: .state.on} | select(.on == false)'
}
hue_set() {
	curl -s -X PUT "http://lights/api/$(cat /etc/hueuser)/lights/$1/state" -d "{\"on\": $2}"
}
office_off() {
	for light in $(seq 24 26); do hue_set $light false; done
}
office_on() {
	for light in $(seq 24 26); do hue_set $light true; done
}

################################################################################
#                  Time                                                        #
################################################################################
function nows() { date -u "+%Y-%m-%d %R UTC"; date "+%Y-%m-%d %R %Z"; }

################################################################################
#                  Buffer shortcuts                                            #
################################################################################
function buffer-insert-date() {
	BUFFER+="$(date +'%Y-%m-%d')"
}
function buffer-insert-datetime() {
	BUFFER+="$(date +'%Y-%m-%d %H:%M:%S')"
}
function buffer-insert-192-168-1() {
	LBUFFER+="192.168.1."
}
function buffer-kubectl-get-expand() {
	if [ "$BUFFER" = "kgs" ]; then
		zle backward-delete-word
		BUFFER+='k get services'
	elif [ "$BUFFER" = "kgn" ]; then
		zle backward-delete-word
		BUFFER+='k get nodes'
	elif [ "$BUFFER" = "kgp" ]; then
		zle backward-delete-word
		BUFFER+='k get pods'
	elif [ "$BUFFER" = "kc" ]; then
		zle backward-delete-word
		BUFFER+='k cluster-info'
	fi
}
# type 'lsth' and then <Alt>-l to expand and enter
function buffer-accept-line-expand-ls() {
	if [ "$BUFFER" = "lsth" ]; then
		zle backward-delete-word
		BUFFER+='ls -t | head -4'
		zle accept-line
	fi
}
zle -N buffer-insert-date
zle -N buffer-insert-datetime
zle -N buffer-kubectl-get-expand
zle -N buffer-insert-192-168-1
zle -N buffer-accept-line-expand-ls
bindkey $'^T' buffer-insert-date
#bindkey $'^[d' buffer-insert-datetime <alt>-d is delete, don't override it
bindkey $'^[k' buffer-kubectl-get-expand
bindkey $'^[9' buffer-insert-192-168-1
bindkey $'^[l' buffer-accept-line-expand-ls
