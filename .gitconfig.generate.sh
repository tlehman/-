#!/bin/sh
# Generate your global gitconfig from a yaml file and this template

GPG_SIGNING_KEY=$(yq '.signingkey' < .gitconfig.local.yaml)
GIT_EMAIL=$(yq '.email' < .gitconfig.local.yaml)

echo "[user]
	name = Tobi Lehman
	email = $GIT_EMAIL
	signingkey = $GPG_SIGNING_KEY
[alias]
	s = status
	a = add
	b = branch
	lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
	co = checkout
[init]
	defaultBranch = main
" > ~/.gitconfig

