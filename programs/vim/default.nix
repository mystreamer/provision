{ pkgs, config, lib, inputs, ... }:
  {
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ 
        vim-airline 
        coc-nvim 
        vim-slime
        fzf-vim
        dracula-vim
        ];
      settings = { ignorecase = true; };
      extraConfig = ''
      colorscheme dracula

      set mouse=a

      let g:slime_target = "tmux"
      let g:slime_paste_file = "$HOME/.slime_paste"
      '';
    };   
  }
