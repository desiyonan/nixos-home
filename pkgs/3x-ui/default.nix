{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "3x-ui";
  version = "2.8.4";

  src = fetchFromGitHub {
    owner = "MHSanaei";
    repo = "3x-ui";
    rev = "v${version}";
    hash = "sha256-twTCFFpKBU8Sw+8f9Z4VkF9Xaf37XRH5G1dkr97/dzA=";
  };

  vendorHash = "sha256-lKmajeHEHEv47QWWJVgd3Me31lubJKKWIpdTvpgQm3c=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Xray panel supporting multi-protocol multi-user";
    homepage = "https://github.com/MHSanaei/3x-ui";
    license = licenses.gpl3Only;
    mainProgram = "3x-ui";
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
