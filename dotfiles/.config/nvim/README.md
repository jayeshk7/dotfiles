(not so much anymore) minimalistic neovim config. 

works for neovim v0.11+ 
current nvim version v0.11.5

if you let mason-lspconfig install treesitter-cli on its own you can get this error when you do :checkhealth nvim-treesitter (https://github.com/tree-sitter/tree-sitter/issues/4174)[https://github.com/tree-sitter/tree-sitter/issues/4174].
just uninstall treesitter-cli from :Mason and install it separately like so `npm install -g tree-sitter-cli@0.25.10`. this should fix it.
