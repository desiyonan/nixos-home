# s72 — 云 VPS（srimsiuh-72）

DediOne 洛杉矶 CN 优化线（AS7488，4134/4837/58453），与 s60/s71 同类的最小化 KVM VPS：`disko` MBR 布局 + `lib.mkHost`（`secret-hub` / `dnf` 用户 / root 公钥）。

- 测试 IP：`144.225.130.19`
- 网卡：`eth0`（DHCP）
- 套餐参考：LAX.VPS.CN.2C4G80G（2C / 4G / 80G）

磁盘布局见 **`disko.nix`**：`vda1`=`/` ext4（含 `/boot`）、`vda2`=swap 1G。

## 首次安装（nixos-anywhere）

目标机需已开启 **root SSH**。会按 `disko.nix` **清空并重分区整盘**。

```bash
cd /data/workspace/repos/nixos-home

export TARGET=root@144.225.130.19

nix run github:nix-community/nixos-anywhere -- \
  --flake .#s72 \
  --target-host "$TARGET"
```

DNS 就绪后可将 `TARGET` 换为 `root@s72.dnfn.tech`。

## 日常更新

```bash
nixos-rebuild switch --flake .#s72 --target-host root@144.225.130.19
```

## 构建检查

```bash
nix build .#nixosConfigurations.s72.config.system.build.toplevel
nix path-info -rSh result
```

## Secret

主机 secret 目录 `secrets/data/hosts/srimsiuh-72/` 尚无时，`secret-hub` 仅加载 `extraSecrets`（默认无）；需要 3x-ui 等主机级 secret 后再登记 GPG 子钥：

```bash
cd secrets
nix run .#deployHostGPGSubKey -- \
  --host srimsiuh-72 \
  --target root@144.225.130.19
```

## 若 SSH 丢失

用服务商 **VNC/救援** 登录后恢复 root 公钥（公钥见 `mesh/users/root.nix`）：

```bash
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo '你的公钥一行' >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
systemctl restart sshd
```
