
# ~/.bashrc
umask 022

alias ls='\ls -Gh'
alias ll='ls -al'
alias wget='curl -LO'
alias ldd='otool -L'
alias rsync='\rsync --exclude=.svn --exclude=.git --exclude=RCS'

# Don't want local rubydocs - TOO SLOW!
alias gi='gem install --no-ri --no-rdoc'
alias bd='bundle --without=production'
alias be='bundle exec'

# Platform goodness
export OS=`uname`
[ "$OS" = Darwin ] && export JAVA_HOME=/Library/Java/Home

# For ruby version manager
[ -s $HOME/.rvm/scripts/rvm ] && . $HOME/.rvm/scripts/rvm

# For Jeweler
export JEWELER_OPTS="--bundler --bacon --create-repo --user-name 'Nate Wiger' --user-email 'nate@wiger.org' --github-username nateware --github-token `cat $HOME/.github-token`"

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

# ImageMagick
add_path_and_lib /usr/local/ImageMagick/bin

# MySQL
add_path_and_lib /usr/local/mysql/bin

# MongoDB
add_path /usr/local/mongodb/bin

# Amazon EC2 CLI tools
export EC2_HOME=/usr/local/ec2-api-tools
add_path "$EC2_HOME/bin" || unset EC2_HOME

# Amazon EC2 gems
if [ -d "$HOME/.ec2" ]; then
  export EC2_PRIVATE_KEY="$HOME/.ec2/pk-UO255XUYVOVVBXUWADA57YCL7XZZKQDE.pem"
  export EC2_CERT="$HOME/.ec2/cert-UO255XUYVOVVBXUWADA57YCL7XZZKQDE.pem"
  ec2_user=`cat $HOME/.ec2/ec2_user.txt`
  alias ess="ssh -i $HOME/.ec2/id_rsa-$ec2_user-keypair -o StrictHostKeyChecking=no -l root"
  alias esync="rsync -av -e 'ssh -i $HOME/.ec2/id_rsa-$ec2_user-keypair -o StrictHostKeyChecking=no -l root'"
  alias pss="ssh -i $HOME/.ec2/id_rsa-$ec2_user-user -o StrictHostKeyChecking=no -l $ec2_user"
  alias psync="rsync -av -e 'ssh -i $HOME/.ec2/id_rsa-$ec2_user-user -o StrictHostKeyChecking=no -l $ec2_user'"

  # For amazon-ec2 gem
  export AMAZON_ACCESS_KEY_ID=`cat $HOME/.ec2/access_key_id.txt`
  export AMAZON_SECRET_ACCESS_KEY=`cat $HOME/.ec2/secret_access_key.txt`
fi

if add_path /Library/PostgreSQL/9.0/bin; then
  . /Library/PostgreSQL/9.0/pg_env.sh
fi

# Remember add_path prefixes, so the one you want first should be last
add_path \
  /usr/local/pgsql/bin \
  /usr/local/git/bin \
  /usr/local/bin \
  /opt/local/sbin \
  /opt/local/bin \
  $HOME/sbin \
  $HOME/bin

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

