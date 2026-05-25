{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;
in
{
  config = lib.mkIf (cfg.enable && cfg.rust.enable) {
    environment.systemPackages = with pkgs; [
      rustup
      jetbrains.rust-rover
      rust-analyzer
      cargo-watch
      cargo-edit
      cargo-nextest
      cargo-audit
      cargo-outdated
      sccache
      taplo
      bacon
    ];
  };
}
