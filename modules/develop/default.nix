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
    database.enable = developEnable "Database management tools";
    clang.enable = developEnable "Clang / LLVM toolchain";
  };

  imports = lib.listModules ./.;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      feishu
      vscode
      code-cursor
      kdePackages.kate
      plantuml
    ];
  };
}
