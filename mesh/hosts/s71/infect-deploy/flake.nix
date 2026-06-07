# 兼容旧路径：等价于仓库根 .#s71
{
  description = "s71 VPS minimal deploy (alias of nixos-home#s71)";

  inputs.nixos-home.url = "path:../../../..";

  outputs = { nixos-home, ... }: {
    nixosConfigurations = {
      s71-minimal = nixos-home.nixosConfigurations.s71;
      s71 = nixos-home.nixosConfigurations.s71;
    };
  };
}
