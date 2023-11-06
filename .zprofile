# Aliases
alias ls='\ls -Gh'
alias ll='ls -al'
alias wget='curl -LO'
alias ldd='otool -L'
alias rsync='\rsync --exclude=.svn --exclude=.git --exclude=RCS'
alias vi='vim -b'

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Ruby
export PATH="$HOME/.rbenv/shims:$PATH"

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

# Switch between AWS account credentials
awsacctdir () {
  echo "$HOME/.awsacct/$1"
}

awsacct () {
  if [ $# -eq 1 ]; then
    local acct="$1"
    local acctdir=$(awsacctdir $acct)
    if [ ! -d $acctdir ]; then
      echo "Error: No such dir $acctdir" >&2
      unset AWS_ACCOUNT AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION
      return 1
    fi

    export AWS_ACCOUNT=$acct

    # Newer tools and unified CLI
    . $acctdir/access_keys.txt
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION

    ec2keypair # reset keys when switch accounts
  fi

  [ -t 0 ] && echo "AWS_ACCOUNT=$AWS_ACCOUNT"
}

#autoload -U promptinit && promptinit && prompt redhat

# Setting PATH for Python 3.12
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"
export PATH
