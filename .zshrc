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
#                  Variables                                                   #
################################################################################
export EDITOR=vim

################################################################################
#                  Git info in the prompt                                      #
################################################################################
# Load version control information
autoload -Uz vcs_info
precmd() {
	# Format the vcs_info_msg_0_ variable
	zstyle ':vcs_info:*' check-for-changes true
	
	# if there are no uncommitted changes
	if command git diff --quiet HEAD 2> /dev/null; then
		zstyle ':vcs_info:git:*' formats 'git:%b'
	elif [[ $(git status --short | grep '^[M ]M' | wc -l) -gt 0 ]]; then
		# Show red if there are ANY unstanged changes
		zstyle ':vcs_info:git:*' formats 'git:%b%F{red}*%f'
	elif [[ $(git status --short | grep '^\W.' | wc -l) -eq 0 ]]; then
		# If everything is staged, show a green *
		if [[ $(git status --short | grep '^\w.' | wc -l) -gt 0 ]]; then
			zstyle ':vcs_info:git:*' formats 'git:%b%F{green}*%f'
		fi
	fi

 
	vcs_info
}

# Set up the prompt (with git branch name)
setopt PROMPT_SUBST

# The prompts
PROMPT="%F{green}%n@%m%f:%F{cyan}%~%f %% "
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
	export PATH=$PATH:/usr/local/go/bin
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
