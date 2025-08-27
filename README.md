# LinuxSetup

### For libvirtd (virtualization)

1. sudo vim /etc/libvirt/libvirtd.conf
2. Uncomment the following lines
  - unix_sock_group = "libvirt"
  - unix_sock_rw_perms = "0770"
3. You might have to add your user to the libvirt group again (sudo usermod -aG libvirt $USER)

### For neovim

`git clone https://github.com/neovim/nvim-lspconfig ~/.config/nvim/pack/nvim/start/nvim-lspconfig`

For built-in lsp support (before v0.12.0)
