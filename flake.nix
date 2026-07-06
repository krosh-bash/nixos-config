{
  description = "Объединённая конфигурация NixOS с портабельным Niri и модульным Waybar";

  # =========================================================================
  # 1. Входные данные (Inputs) — внешние репозитории, от которых зависит конфиг
  # =========================================================================
  inputs = {
    # Основной репозиторий пакетов NixOS (нестабильная ветка bleeding-edge)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Флейк для обхода блокировок Telegram через прокси
    tg-ws-proxy.url = "github:pialtor/tg-ws-proxy-flake";

    # Флейк современного оптимизированного браузера Zen Browser
    zen-browser.url = "github:youwen5/zen-browser-flake";
    # Заставляем Zen Browser использовать те же пакеты nixpkgs, что и основная система
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    
    # Флейк Home Manager для декларативного управления домашней папкой пользователя
    home-manager = {
      url = "github:nix-community/home-manager";
      # Синхронизируем версию пакетов Home Manager с системными nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # =========================================================================
  # 2. Выходные данные (Outputs) — то, что флейк генерирует на основе входов
  # =========================================================================
  outputs = { self, nixpkgs, tg-ws-proxy, zen-browser, home-manager, ... }:
    let
      # Глобальные переменные для удобства повторного использования
      system = "x86_64-linux";  # Архитектура процессора вашего ПК
      username = "krosh";       # Имя вашей учетной записи пользователя
      lib = nixpkgs.lib;        # Синоним библиотеки утилит Nix для сокращения кода

      # Оверлей (наложение): регистрирует пакет zen-browser в глобальном наборе pkgs
      zen-overlay = final: prev: {
        zen-browser = zen-browser.packages.${final.system}.default;
      };

      # Функция для рекурсивного разворачивания сложной модульной структуры папок Waybar.
      # Она обходит папку ./modules/waybar и генерирует пути для Home Manager,
      # чтобы скрипты, темы и jsonc-файлы легли в ~/.config/waybar/ ровно так, как у автора темы.
      generateWaybarFiles = dir: 
        let
          allFiles = lib.filesystem.listFilesRecursive dir;
          toWaybarConfig = path: {
            name = "waybar/${lib.path.removePrefix ./modules/waybar path}";
            value = { source = path; };
          };
        in
          builtins.listToAttrs (map toWaybarConfig allFiles);

      # Универсальная функция-конструктор для сборки операционной системы (Host)
      mkHost = hostname: extraSystemModules: extraHomeModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          
          # Переменные, которые будут доступны внутри конфигурационных файлов NixOS
          specialArgs = {
            inherit tg-ws-proxy;
            hostName = hostname;
          };
          
          # Набор модулей, из которых строится ОС
          modules =
            [
              # Подключаем созданный выше оверлей браузера Zen
              { nixpkgs.overlays = [ zen-overlay ]; }
              
              # Главный конфигурационный файл системы (/etc/nixos/configuration.nix)
              ./configuration.nix
              
              # Интегрируем Home Manager как официальный системный модуль NixOS
              home-manager.nixosModules.home-manager
              
              # Настройка самого Home Manager для пользователя
              {
                home-manager = {
                  useGlobalPkgs = true;   # Использовать системные пакеты вместо скачивания отдельных
                  useUserPackages = true; # Устанавливать пакеты пользователя в его личный профиль
                  
                  # ДОБАВЛЕНО: Защита от конфликтов при активации (бэкап старых файлов)
                  # Если файл вроде ~/.config/mimeapps.list уже существует на диске,
                  # Home Manager автоматически переименует его в .list.backup и продолжит сборку
                  backupFileExtension = "backup";
                  
                  extraSpecialArgs = { inherit hostname; };
                  
                  # Привязка конкретного конфигурационного файла пользователя (home.nix)
                  users.${username} = {
                    imports = [
                      ./home.nix
                    ] ++ extraHomeModules;

                    # Вызов функции генерации модулей Waybar для домашнего профиля Krosh
                    xdg.configFile = generateWaybarFiles ./modules/waybar;
                  };
                };
              }
            ]
            # Дописываем специфичные модули конкретного компьютера (например, файлы аппаратной части)
            ++ extraSystemModules;
        };
    in {
      # Секция сборки конфигураций компьютера
      nixosConfigurations = {
        # Имя вашей готовой конфигурации системы. Вызывается через: sudo nixos-rebuild switch --flake .#krosh
        krosh = mkHost "krosh" 
          [ ] # Подключаем специфичный конфиг вашего ноутбука/ПК
          [ ];
      };

      # Экспортируем пакеты флейков наружу, чтобы их можно было запустить без установки через nix run
      packages.${system} = {
        tg-ws-proxy = tg-ws-proxy.packages.${system}.default;
        zen-browser = zen-browser.packages.${system}.default;
      };
      apps.${system}.tg-ws-proxy = tg-ws-proxy.apps.${system}.default;
    };
}

