{ config, lib, pkgs, ... }:

let
  cfg = config.modules.develop;

  developEnable = description:
    lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = description;
    };
in
{
  options.modules.develop = {
    enable = developEnable "Development toolchain and tools";

    golang.enable = developEnable "Go toolchain";
    python.enable = developEnable "Python toolchain";
    rust.enable = developEnable "Rust toolchain";
    javascript.enable = developEnable "Node.js toolchain";
    java.enable = developEnable "Java JDKs and programs.java";
    android.enable = developEnable "Android cmdline-tools (apkanalyzer, sdkmanager, …)";
    database.enable = developEnable "Database management tools";
    clang.enable = developEnable "Clang / LLVM toolchain";
    memorix.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Memorix HTTP control plane (user systemd). Disabled by default; run via Docker instead.";
    };
  };

  imports = lib.listModules ./.;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      feishu
      vscode
      unstable.code-cursor
      kdePackages.kate
      plantuml
    ];
  };
}
