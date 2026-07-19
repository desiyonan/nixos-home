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

      # 字体：系统 defaultFonts + HM sharedModules 用户级 fonts.conf（Steam 必需）

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
