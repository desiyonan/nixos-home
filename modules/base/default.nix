# 无 enable 开关、默认随系统加载的基础模块（含 git、shell、时区等）
{ lib, ... }:
{
  imports = lib.listModules ./.;
}
