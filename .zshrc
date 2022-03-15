case `uname` in
	Darwin)

	eval "$(/opt/homebrew/bin/brew shellenv)"
	export PATH=$PATH:~/Downloads/cwebx/
	alias code='open -a Visual\ Studio\ Code'
	
	;;
	Linux)
esac

# K8s auto-complete
autoload -U +X compinit && compinit
source <(kubectl completion zsh)
source <(kind completion zsh)

PROMPT="%F{green}%n@%m%f:%F{cyan}%~%f %% "

# this option recomputes the PS1 prompt on every line
