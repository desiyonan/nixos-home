{config, lib, pkgs, ...}@args:
let
  helper = import ./secrets-for-user.nix args;

  host = config.networking.hostName;
  all_users = config.users.users;
  # group = users;
  ug = config.users.groups.users;
  # members
  users = lib.attrsets.mapAttrsToList (n: u: u) (lib.attrsets.filterAttrs (n: u: builtins.elem n ug.members) all_users);

  host_clean_conf = pkgs.writeTextFile {
    name = "nixos-tmpfiles.d";
    destination = "/lib/tmpfiles.d/00-host-${host}.conf";
    text = ''
      # This file is created automatically and should not be modified.

      ${lib.strings.concatStringsSep "\n" (helper.boot.buildCleanRules ug users)}
    '';
  };
  u = all_users.dnf;
  mount_confs = pkgs.writeTextFile {
    name = "nixos-tmpfiles.d";
    destination = "/lib/tmpfiles.d/users/00-${builtins.toString u.uid}.conf";
    text = ''
      # This file is created automatically and should not be modified.

      ${lib.strings.concatStringsSep "\n" (helper.user.buildMountRules ug u)}
    '';
  };
  services_config  = {
    "secrets-tmpfiles-setup@" = {
      enable = true;
      restartIfChanged = false;
      wantedBy = [
        "user-runtime-dir@%i.service"
      ];
      after = [ "user-runtime-dir@%i.service" ];
      before = [ "nixos-activation.service" ];
      unitConfig.DefaultDependencies = "no";

      serviceConfig = {
        Type = "oneshot";

        ExecStartPre=[
          "/bin/sh -c 'systemctl set-environment u=$(${pkgs.getent}/bin/getent passwd %i | cut -d: -f1)'"
          "/bin/sh -c 'cp ${mount_confs}/lib/tmpfiles.d/users/00-%i.conf /run/tmpfiles.d/00-user-%i.conf'"
        ];
        ExecStart = [
          "/bin/sh -c 'echo user=$u'"
          "systemd-tmpfiles --create --remove --clean --exclude-prefix=/dev --prefix=/run/user/%i --prefix=/home/dnf"
        ];
        ExecStartPost = [
          "/bin/sh -c 'rm -rf /run/tmpfiles.d/00-user-%i.conf'"
        ];
      };
    };
  } // (builtins.listToAttrs (map (u: {
    name = "secrets-tmpfiles-setup@${builtins.toString u.uid}";
    value = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      overrideStrategy = "asDropin";
    };
  }) users))
  ;
in
{
  systemd.tmpfiles.packages = [
    host_clean_conf
  ];
  systemd.services = services_config;
}
