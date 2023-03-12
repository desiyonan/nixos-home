{ pkgs, mpkgs, ... }:

{

  environment.systemPackages = with pkgs;[
    go
    golangci-lint
  ];

}
