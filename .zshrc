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

# Go language
if [ -d /usr/local/go ]; then 
	export PATH=$PATH:/usr/local/go/bin
fi
