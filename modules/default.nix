{ pkgs, systemConfig, lib, ...}:
with lib;

let
  cfg = systemConfig;
  hostType = if (cfg ? hostType) then
      cfg.hostType
    else [
      "gpc"
    ];
in {
  imports = [
    (
      if hostType == "ipc"  then ./ipc
      else ./gpc
    )
  ];
}
