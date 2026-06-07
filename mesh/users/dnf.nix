{ ... }:
let
  # Steam 等沙箱应用只读用户级 fontconfig
  cjkFontconfig = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias binding="strong">
        <family>sans-serif</family>
        <prefer>
          <family>Noto Sans CJK SC</family>
          <family>WenQuanYi Zen Hei</family>
        </prefer>
      </alias>
      <alias binding="strong">
        <family>serif</family>
        <prefer>
          <family>Noto Serif CJK SC</family>
          <family>WenQuanYi Zen Hei</family>
        </prefer>
      </alias>
      <alias binding="strong">
        <family>monospace</family>
        <prefer>
          <family>Noto Sans Mono CJK SC</family>
          <family>WenQuanYi Zen Hei</family>
        </prefer>
      </alias>
    </fontconfig>
  '';
in
{ ... }:
{
  users.users.dnf = {
    name = "dnf";
    isNormalUser = true;
    isSystemUser = false;
    extraGroups = [
      "users"
      "wheel"
      "networkmanager"
      "video"
      "libvirtd"
      "root"
      "audio"
      "docker"
      "sudo"
    ];
    uid = 1000;
    initialPassword = "password";
    openssh.authorizedKeys.keys = import ./ssh-keys.nix;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";

    users.dnf = {
      home.stateVersion = "26.05";

      xdg.configFile."fontconfig/fonts.conf".text = cjkFontconfig;

      programs.bash.enable = true;

      programs.fzf = {
        enable = true;
        defaultOptions = [
          "--height 40%"
          "--layout=reverse"
          "--border"
        ];
        enableBashIntegration = true;
      };

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "desiyonan";
            email = "1310332521@qq.com";
          };
          pull.rebase = true;
        };
      };
    };
  };
}
