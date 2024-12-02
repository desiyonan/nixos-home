{config, lib, pkgs, ...}:
with builtins;
let
  callTmpFilesRules = f: g: us:
    let
      users = lib.lists.toList us;
    in
    lib.lists.flatten (
      lib.lists.forEach users (u:
        let
          p = {
            n = u.name;
            uid = toString u.uid;
            gid = toString g.gid;
            inherit g u;
          };
        in f p
      )
    )
  ;

in rec {
  user = rec {
    buildCleanRules = g: u: (
      program.buildCleanRules g u ++
      runtime.buildCleanRules g u
    );

    buildMountRules = g: u: (
      runtime.buildMountRules g u ++
      program.buildMountRules g u
    );

    runtime = rec {
      buildCleanRules = callTmpFilesRules (
        {n, uid, gid, ...} : [
          "R! /run/user/${uid}/secrets 700 ${uid} ${gid} - -"
        ]
      );

      buildMountRules = callTmpFilesRules (
        {n, uid, gid, ...} : [
          "R  /run/user/${uid}/secrets 700 ${uid} ${gid} 0 -"
          "C+ /run/user/${uid}/secrets/ - - - - /run/secrets/hosts/%l/users/${n}"
          "Z  /run/user/${uid}/secrets/ 400 ${uid} ${gid} - -"
        ]
      );
    };
    program = rec {
      ssh = {
        buildCleanRules = callTmpFilesRules (
          {n, uid, gid, ...} : [
            "R! /home/${n}/.ssh 700 ${uid} ${gid} - -"
          ]
        );
        buildMountRules = callTmpFilesRules (
          {n, uid, gid, ...} : [
            "R  /home/${n}/.ssh 700 ${uid} ${gid} - -"
            "C+ /home/${n}/.ssh - - - - /run/secrets/hosts/%l/users/${n}/.ssh"
            "Z  /home/${n}/.ssh 600 ${uid} ${gid} - -"
            "z  /home/${n}/.ssh/*.pub 644 ${uid} ${gid} - -"
            "z  /home/${n}/.ssh/config.d 700 ${uid} ${gid} - -"
            "z  /home/${n}/.ssh 700 ${uid} ${gid} - -"
          ]
        );
      };
      buildCleanRules = g: u: (
        ssh.buildCleanRules g u
      );

      buildMountRules = g: u: (
        ssh.buildMountRules g u
      );
    };

  };

  host = rec {
    runtime = rec {
    };
    program = rec {
      clash = {
        buildCleanRules = callTmpFilesRules (
          {n, uid, gid, ...} : [
            "R! /etc/clash/config.yaml 700 0 0 - -"
          ]
        );
        buildMountRules = callTmpFilesRules (
          {n, uid, gid, ...} : [
            "R  /etc/clash/config.yaml 700 0 0 - -"
            "C+ /etc/clash/config.yaml - - - - /run/secrets/programs/clash/clash.yaml"
            "z  /etc/clash/config.yaml 644 0 0 - -"
          ]
        );
      };

      buildCleanRules = g: u: (
        clash.buildCleanRules g u
      );

      buildMountRules = g: u: (
        clash.buildMountRules g u
      );
    };

    buildCleanRules = g: u: (
      user.buildCleanRules g u
    );

    buildMountRules = g: u: (
      # runtime.buildMountRules g u ++
      program.buildMountRules g u
    );
  };

}
