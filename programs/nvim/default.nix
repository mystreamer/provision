{ pkgs, config, lib, inputs, ... }:
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ 
        coc-nvim 
        # LanguageClient-neovim TODO: Substitute this!
        vim-lsp
        fzf-vim
        vim-airline 
        vim-slime
        dracula-vim
        windsurf-vim
        nerdtree
        vim-oscyank
        vim-commentary
        codecompanion-nvim
        nvim-treesitter.withAllGrammars
      ];
      extraLuaConfig = ''
      -- codecompanion setup
      require("codecompanion").setup({
        adapters = {
          http = {
            anthropic = function()
              return require("codecompanion.adapters").extend("anthropic", {
                env = {
                  api_key = "ANTHROPIC_API_KEY"
                },
                schema = {
                  model = {
                    default = "claude-3-5-sonnet-20241022",
                  },
                },
              })
            end,
          },
        },
        strategies = {
          chat = {
            adapter = "anthropic",
          },
          inline = {
            adapter = "anthropic",
          },
        },
        opts = {
          log_level = "INFO",
        }
      })
      '';
      extraConfig = '' 
        " case-insensitive searching
        set ignorecase
        " tab hacking
        " one: pressing the shift key shall be 4 REAL spaces
        set shiftwidth=4 smarttab
        " two: disable vim from inserting any tab characters at all
        set expandtab
        " three: make it easy to identify violations of the rule
        set tabstop=8 softtabstop=0

        " oscyank config
        nmap <leader>c <Plug>OSCYankOperator
        nmap <leader>cc <leader>c_
        vmap <leader>c <Plug>OSCYankVisual

        " general settings
        colorscheme dracula
        " set term=xterm-256color " should be set by default

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
        " set clipboard=unnamed

        " Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
        " delays and poor user experience
        set updatetime=300

        " Always show the signcolumn, otherwise it would shift the text each time
        " diagnostics appear/become resolved
        set signcolumn=yes

        " slime settings
        let g:slime_target = "tmux"
        let g:slime_paste_file = "$HOME/.slime_paste"

        " TODO: Move these LSPs to the vim-lsp plugin!
        " LanguageClient settings
        "set rtp+=~/.vim/pack/XXX/start/LanguageClient-neovim
        "let g:LanguageClient_serverCommands = {
        "  \ 'haskell': ['haskell-language-server-wrapper', '--lsp'],
        "  \ 'gf' : ['~/.nix-profile/bin/gf-lsp'],
        "  \ 'python' : ['basedpyright-langserver', '--stdio'],
        "  \ }

        " vim-lsp setup
"        if executable('basedpyright-langserver')
        " hook lsp
"        au User lsp_setup call lsp#register_server({
"            \ 'name': 'basedpyright-langserver',
"            \ 'cmd': {server_info->['basedpyright-langserver', '--stdio']},
"            \ 'allowlist': ['python'],
"            \ })
"        endif
"
"        function! s:on_lsp_buffer_enabled() abort
"        setlocal omnifunc=lsp#complete
"        setlocal signcolumn=yes
"        if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
"        nmap <buffer> gd <plug>(lsp-definition)
"        nmap <buffer> gs <plug>(lsp-document-symbol-search)
"        nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
"        nmap <buffer> gr <plug>(lsp-references)
"        nmap <buffer> gi <plug>(lsp-implementation)
"        nmap <buffer> gt <plug>(lsp-type-definition)
"        nmap <buffer> <leader>rn <plug>(lsp-rename)
"        nmap <buffer> [g <plug>(lsp-previous-diagnostic)
"        nmap <buffer> ]g <plug>(lsp-next-diagnostic)
"        nmap <buffer> K <plug>(lsp-hover)
"        nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
"        nnoremap <buffer> <expr><c-d> lsp#scroll(-4)
"
"        let g:lsp_format_sync_timeout = 1000
"        autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
"
"        " refer to doc to add more commands
"        endfunction
"
"        augroup lsp_install
"          au!
"          " call s:on_lsp_buffer_enabled only for languages that has the server registered.
"          autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
"        augroup END
      '';
    };   
  }
