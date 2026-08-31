{ config, pkgs, lib, inputs, ... }:

let
  # Тема для SDDM
  sddmThemeSrc = pkgs.fetchFromGitHub {
    owner = "mahaveergurjar";
    repo = "sddm";
    rev = "pixel";
    hash = "sha256-bzA6WUZrXgQDJvOuK5JIcnPJNRhU/8AiKg3jgAeeoBM=";
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
#    ./modules/vaultwarden/vaultwarden.nix
    ./modules/vaultwarden/tailscale-immich.nix
];
# Создаём пользовательский сервис (он будет запускаться при входе)
# Включаем Flatpak (системный сервис)
services.fprintd.enable = true; 
programs.kdeconnect.enable = true;
#services.snixembed.enable = true;
programs.nh = {
  enable = true;
  
  # Автоматическая очистка мусора и старых конфигураций
  clean.enable = true;
  clean.extraArgs = "--keep-since 4d --keep 3";
  
  # Путь к вашей конфигурации
  flake = "/etc/nixos"; 
};

programs.appimage = {
    enable = true;
    binfmt = true;  # регистрирует AppImage как исполняемый формат
  };
services.gvfs.enable = true;
# --------------------------------------------------------------------------
  # 1a. GnuPG agent
  # --------------------------------------------------------------------------
 services.gnome.gnome-keyring.enable = true;
programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3; # Или pkgs.pinentry-qt / pkgs.pinentry-curses
  };

  # --------------------------------------------------------------------------
  # 2. Загрузчик, файловые системы и ЯДРО ZEN
  # --------------------------------------------------------------------------
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10; # сколько поколений системы показывать в меню загрузки
    consoleMode = "max";     # разрешение текстового меню
    editor = false;          # запретить редактировать boot-параметры из меню (безопасность)
  };
  boot.loader.timeout = 3;   # сек. до автозагрузки записи по умолчанию
  boot.loader.efi.canTouchEfiVariables = true;

  # Графический сплэш-экран при загрузке — у systemd-boot своей темы нет,
  # визуал живёт здесь, на этапе после передачи управления ядру.
  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  # === Ядро Zen ===
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # ЗАКОММЕНТИРОВАНО: используется systemd-boot (см. выше), boot.loader.grub.enable нигде
  # не включён — эта настройка темы GRUB ни на что не влияла (мёртвый код).
  # Если решишь перейти на GRUB — раскомментируй вместе с boot.loader.grub.enable = true;
  # boot.loader.grub.theme = inputs.nixos-grub-themes.packages.${pkgs.system}.nixos;

  fileSystems = {
    "/"     = { options = [ "compress=zstd" ]; };
    "/home" = { options = [ "compress=zstd" ]; };
    "/nix"  = { options = [ "compress=zstd" "noatime" ]; };
  };

  nix.settings.auto-optimise-store = true;
  nix.settings.max-jobs = "auto";
  nix.settings.cores = 0; # использовать все ядра CPU на сборку одной задачи

  # Автоматическая сборка мусора и дедупликация store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true; # периодическая дедупликация, отдельно от auto-optimise-store

  # --------------------------------------------------------------------------
  # 3. MPD, aria2, Caddy
  # --------------------------------------------------------------------------

  services.aria2 = {
    enable = true;
    rpcSecretFile = "/var/lib/aria2/rpc-secret";
    settings = {
      dir = "/home/krosh/Загрузки";
      max-connection-per-server = 16;
      split = 16;
      min-split-size = "1M";
      continue = true;
      max-concurrent-downloads = 5;
      rpc-listen-all = false;
      rpc-listen-port = 6800;
      enable-rpc = true;
      disk-cache = "64M";
      file-allocation = "falloc";
    };
  };

  services.caddy = {
    enable = true;
    # Явно слушаем только localhost — иначе AriaNG/JSON-RPC был бы доступен
    # всем в локальной сети без аутентификации (rpc-secret Caddy не передаёт).
    virtualHosts."127.0.0.1:80, localhost:80" = {
      extraConfig = ''
        root * ${pkgs.ariang}/share/ariang
        file_server
        reverse_proxy /jsonrpc localhost:${toString config.services.aria2.settings.rpc-listen-port}
      '';
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
  # 5. ZRAM, swap и гибернация
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

  # Гибернация: образ памяти сохраняется в swapfile.
  # Получить resume_offset нужно один раз после создания swapfile:
  #   sudo btrfs inspect-internal map-swapfile -r /var/lib/swapfile
  boot.resumeDevice = "/dev/disk/by-uuid/93b0d3a0-103e-4f35-b547-1dcceb20d3c6";
  boot.kernelParams = [
    "resume_offset=19308052"
    "quiet"
    "splash"
    "udev.log_level=3" # приглушить лишний вывод udev поверх сплэша
  ];
  boot.consoleLogLevel = 0; # без этого лог ядра будет мигать поверх Plymouth-анимации
  boot.initrd.verbose = false;

  services.logind.settings.Login = {
    HandlePowerKey = "hibernate";
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
  };

  # --------------------------------------------------------------------------
  # 6. Сеть, локализация, время
  # --------------------------------------------------------------------------
  networking.hostName = "krosh";
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  time.timeZone = "Asia/Yekaterinburg";
  services.timesyncd.enable = true;

  # --------------------------------------------------------------------------
  # 7. Пользователи и группы
  # --------------------------------------------------------------------------
  users.users.krosh = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "plugdev" "adbusers" "tailscale" ];
    shell = pkgs.zsh;
  };
  users.groups.shared-dl.members = [ "krosh" "aria2" ];

