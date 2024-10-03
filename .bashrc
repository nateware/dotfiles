
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
if type rbenv >/dev/null 2>&1; then
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

# Switch between AWS account credentials
awsacct () {
  if [ $# -eq 1 ]; then
    local acct="$1"
    local acctdir=$(awsacctdir $acct)
    if [ ! -d $acctdir ]; then
      echo "Error: No such dir $acctdir" >&2
      unset AWS_ACCOUNT AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION AWS_REGION
      return 1
    fi

    export AWS_ACCOUNT=$acct

    # Newer tools and unified CLI
    . $acctdir/access_keys.txt
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION

    ec2keypair # reset keys when switch accounts
  fi

  [ -t 0 ] && env "AWS_ACCOUNT=$AWS_ACCOUNT" | grep '^AWS'
}

# Switch AWS regions
awsregion () {
  if [ $# -eq 1 ]; then
    export AWS_DEFAULT_REGION=$1
    ec2keypair # reset keys when switch regions
  fi

  [ -t 0 ] && echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
}

awsacctdir () {
  echo "$HOME/.awsacct/$1"
}

# My approach for ec2 is to launch instances with a custom "root" keypair,
# but the username may change based on AMI, so then just ssh ec2-user@whatevs
# Remember keypairs are mapped to IAM user + region so use both pieces.
ec2keypair () {
  local user="${1:-root}"

  if [ -z "$AWS_ACCOUNT" -o -z "$AWS_DEFAULT_REGION" ]; then
    echo "Error: Set awsacct and awsregion before ec2keypair" >&2
    return 1
  fi
  local acctdir=$(awsacctdir $AWS_ACCOUNT)

  export EC2_ROOT_KEY="$acctdir/$user-$AWS_DEFAULT_REGION.pem"
  if [ ! -f "$EC2_ROOT_KEY" ]; then
    echo "Warning: EC2 key does not exist: $EC2_ROOT_KEY" >&2
  fi

  # To override root, use ubuntu@ or ec2-user@ or whatever
  local ssh_cmd="ssh -i $EC2_ROOT_KEY -o StrictHostKeyChecking=no -l root"
  alias ash=$ssh_cmd
  alias async="rsync -av -e '$ssh_cmd'"
}

# Set default AWS region and account
export AWS_DEFAULT_REGION="us-west-2"
if [ -d "$HOME/.awsacct/default" ]; then
  what=$(readlink $HOME/.awsacct/default)
  awsacct $what
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

# GCE
if [ -d $HOME/Workspace/google-cloud-sdk ]; then
  # The next line updates PATH for the Google Cloud SDK.
  . $HOME/Workspace/google-cloud-sdk/path.bash.inc

  # The next line enables bash completion for gcloud.
  . $HOME/Workspace/google-cloud-sdk/completion.bash.inc

  alias gsh="ssh -i $HOME/.ssh/google_compute_engine -o StrictHostKeyChecking=no"
fi

