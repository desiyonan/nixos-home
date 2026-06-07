# root SSH 公钥；避免 switch 后 authorized_keys.d 被清导致无法登录
{ ... }:
{
  users.users.root.openssh.authorizedKeys.keys = import ./ssh-keys.nix;
}
