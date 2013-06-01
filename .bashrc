
# ~/.bashrc
umask 022

# Add to PATH but only if it exists
add_path () {
  err=0
  for p
  do
    if [ -d $p ]; then
      PATH="$p:$PATH"
    else
      err=1
    fi
  done
  return $err
}

# Add to LD_LIB_PATH adjusting for platform
add_lib () {
  if [ "$OS" = Darwin ]; then
    export DYLD_LIBRARY_PATH="$lib:$DYLD_LIBRARY_PATH"
  else
    export LD_LIBRARY_PATH="$lib:$DYLD_LIBRARY_PATH"
  fi
  return 0
}

# Guess
add_path_and_lib () {
  if add_path "$1"; then
    lib=${1%/bin}/lib
    add_lib $lib
  else
    return 1
  fi
}

# Aliases
alias ls='\ls -Gh'
alias ll='ls -al'
alias wget='curl -LO'
alias ldd='otool -L'
alias rsync='\rsync --exclude=.svn --exclude=.git --exclude=RCS'
alias vi='vim -b'

# Don't want to install rubydocs - TOO SLOW!
alias gi='gem install --no-ri --no-rdoc'
alias bi='bundle --without=production install'
alias bu='bundle --without=production update'
alias be='bundle exec'
alias ga='git ci -a -m'
alias gd='git pu && git push -f dev'
alias gp='git pu'
gap () {
  ga "$*" && gp
}
gapd () {
  gap "$*" && cap dev deploy
}

# Change to workspace directory
wd () {
  if [ $# -eq 0 ]; then
    pushd "$HOME/Workspace"
  else
    pushd "$HOME/Workspace/$1"*
  fi
}

# Platform goodness
export OS=`uname`
[ "$OS" = Darwin ] && export JAVA_HOME=/Library/Java/Home

# Remember add_path unshifts, so the one you want first should be last
add_path \
  /usr/local/git/bin \
  /usr/local/bin \
  /opt/local/sbin \
  /opt/local/bin \
  $HOME/sbin \
  $HOME/bin

# For ruby version manager
[ -s $HOME/.rvm/scripts/rvm ] && . $HOME/.rvm/scripts/rvm

# Load node version manager
[ -s $HOME/.nvm/nvm.sh ] && . $HOME/.nvm/nvm.sh

# rbenv
#if add_path $HOME/.rbenv/bin; then
  #eval "$(rbenv init -)"
#fi

# For Jeweler
export JEWELER_OPTS="--bundler --bacon --create-repo --user-name 'Nate Wiger' --user-email 'nwiger@gmail.com' --github-username nateware"

# ImageMagick
add_path_and_lib /usr/local/ImageMagick/bin

# MySQL
add_path_and_lib /usr/local/mysql/bin

# Self-contained Postgres.app
add_path /Applications/Postgres.app/Contents/MacOS/bin

# MongoDB
add_path /usr/local/mongodb/bin

# Amazon EC2 CLI tools (official locations)
export EC2_HOME=/usr/local/ec2-api-tools
add_path "$EC2_HOME/bin" || unset EC2_HOME
export RDS_HOME=/usr/local/rds-cli
add_path "$RDS_HOME/bin" || unset RDS_HOME

ec2region () {
  if [ $# -eq 1 ]; then
    export EC2_REGION=$1
    export EC2_URL="http://ec2.$EC2_REGION.amazonaws.com"
    export AWS_DEFAULT_REGION=$EC2_REGION
    ec2setenv
  fi
  tty -s && echo "EC2_REGION=$EC2_REGION"
}

ec2acct () {
  if [ $# -ge 1 ]; then
    export EC2_ACCOUNT=$1
    if [ $# -eq 2 ]; then
      ec2region $2
    else
      ec2setenv
    fi
  fi
  tty -s && echo "EC2_ACCOUNT=$EC2_ACCOUNT"
}

# Amazon EC2 gems
ec2setenv () {
  export AWS_ACCESS_KEY_ID=`cat $HOME/.ec2/$EC2_ACCOUNT/access_key_id.txt`
  export AWS_SECRET_ACCESS_KEY=`cat $HOME/.ec2/$EC2_ACCOUNT/secret_access_key.txt`

  export EC2_CERT=`ls -1 $HOME/.ec2/$EC2_ACCOUNT/cert-* | head -1`
  export EC2_PRIVATE_KEY=`echo $EC2_CERT | sed 's/cert-\(.*\).pem/pk-\1.pem/'`

  # New paradigm for ec2 is to use the custom keypair, but username may change
  export EC2_ROOT_KEY="$HOME/.ec2/$EC2_ACCOUNT/root-$EC2_REGION.pem"
  if [ ! -f "$EC2_ROOT_KEY" ]; then
    echo "Warning: EC2 key does not exist: $EC2_ROOT_KEY" >&2
  fi

  # To override root, use ubuntu@ or ec2-user@ or whatever
  ssh_cmd="ssh -i $EC2_ROOT_KEY -o StrictHostKeyChecking=no -l root"
  alias ash=$ssh_cmd
  alias async="rsync -av -e '$ssh_cmd'"
}

# Set default EC2 region
if [ -d "$HOME/.ec2" ]; then
  ec2acct work us-west-2
fi

# Use garnaat's unified CLI
complete -C aws_completer aws # bash tab completion
paws (){
  aws "$@" | ruby -rjson -rawesome_print -e "ap JSON.parse(STDIN.read)"
}
complete -C aws_completer paws # bash tab completion

# Easy unzipping
untar () {
  if [ "$#" -eq 0 ]; then
    echo "Usage: untar files ..." >&2
    return 1
  fi
  for f
  do
    case $f in
      *.zip) unzip $f;;
      *.tar.gz|*.tgz) tar xzvf $f;;
      *.tar.bz|*.tbz) bunzip -c $f | tar xvf -;;
      *) echo "Unsupported file type: $f" >&2;;
    esac
  done
}

# shortcut to kill processes that tend to suck
fuck () {
  local pn=
  case "$1" in
  chr*)  pn="Google Chrome";;
  cisc*) pn="Cisco AnyConnect Secure Mobility Client";;
  esac
  killall $pn
  sleep 2
  killall $pn
  sleep 3
  killall -9 $pn
}

# Postgres
if add_path /Library/PostgreSQL/9.0/bin; then
  . /Library/PostgreSQL/9.0/pg_env.sh
fi

export JVA=209.40.197.81
alias jva="ssh -l janetvanarsdale $JVA"
alias rjva="ssh -l root $JVA"

# Still needed for old games
export ORACLE_HOME="/usr/local/oracle/10.2.0.4/client"
if [ -d "$ORACLE_HOME" ]; then
  add_path "$ORACLE_HOME/bin"
  add_lib  "$ORACLE_HOME/lib"
  export TNS_ADMIN="$HOME/tnsadmin"  # Directory
  export NLS_LANG=".AL32UTF8"
fi

# For fucking with "go" the language
export GOROOT=$HOME/Workspace/go
export GOOS=darwin
export GOARCH=386
export GOBIN=$HOME/bin


