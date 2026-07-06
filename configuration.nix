{ config, pkgs, ... }:

{
  # =========================================================================
  # 1. Импорты других конфигурационных модулей
  # =========================================================================
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./keyboard.nix
    ./font-packages.nix
    
    
    # ОБЯЗАТЕЛЬНО: Подключаем модуль home-manager на уровне системы
    # Если вы используете Flakes, это может быть: inputs.home-manager.nixosModules.home-manager
    # Если без Flakes (каналы), то строка ниже:
    # <home-manager/nixos>
  ];

  # =========================================================================
  # 2. Настройки загрузчика, ядра и файловых систем
  # =========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems = {
    "/" = { options = [ "compress=zstd" ]; };
    "/home" = { options = [ "compress=zstd" ]; };
    "/nix" = { options = [ "compress=zstd" "noatime" ]; };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  # =========================================================================
  # 3. Сеть, локализация и системное время
  # =========================================================================
  networking.hostName = "krosh";
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;

  # Настройка часового пояса для Уфы и синхронизация времени
  time.timeZone = "Asia/Yekaterinburg";
  services.timesyncd.enable = true;

  # =========================================================================
  # 4. Пользователи, группы и права доступа
  # =========================================================================
  users.users.krosh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "plugdev" "adbusers" ];
    shell = pkgs.zsh;
  };

  # =========================================================================
  # 5. Графическая подсистема, оконный менеджер и порталы
  # =========================================================================
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Включаем Niri на системном уровне для регистрации сессии в SDDM
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # =========================================================================
  # 6. Аппаратные службы (Bluetooth, Диски, Графика)
  # =========================================================================
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.udisks2.enable = true;
  hardware.graphics.enable32Bit = true;

  # =========================================================================
  # 7. Системные утилиты и окружение
  # =========================================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  
  programs.nix-ld.enable = true;
  services.envfs.enable = true;


  # =========================================================================
  # 8. Командный интерпретатор (Zsh) и поисковик (Fzf)
  # =========================================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    
    interactiveShellInit = ''
      pfetch
      
      # Инициализируем zoxide
      eval "''$(zoxide init zsh --cmd cd)"
      
      # Функция быстрого поиска zoxide + fzf
      __zoxide_zi() {
        local dir
        dir="''$(zoxide query -l | fzf --height 40% --layout=reverse --info=inline --prompt="⚡ Перейти в папку: ")" && cd "''$dir"
        zle reset-prompt
      }
      zle -N __zoxide_zi
      
      # НАВЕШИВАЕМ НА CTRL + G
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

  # Включаем официальный системный модуль FZF (он сам добавит Ctrl+R и Alt+C в Zsh)
  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };


  # =========================================================================
  # 9. Игровые и сторонние программы
  # =========================================================================
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # =========================================================================
  # 10. Закомментированные ранее параметры (сохранены без изменений)
  # =========================================================================
  # home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  # home-manager.users.krosh = import ./home.nix;
  # programs.adb.enable = true;
  # services.happ.enable = true;

  # Версия состояния дистрибутива
  system.stateVersion = "24.11";
}

