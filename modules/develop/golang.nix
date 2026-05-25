{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;
in
{
  config = lib.mkIf (cfg.enable && cfg.golang.enable) {
    environment.systemPackages = with pkgs; [
      go
      golangci-lint
      jetbrains.goland
    ];

    # environment.variables.GOPATH = "/data/workspace/deps/go";
  };
}
