{ pkgs, mpkgs, ... }:

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

}
