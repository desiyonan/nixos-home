# s71 — 云 VPS（最小化）

面向 RackNerd 等 KVM VPS，与 gw/ws 同样走 `lib.mkHost`（含 `emodules` / `secret-hub` / `home-manager` + `dnf` 用户）。

磁盘布局由 **`disko.nix`** 声明：MBR/dos，`vda1`=`/` ext4（含 `/boot`）、`vda2`=swap 1G，与 infect 后现盘一致。

## 模块

| 文件 | 作用 |
|------|------|
| `default.nix` | minimal + headless + qemu-guest profiles |
| `disko.nix` | MBR 两分区：root + swap |
| `configuration.nix` | profiles、网络/SSH、主机名、防火墙 |

root 公钥见 `mesh/users/root.nix`（经 `withUsers` 注入）。

## Secrets（age）

s71 用 **age** 解密，仅挂载 `hosts/srimsiuh-71/**`（见 `secrets.nix`）。私钥在 ws 本机：

```
~/.config/sops/srimsiuh-71-age-key
```

首次生成：

```bash
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/srimsiuh-71-age-key
```

## 部署

推荐一键部署（含 age-key 分发）：

```bash
cd /data/workspace/repos/nixos-home
bash mesh/hosts/s71/deploy.sh root@s71.dnfn.tech
```

仅 switch、不分发密钥：

```bash
nixos-rebuild switch --flake .#s71 --target-host root@s71.dnfn.tech
```

若磁盘紧张，部署前可在远端执行 `nix-collect-garbage -d`。

仅构建对比体积：

```bash
nix build .#nixosConfigurations.s71.config.system.build.toplevel
nix path-info -rSh result
```

## 若 SSH 丢失

`switch-to-configuration` 可能删除 `authorized_keys.d/root`。用 RackNerd **VNC/救援** 登录后：

```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo '你的公钥一行' >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
systemctl restart sshd
```

## 整盘重装（可选）

需要 **≥2GB 内存** 或接受 kexec OOM 风险；会按 `disko.nix` **清空并重分区**。

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#s71 \
  --target-host root@s71.dnfn.tech
```
