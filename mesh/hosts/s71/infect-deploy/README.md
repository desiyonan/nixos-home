# infect-deploy（兼容入口）

配置已合并到仓库根 **`#s71`**（`mesh/hosts/s71/`）。本目录仅保留部署脚本与 flake 别名。

## 部署

```bash
# 推荐：根 flake
cd /data/workspace/repos/nixos-home
nixos-rebuild switch --flake .#s71 --target-host root@s71.dnfn.tech

# 或本脚本（内部调用 .#s71）
./deploy.sh
```

`flake.nix` 中 `s71-minimal` 与 `s71` 均指向根 `nixosConfigurations.s71`。
