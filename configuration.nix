{ config, pkgs, lib, ... }:

let
  sddmThemeSrc = pkgs.fetchFromGitHub {
    owner = "mahaveergurjar";
    repo = "sddm";
    rev = "pixel";
    hash = "sha256-bzA6WUZrXgQDJvOuK5JIcnPJNRhU/8AiKg3jgAeeoBM="; # подставьте свой реальный хеш
  };
  sddmTheme = pkgs.stdenv.mkDerivation {
    name = "sddm";
    src = sddmThemeSrc;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sddm
      cp -r $src/* $out/share/sddm/themes/sddm/
    '';
  };
in
{
  # --------------------------------------------------------------------------
  # 1. Импорты других модулей
  # --------------------------------------------------------------------------
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./keyboard.nix
    ./systemd-services.nix
    ./modules/vim/nixvim.nix
    ./modules/namaz/namaz.nix
    ./modules/rofi/rofi.nix
  ];

environment.systemPackages = with pkgs; [
    sddmTheme
# другие пакеты, если есть
  ];
  # --------------------------------------------------------------------------
  # 2. Загрузчик и файловые системы
  # --------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems = {
    "/"     = { options = [ "compress=zstd" ]; };
    "/home" = { options = [ "compress=zstd" ]; };
    "/nix"  = { options = [ "compress=zstd" "noatime" ]; };
  };

  # --------------------------------------------------------------------------
  # 3. MPD
  # --------------------------------------------------------------------------
  services.mpd = {
    enable = true;
    user = "krosh";
    group = "krosh";
    musicDirectory = "/home/krosh/Music/yandex/";
    playlistDirectory = "/home/krosh/.config/mpd/playlists";
    settings = {
      bind_to_address = "127.0.0.1";
      port = 6600;
      audio_output = [ { type = "pipewire"; name = "PipeWire"; } ];
    };
  };

  # --------------------------------------------------------------------------
  # 4. Rofi (ваш модуль)
  # --------------------------------------------------------------------------
  modules.rofi = {
    enable = true;
    # matugenIntegration.enable = true;  # по желанию
  };

  # --------------------------------------------------------------------------
  # 5. ZRAM и swap
  # --------------------------------------------------------------------------
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
    algorithm = "zstd";
  };
  swapDevices = [{
    device = "/var/lib/swapfile";
    priority = 70;
    size = 16 * 1024;
  }];

  # --------------------------------------------------------------------------
  # 6. Сеть, локализация, время
  # --------------------------------------------------------------------------
  networking.hostName = "krosh";
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  time.timeZone = "Asia/Yekaterinburg";
  services.timesyncd.enable = true;

  # --------------------------------------------------------------------------
  # 7. Пользователи
  # --------------------------------------------------------------------------
  users.users.krosh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "plugdev" "adbusers" ];
    shell = pkgs.zsh;
  };

  # --------------------------------------------------------------------------
  # 8. Графика, SDDM, Niri, порталы
  # --------------------------------------------------------------------------
services.displayManager.sddm = {
  enable = true;
  wayland.enable = true;   # обязательно!
  package = pkgs.kdePackages.sddm;
  theme = "sddm";
  extraPackages = with pkgs.kdePackages; [
  sddmTheme
   qtsvg
    qtdeclarative
    qt5compat                    # Добавляем модуль совместимости
    qtvirtualkeyboard
    ];
};
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # --------------------------------------------------------------------------
  # 9. Оборудование (Bluetooth, диски, графика, Avahi)
  # --------------------------------------------------------------------------
  networking.firewall = {
    allowedTCPPorts = [ 9300 ];
    allowedUDPPorts = [ 9300 ];
  };

  hardware.bluetooth = {
    powerOnBoot = true;
    enable = true;
  };
  services.blueman.enable = true;
  services.udisks2.enable = true;
  hardware.graphics.enable32Bit = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };

  # --------------------------------------------------------------------------
  # 10. Система (Nix, unfree, namaz, envfs)
  # --------------------------------------------------------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  services.namaz-alerts.enable = true;
  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  # --------------------------------------------------------------------------
  # 11. Zsh и Fzf
  # --------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;

    interactiveShellInit = ''
      pfetch
      eval "$(zoxide init zsh --cmd cd)"
      __zoxide_zi() {
        local dir
        dir="$(zoxide query -l | fzf --height 40% --layout=reverse --info=inline --prompt="⚡ Перейти в папку: ")" && cd "$dir"
        zle reset-prompt
      }
      zle -N __zoxide_zi
      bindkey '^G' __zoxide_zi
    '';

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };

    ohMyZsh = {
      enable = true;
      plugins = [ "git" "dirhistory" ];
      theme = "robbyrussell";
    };
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  # --------------------------------------------------------------------------
  # 12. Игры (Steam)
  # --------------------------------------------------------------------------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # --------------------------------------------------------------------------
  # 13. Прочее (закомментированное)
  # --------------------------------------------------------------------------
  # home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  # home-manager.users.krosh = import ./home.nix;
  # programs.adb.enable = true;
  # services.happ.enable = true;
  # environment.etc."nixos/modules/waybar/colors.css".source = /home/krosh/colors.css;

  system.stateVersion = "26.05";
}
