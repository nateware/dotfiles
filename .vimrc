" mkdir -p ~/.vim/autoload ~/.vim/bundle
" curl -so ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/HEAD/autoload/pathogen.vim
" cd ~/.vim/bundle
" git clone git://github.com/tpope/vim-fugitive.git
" git clone git://github.com/tpope/vim-rails.git
" git clone git://github.com/tpope/vim-rake.git
" git clone git://github.com/tpope/vim-surround.git
" git clone git://github.com/tpope/vim-repeat.git
" git clone git://github.com/tpope/vim-commentary.git
"
set nocp
set tabstop=2 shiftwidth=2 expandtab
call pathogen#infect()
syntax on
filetype plugin indent on
colorscheme slate
