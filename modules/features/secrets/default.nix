{config, lib, ...}:
let
  host = config.networking.hostName;
  all_users = config.users.users;
  # group = "users";
  ug = config.users.groups.users;
  # members
  users = lib.attrsets.mapAttrsToList (n: u: u) (lib.attrsets.filterAttrs (n: u: builtins.elem n ug.members) all_users);
  mkUserSecretsMount = u:
  let
    uid = builtins.toString u.uid;
    gid = builtins.toString ug.gid;
    n = u.name;
  in
    [
      "R  /run/user/${uid}/secrets - - - -"
      "D  /run/user/${uid}/secrets 700 ${uid} ${gid} - -"
      "C+ /run/user/${uid}/secrets/ssh - - - - /run/secrets/hosts/${host}/ssh"
      # "C+ /run/user/${uid}/secrets/ssh/ssh_config - - - - /run/secrets/hosts/ssh_config"
      "Z  /run/user/${uid}/secrets/* 400 ${uid} ${gid} - -"

      "R  /home/${n}/.ssh - - - -"
      "C+ /home/${n}/.ssh - - - - /run/user/${uid}/secrets/ssh"
      "Z  /home/${n}/.ssh/* 600 ${uid} ${gid} - -"
      "z  /home/${n}/.ssh/*.pub 644 ${uid} ${gid} - -"
      "z  /home/${n}/.ssh 700 ${uid} ${gid} - -"
    ]
  ;
  mkUsersSecretsMount = us: lib.lists.flatten (builtins.map mkUserSecretsMount us);
in
{
  systemd.tmpfiles.rules = mkUsersSecretsMount users ++
  [
    # "R! /run/user/1000/secrets - - - -"
    # "D  /run/user/1000/secrets 700 dnf users -"
    # "L+ /home/dnf/.ssh/ssh_config - - - - /run/secrets/hosts/ssh_config"
    # "D  /run/user/1000/secrets 744  0 - -"
    # "D  /run/user/1000/secrets/ssh 744 1000 0 - -"
    # "C+ /run/user/1000/secrets/ssh/s1_config - - - - /run/secrets/hosts/ssh_config"
    # "Z  /run/user/1000/secrets 600 1000 100 - -"
    # "z  /run/user/1000/secrets 700 1000 100 - -"

    # "C+ /home/dnf/.ssh/s1_config - - - - /run/secrets/hosts/ssh_config"
    # "Z  /home/dnf/.ssh 600 1000 100 - -"
    # "z  /home/dnf/.ssh/*.pub 644 1000 100 - -"
    # "z  /home/dnf/.ssh 700 1000 100 - -"
  ];
}
