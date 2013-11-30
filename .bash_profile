
# Must source manually
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# Colors!
c1="\033["
c2="m"
c_normal="${c1}0${c2}"
c_bold="${c1}1${c2}"
c_black="${c1}0;30${c2}"
c_blue="${c1}0;34${c2}"
c_green="${c1}0;32${c2}"
c_cyan="${c1}0;36${c2}"
c_red="${c1}0;31${c2}"
c_purple="${c1}0;35${c2}"
c_brown="${c1}0;33${c2}"
c_gray="${c1}0;37${c2}"
c_dark_gray="${c1}1;30${c2}"
c_bold_blue="${c1}1;34${c2}"
c_bold_green="${c1}1;32${c2}"
c_bold_cyan="${c1}1;36${c2}"
c_bold_red="${c1}1;31${c2}"
c_bold_purple="${c1}1;35${c2}"
c_bold_yellow="${c1}1;33${c2}"
c_bold_white="${c1}1;37${c2}"

# Prompt
#export PS1='[\u@\h:\W]\$ '
#export PS1="[$c_green\u$c_normal@$c_purple\h$c_normal:$c_blue\W$c_normal]\\\$ "
export PS1='[\W]\$ '

printf $c_red
type ruby
printf $c_normal

# Only sublime on login; vi otherwise
export EDITOR='subl -w'


[ -s $HOME/.nvm/nvm.sh ] && . $HOME/.nvm/nvm.sh # This loads NVM
