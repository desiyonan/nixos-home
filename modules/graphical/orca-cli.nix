# Keep desktop and CLI entries tied to the same native Orca package.
{ config, lib, pkgs, ... }:
let
  launcher = "${pkgs.orca-ide}/bin/orca-ide";
in {
  config = lib.mkIf config.modules.graphical.enable {
    home-manager.sharedModules = [ {
      # Replace stale user-profile entries that shadow the system desktop file.
      xdg.dataFile."applications/Orca.desktop" = {
        source = "${pkgs.orca-ide}/share/applications/Orca.desktop";
        force = true;
      };

      # Explicit command also avoids GNOME's unrelated `orca` screen reader and
      # Orca's generated shim taking precedence in inherited PATH values.
      home.file.".local/bin/orca-ide".source = launcher;
      home.file.".local/bin/orca".source = launcher;
      programs.bash.shellAliases.orca = launcher;
      programs.bash.shellAliases.orca-ide = launcher;
    } ];
  };
}
