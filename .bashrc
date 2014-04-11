
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
  [ -d "$1" ] || return 0
  if [ "$OS" = Darwin ]; then
    export DYLD_LIBRARY_PATH="$1:$DYLD_LIBRARY_PATH"
  else
    export LD_LIBRARY_PATH="$1:$DYLD_LIBRARY_PATH"
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
alias bi='bundle install --without=production:staging:assets'
alias bu='bundle update'
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
  elif [ -d "$1" ]; then
    # tab expansion
    pushd "$1"
  else
    # wildcard
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

# Android tools
add_path $HOME/Workspace/adt-bundle-mac-x86_64-20130522/sdk/platform-tools

# Ruby version manager
[ -s $HOME/.rvm/scripts/rvm ] && . $HOME/.rvm/scripts/rvm

# Node version manager
[ -s $HOME/.nvm/nvm.sh ] && . $HOME/.nvm/nvm.sh
[ -f $NVM_DIR/bash_completion ] && . $NVM_DIR/bash_completion

# rbenv
if type rbenv >/dev/null; then
  eval "$(rbenv init -)"
fi

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
    local reg=$1
    if [ "$reg" = default ]; then
      reg=$(<$EC2_ACCOUNT_DIR/default_region.txt)
      if [ $? -ne 0 ]; then
        echo "Warning: Defaulting to us-west-2 AWS region" >&2
        reg="us-west-2"
      fi
    fi

    export EC2_REGION=$reg
    export EC2_URL="http://ec2.$EC2_REGION.amazonaws.com"
    export AWS_DEFAULT_REGION=$EC2_REGION

    # My approach for ec2 is to launch with the custom "root" keypair,
    # but username may change based on AMI, so use just do ec2-user@whatevs
    export EC2_ROOT_KEY="$EC2_ACCOUNT_DIR/root-$EC2_REGION.pem"
    if [ ! -f "$EC2_ROOT_KEY" ]; then
      echo "Warning: EC2 key does not exist: $EC2_ROOT_KEY" >&2
    fi

    # To override root, use ubuntu@ or ec2-user@ or whatever
    ssh_cmd="ssh -i $EC2_ROOT_KEY -o StrictHostKeyChecking=no -l root"
    alias ash=$ssh_cmd
    alias async="rsync -av -e '$ssh_cmd'"
  fi

  [ -t 0 ] && echo "EC2_REGION=$EC2_REGION"
}

ec2acct () {
  if [ $# -eq 1 ]; then
    local acctdir="$HOME/.ec2/$1"
    if [ ! -d $acctdir ]; then
      echo "Error: No such dir $acctdir" >&2
      return 1
    fi

    export EC2_ACCOUNT=$1
    export EC2_ACCOUNT_DIR=$acctdir

    # Newer tools and unified CLI
    export AWS_ACCESS_KEY_ID=$(<$EC2_ACCOUNT_DIR/access_key_id.txt)
    export AWS_SECRET_ACCESS_KEY=$(<$EC2_ACCOUNT_DIR/secret_access_key.txt)

    # Old style per-service CLI's
    export AWS_CREDENTIAL_FILE="$EC2_ACCOUNT_DIR/credential-file-path"
  fi

  [ -t 0 ] && echo "EC2_ACCOUNT=$EC2_ACCOUNT"
}

# Set default EC2 region
if [ -d "$HOME/.ec2/default" ]; then
  what=$(readlink $HOME/.ec2/default)
  ec2acct $what
  ec2region default
fi

# Use garnaat's unified CLI
complete -C aws_completer aws # bash tab completion
paws (){
  aws "$@" | ruby -rjson -rawesome_print -e "ap JSON.parse(STDIN.read)"
}
complete -C aws_completer paws # bash tab completion

[ -f "$HOME/.git-completion.bash" ] && . "$HOME/.git-completion.bash"

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
      *.tar.gz|*.tgz)   tar xzvf $f;;
      *.tar.bz|*.tbz)   bunzip -c $f | tar xvf -;;
      *.tar.bz2|*.tbz2) bunzip2 -c $f | tar xvf -;;
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
  killall "$pn"
  sleep 2
  killall "$pn"
  sleep 3
  killall -9 "$pn"
}

# Postgres
if add_path /Library/PostgreSQL/9.0/bin; then
  . /Library/PostgreSQL/9.0/pg_env.sh
fi

export JVA=209.40.197.81
alias jva="ssh -l janetvanarsdale $JVA"
alias rjva="ssh -l root $JVA"

# Workaround for ruby 2.0.0 rubygems issue
alias chef-solo='unset GEM_HOME GEM_PATH && \chef-solo'
alias knife='unset GEM_HOME GEM_PATH && \knife'

# Still needed for old games
if [ -d "/usr/local/oracle/10.2.0.4/client" ]; then
  add_path_and_lib "$ORACLE_HOME/bin"
  export ORACLE_HOME="/usr/local/oracle/10.2.0.4/client"
  export TNS_ADMIN="$HOME/tnsadmin"  # Directory
  export NLS_LANG=".AL32UTF8"
fi

# For fucking with "go" the language
if [ -d $HOME/Workspace/go ]; then
  export GOROOT=$HOME/Workspace/go
  export GOOS=darwin
  export GOARCH=386
  export GOBIN=$HOME/bin
fi

### Added by the Heroku Toolbelt
add_path /usr/local/heroku/bin

# The next line updates PATH for the Google Cloud SDK.
. /Users/nateware/Workspace/google-cloud-sdk/path.bash.inc

# The next line enables bash completion for gcloud.
. /Users/nateware/Workspace/google-cloud-sdk/completion.bash.inc

alias gsh="ssh -i $HOME/.ssh/google_compute_engine -o StrictHostKeyChecking=no"
