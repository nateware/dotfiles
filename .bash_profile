[ -f $HOME/.bashrc ] && . $HOME/.bashrc

use_ruby=ruby-1.9.2-head 
echo "Setting rvm ruby to: $use_ruby"
rvm $use_ruby
type ruby

