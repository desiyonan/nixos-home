# 云 VPS 主机通用说明

适用于 `mesh/hosts` 下各 VPS 主机（如 `s61`、`s71`、`s72`）的统一部署与维护流程。主机通常采用最小化 KVM 方案：`disko` MBR 分区 + `lib.mkHost`（`secret-hub` / `dnf` 用户 / root 公钥）。

## 约定占位符

- `<HOST_FLAKE>`：主机 flake 名称（例如 `s61`）
- `<PUBLIC_IP>`：主机公网 IP
- `<HOSTNAME_OR_DOMAIN>`：主机域名或主机名
- `<HOST_ID>`：主机 ID（对应 `secrets/data/hosts/<HOST_ID>/`）

## 磁盘与系统

磁盘布局一般由主机目录内 `disko.nix` 定义，常见为：

- `vda1`：`/` ext4（含 `/boot`）
- `vda2`：swap（通常 1G）

## 首次安装（nixos-anywhere）

目标机需已开启 **root SSH**（密码或密钥均可）。安装会按 `disko.nix` **清空并重分区整盘**。

```bash
cd /data/workspace/repos/nixos-home

export TARGET=root@<PUBLIC_IP>

nix run github:nix-community/nixos-anywhere -- \
  --flake .#<HOST_FLAKE> \
  --target-host "$TARGET"
```

常用选项：

```bash
# 安装后不自动重启（便于检查日志）
nix run github:nix-community/nixos-anywhere -- \
  --flake .#<HOST_FLAKE> \
  --target-host "$TARGET" \
  --no-reboot

# 仅执行部分阶段（调试）
nix run github:nix-community/nixos-anywhere -- \
  --flake .#<HOST_FLAKE> \
  --target-host "$TARGET" \
  --phases disko,install,reboot
```

DNS 就绪后可将 `TARGET` 改为 `root@<HOSTNAME_OR_DOMAIN>`。

## 日常更新

```bash
nixos-rebuild switch --flake .#<HOST_FLAKE> --target-host root@<HOSTNAME_OR_DOMAIN>
```

## 构建检查

```bash
nix build .#nixosConfigurations.<HOST_FLAKE>.config.system.build.toplevel
nix path-info -rSh result
```

## Secret（secret-hub）

当 `secrets/data/hosts/<HOST_ID>/` 尚无数据时，`secret-hub` 仅加载 `extraSecrets`（默认无）。需要主机级 secret 时为该机生成**独立 RSA 钥**（非 dnfn 子钥），登记加密指纹到 `.sops.yaml`，并同步到目标机 `/var/lib/sops`（只装本机钥）：

```bash
cd secrets
nix run .#deployHostGPGSubKey -- \
  --host <HOST_ID> \
  --target root@<PUBLIC_IP>
```

## 若 SSH 丢失

通过服务商 **VNC/救援** 登录后恢复 root 公钥（公钥见 `mesh/users/root.nix`）：

```bash
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo '你的公钥一行' >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
systemctl restart sshd
```

## 维护建议

- 建议主机内存不少于 2GB；低内存机型可能在安装阶段出现 OOM
- 日常优先使用 `nixos-rebuild switch`，无需每次执行 `nixos-anywhere`
- 部署前可在远端执行 `nix-collect-garbage -d` 释放空间
