################################################################################
#   tobi's zsh config                                                          #
#                                                                              #
#                                                                              #
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
#                  Variables and variable-related utils                        #
################################################################################
export EDITOR=vim

# Prevent tmux from using vi keybindings:
#    http://matija.suklje.name/zsh-vi-and-emacs-modes
bindkey -e 

function paths() { echo $PATH | tr ':' '\n' | sort }
alias ls='/bin/ls --color'

if [[ -f ~/dl/local.yaml ]]; then
	export KUBECONFIG=~/dl/local.yaml
fi

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

