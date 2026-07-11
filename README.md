## ⚠️ Важно знать перед использованием
Данная конфигурация в гитхаб выложена в первую очередь для меня, для моего удобства в вопросе передачи этой конфигурации другим людям и в вопросе установки ее на новые машины. Сразу предупреждаю, что: 
1. она слегка сыровата.
2. в ней могут быть ошибки которые я не заметил из-за моей неопытности в NixOs.
3. Со временем я буду её редактировать и видоизменять.
4. Я попросил нейросеть добавить коментарии на русском языке, так как я переодически делюсь конфигурацией с друзьями. Ну и я часто забываю за что отвечает конкретный пакет. Из-за этого конфигурация может выглядеть слегка громоздко.

# NixOs + home-manager.

## Оглавление

- [⬇️ Установка](#id-Устоновка)
- [⚠️ Важно знать перед использованием](#-важно-знать-перед-использованием)
- [🖥️ Настройка Niri и Waybar](#-настройка-niri-и-waybar)
- [🚀 Дополнительные утилиты (zapret, tg-ws-proxy)](#-дополнительные-утилиты-zapret-tg-ws-proxy)
- [⌨️ Раскладка клавиатуры (Caps Lock переключение)](#-раскладка-клавиатуры-caps-lock-переключение)
- [🧭 Навигация по файловой системе (zoxide + fzf)](#-навигация-по-файловой-системе-zoxide--fzf)
- [🏠 Home-manager](#-home-manager)

##  ⬇️ Установка

```bash
git clone https://github.com/krosh-bash/nixos-config
```

Скопируйте содержимое репозитория в папку /etc/nixos/ 

```bash
cd nixos-config 
rm -rf hardware-configuration.nix
sudo mv -f * /etc/nixos #ВНИМАНИЕ!!! флаг -f перезапищет файлы без спроса.
```

Сделайте ребилд  и перезагрузите 

```bash
sudo nixos-rebuild --switch
reboot 
``` 

## 🖥️ Настройка Niri и Waybar

Изменение конфигурации Niri происходит только через, /etc/nixos/modules/niri/config.kdl после чего делается sudo nixos-rebuild. Если изменить конфигурацию в ~/. config/niri/ то все ваши изменения сохранятся, только до следующего sudo nixos-rebuild, так как в этой сборке /etc/nixos/modules/niri/common.nix отвечает за переписывания конфигурации niri.

Конфигурациные файлы waybar тоже должны лежать в этой директории.

## 🚀 Дополнительные утилиты (zapret, tg-ws-proxy)

Автоматический запуск запрета я пока не настроил, так что пока я запускаю его так: 
1.  Захожу в директорию /etc/nixos/zapret
2. Запустить auto_tune_youtube.sh, дождаться пока выдаст результаты.
3. После запустить service.sh и выбрать конфигурацию которую указал auto_tune_youtube.sh

В будущем попытаюсь автоматизировать этот процесс. Конфигурациные файлы  и сами скрипты для zapret я брал отсюда [ТЫК](https://github.com/Sergeydigl3/zapret-discord-youtube-linux)

Так же настроен tg-ws-proxy. Он должен запускается по команде.

```bash
tg-ws-proxy 
```

Подробнее как он работает можете почитать на странице у разработчика [Flowseal](https://github.com/Flowseal/tg-ws-proxy) Так же можете посмотреть как это реализовал этот разработчик [pialtor](https://github.com/pialtor/tg-ws-proxy-flake) Именно он сделал обёртку для NixOs

## ⌨️ Раскладка клавиатуры (Caps Lock переключение)

Насчёт конфигурации нири у меня настроено 2 языка клавиатуры: английский и башкирский вариант русской клавиатуры. Скорее всего вам не нужна башкирская клавиатура. Можете просто закоментировать строку variant в /etc/nixos/modules/niri/config.kdl.

```bash
 input {
  keyboard {
    xkb {
      layout "us,ru"
      variant ",bak" закоментировать эту строчку 
      options "grp:caps_toggle"
    }
``` 

Также не забудьте закоментировать блок  или изменить блок language в конфиг фале waybar. 
Он выглядит так:

```bash
  "niri/language": {
    "format": "{}",
9    "format-en": "US",
    "format-ru": "BA",
    "tooltip": false
   }
```

Язык клавиатуры меняется по клавише Capslock так как, я считаю, что на клавиатуре не должно быть абсолютно без полезной клавиши.

## 🧭 Навигация по файловой системе (zoxide + fzf)

В configuration.nix я настроил zoxide так, чтобы она перехватывала вызовы cd и работала вместо неё.
Для быстрого перехода в ранее посещённые директории настроена интеграция с fzf — по нажатию Ctrl+G открывается интерактивный список истории каталогов, из которого можно выбрать нужный.

```bash
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
```

## 🏠  Home-manager 
Настройки home-manager находятся в /etc/nixos/home.nix

Настроил открытие изображений формата .jpeg .png .gif .webp через imv, для удобства просмотра изображений в той же директории вызов происходит через imv-dir.

```bash
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "imv-dir.desktop" ];
      "image/png" = [ "imv-dir.desktop" ];
      "image/gif" = [ "imv-dir.desktop" ];
      "image/webp" = [ "imv-dir.desktop" ];
    };
  };
```

Здесь же именно в home.nix происходит активация модуля niri.

  ```bash
    imports = [
    ./modules/niri/common.nix
  ];
  ```

Какое то время искал тему для rofi, но так и руки не дотянулись установить менее вырвиглазную тему. Советую Вам, ее убрать.

```bash
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "JetBrainsMono Nerd Font 11";

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg-col = mkLiteral "#1e1e2e";
        bg-col-light = mkLiteral "#1e1e2e";
        border-col = mkLiteral "#cba6f7";
        selected-col = mkLiteral "#313244";
        blue = mkLiteral "#89b4fa";
        fg-col = mkLiteral "#cdd6f4";
        fg-col2 = mkLiteral "#f38ba8";
        grey = mkLiteral "#6c7086";
        width = 600;
      };

      "window" = {
        height = mkLiteral "360px";
        border = mkLiteral "2px";
        border-color = mkLiteral "@border-col";
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "8px";
      };

      "mainbox" = { 
        background-color = mkLiteral "@bg-col"; 
      };

      "inputbar" = {
        children = map mkLiteral [ "prompt" "entry" ];
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "5px";
        padding = mkLiteral "2px";
      };

      "prompt" = {
        background-color = mkLiteral "@blue";
        padding = mkLiteral "6px";
        text-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "3px";
        margin = mkLiteral "10px 0px 0px 10px";
      };

      "entry" = {
        padding = mkLiteral "6px";
        margin = mkLiteral "10px 10px 0px 10px";
        text-color = mkLiteral "@fg-col";
        background-color = mkLiteral "#181825";
      };

      "listview" = {
        border = mkLiteral "0px";
        padding = mkLiteral "6px 0px 0px";
        margin = mkLiteral "10px 10px 0px 10px";
        columns = 1;
        lines = 8;
        background-color = mkLiteral "@bg-col";
      };

      "element" = {
        padding = mkLiteral "5px";
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@fg-col";
      };

      "element selected" = {
        background-color = mkLiteral "@selected-col";
        text-color = mkLiteral "@blue";
        border-radius = mkLiteral "5px";
      };
    };
  };
```



## ⚠️ Important to know before using
This configuration is posted on GitHub primarily for myself – for my own convenience when sharing it with others and when setting it up on new machines. A heads‑up:
1. It’s a bit rough around the edges.
2. There might be bugs I haven’t noticed due to my inexperience with NixOS.
3. I’ll keep editing and tweaking it over time.
4. I asked an AI to add comments in Russian because I occasionally share this config with friends, and I often forget what each package does. So the config might look a bit bulky.
 
# NixOS + home-manager.

## Table of Contents
- [⬇️ Installation](#-installation)
- [⚠️ Important to know before using](#-important-to-know-before-using)
- [🖥️ Niri and Waybar setup](#-niri-and-waybar-setup)
- [🚀 Extra utilities (zapret, tg-ws-proxy)](#-extra-utilities-zapret-tg-ws-proxy)
- [⌨️ Keyboard layout (Caps Lock to switch)](#-keyboard-layout-caps-lock-to-switch)
- [🧭 Filesystem navigation (zoxide + fzf)](#-filesystem-navigation-zoxide--fzf)
- [🏠 Home‑manager](#-homemanager)

## ⬇️ Installation

```bash
git clone https://github.com/krosh-bash/nixos-config
```

Copy the repository contents to /etc/nixos/:

```bash
cd nixos-config 
rm -rf hardware-configuration.nix
sudo mv -i * /etc/nixos   # WARNING! The -i flag overwrites files without asking.
```

Rebuild and reboot:

```bash
sudo nixos-rebuild --switch
reboot 
```

## 🖥️ Niri and Waybar setup

Niri configuration is changed only via /etc/nixos/modules/niri/config.kdl, then you run sudo nixos-rebuild. If you edit the config in ~/.config/niri/, your changes will persist until the next sudo nixos-rebuild, because in this setup /etc/nixos/modules/niri/common.nix is responsible for overwriting the Niri configuration.

Waybar config files should also be placed in the same directory.

## 🚀 Extra utilities (zapret, tg-ws-proxy)

I haven’t set up autostart for zapret yet, so for now I run it manually:

1. Go to /etc/nixos/zapret
2. Run auto_tune_youtube.sh and wait for the results.
3. Then run service.sh and choose the configuration suggested by auto_tune_youtube.sh.

I plan to automate this in the future. The config files and scripts for zapret are taken from here.

I also have tg-ws-proxy set up. It is launched with the command:

```
tg-ws-proxy 
```

For more details, check the developer’s page Flowseal. You can also see how it was packaged for NixOS by pialtor – he made the flake wrapper.

## ⌨️ Keyboard layout (Caps Lock to switch)

In my Niri config I have two keyboard layouts: US English and Bashkir (a Russian variant). You probably don’t need Bashkir – just comment out the variant line in /etc/nixos/modules/niri/config.kdl.

```
 input {
  keyboard {
    xkb {
      layout "us,ru"
      variant ",bak"   # comment out this line
      options "grp:caps_toggle"
    }
```

Don’t forget to also comment out or change the language block in the Waybar config file. It looks like this:

```
  "niri/language": {
    "format": "{}",
    "format-en": "US",
    "format-ru": "BA",
    "tooltip": false
   }
```

I switch layouts with Caps Lock, because I think keyboards shouldn’t have a completely useless key.

## 🧭 Filesystem navigation (zoxide + fzf)

In configuration.nix I set up zoxide to intercept cd calls and work instead of the standard cd. For quick jumps to previously visited directories, I’ve integrated fzf – press Ctrl+G to open an interactive list of directory history, then pick the one you need.

```nix
    interactiveShellInit = ''
      pfetch
      
      # Initialize zoxide
      eval "''$(zoxide init zsh --cmd cd)"
      
      # Quick zoxide + fzf search function
      __zoxide_zi() {
        local dir
        dir="''$(zoxide query -l | fzf --height 40% --layout=reverse --info=inline --prompt="⚡ Go to folder: ")" && cd "''$dir"
        zle reset-prompt
      }
      zle -N __zoxide_zi
      
      # Bind to CTRL + G
      bindkey '^G' __zoxide_zi
    '';
```

## 🏠 Home‑manager

Home‑manager settings are in /etc/nixos/home.nix.

I set up image opening for formats .jpeg, .png, .gif, .webp with imv – for convenience, the launch uses imv-dir, so you can browse all images in the same directory.

```nix
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "imv-dir.desktop" ];
      "image/png" = [ "imv-dir.desktop" ];
      "image/gif" = [ "imv-dir.desktop" ];
      "image/webp" = [ "imv-dir.desktop" ];
    };
  };
```

It’s also here in home.nix that the Niri module is activated:

```nix
  imports = [
    ./modules/niri/common.nix
  ];
```

I spent some time looking for a rofi theme but never got around to installing one that isn’t an eyesore. I’d suggest you remove it.

```nix
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "JetBrainsMono Nerd Font 11";

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg-col = mkLiteral "#1e1e2e";
        bg-col-light = mkLiteral "#1e1e2e";
        border-col = mkLiteral "#cba6f7";
        selected-col = mkLiteral "#313244";
        blue = mkLiteral "#89b4fa";
        fg-col = mkLiteral "#cdd6f4";
        fg-col2 = mkLiteral "#f38ba8";
        grey = mkLiteral "#6c7086";
        width = 600;
      };

      "window" = {
        height = mkLiteral "360px";
        border = mkLiteral "2px";
        border-color = mkLiteral "@border-col";
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "8px";
      };

      "mainbox" = { 
        background-color = mkLiteral "@bg-col"; 
      };

      "inputbar" = {
        children = map mkLiteral [ "prompt" "entry" ];
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "5px";
        padding = mkLiteral "2px";
      };

      "prompt" = {
        background-color = mkLiteral "@blue";
        padding = mkLiteral "6px";
        text-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "3px";
        margin = mkLiteral "10px 0px 0px 10px";
      };

      "entry" = {
        padding = mkLiteral "6px";
        margin = mkLiteral "10px 10px 0px 10px";
        text-color = mkLiteral "@fg-col";
        background-color = mkLiteral "#181825";
      };

      "listview" = {
        border = mkLiteral "0px";
        padding = mkLiteral "6px 0px 0px";
        margin = mkLiteral "10px 10px 0px 10px";
        columns = 1;
        lines = 8;
        background-color = mkLiteral "@bg-col";
      };

      "element" = {
        padding = mkLiteral "5px";
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@fg-col";
      };

      "element selected" = {
        background-color = mkLiteral "@selected-col";
        text-color = mkLiteral "@blue";
        border-radius = mkLiteral "5px";
      };
    };
  };
```