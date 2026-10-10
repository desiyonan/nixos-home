{ stdenv, fetchurl, dpkg }:

# Ubuntu 24.04 的 GTK/GLib 闭包。云枢 2.3.10.30 在这套库上能完成
# yunshuIsRunning 并画出窗口；NixOS 26.05 的 glib 2.88 会停在用户数据路径日志之后。
let
  debs = [
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/a/at-spi2-core/libatk-bridge2.0-0t64_2.52.0-1build1_amd64.deb";
      sha256 = "16wch2g9p66023kgn84jvs2i0xr03ffk1z9winkm6y8g7izd9dr2";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/a/at-spi2-core/libatk1.0-0t64_2.52.0-1build1_amd64.deb";
      sha256 = "1yd4hkf14pz60f9ba25zaxnqpswiyr26i1jb7hn7rwal16qd9ia2";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/a/at-spi2-core/libatspi2.0-0t64_2.52.0-1build1_amd64.deb";
      sha256 = "1mx187ilqbcjb044r281cy26rias58wnkpp8dhnrrjhf13jar1nn";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/b/brotli/libbrotli1_1.1.0-2build2_amd64.deb";
      sha256 = "0xxjwzd6m40jwam3a9kq67zzkln5mzvcx6lc9dvh7a7xp0cj8jbl";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/b/bzip2/libbz2-1.0_1.0.8-5.1ubuntu0.1_amd64.deb";
      sha256 = "0shj91ndh04473ivv419wfscjwrdgldqh0nf5y5h3r8y1fq0ivin";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/c/cairo/libcairo-gobject2_1.18.0-3build1_amd64.deb";
      sha256 = "00y4x1r8z10r4xbbl0i9vc11qwqapmkf3w57rglwjps58fz3qj7m";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/c/cairo/libcairo2_1.18.0-3build1_amd64.deb";
      sha256 = "0dmvdc7mydyf2hi77zj3ysn2vrsn7c57p4xv9116xzw9d0q0p5cn";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/d/dbus/libdbus-1-3_1.14.10-4ubuntu4.1_amd64.deb";
      sha256 = "021vjpja8lcvz68xx9hbv0a4vsh5lwzpm16f00il8jsby2008qsx";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/e/expat/libexpat1_2.6.1-2ubuntu0.6_amd64.deb";
      sha256 = "04qbqairkmpxif30vmii3a4wlhqsqd6br9x6pk3308bj5xkqwjs9";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/f/fontconfig/libfontconfig1_2.15.0-1.1ubuntu2_amd64.deb";
      sha256 = "11nmv39w99fv5fmgay53nz2c7gjyva7gjdjh522dn7q2xz7hbg52";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/f/freetype/libfreetype6_2.13.2%2bdfsg-1ubuntu0.2_amd64.deb";
      sha256 = "19l8vh5a95wzjfq93azfh9qamv7zyc26zmdj90pzm5v1ban3nvcc";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/f/fribidi/libfribidi0_1.0.13-3build1_amd64.deb";
      sha256 = "07fx8vrkls796fhn2wg7j0js1riqhlkccci6xspxzq4wsdch5mbc";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/gdk-pixbuf/libgdk-pixbuf-2.0-0_2.42.10%2bdfsg-3ubuntu3.3_amd64.deb";
      sha256 = "1fl6b9r7lfk4n5k751k6s312pimqwqw16jfq928y7jfrfzby116y";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/glib2.0/libglib2.0-0t64_2.80.0-6ubuntu3.9_amd64.deb";
      sha256 = "0vzh5jv00mbi7828q68nvj0sm702yrvq366kbnsj13m1i14gavm6";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/graphite2/libgraphite2-3_1.3.14-2ubuntu0.24.04.1_amd64.deb";
      sha256 = "1jqlx6xx3w4pnc7f4y4w9cgk9yk93mam1xf2ww763mkhcq7yl4r4";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/gtk%2b3.0/libgtk-3-0t64_3.24.41-4ubuntu1.3_amd64.deb";
      sha256 = "1z36a7nw56dc2hsbz1gi7bc0bdpw1rnj36072r1x44jb4c4f6qgx";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/h/harfbuzz/libharfbuzz0b_8.3.0-2build2_amd64.deb";
      sha256 = "0p3bd3flmqk02lqdwzkn4kv6nir98q6nhmm0cc2am62g4jifxxyn";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/l/lz4/liblz4-1_1.9.4-1build1.1_amd64.deb";
      sha256 = "1bfb9r6sc2bjam5r5hh2qhml66xhsx0wjlgypxg2viaw1lkk34ri";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libb/libbsd/libbsd0_0.12.1-1build1.1_amd64.deb";
      sha256 = "0vy8wr4hjaxnq9dhs1z4459qvs2b3pxnrgz9cd1gsp5ccc47p1gk";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libc/libcap2/libcap2_2.66-5ubuntu2.4_amd64.deb";
      sha256 = "0sidvvznpp6m51afrq4q71adqij99wj2z1b2irjjlmb6gk3jgii3";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libd/libdatrie/libdatrie1_0.2.13-3build1_amd64.deb";
      sha256 = "0izl4y3jaagsf5nhgnca4w1pl7srz5p1rkiqpm7sqgj11vj69q8s";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libe/libepoxy/libepoxy0_1.5.10-1build1_amd64.deb";
      sha256 = "07wzsckrcllyh0wpg8wgd2d8bcg9xfskq2bb8whr1f3z9vd59rz2";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libf/libffi/libffi8_3.4.6-1build1_amd64.deb";
      sha256 = "18iqy2svv1yaqv8skpj3903ajvjfsb8fzx2138rws26y8ivnlzk3";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt20/libgcrypt20_1.10.3-2ubuntu0.2_amd64.deb";
      sha256 = "02qacnp9gj6w13x052hxg3k9fchxlf5bnvfpspaz5xiwm3m9wywm";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libg/libgpg-error/libgpg-error0_1.47-3build2.1_amd64.deb";
      sha256 = "1vvs016vbpm2p23l25ndpsyblz6nfg31vi957wva0wqa33l4wrck";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_2.1.5-2ubuntu2_amd64.deb";
      sha256 = "1ch08nn2s5l3w4jm0sig09rmm2fz5izfsakxg3xqh5laphimp2zn";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libm/libmd/libmd0_1.1.0-2build1.1_amd64.deb";
      sha256 = "1rqffa6hwb7dy6zxyz7rwzin4wc5ah2slngcaypnl98zqk9h3fp5";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libs/libselinux/libselinux1_3.5-2ubuntu2.1_amd64.deb";
      sha256 = "06cdk0bwdz91fscd4kv3wpfxl76yhh73wxaa9iv1gvs6dz1adfka";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libt/libthai/libthai0_0.1.29-2build1_amd64.deb";
      sha256 = "022mmzk4m97l9q9ddj8xs3l70r5a00c1ajb49rvlnjpqqm2p1njs";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libx11/libx11-6_1.8.7-1build1_amd64.deb";
      sha256 = "102vzsg03pzaxz9jlvdyv2rnx1l21xpzzwrrddwcb8vnfhs88zrr";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxau/libxau6_1.0.9-1build6_amd64.deb";
      sha256 = "102w3k70hgr957hfbxx9a90hh1lh7pdf1szdrax968x6s7qjj3g4";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxcb/libxcb-render0_1.15-1ubuntu2_amd64.deb";
      sha256 = "1ibjq8amj002755jnjn5lknnpyvihdp215p4l9g3ns8sidka10vx";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxcb/libxcb-shm0_1.15-1ubuntu2_amd64.deb";
      sha256 = "0993vx6bwl6fwhznnr4s5n9j178xnvwx6f99q92bmwarsj015792";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxcb/libxcb1_1.15-1ubuntu2_amd64.deb";
      sha256 = "0n7shyb4pvb6p4k38yli3p2i8fscqfpjiw0vdwr9hwxd24fn3ip1";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxcomposite/libxcomposite1_0.4.5-1build3_amd64.deb";
      sha256 = "027kq058df21ys949hn93xb6fwxq6ap0w244yaxqqy8bwyd5sbd1";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxcursor/libxcursor1_1.2.1-1build1_amd64.deb";
      sha256 = "0kghx7v48rx0whlfq2hzi4yy89hic4rickig1pz44kj547kfwjqs";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxdamage/libxdamage1_1.1.6-1build1_amd64.deb";
      sha256 = "1v9mdlv9vs63zw54j03m69knzj9x0jfbngpmiv9fp5p94przm4b8";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxdmcp/libxdmcp6_1.1.3-0ubuntu6_amd64.deb";
      sha256 = "1fs2xvlcxranq6c8yzhl4agm48mgh1lmxyfh6igs9qhww7y3dlxw";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxext/libxext6_1.3.4-1build2_amd64.deb";
      sha256 = "0yan538q0bsx54nv9qsypk356k2qh44wdf1knyvxgsgcm5lkjy25";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxfixes/libxfixes3_6.0.0-2build1_amd64.deb";
      sha256 = "0jjy8n993rhj1h3qbr75l74qlg2ibzs0pkf006g28qyhrif03q8f";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxi/libxi6_1.8.1-1build1_amd64.deb";
      sha256 = "1nd85qks2ajcsg5ffppvggdkdqdz36ih63mkadk4vkm8x2ssr9qf";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxinerama/libxinerama1_1.1.4-3build1_amd64.deb";
      sha256 = "0fgj37k60xl802g5pavbhaiy8linrbs8mx0vyhaf61mvzlz3mjf8";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxkbcommon/libxkbcommon0_1.6.0-1build1_amd64.deb";
      sha256 = "0r6n49v62ykq3ifcnzj010ww4c665j3hpchwd8ll1dgg4fsax71b";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxrandr/libxrandr2_1.5.2-2build1_amd64.deb";
      sha256 = "0v95sr0wsqdnlrf5w3aaawvcp4d13qixjhfjiasj8msgb5g5m5gj";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxrender/libxrender1_0.9.10-1.1build1_amd64.deb";
      sha256 = "1si2mvqnvxnp7da4fb04y4kvvmkdya6xjbnxnls4i3dymqqxh2yp";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libz/libzstd/libzstd1_1.5.5%2bdfsg2-2build1.1_amd64.deb";
      sha256 = "09s7dlfid2kbmdvwrj3zpsgd1m6lbax81y7lsgpxgah73q32bkyz";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/p/pango1.0/libpango-1.0-0_1.52.1%2bds-1build1_amd64.deb";
      sha256 = "0m4zzk826fna4vxnhvii37bgq1y4zp7asc0qpk33w9xbh74abpq9";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/p/pango1.0/libpangocairo-1.0-0_1.52.1%2bds-1build1_amd64.deb";
      sha256 = "0xhkvfq0b0diz82i36skbnxs51pnv0ff9hfz43z12abc0z4mzkwq";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/p/pango1.0/libpangoft2-1.0-0_1.52.1%2bds-1build1_amd64.deb";
      sha256 = "0g91rk768gqa8qy7riybqnaqz6wa5liraj5amknjkwzmdvccjsyc";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/p/pcre2/libpcre2-8-0_10.42-4ubuntu2.1_amd64.deb";
      sha256 = "18194n182k8rcff7j9bmqmc809crh6ccyhd1jzj3wgb7axx7j2hi";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/p/pixman/libpixman-1-0_0.42.2-1build1_amd64.deb";
      sha256 = "089l47dp14iivz6kq79wh17bh266pw4axmcxmgp1aij29hf97hnr";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/s/systemd/libsystemd0_255.4-1ubuntu8.17_amd64.deb";
      sha256 = "1bkr95ag9yi61a8kdkzf4mr2g5ydgid9bxzk66pf5vr1gsnd4xj7";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/u/util-linux/libblkid1_2.39.3-9ubuntu6.6_amd64.deb";
      sha256 = "10pfa3lyz9v5ak15yn8gz6dryqpwj10951r2kc2kj9ayssf1dkrv";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/u/util-linux/libmount1_2.39.3-9ubuntu6.6_amd64.deb";
      sha256 = "1bksy1lk8x969g5d3vfjnjkjnv7f1apy4sxvqpysqz8qkxc2ab4g";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/w/wayland/libwayland-client0_1.22.0-2.1build1_amd64.deb";
      sha256 = "07c8hw1sk27v2cpzy1zg6lzgx3q5xc0qyips4bm9n53m3paaxw3a";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/w/wayland/libwayland-cursor0_1.22.0-2.1build1_amd64.deb";
      sha256 = "09ykf68q1qgfyslijabargs4216d25f66605ry2cjdwfgsi0vhi9";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/w/wayland/libwayland-egl1_1.22.0-2.1build1_amd64.deb";
      sha256 = "05ig7g7f6k2yiaiqhbzdm2fd7czfakcqz3qvanhf0a34fz91gkbn";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/x/xz-utils/liblzma5_5.6.1%2breally5.4.5-1ubuntu0.3_amd64.deb";
      sha256 = "0ljsg137v1csd7s7ri3rcbggyr6briwg8kjxkpfw5lkpr90vvsnj";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/z/zlib/zlib1g_1.3.dfsg-3.1ubuntu2.2_amd64.deb";
      sha256 = "0wz228rf52m245a526wvrxf0pixwkfxc9m3wqa99z75ja9bwzfc4";
    }
    {
      url = "http://security.ubuntu.com/ubuntu/pool/main/libp/libpng1.6/libpng16-16t64_1.6.43-5ubuntu0.7_amd64.deb";
      sha256 = "0v14gfd1l0mlww0p10h5kdgwbb7a0s7v3rlqpb720a4v12xnlgc6";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libx11/libx11-xcb1_1.8.7-1build1_amd64.deb";
      sha256 = "09xii8kci1shhlgffd80005l44x3rqvivnilpr110vnd8xz3a3bx";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/s/systemd/libudev1_255.4-1ubuntu8.17_amd64.deb";
      sha256 = "1c5xdqr77x0a101lhyrqm25dw37gj4yyvnpb8gyv53bk1xvs7zkf";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/k/keyutils/libkeyutils1_1.6.3-3build1_amd64.deb";
      sha256 = "12isd04xb0h3za7bq02ccrccf8rc0ar6z5fzdkj7k08jn2cg2y86";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/a/avahi/libavahi-client3_0.8-13ubuntu6.2_amd64.deb";
      sha256 = "1nglc9kkb70hp5n04jan06l47xvg7fhgnjzfzhsrw6jsx999nq00";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/a/avahi/libavahi-common3_0.8-13ubuntu6.2_amd64.deb";
      sha256 = "10hwvv7fmbzi8lhrbh3mfzzzs4rf1xh2ki3j116m0w0ylajgglgd";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/n/nspr/libnspr4_4.35-1.1build1_amd64.deb";
      sha256 = "1d077hla4nimd6q623c4h5dswnmicl8c6mm7yl9plv0z14nyfyg5";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/c/cups/libcups2t64_2.4.7-1.2ubuntu7.14_amd64.deb";
      sha256 = "1i4w9whlrng9yazhjiv2x82k6cp18njv8nq30gj191ki6vcs65dq";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/m/mesa/libgbm1_25.2.8-0ubuntu0.24.04.4_amd64.deb";
      sha256 = "0zns6jqk8dnad3jy11mvk4abj0cskvxky2hfm12v9dbd8n5k9zjb";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/a/alsa-lib/libasound2t64_1.2.11-1ubuntu0.3_amd64.deb";
      sha256 = "17vpbr7rpkxfm1s6nfwij4iwbwsvpvhlizjix4drzf9yd2svy5sx";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/libc6_2.39-0ubuntu8.9_amd64.deb";
      sha256 = "1gh8a210jk8k9gmzk6yz2zd5wmj5rjwnh8y9nz263xsikgcmfmgz";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/gmp/libgmp10_6.3.0%2bdfsg-2ubuntu6.1_amd64.deb";
      sha256 = "03dfycimkhpldld7fd0bikqmplvs8z9xiaapycrip3psbm88lpr8";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/k/krb5/libgssapi-krb5-2_1.20.1-6ubuntu2.10_amd64.deb";
      sha256 = "1cl7qlhh08fn9xhjivyhs1921lc7008799dz21m3xgnvpj3h2jhd";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libi/libidn2/libidn2-0_2.3.7-2build1.1_amd64.deb";
      sha256 = "1lvppqa8rrrs8b89nx178v8s5ja7lm3xw5c1ymjkp8lmy06x3gs6";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/gnutls28/libgnutls30t64_3.8.3-1.1ubuntu3.6_amd64.deb";
      sha256 = "1qljnq8wj98vddkn61yzljkmm40zjdgp86f0zavscphc4rb4g55q";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxshmfence/libxshmfence1_1.3-1build5_amd64.deb";
      sha256 = "0hn7nm93slpq2wsc0wkr98483c1i848zpg6lhfxahl4hmyzy8vdw";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/k/krb5/libkrb5support0_1.20.1-6ubuntu2.10_amd64.deb";
      sha256 = "0d7vfisicmwidwc8l3ajiy6qxy2pmv7jwrcpx92si0ka4kiys94j";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/k/krb5/libkrb5-3_1.20.1-6ubuntu2.10_amd64.deb";
      sha256 = "0ql3f1ibwz2gcv6ssqvdmc8ij4wfvhz5gmihpb5diw9k69d8rd30";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libt/libtasn1-6/libtasn1-6_4.19.0-3ubuntu0.24.04.2_amd64.deb";
      sha256 = "1rxx0jhxz361kvfz1h5qa0xay0h8pfkzqnys7d9fllpr8b8rlb7q";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/n/nettle/libnettle8t64_3.9.1-2.2build1.1_amd64.deb";
      sha256 = "0vs0ldy135b4qqqwd5xqrsxrfv306fscl77m10zhhcr6jz0zp5vd";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libu/libunistring/libunistring5_1.1-2build1.1_amd64.deb";
      sha256 = "18v5p03qxa2mpa2k2yvqyv4q7vsnsn2bgjd9l7xk6ipmnmbpcg90";
    }
    # NSS 证书库要 libsqlite3.so.0。缺这个文件时 Electron 在 nss_util 里直接中止。
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/s/sqlite3/libsqlite3-0_3.45.1-1ubuntu2.8_amd64.deb";
      sha256 = "1fxlq3nlpc2j98i52p0812i1qkxgbq34dah6fk2grxar4fvhn6di";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/n/nss/libnss3_3.98-1ubuntu0.2_amd64.deb";
      sha256 = "06k5m0fzibm0kmq6zdf48gni40a4knjijd8ig079gyrdg0fz2m22";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/k/krb5/libk5crypto3_1.20.1-6ubuntu2.10_amd64.deb";
      sha256 = "1nz918argxvvmrmj0sk4dvcah5ksf6vphghwyzbjgnb8bb4pqgr7";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/n/nettle/libhogweed6t64_3.9.1-2.2build1.1_amd64.deb";
      sha256 = "16zln34ls8dpa3swp6b716vflvxwdw26fdck3h70dacvsklzgdd9";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/p/p11-kit/libp11-kit0_0.25.3-4ubuntu2.2_amd64.deb";
      sha256 = "1wkv8x7xjmmd8d93z620vipdbg13hqmsbyid97qzb2cxq7m8mig7";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/e/e2fsprogs/libcom-err2_1.47.0-2.4~exp1ubuntu4.1_amd64.deb";
      sha256 = "1jdv0xkzxf9cla5nw3cmddmxhgh77zjdc6kpizdqdgysawq4vcks";
      name = "libcom-err2.deb";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-14/libgcc-s1_14.2.0-4ubuntu2~24.04.1_amd64.deb";
      sha256 = "1kb8mb13r6hxi5wv2rcmj84c4l650430862ki2cwz2xp6fzaszxa";
      name = "libgcc-s1.deb";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-14/libstdc++6_14.2.0-4ubuntu2~24.04.1_amd64.deb";
      sha256 = "1h2l3j1f4l33zxfhlvdcj9gsklca0mc23w1i3abdn4cjhbkqs7x5";
      name = "libstdc++6.deb";
    }
    {
      url = "http://archive.ubuntu.com/ubuntu/pool/main/libd/libdrm/libdrm2_2.4.125-1ubuntu0.1~24.04.2_amd64.deb";
      sha256 = "1145f5sa2axfaq99hnd5y2j49xsxng6xvic7kp21grkvsn6qagjd";
      name = "libdrm2.deb";
    }
  ];
