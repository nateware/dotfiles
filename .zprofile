# Aliases
alias ls='\ls -Gh'
alias ll='ls -al'
alias wget='curl -LO'
alias ldd='otool -L'
alias rsync='\rsync --exclude=.svn --exclude=.git --exclude=RCS'
alias vi='vim -b'

# Homebrew
[ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Ruby
[ -d $HOME/.rbenv ] && export PATH="$HOME/.rbenv/shims:$PATH"


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

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -f "$HOME/.git-completion.zsh" ] && . "$HOME/.git-completion.zsh"

# Use garnaat's unified CLI
complete -C aws_completer aws # bash tab completion
paws (){
  aws "$@" | ruby -rjson -rawesome_print -e "ap JSON.parse(STDIN.read)"
}
complete -C aws_completer paws # bash tab completion


# My approach for ec2 is to launch instances with a custom "root" keypair,
# but the username may change based on AMI, so then just ssh ec2-user@whatevs
# Remember keypairs are mapped to IAM user + region so use both pieces.
ec2keypair () {
  local user="${1:-root}"

  if [ -z "$AWS_ACCOUNT" -o -z "$AWS_REGION" ]; then
    echo "Error: Set awsacct and awsregion before ec2keypair" >&2
    return 1
  fi
  local acctdir=$(awsacctdir $AWS_ACCOUNT)

  export EC2_ROOT_KEY="$acctdir/$user-$AWS_REGION.pem"
  if [ ! -f "$EC2_ROOT_KEY" ]; then
    echo "Warning: EC2 key does not exist: $EC2_ROOT_KEY" >&2
  fi

  # To override root, use ubuntu@ or ec2-user@ or whatever
  local ssh_cmd="ssh -i $EC2_ROOT_KEY -o StrictHostKeyChecking=no -l root"
  alias ash=$ssh_cmd
  alias async="rsync -av -e '$ssh_cmd'"
}

# Switch AWS regions
awsregion () {
  if [ $# -eq 1 ]; then
    export AWS_DEFAULT_REGION=$1
    export AWS_REGION=$1
    # ec2keypair # reset keys when switch regions
  fi

  [ -t 0 ] && echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
}

# Switch between AWS account credentials
awsacct () {
  if [ $# -eq 1 ]; then
    local acct="$1"
    local acctdir="$HOME/.awsacct/$1"
    if [ ! -d $acctdir ]; then
      echo "Error: No such dir $acctdir" >&2
      unset AWS_ACCOUNT AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION AWS_REGION
      return 1
    fi

    export AWS_ACCOUNT=$acct

    # Newer tools and unified CLI
    . $acctdir/access_keys.txt
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION AWS_REGION

    # ec2keypair # reset keys when switch accounts
  fi

  [ -t 0 ] && env | grep '^AWS_'
}

[ -d "$HOME/.awsacct/default" ] && awsacct `readlink "$HOME/.awsacct/default"`

# Prompt in zsh
autoload -U promptinit && promptinit && prompt redhat
