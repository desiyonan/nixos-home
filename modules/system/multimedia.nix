{ config, lib, pkgs, ... }:

let
  cfg = config.modules.multimedia;
  rates = cfg.clock.allowedRates;
  audioHdaPriv = pkgs.writeShellApplication {
    name = "audio-hda-powersave";
    text = ''
      case "''${1:-}" in
        off)
          echo 0 >/sys/module/snd_hda_intel/parameters/power_save
          echo N >/sys/module/snd_hda_intel/parameters/power_save_controller
          ;;
        on)
          echo 10 >/sys/module/snd_hda_intel/parameters/power_save
          echo Y >/sys/module/snd_hda_intel/parameters/power_save_controller
          ;;
        *)
          echo "audio-hda-powersave: 用法: off|on" >&2
          exit 2
          ;;
      esac
    '';
  };
  audioClock = pkgs.writeShellApplication {
    name = "audio-clock";
    runtimeInputs = [
      pkgs.pipewire
      pkgs.gnugrep
      pkgs.gnused
      pkgs.pulseaudio
    ];
    text = ''
      export AUDIO_HDA_POWERSAVE=${lib.escapeShellArg (lib.getExe audioHdaPriv)}
      ${builtins.readFile ./audio-clock.sh}
    '';
  };
in
{
  options.modules.multimedia = {
    enable = lib.mkEnableOption "PipeWire audio stack and pavucontrol";

    clock = {
      defaultRate = lib.mkOption {
        type = lib.types.ints.positive;
        default = 48000;
        description = ''
          PipeWire 图时钟默认采样率。Conexant CX11970 原生 48/96/192 kHz；
          默认 48 kHz，有高采样流时在 allowedRates 内自动提升。
          设为 192000 即开机按声卡上限跑。
        '';
      };
      allowedRates = lib.mkOption {
        type = lib.types.listOf lib.types.ints.positive;
        default = [
          48000
          96000
          192000
        ];
        description = "允许的图时钟（应与模拟 codec 原生速率一致；本机无 44.1）";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      extraConfig.pipewire."10-clock-rates" = {
        "context.properties" = {
          "default.clock.rate" = cfg.clock.defaultRate;
          "default.clock.allowed-rates" = rates;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 2048;
        };
        "stream.properties" = {
          # 44.1 等非原生速率重采样质量（0–15，默认 4）
          "resample.quality" = 10;
        };
      };
      wireplumber = {
        enable = true;
        extraConfig.bluetoothEnhancements = {
          "wireplumber.settings" = {
            # 有录音/通话流时切 HFP（耳机麦），结束后回到 A2DP
            "bluetooth.autoswitch-to-headset-profile" = true;
          };
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            # 不要同时开 HSP+HFP：Sony XM 系列常见只有通话档、没有 A2DP
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "bap_sink"
              "bap_source"
              "hfp_hf"
              "hfp_ag"
            ];
          };
          "monitor.bluez.rules" = [
            {
              matches = [ { "device.name" = "~bluez_card.*"; } ];
              actions = {
                update-props = {
                  "device.profile" = "a2dp-sink";
                  "bluez5.auto-connect" = [
                    "a2dp_sink"
                    "a2dp_source"
                    "hfp_hf"
                    "hfp_ag"
                  ];
                };
              };
            }
          ];
        };
        extraConfig."alsa-native-rates" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "node.name" = "~alsa_output.*"; }
                { "node.name" = "~alsa_input.*"; }
              ];
              actions = {
                update-props = {
                  "audio.allowed-rates" = lib.concatMapStringsSep "," toString rates;
                };
              };
            }
          ];
        };
      };
    };

    # 关掉 HDA 自动休眠，避免空闲掉 D3、爆音，并保持 DAC 持续供电
    boot.extraModprobeConfig = ''
      options snd_hda_intel power_save=0 power_save_controller=N
    '';
    systemd.tmpfiles.rules = [
      "w /sys/module/snd_hda_intel/parameters/power_save - - - - 0"
      "w /sys/module/snd_hda_intel/parameters/power_save_controller - - - - N"
    ];

    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = lib.getExe audioHdaPriv;
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    environment.systemPackages = [
      pkgs.pavucontrol
      audioClock
    ];
  };
}