in
stdenv.mkDerivation {
  pname = "yunshu-ubuntu-gui-libs";
  version = "24.04";

  srcs = map (
    d:
    fetchurl (
      { inherit (d) url sha256; }
      // (if d ? name then { inherit (d) name; } else { })
    )
  ) debs;

  nativeBuildInputs = [ dpkg ];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p unpack "$out/lib"
    for deb in $srcs; do
      dpkg-deb -x "$deb" unpack
    done
    shopt -s nullglob
    for libdir in unpack/usr/lib/x86_64-linux-gnu unpack/lib/x86_64-linux-gnu; do
      [[ -d "$libdir" ]] || continue
      find "$libdir" -maxdepth 1 \( -type f -o -type l \) -name '*.so*' -exec cp -a {} "$out/lib/" \;
      find "$libdir" -mindepth 1 -maxdepth 1 -type d -exec cp -a {} "$out/lib/" \;
    done
    find unpack -name ld-linux-x86-64.so.2 -exec cp -aL {} "$out/lib/ld-linux-x86-64.so.2" \;
    find "$out/lib" -maxdepth 1 -type l | while read -r link; do
      target=$(readlink "$link")
      if [[ "$target" = /* ]]; then
        base=$(basename "$target")
        if [[ -e "$out/lib/$base" ]]; then
          ln -sfn "$base" "$link"
        fi
      fi
    done
    runHook postInstall
  '';

  meta.priority = 1;
}
