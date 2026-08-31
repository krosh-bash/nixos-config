{ pkgs, config, lib, ... }:

{
  programs.macchina = {
    enable = true;
    settings = {
      theme = "mytheme";
    };
  };

  xdg.configFile."macchina/themes/mytheme.toml".text = ''
 # Hydrogen

spacing         = 2
padding         = 0
hide_ascii      = true
separator       = ">"
key_color       = "Cyan"
separator_color = "White"

[palette]
type = "Full"
visible = false

[bar]
glyph           = "ߋ"
symbol_open     = '['
symbol_close    = ']'
hide_delimiters = true
visible         = true

[box]
border          = "plain"
visible         = true

[box.inner_margin]
x               = 1
y               = 0

[randomize]
key_color       = false
separator_color = false

[keys]
host            = "Host"
kernel          = "Kernel"
os              = "OS"
wm              = "WM"
distro          = "Distro"
shell           = "Shell"
packages        = "Packages"
memory          = "Memory"
machine         = "Machine"
disk_space      = "Disk Space"
'';
}