systemd.tmpfiles.rules = [
  "d /home/krosh/Загрузки 2775 krosh shared-dl -"
  "d /home/krosh/Загрузки/Tailscale 0755 krosh users -"
];
  # --------------------------------------------------------------------------
  # 8. Графика, SDDM, Niri, порталы
  # --------------------------------------------------------------------------
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm";
    extraPackages = with pkgs.kdePackages; [
      sddmTheme
      qtsvg
      qtdeclarative
      qt5compat
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
    # TODO: подпиши, для какого сервиса открыт порт 9300 (например: "# LocalSend")
    # — иначе через полгода будет непонятно, зачем он тут, и снять его будет страшно.
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
  hardware.graphics.enable = true;
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
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [ "noctalia.cachix.org-1:2mG2CubD5azvU4Vib9Is9v+3n/R8rOG2hAhfxJKKm4I=" ];
  };
  nixpkgs.config.allowUnfree = true;
  services.namaz-alerts.enable = true;
  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  # --------------------------------------------------------------------------
  # 11. Zsh и Fzf
  # --------------------------------------------------------------------------
  # Тема, плагины, алиасы и interactiveShellInit перенесены в home.nix —
  # home-manager активен (см. flake.nix), и держать их в двух местах
  # означало двойную загрузку oh-my-zsh с разными наборами плагинов.
  # Здесь остаётся только то, что должно быть системным: сам факт, что zsh
  # доступен как shell, и системные completion-пакеты.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    syntaxHighlighting.enable = true;
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
    # Отключено: открывает доп. порты для хостинга dedicated-серверов игр
    # (CS2, Source-игры и т.п.). Включи обратно, если реально их хостишь.
    dedicatedServer.openFirewall = false;
    # Официальная опция модуля programs.steam именно под баг с квадратиками
    # в клиенте (не в играх): Steam-клиент капризно читает шрифты и по
    # умолчанию берёт только config.fonts.packages — расширяем явно, чтобы
    # гарантированно попали кириллица/CJK/эмодзи, независимо от того, что
    # ещё лежит в fonts.packages.
    fontPackages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      dejavu_fonts
      liberation_ttf
    ];

    # fontPackages кладёт шрифты В СБОРКУ пакета, но песочница bubblewrap,
    # в которой реально стартует клиент, может не видеть /usr/share/fonts
    # внутри себя вообще — это известный незакрытый баг nixpkgs (issue
    # #209424). Жёстко пробрасываем путь руками: bind-mount
    # /run/current-system/sw/share/X11/fonts (создаётся благодаря
    # fonts.fontDir.enable ниже) прямо на /usr/share/fonts внутри контейнера.
    package = pkgs.steam.override {
      extraBwrapArgs = [
        "--ro-bind /run/current-system/sw/share/X11/fonts /usr/share/fonts"
      ];
    };
  };

  # Материализует реальные файлы шрифтов в /run/current-system/sw/share/X11/fonts
  # (а не только fontconfig.conf со ссылками на /nix/store) — нужно песочницам
  # вроде steam-run/FHS-окружений, которые ищут шрифты по классическим путям,
  # а не через fontconfig store-пути. Обязателен для bind-mount выше.
  fonts.fontDir.enable = true;

  # --------------------------------------------------------------------------
  # 13. Прочее (закомментированное)
  # --------------------------------------------------------------------------
  # home-manager подключается из flake.nix (home-manager.nixosModules.home-manager
  # + users.krosh.imports = [ ./home.nix ]), поэтому строки ниже не нужны — оставлены
  # закомментированными как справка, что именно и где реально включено.
  # home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  # home-manager.users.krosh = import ./home.nix;
  # programs.adb.enable = true;
  # services.happ.enable = true;
  # environment.etc."nixos/modules/waybar/colors.css".source = /home/krosh/colors.css;

  environment.systemPackages = with pkgs; [
    sddmTheme
    # другие пакеты, если есть
  ];

  services.power-profiles-daemon.enable = true; # или TLP, но не используйте оба одновременно
  services.upower.enable = true;

  # --------------------------------------------------------------------------
  # 14. Оптимизация системы
  # --------------------------------------------------------------------------
  # SSD: у тебя btrfs с compress=zstd, но без discard=async в опциях —
  # значит TRIM нужно делать периодически вручную/по таймеру.
  services.fstrim.enable = true;

  # /tmp в tmpfs — быстрее, и автоматически пуст после каждой перезагрузки
  # (cleanOnBoot не нужен вместе с useTmpfs — tmpfs и так очищается сама)
  boot.tmp.useTmpfs = true;

  boot.kernel.sysctl = {
    # У тебя уже есть zram (приоритет 100) поверх swapfile (приоритет 70).
    # Снижаем готовность ядра свопить вообще, раз zram и так под рукой.
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Упреждающий OOM-killer в userspace — реагирует до того, как ядро
  # заморозит систему под давлением памяти.
  systemd.oomd.enable = true;

  # Ограничение размера логов journald, чтобы не разрастались бесконтрольно
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

  # Удобная обёртка над nixos-rebuild (diff перед switch, генерации, gc)

  system.stateVersion = "26.05";
}
