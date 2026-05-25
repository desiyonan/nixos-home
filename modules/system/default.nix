# 按 host 启用的可选模块（options.modules.<name>.enable）
{ lib, ... }:
{
  imports = lib.listModules ./.;
}
