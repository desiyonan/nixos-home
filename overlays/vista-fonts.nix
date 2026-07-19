# Internet Archive 对 VistaFont_CHS.EXE 常 429；改用已验证 hash 一致的镜像
{ ... }:

final: prev: {
  vista-fonts-chs = prev.vista-fonts-chs.overrideAttrs (_old: {
    src = prev.fetchurl {
      url = "https://www.eeo.cn/download/font/VistaFont_CHS.EXE";
      hash = "sha256-saMIBEDTt9Ijv8g1nQHRNTG1ykIbHrCxjzdhhRYYleM=";
    };
  });
}
