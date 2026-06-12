# s60 — 云 VPS（srimsiuh-60）

与 s71 同类的最小化 KVM VPS：`disko` MBR 布局 + `lib.mkHost`（`secret-hub` / `dnf` 用户 / root 公钥）。

磁盘布局见 **`disko.nix`**：`vda1`=`/` ext4（含 `/boot`）、`vda2`=swap 1G。

## 首次安装（nixos-anywhere）

目标机需已开启 **root SSH**（密码或密钥均可）。会按 `disko.nix` **清空并重分区整盘**。

建议在本机构建（勿用 `--build-on` 指向小内存 VPS）：

```bash
cd /data/workspace/repos/nixos-home

# 将 TARGET 换成 IP 或域名，例如 root@s60.dnfn.tech
export TARGET=root@YOUR_VPS_IP

nix run github:nix-community/nixos-anywhere -- \
  --flake .#s60 \
  --target-host "$TARGET"
```

常用选项：

```bash
# 安装后不自动重启（便于检查日志）
nix run github:nix-community/nixos-anywhere -- \
  --flake .#s60 \
  --target-host "$TARGET" \
  --no-reboot

# 仅执行部分阶段（调试）
nix run github:nix-community/nixos-anywhere -- \
  --flake .#s60 \
  --target-host "$TARGET" \
  --phases disko,install,reboot
```

**注意：**

- 建议 **≥2GB 内存**；1GB 机器可能 kexec OOM，可先在面板临时升配
- 安装完成后用 `nixos-rebuild switch` 做后续更新，不必每次 anywhere
- 主机 secret 目录 `secrets/data/hosts/srimsiuh-60/` 尚无时，`secret-hub` 仅加载 `extraSecrets`（默认无）；需要主机级 secret 后再登记 GPG 子钥

## 日常更新

```bash
nixos-rebuild switch --flake .#s60 --target-host root@s60.dnfn.tech
```

## 构建检查

```bash
nix build .#nixosConfigurations.s60.config.system.build.toplevel
nix path-info -rSh result
```

## 若 SSH 丢失

用服务商 **VNC/救援** 登录后恢复 root 公钥（公钥见 `mesh/users/root.nix`）：

```bash
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo '你的公钥一行' >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
systemctl restart sshd
```
