{ pkgs, config, lib, inputs, ... }:
  {
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ vim-airline coc-nvim ];
      settings = { ignorecase = true; };
      extraConfig = ''
        set mouse=a
      '';
    };   
  }
