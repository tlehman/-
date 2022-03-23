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
PROMPT="%F{green}%n@%m%f:%F{cyan}%~%f %% "

# flowlog is for logging what you are doing while in a state of flow. See the .readme.md for more
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

# Go language
if [ -d /usr/local/go ]; then 
	export PATH=$PATH:/usr/local/go/bin
fi
