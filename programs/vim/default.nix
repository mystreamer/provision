{ pkgs, config, lib, inputs, ... }:
  {
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ 
        coc-nvim 
        LanguageClient-neovim
        fzf-vim
        vim-airline 
        vim-slime
        dracula-vim
        windsurf-vim
        nerdtree
        vim-oscyank
        ];
      settings = { ignorecase = true; };
      extraConfig = '' 
      " general settings
      colorscheme dracula
      set hlsearch
      set bs=2
      set ai
      set ruler
      set hidden " needed for rename operations over multiple buffers in language server
      set mouse=a

      " May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
      " utf-8 byte sequence
      set encoding=utf-8
      " Some servers have issues with backup files, see #649
      set nobackup
      set nowritebackup

      " Clipboard
      set clipboard=unnamed

      " Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
      " delays and poor user experience
      set updatetime=300

      " Always show the signcolumn, otherwise it would shift the text each time
      " diagnostics appear/become resolved
      set signcolumn=yes

      " slime settings
      let g:slime_target = "tmux"
      let g:slime_paste_file = "$HOME/.slime_paste"

      " LanguageClient settings
      set rtp+=~/.vim/pack/XXX/start/LanguageClient-neovim
      let g:LanguageClient_serverCommands = {
        \ 'haskell': ['haskell-language-server-wrapper', '--lsp'],
        \ 'gf' : ['~/.nix-profile/bin/gf-lsp'],
        \ }
      '';
    };   
  }
