{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.namaz-alerts;

  # Основной скрипт: скачивает, парсит ДУМ РБ через номера строк, отправляет звук и уведомления
  prayerCheckScript = pkgs.writeShellScriptBin "prayer-check" ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.curl}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.libnotify}/bin:${pkgs.pipewire}/bin:${pkgs.alsa-utils}/bin:$PATH"

    CACHE_FILE="/tmp/dumrb_namaz.cache"
    CURRENT_TIME=$(date +"%H:%M")
    IN_20_MINS=$(date -d "+20 minutes" +"%H:%M")

    # Функция скачивания и неуязвимого парсинга (по номерам строк после ключевых блоков)
    fetch_times() {
      curl -sL --connect-timeout 10 "https://dumrb.com/namaz" > "$CACHE_FILE.raw" 2>/dev/null
      if [ $? -eq 0 ] && [ -s "$CACHE_FILE.raw" ]; then
        # Находим строки времени по регулярному выражению временного штампа вокруг блоков
        local all_times=$(grep -oE "[0-9]{2}:[0-9]{2}" "$CACHE_FILE.raw" | head -n 15)
        
        # Точечно вытаскиваем строго по порядку पांच основных намазов сайта ДУМ РБ
        local f_time=$(echo "$all_times" | sed -n '1p')
        local d_time=$(echo "$all_times" | sed -n '3p') # Пропускаем Восход (2p)
        local a_time=$(echo "$all_times" | sed -n '4p')
        local m_time=$(echo "$all_times" | sed -n '5p')
        local i_time=$(echo "$all_times" | sed -n '6p')

        # Проверяем, что парсинг прошел успешно и строки не пустые
        if [ -n "$f_time" ] && [ -n "$d_time" ]; then
          echo "Fajr=$f_time" > "$CACHE_FILE"
          echo "Dhuhr=$d_time" >> "$CACHE_FILE"
          echo "Asr=$a_time" >> "$CACHE_FILE"
          echo "Maghrib=$m_time" >> "$CACHE_FILE"
          echo "Isha=$i_time" >> "$CACHE_FILE"
          return 0
        fi
      fi
      return 1
    }

    # Кэшируем на 1 час. Если кэша нет или он устарел — качаем заново
    if [ ! -f "$CACHE_FILE" ] || [ $(find "$CACHE_FILE" -mmin +60) ]; then
      fetch_times
    fi

    # Если сайт ДУМ РБ недоступен или кэш пуст — подгружаем стабильные резервные таймиги Башкортостана
    if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then 
      source "$CACHE_FILE"
    else 
      Fajr="03:10"; Dhuhr="13:30"; Asr="18:58"; Maghrib="21:49"; Isha="23:19"
    fi

    play_distinct_sound() {
      if command -v pw-play >/dev/null 2>&1; then
        pw-play --frequency=900 --duration=0.15 >/dev/null 2>&1; sleep 0.1
        pw-play --frequency=900 --duration=0.15 >/dev/null 2>&1
      else
        aplay -q -d 1 /dev/zero --frequency=900 >/dev/null 2>&1
      fi
    }

    # Хадисы
    PRE_PRAYER_HADITHS_0="«Мосолман кешеһе тәһәрәт алғанда, уның йөҙөнән ул ҡараған гонаһтары һыу менән бергә ағып төшөр...» (Мөслим)."
    PRE_PRAYER_HADITHS_1="«Намаҙҙың асҡысы — таҙарыныу (тәһәрәт)» (Әбү Дауид)."
    PRE_PRAYER_HADITHS_2="«Таҙалыҡһыҙ бер намаҙ ҙа ҡабул ителмәҫ...» (Мөслим)."

    PRAYER_HADITHS_0="«Ҡиәмәт көнөндә Аллаһ ҡолоноң иң беренсе тикшереләсәк ғәмәле — намаҙ булыр...» (әт-Тирмизи)."
    PRAYER_HADITHS_1="«Аллаһ иң яратҡан ғәмәл — ваҡытында уҡылған намаҙ» (әл-Бухари)."
    PRAYER_HADITHS_2="«Кеше менән ширк араһында — намаҙҙы ҡалдырыу тора» (Мөслим)."

    check_prayer() {
      local name_bash="$1"
      local p_time="$2"

      if [ "$p_time" = "$IN_20_MINS" ]; then
        local r=$(( RANDOM % 3 ))
        local hadith=""
        case "$r" in
          0) hadith="$PRE_PRAYER_HADITHS_0" ;;
          1) hadith="$PRE_PRAYER_HADITHS_1" ;;
          *) hadith="$PRE_PRAYER_HADITHS_2" ;;
        esac
        notify-send "Тәһәрәткә әҙерлек" "$hadith\n\n🕒 Иҫкәртеү: $name_bash намаҙына 20 минут ҡалды. Тәһәрәт алырға ваҡыт етте." --icon=appointment-soon -u normal
        play_distinct_sound
      fi

      if [ "$p_time" = "$CURRENT_TIME" ]; then
        local r=$(( RANDOM % 3 ))
        local hadith=""
        case "$r" in
          0) hadith="$PRAYER_HADITHS_0" ;;
          1) hadith="$PRAYER_HADITHS_1" ;;
          *) hadith="$PRAYER_HADITHS_2" ;;
        esac
        notify-send "Намаҙ ваҡыты" "$hadith\n\n🕋 Изге ваҡыт етте: $name_bash намаҙы ($p_time)." --icon=appointment-soon -u critical
        for j in 1 2 3; do pw-play --frequency=650 --duration=0.2 >/dev/null 2>&1; sleep 0.1; done
      fi
    }

    check_prayer "Иртәнге (Фәжер)" "$Fajr"
    check_prayer "Өйлә" "$Dhuhr"
    check_prayer "Икенде" "$Asr"
    check_prayer "Аҡшам" "$Maghrib"
    check_prayer "Йәстү" "$Isha"
  '';

  # Скрипт продвинутого статус-бара: формирует JSON для Waybar
  prayerStatusScript = pkgs.writeShellScriptBin "prayer-status" ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:$PATH"
    CACHE_FILE="/tmp/dumrb_namaz.cache"

    if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then 
      source "$CACHE_FILE"
    else 
      Fajr="03:10"; Dhuhr="13:30"; Asr="18:58"; Maghrib="21:49"; Isha="23:19"
    fi

    NOW=$(date +%s)
    NEXT_NAME="Иртәнге"
    NEXT_TIME="$Fajr"
    CLASS="normal"

    check_next() {
      local name="$1"
      local t_str="$2"
      if [ "$CLASS" = "normal" ]; then
        local t_sec=$(date -d "$t_str" +%s)
        if [ $t_sec -gt $NOW ]; then
          NEXT_NAME="$name"
          NEXT_TIME="$t_str"
          if [ $((t_sec - NOW)) -le 1200 ]; then CLASS="warning"; fi
        fi
      fi
    }

    check_next "Иртәнге" "$Fajr"
    check_next "Өйлә" "$Dhuhr"
    check_next "Икенде" "$Asr"
    check_next "Аҡшам" "$Maghrib"
    check_next "Йәстү" "$Isha"

    TOOLTIP="<b>🌙 Бөгөнгө намаҙ ваҡыттары (ДҮМ РБ):</b>\n• Иртәнге:  $Fajr\n• Өйлә:     $Dhuhr\n• Икенде:   $Asr\n• Аҡшам:    $Maghrib\n• Йәстү:    $Isha"
    echo "{\"text\": \"🕋 $NEXT_NAME: $NEXT_TIME\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
  '';
in {
  options.services.namaz-alerts = {
    enable = mkEnableOption "Namaz alerts and status bar integration for Bashkortostan (DUM RB)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      prayerStatusScript
      prayerCheckScript
    ];

    systemd.user.services.namaz-check = {
      description = "Мониторинг времени намазов ДУМ РБ";
      script = "${prayerCheckScript}/bin/prayer-check";
    };

    systemd.user.timers.namaz-check = {
      description = "Ежеминутный таймер для намаза";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:*:00";
        Persistent = true;
      };
    };
  };
}

