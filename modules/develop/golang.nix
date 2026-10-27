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

    # 国内拉 module 用 goproxy.cn；sumdb 用谷歌中国镜像。
    # GOPROXY 在 buildGoModule 的 go-modules FOD 里属于 impureEnvVars，
    # 需进 nix.settings.impure-env 才能被 nix-daemon 传进构建。
    environment.variables = {
      GOPROXY = "https://goproxy.cn,direct";
      GOSUMDB = "sum.golang.google.cn";
    };

    nix.settings.impure-env = [
      "GOPROXY=https://goproxy.cn,direct"
      "GOSUMDB=sum.golang.google.cn"
    ];
  };
}
