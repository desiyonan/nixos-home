{ pkgs,  ... }:

{
  imports = [
    ./browser
    ./clang
    ./editor
    ./git
    ./golang
    ./java
    ./javascript
    ./rust
  ];

  environment.systemPackages = with pkgs;[
    feishu
  ];
}
