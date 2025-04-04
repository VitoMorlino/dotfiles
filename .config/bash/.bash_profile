
# cd backwards a number of directories up the tree
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# cd into a fuzzily-found directory in home folder
alias fd='fzf-dir'
alias fzf-dir='cd $(find $HOME/ -maxdepth 5 -mindepth 1 -type d | fzf)'

