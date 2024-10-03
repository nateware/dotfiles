
# Must source manually
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# Old school 1986 style colors
# c1="\033["
# c2="m"
# c_normal="${c1}0${c2}"
# c_bold="${c1}1${c2}"
# c_black="${c1}0;30${c2}"
# c_blue="${c1}0;34${c2}"
# c_green="${c1}0;32${c2}"
# c_cyan="${c1}0;36${c2}"
# c_red="${c1}0;31${c2}"
# c_purple="${c1}0;35${c2}"
# c_brown="${c1}0;33${c2}"
# c_gray="${c1}0;37${c2}"
# c_dark_gray="${c1}1;30${c2}"
# c_bold_blue="${c1}1;34${c2}"
# c_bold_green="${c1}1;32${c2}"
# c_bold_cyan="${c1}1;36${c2}"
# c_bold_red="${c1}1;31${c2}"
# c_bold_purple="${c1}1;35${c2}"
# c_bold_yellow="${c1}1;33${c2}"
# c_bold_white="${c1}1;37${c2}"

# http://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm
C_BLACK=$(tput setaf 0)
C_RED=$(tput setaf 1)
C_GREEN=$(tput setaf 2)
C_YELLOW=$(tput setaf 3)
C_LIME_YELLOW=$(tput setaf 190)
C_POWDER_BLUE=$(tput setaf 153)
C_BLUE=$(tput setaf 4)
C_MAGENTA=$(tput setaf 5)
C_CYAN=$(tput setaf 6)
C_WHITE=$(tput setaf 7)
C_BRIGHT=$(tput bold)
C_NORMAL=$(tput sgr0)
C_BLINK=$(tput blink)
C_REVERSE=$(tput smso)
C_UNDERLINE=$(tput smul)

# Prompt
# The \[ \] parts are to fix bash prompt CLI issues
# http://askubuntu.com/questions/111840/ps1-problem-messing-up-cli
export PS1='[\[$C_BLUE\]\W\[$C_NORMAL\]]\[$C_GREEN\]\$\[$C_NORMAL\] '

#printf $C_RED
#type ruby
#printf $C_NORMAL

# Only vim on login; vi otherwise
export EDITOR='vim'

[ -s $HOME/.nvm/nvm.sh ] && . $HOME/.nvm/nvm.sh # This loads NVM
