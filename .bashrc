
# ~/.bashrc
umask 022
export PS1='[\u@\h:\W]\$ '

alias ls='\ls -Gh'
alias ll='ls -al'
alias wget='curl -LO'
alias ldd='otool -L'
alias rsync='\rsync --exclude=.svn --exclude=.git --exclude=RCS'

# Don't want local rubydocs - TOO SLOW!
alias gi='gem install --no-ri --no-rdoc'
alias bd='bundle --without=production'

# For ruby version manager
[ -s $HOME/.rvm/scripts/rvm ] && . $HOME/.rvm/scripts/rvm

# For Jeweler
export JEWELER_OPTS='--bacon --create-repo --gemcutter'

# ImageMagick
export PATH="/usr/local/ImageMagick/bin:$PATH"
export DYLD_LIBRARY_PATH="/usr/local/ImageMagick/lib"

# MySQL
export PATH="/usr/local/mysql/bin:$PATH"
export DYLD_LIBRARY_PATH="/usr/local/mysql/lib"

# MongoDB
export PATH="$PATH:/usr/local/mongodb/bin"

# For Amazon EC2
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

# Tools for EC2
export EC2_HOME=/usr/local/ec2-api-tools
export PATH="$PATH:$EC2_HOME/bin"
export JAVA_HOME=/Library/Java/Home

# Put our ~/bin *first*
export PATH=`echo "
  $HOME/bin
  $HOME/sbin
  /opt/local/bin
  /opt/local/sbin
  /usr/local/bin
  /usr/local/git/bin
  /usr/local/pgsql/bin
  $PATH 
" | tr -s '[:space:]' ':'`

export JVA=209.40.197.81
alias jva="ssh -l janetvanarsdale $JVA"
alias rjva="ssh -l root $JVA"

# Still needed for old games
export ORACLE_HOME="/usr/local/oracle/10.2.0.4/client"
export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$ORACLE_HOME/lib"
export TNS_ADMIN="$HOME/tnsadmin"  # Directory
export NLS_LANG=".AL32UTF8"
PATH="$PATH:$ORACLE_HOME/bin"

# For fucking with "go" the language
export GOROOT=$HOME/Workspace/go
export GOOS=darwin
export GOARCH=386
export GOBIN=$HOME/bin

